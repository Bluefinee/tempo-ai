import Combine
import Foundation
@testable import TempoAI

/// Mock implementation of HealthKitManaging for testing
@MainActor
final class MockHealthKitManager: HealthKitManaging {

    // MARK: - Published Properties

    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false

    // Required for ObservableObject conformance
    nonisolated var objectWillChange: ObservableObjectPublisher {
        ObservableObjectPublisher()
    }

    // MARK: - Call Tracking

    var checkAuthorizationStatusCallCount: Int = 0
    var requestAuthorizationCallCount: Int = 0
    var fetchInitialDataCallCount: Int = 0

    // MARK: - Stubbed Return Values

    var stubbedHealthData: HealthData?

    // MARK: - Error Simulation

    var shouldThrowOnAuthorization: Bool = false
    var shouldThrowOnFetch: Bool = false
    var errorToThrow: Error = HealthKitError.authorizationDenied

    // MARK: - HealthKitManaging Protocol

    func checkAuthorizationStatus() {
        checkAuthorizationStatusCallCount += 1
    }

    func requestAuthorization() async throws {
        requestAuthorizationCallCount += 1
        isRequestingPermission = true
        defer { isRequestingPermission = false }

        if shouldThrowOnAuthorization {
            throw errorToThrow
        }

        authorizationStatus = .authorized
    }

    func fetchInitialData() async throws -> HealthData {
        fetchInitialDataCallCount += 1

        if shouldThrowOnFetch {
            throw errorToThrow
        }

        if let data = stubbedHealthData {
            return data
        }

        return createMockHealthData()
    }

    // MARK: - Helper Methods

    /// Reset all tracked calls and state
    func reset() {
        checkAuthorizationStatusCallCount = 0
        requestAuthorizationCallCount = 0
        fetchInitialDataCallCount = 0
        authorizationStatus = .notDetermined
        isRequestingPermission = false
        stubbedHealthData = nil
        shouldThrowOnAuthorization = false
        shouldThrowOnFetch = false
    }

    /// Create mock health data for testing
    private func createMockHealthData() -> HealthData {
        HealthData(
            sleepData: SleepData(
                totalSleepMinutes: 420,
                deepSleepMinutes: 90,
                remSleepMinutes: 100,
                sleepEfficiency: 0.85,
                sleepStartTime: Date().addingTimeInterval(-8 * 3600),
                sleepEndTime: Date()
            ),
            vitalData: VitalData(
                restingHeartRate: 62,
                heartRateVariability: 45,
                oxygenSaturation: 98,
                respiratoryRate: 14
            ),
            activityData: ActivityData(
                stepCount: 8500,
                activeEnergyBurned: 450,
                exerciseMinutes: 35,
                standHours: 10
            )
        )
    }
}

// MARK: - HealthKitError (for testing)

enum HealthKitError: Error, LocalizedError {
    case authorizationDenied
    case dataNotAvailable
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .dataNotAvailable:
            return "HealthKit data is not available"
        case .fetchFailed:
            return "Failed to fetch HealthKit data"
        }
    }
}
