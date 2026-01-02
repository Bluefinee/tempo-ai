//
//  HomeViewModel.swift
//  TempoAI
//
//  Home Screen ViewModel with Labor Illusion Support
//

import Combine
import CoreLocation
import Foundation

// MARK: - HomeViewModel

/// Home画面のViewModel
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    /// AIアドバイス
    @Published var dailyAdvice: DailyAdvice?

    /// コンディション評価
    @Published var conditionAssessment: ConditionAssessment?

    /// キャリブレーション状態
    @Published var calibrationState: CalibrationState?

    /// ユーザープロフィール
    @Published var userProfile: UserProfile?

    /// 気分（主観）
    @Published var mood: Mood?

    /// 今日のモード
    @Published var todayMode: TodayMode?

    /// 気象データ
    @Published var weather: WeatherData?

    /// ローディング中か
    @Published var isLoading: Bool = false

    /// ローディングステップ（Labor Illusion用: 0-3）
    @Published var loadingStep: Int = 0

    /// エラー
    @Published var error: HomeError?

    /// Morning Check-in完了済みか
    @Published var isMorningCheckInCompleted: Bool = false

    /// 現在の位置情報
    @Published var currentLocation: CLLocation?

    /// 現在の都市名
    @Published var currentCity: String?

    // MARK: - Constants

    /// Labor Illusionローディングステップ
    static let loadingSteps: [String] = [
        "睡眠データを解析中...",
        "自律神経バランスを計算中...",
        "今日の環境を確認中...",
        "あなたへのアドバイスを作成中..."
    ]

    /// ローディングステップ間隔（秒）
    private static let loadingStepInterval: TimeInterval = 0.8

    // MARK: - Dependencies

    private let adviceAPIClient: APIClientProtocol
    private let scoreCalculator: ScoreCalculator
    private let weatherAPIClient: WeatherAPIClientProtocol
    private let localStorage: LocalStorageProtocol
    private let healthKitRepository: HealthKitRepositoryProtocol

    // MARK: - Computed Properties

    /// 挨拶文
    var greeting: String {
        let hour: Int = Calendar.current.component(.hour, from: Date())
        let nickname: String = userProfile?.nickname ?? "ゲスト"

        switch hour {
        case 5..<12:
            return "\(nickname)さん、おはようございます"
        case 12..<17:
            return "\(nickname)さん、こんにちは"
        default:
            return "\(nickname)さん、こんばんは"
        }
    }

    /// 現在のローディングメッセージ
    var currentLoadingMessage: String {
        guard loadingStep < Self.loadingSteps.count else {
            return Self.loadingSteps.last ?? ""
        }
        return Self.loadingSteps[loadingStep]
    }

    /// キャリブレーション中か
    var isCalibrating: Bool {
        guard let state = calibrationState else { return true }
        return !state.isComplete
    }

    /// スコア表示可能か
    var canShowScores: Bool {
        !isCalibrating && conditionAssessment != nil
    }

    // MARK: - Initialization

    init(
        adviceAPIClient: APIClientProtocol = AdviceAPIClient(),
        scoreCalculator: ScoreCalculator = ScoreCalculator(),
        weatherAPIClient: WeatherAPIClientProtocol = WeatherAPIClient(),
        localStorage: LocalStorageProtocol = LocalStorage(),
        healthKitRepository: HealthKitRepositoryProtocol = HealthKitRepository()
    ) {
        self.adviceAPIClient = adviceAPIClient
        self.scoreCalculator = scoreCalculator
        self.weatherAPIClient = weatherAPIClient
        self.localStorage = localStorage
        self.healthKitRepository = healthKitRepository

        // ローカルデータを初期ロード
        loadLocalData()
    }

    // MARK: - Public Methods

    /// ダッシュボードデータを読み込む
    func loadDashboardData() async {
        guard !isLoading else { return }

        isLoading = true
        loadingStep = 0
        error = nil

        do {
            // ローカルデータを再読み込み
            loadLocalData()

            // Step 1: 睡眠データを解析中
            try await advanceLoadingStep()
            let healthMetrics: HealthMetrics = try await healthKitRepository.fetchTodayMetrics()

            // Step 2: 自律神経バランスを計算中
            try await advanceLoadingStep()
            let sleepHistory: [SleepMetrics] = try await healthKitRepository.fetchSleepHistory(days: 7)
            let rhythmAnalysis: RhythmAnalysis = calculateRhythmAnalysis(from: sleepHistory)

            // スコア計算
            conditionAssessment = scoreCalculator.calculateAll(
                healthMetrics: healthMetrics,
                rhythmAnalysis: rhythmAnalysis
            )

            // Step 3: 今日の環境を確認中
            try await advanceLoadingStep()
            await loadWeatherData()

            // Step 4: あなたへのアドバイスを作成中
            try await advanceLoadingStep()
            await loadDailyAdvice(healthMetrics: healthMetrics, rhythmAnalysis: rhythmAnalysis)

            // キャリブレーション状態を更新
            updateCalibrationState(healthDataDays: sleepHistory.count)

        } catch let healthKitError as HealthKitError {
            error = .healthKitError(healthKitError.localizedDescription)
        } catch {
            self.error = .dataLoadFailed
        }

        isLoading = false
    }

    /// データをリフレッシュ
    func refreshData() async {
        await loadDashboardData()
    }

    /// Morning Check-inを送信
    func submitMorningCheckIn() async {
        guard mood != nil, todayMode != nil else { return }

        // ローカルに保存
        saveMoodLog()
        saveTodayModeLog()

        isMorningCheckInCompleted = true

        // AI Adviceを再取得（mood/todayModeを反映）
        if let assessment = conditionAssessment {
            await loadDailyAdvice(
                healthMetrics: nil,
                rhythmAnalysis: assessment.rhythmAnalysis
            )
        }
    }

    /// フィードバックを送信
    func submitFeedback(_ isHelpful: Bool) async {
        let feedback: FeedbackLog = FeedbackLog(
            date: Date(),
            isHelpful: isHelpful,
            adviceSummary: dailyAdvice?.summary
        )

        saveFeedbackLog(feedback)
    }

    /// 位置情報を設定
    func setLocation(_ location: CLLocation, city: String?) {
        currentLocation = location
        currentCity = city
    }

    // MARK: - Private Methods

    private func loadLocalData() {
        userProfile = localStorage.load(forKey: StorageKeys.userProfile)
        calibrationState = localStorage.load(forKey: StorageKeys.calibrationState)

        // 今日のMood/TodayModeログを確認
        if let moodLogs: [MoodLog] = localStorage.load(forKey: StorageKeys.moodLogs) {
            let today: Date = Calendar.current.startOfDay(for: Date())
            if let todayLog = moodLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                mood = todayLog.mood
                isMorningCheckInCompleted = true
            }
        }

        if let modeLogs: [TodayModeLog] = localStorage.load(forKey: StorageKeys.todayModeLogs) {
            let today: Date = Calendar.current.startOfDay(for: Date())
            if let todayLog = modeLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                todayMode = todayLog.mode
            }
        }

        // 今日のアドバイスをキャッシュから読み込み
        let adviceKey: String = StorageKeys.advice(for: Date())
        dailyAdvice = localStorage.load(forKey: adviceKey)
    }

    private func advanceLoadingStep() async throws {
        try await Task.sleep(nanoseconds: UInt64(Self.loadingStepInterval * 1_000_000_000))
        if loadingStep < Self.loadingSteps.count - 1 {
            loadingStep += 1
        }
    }

    private func loadWeatherData() async {
        guard let location = currentLocation else {
            // 位置情報がない場合はスキップ
            return
        }

        do {
            weather = try await weatherAPIClient.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } catch {
            // 天気データの取得失敗は致命的ではないので無視
        }
    }

    private func loadDailyAdvice(healthMetrics: HealthMetrics?, rhythmAnalysis: RhythmAnalysis) async {
        guard let profile = userProfile else {
            dailyAdvice = .fallback()
            return
        }

        // 今日のアドバイスがキャッシュにあればそれを使用
        let adviceKey: String = StorageKeys.advice(for: Date())
        if let cached: DailyAdvice = localStorage.load(forKey: adviceKey),
           !cached.isOfflineFallback {
            dailyAdvice = cached
            return
        }

        // API リクエストを構築
        let request: AdviceRequestDTO = buildAdviceRequest(
            profile: profile,
            healthMetrics: healthMetrics,
            rhythmAnalysis: rhythmAnalysis
        )

        do {
            let response: AdviceResponseDTO = try await adviceAPIClient.fetchAdvice(request)
            if let advice = response.toDomain() {
                dailyAdvice = advice
                localStorage.save(advice, forKey: adviceKey)
            } else {
                dailyAdvice = .fallback()
            }
        } catch {
            dailyAdvice = .fallback()
        }
    }

    private func buildAdviceRequest(
        profile: UserProfile,
        healthMetrics: HealthMetrics?,
        rhythmAnalysis: RhythmAnalysis
    ) -> AdviceRequestDTO {
        let profileDTO: ProfileDTO = ProfileDTO.from(profile)

        let scoresDTO: ScoresDTO = ScoresDTO(
            autonomic: conditionAssessment?.autonomicScore.value ?? 50,
            sleep: conditionAssessment?.sleepScore.value ?? 50,
            rhythm: conditionAssessment?.rhythmScore.value ?? 50,
            activity: conditionAssessment?.activityScore.value ?? 50
        )

        let rhythmAnalysisDTO: RhythmAnalysisDTO = RhythmAnalysisDTO.from(rhythmAnalysis)

        var sleepDTO: SleepDTO?
        if let sleep = healthMetrics?.sleep {
            sleepDTO = SleepDTO.from(sleep)
        }

        var hrvDTO: HRVDTO?
        if let hrv = healthMetrics?.hrv {
            hrvDTO = HRVDTO.from(hrv)
        }

        var activityDTO: ActivityDTO?
        if let activity = healthMetrics?.activity {
            activityDTO = ActivityDTO.from(activity)
        }

        var auxiliaryDTO: AuxiliaryDTO?
        if let auxiliary = healthMetrics?.auxiliary {
            auxiliaryDTO = AuxiliaryDTO.from(auxiliary)
        }

        let healthDataDTO: HealthDataDTO = HealthDataDTO(
            scores: scoresDTO,
            rhythmAnalysis: rhythmAnalysisDTO,
            sleep: sleepDTO,
            hrv: hrvDTO,
            activity: activityDTO,
            auxiliary: auxiliaryDTO
        )

        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime: String = formatter.string(from: Date())

        let weekdaySymbols: [String] = ["", "日", "月", "火", "水", "木", "金", "土"]
        let weekday: Int = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek: String = weekdaySymbols[weekday]

        let contextDTO: ContextDTO = ContextDTO(
            currentTime: currentTime,
            dayOfWeek: dayOfWeek,
            todayMode: (todayMode ?? .normal).rawValue,
            mood: mood?.rawValue
        )

        let locationDTO: LocationDTO
        if let location = currentLocation {
            locationDTO = LocationDTO(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: currentCity ?? "不明"
            )
        } else {
            // デフォルト値（東京）
            locationDTO = LocationDTO(
                latitude: 35.6762,
                longitude: 139.6503,
                city: "東京"
            )
        }

        var weatherDTO: WeatherDTO?
        if let w = weather {
            weatherDTO = WeatherDTO(
                temperature: w.temperature,
                humidity: Double(w.humidity),
                pressure: w.pressure,
                weatherCode: w.weatherCode,
                uvIndexMax: Double(w.uvIndex)
            )
        }

        return AdviceRequestDTO(
            profile: profileDTO,
            healthData: healthDataDTO,
            location: locationDTO,
            context: contextDTO,
            weather: weatherDTO
        )
    }

    private func calculateRhythmAnalysis(from sleepHistory: [SleepMetrics]) -> RhythmAnalysis {
        guard sleepHistory.count >= 2 else {
            return RhythmAnalysis(
                bedtimeStddevMinutes: 60,
                wakeTimeStddevMinutes: 60,
                consecutiveStableDays: 0,
                wristTemperature: nil
            )
        }

        // 就寝時刻の標準偏差を計算
        let bedtimes: [Double] = sleepHistory.map { $0.bedtime.timeIntervalSince1970 }
        let wakeTimes: [Double] = sleepHistory.map { $0.wakeTime.timeIntervalSince1970 }

        let bedtimeStddev: Double = standardDeviation(bedtimes) / 60 // 秒→分
        let wakeTimeStddev: Double = standardDeviation(wakeTimes) / 60

        // 連続安定日数（stddev <= 30分）
        let stableDays: Int = bedtimeStddev <= 30 && wakeTimeStddev <= 30 ? sleepHistory.count : 0

        return RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: stableDays,
            wristTemperature: nil
        )
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean: Double = values.reduce(0, +) / Double(values.count)
        let squaredDiffs: Double = values.reduce(0) { $0 + pow($1 - mean, 2) }
        return sqrt(squaredDiffs / Double(values.count - 1))
    }

    private func updateCalibrationState(healthDataDays: Int) {
        var state: CalibrationState = calibrationState ?? CalibrationState()
        state.updateProgress(healthDataDays: healthDataDays)
        calibrationState = state
        localStorage.save(state, forKey: StorageKeys.calibrationState)
    }

    private func saveMoodLog() {
        guard let mood = mood else { return }

        var logs: [MoodLog] = localStorage.load(forKey: StorageKeys.moodLogs) ?? []
        let today: Date = Calendar.current.startOfDay(for: Date())

        // 今日のログがあれば更新、なければ追加
        if let index = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            logs[index] = MoodLog(date: Date(), mood: mood)
        } else {
            logs.append(MoodLog(date: Date(), mood: mood))
        }

        // 最新30日分のみ保持
        logs = Array(logs.suffix(30))
        localStorage.save(logs, forKey: StorageKeys.moodLogs)
    }

    private func saveTodayModeLog() {
        guard let mode = todayMode else { return }

        var logs: [TodayModeLog] = localStorage.load(forKey: StorageKeys.todayModeLogs) ?? []
        let today: Date = Calendar.current.startOfDay(for: Date())

        if let index = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            logs[index] = TodayModeLog(date: Date(), mode: mode)
        } else {
            logs.append(TodayModeLog(date: Date(), mode: mode))
        }

        logs = Array(logs.suffix(30))
        localStorage.save(logs, forKey: StorageKeys.todayModeLogs)
    }

    private func saveFeedbackLog(_ feedback: FeedbackLog) {
        var logs: [FeedbackLog] = localStorage.load(forKey: StorageKeys.feedbackLogs) ?? []
        logs.append(feedback)
        logs = Array(logs.suffix(30))
        localStorage.save(logs, forKey: StorageKeys.feedbackLogs)
    }
}

// MARK: - HomeError

/// Home画面のエラー
enum HomeError: Error, LocalizedError, Sendable {
    case dataLoadFailed
    case apiError(String)
    case healthKitError(String)
    case offlineMode

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "データの読み込みに失敗しました"
        case .apiError(let message):
            return "API エラー: \(message)"
        case .healthKitError(let message):
            return "HealthKit エラー: \(message)"
        case .offlineMode:
            return "オフラインモードです"
        }
    }
}

// MARK: - Log Models

/// 気分ログ
struct MoodLog: Codable, Sendable {
    let date: Date
    let mood: Mood
}

/// 今日のモードログ
struct TodayModeLog: Codable, Sendable {
    let date: Date
    let mode: TodayMode
}

/// フィードバックログ
struct FeedbackLog: Codable, Sendable {
    let date: Date
    let isHelpful: Bool
    let adviceSummary: String?
}
