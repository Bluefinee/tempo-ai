import XCTest
@testable import TempoAI

final class JSONSerializationTests: XCTestCase {

    // MARK: - JSON Serialization Tests

    func testHealthDataJSONSerialization() throws {
        // Given: Health data model
        let healthData = APIClientTestData.createMockHealthData()

        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(healthData)

        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)

        // And: Should decode back to the same data
        let decodedHealthData = try JSONDecoder().decode(HealthData.self, from: jsonData)
        XCTAssertEqual(decodedHealthData.sleep.duration, healthData.sleep.duration)
        XCTAssertEqual(decodedHealthData.hrv.average, healthData.hrv.average)
    }

    func testLocationDataJSONSerialization() throws {
        // Given: Location data
        let locationData = LocationData(latitude: 35.6895, longitude: 139.6917)

        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(locationData)

        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)

        // And: Should decode back correctly
        let decodedLocation = try JSONDecoder().decode(LocationData.self, from: jsonData)
        XCTAssertEqual(decodedLocation.latitude, locationData.latitude)
        XCTAssertEqual(decodedLocation.longitude, locationData.longitude)
    }

    func testDailyAdviceJSONSerialization() throws {
        // Given: Daily advice model
        let dailyAdvice = APIClientTestData.createMockDailyAdvice()

        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(dailyAdvice)

        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)

        // And: Should decode back correctly (but with new UUID)
        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: jsonData)
        XCTAssertEqual(decodedAdvice.theme, dailyAdvice.theme)
        XCTAssertEqual(decodedAdvice.summary, dailyAdvice.summary)
        // Note: UUID will be different after decoding since it's generated
    }

    func testAnalysisRequestJSONSerialization() throws {
        // Given: Analysis request
        let request = AnalysisRequest(
            healthData: APIClientTestData.createMockHealthData(),
            location: LocationData(latitude: 35.6895, longitude: 139.6917),
            userProfile: APIClientTestData.createMockUserProfile()
        )

        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(request)

        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)

        // And: Should decode back correctly
        let decodedRequest = try JSONDecoder().decode(AnalysisRequest.self, from: jsonData)
        XCTAssertEqual(decodedRequest.healthData.sleep.duration, request.healthData.sleep.duration)
        XCTAssertEqual(decodedRequest.location.latitude, request.location.latitude)
        XCTAssertEqual(decodedRequest.userProfile.age, request.userProfile.age)
    }
}
