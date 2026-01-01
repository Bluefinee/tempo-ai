import Foundation

// MARK: - APIClientProtocol

/// API通信プロトコル（テスト容易性のため）
protocol APIClientProtocol: Sendable {

    /// アドバイスを取得
    /// - Parameter request: リクエストDTO
    /// - Returns: アドバイスレスポンスDTO
    /// - Throws: APIError
    func fetchAdvice(_ request: AdviceRequestDTO) async throws -> AdviceResponseDTO
}

// MARK: - NetworkSession

/// URLSessionのラッパープロトコル（テスト用）
protocol NetworkSession: Sendable {

    /// データタスクを実行
    /// - Parameter request: URLRequest
    /// - Returns: データとレスポンスのタプル
    /// - Throws: ネットワークエラー
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession+NetworkSession

extension URLSession: NetworkSession {}
