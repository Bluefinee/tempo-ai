import Foundation
import Testing

@testable import TempoAI

struct UserProfileValidationTests {

    // MARK: - BMI Calculation Tests

    @Test("BMI calculates correctly for normal values")
    func bmiCalculationNormal() {
        let profile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )

        // BMI = 70 / (1.75)^2 ≈ 22.86
        let expectedBMI = 70.0 / (1.75 * 1.75)
        #expect(abs(profile.bmi - expectedBMI) < 0.01)
    }

    @Test("BMI returns 0 when height is 0")
    func bmiCalculationZeroHeight() {
        let profile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weightKg: 70.0,
            heightCm: 0.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )

        #expect(profile.bmi == 0.0)
    }

    // MARK: - Completion Rate Tests

    @Test("Minimal profile has 60% completion")
    func completionRateMinimal() {
        let minimalProfile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )

        // 5 required + 1 interest = 6/10 = 0.6
        #expect(abs(minimalProfile.completionRate - 0.6) < 0.01)
    }

    @Test("Full profile has 100% completion")
    func completionRateFull() {
        let fullProfile = UserProfile(
            nickname: "テスト",
            age: 30,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: .itEngineer,
            lifestyleRhythm: .morning,
            exerciseFrequency: .threeToFour,
            alcoholFrequency: .never,
            interests: [.fitness, .nutrition, .sleep]
        )

        // All 10 fields = 10/10 = 1.0
        #expect(abs(fullProfile.completionRate - 1.0) < 0.01)
    }

    // MARK: - Validation Tests

    @Test("Valid profile passes validation")
    func validationSuccess() throws {
        let validProfile = UserProfile.sampleData
        #expect(throws: Never.self) {
            try validProfile.validate()
        }
    }

    @Test("Empty nickname fails validation with emptyNickname error")
    func validationEmptyNickname() {
        let invalidProfile = UserProfile(
            nickname: "",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )

        #expect(throws: UserProfile.ValidationError.emptyNickname) {
            try invalidProfile.validate()
        }
    }

    @Test("Nickname over 20 characters fails validation")
    func validationNicknameTooLong() {
        let invalidProfile = UserProfile(
            nickname: String(repeating: "a", count: 25),
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )

        #expect(throws: UserProfile.ValidationError.nicknameTooLong) {
            try invalidProfile.validate()
        }
    }

    // MARK: - Enum Tests

    @Test("Gender display names are correctly localized")
    func genderDisplayNames() {
        #expect(UserProfile.Gender.male.displayName == "男性")
        #expect(UserProfile.Gender.female.displayName == "女性")
        #expect(UserProfile.Gender.other.displayName == "その他")
        #expect(UserProfile.Gender.notSpecified.displayName == "回答しない")
    }

    @Test("Interest display names are correctly localized")
    func interestDisplayNames() {
        #expect(UserProfile.Interest.fitness.displayName == "運動・フィットネス")
        #expect(UserProfile.Interest.nutrition.displayName == "栄養・食事")
        #expect(UserProfile.Interest.sleep.displayName == "睡眠")
    }

    @Test("Interest icons are correct")
    func interestIcons() {
        #expect(UserProfile.Interest.fitness.icon == "figure.run")
        #expect(UserProfile.Interest.nutrition.icon == "fork.knife")
        #expect(UserProfile.Interest.sleep.icon == "moon.fill")
    }

    // MARK: - Codable Tests

    @Test("UserProfile can be encoded and decoded")
    func userProfileCodable() throws {
        let profile = UserProfile.sampleData

        let encodedData = try JSONEncoder().encode(profile)
        #expect(encodedData.count > 0)

        let decodedProfile = try JSONDecoder().decode(UserProfile.self, from: encodedData)

        #expect(decodedProfile.nickname == profile.nickname)
        #expect(decodedProfile.age == profile.age)
        #expect(decodedProfile.gender == profile.gender)
    }
}
