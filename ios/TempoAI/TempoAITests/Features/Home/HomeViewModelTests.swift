//
//  HomeViewModelTests.swift
//  TempoAITests
//
//  Tests for HomeViewModel
//

import XCTest
@testable import TempoAI

// MARK: - HomeViewModelTests

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - Properties

    private var sut: HomeViewModel!
    private var mockAPIClient: MockAPIClient!
    private var mockWeatherClient: MockWeatherAPIClient!
    private var mockStorage: MockLocalStorage!
    private var mockHealthKit: MockHealthKitRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockWeatherClient = MockWeatherAPIClient()
        mockStorage = MockLocalStorage()
        mockHealthKit = MockHealthKitRepository()

        sut = HomeViewModel(
            adviceAPIClient: mockAPIClient,
            scoreCalculator: ScoreCalculator(),
            weatherAPIClient: mockWeatherClient,
            localStorage: mockStorage,
            healthKitRepository: mockHealthKit,
        )
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockWeatherClient = nil
        mockStorage = nil
        mockHealthKit = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_AllPropertiesAreNil() {
        XCTAssertNil(sut.dailyAdvice)
        XCTAssertNil(sut.conditionAssessment)
        XCTAssertNil(sut.userProfile)
        XCTAssertNil(sut.mood)
        XCTAssertNil(sut.todayMode)
        XCTAssertNil(sut.weather)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.loadingStep, 0)
        XCTAssertNil(sut.error)
    }

    func testInitialState_IsCalibrating_WhenNoCalibrationState() {
        XCTAssertTrue(sut.isCalibrating)
    }

    // MARK: - Greeting Tests

    func testGreeting_Morning_ReturnsCorrectGreeting() {
        // 朝の時間帯をシミュレート（テスト実行時刻に依存）
        // ニックネームがない場合
        XCTAssertTrue(sut.greeting.contains("さん"))
    }

    func testGreeting_WithNickname_IncludesNickname() {
        let profile: UserProfile = createMockUserProfile(nickname: "テスト太郎")
        if let data = try? JSONEncoder().encode(profile) {
            mockStorage.setMockData(data, forKey: StorageKeys.userProfile)
        }

        sut = HomeViewModel(
            adviceAPIClient: mockAPIClient,
            scoreCalculator: ScoreCalculator(),
            weatherAPIClient: mockWeatherClient,
            localStorage: mockStorage,
            healthKitRepository: mockHealthKit,
        )

        XCTAssertTrue(sut.greeting.contains("テスト太郎"))
    }

    // MARK: - Loading Steps Tests

    func testLoadingSteps_HasFourSteps() {
        XCTAssertEqual(HomeViewModel.loadingSteps.count, 4)
    }

    func testLoadingSteps_FirstStep_IsSleepAnalysis() {
        XCTAssertEqual(HomeViewModel.loadingSteps[0], "睡眠データを解析中...")
    }

    func testLoadingSteps_LastStep_IsAdviceCreation() {
        XCTAssertEqual(HomeViewModel.loadingSteps[3], "あなたへのアドバイスを作成中...")
    }

    func testCurrentLoadingMessage_ReturnsCorrectMessage() {
        sut.loadingStep = 0
        XCTAssertEqual(sut.currentLoadingMessage, "睡眠データを解析中...")

        sut.loadingStep = 2
        XCTAssertEqual(sut.currentLoadingMessage, "今日の環境を確認中...")
    }

    // MARK: - Calibration Tests

    func testIsCalibrating_True_WhenNoCalibrationState() {
        XCTAssertTrue(sut.isCalibrating)
    }

    func testIsCalibrating_True_WhenCalibrationNotComplete() {
        let state: CalibrationState = CalibrationState(startDate: Date(), daysCompleted: 3)
        if let data = try? JSONEncoder().encode(state) {
            mockStorage.setMockData(data, forKey: StorageKeys.calibrationState)
        }

        // Reload to pick up the mock data
        sut = HomeViewModel(
            adviceAPIClient: mockAPIClient,
            scoreCalculator: ScoreCalculator(),
            weatherAPIClient: mockWeatherClient,
            localStorage: mockStorage,
            healthKitRepository: mockHealthKit,
        )

        XCTAssertTrue(sut.isCalibrating)
    }

    func testIsCalibrating_False_WhenCalibrationComplete() {
        let state: CalibrationState = CalibrationState(startDate: Date(), daysCompleted: 7)
        if let data = try? JSONEncoder().encode(state) {
            mockStorage.setMockData(data, forKey: StorageKeys.calibrationState)
        }

        sut = HomeViewModel(
            adviceAPIClient: mockAPIClient,
            scoreCalculator: ScoreCalculator(),
            weatherAPIClient: mockWeatherClient,
            localStorage: mockStorage,
            healthKitRepository: mockHealthKit,
        )

        XCTAssertFalse(sut.isCalibrating)
    }

    // MARK: - Morning Check-in Tests

    func testSubmitMorningCheckIn_DoesNothing_WhenMoodIsNil() async {
        sut.todayMode = .normal

        await sut.submitMorningCheckIn()

        XCTAssertFalse(sut.isMorningCheckInCompleted)
    }

    func testSubmitMorningCheckIn_DoesNothing_WhenTodayModeIsNil() async {
        sut.mood = .good

        await sut.submitMorningCheckIn()

        XCTAssertFalse(sut.isMorningCheckInCompleted)
    }

    func testSubmitMorningCheckIn_Succeeds_WhenBothSet() async {
        sut.mood = .good
        sut.todayMode = .normal

        await sut.submitMorningCheckIn()

        XCTAssertTrue(sut.isMorningCheckInCompleted)
    }

    // MARK: - Error Tests

    func testHomeError_DataLoadFailed_HasCorrectDescription() {
        let error: HomeError = .dataLoadFailed
        XCTAssertEqual(error.errorDescription, "データの読み込みに失敗しました")
    }

    func testHomeError_APIError_IncludesMessage() {
        let error: HomeError = .apiError("接続タイムアウト")
        XCTAssertEqual(error.errorDescription, "API エラー: 接続タイムアウト")
    }

    func testHomeError_HealthKitError_IncludesMessage() {
        let error: HomeError = .healthKitError("アクセス権限がありません")
        XCTAssertEqual(error.errorDescription, "HealthKit エラー: アクセス権限がありません")
    }

    func testHomeError_OfflineMode_HasCorrectDescription() {
        let error: HomeError = .offlineMode
        XCTAssertEqual(error.errorDescription, "オフラインモードです")
    }

    // MARK: - Log Models Tests

    func testMoodLog_IsEncodableAndDecodable() throws {
        let log: MoodLog = MoodLog(date: Date(), mood: .good)

        let encoded: Data = try JSONEncoder().encode(log)
        let decoded: MoodLog = try JSONDecoder().decode(MoodLog.self, from: encoded)

        XCTAssertEqual(decoded.mood, .good)
    }

    func testTodayModeLog_IsEncodableAndDecodable() throws {
        let log: TodayModeLog = TodayModeLog(date: Date(), mode: .challenge)

        let encoded: Data = try JSONEncoder().encode(log)
        let decoded: TodayModeLog = try JSONDecoder().decode(TodayModeLog.self, from: encoded)

        XCTAssertEqual(decoded.mode, .challenge)
    }

    func testFeedbackLog_IsEncodableAndDecodable() throws {
        let log: FeedbackLog = FeedbackLog(
            date: Date(),
            isHelpful: true,
            adviceSummary: "テストアドバイス"
        )

        let encoded: Data = try JSONEncoder().encode(log)
        let decoded: FeedbackLog = try JSONDecoder().decode(FeedbackLog.self, from: encoded)

        XCTAssertTrue(decoded.isHelpful)
        XCTAssertEqual(decoded.adviceSummary, "テストアドバイス")
    }

    // MARK: - Helper Methods

    private func createMockUserProfile(nickname: String = "テスト") -> UserProfile {
        UserProfile(
            nickname: nickname,
            age: 30,
            gender: .male,
            weight: 70,
            height: 175,
            occupation: .deskWork,
            chronotype: .intermediate,
            exerciseFrequency: .twiceWeek,
            alcoholFrequency: .rarely,
            targetBedtime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
        )
    }
}

