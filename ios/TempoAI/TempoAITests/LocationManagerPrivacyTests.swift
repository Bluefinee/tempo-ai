//
//  LocationManagerPrivacyTests.swift
//  TempoAITests
//
//  Created by Claude on 2025-12-07.
//  
//  Privacy protection functionality tests for LocationManager.
//

import CoreLocation
import XCTest

@testable import TempoAI

class LocationManagerPrivacyTests: XCTestCase {

    var locationManager: LocationManager!
    var mockCLLocationManager: MockCLLocationManager!

    override func setUpWithError() throws {
        mockCLLocationManager = MockCLLocationManager()
        locationManager = LocationManager(locationManager: mockCLLocationManager)
    }

    override func tearDownWithError() throws {
        locationManager = nil
        mockCLLocationManager = nil
    }

    // MARK: - Privacy Protection Tests

    @MainActor
    func testGetPrivacyProtectedLocation() async throws {
        // Given: A precise location
        let preciseLocation = CLLocation(
            latitude: 35.689487, // Tokyo Station with high precision
            longitude: 139.691711,
            altitude: 10,
            horizontalAccuracy: 5,
            verticalAccuracy: 3,
            timestamp: Date()
        )

        // Set up location manager with the precise location
        await locationManager.locationManager(CLLocationManager(), didUpdateLocations: [preciseLocation])

        // When: Getting privacy protected location
        let protectedLocation = try await locationManager.getPrivacyProtectedLocation()

        // Then: Coordinates should be rounded for privacy
        XCTAssertEqual(protectedLocation.coordinate.latitude, 35.69, accuracy: 0.001)
        XCTAssertEqual(protectedLocation.coordinate.longitude, 139.69, accuracy: 0.001)
        XCTAssertEqual(protectedLocation.horizontalAccuracy, 1000)
    }

    @MainActor
    func testGetPrivacyProtectedLocationThrowsWhenNoLocation() async {
        // Given: No current location
        // (locationManager starts with nil location)

        // When/Then: Should throw unavailable error
        do {
            _ = try await locationManager.getPrivacyProtectedLocation()
            XCTFail("Expected LocationError.unavailable to be thrown")
        } catch LocationError.unavailable {
            // Expected
        } catch {
            XCTFail("Expected LocationError.unavailable, got \(error)")
        }
    }

    @MainActor
    func testGetLocationForWeather() async throws {
        // Given: A location
        let testLocation = CLLocation(
            latitude: 40.7589, // Times Square
            longitude: -73.9851,
            altitude: 10,
            horizontalAccuracy: 5,
            verticalAccuracy: 3,
            timestamp: Date()
        )

        await locationManager.locationManager(CLLocationManager(), didUpdateLocations: [testLocation])

        // When: Getting location for weather
        let weatherLocation = try await locationManager.getLocationForWeather()

        // Then: Should return privacy protected LocationData
        XCTAssertEqual(weatherLocation.latitude, 40.76, accuracy: 0.001)
        XCTAssertEqual(weatherLocation.longitude, -73.99, accuracy: 0.001)
    }

    // MARK: - Privacy Level Tests

