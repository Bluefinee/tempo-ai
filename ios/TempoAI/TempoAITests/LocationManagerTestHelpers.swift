/**
 * @fileoverview Location Manager Test Helpers
 * 
 * LocationManagerのテストで使用するモックとヘルパー関数を提供します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import CoreLocation
import XCTest
@testable import TempoAI

// MARK: - Mock Classes

class MockCLLocationManager: NSObject, CLLocationManagerProtocol {
    private let identifier: UUID = UUID()

    var authorizationStatusResult: CLAuthorizationStatus = .notDetermined
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    var delegate: (any CLLocationManagerDelegate)?

    var requestWhenInUseAuthorizationCalled: Bool = false
    var requestLocationCalled: Bool = false
    var requestLocationCalledCount: Int = 0

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
        guard let other = object as? MockCLLocationManager else { return false }
        return self.identifier == other.identifier
    }

    override var hash: Int {
        return identifier.hashValue
    }
}

// MARK: - Location Validation Helpers

struct LocationTestHelpers {
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90.0 && coordinate.latitude <= 90.0 &&
               coordinate.longitude >= -180.0 && coordinate.longitude <= 180.0
    }

    static func isRecentTimestamp(_ timestamp: Date) -> Bool {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        return timestamp > fiveMinutesAgo
    }

    static func isAccurateLocation(_ location: CLLocation) -> Bool {
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy < 100 // Within 100 meters
    }

    static func createLocationWithAccuracy(_ accuracy: Double) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            altitude: 10.0,
            horizontalAccuracy: accuracy,
            verticalAccuracy: accuracy,
            timestamp: Date()
        )
    }
}

// MARK: - Test Data Factory

extension TestHelpers {
    static func createMockLocation(latitude: Double = 35.6895, longitude: Double = 139.6917) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            timestamp: Date()
        )
    }

    static func createMockTokyoLocation() -> CLLocation {
        return createMockLocation(latitude: 35.6895, longitude: 139.6917)
    }

    static func createMockNewYorkLocation() -> CLLocation {
        return createMockLocation(latitude: 40.7128, longitude: -74.0060)
    }

    static func createMockLondonLocation() -> CLLocation {
        return createMockLocation(latitude: 51.5074, longitude: -0.1278)
    }

    static func createMockInvalidLocation() -> CLLocation {
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
