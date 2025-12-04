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

    func analyzeHealth(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile
    ) async throws -> DailyAdvice {
        let request = AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )

        let url = URL(string: "\(baseURL)/health/analyze")!
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

            if httpResponse.statusCode == 200 {
                let apiResponse = try JSONDecoder().decode(APIResponse<DailyAdvice>.self, from: data)
                if let advice = apiResponse.data {
                    return advice
                } else {
                    throw APIError.serverError(apiResponse.error ?? "Unknown error")
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

    func analyzeHealthMock(
        healthData: HealthData,
        location: LocationData,
        userProfile: UserProfile
    ) async throws -> DailyAdvice {
        let request = AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )

        let url = URL(string: "\(baseURL)/test/analyze-mock")!
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

            if httpResponse.statusCode == 200 {
                let mockResponse = try JSONDecoder().decode(MockAdviceResponse.self, from: data)
                return mockResponse.advice
            } else {
                throw APIError.httpError(httpResponse.statusCode)
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    func testConnection() async -> Bool {
        let url = URL(string: baseURL.replacingOccurrences(of: "/api", with: ""))!

        do {
            let (_, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    func checkHealthStatus() async throws -> String {
        let url = URL(string: "\(baseURL)/health/status")!

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let status = jsonObject["status"] as? String
                {
                    return status
                }
                return "Unknown status"
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
