import XCTest
@testable import TempoAI

final class UserProfileTests: XCTestCase {
    
    // MARK: - BMI Calculation Tests
    
    func testBMICalculation() {
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
        
        // BMI = weight(kg) / height(m)^2 = 70 / (1.75)^2 = 70 / 3.0625 ≈ 22.86
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
    
    func testCompletionRateMinimalProfile() {
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
        
        // 5 required fields + 1 interest = 6/10 = 0.6
        XCTAssertEqual(minimalProfile.completionRate, 0.6, accuracy: 0.01, "Minimal profile completion should be 60%")
    }
    
    func testCompletionRateFullProfile() {
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
        
        // All 10 fields filled = 10/10 = 1.0
        XCTAssertEqual(fullProfile.completionRate, 1.0, accuracy: 0.01, "Full profile completion should be 100%")
    }
    
    // MARK: - Validation Tests
    
    func testValidationSuccessful() {
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
            XCTAssertTrue(error is UserProfile.ValidationError, "Should throw ValidationError")
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .emptyNickname, "Should be emptyNickname error")
            }
        }
    }
    
    func testValidationNicknameTooLong() {
        let invalidProfile = UserProfile(
            nickname: String(repeating: "a", count: 25), // 25 characters (>20)
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
    
    func testValidationInvalidAge() {
        let invalidProfile = UserProfile(
            nickname: "テスト",
            age: 15, // Under 18
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
                XCTAssertEqual(validationError, .invalidAge, "Should be invalidAge error")
            }
        }
    }
    
    func testValidationInvalidWeight() {
        let invalidProfile = UserProfile(
            nickname: "テスト",
            age: 25,
            gender: .male,
            weightKg: 25.0, // Under 30
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )
        
        XCTAssertThrowsError(try invalidProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .invalidWeight, "Should be invalidWeight error")
            }
        }
    }
    
    func testValidationInvalidHeight() {
        let invalidProfile = UserProfile(
            nickname: "テスト",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 80.0, // Under 100
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness]
        )
        
        XCTAssertThrowsError(try invalidProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .invalidHeight, "Should be invalidHeight error")
            }
        }
    }
    
    func testValidationInvalidInterestsCount() {
        let noInterestsProfile = UserProfile(
            nickname: "テスト",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [] // Empty interests
        )
        
        XCTAssertThrowsError(try noInterestsProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .invalidInterestsCount, "Should be invalidInterestsCount error")
            }
        }
        
        let tooManyInterestsProfile = UserProfile(
            nickname: "テスト",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: [.fitness, .nutrition, .sleep, .beauty] // 4 interests (>3)
        )
        
        XCTAssertThrowsError(try tooManyInterestsProfile.validate()) { error in
            if let validationError = error as? UserProfile.ValidationError {
                XCTAssertEqual(validationError, .invalidInterestsCount, "Should be invalidInterestsCount error for too many interests")
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
    
    func testInterestDisplayNamesAndIcons() {
        XCTAssertEqual(UserProfile.Interest.fitness.displayName, "運動・フィットネス", "Fitness display name should be correct")
        XCTAssertEqual(UserProfile.Interest.fitness.icon, "figure.run", "Fitness icon should be correct")
        
        XCTAssertEqual(UserProfile.Interest.nutrition.displayName, "栄養・食事", "Nutrition display name should be correct")
        XCTAssertEqual(UserProfile.Interest.nutrition.icon, "fork.knife", "Nutrition icon should be correct")
        
        XCTAssertEqual(UserProfile.Interest.sleep.displayName, "睡眠", "Sleep display name should be correct")
        XCTAssertEqual(UserProfile.Interest.sleep.icon, "moon.fill", "Sleep icon should be correct")
    }
    
    func testOccupationDisplayNames() {
        XCTAssertEqual(UserProfile.Occupation.itEngineer.displayName, "IT・エンジニア", "IT Engineer display name should be correct")
        XCTAssertEqual(UserProfile.Occupation.medical.displayName, "医療・介護", "Medical display name should be correct")
        XCTAssertEqual(UserProfile.Occupation.student.displayName, "学生", "Student display name should be correct")
    }
    
    // MARK: - Codable Tests
    
    func testUserProfileCodable() throws {
        let profile = UserProfile.sampleData
        
        // Test encoding
        let encodedData = try JSONEncoder().encode(profile)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        // Test decoding
        let decodedProfile = try JSONDecoder().decode(UserProfile.self, from: encodedData)
        
        XCTAssertEqual(decodedProfile.nickname, profile.nickname, "Decoded nickname should match")
        XCTAssertEqual(decodedProfile.age, profile.age, "Decoded age should match")
        XCTAssertEqual(decodedProfile.gender, profile.gender, "Decoded gender should match")
        XCTAssertEqual(decodedProfile.interests, profile.interests, "Decoded interests should match")
    }
}