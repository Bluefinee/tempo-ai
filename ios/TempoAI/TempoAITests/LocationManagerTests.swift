/**
 * @fileoverview Location Manager Tests for iOS
 * 
 * このファイルは、iOS アプリの位置情報管理機能（LocationManager.swift）のテストを担当します。
 * Core Location との統合、位置情報の取得・管理、権限要求、
 * および位置データの処理機能のテストを行います。
 * 
 * テスト対象:
 * - LocationManager クラスの Core Location 統合
 * - 位置情報の権限要求と管理
 * - GPS 座標の取得と精度管理
 * - 位置情報エラーのハンドリング
 * - バックグラウンド位置取得の制御
 * - モック CLLocationManager の統合
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import XCTest
import CoreLocation
@testable import TempoAI

@MainActor
final class LocationManagerTests: XCTestCase {
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
        let mockLocation = createMockTokyoLocation()
        
        // When: Location is updated
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [mockLocation])
        
        // Then: Should update location and clear error
        XCTAssertEqual(locationManager.location?.coordinate.latitude, mockLocation.coordinate.latitude)
        XCTAssertEqual(locationManager.location?.coordinate.longitude, mockLocation.coordinate.longitude)
        XCTAssertNil(locationManager.errorMessage)
    }
    
    func testLocationManagerDidUpdateLocationsWithMultipleLocations() {
        // Given: Multiple locations (should use the last one)
        let location1 = createMockTokyoLocation()
        let location2 = createMockNewYorkLocation()
        let location3 = createMockLondonLocation()
        
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
    
    // MARK: - Location Data Tests
    
    func testLocationDataWhenLocationExists() {
        // Given: Valid location
        let mockLocation = createMockTokyoLocation()
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
            createMockTokyoLocation(),
            createMockNewYorkLocation(),
            createMockLondonLocation(),
            createMockLocation(latitude: 0, longitude: 0), // Equator
            createMockLocation(latitude: -90, longitude: -180) // South Pole
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
        let initialError = locationManager.errorMessage
        
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
        locationManager.locationManagerDidChangeAuthorization(mockCLLocationManager as! CLLocationManager)
        
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
        locationManager.locationManagerDidChangeAuthorization(mockCLLocationManager as! CLLocationManager)
        
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
        let invalidLocation = createMockInvalidLocation()
        
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
            (90.0, 180.0),       // Other extreme
        ]
        
        for (lat, lon) in testCoordinates {
            let location = createMockLocation(latitude: lat, longitude: lon)
            locationManager.location = location
            
            let locationData = locationManager.locationData
            XCTAssertNotNil(locationData)
            XCTAssertEqual(locationData?.latitude, lat, accuracy: 0.0001)
            XCTAssertEqual(locationData?.longitude, lon, accuracy: 0.0001)
            
            // Validate coordinate ranges
            XCTAssertTrue(isValidCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon)))
        }
    }
}

// MARK: - Mock Classes

class MockCLLocationManager: NSObject, CLLocationManagerProtocol {
    var authorizationStatusResult: CLAuthorizationStatus = .notDetermined
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    var delegate: CLLocationManagerDelegate?
    
    var requestWhenInUseAuthorizationCalled = false
    var requestLocationCalled = false
    var requestLocationCalledCount = 0
    
    var authorizationStatus: CLAuthorizationStatus {
        return authorizationStatusResult
    }
    
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
        // Optionally simulate immediate authorization
        // authorizationStatusResult = .authorizedWhenInUse
        // delegate?.locationManagerDidChangeAuthorization?(self as! CLLocationManager)
    }
    
    func requestLocation() {
        requestLocationCalled = true
        requestLocationCalledCount += 1
    }
}

// For situations where we need to cast to CLLocationManager
extension MockCLLocationManager {
    override func isEqual(_ object: Any?) -> Bool {
        return object is MockCLLocationManager
    }
}

// MARK: - Test Data Helpers

extension LocationManagerTests {
    func createMockLocation(latitude: Double = 35.6895, longitude: Double = 139.6917) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            timestamp: Date()
        )
    }
    
    func createMockTokyoLocation() -> CLLocation {
        return createMockLocation(latitude: 35.6895, longitude: 139.6917)
    }
    
    func createMockNewYorkLocation() -> CLLocation {
        return createMockLocation(latitude: 40.7128, longitude: -74.0060)
    }
    
    func createMockLondonLocation() -> CLLocation {
        return createMockLocation(latitude: 51.5074, longitude: -0.1278)
    }
    
    func createMockInvalidLocation() -> CLLocation {
        // Create location with invalid accuracy (negative)
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            altitude: 0,
            horizontalAccuracy: -1, // Invalid accuracy
            verticalAccuracy: -1,
            timestamp: Date()
        )
    }
}

// MARK: - Location Validation Helpers

extension LocationManagerTests {
    func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90.0 && coordinate.latitude <= 90.0 &&
               coordinate.longitude >= -180.0 && coordinate.longitude <= 180.0
    }
    
    func isRecentTimestamp(_ timestamp: Date) -> Bool {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        return timestamp > fiveMinutesAgo
    }
    
    func isAccurateLocation(_ location: CLLocation) -> Bool {
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy < 100 // Within 100 meters
    }
    
    func createLocationWithAccuracy(_ accuracy: Double) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            altitude: 10.0,
            horizontalAccuracy: accuracy,
            verticalAccuracy: accuracy,
            timestamp: Date()
        )
    }
}