import Combine
import CoreLocation
import Foundation

// MARK: - LocationManager

/// 位置情報サービスを管理するObservableObjectクラス
@MainActor
final class LocationManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var isLoading: Bool = false
    @Published var lastError: LocationError?

    // MARK: - Properties

    private let locationManager: CLLocationManager
    private let geocoder: CLGeocoder
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Initialization

    override init() {
        self.locationManager = CLLocationManager()
        self.geocoder = CLGeocoder()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// 位置情報の認証を要求
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 現在の位置情報を取得
    func requestCurrentLocation() async throws -> CLLocation {
        isLoading = true
        lastError = nil

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    /// 都市名を取得
    func fetchCityName(for location: CLLocation) async -> String? {
        do {
            let placemarks: [CLPlacemark] = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.administrativeArea
        } catch {
            return nil
        }
    }

    // MARK: - Private Methods

    private func checkAuthorizationStatus() {
        updateAuthorizationStatus(locationManager.authorizationStatus)
    }

    private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .authorizedAlways:
            authorizationStatus = .authorized
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
        case .denied:
            authorizationStatus = .denied
        case .restricted:
            authorizationStatus = .restricted
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.currentLocation = location
            self.isLoading = false

            if let cityName = await fetchCityName(for: location) {
                self.currentCity = cityName
            }

            self.locationContinuation?.resume(returning: location)
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.isLoading = false
            self.lastError = .locationFailed(error)
            self.locationContinuation?.resume(throwing: LocationError.locationFailed(error))
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.updateAuthorizationStatus(manager.authorizationStatus)
        }
    }
}

// MARK: - LocationError

enum LocationError: Error, LocalizedError, Sendable {
    case notAuthorized
    case locationFailed(Error)
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "位置情報へのアクセスが許可されていません"
        case .locationFailed(let error):
            return "位置情報の取得に失敗しました: \(error.localizedDescription)"
        case .geocodingFailed:
            return "住所の取得に失敗しました"
        }
    }
}

// MARK: - Mock for Previews

#if DEBUG
extension LocationManager {
    static func mock(status: LocationAuthorizationStatus = .authorizedWhenInUse) -> LocationManager {
        let manager: LocationManager = LocationManager()
        manager.authorizationStatus = status
        manager.currentCity = "東京都"
        return manager
    }
}
#endif
