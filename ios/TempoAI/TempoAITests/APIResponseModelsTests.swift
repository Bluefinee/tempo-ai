import XCTest
@testable import TempoAI

final class APIResponseModelsTests: XCTestCase {

    // MARK: - API Response Model Tests

    func testAPIResponseSuccessCreation() {
        // Given: Successful API response
        let mockAdvice = APIClientTestData.createMockDailyAdvice()
        let apiResponse = APIResponse(success: true, data: mockAdvice, error: nil)

        // Then: Should create valid response
        XCTAssertTrue(apiResponse.success)
        XCTAssertNotNil(apiResponse.data)
        XCTAssertNil(apiResponse.error)
        XCTAssertEqual(apiResponse.data?.theme, "バランス調整の日")
    }

    func testAPIResponseErrorCreation() {
        // Given: Error API response
        let apiResponse = APIResponse<DailyAdvice>(success: false, data: nil, error: "Server error")

        // Then: Should create valid error response
        XCTAssertFalse(apiResponse.success)
        XCTAssertNil(apiResponse.data)
        XCTAssertEqual(apiResponse.error, "Server error")
    }

    func testMockAdviceResponseCreation() {
        // Given: Mock advice response
        let mockAdvice = APIClientTestData.createMockDailyAdvice()
        let mockResponse = MockAdviceResponse(advice: mockAdvice)

        // Then: Should create valid mock response
        XCTAssertEqual(mockResponse.advice.theme, "バランス調整の日")
        XCTAssertNotNil(mockResponse.advice.breakfast)
    }
}
