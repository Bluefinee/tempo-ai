//
//  AnalyticsViewModel.swift
//  TempoAI
//
//  Analytics画面の状態管理ViewModel
//

import Combine
import Foundation

// MARK: - AnalyticsViewModel

/// Analytics画面の状態管理
@MainActor
final class AnalyticsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedPeriod: TimePeriod = .weekly
    @Published var scoreSnapshots: [DailyScoreSnapshot] = []
    @Published var rhythmAnalysis: RhythmAnalysis?
    @Published var insights: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: AnalyticsError?
    @Published var isCalibrating: Bool = false
    @Published var calibrationDaysCompleted: Int = 0

    // MARK: - Dependencies

    private let healthKitManager: HealthKitManager
    private let scoreCalculator: ScoreCalculator
    private let localStorage: LocalStorageProtocol

    // MARK: - Initialization

    init(
        healthKitManager: HealthKitManager,
        scoreCalculator: ScoreCalculator = ScoreCalculator(),
        localStorage: LocalStorageProtocol = LocalStorage()
    ) {
        self.healthKitManager = healthKitManager
        self.scoreCalculator = scoreCalculator
        self.localStorage = localStorage
    }

    // MARK: - Public Methods

    /// Analyticsデータを読み込む
    func loadAnalyticsData() async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        // 1. キャリブレーション状態を確認
        checkCalibrationState()

        // キャリブレーション中は基本的なデータのみ取得
        if isCalibrating {
            return
        }

        // 2. 期間に応じたデータを取得
        let days: Int = selectedPeriod.days
        let dailyMetrics: [HealthMetrics] = await healthKitManager.fetchDailyMetrics(days: days)

        if dailyMetrics.isEmpty {
            error = .insufficientData
            return
        }

        // 3. スコアスナップショットを作成
        await calculateScoreSnapshots(from: dailyMetrics)

        // 4. リズム分析を計算
        calculateRhythmAnalysis(from: dailyMetrics)

        // 5. インサイトを生成
        generateInsights()
    }

    /// 期間を変更
    func changePeriod(_ period: TimePeriod) async {
        guard period != selectedPeriod else { return }
        selectedPeriod = period
        await loadAnalyticsData()
    }

    // MARK: - Private Methods

    private func checkCalibrationState() {
        if let calibrationState: CalibrationState = localStorage.load(forKey: StorageKeys.calibrationState) {
            isCalibrating = !calibrationState.isComplete
            calibrationDaysCompleted = calibrationState.daysCompleted
        } else {
            // キャリブレーション状態がない = 未開始
            isCalibrating = true
            calibrationDaysCompleted = 0
        }
    }

    private func calculateScoreSnapshots(from dailyMetrics: [HealthMetrics]) async {
        var snapshots: [DailyScoreSnapshot] = []

        // デフォルトのリズム分析（後で更新される）
        let defaultRhythmAnalysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 30,
            wakeTimeStddevMinutes: 30,
            consecutiveStableDays: 3,
            wristTemperature: nil
        )

        for metrics in dailyMetrics {
            let assessment: ConditionAssessment = scoreCalculator.calculateAll(
                healthMetrics: metrics,
                rhythmAnalysis: defaultRhythmAnalysis
            )

            let snapshot: DailyScoreSnapshot = DailyScoreSnapshot(
                date: metrics.date,
                autonomicScore: assessment.autonomicScore.value,
                sleepScore: assessment.sleepScore.value,
                rhythmScore: assessment.rhythmScore.value,
                activityScore: assessment.activityScore.value
            )
            snapshots.append(snapshot)
        }

        scoreSnapshots = snapshots
    }

    private func calculateRhythmAnalysis(from dailyMetrics: [HealthMetrics]) {
        let sleepMetrics: [SleepMetrics] = dailyMetrics.compactMap { $0.sleep }

        guard sleepMetrics.count >= 3 else {
            rhythmAnalysis = nil
            return
        }

        // 就寝時刻の標準偏差を計算
        let bedtimeMinutes: [Double] = sleepMetrics.map { sleep in
            let components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: sleep.bedtime)
            var minutes: Double = Double(components.hour ?? 0) * 60 + Double(components.minute ?? 0)
            // 深夜0時以降は翌日として扱う
            if minutes < 360 { minutes += 1440 }
            return minutes
        }

        let wakeTimeMinutes: [Double] = sleepMetrics.map { sleep in
            let components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: sleep.wakeTime)
            return Double(components.hour ?? 0) * 60 + Double(components.minute ?? 0)
        }

        let bedtimeStddev: Double = standardDeviation(bedtimeMinutes)
        let wakeTimeStddev: Double = standardDeviation(wakeTimeMinutes)

        // 連続安定日数を計算
        var consecutiveStable: Int = 0
        for i in stride(from: sleepMetrics.count - 1, through: 1, by: -1) {
            let current: SleepMetrics = sleepMetrics[i]
            let previous: SleepMetrics = sleepMetrics[i - 1]

            let bedtimeDiff: TimeInterval = abs(current.bedtime.timeIntervalSince(previous.bedtime))
            let wakeTimeDiff: TimeInterval = abs(current.wakeTime.timeIntervalSince(previous.wakeTime))

            // 両方30分以内なら安定
            if bedtimeDiff <= 30 * 60 && wakeTimeDiff <= 30 * 60 {
                consecutiveStable += 1
            } else {
                break
            }
        }

        rhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: consecutiveStable,
            wristTemperature: nil
        )
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }

        let mean: Double = values.reduce(0, +) / Double(values.count)
        let squaredDiffs: Double = values.reduce(0) { sum, value in
            sum + pow(value - mean, 2)
        }
        return sqrt(squaredDiffs / Double(values.count))
    }

    private func generateInsights() {
        guard !scoreSnapshots.isEmpty else {
            insights = ["データを蓄積中です。しばらくお待ちください。"]
            return
        }

        var generatedInsights: [String] = []

        // 睡眠時間とスコアの相関
        let highSleepScoreDays: Int = scoreSnapshots.filter { $0.sleepScore >= 70 }.count
        if highSleepScoreDays > scoreSnapshots.count / 2 {
            generatedInsights.append("睡眠スコアが高い日が多く、良質な睡眠が取れています")
        }

        // リズム安定性に基づくインサイト
        if let rhythm = rhythmAnalysis {
            if rhythm.isStable {
                generatedInsights.append("生活リズムが安定しており、コンディション維持に貢献しています")
            } else if rhythm.bedtimeStddevMinutes > 45 {
                generatedInsights.append("就寝時刻のばらつきが大きめです。規則正しい就寝を心がけましょう")
            }

            if rhythm.consecutiveStableDays >= 5 {
                generatedInsights.append("連続\(rhythm.consecutiveStableDays)日間リズムが安定しています")
            }
        }

        // 活動量に基づくインサイト
        let avgActivityScore: Double = Double(scoreSnapshots.reduce(0) { $0 + $1.activityScore }) / Double(scoreSnapshots.count)
        if avgActivityScore >= 70 {
            generatedInsights.append("活動量が十分で、健康的な生活を送れています")
        } else if avgActivityScore < 50 {
            generatedInsights.append("活動量を増やすと、睡眠の質向上が期待できます")
        }

        // 自律神経スコアのトレンド
        if scoreSnapshots.count >= 3 {
            let recent: Int = scoreSnapshots.suffix(3).reduce(0) { $0 + $1.autonomicScore } / 3
            let earlier: Int = scoreSnapshots.prefix(3).reduce(0) { $0 + $1.autonomicScore } / 3
            if recent > earlier + 10 {
                generatedInsights.append("自律神経スコアが改善傾向にあります")
            } else if recent < earlier - 10 {
                generatedInsights.append("最近、自律神経スコアが低下傾向です。休養を意識しましょう")
            }
        }

        // 生成がなければデフォルトメッセージを追加
        if generatedInsights.isEmpty {
            generatedInsights.append("データを分析中です。継続して記録を続けてください")
        }

        insights = Array(generatedInsights.prefix(5))
    }
}

// MARK: - Preview Helper

#if DEBUG
extension AnalyticsViewModel {
    static func preview() -> AnalyticsViewModel {
        let viewModel: AnalyticsViewModel = AnalyticsViewModel(
            healthKitManager: HealthKitManager.mock()
        )
        viewModel.isCalibrating = false
        viewModel.rhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 25,
            wakeTimeStddevMinutes: 20,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        viewModel.insights = [
            "睡眠7時間以上の日はスコアが平均+10pt",
            "23時前就寝で深い睡眠が20%増加傾向",
            "リズムが安定しており、コンディション維持に貢献"
        ]

        let calendar: Calendar = Calendar.current
        let today: Date = calendar.startOfDay(for: Date())
        viewModel.scoreSnapshots = (0..<7).compactMap { offset -> DailyScoreSnapshot? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DailyScoreSnapshot(
                date: date,
                autonomicScore: 65 + Int.random(in: -10...15),
                sleepScore: 70 + Int.random(in: -15...15),
                rhythmScore: 75 + Int.random(in: -10...10),
                activityScore: 60 + Int.random(in: -15...20)
            )
        }.reversed()

        return viewModel
    }
}
#endif
