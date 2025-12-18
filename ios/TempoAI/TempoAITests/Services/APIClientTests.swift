import Foundation
import Testing

@testable import TempoAI

@MainActor
struct APIClientTests {

    // MARK: - Mock API Client Tests

    @Test("Healthy mock client returns true for health check")
    func healthyMockHealthCheck() async {
        let client = MockAPIClient.healthy()

        let result = await client.healthCheck()

        #expect(result == true)
        #expect(client.healthCheckCallCount == 1)
    }

    @Test("Unhealthy mock client returns false for health check")
    func unhealthyMockHealthCheck() async {
        let client = MockAPIClient.unhealthy()

        let result = await client.healthCheck()

        #expect(result == false)
        #expect(client.healthCheckCallCount == 1)
    }

    @Test("Mock client generates advice successfully")
    func mockGenerateAdviceSuccess() async throws {
        let client = MockAPIClient()
        let request = createMockAdviceRequest()

        let advice = try await client.generateAdvice(request: request)

        #expect(!advice.greeting.isEmpty)
        #expect(client.generateAdviceCalls.count == 1)
        #expect(client.generateAdviceCalls[0].userProfile.nickname == request.userProfile.nickname)
    }

    @Test("Mock client with stubbed advice returns custom advice")
    func mockGenerateAdviceWithStub() async throws {
        let client = MockAPIClient()
        let customAdvice = DailyAdvice.createMock(timeSlot: .evening)
        client.stubbedAdvice = customAdvice

        let request = createMockAdviceRequest()
        let advice = try await client.generateAdvice(request: request)

        #expect(advice.timeSlot == .evening)
    }

    @Test("Network error mock throws network error")
    func mockNetworkError() async {
        let client = MockAPIClient.networkError()
        let request = createMockAdviceRequest()

        do {
            _ = try await client.generateAdvice(request: request)
            Issue.record("Expected network error to be thrown")
        } catch let error as APIError {
            if case .networkError = error {
                // Expected
            } else {
                Issue.record("Expected networkError but got \(error)")
            }
        } catch {
            Issue.record("Expected APIError but got \(error)")
        }
    }

    @Test("Unauthorized mock throws unauthorized error")
    func mockUnauthorizedError() async {
        let client = MockAPIClient.unauthorized()
        let request = createMockAdviceRequest()

        do {
            _ = try await client.generateAdvice(request: request)
            Issue.record("Expected unauthorized error to be thrown")
        } catch let error as APIError {
            if case .unauthorized = error {
                // Expected
            } else {
                Issue.record("Expected unauthorized but got \(error)")
            }
        } catch {
            Issue.record("Expected APIError but got \(error)")
        }
    }

    @Test("Server error mock throws server error")
    func mockServerError() async {
        let client = MockAPIClient.serverError()
        let request = createMockAdviceRequest()

        do {
            _ = try await client.generateAdvice(request: request)
            Issue.record("Expected server error to be thrown")
        } catch let error as APIError {
            if case .serverError = error {
                // Expected
            } else {
                Issue.record("Expected serverError but got \(error)")
            }
        } catch {
            Issue.record("Expected APIError but got \(error)")
        }
    }

    @Test("Mock client reset clears all state")
    func mockClientReset() async {
        let client = MockAPIClient()
        client.stubbedHealthCheckResult = false
        client.shouldThrowOnGenerateAdvice = true
        _ = await client.healthCheck()

        client.reset()

        #expect(client.healthCheckCallCount == 0)
        #expect(client.generateAdviceCalls.isEmpty)
        #expect(client.stubbedHealthCheckResult == true)
        #expect(client.shouldThrowOnGenerateAdvice == false)
    }

    // MARK: - API Error Tests

    @Test("APIError provides localized description")
    func apiErrorLocalizedDescription() {
        let networkError = APIError.networkError("Connection failed")
        let unauthorizedError = APIError.unauthorized
        let serverError = APIError.serverError("Internal error")

        #expect(networkError.errorDescription?.contains("ネットワーク") == true)
        #expect(unauthorizedError.errorDescription?.contains("認証") == true)
        #expect(serverError.errorDescription?.contains("サーバー") == true)
    }

    @Test("APIError provides recovery suggestion where applicable")
    func apiErrorRecoverySuggestion() {
        let networkError = APIError.networkError("Connection failed")
        let rateLimitError = APIError.rateLimitExceeded

        #expect(networkError.recoverySuggestion != nil)
        #expect(rateLimitError.recoverySuggestion != nil)
    }

    // MARK: - Helper

    private func createMockAdviceRequest() -> AdviceRequest {
        AdviceRequest(
            userProfile: UserProfile.sampleData,
            healthData: HealthData(
                sleepData: SleepData(
                    totalSleepMinutes: 420,
                    deepSleepMinutes: 90,
                    remSleepMinutes: 100,
                    sleepEfficiency: 0.85,
                    sleepStartTime: Date().addingTimeInterval(-8 * 3600),
                    sleepEndTime: Date()
                ),
                vitalData: VitalData(
                    restingHeartRate: 62,
                    heartRateVariability: 45,
                    oxygenSaturation: 98,
                    respiratoryRate: 14
                ),
                activityData: ActivityData(
                    stepCount: 8500,
                    activeEnergyBurned: 450,
                    exerciseMinutes: 35,
                    standHours: 10
                )
            ),
            location: LocationData(
                latitude: 35.6762,
                longitude: 139.6503,
                city: "Tokyo",
                country: "Japan"
            ),
            requestContext: RequestContext(
                isWeekday: true,
                dayOfWeek: "Monday"
            )
        )
    }
}
