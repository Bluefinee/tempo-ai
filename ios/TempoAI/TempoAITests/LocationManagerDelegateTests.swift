/**
 * @fileoverview Location Manager Delegate Tests
 * 
 * LocationManager のデリゲートメソッドのテストを担当します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import CoreLocation
import XCTest
@testable import TempoAI

@MainActor
final class LocationManagerDelegateTests: XCTestCase {
    var locationManager: LocationManager!
    var mockCLLocationManager: MockCLLocationManager!

    override func setUp() {
        super.setUp()
        mockCLLocationManager = MockCLLocationManager()
        locationManager = LocationManager(locationManager: mockCLLocationManager)
    }

    override func tearDown() {
        locationManager = nil
        mockCLLocationManager = nil
        super.tearDown()
    }

    // MARK: - Delegate Method Tests

    func testLocationManagerDidChangeAuthorizationToAuthorized() {
        // Given: Authorization changes to authorized
        mockCLLocationManager.authorizationStatusResult = .authorizedWhenInUse

        // When: Authorization changes (use actual CLLocationManager instance)
        let actualManager = CLLocationManager()
        locationManager.locationManagerDidChangeAuthorization(actualManager)

        // Then: Should update status and request location
        XCTAssertEqual(locationManager.authorizationStatus, .authorizedWhenInUse)
        XCTAssertTrue(mockCLLocationManager.requestLocationCalled)
    }

    func testLocationManagerDidChangeAuthorizationToDenied() {
        // Given: Authorization changes to denied
        mockCLLocationManager.authorizationStatusResult = .denied

        // When: Authorization changes (use actual CLLocationManager instance)
        let actualManager = CLLocationManager()
        locationManager.locationManagerDidChangeAuthorization(actualManager)

        // Then: Should update status and set error message
        XCTAssertEqual(locationManager.authorizationStatus, .denied)
        XCTAssertEqual(locationManager.errorMessage, "Location access denied")
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
    }

    func testLocationManagerDidChangeAuthorizationToNotDetermined() {
        // Given: Authorization changes to not determined
        mockCLLocationManager.authorizationStatusResult = .notDetermined

        // When: Authorization changes (use actual CLLocationManager instance)
        let actualManager = CLLocationManager()
        locationManager.locationManagerDidChangeAuthorization(actualManager)

        // Then: Should update status but not request location
        XCTAssertEqual(locationManager.authorizationStatus, .notDetermined)
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
    }

    func testLocationManagerDidUpdateLocations() {
        // Given: Valid location
        let mockLocation = TestHelpers.createMockTokyoLocation()

        // When: Location is updated
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [mockLocation])

        // Then: Should update location and clear error
        XCTAssertEqual(locationManager.location?.coordinate.latitude, mockLocation.coordinate.latitude)
        XCTAssertEqual(locationManager.location?.coordinate.longitude, mockLocation.coordinate.longitude)
        XCTAssertNil(locationManager.errorMessage)
    }

    func testLocationManagerDidUpdateLocationsWithMultipleLocations() {
        // Given: Multiple locations (should use the last one)
        let location1 = TestHelpers.createMockTokyoLocation()
        let location2 = TestHelpers.createMockNewYorkLocation()
        let location3 = TestHelpers.createMockLondonLocation()

        // When: Multiple locations are provided
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [location1, location2, location3])

        // Then: Should use the last location
        XCTAssertEqual(locationManager.location?.coordinate.latitude, location3.coordinate.latitude)
        XCTAssertEqual(locationManager.location?.coordinate.longitude, location3.coordinate.longitude)
        XCTAssertNil(locationManager.errorMessage)
    }

    func testLocationManagerDidUpdateLocationsWithEmptyArray() {
        // Given: Empty locations array
        let initialLocation = locationManager.location

        // When: Empty locations array is provided
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [])

        // Then: Should not change location
        XCTAssertEqual(locationManager.location, initialLocation)
    }

    func testLocationManagerDidFailWithError() {
        // Given: A location error
        let error = CLError(.locationUnknown)

        // When: Location fails with error
        locationManager.locationManager(CLLocationManager(), didFailWithError: error)

        // Then: Should set error message
        XCTAssertNotNil(locationManager.errorMessage)
        XCTAssertTrue(locationManager.errorMessage?.contains("Failed to get location") == true)
        XCTAssertTrue(locationManager.errorMessage?.contains(error.localizedDescription) == true)
    }
}
