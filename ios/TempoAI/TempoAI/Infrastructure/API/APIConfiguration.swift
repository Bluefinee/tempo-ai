import Foundation

// MARK: - APIConfiguration

/// API設定（環境別URL）
enum APIConfiguration {

    // MARK: - Properties

    /// ベースURL（DEBUG/RELEASEで切替）
    static var baseURL: URL {
        #if DEBUG
        // 開発環境: ローカルサーバー
        // swiftlint:disable:next force_unwrapping
        return URL(string: "http://localhost:8787")!
        #else
        // 本番環境: Cloudflare Workers
        // swiftlint:disable:next force_unwrapping
        return URL(string: "https://tempo-ai-api.workers.dev")!
        #endif
    }

    /// リクエストタイムアウト（秒）
    static let timeout: TimeInterval = 30.0

    // MARK: - Endpoints

    /// アドバイスエンドポイント
    static var adviceEndpoint: URL {
        baseURL.appendingPathComponent("api/advice")
    }
}
