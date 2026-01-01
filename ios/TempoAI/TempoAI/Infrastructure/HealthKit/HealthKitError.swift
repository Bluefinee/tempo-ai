import Foundation

// MARK: - HealthKitError

/// HealthKit関連のエラー型
enum HealthKitError: Error, LocalizedError, Sendable {
    case notAvailable
    case notAuthorized
    case dataUnavailable
    case queryFailed(Error)
    case insufficientData

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスでは利用できません"
        case .notAuthorized:
            return "HealthKitへのアクセスが許可されていません"
        case .dataUnavailable:
            return "ヘルスデータが利用できません"
        case .queryFailed(let error):
            return "データ取得に失敗しました: \(error.localizedDescription)"
        case .insufficientData:
            return "十分なデータがありません"
        }
    }
}

// MARK: - HealthKitAuthorizationStatus

/// HealthKit認証状態
enum HealthKitAuthorizationStatus: Sendable {
    case notDetermined
    case authorized
    case partiallyAuthorized
    case denied

    var displayText: String {
        switch self {
        case .notDetermined:
            return "未設定"
        case .authorized:
            return "許可済み"
        case .partiallyAuthorized:
            return "一部許可"
        case .denied:
            return "拒否"
        }
    }

    var isAuthorized: Bool {
        switch self {
        case .authorized, .partiallyAuthorized:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}
