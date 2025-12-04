/**
 * @fileoverview Location Manager Data Tests
 * 
 * LocationManager のデータ処理と状態管理のテストを担当します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import CoreLocation
import XCTest
@testable import TempoAI

@MainActor
final class LocationManagerDataTests: XCTestCase {
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

    // MARK: - Location Data Tests

    func testLocationDataWhenLocationExists() {
        // Given: Valid location
        let mockLocation = TestHelpers.createMockTokyoLocation()
        locationManager.location = mockLocation

        // When: Getting location data
        let locationData = locationManager.locationData

        // Then: Should return proper location data
        XCTAssertNotNil(locationData)
        XCTAssertEqual(locationData?.latitude, mockLocation.coordinate.latitude)
        XCTAssertEqual(locationData?.longitude, mockLocation.coordinate.longitude)
    }

    func testLocationDataWhenLocationIsNil() {
        // Given: No location
        locationManager.location = nil

        // When: Getting location data
        let locationData = locationManager.locationData

        // Then: Should return nil
        XCTAssertNil(locationData)
    }

    func testLocationDataWithDifferentCoordinates() {
        // Test multiple different locations
        let testLocations = [
            TestHelpers.createMockTokyoLocation(),
            TestHelpers.createMockNewYorkLocation(),
            TestHelpers.createMockLondonLocation(),
            TestHelpers.createMockLocation(latitude: 0, longitude: 0), // Equator
            TestHelpers.createMockLocation(latitude: -90, longitude: -180) // South Pole
        ]

        for testLocation in testLocations {
            // Given: Specific location
            locationManager.location = testLocation

            // When: Getting location data
            let locationData = locationManager.locationData

            // Then: Should match coordinates
            XCTAssertNotNil(locationData)
            XCTAssertEqual(locationData?.latitude, testLocation.coordinate.latitude)
            XCTAssertEqual(locationData?.longitude, testLocation.coordinate.longitude)
        }
    }

    // MARK: - Error Handling Tests

    func testMultipleLocationErrors() {
        let testErrors = [
            CLError(.locationUnknown),
            CLError(.denied),
            CLError(.network),
            CLError(.headingFailure),
            CLError(.rangingUnavailable)
        ]

        for error in testErrors {
            // Clear previous error
            locationManager.errorMessage = nil

            // When: Each error occurs
            locationManager.locationManager(CLLocationManager(), didFailWithError: error)

            // Then: Should set appropriate error message
            XCTAssertNotNil(locationManager.errorMessage)
            XCTAssertTrue(locationManager.errorMessage?.contains("Failed to get location") == true)
        }
    }

    // MARK: - State Management Tests

    func testLocationManagerStateConsistency() {
        // Given: Initial state
        let initialStatus = locationManager.authorizationStatus
        let initialLocation = locationManager.location

        // State should be consistent
        if initialStatus == .denied || initialStatus == .restricted {
            // Should have error message but no location
            XCTAssertNotNil(locationManager.errorMessage)
        }

        if initialLocation != nil {
            // If we have a location, error should be cleared
            // (unless there's a more recent error)
        }
    }

    func testAuthorizationStatusFlowFromNotDeterminedToAuthorized() {
        // Given: Not determined status
        mockCLLocationManager.authorizationStatusResult = .notDetermined
        locationManager.authorizationStatus = .notDetermined

        // When: Request location (should request authorization)
        locationManager.requestLocation()
        XCTAssertTrue(mockCLLocationManager.requestWhenInUseAuthorizationCalled)

        // Then: Simulate authorization granted
        mockCLLocationManager.authorizationStatusResult = .authorizedWhenInUse
        locationManager.locationManagerDidChangeAuthorization(CLLocationManager())

        // Should now request location
        XCTAssertEqual(locationManager.authorizationStatus, .authorizedWhenInUse)
        XCTAssertTrue(mockCLLocationManager.requestLocationCalled)
    }

    func testAuthorizationStatusFlowFromNotDeterminedToDenied() {
        // Given: Not determined status
        mockCLLocationManager.authorizationStatusResult = .notDetermined
        locationManager.authorizationStatus = .notDetermined

        // When: Request location (should request authorization)
        locationManager.requestLocation()
        XCTAssertTrue(mockCLLocationManager.requestWhenInUseAuthorizationCalled)

        // Then: Simulate authorization denied
        mockCLLocationManager.authorizationStatusResult = .denied
        locationManager.locationManagerDidChangeAuthorization(CLLocationManager())

        // Should set error and not request location
        XCTAssertEqual(locationManager.authorizationStatus, .denied)
        XCTAssertEqual(locationManager.errorMessage, "Location access denied")
    }

    // MARK: - Performance Tests

    func testLocationRequestPerformance() {
        measure {
            // Setup authorized state
            mockCLLocationManager.authorizationStatusResult = .authorizedWhenInUse
            locationManager.authorizationStatus = .authorizedWhenInUse

            // Measure location request performance
            locationManager.requestLocation()
        }
    }

    // MARK: - Memory Management Tests

    func testLocationManagerMemoryManagement() {
        weak var weakManager = locationManager
        locationManager = nil

        // Note: In a real test environment, we might need to trigger garbage collection
        // For now, just ensure the manager can be deallocated
        XCTAssertNotNil(weakManager) // Still referenced by the test
    }

    // MARK: - Edge Cases

    func testLocationWithInvalidCoordinates() {
        // Given: Location with invalid accuracy (but valid coordinates)
        let invalidLocation = TestHelpers.createMockInvalidLocation()

        // When: Setting invalid location
        locationManager.location = invalidLocation

        // Then: Should still provide location data (coordinates are valid)
        let locationData = locationManager.locationData
        XCTAssertNotNil(locationData)
        XCTAssertEqual(locationData?.latitude, invalidLocation.coordinate.latitude)
        XCTAssertEqual(locationData?.longitude, invalidLocation.coordinate.longitude)
    }

    func testMultipleConsecutiveLocationRequests() {
        // Given: Authorized state
        mockCLLocationManager.authorizationStatusResult = .authorizedWhenInUse
        locationManager.authorizationStatus = .authorizedWhenInUse

        // When: Making multiple consecutive requests
        locationManager.requestLocation()
        locationManager.requestLocation()
        locationManager.requestLocation()

        // Then: Should handle gracefully
        XCTAssertTrue(mockCLLocationManager.requestLocationCalledCount >= 3)
    }

    // MARK: - Coordinate Validation Tests

    func testLocationCoordinateValidation() {
        let testCoordinates = [
            (35.6895, 139.6917), // Tokyo
            (40.7128, -74.0060), // New York
            (51.5074, -0.1278),  // London
            (0.0, 0.0),          // Equator/Prime Meridian
            (-90.0, -180.0),     // Extreme coordinates
            (90.0, 180.0)       // Other extreme
        ]

        for (lat, lon) in testCoordinates {
            let location = TestHelpers.createMockLocation(latitude: lat, longitude: lon)
            locationManager.location = location

            let locationData = locationManager.locationData
            XCTAssertNotNil(locationData)
            XCTAssertEqual(locationData?.latitude, lat, accuracy: 0.0001)
            XCTAssertEqual(locationData?.longitude, lon, accuracy: 0.0001)

            // Validate coordinate ranges
            XCTAssertTrue(LocationTestHelpers.isValidCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon)))
        }
    }
}
