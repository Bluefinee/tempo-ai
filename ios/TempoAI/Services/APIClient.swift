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
            
            // Warn in production builds about insecure API key usage
            #if RELEASE
            print("⚠️ WARNING: Using development API key in release build!")
            print("⚠️ Set TEMPO_API_KEY environment variable or configure secure key management")
            print("⚠️ Hardcoded keys are vulnerable to reverse engineering")
            #endif
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
     * Decodes successful advice response with comprehensive error handling
     * 
     * @param data Raw response data from the server
     * @returns DailyAdvice object if successful
     * @throws APIError for various decoding failure scenarios
     */
    private func decodeAdviceResponse(from data: Data) throws -> DailyAdvice {
        // Validate that we have data to decode
        guard !data.isEmpty else {
            throw APIError.missingData("Empty response data")
        }
        
        // Log raw response for debugging (development only)
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📡 API Response: \(jsonString)")
        }
        #endif
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // First, try to decode as a generic response to check for API errors
            let response = try decoder.decode(AdviceResponse.self, from: data)
            
            // Check if the API returned an error
            if !response.success {
                let errorMessage = response.error ?? "Unknown API error"
                let errorCode = response.code ?? "UNKNOWN_ERROR"
                
                // Map specific error codes to appropriate error types
                switch errorCode {
                case "UNAUTHORIZED":
                    throw APIError.unauthorized
                case "VALIDATION_ERROR":
                    throw APIError.badRequest(errorMessage)
                case "RATE_LIMIT_EXCEEDED":
                    throw APIError.rateLimitExceeded
                default:
                    throw APIError.serverError(errorMessage)
                }
            }
            
            // Validate that we have the expected advice data
            guard let advice = response.data?.mainAdvice else {
                throw APIError.missingData("No advice data in successful response")
            }
            
            // Additional validation of required fields
            guard !advice.greeting.isEmpty,
                  !advice.condition.summary.isEmpty,
                  !advice.actionSuggestions.isEmpty,
                  !advice.dailyTry.title.isEmpty else {
                throw APIError.missingData("Incomplete advice data - missing required fields")
            }
            
            return advice
            
        } catch let decodingError as DecodingError {
            // Provide detailed decoding error information
            let errorDescription = formatDecodingError(decodingError)
            throw APIError.decodingError("JSON parsing failed: \(errorDescription)")
        } catch let apiError as APIError {
            // Re-throw API errors without modification
            throw apiError
        } catch {
            // Handle any other unexpected errors
            throw APIError.decodingError("Unexpected decoding error: \(error.localizedDescription)")
        }
    }
    
    /**
     * Formats DecodingError into human-readable description
     * 
     * @param error DecodingError from JSON decoding
     * @returns Formatted error description
     */
    private func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .valueNotFound(let type, let context):
            return "Missing value for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .keyNotFound(let key, let context):
            return "Missing key '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: ".")) - \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error"
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