import Foundation

// MARK: - APIError

/// API通信エラー
public enum APIError: Error, Equatable, Sendable {
    case invalidURL
    case invalidRequest(String)
    case networkError(String)
    case serverError(Int, String)
    case rateLimitExceeded
    case decodingError(String)
    case unknownError(String)
    case apiLogicError(String)
}

// MARK: - LocalizedError

extension APIError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidRequest(let message):
            return "リクエストが無効です: \(message)"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .serverError(let code, let message):
            return "サーバーエラー (\(code)): \(message)"
        case .rateLimitExceeded:
            return "リクエスト制限に達しました。しばらく待ってから再試行してください"
        case .decodingError(let message):
            return "データ解析エラー: \(message)"
        case .unknownError(let message):
            return "不明なエラー: \(message)"
        case .apiLogicError(let message):
            return "APIロジックエラー: \(message)"
        }
    }
}

// MARK: - APIError+HTTP

extension APIError {

    /// HTTPステータスコードからAPIErrorを生成
    /// - Parameters:
    ///   - statusCode: HTTPステータスコード
    ///   - message: エラーメッセージ
    /// - Returns: 対応するAPIError
    public static func fromHTTPStatus(_ statusCode: Int, message: String) -> APIError {
        switch statusCode {
        case 400:
            return .invalidRequest(message)
        case 429:
            return .rateLimitExceeded
        case 500...599:
            return .serverError(statusCode, message)
        default:
            return .unknownError("HTTP \(statusCode): \(message)")
        }
    }
}
