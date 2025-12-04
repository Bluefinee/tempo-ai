/**
 * @fileoverview API Client Tests for iOS
 * 
 * このファイルは、iOS アプリの API クライアント（APIClient.swift）のテストを担当します。
 * バックエンド API との通信、HTTP リクエスト/レスポンス処理、エラーハンドリング、
 * およびネットワーク接続のテストを行います。
 * 
 * テスト対象:
 * - APIClient クラスの HTTP 通信機能
 * - ヘルス分析 API への POST リクエスト
 * - レスポンス JSON のパース処理
 * - ネットワークエラーのハンドリング
 * - URLSession のモック機能
 * - CoreLocation データの統合
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import XCTest
import Foundation
import CoreLocation
@testable import TempoAI

@MainActor
final class APIClientTests: XCTestCase {
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        apiClient = APIClient(urlSession: mockURLSession)
    }
    
    override func tearDown() {
        mockURLSession = nil
        apiClient = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAPIClientInitialization() {
        XCTAssertNotNil(apiClient)
        // Verify shared instance works with default URLSession
        let sharedClient = APIClient.shared
        XCTAssertNotNil(sharedClient)
    }
    
    // MARK: - Mock Analysis Tests (No API Calls)
    
    func testAnalyzeHealthMockMode() async throws {
        // Given: Valid health data, location, and user profile
        let healthData = createMockHealthData()
        let locationData = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // Setup mock response for analyze-mock endpoint
        let mockAdvice = createMockDailyAdvice()
        let mockResponse = MockAdviceResponse(advice: mockAdvice)
        let responseData = try JSONEncoder().encode(mockResponse)
        
        mockURLSession.data = responseData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/test/analyze-mock")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )
        
        // When: Calling mock analyze health (no actual API call)
        let advice = try await apiClient.analyzeHealthMock(
            healthData: healthData,
            location: locationData,
            userProfile: userProfile
        )
        
        // Then: Should return mock advice with valid structure
        XCTAssertEqual(advice.theme, "バランス調整の日")
        XCTAssertEqual(advice.summary, "今日は適度な運動を。")
        
        // Verify required fields are present
        XCTAssertNotNil(advice.breakfast)
        XCTAssertNotNil(advice.lunch) 
        XCTAssertNotNil(advice.dinner)
        XCTAssertNotNil(advice.exercise)
        XCTAssertNotNil(advice.hydration)
        XCTAssertNotNil(advice.breathing)
        XCTAssertNotNil(advice.sleepPreparation)
        XCTAssertNotNil(advice.weatherConsiderations)
        XCTAssertFalse(advice.priorityActions.isEmpty)
        
        // Verify request was made correctly
        XCTAssertNotNil(mockURLSession.lastRequest)
        XCTAssertEqual(mockURLSession.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(mockURLSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertTrue(mockURLSession.lastRequest?.url?.absoluteString.contains("/test/analyze-mock") ?? false)
    }
    
    // MARK: - Error Handling Tests
    
    func testAnalyzeHealthWithInvalidJSONResponse() async throws {
        // Given: Invalid JSON response data
        mockURLSession.data = "Invalid JSON".data(using: .utf8)
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/analyze")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )
        
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // When & Then: Should throw decoding error
        do {
            _ = try await apiClient.analyzeHealth(
                healthData: healthData,
                location: location,
                userProfile: userProfile
            )
            XCTFail("Expected decoding error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.decodingError)
        } catch {
            XCTFail("Expected APIError but got: \(error)")
        }
    }
    
    func testAnalyzeHealthWithServerError() async throws {
        // Given: Server error response
        mockURLSession.data = nil
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/analyze")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // When & Then: Should throw HTTP error
        do {
            _ = try await apiClient.analyzeHealth(
                healthData: healthData,
                location: location,
                userProfile: userProfile
            )
            XCTFail("Expected HTTP error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.httpError(500))
        } catch {
            XCTFail("Expected APIError but got: \(error)")
        }
    }
    
    func testAnalyzeHealthWithNetworkError() async throws {
        // Given: Network error
        mockURLSession.error = URLError(.notConnectedToInternet)
        
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // When & Then: Should throw network error
        do {
            _ = try await apiClient.analyzeHealth(
                healthData: healthData,
                location: location,
                userProfile: userProfile
            )
            XCTFail("Expected network error but got success")
        } catch let error as APIError {
            if case .networkError = error {
                // Expected network error
            } else {
                XCTFail("Expected network error but got: \(error)")
            }
        } catch {
            XCTFail("Expected APIError but got: \(error)")
        }
    }
    
    // MARK: - Request Construction Tests
    
    func testAnalyzeHealthRequestStructure() async throws {
        // Given: Mock data and successful response
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        let mockAdvice = createMockDailyAdvice()
        let mockAPIResponse = APIResponse(success: true, data: mockAdvice, error: nil)
        let responseData = try JSONEncoder().encode(mockAPIResponse)
        
        mockURLSession.data = responseData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/analyze")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )
        
        // When: Making request
        _ = try await apiClient.analyzeHealth(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )
        
        // Then: Should have made request with proper structure
        XCTAssertNotNil(mockURLSession.lastRequest)
        XCTAssertEqual(mockURLSession.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(mockURLSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        
        // Verify URL
        XCTAssertTrue(mockURLSession.lastRequest?.url?.absoluteString.contains("/health/analyze") ?? false)
        
        // Verify request body structure
        if let requestBody = mockURLSession.lastRequest?.httpBody {
            let requestDict = try JSONSerialization.jsonObject(with: requestBody) as? [String: Any]
            XCTAssertNotNil(requestDict?["healthData"])
            XCTAssertNotNil(requestDict?["location"])
            XCTAssertNotNil(requestDict?["userProfile"])
            
            // Verify location data
            let locationDict = requestDict?["location"] as? [String: Double]
            XCTAssertEqual(locationDict?["latitude"], 35.6895)
            XCTAssertEqual(locationDict?["longitude"], 139.6917)
        } else {
            XCTFail("Request body should not be nil")
        }
    }
    
    // MARK: - Response Parsing Tests
    
    func testAnalyzeHealthSuccessfulResponse() async throws {
        // Given: Valid response with all fields
        let mockAdvice = createMockDailyAdvice()
        let mockAPIResponse = APIResponse(success: true, data: mockAdvice, error: nil)
        let responseData = try JSONEncoder().encode(mockAPIResponse)
        
        mockURLSession.data = responseData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/analyze")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )
        
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // When: Making request
        let advice = try await apiClient.analyzeHealth(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )
        
        // Then: Should parse all fields correctly
        XCTAssertEqual(advice.theme, "バランス調整の日")
        XCTAssertEqual(advice.summary, "今日は適度な運動を。")
        
        // Breakfast
        XCTAssertEqual(advice.breakfast.recommendation, "タンパク質豊富な朝食を")
        XCTAssertEqual(advice.breakfast.examples?.count, 2)
        
        // Exercise
        XCTAssertEqual(advice.exercise.intensity, "Moderate")
        XCTAssertEqual(advice.exercise.timing, "午前10時頃")
        
        // Hydration
        XCTAssertEqual(advice.hydration.target, "2.5")
        XCTAssertEqual(advice.hydration.schedule.morning, "500")
        
        // Priority actions
        XCTAssertEqual(advice.priorityActions.count, 3)
    }
    
    // MARK: - HTTP Status Code Tests
    
    func testAnalyzeHealthHTTPStatusCodes() async throws {
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        let statusCodes = [400, 401, 403, 404, 429, 500, 502, 503]
        
        for statusCode in statusCodes {
            mockURLSession.data = nil
            mockURLSession.response = HTTPURLResponse(
                url: URL(string: "http://localhost:8787/api/health/analyze")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )
            
            do {
                _ = try await apiClient.analyzeHealth(
                    healthData: healthData,
                    location: location,
                    userProfile: userProfile
                )
                XCTFail("Expected error for status code \(statusCode)")
            } catch let error as APIError {
                XCTAssertEqual(error, APIError.httpError(statusCode))
            } catch {
                XCTFail("Expected APIError but got: \(error)")
            }
        }
    }
    
    // MARK: - Connection Tests
    
    func testConnectionSuccess() async {
        // Given: Successful connection
        mockURLSession.data = Data()
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When: Testing connection
        let isConnected = await apiClient.testConnection()
        
        // Then: Should return true
        XCTAssertTrue(isConnected)
    }
    
    func testConnectionFailure() async {
        // Given: Failed connection
        mockURLSession.error = URLError(.notConnectedToInternet)
        
        // When: Testing connection
        let isConnected = await apiClient.testConnection()
        
        // Then: Should return false
        XCTAssertFalse(isConnected)
    }
    
    // MARK: - Health Status Tests
    
    func testCheckHealthStatusSuccess() async throws {
        // Given: Successful health status response
        let statusResponse = ["status": "healthy", "service": "Test Service"]
        let responseData = try JSONSerialization.data(withJSONObject: statusResponse)
        
        mockURLSession.data = responseData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/status")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When: Checking health status
        let status = try await apiClient.checkHealthStatus()
        
        // Then: Should return healthy status
        XCTAssertEqual(status, "healthy")
    }
    
    func testCheckHealthStatusError() async throws {
        // Given: Error response
        mockURLSession.data = nil
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "http://localhost:8787/api/health/status")!,
            statusCode: 503,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then: Should throw error
        do {
            _ = try await apiClient.checkHealthStatus()
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.httpError(503))
        } catch {
            XCTFail("Expected APIError but got: \(error)")
        }
    }
}

// MARK: - Mock Classes

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
        if let error = error {
            throw error
        }
        
        guard let response = response else {
            throw URLError(.badServerResponse)
        }
        
        return (data ?? Data(), response)
    }
}

// MARK: - Test Data Helpers

extension APIClientTests {
    func createMockHealthData() -> HealthData {
        return HealthData(
            sleep: SleepData(
                duration: 7.5,
                deep: 1.2,
                rem: 1.8,
                light: 4.5,
                awake: 0.0,
                efficiency: 88
            ),
            hrv: HRVData(
                average: 45.2,
                min: 38.1,
                max: 52.7
            ),
            heartRate: HeartRateData(
                resting: 58,
                average: 72,
                min: 55,
                max: 85
            ),
            activity: ActivityData(
                steps: 8234,
                distance: 6.2,
                calories: 420,
                activeMinutes: 35
            )
        )
    }
    
    func createMockUserProfile() -> UserProfile {
        return UserProfile(
            age: 30,
            gender: "male",
            goals: ["疲労回復", "集中力向上"],
            dietaryPreferences: "バランス重視",
            exerciseHabits: "週3回ジム",
            exerciseFrequency: "3回/週"
        )
    }
    
    func createMockDailyAdvice() -> DailyAdvice {
        return DailyAdvice(
            theme: "バランス調整の日",
            summary: "今日は適度な運動を。",
            breakfast: MealAdvice(
                recommendation: "タンパク質豊富な朝食を",
                reason: "筋肉合成を促進",
                examples: ["ゆで卵", "ヨーグルト"],
                timing: nil,
                avoid: nil
            ),
            lunch: MealAdvice(
                recommendation: "バランス食",
                reason: "エネルギー維持",
                examples: ["サラダ"],
                timing: "12:30 PM",
                avoid: ["揚げ物"]
            ),
            dinner: MealAdvice(
                recommendation: "軽い食事",
                reason: "睡眠の質保持",
                examples: ["魚料理"],
                timing: "6:30 PM",
                avoid: ["遅い食事"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "有酸素運動30分",
                intensity: "Moderate",
                reason: "回復状態が良好",
                timing: "午前10時頃",
                avoid: ["高強度運動"]
            ),
            hydration: HydrationAdvice(
                target: "2.5",
                schedule: HydrationSchedule(
                    morning: "500",
                    afternoon: "1000",
                    evening: "1000"
                ),
                reason: "活動量に対応"
            ),
            breathing: BreathingAdvice(
                technique: "4-7-8 breathing",
                duration: "5分",
                frequency: "2回",
                instructions: ["吸う", "止める", "吐く"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "22:30",
                routine: ["お風呂", "読書"],
                avoid: ["スマホ"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: ["日焼け止めを"],
                opportunities: ["散歩に最適"]
            ),
            priorityActions: ["朝食を摂る", "運動する", "水分摂取"]
        )
    }
}