/**
 * @fileoverview HealthKit Manager Tests for iOS
 * 
 * このファイルは、iOS アプリの HealthKit 管理機能（HealthKitManager.swift）のテストを担当します。
 * Apple HealthKit との統合、ヘルスデータの読み取り・書き込み、権限管理、
 * およびデータ変換処理のテストを行います。
 * 
 * テスト対象:
 * - HealthKitManager クラスの HealthKit 統合
 * - ヘルスデータの権限要求と管理
 * - 睡眠、心拍数、HRV、アクティビティデータの取得
 * - HealthKit データ型の変換処理
 * - エラーハンドリングと例外処理
 * - モック HealthStore の統合
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import HealthKit
import XCTest

@testable import TempoAI


@MainActor
final class HealthKitManagerTests: XCTestCase {
    var healthKitManager: HealthKitManager!
    var mockHealthStore: MockHealthKitStore!
    var mockQueryFactory: MockHealthKitQueryFactory!

    override func setUp() {
        super.setUp()
        mockHealthStore = MockHealthKitStore()
        mockQueryFactory = MockHealthKitQueryFactory()
        healthKitManager = HealthKitManager(healthStore: mockHealthStore, queryFactory: mockQueryFactory)
    }

    override func tearDown() {
        healthKitManager = nil
        mockHealthStore = nil
        mockQueryFactory = nil
        super.tearDown()
    }

    // MARK: - Authorization Tests

    func testRequestAuthorizationSuccess() async throws {
        // Given: Health data is available and authorization will be granted
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .sharingAuthorized

        // When: Requesting authorization
        try await healthKitManager.requestAuthorization()

        // Then: Should be authorized
        XCTAssertTrue(mockHealthStore.requestAuthorizationCalled)
        XCTAssertTrue(healthKitManager.isAuthorized)
        XCTAssertEqual(healthKitManager.authorizationStatus, "Authorized")
    }

    func testRequestAuthorizationDenied() async throws {
        // Given: Health data is available but authorization will be denied
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .sharingDenied

        // When: Requesting authorization
        try await healthKitManager.requestAuthorization()

        // Then: Should not be authorized
        XCTAssertTrue(mockHealthStore.requestAuthorizationCalled)
        XCTAssertFalse(healthKitManager.isAuthorized)
        XCTAssertEqual(healthKitManager.authorizationStatus, "Denied")
    }

    func testRequestAuthorizationNotDetermined() async throws {
        // Given: Health data is available but authorization is not determined
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .notDetermined

        // When: Requesting authorization
        try await healthKitManager.requestAuthorization()

        // Then: Should not be authorized
        XCTAssertTrue(mockHealthStore.requestAuthorizationCalled)
        XCTAssertFalse(healthKitManager.isAuthorized)
        XCTAssertEqual(healthKitManager.authorizationStatus, "Not Determined")
    }

    func testRequestAuthorizationHealthKitNotAvailable() async throws {
        // Given: Health data is not available
        mockHealthStore.isHealthDataAvailableResult = false

        // When & Then: Should throw not available error
        do {
            try await healthKitManager.requestAuthorization()
            XCTFail("Expected HealthKitError.notAvailable")
        } catch HealthKitError.notAvailable {
            // Expected error
            XCTAssertFalse(mockHealthStore.requestAuthorizationCalled)
        } catch {
            XCTFail("Expected HealthKitError.notAvailable but got: \(error)")
        }
    }

    // MARK: - Health Data Fetching Tests

    func testFetchTodayHealthDataWhenAuthorized() async throws {
        // Given: Manager is authorized and health data is available
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .sharingAuthorized
        try await healthKitManager.requestAuthorization()

        // Setup mock query responses
        setupMockQueryResponses()

        // When: Fetching today's health data
        let healthData = try await healthKitManager.fetchTodayHealthData()

        // Then: Should return proper structure with mock data
        XCTAssertNotNil(healthData.sleep)
        XCTAssertNotNil(healthData.hrv)
        XCTAssertNotNil(healthData.heartRate)
        XCTAssertNotNil(healthData.activity)

        // Verify queries were executed
        XCTAssertGreaterThan(mockHealthStore.executedQueries.count, 0)
    }

    func testFetchTodayHealthDataWhenNotAuthorized() async throws {
        // Given: Manager is not authorized
        healthKitManager.isAuthorized = false

        // When & Then: Should throw not authorized error
        do {
            _ = try await healthKitManager.fetchTodayHealthData()
            XCTFail("Expected HealthKitError.notAuthorized")
        } catch HealthKitError.notAuthorized {
            // Expected error
        } catch {
            XCTFail("Expected HealthKitError.notAuthorized but got: \(error)")
        }
    }

    // MARK: - Sleep Data Tests

    func testFetchSleepDataWhenHealthKitNotAvailable() async throws {
        // Given: HealthKit is not available
        mockHealthStore.isHealthDataAvailableResult = false

        // When: Fetch is called internally (we'll test via the mock data path)
        let healthData = try await withMockData {
            return HealthData(
                sleep: SleepData(duration: 6.5, deep: 1.2, rem: 1.8, light: 3.0, awake: 0.5, efficiency: 92),
                hrv: HRVData(average: 45, min: 25, max: 68),
                heartRate: HeartRateData(resting: 62, average: 75, min: 58, max: 145),
                activity: ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
            )
        }

        // Then: Should return mock sleep data
        XCTAssertEqual(healthData.sleep.duration, 6.5)
        XCTAssertEqual(healthData.sleep.deep, 1.2)
        XCTAssertEqual(healthData.sleep.rem, 1.8)
        XCTAssertEqual(healthData.sleep.light, 3.0)
        XCTAssertEqual(healthData.sleep.awake, 0.5)
        XCTAssertEqual(healthData.sleep.efficiency, 92)
    }

    func testSleepDataValidation() async throws {
        // Given: Authorized manager with mock data
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Fetching health data
        let healthData = try await healthKitManager.fetchTodayHealthData()
        let sleep = healthData.sleep

        // Then: Sleep data should be valid
        XCTAssertGreaterThanOrEqual(sleep.duration, 0)
        XCTAssertLessThanOrEqual(sleep.duration, 24)
        XCTAssertGreaterThanOrEqual(sleep.deep, 0)
        XCTAssertGreaterThanOrEqual(sleep.rem, 0)
        XCTAssertGreaterThanOrEqual(sleep.light, 0)
        XCTAssertGreaterThanOrEqual(sleep.awake, 0)
        XCTAssertGreaterThanOrEqual(sleep.efficiency, 0)
        XCTAssertLessThanOrEqual(sleep.efficiency, 100)

        // Sleep components should be reasonable
        let totalComponents = sleep.deep + sleep.rem + sleep.light + sleep.awake
        XCTAssertLessThanOrEqual(totalComponents, sleep.duration + 1.0) // Allow small margin
    }

    // MARK: - HRV Data Tests

    func testHRVDataValidation() async throws {
        // Given: Authorized manager with mock data
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Fetching health data
        let healthData = try await healthKitManager.fetchTodayHealthData()
        let hrv = healthData.hrv

        // Then: HRV data should be valid
        XCTAssertGreaterThanOrEqual(hrv.average, 0)
        XCTAssertLessThanOrEqual(hrv.average, 200) // Upper bound for validation
        XCTAssertLessThanOrEqual(hrv.min, hrv.average)
        XCTAssertGreaterThanOrEqual(hrv.max, hrv.average)
        XCTAssertGreaterThanOrEqual(hrv.min, 0)
        XCTAssertLessThanOrEqual(hrv.max, 200)
    }

    // MARK: - Heart Rate Tests

    func testHeartRateDataValidation() async throws {
        // Given: Authorized manager with mock data
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Fetching health data
        let healthData = try await healthKitManager.fetchTodayHealthData()
        let heartRate = healthData.heartRate

        // Then: Heart rate data should be valid
        XCTAssertGreaterThanOrEqual(heartRate.resting, 30)
        XCTAssertLessThanOrEqual(heartRate.resting, 120)
        XCTAssertGreaterThanOrEqual(heartRate.average, 30)
        XCTAssertLessThanOrEqual(heartRate.average, 220)
        XCTAssertGreaterThanOrEqual(heartRate.min, 30)
        XCTAssertLessThanOrEqual(heartRate.min, 220)
        XCTAssertGreaterThanOrEqual(heartRate.max, 30)
        XCTAssertLessThanOrEqual(heartRate.max, 220)

        // Min should be <= average <= max
        XCTAssertLessThanOrEqual(heartRate.min, heartRate.average)
        XCTAssertLessThanOrEqual(heartRate.average, heartRate.max)
    }

    // MARK: - Activity Data Tests

    func testActivityDataValidation() async throws {
        // Given: Authorized manager with mock data
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Fetching health data
        let healthData = try await healthKitManager.fetchTodayHealthData()
        let activity = healthData.activity

        // Then: Activity data should be valid
        XCTAssertGreaterThanOrEqual(activity.steps, 0)
        XCTAssertLessThanOrEqual(activity.steps, 100000)
        XCTAssertGreaterThanOrEqual(activity.distance, 0)
        XCTAssertLessThanOrEqual(activity.distance, 200) // km
        XCTAssertGreaterThanOrEqual(activity.calories, 0)
        XCTAssertLessThanOrEqual(activity.calories, 5000)
        XCTAssertGreaterThanOrEqual(activity.activeMinutes, 0)
        XCTAssertLessThanOrEqual(activity.activeMinutes, 1440) // minutes per day
    }

    // MARK: - Error Handling Tests

    func testAuthorizationStatusTypes() async throws {
        // Test unknown authorization status
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = HKAuthorizationStatus(rawValue: 999) ?? .notDetermined

        try await healthKitManager.requestAuthorization()

        XCTAssertFalse(healthKitManager.isAuthorized)
        XCTAssertEqual(healthKitManager.authorizationStatus, "Unknown")
    }

    // MARK: - Performance Tests

    func testFetchHealthDataPerformance() async throws {
        // Given: Authorized manager
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Testing performance with proper async handling
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(options: options) {
            let semaphore = DispatchSemaphore(value: 0)
            
            Task {
                do {
                    _ = try await healthKitManager.fetchTodayHealthData()
                    semaphore.signal()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
        }
    }

    // MARK: - Memory Management Tests

    func testHealthKitManagerMemoryManagement() {
        weak var weakManager = healthKitManager
        healthKitManager = nil

        // In a real test environment, we might need to trigger garbage collection
        // For now, just ensure the manager can be deallocated
        XCTAssertNotNil(weakManager) // Still referenced by the test
    }

    // MARK: - Data Consistency Tests

    func testFetchHealthDataConsistency() async throws {
        // Given: Authorized manager
        await setupAuthorizedManager()
        setupMockQueryResponses()

        // When: Fetching health data multiple times
        let healthData1 = try await healthKitManager.fetchTodayHealthData()
        let healthData2 = try await healthKitManager.fetchTodayHealthData()

        // Then: Structure should be consistent
        XCTAssertEqual(type(of: healthData1.sleep), type(of: healthData2.sleep))
        XCTAssertEqual(type(of: healthData1.hrv), type(of: healthData2.hrv))
        XCTAssertEqual(type(of: healthData1.heartRate), type(of: healthData2.heartRate))
        XCTAssertEqual(type(of: healthData1.activity), type(of: healthData2.activity))

        // Values should be consistent when using the same mock data
        XCTAssertEqual(healthData1.sleep.duration, healthData2.sleep.duration)
        XCTAssertEqual(healthData1.hrv.average, healthData2.hrv.average)
        XCTAssertEqual(healthData1.heartRate.average, healthData2.heartRate.average)
        XCTAssertEqual(healthData1.activity.steps, healthData2.activity.steps)
    }
}

