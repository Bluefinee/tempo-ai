import Foundation
import HealthKit

// MARK: - HealthKit Error

/// HealthKitエラー
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed
    case dataFetchFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .authorizationFailed:
            return "HealthKit権限の取得に失敗しました"
        case .dataFetchFailed(let message):
            return "データの取得に失敗しました: \(message)"
        }
    }
}

// MARK: - HealthKit Manager

/// HealthKit管理クラス
/// HealthKitManagingプロトコルに準拠し、テスト時にモック実装を注入可能
@MainActor
final class HealthKitManager: ObservableObject, HealthKitManaging {
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false

    private let healthStore = HKHealthStore()

    /// 必須データタイプ
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned)
    ]

    /// オプショナルデータタイプ
    private let optionalTypes: Set<HKObjectType> = [
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.oxygenSaturation),
        HKQuantityType(.bodyTemperature)
    ]

    init() {
        checkAuthorizationStatus()
    }

    /// 現在の認証ステータスを確認
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .denied
            return
        }

        // 必須データタイプのみで判定（オプショナルは無視）
        var requiredAuthorizedCount = 0
        var requiredDeniedCount = 0
        var hasNotDetermined = false

        for type in requiredTypes {
            let status = healthStore.authorizationStatus(for: type)
            switch status {
            case .sharingAuthorized:
                requiredAuthorizedCount += 1
            case .sharingDenied:
                requiredDeniedCount += 1
            case .notDetermined:
                hasNotDetermined = true
            @unknown default:
                break
            }
        }

        // 未決定の必須データがある場合
        if hasNotDetermined {
            authorizationStatus = .notDetermined
            return
        }

        // 必須データの権限状況で判定
        if requiredAuthorizedCount == requiredTypes.count {
            authorizationStatus = .authorized  // 必須データがすべて許可
        } else if requiredAuthorizedCount > 0 {
            authorizationStatus = .partiallyAuthorized  // 必須データの一部のみ許可
        } else {
            authorizationStatus = .denied  // 必須データがすべて拒否
        }
    }

    /// HealthKit権限をリクエスト
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        isRequestingPermission = true
        defer { isRequestingPermission = false }

        do {
            let allTypes = requiredTypes.union(optionalTypes)
            try await healthStore.requestAuthorization(toShare: [], read: allTypes)
            checkAuthorizationStatus()
        } catch {
            throw HealthKitError.authorizationFailed
        }
    }

    /// 過去30日分のHealthKitデータを取得
    func fetchInitialData() async throws -> HealthData {
        // モック実装（Phase 2で完全実装予定）
        #if DEBUG
        return Self.generateMockData()
        #else
        throw HealthKitError.dataFetchFailed("Not implemented yet")
        #endif
    }

    // MARK: - Phase 12.5: リズム指標

    /// 手首皮膚温が利用可能か確認
    func isWristTemperatureAvailable() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        if #available(iOS 16.0, *) {
            let temperatureType = HKQuantityType(.appleSleepingWristTemperature)
            return healthStore.authorizationStatus(for: temperatureType) == .sharingAuthorized
        }
        return false
        #endif
    }

    /// 日光浴時間を取得
    func fetchTimeInDaylight(for date: Date) async throws -> (total: Int, morning: Int) {
        #if DEBUG
        // シミュレータ用モックデータ
        return (total: Int.random(in: 10...45), morning: Int.random(in: 5...25))
        #else
        guard #available(iOS 17.0, *) else {
            return (0, 0)
        }

        let daylightType = HKQuantityType(.timeInDaylight)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let noon = calendar.date(byAdding: .hour, value: 12, to: startOfDay),
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return (0, 0)
        }

        async let morningMinutes = fetchDaylightMinutes(
            type: daylightType,
            start: startOfDay,
            end: noon
        )
        async let totalMinutes = fetchDaylightMinutes(
            type: daylightType,
            start: startOfDay,
            end: endOfDay
        )

        return try await (total: totalMinutes, morning: morningMinutes)
        #endif
    }

    @available(iOS 17.0, *)
    private func fetchDaylightMinutes(
        type: HKQuantityType,
        start: Date,
        end: Date
    ) async throws -> Int {
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let minutes = statistics?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                continuation.resume(returning: Int(minutes))
            }
            healthStore.execute(query)
        }
    }

    /// 手首皮膚温データを取得
    func fetchWristTemperature() async throws -> TemperatureMetric? {
        guard isWristTemperatureAvailable() else {
            return nil
        }

        #if DEBUG
        // シミュレータ用モックデータ
        return TemperatureMetric(
            phaseShiftHours: Double.random(in: -1.0...1.0),
            isAvailable: true,
            nightsOfData: Int.random(in: 3...10)
        )
        #else
        // TODO: Phase 2で実装
        // HKQuantityType(.appleSleepingWristTemperature)からデータを取得
        // 体温リズムから位相ズレを算出
        return nil
        #endif
    }

    /// 全リズム指標を一括取得
    func fetchRhythmMetrics(for date: Date) async throws -> RhythmMetrics {
        #if DEBUG
        return RhythmMetrics.mock
        #else
        // TODO: Phase 2で完全実装
        // 各指標を並行取得してRhythmMetricsを構築
        throw HealthKitError.dataFetchFailed("Not implemented yet")
        #endif
    }

    /// テストデータを生成（シミュレータ用）
    static func generateMockData() -> HealthData {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) else {
            return HealthData(
                heartRateData: [],
                hrvData: [],
                sleepData: [],
                stepData: [],
                activeEnergyData: [],
                fetchedAt: Date()
            )
        }

        var heartRateData: [HeartRateData] = []
        var hrvData: [HRVData] = []
        var sleepData: [SleepData] = []
        var stepData: [StepData] = []
        var activeEnergyData: [ActiveEnergyData] = []

        var currentDate = startDate
        while currentDate < endDate {
            // 心拍数: 55-75 bpm
            heartRateData.append(HeartRateData(date: currentDate, value: Double.random(in: 55...75)))

            // HRV: 40-80 ms
            hrvData.append(HRVData(date: currentDate, value: Double.random(in: 40...80)))

            // 睡眠: 6-8時間
            let sleepDuration = Double.random(in: 6.0...8.0)
            let bedTime = calendar.date(byAdding: .hour, value: 22, to: currentDate) ?? currentDate
            let wakeTime = calendar.date(byAdding: .hour, value: Int(sleepDuration), to: bedTime) ?? currentDate
            sleepData.append(SleepData(
                date: currentDate,
                duration: sleepDuration,
                bedTime: bedTime,
                wakeTime: wakeTime
            ))

            // 歩数: 5000-12000歩
            stepData.append(StepData(date: currentDate, count: Int.random(in: 5000...12000)))

            // 消費エネルギー: 200-600 kcal
            activeEnergyData.append(ActiveEnergyData(date: currentDate, value: Double.random(in: 200...600)))

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }

        return HealthData(
            heartRateData: heartRateData,
            hrvData: hrvData,
            sleepData: sleepData,
            stepData: stepData,
            activeEnergyData: activeEnergyData,
            fetchedAt: Date()
        )
    }
}
