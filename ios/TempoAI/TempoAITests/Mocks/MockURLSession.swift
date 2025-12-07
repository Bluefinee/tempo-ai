/**
 * @fileoverview Mock URL Session for API Testing
 * 
 * APIClientのテストで使用するMockURLSessionを提供します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import Foundation
@testable import TempoAI

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request

        if let error = error {
            throw error
        }

        guard let response = response else {
            throw URLError(.badServerResponse)
        }

        return (data ?? Data(), response)
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastRequest = URLRequest(url: url)

        if let error = error {
            throw error
        }

        guard let response = response else {
            throw URLError(.badServerResponse)
        }

        return (data ?? Data(), response)
    }
}
