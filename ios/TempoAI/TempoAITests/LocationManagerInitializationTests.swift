/**
 * @fileoverview Location Manager Initialization Tests
 * 
 * LocationManager の初期化とセットアップ機能のテストを担当します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import CoreLocation
import XCTest
@testable import TempoAI

@MainActor
final class LocationManagerInitializationTests: XCTestCase {
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

    // MARK: - Initialization Tests

    func testLocationManagerInitialization() {
        XCTAssertNotNil(locationManager)
        XCTAssertEqual(locationManager.authorizationStatus, .notDetermined)
        XCTAssertNil(locationManager.location)
        XCTAssertNil(locationManager.errorMessage)
        XCTAssertEqual(mockCLLocationManager.desiredAccuracy, kCLLocationAccuracyBest)
        XCTAssertNotNil(mockCLLocationManager.delegate)
    }
}
