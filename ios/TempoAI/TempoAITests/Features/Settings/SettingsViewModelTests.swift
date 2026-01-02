//
//  SettingsViewModelTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

// MARK: - Mock Classes

final class MockLocalStorageForSettings: LocalStorageProtocol, @unchecked Sendable {
    var storage: [String: Any] = [:]
    var userProfile: UserProfile?
    var saveCallCount: Int = 0
    var lastSavedProfile: UserProfile?

    func save<T: Codable>(_ value: T, forKey key: String) {
        storage[key] = value
        saveCallCount += 1
        if key == StorageKeys.userProfile, let profile = value as? UserProfile {
            lastSavedProfile = profile
            userProfile = profile
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        if key == StorageKeys.userProfile {
            return userProfile as? T
        }
        return storage[key] as? T
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        if key == StorageKeys.userProfile {
            return userProfile != nil
        }
        return storage[key] != nil
    }
}

// MARK: - Test Data

private let testProfile: UserProfile = UserProfile(
    nickname: "テスト",
    age: 30,
    gender: .male,
    weight: 65.0,
    height: 170.0,
    occupation: .deskWork,
    chronotype: .intermediate,
    exerciseFrequency: .twiceWeek,
    alcoholFrequency: .rarely,
    targetBedtime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
)

// MARK: - SettingsViewModelTests

@MainActor
struct SettingsViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state has empty nickname")
    func initialStateHasEmptyNickname() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(viewModel.nickname == "")
    }

    @Test("Initial state has isLoading false")
    func initialStateHasIsLoadingFalse() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(viewModel.isLoading == false)
    }

    @Test("Initial state has isSaving false")
    func initialStateHasIsSavingFalse() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(viewModel.isSaving == false)
    }

    @Test("Initial state has error nil")
    func initialStateHasErrorNil() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(viewModel.error == nil)
    }

    @Test("Initial state has hasChanges false")
    func initialStateHasNoChanges() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(viewModel.hasChanges == false)
    }

    // MARK: - Load Profile Tests

    @Test("loadProfile populates fields from stored profile")
    func loadProfilePopulatesFields() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        #expect(viewModel.nickname == "テスト")
        #expect(viewModel.age == 30)
        #expect(viewModel.gender == .male)
        #expect(viewModel.weight == 65.0)
        #expect(viewModel.height == 170.0)
        #expect(viewModel.chronotype == .intermediate)
    }

    @Test("loadProfile sets error when profile not found")
    func loadProfileSetsErrorWhenNotFound() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        // userProfile is nil

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        #expect(viewModel.error == .loadFailed)
    }

    // MARK: - Has Changes Tests

    @Test("hasChanges is true when nickname changed")
    func hasChangesWhenNicknameChanged() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.nickname = "新しい名前"

        #expect(viewModel.hasChanges == true)
    }

    @Test("hasChanges is true when weight changed")
    func hasChangesWhenWeightChanged() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.weight = 70.0

        #expect(viewModel.hasChanges == true)
    }

    @Test("hasChanges is true when chronotype changed")
    func hasChangesWhenChronotypeChanged() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.chronotype = .morning

        #expect(viewModel.hasChanges == true)
    }

    @Test("hasChanges is false when values unchanged")
    func hasChangesIsFalseWhenUnchanged() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        #expect(viewModel.hasChanges == false)
    }

    // MARK: - Save Profile Tests

    @Test("saveProfile saves updated profile to storage")
    func saveProfileSavesToStorage() async {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.nickname = "更新済み"
        viewModel.weight = 70.0

        await viewModel.saveProfile()

        #expect(mockStorage.saveCallCount == 1)
        #expect(mockStorage.lastSavedProfile?.nickname == "更新済み")
        #expect(mockStorage.lastSavedProfile?.weight == 70.0)
        // Read-only fields should remain unchanged
        #expect(mockStorage.lastSavedProfile?.age == 30)
        #expect(mockStorage.lastSavedProfile?.gender == .male)
    }

    @Test("saveProfile does not save when no changes")
    func saveProfileDoesNotSaveWhenNoChanges() async {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        // No changes made
        await viewModel.saveProfile()

        #expect(mockStorage.saveCallCount == 0)
    }

    @Test("saveProfile saves when changes exist")
    func saveProfileSavesWhenChangesExist() async {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.nickname = "変更後"

        // Start save in background without awaiting the full 3-second delay
        let saveTask = Task {
            await viewModel.saveProfile()
        }

        // Give time for initial save to complete but not the 3-second success message delay
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds

        #expect(mockStorage.saveCallCount == 1)
        #expect(mockStorage.lastSavedProfile?.nickname == "変更後")

        saveTask.cancel()
    }

    // MARK: - Reset Tests

    @Test("resetToOriginal restores original values")
    func resetToOriginalRestoresValues() {
        let mockStorage: MockLocalStorageForSettings = MockLocalStorageForSettings()
        mockStorage.userProfile = testProfile

        let viewModel: SettingsViewModel = createViewModel(localStorage: mockStorage)
        viewModel.loadProfile()

        viewModel.nickname = "変更後"
        viewModel.weight = 80.0
        viewModel.chronotype = .evening

        #expect(viewModel.hasChanges == true)

        viewModel.resetToOriginal()

        #expect(viewModel.nickname == "テスト")
        #expect(viewModel.weight == 65.0)
        #expect(viewModel.chronotype == .intermediate)
        #expect(viewModel.hasChanges == false)
    }

    // MARK: - Version Tests

    @Test("appVersion returns valid version string")
    func appVersionReturnsValidString() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(!viewModel.appVersion.isEmpty)
    }

    @Test("buildNumber returns valid build string")
    func buildNumberReturnsValidString() {
        let viewModel: SettingsViewModel = createViewModel()
        #expect(!viewModel.buildNumber.isEmpty)
    }

    @Test("versionDisplayString contains version and build")
    func versionDisplayStringContainsBoth() {
        let viewModel: SettingsViewModel = createViewModel()
        let displayString: String = viewModel.versionDisplayString
        #expect(displayString.contains("Version"))
    }

    // MARK: - SettingsError Tests

    @Test("SettingsError loadFailed has correct description")
    func settingsErrorLoadFailedDescription() {
        let error: SettingsError = .loadFailed
        #expect(error.errorDescription?.contains("読み込み") == true)
    }

    @Test("SettingsError saveFailed has correct description")
    func settingsErrorSaveFailedDescription() {
        let error: SettingsError = .saveFailed
        #expect(error.errorDescription?.contains("保存") == true)
    }

    @Test("SettingsError invalidData has correct description")
    func settingsErrorInvalidDataDescription() {
        let error: SettingsError = .invalidData
        #expect(error.errorDescription?.contains("不正") == true)
    }

    // MARK: - Helpers

    private func createViewModel(
        localStorage: LocalStorageProtocol = MockLocalStorageForSettings()
    ) -> SettingsViewModel {
        SettingsViewModel(localStorage: localStorage)
    }
}
