import Combine
import Foundation

// MARK: - Tempo AI API Client

/// Enhanced API client for Claude AI analysis integration
/// Extends existing APIClient functionality with comprehensive health analysis support
@MainActor
class TempoAIAPIClient: ObservableObject {

    // MARK: - Properties

    static let shared = TempoAIAPIClient()

    private let baseAPIClient: APIClient
    private let baseURL: String
    private let urlSession: URLSessionProtocol

    // MARK: - Initialization

    init(
        baseAPIClient: APIClient = APIClient.shared,
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.baseAPIClient = baseAPIClient
        self.urlSession = urlSession

        #if DEBUG
            self.baseURL = "https://tempo-ai-backend.workers.dev/api"
            print("🌐 TempoAIAPIClient: Using production backend")
        #else
            self.baseURL = "https://tempo-ai-backend.workers.dev/api"
        #endif
    }

    // MARK: - Public AI Analysis Methods

    /// Analyze comprehensive health data using Claude AI
    /// - Parameter request: Analysis request with comprehensive health data
    /// - Returns: AI-generated health insights
    func analyzeHealth(request: AnalysisRequest) async throws -> AIHealthInsights {

        print("🤖 TempoAIAPIClient: Starting AI health analysis...")

        do {
            let apiResponse: APIResponse<AIHealthInsights> = try await performRequestWithRetry(
                endpoint: "ai/analyze-comprehensive",
                request: request
            )

            if let insights = apiResponse.data {
                print("✅ AI analysis completed successfully")
                return insights
            } else {
                let errorMessage = apiResponse.error ?? "Unknown AI analysis error"
                print("❌ AI analysis failed: \(errorMessage)")
                throw TempoAIAPIError.analysisError(errorMessage)
            }

        } catch {
            print("❌ AI analysis request failed: \(error.localizedDescription)")

            // Re-throw the error instead of returning mock data
            throw TempoAIAPIError.requestFailed(error.localizedDescription)
        }
    }

    /// Quick analysis for immediate insights
    /// - Parameters:
    ///   - healthData: Comprehensive health data
    ///   - language: User's preferred language
    /// - Returns: Quick AI insights
    func quickAnalyze(
        healthData: ComprehensiveHealthData,
        language: String = "japanese"
    ) async throws -> QuickAIInsights {

        print("⚡ TempoAIAPIClient: Starting quick AI analysis...")

        let quickRequest = QuickAnalysisRequest(
            healthData: healthData,
            language: language,
            analysisType: .quick,
            timestamp: Date()
        )

        do {
            let apiResponse: APIResponse<QuickAIInsights> = try await performRequestWithRetry(
                endpoint: "ai/quick-analyze",
                request: quickRequest
            )

            if let insights = apiResponse.data {
                print("✅ Quick analysis completed")
                return insights
            } else {
                throw TempoAIAPIError.analysisError(apiResponse.error ?? "Quick analysis failed")
            }

        } catch {
            print("❌ Quick analysis request failed: \(error.localizedDescription)")

            // Re-throw the error instead of returning mock data
            throw TempoAIAPIError.requestFailed(error.localizedDescription)
        }
    }

    /// Test Claude AI connectivity and response
    /// - Returns: Boolean indicating successful connection
    func testAIConnection() async -> Bool {

        guard let url = URL(string: "\(baseURL)/ai/health-check") else {
            return false
        }

        do {
            let (_, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return (200 ... 299).contains(httpResponse.statusCode)
        } catch {
            print("❌ AI connection test failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Private Helper Methods

    /// Perform HTTP request with retry logic
    private func performRequestWithRetry<T: Codable, R: Codable>(
        endpoint: String,
        request: R,
        maxRetries: Int = 3
    ) async throws -> T {

        var lastError: Error?

        for attempt in 0 ..< maxRetries {
            do {
                return try await performRequest(endpoint: endpoint, request: request)
            } catch {
                lastError = error

                // Don't retry on client errors
                if let apiError = error as? TempoAIAPIError,
                    case .clientError = apiError
                {
                    throw error
                }

                // Retry with exponential backoff
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) + Double.random(in: 0 ... 1)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? TempoAIAPIError.networkError("Max retries exceeded")
    }

    /// Perform individual HTTP request
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        request: R
    ) async throws -> T {

        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw TempoAIAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("TempoAI-iOS/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.timeoutInterval = 30.0

        // Encode request body
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw TempoAIAPIError.encodingError
        }

        // Perform request
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TempoAIAPIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200 ... 299:
                // Success - decode response
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw TempoAIAPIError.decodingError
                }

            case 400 ... 499:
                throw TempoAIAPIError.clientError(httpResponse.statusCode)

            case 500 ... 599:
                throw TempoAIAPIError.serverError(httpResponse.statusCode)

            default:
                throw TempoAIAPIError.httpError(httpResponse.statusCode)
            }

        } catch let error as TempoAIAPIError {
            throw error
        } catch {
            throw TempoAIAPIError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Error Handling

    /// Helper method to check if error should trigger local fallback
    private func shouldFallbackToLocalAnalysis(_ error: Error) -> Bool {
        // Determine if error warrants falling back to local analysis
        // vs. propagating error to user
        if let apiError = error as? TempoAIAPIError {
            switch apiError {
            case .networkError, .requestFailed:
                return true
            case .invalidResponse, .analysisError:
                return false
            }
        }
        return true  // Default to local fallback for unknown errors
    }
}

// MARK: - Supporting Types

/// Quick analysis request structure
struct QuickAnalysisRequest: Codable {
    let healthData: ComprehensiveHealthData
    let language: String
    let analysisType: AnalysisType
    let timestamp: Date
}

/// Quick AI insights response
struct QuickAIInsights: Codable {
    let summary: String
    let quickTip: String
    let score: Int
    let timestamp: Date
}

/// Tempo AI specific errors
enum TempoAIAPIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case decodingError
    case networkError(String)
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case httpError(Int)
    case analysisError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .encodingError:
            return "リクエストのエンコードに失敗しました"
        case .decodingError:
            return "レスポンスのデコードに失敗しました"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .clientError(let code):
            return "クライアントエラー: \(code)"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .analysisError(let message):
            return "分析エラー: \(message)"
        }
    }
}
