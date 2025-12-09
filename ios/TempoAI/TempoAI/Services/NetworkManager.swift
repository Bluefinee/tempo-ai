//
//  NetworkManager.swift
//  TempoAI
//
//  Created for standard iOS networking layer following 2025 best practices
//

import Foundation
import Network
import os.log
import Combine

/// Standard iOS NetworkManager with universal device support
final class NetworkManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = NetworkManager()

    // MARK: - Properties
    private let session: URLSession
    private let configuration: EnvironmentConfiguration
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TempoAI", category: "NetworkManager")

    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?

    // MARK: - Initialization
    override init() {
        self.configuration = EnvironmentConfiguration.current

        // Configure URLSession with best practices
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = self.configuration.timeout
        config.timeoutIntervalForResource = self.configuration.timeout * 2
        config.waitsForConnectivity = true
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true

        // Set cache policy for better performance
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50MB
            diskCapacity: 100 * 1024 * 1024,  // 100MB
            diskPath: "tempo_ai_cache"
        )

        self.session = URLSession(configuration: config)
        self.monitor = NWPathMonitor()

        super.init()

        // Setup network monitoring
        setupNetworkMonitoring()

        if self.configuration.enableLogging {
            logger.info("NetworkManager initialized for \(self.configuration.baseURL)")
            logger.info("Device type: \(DeviceType.current == .simulator ? "Simulator" : "Device")")
        }
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type

                if let self = self, self.configuration.enableLogging {
                    self.logger.info(
                        "Network status changed: \(path.status == .satisfied ? "Connected" : "Disconnected")")
                    if let type = self.connectionType {
                        self.logger.info("Connection type: \(String(describing: type))")
                    }
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Core Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        headers: [String: String]? = nil,
        retryCount: Int = 3
    ) async throws -> T {
        // Build URL
        guard let url = self.configuration.buildURL(for: endpoint) else {
            if self.configuration.enableLogging {
                logger.error("Failed to build URL for endpoint: \(endpoint)")
                logger.error("Base URL: \(self.configuration.baseURL), Port: \(self.configuration.port), Scheme: \(self.configuration.scheme)")
            }
            throw NetworkError.invalidURL
        }
        
        if self.configuration.enableLogging {
            logger.info("🌐 Built URL: \(url.absoluteString)")
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = self.configuration.timeout

        // Set standard headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TempoAI/1.0", forHTTPHeaderField: "User-Agent")

        // Add custom headers
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // Add request body
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingFailed(error.localizedDescription)
            }
        }

        // Execute request with retry logic
        return try await executeWithRetry(request: request, retryCount: retryCount)
    }

    // MARK: - Request Execution with Retry Logic
    private func executeWithRetry<T: Decodable>(
        request: URLRequest,
        retryCount: Int,
        currentAttempt: Int = 1
    ) async throws -> T {
        do {
            if self.configuration.enableLogging {
                logger.info(
                    "Request attempt \(currentAttempt)/\(retryCount + 1): \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")"
                )
            }

            let (data, response) = try await session.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if self.configuration.enableLogging {
                logger.info("Response received: \(httpResponse.statusCode)")
            }

            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200 ... 299:
                // Success - decode response
                return try decodeResponse(data: data)

            case 400 ... 499:
                let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data)
                if self.configuration.enableLogging {
                    logger.error("Client error \(httpResponse.statusCode): \(error.localizedDescription)")
                }
                throw error

            case 500 ... 599:
                let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data)
                if self.configuration.enableLogging {
                    logger.error("Server error \(httpResponse.statusCode): \(error.localizedDescription)")
                }
                throw error

            default:
                throw NetworkError.unexpectedStatusCode(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            // Handle specific network errors
            return try await handleNetworkError(
                error: error,
                request: request,
                retryCount: retryCount,
                currentAttempt: currentAttempt
            )
        } catch let urlError as URLError {
            // Convert URLError to NetworkError
            let networkError = NetworkError.from(urlError)
            return try await handleNetworkError(
                error: networkError,
                request: request,
                retryCount: retryCount,
                currentAttempt: currentAttempt
            )
        } catch {
            // Unknown error
            if self.configuration.enableLogging {
                logger.error("Unknown error: \(error.localizedDescription)")
            }
            throw NetworkError.unknownError(error)
        }
    }

    // MARK: - Error Handling with Exponential Backoff
    private func handleNetworkError<T: Decodable>(
        error: NetworkError,
        request: URLRequest,
        retryCount: Int,
        currentAttempt: Int
    ) async throws -> T {
        if configuration.enableLogging {
            logger.warning("Network error on attempt \(currentAttempt): \(error.localizedDescription)")
        }

        // Check if we should retry
        guard currentAttempt <= retryCount && error.isRetriable else {
            throw error
        }

        // Calculate exponential backoff delay
        let baseDelay = error.retryDelay
        let exponentialDelay = baseDelay * pow(2.0, Double(currentAttempt - 1))
        let jitterDelay = exponentialDelay + Double.random(in: 0 ... 1)  // Add jitter
        let delay = min(jitterDelay, 30.0)  // Cap at 30 seconds

        if configuration.enableLogging {
            logger.info("Retrying in \(String(format: "%.1f", delay)) seconds...")
        }

        // Wait before retry
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        // Retry request
        return try await executeWithRetry(
            request: request,
            retryCount: retryCount,
            currentAttempt: currentAttempt + 1
        )
    }

    // MARK: - Response Decoding
    private func decodeResponse<T: Decodable>(data: Data) throws -> T {
        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            if self.configuration.enableLogging {
                logger.error("Decoding error: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    logger.debug("Response data: \(jsonString)")
                }
            }
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
    
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}
