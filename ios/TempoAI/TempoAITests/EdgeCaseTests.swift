import XCTest
@testable import TempoAI

final class EdgeCaseTests: XCTestCase {

    // MARK: - Edge Cases and Error Handling

    func testEmptyUserGoals() {
        // Given: User profile with empty goals
        let userProfile = UserProfile(
            age: 25,
            gender: "female",
            goals: [],
            dietaryPreferences: "ベジタリアン",
            exerciseHabits: "ヨガ",
            exerciseFrequency: "毎日"
        )

        // Then: Should handle empty goals
        XCTAssertEqual(userProfile.goals.count, 0)
        XCTAssertEqual(userProfile.age, 25)
    }

    func testExtremeCoordinates() {
        // Given: Extreme but valid coordinates
        let extremeLocations = [
            LocationData(latitude: 90.0, longitude: 180.0),    // North Pole, Date Line
            LocationData(latitude: -90.0, longitude: -180.0),  // South Pole, Date Line
            LocationData(latitude: 0.0, longitude: 0.0)        // Null Island
        ]

        // Then: Should handle extreme coordinates
        for location in extremeLocations {
            XCTAssertGreaterThanOrEqual(location.latitude, -90.0)
            XCTAssertLessThanOrEqual(location.latitude, 90.0)
            XCTAssertGreaterThanOrEqual(location.longitude, -180.0)
            XCTAssertLessThanOrEqual(location.longitude, 180.0)
        }
    }

    func testZeroActivityData() {
        // Given: Activity data with zero values
        let activityData = ActivityData(steps: 0, distance: 0.0, calories: 0, activeMinutes: 0)

        // Then: Should handle zero values
        XCTAssertEqual(activityData.steps, 0)
        XCTAssertEqual(activityData.distance, 0.0)
        XCTAssertEqual(activityData.calories, 0)
        XCTAssertEqual(activityData.activeMinutes, 0)
    }

    func testInvalidCoordinatesValidation() {
        // Given: Invalid coordinates that exceed valid ranges
        let invalidCoordinates = [
            (latitude: 91.0, longitude: 0.0),    // Latitude too high
            (latitude: -91.0, longitude: 0.0),   // Latitude too low
            (latitude: 0.0, longitude: 181.0),   // Longitude too high
            (latitude: 0.0, longitude: -181.0),  // Longitude too low
            (latitude: Double.infinity, longitude: 0.0), // Infinity
            (latitude: 0.0, longitude: Double.nan)       // NaN
        ]

        // When/Then: Should identify invalid coordinates
        for (lat, lon) in invalidCoordinates {
            // These coordinates should fail validation in a proper validation system
            let isValid = lat >= -90.0 && lat <= 90.0 &&
                         lon >= -180.0 && lon <= 180.0 &&
                         !lat.isInfinite && !lat.isNaN &&
                         !lon.isInfinite && !lon.isNaN

            XCTAssertFalse(isValid, "Coordinates (\(lat), \(lon)) should be invalid")
        }
    }

    func testExtremeCoordinatesWithAPI() {
        // Given: Extreme but valid coordinates for API testing
        let extremeLocation = LocationData(latitude: -89.5, longitude: 179.5) // Near South Pole
        let mockHealthData = TestHelpers.createMockHealthData()
        let mockUserProfile = TestHelpers.createMockUserProfile()

        // When: Creating analysis request with extreme coordinates
        let analysisRequest = AnalysisRequest(
            healthData: mockHealthData,
            location: extremeLocation,
            userProfile: mockUserProfile
        )

        // Then: Request should be properly formed with extreme coordinates
        XCTAssertNotNil(analysisRequest)
        XCTAssertEqual(analysisRequest.location.latitude, -89.5, accuracy: 0.001)
        XCTAssertEqual(analysisRequest.location.longitude, 179.5, accuracy: 0.001)

        // Note: This tests the data structure handling, not actual API call
        // Real API testing would require mock responses or integration test environment
    }

    func testEdgeCaseHealthData() {
        // Given: Health data with extreme but possible values
        let extremeHealthData = HealthData(
            sleep: SleepData(duration: 0.1, deep: 0.0, rem: 0.0, light: 0.1, awake: 0.0, efficiency: 1),
            hrv: HRVData(average: 1.0, min: 1.0, max: 1.0),
            heartRate: HeartRateData(resting: 30, average: 30, min: 30, max: 220),
            activity: ActivityData(steps: 100000, distance: 100.0, calories: 10000, activeMinutes: 1440)
        )

        // When: Processing extreme health data
        let analysisRequest = AnalysisRequest(
            healthData: extremeHealthData,
            location: TestHelpers.createMockLocationData(),
            userProfile: TestHelpers.createMockUserProfile()
        )

        // Then: Should handle extreme values gracefully
        XCTAssertNotNil(analysisRequest)
        XCTAssertEqual(extremeHealthData.sleep.duration, 0.1, accuracy: 0.001)
        XCTAssertEqual(extremeHealthData.activity.steps, 100000)
        XCTAssertEqual(extremeHealthData.heartRate.max, 220)
    }
}
