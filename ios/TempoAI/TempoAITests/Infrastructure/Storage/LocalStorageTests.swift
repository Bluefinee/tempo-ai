//
//  LocalStorageTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct LocalStorageTests {

    // MARK: - Test Helpers

    private func makeTestStorage() -> LocalStorage {
        let suiteName: String = "com.tempoai.tests.\(UUID().uuidString)"
        let defaults: UserDefaults = UserDefaults(suiteName: suiteName)!
        return LocalStorage(defaults: defaults)
    }

    // MARK: - Basic Operations Tests

    @Test("LocalStorage saves and loads data correctly")
    func saveAndLoadRoundtrip() {
        let storage: LocalStorage = makeTestStorage()
        let original: UserProfile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weight: 70,
            height: 175,
            occupation: .deskWork,
            chronotype: .intermediate,
            exerciseFrequency: .twiceWeek,
            alcoholFrequency: .rarely,
            targetBedtime: Date()
        )

        storage.save(original, forKey: "test_profile")
        let loaded: UserProfile? = storage.load(forKey: "test_profile")

        #expect(loaded != nil)
        #expect(loaded?.nickname == original.nickname)
        #expect(loaded?.age == original.age)
    }

    @Test("LocalStorage returns nil for missing key")
    func loadReturnsNilForMissingKey() {
        let storage: LocalStorage = makeTestStorage()
        let result: UserProfile? = storage.load(forKey: "nonexistent_key")
        #expect(result == nil)
    }

    @Test("LocalStorage removes data correctly")
    func removeDeletesData() {
        let storage: LocalStorage = makeTestStorage()
        storage.save("test value", forKey: "test_key")

        #expect(storage.exists(forKey: "test_key") == true)

        storage.remove(forKey: "test_key")

        #expect(storage.exists(forKey: "test_key") == false)
        let result: String? = storage.load(forKey: "test_key")
        #expect(result == nil)
    }

    @Test("LocalStorage overwrites existing data")
    func saveOverwritesExistingData() {
        let storage: LocalStorage = makeTestStorage()

        storage.save("first value", forKey: "test_key")
        let first: String? = storage.load(forKey: "test_key")
        #expect(first == "first value")

        storage.save("second value", forKey: "test_key")
        let second: String? = storage.load(forKey: "test_key")
        #expect(second == "second value")
    }

    @Test("LocalStorage exists returns correct values")
    func existsReturnsCorrectly() {
        let storage: LocalStorage = makeTestStorage()

        #expect(storage.exists(forKey: "nonexistent") == false)

        storage.save("value", forKey: "existing_key")
        #expect(storage.exists(forKey: "existing_key") == true)
    }

    // MARK: - Complex Types Tests

    @Test("LocalStorage handles arrays correctly")
    func handlesArrays() {
        let storage: LocalStorage = makeTestStorage()
        let original: [Int] = [1, 2, 3, 4, 5]

        storage.save(original, forKey: "test_array")
        let loaded: [Int]? = storage.load(forKey: "test_array")

        #expect(loaded == original)
    }

    @Test("LocalStorage handles CalibrationState correctly")
    func handlesCalibrationState() {
        let storage: LocalStorage = makeTestStorage()
        var original: CalibrationState = CalibrationState()
        original.updateProgress(healthDataDays: 3)

        storage.save(original, forKey: StorageKeys.calibrationState)
        let loaded: CalibrationState? = storage.load(forKey: StorageKeys.calibrationState)

        #expect(loaded != nil)
        #expect(loaded?.daysCompleted == 3)
        #expect(loaded?.isComplete == false)
    }

    // MARK: - StorageKeys Tests

    @Test("StorageKeys generates date-based advice keys")
    func adviceKeyGeneration() {
        let date: Date = Date(timeIntervalSince1970: 1704067200) // 2024-01-01
        let key: String = StorageKeys.advice(for: date)
        #expect(key.hasPrefix("advice_"))
        #expect(key.contains("2024"))
    }
}
