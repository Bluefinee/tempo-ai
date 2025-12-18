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
        defer { NotificationCenter.default.removeObserver(observer) }

        service.performLightReset()

        // Yield to allow main queue to process
        await Task.yield()

        #expect(notificationReceived)
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
        defer { NotificationCenter.default.removeObserver(observer) }

        service.performCompleteReset()

        // Yield to allow main queue to process
        await Task.yield()

        #expect(notificationReceived)
    }
}
#endif