    @MainActor
    func testGetLocationWithFullPrivacyLevel() async throws {
        // Given: A precise location
        let preciseLocation = CLLocation(
            latitude: 51.5074123456, // London with high precision
            longitude: -0.1278987654,
            altitude: 10,
            horizontalAccuracy: 5,
            verticalAccuracy: 3,
            timestamp: Date()
        )

        await locationManager.locationManager(CLLocationManager(), didUpdateLocations: [preciseLocation])

        // When: Getting full privacy level location
        let protectedLocation = try await locationManager.getLocationWithPrivacy(level: .full)

        // Then: Should maintain high precision
        XCTAssertEqual(protectedLocation.coordinate.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(protectedLocation.coordinate.longitude, -0.1279, accuracy: 0.0001)
        XCTAssertEqual(protectedLocation.horizontalAccuracy, 10)
    }

    @MainActor
    func testGetLocationWithBalancedPrivacyLevel() async throws {
        // Given: A precise location
        let preciseLocation = CLLocation(
            latitude: 51.5074123456,
            longitude: -0.1278987654,
            altitude: 10,
            horizontalAccuracy: 5,
            verticalAccuracy: 3,
            timestamp: Date()
        )

        await locationManager.locationManager(CLLocationManager(), didUpdateLocations: [preciseLocation])

        // When: Getting balanced privacy level location (default)
        let protectedLocation = try await locationManager.getLocationWithPrivacy(level: .balanced)

        // Then: Should reduce precision moderately
        XCTAssertEqual(protectedLocation.coordinate.latitude, 51.51, accuracy: 0.001)
        XCTAssertEqual(protectedLocation.coordinate.longitude, -0.13, accuracy: 0.001)
        XCTAssertEqual(protectedLocation.horizontalAccuracy, 1000)
    }

    @MainActor
    func testGetLocationWithMinimalPrivacyLevel() async throws {
        // Given: A precise location
        let preciseLocation = CLLocation(
            latitude: 51.5074123456,
            longitude: -0.1278987654,
            altitude: 10,
            horizontalAccuracy: 5,
            verticalAccuracy: 3,
            timestamp: Date()
        )

        await locationManager.locationManager(CLLocationManager(), didUpdateLocations: [preciseLocation])

        // When: Getting minimal privacy level location
        let protectedLocation = try await locationManager.getLocationWithPrivacy(level: .minimal)

        // Then: Should significantly reduce precision
        XCTAssertEqual(protectedLocation.coordinate.latitude, 51.5, accuracy: 0.01)
        XCTAssertEqual(protectedLocation.coordinate.longitude, -0.1, accuracy: 0.01)
        XCTAssertEqual(protectedLocation.horizontalAccuracy, 10000)
    }

    // MARK: - Location Quality Tests

    func testIsLocationQualitySufficientWithGoodLocation() {
        // Given: A good quality location (recent, accurate, valid)
        let goodLocation = CLLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 10,
            horizontalAccuracy: 50,
            verticalAccuracy: 10,
            timestamp: Date() // Current time
        )

        // When/Then: Should return true
        XCTAssertTrue(locationManager.isLocationQualitySufficient(goodLocation))
    }

    func testIsLocationQualitySufficientWithOldLocation() {
        // Given: An old location (more than 5 minutes old)
        let oldLocation = CLLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 10,
            horizontalAccuracy: 50,
            verticalAccuracy: 10,
            timestamp: Date().addingTimeInterval(-400) // 6+ minutes ago
        )

        // When/Then: Should return false
        XCTAssertFalse(locationManager.isLocationQualitySufficient(oldLocation))
    }

    func testIsLocationQualitySufficientWithInaccurateLocation() {
        // Given: An inaccurate location
        let inaccurateLocation = CLLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 10,
            horizontalAccuracy: 15000, // Very poor accuracy
            verticalAccuracy: 10,
            timestamp: Date()
        )

        // When/Then: Should return false
        XCTAssertFalse(locationManager.isLocationQualitySufficient(inaccurateLocation))
    }

    func testIsLocationQualitySufficientWithInvalidLocation() {
        // Given: An invalid location with negative accuracy
        let invalidLocation = CLLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 10,
            horizontalAccuracy: -1, // Invalid accuracy
            verticalAccuracy: 10,
            timestamp: Date()
        )

        // When/Then: Should return false
        XCTAssertFalse(locationManager.isLocationQualitySufficient(invalidLocation))
    }

    // MARK: - Privacy Level Enum Tests

    func testPrivacyLevelRoundingFactors() {
        XCTAssertEqual(LocationManager.PrivacyLevel.full.coordinateRoundingFactor, 10000)
        XCTAssertEqual(LocationManager.PrivacyLevel.balanced.coordinateRoundingFactor, 100)
        XCTAssertEqual(LocationManager.PrivacyLevel.minimal.coordinateRoundingFactor, 10)
    }

    func testPrivacyLevelHorizontalAccuracy() {
        XCTAssertEqual(LocationManager.PrivacyLevel.full.horizontalAccuracy, 10)
        XCTAssertEqual(LocationManager.PrivacyLevel.balanced.horizontalAccuracy, 1000)
        XCTAssertEqual(LocationManager.PrivacyLevel.minimal.horizontalAccuracy, 10000)
    }

    // MARK: - Location Error Tests

    func testLocationErrorDescriptions() {
        XCTAssertEqual(LocationError.unavailable.errorDescription, "Location data unavailable")
        XCTAssertEqual(LocationError.unauthorized.errorDescription, "Location access not authorized")
        XCTAssertEqual(LocationError.timeout.errorDescription, "Location request timeout")
        XCTAssertEqual(LocationError.accuracyTooLow.errorDescription, "Location accuracy too low for reliable data")
    }
}
