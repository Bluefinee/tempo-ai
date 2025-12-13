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
