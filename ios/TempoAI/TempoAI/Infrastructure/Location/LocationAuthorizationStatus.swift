import Foundation

// MARK: - LocationAuthorizationStatus

/// 位置情報の認証状態
enum LocationAuthorizationStatus: Sendable {
    case notDetermined
    case authorized
    case authorizedWhenInUse
    case denied
    case restricted

    var displayText: String {
        switch self {
        case .notDetermined:
            return String(localized: "未設定", comment: "Location authorization not determined")
        case .authorized:
            return String(localized: "常に許可", comment: "Location always authorized")
        case .authorizedWhenInUse:
            return String(localized: "使用中のみ許可", comment: "Location authorized when in use")
        case .denied:
            return String(localized: "拒否", comment: "Location authorization denied")
        case .restricted:
            return String(localized: "制限あり", comment: "Location authorization restricted")
        }
    }

    var isAuthorized: Bool {
        switch self {
        case .authorized, .authorizedWhenInUse:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        }
    }
}
