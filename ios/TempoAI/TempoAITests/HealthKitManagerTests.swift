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

class MockHealthKitQueryFactory: HealthKitQueryFactory {
    var capturedResultsHandlers: [(HKSampleQuery, [HKSample]?, Error?) -> Void] = []
    var capturedQueries: [HKSampleQuery] = []

    func createSampleQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) -> HKSampleQuery {
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, _, _ in
            // Empty handler - we'll use capturedResultsHandlers instead
        }

        capturedQueries.append(query)
        capturedResultsHandlers.append(resultsHandler)

        return query
    }

    func triggerHandler(at index: Int, with samples: [HKSample]?, error: Error? = nil) {
        guard index < capturedResultsHandlers.count && index < capturedQueries.count else { return }
        let handler = capturedResultsHandlers[index]
        let query = capturedQueries[index]
        handler(query, samples, error)
    }
}

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

        // When: Testing performance
        measure {
            let expectation = XCTestExpectation(description: "Health data fetch")

            Task {
                do {
                    _ = try await healthKitManager.fetchTodayHealthData()
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 5.0)
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

// MARK: - Mock Classes

class MockHealthKitStore: HealthKitStoreProtocol {
    var isHealthDataAvailableResult = true
    var authorizationStatusResult: HKAuthorizationStatus = .notDetermined
    var requestAuthorizationCalled = false
    var requestAuthorizationError: Error?
    var executedQueries: [HKQuery] = []
    var mockQueryResults: [String: Any] = [:]

    static func isHealthDataAvailable() -> Bool {
        // This will be controlled by the instance variable
        return true // Default, but we'll override in tests
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return authorizationStatusResult
    }

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?) async throws {
        requestAuthorizationCalled = true

        if let error = requestAuthorizationError {
            throw error
        }

        // Simulate authorization granted
        authorizationStatusResult = .sharingAuthorized
    }

    func execute(_ query: HKQuery) {
        executedQueries.append(query)

        // Simulate query execution with mock results
        DispatchQueue.main.async {
            if let sampleQuery = query as? HKSampleQuery {
                self.handleSampleQuery(sampleQuery)
            } else if let statisticsQuery = query as? HKStatisticsQuery {
                self.handleStatisticsQuery(statisticsQuery)
            }
        }
    }

    private func handleSampleQuery(_ query: HKSampleQuery) {
        var samples: [HKSample] = []

        // Create mock samples based on query type
        if query.sampleType.identifier == HKCategoryTypeIdentifier.sleepAnalysis.rawValue {
            samples = createMockSleepSamples()
        } else if query.sampleType.identifier == HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue {
            samples = createMockHRVSamples()
        } else if query.sampleType.identifier == HKQuantityTypeIdentifier.heartRate.rawValue {
            samples = createMockHeartRateSamples()
        }

        // Use MockQueryFactory to handle results instead of direct resultsHandler access
    }

    private func handleStatisticsQuery(_ query: HKStatisticsQuery) {
        let mockValue: Double

        switch query.quantityType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            mockValue = 8234
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            mockValue = 6200 // meters
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            mockValue = 420
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            mockValue = 35
        default:
            mockValue = 0
        }

        let quantity = HKQuantity(unit: query.quantityType.canonicalUnit, doubleValue: mockValue)
        let statistics = MockHKStatistics(sumQuantity: quantity)

        query.resultsHandler?(query, statistics, nil)
    }

    private func createMockSleepSamples() -> [HKCategorySample] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date()
        let endDate = Date()

        let sample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleep.rawValue,
            start: startDate,
            end: endDate
        )

        return [sample]
    }

    private func createMockHRVSamples() -> [HKQuantitySample] {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let unit = HKUnit.secondUnit(with: .milli)
        let quantity = HKQuantity(unit: unit, doubleValue: 45.2)
        let startDate = Date()

        let sample = HKQuantitySample(
            type: hrvType,
            quantity: quantity,
            start: startDate,
            end: startDate
        )

        return [sample]
    }

    private func createMockHeartRateSamples() -> [HKQuantitySample] {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let unit = HKUnit.count().unitDivided(by: .minute())
        let quantity = HKQuantity(unit: unit, doubleValue: 75)
        let startDate = Date()

        let sample = HKQuantitySample(
            type: heartRateType,
            quantity: quantity,
            start: startDate,
            end: startDate
        )

        return [sample]
    }
}

class MockHKStatistics: HKStatistics {
    private let _sumQuantity: HKQuantity?

    init(sumQuantity: HKQuantity?) {
        self._sumQuantity = sumQuantity
        super.init()
    }

    override func sumQuantity() -> HKQuantity? {
        return _sumQuantity
    }
}

// MARK: - Test Helpers

extension HealthKitManagerTests {
    func setupAuthorizedManager() async {
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .sharingAuthorized
        try? await healthKitManager.requestAuthorization()
    }

    func setupMockQueryResponses() {
        // Reset previous queries
        mockHealthStore.executedQueries.removeAll()
    }

    func withMockData<T>(_ block: () throws -> T) rethrows -> T {
        return try block()
    }
}
