import Foundation
import Testing

@testable import TempoAI

@MainActor
struct CacheManagerTests {

    // MARK: - Helper

    /// Cleans up test data to avoid test pollution
    private func cleanupTestData() {
        let cacheManager = CacheManager.shared
        cacheManager.deleteUserProfile()
        cacheManager.resetOnboardingState()
    }

    // MARK: - User Profile Tests

    @Test("Save and load user profile round-trip")
    func saveAndLoadUserProfile() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let profile = UserProfile.sampleData

        try cacheManager.saveUserProfile(profile)
        let loaded = try cacheManager.loadUserProfile()

        #expect(loaded != nil)
        #expect(loaded?.nickname == profile.nickname)
        #expect(loaded?.age == profile.age)
        #expect(loaded?.gender == profile.gender)

        cleanupTestData()
    }

    @Test("Load returns nil when no profile exists")
    func loadUserProfileWhenEmpty() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let loaded = try cacheManager.loadUserProfile()

        #expect(loaded == nil)

        cleanupTestData()
    }

    @Test("Delete user profile removes stored data")
    func deleteUserProfile() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let profile = UserProfile.sampleData

        // Save and verify
        try cacheManager.saveUserProfile(profile)
        let beforeDelete = try cacheManager.loadUserProfile()
        #expect(beforeDelete != nil)

        // Delete and verify
        cacheManager.deleteUserProfile()
        let afterDelete = try cacheManager.loadUserProfile()

        #expect(afterDelete == nil)

        cleanupTestData()
    }

    // MARK: - Onboarding State Tests

    @Test("Save and check onboarding completed state")
    func onboardingStatePersistence() {
        cleanupTestData()

        let cacheManager = CacheManager.shared

        // Set completed
        cacheManager.saveOnboardingCompleted(true)
        #expect(cacheManager.isOnboardingCompleted() == true)

        // Set not completed
        cacheManager.saveOnboardingCompleted(false)
        #expect(cacheManager.isOnboardingCompleted() == false)

        cleanupTestData()
    }

    @Test("Reset onboarding state clears completion flag")
    func resetOnboardingState() {
        cleanupTestData()

        let cacheManager = CacheManager.shared

        cacheManager.saveOnboardingCompleted(true)
        #expect(cacheManager.isOnboardingCompleted() == true)

        cacheManager.resetOnboardingState()
        #expect(cacheManager.isOnboardingCompleted() == false)

        cleanupTestData()
    }

    // MARK: - Advice Cache Tests

    @Test("Save and load advice for specific date")
    func saveAndLoadAdvice() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let testDate = Date()
        let advice = DailyAdvice.createMock()

        try cacheManager.saveAdvice(advice, for: testDate)
        let loaded: DailyAdvice? = try cacheManager.loadAdvice(for: testDate, type: DailyAdvice.self)

        #expect(loaded != nil)
        #expect(loaded?.greeting == advice.greeting)
        #expect(loaded?.timeSlot == advice.timeSlot)

        cleanupTestData()
    }

    @Test("Check if advice is cached for date")
    func isAdviceCached() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let testDate = Date()
        let advice = DailyAdvice.createMock()

        // Before caching
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        #expect(cacheManager.isAdviceCached(for: tomorrow) == false)

        // After caching
        try cacheManager.saveAdvice(advice, for: testDate)
        #expect(cacheManager.isAdviceCached(for: testDate) == true)

        cleanupTestData()
    }

    @Test("Load advice returns nil for uncached date")
    func loadAdviceForUncachedDate() throws {
        cleanupTestData()

        let cacheManager = CacheManager.shared
        let futureDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())!

        let loaded: DailyAdvice? = try cacheManager.loadAdvice(for: futureDate, type: DailyAdvice.self)

        #expect(loaded == nil)

        cleanupTestData()
    }
}
