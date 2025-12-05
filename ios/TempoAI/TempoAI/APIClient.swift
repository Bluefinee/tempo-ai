import Combine
import Foundation

@MainActor
class APIClient: ObservableObject {
    static let shared = APIClient()

    private let baseURL: String
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        #if DEBUG
            self.baseURL = "http://localhost:8787/api"
        #else
            self.baseURL = "https://tempo-ai-backend.workers.dev/api"
        #endif
        self.urlSession = urlSession
    }

    private func performRequest<T: Codable>(endpoint: String, request: AnalysisRequest) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30.0

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw APIError.encodingError
        }

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if (200 ... 299).contains(httpResponse.statusCode) {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError
                }
            } else {
                throw APIError.httpError(httpResponse.statusCode)
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Private Helper Methods

    private func createAnalysisRequest(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile,
        healthAnalysis: HealthAnalysis? = nil,
        urgencyLevel: String? = nil
    ) -> AnalysisRequest {
        // Create enhanced request context
        let requestContext = RequestContext(
            urgencyLevel: urgencyLevel ?? determineUrgencyLevel(from: healthAnalysis),
            preferredLanguage: determinePreferredLanguage()
        )

        return AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile,
            healthAnalysis: healthAnalysis,
            requestContext: requestContext
        )
    }

    private func determineUrgencyLevel(from healthAnalysis: HealthAnalysis?) -> String {
        guard let analysis = healthAnalysis else { return "normal" }

        switch analysis.status {
        case .rest: return "high"
        case .care: return "medium"
        case .good, .optimal: return "normal"
        case .unknown: return "low"
        }
    }

    private func determinePreferredLanguage() -> String {
        // Get system language preference, default to English
        let preferredLanguages = Locale.preferredLanguages
        let primaryLanguage = preferredLanguages.first?.prefix(2) ?? "en"
        return String(primaryLanguage)
    }

    private func performRequestWithRetry<T: Codable>(
        endpoint: String,
        request: AnalysisRequest,
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 10.0
    ) async throws -> T {
        var lastError: APIError?

        for attempt in 0 ..< maxRetries {
            do {
                return try await performRequest(endpoint: endpoint, request: request)
            } catch let error as APIError {
                lastError = error

                // Don't retry on client errors (4xx) except for specific cases
                switch error {
                case .httpError(let code) where (400 ..< 500).contains(code) && code != 429:
                    throw error
                case .encodingError, .decodingError, .invalidURL:
                    throw error
                default:
                    // Retry on network errors, server errors (5xx), and rate limiting (429)
                    if attempt < maxRetries - 1 {
                        // Exponential backoff with jitter
                        let backoffDelay = min(baseDelay * pow(2.0, Double(attempt)), maxDelay)
                        let jitter = Double.random(in: 0.0...0.1) * backoffDelay
                        let delayWithJitter = backoffDelay + jitter
                        try await Task.sleep(nanoseconds: UInt64(delayWithJitter * 1_000_000_000))
                    }
                }
            }
        }

        throw lastError ?? APIError.networkError("Max retry attempts exceeded")
    }

    // MARK: - Public API Methods

    func analyzeHealth(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile,
        healthAnalysis: HealthAnalysis? = nil
    ) async throws -> DailyAdvice {
        let request = createAnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile,
            healthAnalysis: healthAnalysis
        )

        let apiResponse: APIResponse<DailyAdvice> = try await performRequestWithRetry(
            endpoint: "health/analyze",
            request: request
        )
        if let advice = apiResponse.data {
            return advice
        } else {
            throw APIError.serverError(apiResponse.error ?? "Unknown error")
        }
    }

    func analyzeHealthMock(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile,
        healthAnalysis: HealthAnalysis? = nil
    ) async throws -> DailyAdvice {
        let request = createAnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile,
            healthAnalysis: healthAnalysis
        )

        let mockResponse: MockAdviceResponse = try await performRequestWithRetry(
            endpoint: "test/analyze-mock",
            request: request,
            maxRetries: 1  // Reduced retries for mock endpoint
        )
        return mockResponse.advice
    }

    /// Enhanced health analysis with personalized context and quality indicators
    func analyzeHealthEnhanced(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile,
        healthAnalysis: HealthAnalysis,
        previousAdviceFollowed: Bool? = nil,
        userFeedback: String? = nil
    ) async throws -> DailyAdvice {
        // Create enhanced context with user feedback
        let enhancedContext = RequestContext(
            previousAdviceFollowed: previousAdviceFollowed,
            userFeedback: userFeedback,
            urgencyLevel: determineUrgencyLevel(from: healthAnalysis),
            preferredLanguage: determinePreferredLanguage()
        )

        let request = AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile,
            healthAnalysis: healthAnalysis,
            requestContext: enhancedContext
        )

        let apiResponse: APIResponse<DailyAdvice> = try await performRequestWithRetry(
            endpoint: "health/analyze-enhanced",
            request: request
        )

        if let advice = apiResponse.data {
            return advice
        } else {
            throw APIError.serverError(apiResponse.error ?? "Unknown error")
        }
    }

    func testConnection() async -> Bool {
        guard let url = URL(string: baseURL.replacingOccurrences(of: "/api", with: "")) else {
            return false
        }

        do {
            let (_, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    func checkHealthStatus() async throws -> String {
        guard let url = URL(string: "\(baseURL)/health/status") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if (200 ... 299).contains(httpResponse.statusCode) {
                do {
                    let healthStatusResponse = try JSONDecoder().decode(HealthStatusResponse.self, from: data)
                    return healthStatusResponse.status
                } catch {
                    throw APIError.decodingError
                }
            } else {
                throw APIError.httpError(httpResponse.statusCode)
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

struct HealthStatusResponse: Codable {
    let status: String
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case networkError(String)
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

// MARK: - URLSession Protocol for Testing
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
