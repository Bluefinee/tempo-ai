import XCTest
@testable import TempoAI

final class LocationProfileTests: XCTestCase {

    // MARK: - Location & User Profile Tests

    func testLocationDataCreation() {
        // Given: Valid coordinates
        let latitude = 35.6895
        let longitude = 139.6917

        // When: Creating location data
        let locationData = LocationData(latitude: latitude, longitude: longitude)

        // Then: Should create valid location
        XCTAssertEqual(locationData.latitude, latitude)
        XCTAssertEqual(locationData.longitude, longitude)

        // Validate coordinate ranges
        XCTAssertGreaterThanOrEqual(locationData.latitude, -90.0)
        XCTAssertLessThanOrEqual(locationData.latitude, 90.0)
        XCTAssertGreaterThanOrEqual(locationData.longitude, -180.0)
        XCTAssertLessThanOrEqual(locationData.longitude, 180.0)
    }

    func testUserProfileCreation() {
        // Given: Valid user profile data
        let userProfile = UserProfile(
            age: 30,
            gender: "male",
            goals: ["疲労回復", "集中力向上"],
            dietaryPreferences: "バランス重視",
            exerciseHabits: "週3回ジム",
            exerciseFrequency: "3回/週"
        )

        // Then: Should create valid user profile
        XCTAssertEqual(userProfile.age, 30)
        XCTAssertEqual(userProfile.gender, "male")
        XCTAssertEqual(userProfile.goals.count, 2)
        XCTAssertEqual(userProfile.goals[0], "疲労回復")
        XCTAssertEqual(userProfile.dietaryPreferences, "バランス重視")
        XCTAssertEqual(userProfile.exerciseHabits, "週3回ジム")
        XCTAssertEqual(userProfile.exerciseFrequency, "3回/週")

        // Validate reasonable ranges
        XCTAssertGreaterThan(userProfile.age, 0)
        XCTAssertLessThan(userProfile.age, 150) // Reasonable age limit
    }
}
