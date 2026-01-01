import Combine
import Foundation
import HealthKit

// MARK: - HealthKitManager

/// HealthKit連携を管理するObservableObjectクラス
/// SwiftUIビューからの利用を想定
@MainActor
final class HealthKitManager: ObservableObject {

    // MARK: - Published Properties

    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var lastError: HealthKitError?

    // MARK: - Properties

    private let repository: HealthKitRepositoryProtocol

    // MARK: - Initialization

    init(repository: HealthKitRepositoryProtocol = HealthKitRepository()) {
        self.repository = repository
        checkAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// HealthKitへの認証を要求
    func requestAuthorization() async {
        isLoading = true
        lastError = nil

        do {
            try await repository.requestAuthorization()
            authorizationStatus = .authorized
        } catch let error as HealthKitError {
            lastError = error
            if case .notAuthorized = error {
                authorizationStatus = .denied
            }
        } catch {
            lastError = .queryFailed(error)
        }

        isLoading = false
    }

    /// 今日のヘルスメトリクスを取得
    func fetchTodayMetrics() async -> HealthMetrics? {
        isLoading = true
        lastError = nil

        do {
            let metrics: HealthMetrics = try await repository.fetchTodayMetrics()
            isLoading = false
            return metrics
        } catch let error as HealthKitError {
            lastError = error
            isLoading = false
            return nil
        } catch {
            lastError = .queryFailed(error)
            isLoading = false
            return nil
        }
    }

    /// 睡眠履歴を取得
    func fetchSleepHistory(days: Int = 7) async -> [SleepMetrics] {
        isLoading = true
        lastError = nil

        do {
            let history: [SleepMetrics] = try await repository.fetchSleepHistory(days: days)
            isLoading = false
            return history
        } catch let error as HealthKitError {
            lastError = error
            isLoading = false
            return []
        } catch {
            lastError = .queryFailed(error)
            isLoading = false
            return []
        }
    }

    /// HRVベースラインを取得
    func fetchHRVBaseline(days: Int = 30) async -> Double? {
        do {
            return try await repository.fetchHRVBaseline(days: days)
        } catch {
            return nil
        }
    }

    // MARK: - Private Methods

    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .denied
            return
        }

        let healthStore: HKHealthStore = HKHealthStore()
        let hrvType: HKQuantityType = HKQuantityType(.heartRateVariabilitySDNN)
        let status: HKAuthorizationStatus = healthStore.authorizationStatus(for: hrvType)

        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .sharingAuthorized:
            authorizationStatus = .authorized
        case .sharingDenied:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

// MARK: - Mock for Previews

#if DEBUG
extension HealthKitManager {
    static func mock(status: HealthKitAuthorizationStatus = .authorized) -> HealthKitManager {
        let manager: HealthKitManager = HealthKitManager(repository: MockHealthKitRepository())
        manager.authorizationStatus = status
        return manager
    }
}

private final class MockHealthKitRepository: HealthKitRepositoryProtocol, @unchecked Sendable {
    func requestAuthorization() async throws {}

    func fetchTodayMetrics() async throws -> HealthMetrics {
        HealthMetrics(
            date: Date(),
            sleep: SleepMetrics(
                bedtime: Date().addingTimeInterval(-8 * 3600),
                wakeTime: Date(),
                durationMinutes: 450,
                deepSleepMinutes: 90,
                remSleepMinutes: 100
            ),
            hrv: HRVMetrics(value: 55, baseline30d: 50),
            activity: ActivityMetrics(stepsYesterday: 8500, activeMinutesYesterday: 45),
            auxiliary: nil
        )
    }

    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics] {
        []
    }

    func fetchHRVBaseline(days: Int) async throws -> Double {
        50.0
    }
}
#endif
