import XCTest
@testable import TempoAI

/// Comprehensive test suite for HealthStatusAnalyzer functionality.
///
/// Tests cover individual metric analysis, overall health status determination,
/// data quality assessment, and edge cases. Follows TDD principles with
/// thorough coverage of the health analysis engine.
@MainActor
final class HealthStatusAnalyzerTests: XCTestCase {

    var analyzer: HealthStatusAnalyzer!

    override func setUp() async throws {
        try await super.setUp()

        // Initialize analyzer with standard test profile
        analyzer = HealthStatusAnalyzer(
            userAge: 30,
            userGender: "male",
            activityLevel: .moderatelyActive
        )
    }

    override func tearDown() async throws {
        analyzer = nil
        try await super.tearDown()
    }

    // MARK: - Health Status Classification Tests

    func testOptimalHealthStatus() async {
        let healthData = createOptimalHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.status, .optimal, "Should classify excellent health metrics as optimal")
        XCTAssertGreaterThan(analysis.overallScore, 0.8, "Optimal health should have high overall score")
        XCTAssertGreaterThan(analysis.confidence, 0.7, "Should have high confidence with complete data")
    }

    func testGoodHealthStatus() async {
        let healthData = createGoodHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.status, .good, "Should classify good health metrics as good")
        XCTAssertTrue(analysis.overallScore >= 0.6 && analysis.overallScore < 0.8, "Good health should have moderate score")
    }

    func testCareHealthStatus() async {
        let healthData = createCareHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.status, .care, "Should classify concerning metrics as care mode")
        XCTAssertTrue(analysis.overallScore >= 0.4 && analysis.overallScore < 0.6, "Care mode should have lower score")
    }

    func testRestHealthStatus() async {
        let healthData = createRestHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.status, .rest, "Should classify poor metrics as rest mode")
        XCTAssertLessThan(analysis.overallScore, 0.4, "Rest mode should have low overall score")
    }

    func testUnknownHealthStatus() async {
        let healthData = createEmptyHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.status, .unknown, "Should return unknown status for insufficient data")
        XCTAssertEqual(analysis.dataQuality, .poor, "Should indicate poor data quality")
    }

    // MARK: - Individual Metric Analysis Tests

    func testHRVAnalysisOptimal() async {
        let healthData = HealthKitData(
            hrv: HRVData(average: 55.0), // Excellent for 30-year-old
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.hrvScore)
        XCTAssertGreaterThan(analysis.hrvScore!, 0.8, "High HRV should result in high score")
    }

    func testHRVAnalysisPoor() async {
        let healthData = HealthKitData(
            hrv: HRVData(average: 20.0), // Poor for 30-year-old
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.hrvScore)
        XCTAssertLessThan(analysis.hrvScore!, 0.6, "Low HRV should result in low score")
    }

    func testSleepAnalysisOptimal() async {
        let healthData = HealthKitData(
            sleep: SleepData(
                duration: 8.0,
                deep: 2.0,
                rem: 1.6,
                light: 4.0,
                awake: 0.4,
                efficiency: 0.9
            ),
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.sleepScore)
        XCTAssertGreaterThan(analysis.sleepScore!, 0.8, "Optimal sleep should result in high score")
    }

    func testSleepAnalysisPoor() async {
        let healthData = HealthKitData(
            sleep: SleepData(
                duration: 4.5,
                deep: 0.5,
                rem: 0.8,
                light: 3.0,
                awake: 0.2,
                efficiency: 0.6
            ),
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.sleepScore)
        XCTAssertLessThan(analysis.sleepScore!, 0.6, "Poor sleep should result in low score")
    }

    func testActivityAnalysisOptimal() async {
        let healthData = HealthKitData(
            activity: ActivityData(
                steps: 12000,
                calories: 500,
                activeMinutes: 35
            ),
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.activityScore)
        XCTAssertGreaterThan(analysis.activityScore!, 0.8, "High activity should result in high score")
    }

    func testHeartRateAnalysis() async {
        let healthData = HealthKitData(
            heartRate: HeartRateData(
                resting: 60.0,
                average: 75.0
            ),
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.heartRateScore)
        XCTAssertGreaterThan(analysis.heartRateScore!, 0.7, "Good heart rate metrics should result in good score")
    }

    // MARK: - Data Quality Assessment Tests

    func testDataQualityExcellent() async {
        let healthData = createCompleteHealthData()

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.dataQuality, .excellent, "Complete data should be rated as excellent quality")
    }

    func testDataQualityGood() async {
        let healthData = HealthKitData(
            sleep: SleepData(duration: 7.5, efficiency: 0.85),
            hrv: HRVData(average: 45.0),
            heartRate: HeartRateData(resting: 65.0),
            // Missing activity data
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.dataQuality, .good, "Mostly complete data should be rated as good quality")
    }

    func testDataQualityFair() async {
        let healthData = HealthKitData(
            sleep: SleepData(duration: 7.0, efficiency: 0.8),
            hrv: HRVData(average: 40.0),
            // Missing heart rate and activity data
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.dataQuality, .fair, "Partial data should be rated as fair quality")
    }

    func testDataQualityPoor() async {
        let healthData = HealthKitData(
            sleep: SleepData(duration: 6.0, efficiency: 0.7),
            // Missing most data
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        XCTAssertEqual(analysis.dataQuality, .poor, "Minimal data should be rated as poor quality")
    }

    // MARK: - Age and Gender Adjustment Tests

    func testAgeAdjustmentForOlderUser() async {
        let olderAnalyzer = HealthStatusAnalyzer(
            userAge: 55,
            userGender: "female",
            activityLevel: .moderatelyActive
        )

        let healthData = HealthKitData(
            hrv: HRVData(average: 30.0), // Lower HRV, but appropriate for age 55
            timestamp: Date()
        )

        let analysis = await olderAnalyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.hrvScore)
        XCTAssertGreaterThan(analysis.hrvScore!, 0.7, "Age-adjusted HRV should be scored appropriately")
    }

    func testActivityLevelAdjustment() async {
        let activeAnalyzer = HealthStatusAnalyzer(
            userAge: 25,
            userGender: "male",
            activityLevel: .veryActive
        )

        let healthData = HealthKitData(
            activity: ActivityData(
                steps: 15000,
                calories: 600,
                activeMinutes: 60
            ),
            timestamp: Date()
        )

        let analysis = await activeAnalyzer.analyzeHealthStatus(from: healthData)

        XCTAssertNotNil(analysis.activityScore)
        XCTAssertGreaterThan(analysis.activityScore!, 0.8, "Very active user should get good activity score")
    }

    // MARK: - Edge Cases and Error Handling Tests

    func testInvalidHealthData() async {
        let healthData = HealthKitData(
            hrv: HRVData(average: -10.0), // Invalid negative HRV
            sleep: SleepData(duration: -2.0, efficiency: 1.5), // Invalid values
            timestamp: Date()
        )

        let analysis = await analyzer.analyzeHealthStatus(from: healthData)

        // Should handle invalid data gracefully
        XCTAssertNotNil(analysis)
        XCTAssertNotEqual(analysis.status, .optimal, "Invalid data should not result in optimal status")
    }

    func testAnalysisConsistency() async {
        let healthData = createOptimalHealthData()

        // Run analysis multiple times
        let analysis1 = await analyzer.analyzeHealthStatus(from: healthData)
        let analysis2 = await analyzer.analyzeHealthStatus(from: healthData)

        // Results should be consistent
        XCTAssertEqual(analysis1.status, analysis2.status, "Analysis should be consistent for same data")
        XCTAssertEqual(analysis1.overallScore, analysis2.overallScore, accuracy: 0.001, "Scores should be identical")
    }

    // MARK: - Performance Tests

    func testAnalysisPerformance() async {
        let healthData = createCompleteHealthData()

        let startTime = Date()
        let analysis = await analyzer.analyzeHealthStatus(from: healthData)
        let endTime = Date()

        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 1.0, "Analysis should complete within 1 second")
        XCTAssertNotNil(analysis, "Analysis should succeed within time limit")
    }

    // MARK: - Helper Methods for Test Data Creation

    private func createOptimalHealthData() -> HealthKitData {
        return HealthKitData(
            sleep: SleepData(
                duration: 8.0,
                deep: 2.0,
                rem: 1.8,
                light: 4.0,
                awake: 0.2,
                efficiency: 0.95
            ),
            hrv: HRVData(average: 55.0),
            heartRate: HeartRateData(
                resting: 55.0,
                average: 75.0
            ),
            activity: ActivityData(
                steps: 12000,
                calories: 500,
                activeMinutes: 40
            ),
            timestamp: Date()
        )
    }

    private func createGoodHealthData() -> HealthKitData {
        return HealthKitData(
            sleep: SleepData(
                duration: 7.0,
                deep: 1.5,
                rem: 1.4,
                light: 3.8,
                awake: 0.3,
                efficiency: 0.8
            ),
            hrv: HRVData(average: 40.0),
            heartRate: HeartRateData(
                resting: 65.0,
                average: 80.0
            ),
            activity: ActivityData(
                steps: 9000,
                calories: 350,
                activeMinutes: 25
            ),
            timestamp: Date()
        )
    }

    private func createCareHealthData() -> HealthKitData {
        return HealthKitData(
            sleep: SleepData(
                duration: 6.0,
                deep: 0.8,
                rem: 1.0,
                light: 3.5,
                awake: 0.7,
                efficiency: 0.7
            ),
            hrv: HRVData(average: 25.0),
            heartRate: HeartRateData(
                resting: 75.0,
                average: 90.0
            ),
            activity: ActivityData(
                steps: 5000,
                calories: 200,
                activeMinutes: 10
            ),
            timestamp: Date()
        )
    }

    private func createRestHealthData() -> HealthKitData {
        return HealthKitData(
            sleep: SleepData(
                duration: 4.5,
                deep: 0.5,
                rem: 0.7,
                light: 2.8,
                awake: 0.5,
                efficiency: 0.6
            ),
            hrv: HRVData(average: 15.0),
            heartRate: HeartRateData(
                resting: 85.0,
                average: 100.0
            ),
            activity: ActivityData(
                steps: 2000,
                calories: 100,
                activeMinutes: 5
            ),
            timestamp: Date()
        )
    }

    private func createEmptyHealthData() -> HealthKitData {
        return HealthKitData(timestamp: Date())
    }

    private func createCompleteHealthData() -> HealthKitData {
        return HealthKitData(
            sleep: SleepData(
                duration: 7.5,
                deep: 1.8,
                rem: 1.5,
                light: 4.0,
                awake: 0.2,
                efficiency: 0.85
            ),
            hrv: HRVData(average: 45.0, min: 25.0, max: 65.0),
            heartRate: HeartRateData(
                resting: 60.0,
                average: 78.0,
                min: 55.0,
                max: 150.0
            ),
            activity: ActivityData(
                steps: 10000,
                distance: 8.0,
                calories: 400,
                activeMinutes: 30
            ),
            timestamp: Date()
        )
    }
}

