import XCTest
@testable import TempoAI

/// Unit tests for OnboardingViewModel functionality.
///
/// Tests cover page navigation, permission management, state persistence,
/// and completion flow to ensure reliable onboarding experience.
/// Follows TDD principles with comprehensive test coverage.
@MainActor
final class OnboardingViewModelTests: XCTestCase {
    
    var viewModel: OnboardingViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = OnboardingViewModel()
        
        // Reset onboarding state for clean tests
        viewModel.resetOnboarding()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - Page Navigation Tests
    
    func testInitialPageIsZero() {
        XCTAssertEqual(viewModel.currentPage, 0, "Initial page should be 0")
    }
    
    func testNextPageProgression() {
        // Test progression through all pages
        XCTAssertEqual(viewModel.currentPage, 0)
        
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 1)
        
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 2)
        
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 3)
        
        // Should not go beyond last page
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 3)
    }
    
    func testPreviousPageProgression() {
        // Start at last page
        viewModel.goToPage(3)
        XCTAssertEqual(viewModel.currentPage, 3)
        
        viewModel.previousPage()
        XCTAssertEqual(viewModel.currentPage, 2)
        
        viewModel.previousPage()
        XCTAssertEqual(viewModel.currentPage, 1)
        
        viewModel.previousPage()
        XCTAssertEqual(viewModel.currentPage, 0)
        
        // Should not go below first page
        viewModel.previousPage()
        XCTAssertEqual(viewModel.currentPage, 0)
    }
    
    func testGoToPageDirectly() {
        viewModel.goToPage(2)
        XCTAssertEqual(viewModel.currentPage, 2)
        
        viewModel.goToPage(0)
        XCTAssertEqual(viewModel.currentPage, 0)
        
        // Test invalid pages are ignored
        viewModel.goToPage(-1)
        XCTAssertEqual(viewModel.currentPage, 0)
        
        viewModel.goToPage(4)
        XCTAssertEqual(viewModel.currentPage, 0)
    }
    
    // MARK: - Permission Status Tests
    
    func testInitialPermissionStatus() {
        XCTAssertEqual(viewModel.healthKitStatus, .notDetermined)
        XCTAssertEqual(viewModel.locationStatus, .notDetermined)
    }
    
    // MARK: - Computed Properties Tests
    
    func testAllPermissionsGranted() {
        // Initially false
        XCTAssertFalse(viewModel.allPermissionsGranted)
        
        // Set both permissions to granted
        viewModel.healthKitStatus = .granted
        viewModel.locationStatus = .granted
        XCTAssertTrue(viewModel.allPermissionsGranted)
        
        // If one permission denied, should be false
        viewModel.healthKitStatus = .denied
        XCTAssertFalse(viewModel.allPermissionsGranted)
    }
    
    func testAnyPermissionsGranted() {
        // Initially false
        XCTAssertFalse(viewModel.anyPermissionsGranted)
        
        // One permission granted
        viewModel.healthKitStatus = .granted
        XCTAssertTrue(viewModel.anyPermissionsGranted)
        
        // Other permission granted
        viewModel.healthKitStatus = .notDetermined
        viewModel.locationStatus = .granted
        XCTAssertTrue(viewModel.anyPermissionsGranted)
        
        // Both denied
        viewModel.healthKitStatus = .denied
        viewModel.locationStatus = .denied
        XCTAssertFalse(viewModel.anyPermissionsGranted)
    }
    
    func testOnboardingProgress() {
        XCTAssertEqual(viewModel.onboardingProgress, 0.0, accuracy: 0.01)
        
        viewModel.nextPage() // Page 1
        XCTAssertEqual(viewModel.onboardingProgress, 1.0/3.0, accuracy: 0.01)
        
        viewModel.nextPage() // Page 2
        XCTAssertEqual(viewModel.onboardingProgress, 2.0/3.0, accuracy: 0.01)
        
        viewModel.nextPage() // Page 3
        XCTAssertEqual(viewModel.onboardingProgress, 1.0, accuracy: 0.01)
    }
    
    func testIsOnFinalPage() {
        XCTAssertFalse(viewModel.isOnFinalPage)
        
        viewModel.goToPage(3)
        XCTAssertTrue(viewModel.isOnFinalPage)
        
        viewModel.goToPage(2)
        XCTAssertFalse(viewModel.isOnFinalPage)
    }
    
    func testCanProceed() {
        // All pages should allow proceeding (can skip permissions)
        for page in 0...3 {
            viewModel.goToPage(page)
            XCTAssertTrue(viewModel.canProceed, "Should be able to proceed from page \(page)")
        }
    }
    
    // MARK: - Onboarding Completion Tests
    
    func testOnboardingCompletion() {
        XCTAssertFalse(viewModel.isOnboardingCompleted)
        
        viewModel.completeOnboarding()
        
        XCTAssertTrue(viewModel.isOnboardingCompleted)
        
        // Test persistence across instances
        let newViewModel = OnboardingViewModel()
        XCTAssertTrue(newViewModel.isOnboardingCompleted)
    }
    
    func testOnboardingReset() {
        // Complete onboarding first
        viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingCompleted)
        
        // Reset and verify
        viewModel.resetOnboarding()
        
        XCTAssertFalse(viewModel.isOnboardingCompleted)
        XCTAssertEqual(viewModel.currentPage, 0)
        
        // Test persistence of reset
        let newViewModel = OnboardingViewModel()
        XCTAssertFalse(newViewModel.isOnboardingCompleted)
    }
    
    // MARK: - Analytics Tracking Tests
    
    func testTrackOnboardingStart() {
        // This test verifies the tracking method doesn't crash
        // In a real implementation, you might mock analytics service
        viewModel.trackOnboardingStart()
        
        // Verify start time is recorded in UserDefaults
        let startTime = UserDefaults.standard.object(forKey: "OnboardingStartTime")
        XCTAssertNotNil(startTime)
    }
    
    // MARK: - Mock Permission Request Tests
    
    func testMockHealthKitPermissionRequest() async {
        // This is a mock test - in real implementation you'd mock PermissionManager
        XCTAssertEqual(viewModel.healthKitStatus, .notDetermined)
        
        // In actual implementation, this would involve mocking PermissionManager
        // For now, we test the method doesn't crash
        await viewModel.requestHealthKitPermission()
        
        // Note: In real tests, you would mock the permission manager
        // and verify the status changes appropriately
    }
    
    func testMockLocationPermissionRequest() async {
        // This is a mock test - in real implementation you'd mock PermissionManager
        XCTAssertEqual(viewModel.locationStatus, .notDetermined)
        
        // In actual implementation, this would involve mocking PermissionManager
        // For now, we test the method doesn't crash
        await viewModel.requestLocationPermission()
        
        // Note: In real tests, you would mock the permission manager
        // and verify the status changes appropriately
    }
}

