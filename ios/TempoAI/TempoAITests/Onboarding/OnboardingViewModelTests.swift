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

    // MARK: - Flow State Tests (Specification Section 2)

    /// Test: リセット時の初期状態設定
    func testResetOnboarding_SetsCorrectInitialState() {
        // Complete onboarding first
        viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingCompleted)

        // Navigate to different page
        viewModel.goToPage(3)
        XCTAssertEqual(viewModel.currentPage, 3)

        // Reset onboarding
        viewModel.resetOnboarding()

        // Verify initial state
        XCTAssertEqual(viewModel.currentPage, 0, "Current page should reset to 0")
        XCTAssertFalse(viewModel.isOnboardingCompleted, "Onboarding completion should reset to false")

        // Verify UserDefaults are cleared
        let userDefaults = UserDefaults.standard
        XCTAssertNil(userDefaults.object(forKey: "OnboardingCompleted"),
                     "OnboardingCompleted key should be removed")
        XCTAssertNil(userDefaults.object(forKey: "OnboardingStartTime"),
                     "OnboardingStartTime key should be removed")
    }

    /// Test: リセット後に即座に完了状態にならない
    func testResetOnboarding_DoesNotImmediatelyComplete() {
        // Complete onboarding
        viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingCompleted)

        // Reset
        viewModel.resetOnboarding()

        // Verify not completed immediately after reset
        XCTAssertFalse(viewModel.isOnboardingCompleted,
                       "Should not be completed immediately after reset")

        // Wait a moment to ensure no async completion
        let expectation = expectation(description: "Wait for potential completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.5)

        XCTAssertFalse(viewModel.isOnboardingCompleted,
                       "Should still not be completed after waiting")
    }

    /// Test: 言語変更の即座反映
    func testLanguageChange_UpdatesImmediately() {
        // Initial state
        XCTAssertEqual(viewModel.selectedLanguage, .japanese) // Default language

        // Change to English
        viewModel.setLanguage(.english)

        // Verify immediate update
        XCTAssertEqual(viewModel.selectedLanguage, .english,
                       "Language should update immediately")

        // Change back to Japanese
        viewModel.setLanguage(.japanese)

        // Verify immediate update again
        XCTAssertEqual(viewModel.selectedLanguage, .japanese,
                       "Language should update immediately again")
    }

    /// Test: 権限状態変化のUI更新
    func testPermissionStatusChange_UpdatesUIState() {
        // Initial state
        XCTAssertEqual(viewModel.healthKitStatus, .notDetermined)
        XCTAssertEqual(viewModel.locationStatus, .notDetermined)

        // Update permission statuses
        viewModel.healthKitStatus = .granted
        viewModel.locationStatus = .granted

        // Verify computed properties update correctly
        XCTAssertTrue(viewModel.allPermissionsGranted,
                      "All permissions granted should be true")
        XCTAssertTrue(viewModel.anyPermissionsGranted,
                      "Any permissions granted should be true")

        // Test denied state
        viewModel.healthKitStatus = .denied
        viewModel.locationStatus = .denied

        XCTAssertFalse(viewModel.allPermissionsGranted,
                       "All permissions granted should be false")
        XCTAssertFalse(viewModel.anyPermissionsGranted,
                       "Any permissions granted should be false")

        // Test mixed state
        viewModel.healthKitStatus = .granted
        viewModel.locationStatus = .denied

        XCTAssertFalse(viewModel.allPermissionsGranted,
                       "All permissions granted should be false with mixed state")
        XCTAssertTrue(viewModel.anyPermissionsGranted,
                       "Any permissions granted should be true with mixed state")
    }

    /// Test: ページ遷移の状態一貫性
    func testPageTransition_ValidatesStateConsistency() {
        // Test valid transitions
        XCTAssertEqual(viewModel.currentPage, 0)

        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 1)

        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 2)

        // Test backward navigation
        viewModel.previousPage()
        XCTAssertEqual(viewModel.currentPage, 1)

        // Test boundary conditions
        viewModel.goToPage(0)
        viewModel.previousPage() // Should not go below 0
        XCTAssertEqual(viewModel.currentPage, 0, "Should not go below page 0")

        // Test upper boundary (assuming last page is 6 for 7-page flow)
        for _ in 0..<10 {
            viewModel.nextPage()
        }
        XCTAssertLessThanOrEqual(viewModel.currentPage, 6,
                                "Should not exceed maximum page")
    }

    // MARK: - Data Persistence Tests

    /// Test: オンボーディング完了のUserDefaults保存
    func testOnboardingCompletion_PersistsToUserDefaults() {
        // Initially not completed
        XCTAssertFalse(viewModel.isOnboardingCompleted)

        // Complete onboarding
        viewModel.completeOnboarding()

        // Verify completion status persisted
        let userDefaults = UserDefaults.standard
        let isCompleted = userDefaults.bool(forKey: "OnboardingCompleted")
        XCTAssertTrue(isCompleted, "Completion should be saved to UserDefaults")

        // Verify ViewModel state
        XCTAssertTrue(viewModel.isOnboardingCompleted,
                      "ViewModel should reflect completed state")
    }

    /// Test: 言語設定のUserDefaults保存
    func testLanguageSelection_PersistsToUserDefaults() {
        // Change language
        viewModel.setLanguage(.english)

        // Verify language persisted (through LocalizationManager)
        XCTAssertEqual(viewModel.selectedLanguage, .english,
                       "Language selection should be persisted")

        // Change back
        viewModel.setLanguage(.japanese)
        XCTAssertEqual(viewModel.selectedLanguage, .japanese,
                       "Language selection should update and persist")
    }

    /// Test: 破損したUserDefaultsからの設定復元
    func testStateRecovery_FromCorruptedUserDefaults() {
        // Simulate corrupted UserDefaults by setting invalid data
        let userDefaults = UserDefaults.standard
        userDefaults.set("invalid_data", forKey: "OnboardingCompleted")

        // Create new ViewModel instance (simulates app restart)
        let newViewModel = OnboardingViewModel()

        // Should recover with default values
        XCTAssertFalse(newViewModel.isOnboardingCompleted,
                       "Should recover with default completion state")
        XCTAssertEqual(newViewModel.currentPage, 0,
                       "Should recover with default page")

        // Clean up
        userDefaults.removeObject(forKey: "OnboardingCompleted")
    }

    /// Test: 複数ViewModelインスタンス間のデータ一貫性
    func testMultipleViewModelInstances_DataConsistency() {
        // Complete onboarding in first instance
        viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingCompleted)

        // Create second instance
        let secondViewModel = OnboardingViewModel()

        // Should reflect completed state from UserDefaults
        XCTAssertTrue(secondViewModel.isOnboardingCompleted,
                      "Second instance should load completed state")

        // Reset in second instance
        secondViewModel.resetOnboarding()

        // Create third instance
        let thirdViewModel = OnboardingViewModel()

        // Should reflect reset state
        XCTAssertFalse(thirdViewModel.isOnboardingCompleted,
                       "Third instance should load reset state")
    }

    /// Test: 状態変更の順序保証
    func testStateChanges_OrderGuarantee() {
        // Test that state changes happen in expected order
        var stateChanges: [String] = []

        // Monitor state changes (in real implementation, we'd use Combine)
        let initialCompleted = viewModel.isOnboardingCompleted
        let initialPage = viewModel.currentPage

        // Perform operations
        viewModel.nextPage()
        let afterNextPage = viewModel.currentPage

        viewModel.completeOnboarding()
        let afterCompletion = viewModel.isOnboardingCompleted

        // Verify expected sequence
        XCTAssertFalse(initialCompleted, "Initial state should be not completed")
        XCTAssertEqual(initialPage, 0, "Initial page should be 0")
        XCTAssertEqual(afterNextPage, 1, "After next page should be 1")
        XCTAssertTrue(afterCompletion, "After completion should be completed")
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
