import XCTest
@testable import TempoAI

// MARK: - MockNetworkSession

final class MockNetworkSession: NetworkSession, @unchecked Sendable {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}

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
            if case .serverError(_, let message) = error {
                XCTAssertEqual(message, "API error occurred")
            } else {
                XCTFail("Expected serverError, got \(error)")
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

// MARK: - AdviceRequestDTO Tests

final class AdviceRequestDTOTests: XCTestCase {

    func testProfileDTOFromDomain() {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = DateComponents()
        components.hour = 23
        components.minute = 0
        let targetBedtime: Date = calendar.date(from: components)!

        let profile: UserProfile = UserProfile(
            nickname: "テスト",
            age: 28,
            gender: .male,
            weight: 70.0,
            height: 175.0,
            occupation: .deskWork,
            chronotype: .morning,
            exerciseFrequency: .twiceWeek,
            alcoholFrequency: nil,
            targetBedtime: targetBedtime
        )

        let dto: ProfileDTO = ProfileDTO.from(profile)

        XCTAssertEqual(dto.nickname, "テスト")
        XCTAssertEqual(dto.age, 28)
        XCTAssertEqual(dto.gender, "male")
        XCTAssertEqual(dto.chronotype, "morning")
        XCTAssertEqual(dto.occupation, "deskWork")
        XCTAssertEqual(dto.exerciseFrequency, "twiceWeek")
        XCTAssertEqual(dto.targetBedtime, "23:00")
    }

    func testRhythmAnalysisDTOFromDomain() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 22.5,
            wakeTimeStddevMinutes: 18.3,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )

        let dto: RhythmAnalysisDTO = RhythmAnalysisDTO.from(analysis)

        XCTAssertEqual(dto.bedtimeStddevMinutes, 22.5)
        XCTAssertEqual(dto.wakeTimeStddevMinutes, 18.3)
        XCTAssertEqual(dto.consecutiveStableDays, 5)
        XCTAssertEqual(dto.status, "stable")
    }

    func testSleepDTOFromDomain() {
        let bedtime: Date = Date(timeIntervalSince1970: 1704067200)  // 2024-01-01 00:00
        let wakeTime: Date = Date(timeIntervalSince1970: 1704092400)  // 2024-01-01 07:00

        let sleep: SleepMetrics = SleepMetrics(
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: 420,
            deepSleepMinutes: 90,
            remSleepMinutes: 100
        )

        let dto: SleepDTO = SleepDTO.from(sleep)

        XCTAssertEqual(dto.durationHours, 7.0)
        XCTAssertEqual(dto.deepSleepMinutes, 90)
        XCTAssertEqual(dto.remSleepMinutes, 100)
        XCTAssertEqual(dto.deepSleepRatio, 90.0 / 420.0, accuracy: 0.01)
    }

    func testHRVDTOFromDomain() {
        let hrv: HRVMetrics = HRVMetrics(
            value: 68.0,
            baseline30d: 62.0
        )

        let dto: HRVDTO = HRVDTO.from(hrv)

        XCTAssertEqual(dto.value, 68.0)
        XCTAssertEqual(dto.baseline30d, 62.0)
        XCTAssertEqual(dto.deviationPercent, ((68.0 - 62.0) / 62.0) * 100, accuracy: 0.1)
    }

    func testActivityDTOFromDomain() {
        let activity: ActivityMetrics = ActivityMetrics(
            stepsYesterday: 8500,
            activeMinutesYesterday: 45
        )

        let dto: ActivityDTO = ActivityDTO.from(activity)

        XCTAssertEqual(dto.stepsYesterday, 8500)
        XCTAssertEqual(dto.activeMinutesYesterday, 45)
    }
}

// MARK: - AdviceResponseDTO Tests

final class AdviceResponseDTOTests: XCTestCase {

    func testToDomainSuccess() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: true,
            data: AdviceDataDTO(
                summary: "サマリー",
                fullInsight: "インサイト",
                recommendedAction: RecommendedActionDTO(
                    type: "breathing",
                    message: "深呼吸"
                )
            ),
            error: nil
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNotNil(advice)
        XCTAssertEqual(advice?.summary, "サマリー")
        XCTAssertEqual(advice?.fullInsight, "インサイト")
        XCTAssertEqual(advice?.recommendedAction.type, .breathing)
        XCTAssertEqual(advice?.recommendedAction.message, "深呼吸")
        XCTAssertFalse(advice?.isOfflineFallback ?? true)
    }

    func testToDomainFailureNotSuccess() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: false,
            data: nil,
            error: "エラー"
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNil(advice)
    }

    func testToDomainFailureInvalidActionType() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: true,
            data: AdviceDataDTO(
                summary: "サマリー",
                fullInsight: "インサイト",
                recommendedAction: RecommendedActionDTO(
                    type: "invalid",
                    message: "メッセージ"
                )
            ),
            error: nil
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNil(advice)
    }

    func testAdviceDataDTOToDomain() {
        let dataDTO: AdviceDataDTO = AdviceDataDTO(
            summary: "サマリー",
            fullInsight: "インサイト",
            recommendedAction: RecommendedActionDTO(
                type: "morning_light",
                message: "朝の光"
            )
        )

        let advice: DailyAdvice? = dataDTO.toDomain()

        XCTAssertNotNil(advice)
        XCTAssertEqual(advice?.recommendedAction.type, .morningLight)
    }
}

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
    }
}
