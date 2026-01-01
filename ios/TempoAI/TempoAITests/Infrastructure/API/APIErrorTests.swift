import XCTest
@testable import TempoAI

// MARK: - APIError Tests

final class APIErrorTests: XCTestCase {

    func testFromHTTPStatus400() {
        let error: APIError = APIError.fromHTTPStatus(400, message: "Bad request")

        if case .invalidRequest(let message) = error {
            XCTAssertEqual(message, "Bad request")
        } else {
            XCTFail("Expected invalidRequest")
        }
    }

    func testFromHTTPStatus429() {
        let error: APIError = APIError.fromHTTPStatus(429, message: "Rate limited")

        XCTAssertEqual(error, .rateLimitExceeded)
    }

    func testFromHTTPStatus500() {
        let error: APIError = APIError.fromHTTPStatus(500, message: "Server error")

        if case .serverError(let code, let message) = error {
            XCTAssertEqual(code, 500)
            XCTAssertEqual(message, "Server error")
        } else {
            XCTFail("Expected serverError")
        }
    }

    func testFromHTTPStatus503() {
        let error: APIError = APIError.fromHTTPStatus(503, message: "Service unavailable")

        if case .serverError(let code, let message) = error {
            XCTAssertEqual(code, 503)
            XCTAssertEqual(message, "Service unavailable")
        } else {
            XCTFail("Expected serverError")
        }
    }

    func testFromHTTPStatusUnknown() {
        let error: APIError = APIError.fromHTTPStatus(418, message: "I'm a teapot")

        if case .unknownError(let message) = error {
            XCTAssertTrue(message.contains("418"))
        } else {
            XCTFail("Expected unknownError")
        }
    }

    func testErrorDescriptions() {
        XCTAssertEqual(APIError.invalidURL.errorDescription, "無効なURLです")
        XCTAssertEqual(APIError.rateLimitExceeded.errorDescription, "リクエスト制限に達しました。しばらく待ってから再試行してください")

        if let description = APIError.invalidRequest("test").errorDescription {
            XCTAssertTrue(description.contains("test"))
        }

        if let description = APIError.serverError(500, "error").errorDescription {
            XCTAssertTrue(description.contains("500"))
            XCTAssertTrue(description.contains("error"))
        }

        if let description = APIError.apiLogicError("logic error").errorDescription {
            XCTAssertTrue(description.contains("logic error"))
        }
    }
}
