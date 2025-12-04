/**
 * @fileoverview Location Manager Authorization Tests
 * 
 * LocationManager の権限要求と管理機能のテストを担当します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import CoreLocation
import XCTest
@testable import TempoAI

@MainActor
final class LocationManagerAuthorizationTests: XCTestCase {
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

    // MARK: - Authorization Tests

    func testRequestLocationWhenNotDetermined() {
        // Given: Authorization status is not determined
        mockCLLocationManager.authorizationStatusResult = .notDetermined
        locationManager.authorizationStatus = .notDetermined

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should request authorization
        XCTAssertTrue(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
    }

    func testRequestLocationWhenAuthorizedWhenInUse() {
        // Given: Authorization status is authorized when in use
        mockCLLocationManager.authorizationStatusResult = .authorizedWhenInUse
        locationManager.authorizationStatus = .authorizedWhenInUse

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should request location
        XCTAssertFalse(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertTrue(mockCLLocationManager.requestLocationCalled)
        XCTAssertNil(locationManager.errorMessage)
    }

    func testRequestLocationWhenAuthorizedAlways() {
        // Given: Authorization status is authorized always
        mockCLLocationManager.authorizationStatusResult = .authorizedAlways
        locationManager.authorizationStatus = .authorizedAlways

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should request location
        XCTAssertFalse(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertTrue(mockCLLocationManager.requestLocationCalled)
        XCTAssertNil(locationManager.errorMessage)
    }

    func testRequestLocationWhenDenied() {
        // Given: Authorization status is denied
        mockCLLocationManager.authorizationStatusResult = .denied
        locationManager.authorizationStatus = .denied

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should set error message
        XCTAssertFalse(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
        XCTAssertEqual(locationManager.errorMessage, "Location access denied. Please enable in Settings.")
    }

    func testRequestLocationWhenRestricted() {
        // Given: Authorization status is restricted
        mockCLLocationManager.authorizationStatusResult = .restricted
        locationManager.authorizationStatus = .restricted

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should set error message
        XCTAssertFalse(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
        XCTAssertEqual(locationManager.errorMessage, "Location access denied. Please enable in Settings.")
    }

    func testRequestLocationWhenUnknownStatus() {
        // Given: Authorization status is unknown
        let unknownStatus = CLAuthorizationStatus(rawValue: 999) ?? .notDetermined
        mockCLLocationManager.authorizationStatusResult = unknownStatus
        locationManager.authorizationStatus = unknownStatus

        // When: Requesting location
        locationManager.requestLocation()

        // Then: Should set error message
        XCTAssertFalse(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertFalse(mockCLLocationManager.requestLocationCalled)
        XCTAssertEqual(locationManager.errorMessage, "Unknown location authorization status.")
    }
}
