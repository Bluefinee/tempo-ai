import Combine
import Foundation
@testable import TempoAI

/// Mock implementation of LocationManaging for testing
@MainActor
final class MockLocationManager: LocationManaging {

    // MARK: - Published Properties

    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false
    @Published var isRequestingLocation: Bool = false
    @Published var currentLocation: LocationData?

    // Required for ObservableObject conformance
    nonisolated var objectWillChange: ObservableObjectPublisher {
        ObservableObjectPublisher()
    }

    // MARK: - Call Tracking

    var checkAuthorizationStatusCallCount: Int = 0
    var requestAuthorizationCallCount: Int = 0
    var requestCurrentLocationCallCount: Int = 0

    // MARK: - Stubbed Return Values

    var stubbedLocation: LocationData?

    // MARK: - Error Simulation

    var shouldThrowOnLocation: Bool = false
    var errorToThrow: Error = LocationError.locationNotAvailable

    // MARK: - LocationManaging Protocol

    func checkAuthorizationStatus() {
        checkAuthorizationStatusCallCount += 1
    }

    func requestAuthorization() {
        requestAuthorizationCallCount += 1
        isRequestingPermission = true

        // Simulate async authorization
        DispatchQueue.main.async { [weak self] in
            self?.isRequestingPermission = false
            self?.authorizationStatus = .authorizedWhenInUse
        }
    }

    func requestCurrentLocation() async throws -> LocationData {
        requestCurrentLocationCallCount += 1
        isRequestingLocation = true
        defer { isRequestingLocation = false }

        if shouldThrowOnLocation {
            throw errorToThrow
        }

        if let location = stubbedLocation {
            currentLocation = location
            return location
        }

        let mockLocation = createMockLocation()
        currentLocation = mockLocation
        return mockLocation
    }

    // MARK: - Helper Methods

    /// Reset all tracked calls and state
    func reset() {
        checkAuthorizationStatusCallCount = 0
        requestAuthorizationCallCount = 0
        requestCurrentLocationCallCount = 0
        authorizationStatus = .notDetermined
        isRequestingPermission = false
        isRequestingLocation = false
        currentLocation = nil
        stubbedLocation = nil
        shouldThrowOnLocation = false
    }

    /// Create mock location data for testing (Tokyo)
    private func createMockLocation() -> LocationData {
        LocationData(
            latitude: 35.6762,
            longitude: 139.6503,
            city: "Tokyo",
            country: "Japan"
        )
    }
}

// MARK: - LocationError (for testing)

enum LocationError: Error, LocalizedError {
    case locationNotAvailable
    case authorizationDenied
    case timeout

    var errorDescription: String? {
        switch self {
        case .locationNotAvailable:
            return "Location is not available"
        case .authorizationDenied:
            return "Location authorization was denied"
        case .timeout:
            return "Location request timed out"
        }
    }
}