// MARK: - Mock Classes

private final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var mockResponse: AdviceResponseDTO?
    var mockError: Error?

    func fetchAdvice(_ request: AdviceRequestDTO) async throws -> AdviceResponseDTO {
        if let error = mockError {
            throw error
        }
        return mockResponse ?? AdviceResponseDTO(success: false, data: nil, error: "Mock not configured")
    }
}

private final class MockWeatherAPIClient: WeatherAPIClientProtocol, @unchecked Sendable {
    var mockWeather: WeatherData?
    var mockError: Error?

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        if let error = mockError {
            throw error
        }
        return mockWeather ?? .mock()
    }
}

private final class MockHealthKitRepository: HealthKitRepositoryProtocol, @unchecked Sendable {
    var mockMetrics: HealthMetrics?
    var mockSleepHistory: [SleepMetrics] = []
    var mockHRVBaseline: Double = 50
    var mockError: Error?

    func requestAuthorization() async throws {
        if let error = mockError {
            throw error
        }
    }

    func fetchTodayMetrics() async throws -> HealthMetrics {
        if let error = mockError {
            throw error
        }
        return mockMetrics ?? HealthMetrics(
            date: Date(),
            sleep: nil,
            hrv: nil,
            activity: nil,
            auxiliary: nil
        )
    }

    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics] {
        if let error = mockError {
            throw error
        }
        return mockSleepHistory
    }

    func fetchHRVBaseline(days: Int) async throws -> Double {
        if let error = mockError {
            throw error
        }
        return mockHRVBaseline
    }
}
