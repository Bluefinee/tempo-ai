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
            return "未設定"
        case .authorized:
            return "常に許可"
        case .authorizedWhenInUse:
            return "使用中のみ許可"
        case .denied:
            return "拒否"
        case .restricted:
            return "制限あり"
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
