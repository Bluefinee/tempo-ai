import Foundation
import Testing

@testable import TempoAI

@MainActor
struct LocationManagerTests {

    // MARK: - Mock LocationManager Tests

    @Test("Initial authorization status is notDetermined")
    func initialAuthorizationStatus() {
        let manager = MockLocationManager()

        #expect(manager.authorizationStatus == .notDetermined)
        #expect(manager.isRequestingPermission == false)
        #expect(manager.isRequestingLocation == false)
        #expect(manager.currentLocation == nil)
    }

    @Test("Check authorization status increments call count")
    func checkAuthorizationStatus() {
        let manager = MockLocationManager()

        manager.checkAuthorizationStatus()

        #expect(manager.checkAuthorizationStatusCallCount == 1)
    }

    @Test("Request authorization increments call count")
    func requestAuthorization() {
        let manager = MockLocationManager()

        manager.requestAuthorization()

        #expect(manager.requestAuthorizationCallCount == 1)
    }

    @Test("Request current location returns mock Tokyo location")
    func requestCurrentLocationSuccess() async throws {
        let manager = MockLocationManager()

        let location = try await manager.requestCurrentLocation()

        #expect(location.city == "Tokyo")
        #expect(location.country == "Japan")
        #expect(location.latitude > 35)
        #expect(location.longitude > 139)
        #expect(manager.requestCurrentLocationCallCount == 1)
        #expect(manager.currentLocation != nil)
    }

    @Test("Request current location returns stubbed data when set")
    func requestCurrentLocationWithStub() async throws {
        let manager = MockLocationManager()
        let customLocation = LocationData(
            latitude: 34.6937,
            longitude: 135.5023,
            city: "Osaka",
            country: "Japan"
        )
        manager.stubbedLocation = customLocation

        let location = try await manager.requestCurrentLocation()

        #expect(location.city == "Osaka")
        #expect(location.latitude == 34.6937)
    }

    @Test("Request current location throws when configured to fail")
    func requestCurrentLocationFailure() async {
        let manager = MockLocationManager()
        manager.shouldThrowOnLocation = true

        do {
            _ = try await manager.requestCurrentLocation()
            Issue.record("Expected location request to throw")
        } catch {
            #expect(manager.requestCurrentLocationCallCount == 1)
        }
    }

    @Test("Reset clears all state")
    func resetClearsState() async throws {
        let manager = MockLocationManager()
        manager.requestAuthorization()
        _ = try await manager.requestCurrentLocation()

        manager.reset()

        #expect(manager.checkAuthorizationStatusCallCount == 0)
        #expect(manager.requestAuthorizationCallCount == 0)
        #expect(manager.requestCurrentLocationCallCount == 0)
        #expect(manager.authorizationStatus == .notDetermined)
        #expect(manager.currentLocation == nil)
    }

    // MARK: - LocationError Tests

    @Test("LocationError provides localized description")
    func locationErrorLocalizedDescription() {
        let notAvailable = LocationError.locationNotAvailable
        let denied = LocationError.authorizationDenied
        let timeout = LocationError.timeout

        #expect(notAvailable.errorDescription?.contains("not available") == true)
        #expect(denied.errorDescription?.contains("denied") == true)
        #expect(timeout.errorDescription?.contains("timed out") == true)
    }
}
