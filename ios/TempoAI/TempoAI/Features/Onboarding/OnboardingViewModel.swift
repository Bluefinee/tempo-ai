import Combine
import Foundation
import SwiftUI

// MARK: - OnboardingViewModel

/// オンボーディングの状態管理とビジネスロジック
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: OnboardingStep = .welcome
    @Published var state: OnboardingState = OnboardingState()
    @Published var isLoading: Bool = false
    @Published var error: OnboardingError? = nil
    @Published var showError: Bool = false

    // MARK: - Sleep Data for Auto-Estimation

    @Published private(set) var sleepHistory: [SleepMetrics] = []

    // MARK: - Dependencies

    private let healthKitManager: HealthKitManager
    private let locationManager: LocationManager
    private let localStorage: LocalStorageProtocol

    // MARK: - Constants

    private let minimumSleepDataDays: Int = 7
    private let sleepDataFetchDays: Int = 30

    // MARK: - Initialization

    init(
        healthKitManager: HealthKitManager,
        locationManager: LocationManager,
        localStorage: LocalStorageProtocol,
        initialSleepHistory: [SleepMetrics] = []
    ) {
        self.healthKitManager = healthKitManager
        self.locationManager = locationManager
        self.localStorage = localStorage
        self.sleepHistory = initialSleepHistory
    }

    /// デフォルト初期化（MainActorコンテキストで呼び出す必要あり）
    convenience init() {
        self.init(
            healthKitManager: HealthKitManager(),
            locationManager: LocationManager(),
            localStorage: LocalStorage()
        )
    }

    // MARK: - Navigation

    /// 次のステップへ進む
    func nextStep() {
        guard let nextStep: OnboardingStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }
    }

    /// 前のステップへ戻る
    func previousStep() {
        guard let previousStep: OnboardingStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previousStep
        }
    }

    /// 特定のステップへ移動
    func goToStep(_ step: OnboardingStep) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }

    // MARK: - HealthKit Authorization (Step 2)

    /// HealthKit認証を要求し、データを取得
    func requestHealthKitAuthorization() async {
        isLoading = true
        error = nil

        // HealthKitが利用可能かチェック
        guard healthKitManager.isHealthDataAvailable else {
            setError(.healthKitNotAvailable)
            isLoading = false
            return
        }

        await healthKitManager.requestAuthorization()

        switch healthKitManager.authorizationStatus {
        case .authorized, .partiallyAuthorized:
            state.healthKitAuthorized = true
            await fetchSleepHistory()
            nextStep()
        case .denied:
            setError(.healthKitAuthorizationFailed)
        case .notDetermined:
            setError(.healthKitAuthorizationFailed)
        }

        isLoading = false
    }

    /// 睡眠履歴を取得
    private func fetchSleepHistory() async {
        sleepHistory = await healthKitManager.fetchSleepHistory(days: sleepDataFetchDays)
    }

    // MARK: - Chronotype Auto-Estimation (Step 5)

    /// クロノタイプを自動推定
    /// - Returns: (推定されたクロノタイプ, 自動推定が成功したかどうか)
    func estimateChronotype() -> (Chronotype, Bool) {
        guard sleepHistory.count >= minimumSleepDataDays else {
            return (.intermediate, false)
        }

        let msfsc: Double = calculateMSFsc()
        let chronotype: Chronotype = classifyChronotype(msfsc: msfsc)

        state.chronotype = chronotype
        state.chronotypeAutoEstimated = true

        return (chronotype, true)
    }

    /// MSFsc（睡眠中間点）を計算
    /// MSFsc = 平均就寝時刻 + 平均睡眠時間/2
    private func calculateMSFsc() -> Double {
        guard !sleepHistory.isEmpty else { return 28.0 } // デフォルト4:00 = 中間型

        let calendar: Calendar = Calendar.current
        var totalMidSleepHours: Double = 0

        for sleep in sleepHistory {
            let bedtimeHour: Double = hourOfDay(from: sleep.bedtime, calendar: calendar)
            let durationHours: Double = Double(sleep.durationMinutes) / 60.0
            let midSleepHour: Double = bedtimeHour + (durationHours / 2.0)
            totalMidSleepHours += midSleepHour
        }

        return totalMidSleepHours / Double(sleepHistory.count)
    }

    /// 時刻を0-24+の時間単位に変換（深夜は24以上で表現）
    private func hourOfDay(from date: Date, calendar: Calendar) -> Double {
        let hour: Int = calendar.component(.hour, from: date)
        let minute: Int = calendar.component(.minute, from: date)

        // 深夜0-6時は24+として扱う（前日の続き）
        let adjustedHour: Double = hour < 6 ? Double(hour + 24) : Double(hour)
        return adjustedHour + (Double(minute) / 60.0)
    }

    /// MSFscからクロノタイプを分類
    private func classifyChronotype(msfsc: Double) -> Chronotype {
        switch msfsc {
        case ..<27.0: // 3:00未満（27時 = 3:00AM）
            return .morning
        case 27.0..<29.0: // 3:00-5:00
            return .intermediate
        default: // 5:00以上
            return .evening
        }
    }

    // MARK: - Bedtime Goal Auto-Estimation (Step 6)

    /// 就寝目標を自動提案
    /// - Returns: (提案される就寝時刻, 自動提案が成功したかどうか)
    func estimateBedtimeGoal() -> (Date, Bool) {
        guard sleepHistory.count >= minimumSleepDataDays else {
            return (OnboardingState.defaultBedtime, false)
        }

        let averageBedtime: Date = calculateAverageBedtime()
        let roundedBedtime: Date = roundToNearest30Minutes(averageBedtime)

        state.targetBedtime = roundedBedtime
        state.bedtimeAutoEstimated = true

        return (roundedBedtime, true)
    }

    /// 平均就寝時刻を計算
    private func calculateAverageBedtime() -> Date {
        guard !sleepHistory.isEmpty else { return OnboardingState.defaultBedtime }

        let calendar: Calendar = Calendar.current
        var totalMinutesFromMidnight: Double = 0

        for sleep in sleepHistory {
            let components: DateComponents = calendar.dateComponents([.hour, .minute], from: sleep.bedtime)
            var hour: Int = components.hour ?? 23
            let minute: Int = components.minute ?? 0

            // 深夜（0-6時）は翌日として扱う
            if hour < 6 {
                hour += 24
            }

            totalMinutesFromMidnight += Double(hour * 60 + minute)
        }

        let averageMinutes: Int = Int(totalMinutesFromMidnight / Double(sleepHistory.count))
        var adjustedMinutes: Int = averageMinutes

        // 24時間以上の場合は調整
        if adjustedMinutes >= 24 * 60 {
            adjustedMinutes -= 24 * 60
        }

        let hour: Int = adjustedMinutes / 60
        let minute: Int = adjustedMinutes % 60

        var components: DateComponents = DateComponents()
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components) ?? OnboardingState.defaultBedtime
    }

    /// 30分単位に丸める
    private func roundToNearest30Minutes(_ date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.hour, .minute], from: date)
        let hour: Int = components.hour ?? 23
        let minute: Int = components.minute ?? 0

        let roundedMinute: Int
        let adjustedHour: Int

        if minute < 15 {
            roundedMinute = 0
            adjustedHour = hour
        } else if minute < 45 {
            roundedMinute = 30
            adjustedHour = hour
        } else {
            roundedMinute = 0
            adjustedHour = hour + 1
        }

        var newComponents: DateComponents = DateComponents()
        newComponents.hour = adjustedHour % 24
        newComponents.minute = roundedMinute

        return calendar.date(from: newComponents) ?? date
    }

    // MARK: - Lifestyle Step (Step 7)

    /// ライフスタイルステップをスキップ（データをクリアして次へ）
    func skipLifestyleStep() {
        state.occupation = nil
        state.exerciseFrequency = nil
        state.alcoholFrequency = nil
        nextStep()
    }

    // MARK: - Location Authorization (Step 8)

    /// 位置情報認証を要求
    func requestLocationAuthorization() {
        locationManager.requestAuthorization()
    }

    /// 位置情報認証状態を確認
    var isLocationAuthorized: Bool {
        locationManager.authorizationStatus.isAuthorized
    }

    // MARK: - Complete Onboarding (Step 9)

    /// オンボーディングを完了
    /// - Returns: 完了が成功したかどうか
    @discardableResult
    func completeOnboarding() async -> Bool {
        isLoading = true
        error = nil

        do {
            // UserProfileを保存
            let userProfile: UserProfile = state.toUserProfile()
            try localStorage.save(userProfile, forKey: StorageKeys.userProfile)

            // CalibrationStateを初期化
            let calibrationState: CalibrationState = CalibrationState()
            try localStorage.save(calibrationState, forKey: StorageKeys.calibrationState)

            // onboardingCompletedをtrueに
            try localStorage.save(true, forKey: StorageKeys.onboardingCompleted)
        } catch {
            setError(.saveError("データの保存に失敗しました"))
            isLoading = false
            return false
        }

        // 保存確認
        guard localStorage.exists(forKey: StorageKeys.onboardingCompleted) else {
            setError(.saveError("データの保存に失敗しました"))
            isLoading = false
            return false
        }

        state.locationAuthorized = isLocationAuthorized

        isLoading = false
        return true
    }

    // MARK: - Error Handling

    private func setError(_ onboardingError: OnboardingError) {
        error = onboardingError
        showError = true
    }

    func dismissError() {
        showError = false
        error = nil
    }

    // MARK: - Validation

    /// 現在のステップが次に進めるかどうか
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .healthKit:
            return state.healthKitAuthorized
        case .nickname:
            return state.isNicknameValid
        case .basicInfo:
            return state.isBasicInfoValid
        case .chronotype:
            return true
        case .bedtimeGoal:
            return true
        case .lifestyle:
            return true // スキップ可能
        case .location:
            return true // 任意
        case .complete:
            return true
        }
    }

    // MARK: - Formatters

    private static let bedtimeFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: - Formatted Display Values

    /// 就寝時刻を表示用にフォーマット
    func formattedBedtime(_ date: Date) -> String {
        Self.bedtimeFormatter.string(from: date)
    }
}
