import XCTest
@testable import TempoAI

final class OnboardingStateTests: XCTestCase {
    
    var onboardingState: OnboardingState!
    
    override func setUp() {
        super.setUp()
        onboardingState = OnboardingState()
    }
    
    // MARK: - Initialization Tests
    
    func testOnboardingStateInitialization() {
        XCTAssertNotNil(onboardingState, "OnboardingState should initialize successfully")
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Initial step should be welcome")
        XCTAssertFalse(onboardingState.isCompleted, "Should not be completed initially")
    }
    
    // MARK: - Step Navigation Tests
    
    func testStepProgression() {
        // Test normal progression
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Should start at welcome")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .nickname, "Should move to nickname")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .basicInfo, "Should move to basicInfo")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .lifestyle, "Should move to lifestyle")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .interests, "Should move to interests")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .permissions, "Should move to permissions")
        
        onboardingState.moveToNextStep()
        XCTAssertEqual(onboardingState.currentStep, .loading, "Should move to loading")
    }
    
    func testStepBackNavigation() {
        // Move forward first
        onboardingState.moveToNextStep() // nickname
        onboardingState.moveToNextStep() // basicInfo
        
        XCTAssertEqual(onboardingState.currentStep, .basicInfo, "Should be at basicInfo")
        
        // Test back navigation
        onboardingState.moveToPreviousStep()
        XCTAssertEqual(onboardingState.currentStep, .nickname, "Should move back to nickname")
        
        onboardingState.moveToPreviousStep()
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Should move back to welcome")
    }
    
    func testCannotGoBackFromFirstStep() {
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Should be at welcome")
        
        onboardingState.moveToPreviousStep()
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Should stay at welcome when trying to go back")
    }
    
    // MARK: - Form Data Tests
    
    func testNicknameStorage() {
        let testNickname = "テストユーザー"
        
        onboardingState.updateNickname(testNickname)
        XCTAssertEqual(onboardingState.nickname, testNickname, "Nickname should be stored correctly")
    }
    
    func testBasicInfoStorage() {
        let testAge = 25
        let testGender = UserProfile.Gender.male
        let testWeight = 70.0
        let testHeight = 175.0
        
        onboardingState.updateBasicInfo(age: testAge, gender: testGender, weight: testWeight, height: testHeight)
        
        XCTAssertEqual(onboardingState.age, testAge, "Age should be stored correctly")
        XCTAssertEqual(onboardingState.gender, testGender, "Gender should be stored correctly")
        XCTAssertEqual(onboardingState.weightKg, testWeight, "Weight should be stored correctly")
        XCTAssertEqual(onboardingState.heightCm, testHeight, "Height should be stored correctly")
    }
    
    func testInterestsStorage() {
        let testInterests: [UserProfile.Interest] = [.fitness, .nutrition, .sleep]
        
        onboardingState.updateInterests(testInterests)
        XCTAssertEqual(onboardingState.selectedInterests, testInterests, "Interests should be stored correctly")
    }
    
    // MARK: - Validation Tests
    
    func testIsCurrentStepValid() {
        // Welcome step should always be valid
        XCTAssertTrue(onboardingState.isCurrentStepValid(), "Welcome step should be valid")
        
        // Move to nickname step
        onboardingState.moveToNextStep()
        XCTAssertFalse(onboardingState.isCurrentStepValid(), "Nickname step should be invalid without nickname")
        
        // Add nickname
        onboardingState.updateNickname("テスト")
        XCTAssertTrue(onboardingState.isCurrentStepValid(), "Nickname step should be valid with nickname")
    }
    
    func testCanProceedToNextStep() {
        XCTAssertTrue(onboardingState.canProceedToNextStep(), "Should be able to proceed from welcome")
        
        onboardingState.moveToNextStep() // nickname
        XCTAssertFalse(onboardingState.canProceedToNextStep(), "Should not be able to proceed without nickname")
        
        onboardingState.updateNickname("テスト")
        XCTAssertTrue(onboardingState.canProceedToNextStep(), "Should be able to proceed with valid nickname")
    }
    
    // MARK: - Profile Generation Tests
    
    func testGenerateUserProfile() throws {
        // Fill all required data
        onboardingState.updateNickname("テストユーザー")
        onboardingState.updateBasicInfo(age: 25, gender: .male, weight: 70.0, height: 175.0)
        onboardingState.updateInterests([.fitness, .nutrition])
        
        let profile = try onboardingState.generateUserProfile()
        
        XCTAssertEqual(profile.nickname, "テストユーザー", "Generated profile nickname should match")
        XCTAssertEqual(profile.age, 25, "Generated profile age should match")
        XCTAssertEqual(profile.gender, .male, "Generated profile gender should match")
        XCTAssertEqual(profile.weightKg, 70.0, "Generated profile weight should match")
        XCTAssertEqual(profile.heightCm, 175.0, "Generated profile height should match")
        XCTAssertEqual(profile.interests, [.fitness, .nutrition], "Generated profile interests should match")
    }
    
    func testGenerateUserProfileIncompleteData() {
        // Don't fill required data
        XCTAssertThrowsError(try onboardingState.generateUserProfile()) { error in
            XCTAssertTrue(error is OnboardingState.ValidationError, "Should throw ValidationError for incomplete data")
        }
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        // Fill some data
        onboardingState.updateNickname("テスト")
        onboardingState.moveToNextStep()
        
        XCTAssertEqual(onboardingState.nickname, "テスト", "Nickname should be set")
        XCTAssertEqual(onboardingState.currentStep, .nickname, "Should be at nickname step")
        
        // Reset
        onboardingState.reset()
        
        XCTAssertNil(onboardingState.nickname, "Nickname should be reset")
        XCTAssertEqual(onboardingState.currentStep, .welcome, "Should be back at welcome step")
        XCTAssertFalse(onboardingState.isCompleted, "Should not be completed after reset")
    }
    
    // MARK: - Progress Tests
    
    func testProgressCalculation() {
        let initialProgress = onboardingState.progress
        XCTAssertEqual(initialProgress, 0.0, accuracy: 0.01, "Initial progress should be 0")
        
        // Move through steps
        onboardingState.moveToNextStep() // nickname
        let nicknameProgress = onboardingState.progress
        XCTAssertGreaterThan(nicknameProgress, 0.0, "Progress should increase after moving to nickname")
        
        onboardingState.moveToNextStep() // basicInfo
        let basicInfoProgress = onboardingState.progress
        XCTAssertGreaterThan(basicInfoProgress, nicknameProgress, "Progress should continue increasing")
    }
}