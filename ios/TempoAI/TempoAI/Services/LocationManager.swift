import CoreLocation
import Foundation

// MARK: - Location Error

/// 位置情報エラー
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
    case timeout

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置情報の権限が拒否されています"
        case .locationUnavailable:
            return "位置情報を取得できません"
        case .geocodingFailed:
            return "住所の取得に失敗しました"
        case .timeout:
            return "位置情報の取得がタイムアウトしました"
        }
    }
}

// MARK: - Location Manager

/// 位置情報管理クラス
/// LocationManagingプロトコルに準拠し、テスト時にモック実装を注入可能
@MainActor
final class LocationManager: NSObject, ObservableObject, LocationManaging {
    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false
    @Published var isRequestingLocation: Bool = false
    @Published var currentLocation: LocationData?

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        setupLocationManager()
        checkAuthorizationStatus()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // 都市レベルの精度で十分
        locationManager.distanceFilter = 1000  // 1km以上移動したら更新
    }

    /// 現在の認証ステータスを確認
    func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationStatus = .authorized
        case .denied:
            authorizationStatus = .denied
        case .restricted:
            authorizationStatus = .restricted
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }

    /// 位置情報権限をリクエスト
    func requestAuthorization() {
        guard authorizationStatus == .notDetermined else { return }

        isRequestingPermission = true
        locationManager.requestWhenInUseAuthorization()
    }

    /// 現在位置を取得
    func requestCurrentLocation() async throws -> LocationData {
        guard authorizationStatus == .authorized else {
            throw LocationError.permissionDenied
        }

        isRequestingLocation = true
        defer { isRequestingLocation = false }

        #if DEBUG
        // モック実装
        return Self.generateMockLocationData()
        #else
        throw LocationError.locationUnavailable
        #endif
    }

    /// テストデータを生成（シミュレータ用）
    static func generateMockLocationData() -> LocationData {
        // 東京の座標をベースにしたモックデータ
        let mockCoordinates = LocationCoordinates(
            latitude: 35.6762 + Double.random(in: -0.1...0.1),  // 東京周辺
            longitude: 139.6503 + Double.random(in: -0.1...0.1)
        )

        let mockCities = ["東京", "渋谷区", "新宿区", "港区", "千代田区", "大阪", "名古屋", "横浜"]
        let cityName = mockCities.randomElement() ?? "東京"

        return LocationData(
            coordinates: mockCoordinates,
            cityName: cityName,
            fetchedAt: Date()
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        Task { @MainActor in
            checkAuthorizationStatus()
            isRequestingPermission = false
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }

        Task { @MainActor in
            guard let continuation = locationContinuation else { return }
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            guard let continuation = locationContinuation else { return }
            locationContinuation = nil

            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    continuation.resume(throwing: LocationError.permissionDenied)
                case .locationUnknown:
                    continuation.resume(throwing: LocationError.locationUnavailable)
                default:
                    continuation.resume(throwing: clError)
                }
            } else {
                continuation.resume(throwing: error)
            }
        }
    }
}
