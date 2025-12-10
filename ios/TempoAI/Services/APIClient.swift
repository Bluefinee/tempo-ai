import Foundation

// MARK: - API Client Configuration

/**
 * Main API client for Tempo AI backend communication
 * 
 * Phase 7 Implementation:
 * - Basic HTTP client setup with URLSession
 * - API key authentication
 * - Type-safe request/response handling
 * - Error handling for network and API errors
 * 
 * Future phases will add:
 * - Retry logic with exponential backoff
 * - Request/response caching
 * - Background request support
 */
@MainActor
final class APIClient: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = APIClient()
    
    /// Base URL for the Tempo AI backend API
    private let baseURL: String
    
    /// URLSession for network requests
    private let session: URLSession

    /// API key for authentication (loaded from environment or defaults to development key)
    private let apiKey: String
    
    // MARK: - Initialization
    
    private init() {
        // Configure base URL based on environment
        if let envBaseURL = ProcessInfo.processInfo.environment["TEMPO_API_BASE_URL"] {
            self.baseURL = envBaseURL
        } else {
            // Default to local development server
            self.baseURL = "http://localhost:8787"
        }

        // Configure API key from environment or use development default
        // IMPORTANT: In production, API key should be loaded from Keychain or secure configuration
        if let envAPIKey = ProcessInfo.processInfo.environment["TEMPO_API_KEY"] {
            self.apiKey = envAPIKey
        } else {
            // Development-only default key
            self.apiKey = "tempo-ai-mobile-app-key-v1"
        }

        // Configure URLSession
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0

        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public API Methods
    
    /**
     * Generates daily advice based on user profile and health data
     * 
     * @param request The advice request containing user data
     * @returns DailyAdvice response from the backend
     * @throws APIError for various failure conditions
     */
    func generateAdvice(request: AdviceRequest) async throws -> DailyAdvice {
        guard let url = URL(string: "\(baseURL)/api/advice") else {
            throw APIError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw APIError.encodingError(error.localizedDescription)
        }
        
        // Perform network request
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            // Check HTTP response status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                return try decodeAdviceResponse(from: data)
                
            case 400:
                let errorMsg = try? decodeErrorMessage(from: data)
                throw APIError.badRequest(errorMsg ?? "Invalid request")
                
            case 401:
                throw APIError.unauthorized
                
            case 429:
                throw APIError.rateLimitExceeded
                
            case 500...599:
                let errorMsg = try? decodeErrorMessage(from: data)
                throw APIError.serverError(errorMsg ?? "Server error")
                
            default:
                throw APIError.unexpectedStatusCode(httpResponse.statusCode)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    /**
     * Health check to verify backend connectivity
     * 
     * @returns True if backend is healthy, false otherwise
     */
    func healthCheck() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            return false
        }

        do {
            let (_, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * Decodes successful advice response
     */
    private func decodeAdviceResponse(from data: Data) throws -> DailyAdvice {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let response = try decoder.decode(AdviceResponse.self, from: data)
            
            guard response.success, let advice = response.data?.mainAdvice else {
                throw APIError.missingData("No advice data in response")
            }
            
            return advice
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError.localizedDescription)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
    
    /**
     * Decodes error message from response
     */
    private func decodeErrorMessage(from data: Data) throws -> String {
        struct ErrorResponse: Codable {
            let error: String
        }
        
        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
        return errorResponse.error
    }
}

// MARK: - API Error Types

/**
 * Comprehensive error types for API communication
 */
enum APIError: Error, LocalizedError {
    case networkError(String)
    case invalidResponse
    case encodingError(String)
    case decodingError(String)
    case badRequest(String)
    case unauthorized
    case rateLimitExceeded
    case serverError(String)
    case missingData(String)
    case unexpectedStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .encodingError(let message):
            return "データの送信に失敗しました: \(message)"
        case .decodingError(let message):
            return "データの解析に失敗しました: \(message)"
        case .badRequest(let message):
            return "リクエストが無効です: \(message)"
        case .unauthorized:
            return "認証に失敗しました"
        case .rateLimitExceeded:
            return "リクエスト制限に達しました。しばらくしてから再試行してください"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        case .missingData(let message):
            return "データが不足しています: \(message)"
        case .unexpectedStatusCode(let code):
            return "予期しないエラーが発生しました (コード: \(code))"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "インターネット接続を確認してください"
        case .unauthorized:
            return "アプリを再起動してください"
        case .rateLimitExceeded:
            return "しばらく時間をおいてから再試行してください"
        case .serverError:
            return "一時的な問題の可能性があります。再試行してください"
        default:
            return nil
        }
    }
}