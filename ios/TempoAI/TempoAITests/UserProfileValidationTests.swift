import XCTest
@testable import TempoAI

final class UserProfileValidationTests: XCTestCase {
    
    // MARK: - BMI Calculation Tests
    
    func testBMICalculationNormal() {
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
        XCTAssertEqual(profile.bmi, expectedBMI, accuracy: 0.01, "BMI calculation should be correct")
    }
    
    func testBMICalculationZeroHeight() {
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
        
        XCTAssertEqual(profile.bmi, 0.0, "BMI should be 0 when height is 0")
    }
    
    // MARK: - Completion Rate Tests
    
    func testCompletionRateMinimal() {
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
        XCTAssertEqual(minimalProfile.completionRate, 0.6, accuracy: 0.01, "Minimal completion should be 60%")
    }
    
    func testCompletionRateFull() {
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
        XCTAssertEqual(fullProfile.completionRate, 1.0, accuracy: 0.01, "Full completion should be 100%")
    }
    
    // MARK: - Validation Tests
    
    func testValidationSuccess() {
        let validProfile = UserProfile.sampleData
        XCTAssertNoThrow(try validProfile.validate(), "Valid profile should pass validation")
    }
    
    func testValidationEmptyNickname() {
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
        
        XCTAssertThrowsError(try invalidProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .emptyNickname, "Should be emptyNickname error")
            }
        }
    }
    
    func testValidationNicknameTooLong() {
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
        
        XCTAssertThrowsError(try invalidProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .nicknameTooLong, "Should be nicknameTooLong error")
            }
        }
    }
    
    // MARK: - Enum Tests
    
    func testGenderDisplayNames() {
        XCTAssertEqual(UserProfile.Gender.male.displayName, "男性", "Male display name should be correct")
        XCTAssertEqual(UserProfile.Gender.female.displayName, "女性", "Female display name should be correct")
        XCTAssertEqual(UserProfile.Gender.other.displayName, "その他", "Other display name should be correct")
        XCTAssertEqual(UserProfile.Gender.notSpecified.displayName, "回答しない", "Not specified display name should be correct")
    }
    
    func testInterestDisplayNames() {
        XCTAssertEqual(UserProfile.Interest.fitness.displayName, "運動・フィットネス", "Fitness display name should be correct")
        XCTAssertEqual(UserProfile.Interest.nutrition.displayName, "栄養・食事", "Nutrition display name should be correct")
        XCTAssertEqual(UserProfile.Interest.sleep.displayName, "睡眠", "Sleep display name should be correct")
    }
    
    func testInterestIcons() {
        XCTAssertEqual(UserProfile.Interest.fitness.icon, "figure.run", "Fitness icon should be correct")
        XCTAssertEqual(UserProfile.Interest.nutrition.icon, "fork.knife", "Nutrition icon should be correct")
        XCTAssertEqual(UserProfile.Interest.sleep.icon, "moon.fill", "Sleep icon should be correct")
    }
    
    // MARK: - Codable Tests
    
    func testUserProfileCodable() throws {
        let profile = UserProfile.sampleData
        
        let encodedData = try JSONEncoder().encode(profile)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        let decodedProfile = try JSONDecoder().decode(UserProfile.self, from: encodedData)
        
        XCTAssertEqual(decodedProfile.nickname, profile.nickname, "Decoded nickname should match")
        XCTAssertEqual(decodedProfile.age, profile.age, "Decoded age should match")
        XCTAssertEqual(decodedProfile.gender, profile.gender, "Decoded gender should match")
    }
}