import Foundation
@testable import TempoAI

/// Mock implementation of APIClientProtocol for testing
@MainActor
final class MockAPIClient: APIClientProtocol {

    // MARK: - Call Tracking

    var generateAdviceCalls: [AdviceRequest] = []
    var healthCheckCallCount: Int = 0

    // MARK: - Stubbed Return Values

    var stubbedAdvice: DailyAdvice?
    var stubbedHealthCheckResult: Bool = true

    // MARK: - Error Simulation

    var shouldThrowOnGenerateAdvice: Bool = false
    var errorToThrow: APIError = .networkError("Mock network error")

    // MARK: - APIClientProtocol

    func generateAdvice(request: AdviceRequest) async throws -> DailyAdvice {
        generateAdviceCalls.append(request)

        if shouldThrowOnGenerateAdvice {
            throw errorToThrow
        }

        if let advice = stubbedAdvice {
            return advice
        }

        return createMockAdvice()
    }

    func healthCheck() async -> Bool {
        healthCheckCallCount += 1
        return stubbedHealthCheckResult
    }

    // MARK: - Helper Methods

    /// Reset all tracked calls and state
    func reset() {
        generateAdviceCalls.removeAll()
        healthCheckCallCount = 0
        stubbedAdvice = nil
        stubbedHealthCheckResult = true
        shouldThrowOnGenerateAdvice = false
    }

    /// Create mock advice for testing
    private func createMockAdvice() -> DailyAdvice {
        DailyAdvice.createMock(timeSlot: .morning)
    }

    // MARK: - Factory Methods for Common Test Scenarios

    /// Create a mock that returns healthy status
    static func healthy() -> MockAPIClient {
        let mock = MockAPIClient()
        mock.stubbedHealthCheckResult = true
        return mock
    }

    /// Create a mock that returns unhealthy status
    static func unhealthy() -> MockAPIClient {
        let mock = MockAPIClient()
        mock.stubbedHealthCheckResult = false
        return mock
    }

    /// Create a mock that throws network error
    static func networkError() -> MockAPIClient {
        let mock = MockAPIClient()
        mock.shouldThrowOnGenerateAdvice = true
        mock.errorToThrow = .networkError("Network unavailable")
        return mock
    }

    /// Create a mock that throws unauthorized error
    static func unauthorized() -> MockAPIClient {
        let mock = MockAPIClient()
        mock.shouldThrowOnGenerateAdvice = true
        mock.errorToThrow = .unauthorized
        return mock
    }

    /// Create a mock that throws server error
    static func serverError() -> MockAPIClient {
        let mock = MockAPIClient()
        mock.shouldThrowOnGenerateAdvice = true
        mock.errorToThrow = .serverError("Internal server error")
        return mock
    }
}
