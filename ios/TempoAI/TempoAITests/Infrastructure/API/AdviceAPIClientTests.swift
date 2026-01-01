import XCTest
@testable import TempoAI

// MARK: - AdviceAPIClientTests

final class AdviceAPIClientTests: XCTestCase {

    // MARK: - Properties

    private var mockSession: MockNetworkSession!
    private var client: AdviceAPIClient!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        client = AdviceAPIClient(session: mockSession)
    }

    override func tearDown() {
        mockSession = nil
        client = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createValidRequest() -> AdviceRequestDTO {
        AdviceRequestDTO(
            profile: ProfileDTO(
                nickname: "テスト",
                age: 28,
                gender: "male",
                chronotype: "morning",
                occupation: "deskWork",
                exerciseFrequency: "twiceWeek",
                targetBedtime: "23:00"
            ),
            healthData: HealthDataDTO(
                scores: ScoresDTO(
                    autonomic: 85,
                    sleep: 78,
                    rhythm: 88,
                    activity: 68
                ),
                rhythmAnalysis: RhythmAnalysisDTO(
                    bedtimeStddevMinutes: 22,
                    wakeTimeStddevMinutes: 18,
                    consecutiveStableDays: 5,
                    status: "stable"
                ),
                sleep: nil,
                hrv: nil,
                activity: nil,
                auxiliary: nil
            ),
            location: LocationDTO(
                latitude: 35.6762,
                longitude: 139.6503,
                city: "Tokyo"
            ),
            context: ContextDTO(
                currentTime: "07:15",
                dayOfWeek: "水曜日",
                todayMode: "normal",
                mood: nil
            ),
            weather: nil
        )
    }

    private func createMockHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: APIConfiguration.adviceEndpoint,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    private func createSuccessResponseData() -> Data {
        """
        {
            "success": true,
            "data": {
                "summary": "今日のコンディションは良好です。",
                "fullInsight": "詳細なアドバイスです。",
                "recommendedAction": {
                    "type": "breathing",
                    "message": "深呼吸をしましょう"
                }
            }
        }
        """.data(using: .utf8)!
    }

    // MARK: - Success Tests

    func testFetchAdviceSuccess() async throws {
        mockSession.mockData = createSuccessResponseData()
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

        let response: AdviceResponseDTO = try await client.fetchAdvice(createValidRequest())

        XCTAssertTrue(response.success)
        XCTAssertNotNil(response.data)
        XCTAssertEqual(response.data?.summary, "今日のコンディションは良好です。")
        XCTAssertEqual(response.data?.recommendedAction.type, "breathing")
    }

    func testFetchDailyAdviceSuccess() async throws {
        mockSession.mockData = createSuccessResponseData()
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

        let advice: DailyAdvice = try await client.fetchDailyAdvice(createValidRequest())

        XCTAssertEqual(advice.summary, "今日のコンディションは良好です。")
        XCTAssertEqual(advice.recommendedAction.type, .breathing)
        XCTAssertFalse(advice.isOfflineFallback)
    }

    // MARK: - Error Tests

    func testFetchAdviceNetworkError() async {
        mockSession.mockError = URLError(.notConnectedToInternet)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAdviceBadRequest() async {
        let errorData: Data = """
        {
            "success": false,
            "error": "Invalid request data"
        }
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 400)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .invalidRequest(let message) = error {
                XCTAssertEqual(message, "Invalid request data")
            } else {
                XCTFail("Expected invalidRequest, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAdviceRateLimitExceeded() async {
        let errorData: Data = """
        {
            "success": false,
            "error": "Rate limit exceeded"
        }
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 429)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            XCTAssertEqual(error, .rateLimitExceeded)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAdviceServerError() async {
        let errorData: Data = """
        {
            "success": false,
            "error": "Internal server error"
        }
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 500)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 500)
                XCTAssertEqual(message, "Internal server error")
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAdviceDecodingError() async {
        let invalidData: Data = "invalid json".data(using: .utf8)!

        mockSession.mockData = invalidData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAdviceAPIReturnedError() async {
        let errorData: Data = """
        {
            "success": false,
            "error": "API error occurred"
        }
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

        do {
            _ = try await client.fetchAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .apiLogicError(let message) = error {
                XCTAssertEqual(message, "API error occurred")
            } else {
                XCTFail("Expected apiLogicError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Domain Conversion Tests

    func testFetchDailyAdviceInvalidActionType() async {
        let invalidActionData: Data = """
        {
            "success": true,
            "data": {
                "summary": "サマリー",
                "fullInsight": "インサイト",
                "recommendedAction": {
                    "type": "invalid_type",
                    "message": "メッセージ"
                }
            }
        }
        """.data(using: .utf8)!

        mockSession.mockData = invalidActionData
        mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

        do {
            _ = try await client.fetchDailyAdvice(createValidRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .decodingError(let message) = error {
                XCTAssertTrue(message.contains("domain model"))
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - All Action Types Tests

    func testFetchDailyAdviceAllActionTypes() async throws {
        let actionTypes: [String] = ["breathing", "morning_light", "rest", "activity"]

        for actionType in actionTypes {
            let responseData: Data = """
            {
                "success": true,
                "data": {
                    "summary": "サマリー",
                    "fullInsight": "インサイト",
                    "recommendedAction": {
                        "type": "\(actionType)",
                        "message": "メッセージ"
                    }
                }
            }
            """.data(using: .utf8)!

            mockSession.mockData = responseData
            mockSession.mockResponse = createMockHTTPResponse(statusCode: 200)

            let advice: DailyAdvice = try await client.fetchDailyAdvice(createValidRequest())
            XCTAssertEqual(advice.recommendedAction.type.rawValue, actionType)
        }
    }
}
