import Combine
import CoreLocation
import Foundation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    private var locationManager: CLLocationManagerProtocol

    init(locationManager: CLLocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = locationManager.authorizationStatus

            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            case .denied, .restricted:
                errorMessage = "Location access denied"
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
            errorMessage = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }

    var locationData: LocationData? {
        guard let location = location else { return nil }
        return LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    var currentLocation: CLLocation? {
        return location
    }
}

// MARK: - CLLocationManager Protocol for Testing
protocol CLLocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var desiredAccuracy: CLLocationAccuracy { get set }

    func requestWhenInUseAuthorization()
    func requestLocation()
}

extension CLLocationManager: CLLocationManagerProtocol {}

// MARK: - Location Errors

enum LocationError: Error, LocalizedError {
    case unavailable
    case unauthorized
    case timeout
    case accuracyTooLow
    
    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Location data unavailable"
        case .unauthorized:
            return "Location access not authorized"
        case .timeout:
            return "Location request timeout"
        case .accuracyTooLow:
            return "Location accuracy too low for reliable data"
        }
    }
}

// MARK: - Privacy Protection Extension

extension LocationManager {
    
    /// プライバシー保護された位置情報を取得
    /// 精度を適度に下げることでプライバシーを保護しつつ、天気データ取得に十分な精度を提供
    func getPrivacyProtectedLocation() async throws -> CLLocation {
        guard let location = currentLocation else {
            throw LocationError.unavailable
        }
        
        // 位置情報の精度を適度に下げてプライバシー保護
        // 約1km程度の精度に丸める（小数点以下2桁）
        let reducedAccuracy = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: round(location.coordinate.latitude * 100) / 100,
                longitude: round(location.coordinate.longitude * 100) / 100
            ),
            altitude: location.altitude,
            horizontalAccuracy: 1000, // 1km精度に設定
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )
        
        return reducedAccuracy
    }
    
    /// 天気データ取得用の位置情報を取得（プライバシー保護済み）
    /// - Returns: 天気API用に最適化されたLocationData
    func getLocationForWeather() async throws -> LocationData {
        let protectedLocation = try await getPrivacyProtectedLocation()
        
        return LocationData(
            latitude: protectedLocation.coordinate.latitude,
            longitude: protectedLocation.coordinate.longitude
        )
    }
    
    /// プライバシー設定に応じた位置情報精度レベル
    enum PrivacyLevel {
        case full      // 完全精度（~10m）
        case balanced  // バランス（~1km） - デフォルト
        case minimal   // 最小限（~10km）
        
        var coordinateRoundingFactor: Double {
            switch self {
            case .full: return 10000    // 小数点以下4桁
            case .balanced: return 100  // 小数点以下2桁
            case .minimal: return 10    // 小数点以下1桁
            }
        }
        
        var horizontalAccuracy: CLLocationAccuracy {
            switch self {
            case .full: return 10
            case .balanced: return 1000
            case .minimal: return 10000
            }
        }
    }
    
    /// プライバシーレベルを指定した位置情報取得
    /// - Parameter level: プライバシー保護レベル
    /// - Returns: 指定レベルで保護された位置情報
    func getLocationWithPrivacy(level: PrivacyLevel = .balanced) async throws -> CLLocation {
        guard let location = currentLocation else {
            throw LocationError.unavailable
        }
        
        let factor = level.coordinateRoundingFactor
        
        let protectedLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: round(location.coordinate.latitude * factor) / factor,
                longitude: round(location.coordinate.longitude * factor) / factor
            ),
            altitude: location.altitude,
            horizontalAccuracy: level.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )
        
        return protectedLocation
    }
    
    /// 位置情報の品質チェック
    /// - Parameter location: チェック対象の位置情報
    /// - Returns: 位置情報が十分な品質かどうか
    func isLocationQualitySufficient(_ location: CLLocation) -> Bool {
        // 位置情報が新しい（5分以内）
        let isRecent = location.timestamp.timeIntervalSinceNow > -300
        
        // 水平精度が妥当（10km以内）
        let hasReasonableAccuracy = location.horizontalAccuracy < 10000 && location.horizontalAccuracy > 0
        
        // 有効な座標
        let hasValidCoordinates = CLLocationCoordinate2DIsValid(location.coordinate)
        
        return isRecent && hasReasonableAccuracy && hasValidCoordinates
    }
}
