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
        userProfile: UserProfile
    ) -> AnalysisRequest {
        return AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )
    }

    // MARK: - Public API Methods

    func analyzeHealth(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile
    ) async throws -> DailyAdvice {
        let request = createAnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )

        let apiResponse: APIResponse<DailyAdvice> = try await performRequest(
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
        userProfile: UserProfile
    ) async throws -> DailyAdvice {
        let request = createAnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )

        let mockResponse: MockAdviceResponse = try await performRequest(endpoint: "test/analyze-mock", request: request)
        return mockResponse.advice
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
