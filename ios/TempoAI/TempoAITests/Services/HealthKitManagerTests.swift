import Foundation
import Testing

@testable import TempoAI

@MainActor
struct HealthKitManagerTests {

    // MARK: - Mock HealthKitManager Tests

    @Test("Initial authorization status is notDetermined")
    func initialAuthorizationStatus() {
        let manager = MockHealthKitManager()

        #expect(manager.authorizationStatus == .notDetermined)
        #expect(manager.isRequestingPermission == false)
    }

    @Test("Check authorization status increments call count")
    func checkAuthorizationStatus() {
        let manager = MockHealthKitManager()

        manager.checkAuthorizationStatus()

        #expect(manager.checkAuthorizationStatusCallCount == 1)
    }

    @Test("Request authorization updates status to authorized")
    func requestAuthorizationSuccess() async throws {
        let manager = MockHealthKitManager()

        try await manager.requestAuthorization()

        #expect(manager.authorizationStatus == .authorized)
        #expect(manager.requestAuthorizationCallCount == 1)
    }

    @Test("Request authorization throws when configured to fail")
    func requestAuthorizationFailure() async {
        let manager = MockHealthKitManager()
        manager.shouldThrowOnAuthorization = true

        do {
            try await manager.requestAuthorization()
            Issue.record("Expected authorization to throw")
        } catch {
            #expect(manager.requestAuthorizationCallCount == 1)
        }
    }

    @Test("Fetch initial data returns mock health data")
    func fetchInitialDataSuccess() async throws {
        let manager = MockHealthKitManager()

        let healthData = try await manager.fetchInitialData()

        #expect(healthData.sleepData.totalSleepMinutes > 0)
        #expect(healthData.vitalData.restingHeartRate > 0)
        #expect(healthData.activityData.stepCount > 0)
        #expect(manager.fetchInitialDataCallCount == 1)
    }

    @Test("Fetch initial data returns stubbed data when set")
    func fetchInitialDataWithStub() async throws {
        let manager = MockHealthKitManager()
        let customData = HealthData(
            sleepData: SleepData(
                totalSleepMinutes: 500,
                deepSleepMinutes: 100,
                remSleepMinutes: 120,
                sleepEfficiency: 0.90,
                sleepStartTime: Date(),
                sleepEndTime: Date()
            ),
            vitalData: VitalData(
                restingHeartRate: 55,
                heartRateVariability: 50,
                oxygenSaturation: 99,
                respiratoryRate: 12
            ),
            activityData: ActivityData(
                stepCount: 10000,
                activeEnergyBurned: 500,
                exerciseMinutes: 45,
                standHours: 12
            )
        )
        manager.stubbedHealthData = customData

        let healthData = try await manager.fetchInitialData()

        #expect(healthData.sleepData.totalSleepMinutes == 500)
        #expect(healthData.vitalData.restingHeartRate == 55)
        #expect(healthData.activityData.stepCount == 10000)
    }

    @Test("Fetch initial data throws when configured to fail")
    func fetchInitialDataFailure() async {
        let manager = MockHealthKitManager()
        manager.shouldThrowOnFetch = true

        do {
            _ = try await manager.fetchInitialData()
            Issue.record("Expected fetch to throw")
        } catch {
            #expect(manager.fetchInitialDataCallCount == 1)
        }
    }

    @Test("Reset clears all state")
    func resetClearsState() async throws {
        let manager = MockHealthKitManager()
        try await manager.requestAuthorization()
        _ = try await manager.fetchInitialData()

        manager.reset()

        #expect(manager.checkAuthorizationStatusCallCount == 0)
        #expect(manager.requestAuthorizationCallCount == 0)
        #expect(manager.fetchInitialDataCallCount == 0)
        #expect(manager.authorizationStatus == .notDetermined)
    }

    // MARK: - HealthKitError Tests

    @Test("HealthKitError provides localized description")
    func healthKitErrorLocalizedDescription() {
        let authError = HealthKitError.authorizationDenied
        let dataError = HealthKitError.dataNotAvailable
        let fetchError = HealthKitError.fetchFailed

        #expect(authError.errorDescription?.contains("authorization") == true)
        #expect(dataError.errorDescription?.contains("not available") == true)
        #expect(fetchError.errorDescription?.contains("fetch") == true)
    }
}
