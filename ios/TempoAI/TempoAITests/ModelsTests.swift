import XCTest
@testable import TempoAI

final class ModelsTests: XCTestCase {

    // MARK: - API Request Model Tests

    func testAnalysisRequestCreation() {
        // Given: Valid components
        let healthData = APIClientTestData.createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = APIClientTestData.createMockUserProfile()

        // When: Creating analysis request
        let request = AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )

        // Then: Should create valid request
        XCTAssertEqual(request.healthData.sleep.duration, healthData.sleep.duration)
        XCTAssertEqual(request.location.latitude, location.latitude)
        XCTAssertEqual(request.userProfile.age, userProfile.age)
    }
}