// MARK: - Permission Status Tests

final class PermissionStatusTests: XCTestCase {
    
    func testPermissionStatusDisplayText() {
        XCTAssertEqual(PermissionStatus.notDetermined.displayText, "Not Requested")
        XCTAssertEqual(PermissionStatus.granted.displayText, "Granted")
        XCTAssertEqual(PermissionStatus.denied.displayText, "Denied")
        XCTAssertEqual(PermissionStatus.restricted.displayText, "Restricted")
    }
    
    func testPermissionStatusColors() {
        XCTAssertEqual(PermissionStatus.granted.color, .green)
        XCTAssertEqual(PermissionStatus.denied.color, .red)
        XCTAssertEqual(PermissionStatus.restricted.color, .red)
        XCTAssertEqual(PermissionStatus.notDetermined.color, .orange)
    }
    
    func testPermissionStatusIcons() {
        XCTAssertEqual(PermissionStatus.granted.icon, "checkmark.circle.fill")
        XCTAssertEqual(PermissionStatus.denied.icon, "xmark.circle.fill")
        XCTAssertEqual(PermissionStatus.restricted.icon, "xmark.circle.fill")
        XCTAssertEqual(PermissionStatus.notDetermined.icon, "questionmark.circle.fill")
    }
    
    func testCoreLocationStatusConversion() {
        XCTAssertEqual(PermissionStatus.from(clStatus: .notDetermined), .notDetermined)
        XCTAssertEqual(PermissionStatus.from(clStatus: .authorizedWhenInUse), .granted)
        XCTAssertEqual(PermissionStatus.from(clStatus: .authorizedAlways), .granted)
        XCTAssertEqual(PermissionStatus.from(clStatus: .denied), .denied)
        XCTAssertEqual(PermissionStatus.from(clStatus: .restricted), .restricted)
    }
}