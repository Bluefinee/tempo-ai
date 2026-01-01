//
//  UserProfileTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct UserProfileTests {

    // MARK: - UserProfile Tests

    @Test("UserProfile calculates BMI correctly")
    func userProfileBMICalculation() {
        let profile: UserProfile = UserProfile(
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
        // BMI = 70 / (1.75 * 1.75) = 22.857...
        #expect(profile.bmi > 22.8 && profile.bmi < 22.9)
    }

    @Test("UserProfile handles zero height safely")
    func userProfileZeroHeightSafe() {
        let profile: UserProfile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weight: 70,
            height: 0,
            occupation: nil,
            chronotype: .intermediate,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            targetBedtime: Date()
        )
        #expect(profile.bmi == 0)
    }

    // MARK: - Codable Tests

    @Test("UserProfile encodes and decodes correctly")
    func userProfileCodable() throws {
        let original: UserProfile = UserProfile(
            nickname: "テスト太郎",
            age: 35,
            gender: .male,
            weight: 68.5,
            height: 172.0,
            occupation: .deskWork,
            chronotype: .morning,
            exerciseFrequency: .threeOrMore,
            alcoholFrequency: .weekly,
            targetBedtime: Date(timeIntervalSince1970: 1704067200)
        )

        let encoder: JSONEncoder = JSONEncoder()
        let data: Data = try encoder.encode(original)

        let decoder: JSONDecoder = JSONDecoder()
        let decoded: UserProfile = try decoder.decode(UserProfile.self, from: data)

        #expect(decoded.nickname == original.nickname)
        #expect(decoded.age == original.age)
        #expect(decoded.gender == original.gender)
        #expect(decoded.weight == original.weight)
        #expect(decoded.height == original.height)
        #expect(decoded.occupation == original.occupation)
        #expect(decoded.chronotype == original.chronotype)
    }

    // MARK: - Chronotype Tests

    @Test("Chronotype has recommended bedtime ranges")
    func chronotypeRecommendedBedtimes() {
        #expect(Chronotype.morning.recommendedBedtimeRange.contains("21:00"))
        #expect(Chronotype.intermediate.recommendedBedtimeRange.contains("22:00"))
        #expect(Chronotype.evening.recommendedBedtimeRange.contains("23:00"))
    }

    // MARK: - CalibrationState Tests

    @Test("CalibrationState initializes correctly")
    func calibrationStateInitialization() {
        let state: CalibrationState = CalibrationState()
        #expect(state.daysCompleted == 0)
        #expect(state.isComplete == false)
        #expect(state.remainingDays == 7)
    }

    @Test("CalibrationState updates progress correctly")
    func calibrationStateProgressUpdate() {
        var state: CalibrationState = CalibrationState()
        state.updateProgress(healthDataDays: 5)

        #expect(state.daysCompleted == 5)
        #expect(state.isComplete == false)
        #expect(state.remainingDays == 2)
        #expect(state.progressRatio > 0.7 && state.progressRatio < 0.72)
    }

    @Test("CalibrationState completes at 7 days")
    func calibrationStateCompletion() {
        var state: CalibrationState = CalibrationState()
        state.updateProgress(healthDataDays: 7)

        #expect(state.daysCompleted == 7)
        #expect(state.isComplete == true)
        #expect(state.remainingDays == 0)
        #expect(state.progressRatio == 1.0)
    }

    @Test("CalibrationState caps at required days")
    func calibrationStateCapsAtRequired() {
        var state: CalibrationState = CalibrationState()
        state.updateProgress(healthDataDays: 30)

        #expect(state.daysCompleted == 7)
        #expect(state.isComplete == true)
    }
}
