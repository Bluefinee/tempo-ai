import Foundation
@testable import TempoAI

// MARK: - Test Data Helpers

/// Utility functions for creating mock data in tests
enum TestHelpers {

}

// MARK: - Extensions for Test Classes

/// Extension to provide helper methods for test classes that need access to mock data
extension TestHelpers {

    /// Creates a mock LocationData instance for testing
    static func createMockLocationData() -> LocationData {
        return LocationData(latitude: 35.6895, longitude: 139.6917) // Tokyo coordinates
    }

    /// Creates a mock AnalysisRequest instance for testing
    static func createMockAnalysisRequest() -> AnalysisRequest {
        return AnalysisRequest(
            healthData: APIClientTestData.createMockHealthData(),
            location: createMockLocationData(),
            userProfile: APIClientTestData.createMockUserProfile()
        )
    }

    /// Creates a mock APIResponse with success status for testing
    static func createMockSuccessAPIResponse() -> APIResponse<DailyAdvice> {
        return APIResponse(success: true, data: APIClientTestData.createMockDailyAdvice(), error: nil)
    }

    /// Creates a mock APIResponse with error status for testing
    static func createMockErrorAPIResponse() -> APIResponse<DailyAdvice> {
        return APIResponse(success: false, data: nil, error: "Test error message")
    }
}
