import XCTest
@testable import TempoAI

final class HealthDataModelsTests: XCTestCase {

    // MARK: - Health Data Model Tests

    func testHealthDataModelCreation() {
        // Given: Valid health data components
        let sleepData = SleepData(duration: 7.5, deep: 1.2, rem: 1.8, light: 4.5, awake: 0.0, efficiency: 88)
        let hrvData = HRVData(average: 45.2, min: 38.1, max: 52.7)
        let heartRateData = HeartRateData(resting: 58, average: 72, min: 55, max: 85)
        let activityData = ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)

        // When: Creating health data model
        let healthData = HealthData(
            sleep: sleepData,
            hrv: hrvData,
            heartRate: heartRateData,
            activity: activityData
        )

        // Then: Should create valid health data
        XCTAssertEqual(healthData.sleep.duration, 7.5)
        XCTAssertEqual(healthData.hrv.average, 45.2)
        XCTAssertEqual(healthData.heartRate.resting, 58)
        XCTAssertEqual(healthData.activity.steps, 8234)
    }

    func testSleepDataValidation() {
        // Given: Sleep data with various values
        let sleepData = SleepData(duration: 8.0, deep: 1.5, rem: 2.0, light: 4.0, awake: 0.5, efficiency: 94)

        // Then: Should maintain all sleep components
        XCTAssertEqual(sleepData.duration, 8.0)
        XCTAssertEqual(sleepData.deep, 1.5)
        XCTAssertEqual(sleepData.rem, 2.0)
        XCTAssertEqual(sleepData.light, 4.0)
        XCTAssertEqual(sleepData.awake, 0.5)
        XCTAssertEqual(sleepData.efficiency, 94)

        // Validate reasonable ranges
        XCTAssertGreaterThanOrEqual(sleepData.duration, 0)
        XCTAssertGreaterThanOrEqual(sleepData.efficiency, 0)
        XCTAssertLessThanOrEqual(sleepData.efficiency, 100)
    }

    func testHRVDataValidation() {
        // Given: HRV data
        let hrvData = HRVData(average: 42.5, min: 35.0, max: 55.0)

        // Then: Should maintain HRV values
        XCTAssertEqual(hrvData.average, 42.5)
        XCTAssertEqual(hrvData.min, 35.0)
        XCTAssertEqual(hrvData.max, 55.0)

        // Validate relationships
        XCTAssertLessThanOrEqual(hrvData.min, hrvData.average)
        XCTAssertGreaterThanOrEqual(hrvData.max, hrvData.average)
    }

    func testHeartRateDataValidation() {
        // Given: Heart rate data
        let heartRateData = HeartRateData(resting: 60, average: 75, min: 58, max: 145)

        // Then: Should maintain heart rate values
        XCTAssertEqual(heartRateData.resting, 60)
        XCTAssertEqual(heartRateData.average, 75)
        XCTAssertEqual(heartRateData.min, 58)
        XCTAssertEqual(heartRateData.max, 145)

        // Validate reasonable ranges
        XCTAssertGreaterThan(heartRateData.resting, 0)
        XCTAssertGreaterThan(heartRateData.average, 0)
        XCTAssertLessThanOrEqual(heartRateData.min, heartRateData.average)
        XCTAssertGreaterThanOrEqual(heartRateData.max, heartRateData.average)
    }

    func testActivityDataValidation() {
        // Given: Activity data
        let activityData = ActivityData(steps: 10000, distance: 8.5, calories: 500, activeMinutes: 45)

        // Then: Should maintain activity values
        XCTAssertEqual(activityData.steps, 10000)
        XCTAssertEqual(activityData.distance, 8.5)
        XCTAssertEqual(activityData.calories, 500)
        XCTAssertEqual(activityData.activeMinutes, 45)

        // Validate reasonable ranges
        XCTAssertGreaterThanOrEqual(activityData.steps, 0)
        XCTAssertGreaterThanOrEqual(activityData.distance, 0)
        XCTAssertGreaterThanOrEqual(activityData.calories, 0)
        XCTAssertGreaterThanOrEqual(activityData.activeMinutes, 0)
    }
}
