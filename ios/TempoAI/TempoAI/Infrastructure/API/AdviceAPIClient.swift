import Foundation
import os.log

// MARK: - AdviceAPIClient

/// アドバイスAPI通信クライアント
final class AdviceAPIClient: APIClientProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let session: NetworkSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private static let logger: Logger = Logger(subsystem: "com.tempoai", category: "AdviceAPIClient")

    // MARK: - Initialization

    init(
        session: NetworkSession = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - APIClientProtocol

    func fetchAdvice(_ request: AdviceRequestDTO) async throws -> AdviceResponseDTO {
        let url: URL = APIConfiguration.adviceEndpoint

        Self.logger.debug("Fetching advice from: \(url.absoluteString)")

        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = APIConfiguration.timeout

        do {
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            Self.logger.error("Failed to encode request: \(error.localizedDescription)")
            throw APIError.invalidRequest("Failed to encode request body")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            Self.logger.error("Network error: \(urlError.localizedDescription)")
            throw APIError.networkError(urlError.localizedDescription)
        } catch {
            Self.logger.error("Unknown network error: \(error.localizedDescription)")
            throw APIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownError("Invalid response type")
        }

        Self.logger.debug("Response status code: \(httpResponse.statusCode)")

        // ステータスコードに応じたエラーハンドリング
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            let errorMessage: String = extractErrorMessage(from: data) ?? "Bad request"
            throw APIError.invalidRequest(errorMessage)
        case 429:
            throw APIError.rateLimitExceeded
        case 500...599:
            let errorMessage: String = extractErrorMessage(from: data) ?? "Server error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        default:
            let errorMessage: String = extractErrorMessage(from: data) ?? "Unknown error"
            throw APIError.fromHTTPStatus(httpResponse.statusCode, message: errorMessage)
        }

        do {
            let responseDTO: AdviceResponseDTO = try decoder.decode(AdviceResponseDTO.self, from: data)

            if !responseDTO.success {
                let errorMessage: String = responseDTO.error ?? "Unknown API error"
                Self.logger.error("API returned error: \(errorMessage)")
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }

            Self.logger.debug("Successfully decoded advice response")
            return responseDTO
        } catch let decodingError as DecodingError {
            Self.logger.error("Failed to decode response: \(decodingError.localizedDescription)")
            throw APIError.decodingError(decodingError.localizedDescription)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            Self.logger.error("Unknown decoding error: \(error.localizedDescription)")
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    /// エラーメッセージをレスポンスから抽出
    private func extractErrorMessage(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let error: String?
            let message: String?
        }

        guard let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) else {
            return nil
        }

        return errorResponse.error ?? errorResponse.message
    }
}

// MARK: - AdviceAPIClient+DomainConvenience

extension AdviceAPIClient {

    /// ドメインモデルでアドバイスを取得
    /// - Parameter request: AdviceRequestDTO
    /// - Returns: DailyAdvice
    /// - Throws: APIError
    func fetchDailyAdvice(_ request: AdviceRequestDTO) async throws -> DailyAdvice {
        let response: AdviceResponseDTO = try await fetchAdvice(request)

        guard let advice = response.toDomain() else {
            throw APIError.decodingError("Failed to convert response to domain model")
        }

        return advice
    }
}
