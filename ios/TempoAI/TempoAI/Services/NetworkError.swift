//
//  NetworkError.swift
//  TempoAI
//
//  Created for standard iOS networking error handling
//

import Foundation

/// Comprehensive network error types following iOS best practices
enum NetworkError: Error, LocalizedError {
    // Connection Errors
    case noInternetConnection
    case connectionTimeout
    case connectionRefused
    case serverUnreachable

    // Request Errors
    case invalidURL
    case invalidRequest
    case requestTimeout

    // Response Errors
    case invalidResponse
    case noData
    case decodingFailed(String)
    case encodingFailed(String)

    // HTTP Status Errors
    case clientError(Int, String?)
    case serverError(Int, String?)
    case unexpectedStatusCode(Int)

    // Security Errors
    case certificateError
    case authenticationRequired
    case forbidden

    // Application Errors
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case serviceUnavailable
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "インターネット接続がありません。ネットワーク設定を確認してください。"
        case .connectionTimeout:
            return "接続がタイムアウトしました。しばらく待ってから再試行してください。"
        case .connectionRefused:
            return "サーバーに接続できませんでした。"
        case .serverUnreachable:
            return "サーバーに到達できません。"
        case .invalidURL:
            return "無効なURLです。"
        case .invalidRequest:
            return "無効なリクエストです。"
        case .requestTimeout:
            return "リクエストがタイムアウトしました。"
        case .invalidResponse:
            return "サーバーからの応答が無効です。"
        case .noData:
            return "データを受信できませんでした。"
        case .decodingFailed(let details):
            return "データの解析に失敗しました: \(details)"
        case .encodingFailed(let details):
            return "データのエンコードに失敗しました: \(details)"
        case .clientError(let code, let message):
            return message ?? "クライアントエラー (\(code))"
        case .serverError(let code, let message):
            return message ?? "サーバーエラー (\(code))"
        case .unexpectedStatusCode(let code):
            return "予期しないステータスコード: \(code)"
        case .certificateError:
            return "証明書エラーです。"
        case .authenticationRequired:
            return "認証が必要です。"
        case .forbidden:
            return "アクセスが拒否されました。"
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter {
                return "リクエスト制限に達しました。\(Int(retryAfter))秒後に再試行してください。"
            } else {
                return "リクエスト制限に達しました。しばらく待ってから再試行してください。"
            }
        case .serviceUnavailable:
            return "サービスが利用できません。"
        case .unknownError(let error):
            return "不明なエラー: \(error.localizedDescription)"
        }
    }

    var failureReason: String? {
        switch self {
        case .noInternetConnection:
            return "ネットワーク接続なし"
        case .connectionTimeout, .requestTimeout:
            return "タイムアウト"
        case .connectionRefused:
            return "接続拒否"
        case .serverUnreachable:
            return "サーバー到達不可"
        case .invalidURL, .invalidRequest:
            return "無効なリクエスト"
        case .invalidResponse, .noData:
            return "無効なレスポンス"
        case .decodingFailed, .encodingFailed:
            return "データ処理エラー"
        case .clientError:
            return "クライアントエラー"
        case .serverError:
            return "サーバーエラー"
        case .unexpectedStatusCode:
            return "予期しないレスポンス"
        case .certificateError, .authenticationRequired, .forbidden:
            return "セキュリティエラー"
        case .rateLimitExceeded:
            return "レート制限"
        case .serviceUnavailable:
            return "サービス利用不可"
        case .unknownError:
            return "不明なエラー"
        }
    }

    /// Whether this error should trigger a retry
    var isRetriable: Bool {
        switch self {
        case .connectionTimeout, .requestTimeout, .serverError, .serviceUnavailable:
            return true
        case .noInternetConnection, .connectionRefused, .serverUnreachable:
            return true
        case .rateLimitExceeded:
            return true
        default:
            return false
        }
    }

    /// Suggested retry delay in seconds
    var retryDelay: TimeInterval {
        switch self {
        case .rateLimitExceeded(let retryAfter):
            return retryAfter ?? 60.0
        case .serverError:
            return 5.0
        case .connectionTimeout, .requestTimeout:
            return 2.0
        default:
            return 1.0
        }
    }

    /// Convert from URLError to NetworkError
    static func from(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return .noInternetConnection
        case .timedOut:
            return .connectionTimeout
        case .cannotConnectToHost, .networkConnectionLost:
            return .connectionRefused
        case .cannotFindHost, .dnsLookupFailed:
            return .serverUnreachable
        case .badURL:
            return .invalidURL
        case .badServerResponse:
            return .invalidResponse
        case .secureConnectionFailed:
            return .certificateError
        default:
            return .unknownError(urlError)
        }
    }

    /// Convert from HTTP status code to NetworkError
    static func from(statusCode: Int, data: Data? = nil) -> NetworkError {
        let message = data?.asString()

        switch statusCode {
        case 400 ... 499:
            switch statusCode {
            case 401:
                return .authenticationRequired
            case 403:
                return .forbidden
            case 429:
                // Try to parse retry-after from response
                return .rateLimitExceeded(retryAfter: nil)
            default:
                return .clientError(statusCode, message)
            }
        case 500 ... 599:
            switch statusCode {
            case 503:
                return .serviceUnavailable
            default:
                return .serverError(statusCode, message)
            }
        default:
            return .unexpectedStatusCode(statusCode)
        }
    }
}

// MARK: - Helper Extensions
extension Data {
    fileprivate func asString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
