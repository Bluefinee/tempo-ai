import XCTest
@testable import TempoAI

class OnboardingCoordinatorTests: XCTestCase {
    var coordinator: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = OnboardingCoordinator()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(coordinator.currentPage, .welcome)
        XCTAssertFalse(coordinator.isCompleted)
        XCTAssertTrue(coordinator.canProceed)
    }
    
    func testWelcomePageProgression() {
        XCTAssertTrue(coordinator.canProceed)
        
        coordinator.nextPage()
        XCTAssertEqual(coordinator.currentPage, .userMode)
        XCTAssertFalse(coordinator.canProceed)
    }
    
    func testUserModeSelection() {
        coordinator.nextPage()
        XCTAssertFalse(coordinator.canProceed)
        
        coordinator.selectedUserMode = .standard
        XCTAssertTrue(coordinator.canProceed)
        
        coordinator.nextPage()
        XCTAssertEqual(coordinator.currentPage, .focusTags)
    }
    
    func testFocusTagsSelection() {
        coordinator.currentPage = .focusTags
        XCTAssertFalse(coordinator.canProceed)
        
        coordinator.selectedTags.insert(.work)
        XCTAssertTrue(coordinator.canProceed)
        
        coordinator.nextPage()
        XCTAssertEqual(coordinator.currentPage, .healthPermission)
    }
    
    func testPermissionPages() {
        coordinator.currentPage = .healthPermission
        XCTAssertFalse(coordinator.canProceed)
        
        coordinator.healthPermissionGranted = true
        XCTAssertTrue(coordinator.canProceed)
        
        coordinator.nextPage()
        XCTAssertEqual(coordinator.currentPage, .locationPermission)
    }
    
    func testOnboardingCompletion() {
        coordinator.selectedUserMode = .athlete
        coordinator.selectedTags = [.work, .beauty]
        coordinator.healthPermissionGranted = true
        coordinator.locationPermissionGranted = true
        coordinator.currentPage = .completion
        
        coordinator.nextPage()
        
        XCTAssertTrue(coordinator.isCompleted)
        XCTAssertEqual(UserProfileManager.shared.currentMode, .athlete)
    }
    
    func testBackwardNavigation() {
        coordinator.currentPage = .userMode
        coordinator.previousPage()
        XCTAssertEqual(coordinator.currentPage, .welcome)
    }
}