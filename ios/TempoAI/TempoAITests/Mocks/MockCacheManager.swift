import Foundation
@testable import TempoAI

/// Mock implementation of CacheManaging for testing
@MainActor
final class MockCacheManager: CacheManaging {

    // MARK: - Call Tracking

    var saveUserProfileCalls: [UserProfile] = []
    var loadUserProfileCallCount: Int = 0
    var deleteUserProfileCallCount: Int = 0
    var saveOnboardingCompletedCalls: [Bool] = []
    var isOnboardingCompletedCallCount: Int = 0
    var resetOnboardingStateCallCount: Int = 0
    var saveAdviceCalls: [(advice: Any, date: Date)] = []
    var loadAdviceCalls: [(date: Date, type: Any.Type)] = []
    var isAdviceCachedCalls: [Date] = []

    // MARK: - Stubbed Return Values

    var storedProfile: UserProfile?
    var onboardingCompleted: Bool = false
    var cachedAdvice: [String: Any] = [:]

    // MARK: - Error Simulation

    var shouldThrowError: Bool = false
    var errorToThrow: Error = CacheError.encodingFailed

    // MARK: - CacheManaging Protocol - User Profile

    func saveUserProfile(_ profile: UserProfile) throws {
        saveUserProfileCalls.append(profile)
        if shouldThrowError {
            throw errorToThrow
        }
        storedProfile = profile
    }

    func loadUserProfile() throws -> UserProfile? {
        loadUserProfileCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        return storedProfile
    }

    func deleteUserProfile() {
        deleteUserProfileCallCount += 1
        storedProfile = nil
    }

    // MARK: - CacheManaging Protocol - Onboarding

    func saveOnboardingCompleted(_ completed: Bool) {
        saveOnboardingCompletedCalls.append(completed)
        onboardingCompleted = completed
    }

    func isOnboardingCompleted() -> Bool {
        isOnboardingCompletedCallCount += 1
        return onboardingCompleted
    }

    func resetOnboardingState() {
        resetOnboardingStateCallCount += 1
        onboardingCompleted = false
    }

    // MARK: - CacheManaging Protocol - Advice Cache

    func saveAdvice<T: Codable>(_ advice: T, for date: Date) throws {
        saveAdviceCalls.append((advice: advice, date: date))
        if shouldThrowError {
            throw errorToThrow
        }
        let key = dateKey(for: date)
        cachedAdvice[key] = advice
    }

    func loadAdvice<T: Codable>(for date: Date, type: T.Type) throws -> T? {
        loadAdviceCalls.append((date: date, type: type))
        if shouldThrowError {
            throw errorToThrow
        }
        let key = dateKey(for: date)
        return cachedAdvice[key] as? T
    }

    func isAdviceCached(for date: Date) -> Bool {
        isAdviceCachedCalls.append(date)
        let key = dateKey(for: date)
        return cachedAdvice[key] != nil
    }

    // MARK: - Helper Methods

    private func dateKey(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }

    /// Reset all tracked calls and state
    func reset() {
        saveUserProfileCalls.removeAll()
        loadUserProfileCallCount = 0
        deleteUserProfileCallCount = 0
        saveOnboardingCompletedCalls.removeAll()
        isOnboardingCompletedCallCount = 0
        resetOnboardingStateCallCount = 0
        saveAdviceCalls.removeAll()
        loadAdviceCalls.removeAll()
        isAdviceCachedCalls.removeAll()
        storedProfile = nil
        onboardingCompleted = false
        cachedAdvice.removeAll()
        shouldThrowError = false
    }
}

// MARK: - CacheError (for testing)

enum CacheError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .fileNotFound:
            return "File not found"
        }
    }
}
