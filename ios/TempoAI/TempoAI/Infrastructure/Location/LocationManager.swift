import Combine
import CoreLocation
import Foundation
import os.log

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
    private var timeoutTask: Task<Void, Never>?
    private static let logger: Logger = Logger(subsystem: "com.tempoai", category: "Location")
    private static let locationTimeoutSeconds: UInt64 = 30

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

    /// 現在の位置情報を取得（30秒タイムアウト付き）
    func requestCurrentLocation() async throws -> CLLocation {
        isLoading = true
        lastError = nil

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()

            // タイムアウト処理
            self.timeoutTask = Task {
                try? await Task.sleep(nanoseconds: Self.locationTimeoutSeconds * 1_000_000_000)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    if self.locationContinuation != nil {
                        self.isLoading = false
                        self.lastError = .timeout
                        self.locationContinuation?.resume(throwing: LocationError.timeout)
                        self.locationContinuation = nil
                    }
                }
            }
        }
    }

    /// 都市名を取得
    func fetchCityName(for location: CLLocation) async -> String? {
        do {
            let placemarks: [CLPlacemark] = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.administrativeArea
        } catch {
            #if DEBUG
            Self.logger.debug("Geocoding failed: \(error.localizedDescription)")
            #endif
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
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
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
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
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
    case timeout

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return String(
                localized: "位置情報へのアクセスが許可されていません",
                comment: "Location access not authorized error"
            )
        case .locationFailed(let error):
            let format = String(
                localized: "位置情報の取得に失敗しました: %@",
                comment: "Location fetch failed error with underlying error"
            )
            return String(format: format, error.localizedDescription)
        case .geocodingFailed:
            return String(
                localized: "住所の取得に失敗しました",
                comment: "Geocoding failed error"
            )
        case .timeout:
            return String(
                localized: "位置情報の取得がタイムアウトしました",
                comment: "Location fetch timeout error"
            )
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
