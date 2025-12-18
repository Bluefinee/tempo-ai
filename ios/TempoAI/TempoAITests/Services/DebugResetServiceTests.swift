import Foundation
import Testing

@testable import TempoAI

#if DEBUG
@MainActor
struct DebugResetServiceTests {

    // MARK: - performLightReset Tests

    @Test("Light reset deletes user profile")
    func lightResetDeletesUserProfile() async {
        let mockCache = MockCacheManager()
        mockCache.storedProfile = UserProfile.sampleData

        let service = DebugResetService(cacheManager: mockCache)
        service.performLightReset()

        #expect(mockCache.deleteUserProfileCallCount == 1)
    }

    @Test("Light reset resets onboarding state")
    func lightResetResetsOnboardingState() async {
        let mockCache = MockCacheManager()
        mockCache.onboardingCompleted = true

        let service = DebugResetService(cacheManager: mockCache)
        service.performLightReset()

        #expect(mockCache.resetOnboardingStateCallCount == 1)
    }

    @Test("Light reset posts notification")
    func lightResetPostsNotification() async {
        let mockCache = MockCacheManager()
        let service = DebugResetService(cacheManager: mockCache)

        var notificationReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: .onboardingReset,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }

        service.performLightReset()

        // Give notification time to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived)

        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - performCompleteReset Tests

    @Test("Complete reset deletes user profile")
    func completeResetDeletesUserProfile() async {
        let mockCache = MockCacheManager()
        mockCache.storedProfile = UserProfile.sampleData

        let service = DebugResetService(cacheManager: mockCache)
        service.performCompleteReset()

        #expect(mockCache.deleteUserProfileCallCount == 1)
    }

    @Test("Complete reset resets onboarding state")
    func completeResetResetsOnboardingState() async {
        let mockCache = MockCacheManager()
        mockCache.onboardingCompleted = true

        let service = DebugResetService(cacheManager: mockCache)
        service.performCompleteReset()

        #expect(mockCache.resetOnboardingStateCallCount == 1)
    }

    @Test("Complete reset posts notification")
    func completeResetPostsNotification() async {
        let mockCache = MockCacheManager()
        let service = DebugResetService(cacheManager: mockCache)

        var notificationReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: .onboardingReset,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }

        service.performCompleteReset()

        // Give notification time to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived)

        NotificationCenter.default.removeObserver(observer)
    }
}
#endif