// MARK: - HealthStatus Enum Tests

final class HealthStatusTests: XCTestCase {

    func testHealthStatusFromScore() {
        XCTAssertEqual(HealthStatus.from(overallScore: 0.9), .optimal)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.8), .optimal)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.7), .good)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.6), .good)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.5), .care)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.4), .care)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.3), .rest)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.1), .rest)
        XCTAssertEqual(HealthStatus.from(overallScore: 0.0), .unknown)
    }

    func testHealthStatusColors() {
        XCTAssertEqual(HealthStatus.optimal.color, .green)
        XCTAssertEqual(HealthStatus.good.color, .yellow)
        XCTAssertEqual(HealthStatus.care.color, .orange)
        XCTAssertEqual(HealthStatus.rest.color, .red)
        XCTAssertEqual(HealthStatus.unknown.color, .gray)
    }

    func testHealthStatusScores() {
        XCTAssertEqual(HealthStatus.optimal.score, 1.0)
        XCTAssertEqual(HealthStatus.good.score, 0.75)
        XCTAssertEqual(HealthStatus.care.score, 0.5)
        XCTAssertEqual(HealthStatus.rest.score, 0.25)
        XCTAssertEqual(HealthStatus.unknown.score, 0.0)
    }

    func testHealthStatusPriority() {
        XCTAssertEqual(HealthStatus.optimal.priority, .low)
        XCTAssertEqual(HealthStatus.good.priority, .low)
        XCTAssertEqual(HealthStatus.care.priority, .medium)
        XCTAssertEqual(HealthStatus.rest.priority, .high)
        XCTAssertEqual(HealthStatus.unknown.priority, .none)
    }

    func testHealthStatusFromIndividualScores() {
        // Test optimal combination
        let optimal = HealthStatus.from(
            hrvScore: 0.9,
            sleepScore: 0.9,
            activityScore: 0.8,
            heartRateScore: 0.85
        )
        XCTAssertEqual(optimal, .optimal)

        // Test care combination
        let care = HealthStatus.from(
            hrvScore: 0.4,
            sleepScore: 0.5,
            activityScore: 0.5,
            heartRateScore: 0.6
        )
        XCTAssertEqual(care, .care)
    }
}
