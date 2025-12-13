import Foundation

// MARK: - HealthKit Authorization Status

/// HealthKit権限ステータス
enum HealthKitAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case denied = "denied"
    case partiallyAuthorized = "partially_authorized"
}

// MARK: - Location Authorization Status

/// 位置情報権限ステータス
enum LocationAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case authorizedOnce = "authorized_once"
    case denied = "denied"
    case restricted = "restricted"
}
