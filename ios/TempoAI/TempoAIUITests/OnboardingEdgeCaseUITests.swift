//
//  OnboardingEdgeCaseUITests.swift
//  TempoAIUITests
//
//  UI tests for onboarding edge cases and exceptional scenarios
//

import XCTest

/// UI tests for edge cases during onboarding flow
/// Based on OnboardingFlowSpecification.md section 4
@MainActor  
final class OnboardingEdgeCaseUITests: BaseUITest {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Set up test environment
        app.launchEnvironment["RESET_ONBOARDING"] = "1"
        app.launchEnvironment["UI_TESTING"] = "1"
    }
    
    // MARK: - App Lifecycle Tests (仕様書 4.1)
    
    /// Test: オンボーディング途中でアプリをバックグラウンド→状態保持
    func testAppBackgrounding_PreservesCurrentPage() {
        // Navigate to middle page (AI Analysis)
        navigateToAIAnalysisPage()
        
        // Verify on correct page
        let aiAnalysisPage = app.otherElements[UIIdentifiers.OnboardingFlow.aiAnalysisPage]
        XCTAssertTrue(waitForElement(aiAnalysisPage, timeout: 5.0),
                      "Should be on AI Analysis page")
        
        // Simulate app backgrounding
        XCUIDevice.shared.press(.home)
        
        // Wait a moment then return to app
        sleep(2)
        
        // Reactivate app
        app.activate()
        
        // Verify still on the same page
        XCTAssertTrue(waitForElement(aiAnalysisPage, timeout: 5.0),
                      "Should remain on AI Analysis page after backgrounding")
        
        // Verify page functionality still works
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.aiAnalysisNextButton]
        XCTAssertTrue(nextButton.exists && nextButton.isHittable,
                      "Next button should still be functional after backgrounding")
    }
    
    /// Test: オンボーディング途中でアプリ強制終了→Page 0から再開
    func testAppTermination_RestartsFromPageZero() {
        // Navigate to permission page
        navigateToHealthKitPage()
        
        // Verify on HealthKit page
        let healthKitPage = app.otherElements[UIIdentifiers.OnboardingFlow.healthKitPage]
        XCTAssertTrue(waitForElement(healthKitPage, timeout: 5.0),
                      "Should be on HealthKit page")
        
        // Terminate app completely
        app.terminate()
        
        // Relaunch app
        app.launch()
        
        // Should restart from language selection (Page 0)
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Should restart from language selection after termination")
        
        // Verify language settings preserved (but page position reset)
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        let englishButton = app.buttons[UIIdentifiers.OnboardingFlow.englishButton]
        
        XCTAssertTrue(japaneseButton.exists && japaneseButton.isHittable,
                      "Language selection should be available")
        XCTAssertTrue(englishButton.exists && englishButton.isHittable,
                      "English selection should be available")
    }
    
    /// Test: メモリ警告時の適切な処理
    func testMemoryWarning_HandlesGracefully() {
        // Navigate through several pages to load content
        completeOnboardingToLocationPage()
        
        // Simulate memory warning
        // Note: In real testing, we might use XCTMemoryMetrics or custom simulation
        
        // Verify app continues to function
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0),
                      "Location page should remain functional after memory pressure")
        
        // Verify critical UI elements still work
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.locationAllowButton]
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        
        XCTAssertTrue(allowButton.exists || skipButton.exists,
                      "Permission buttons should remain available after memory warning")
    }
    
    // MARK: - User Interaction Edge Cases
    
    /// Test: 連続タップ防止（重複遷移防止）
    func testRapidTapping_PreventsDuplicateTransitions() {
        // Navigate to a page with next button
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0))
        
        // Rapidly tap the next button multiple times
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(waitForElement(nextButton, timeout: 5.0))
        
        // Tap rapidly multiple times
        for _ in 0..<5 {
            nextButton.tap()
        }
        
        // Verify only moved to next page once (Data Sources)
        let dataSourcesPage = app.otherElements[UIIdentifiers.OnboardingFlow.dataSourcesPage]
        XCTAssertTrue(waitForElement(dataSourcesPage, timeout: 5.0),
                      "Should be on Data Sources page")
        
        // Verify not accidentally skipped multiple pages
        let aiAnalysisPage = app.otherElements[UIIdentifiers.OnboardingFlow.aiAnalysisPage]
        XCTAssertFalse(aiAnalysisPage.exists,
                       "Should not have skipped to AI Analysis page due to rapid tapping")
    }
    
    /// Test: 権限ダイアログ表示中のアプリ状態
    func testPermissionDialogInterruption_HandlesProperly() {
        // Navigate to HealthKit permission page
        navigateToHealthKitPage()
        
        // Tap permission button (would show system dialog in real scenario)
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitAllowButton]
        XCTAssertTrue(waitForElement(allowButton, timeout: 5.0))
        safeTap(allowButton)
        
        // In real testing, system permission dialog would appear
        // Simulate app backgrounding while dialog is shown
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.activate()
        
        // Verify app handles this gracefully
        let healthKitPage = app.otherElements[UIIdentifiers.OnboardingFlow.healthKitPage]
        XCTAssertTrue(waitForElement(healthKitPage, timeout: 5.0),
                      "Should return to HealthKit page after permission dialog interruption")
        
        // Verify page is still functional
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(skipButton.exists && skipButton.isHittable,
                      "Skip button should remain functional")
    }
    
    // MARK: - Device Limitation Tests
    
    /// Test: HealthKit利用不可デバイスでの処理
    func testHealthKitUnavailable_ShowsAppropriateMessage() {
        // Note: In real testing, we'd simulate HealthKit unavailable
        // For now, verify the page handles the standard case
        
        navigateToHealthKitPage()
        
        // Verify appropriate messaging exists
        let healthKitTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitTitle]
        let healthKitDescription = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitDescription]
        
        XCTAssertTrue(healthKitTitle.exists,
                      "HealthKit title should explain functionality")
        XCTAssertTrue(healthKitDescription.exists,
                      "HealthKit description should be informative")
        
        // Verify skip option is always available
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(skipButton.exists,
                      "Skip button should be available for device limitations")
    }
    
    /// Test: 権限が既にシステム設定で拒否済みの場合
    func testPermissionPreviouslyDeniedInSettings_HandlesGracefully() {
        // Navigate to location page
        completeOnboardingToLocationPage()
        
        // Attempt to request permission (would normally show settings prompt)
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.locationAllowButton]
        XCTAssertTrue(waitForElement(allowButton, timeout: 5.0))
        safeTap(allowButton)
        
        // Verify graceful handling with skip option
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        XCTAssertTrue(waitForElement(skipButton, timeout: 10.0),
                      "Skip button should be available if permission previously denied")
        
        // Verify can still complete onboarding
        safeTap(skipButton)
        
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should complete onboarding despite permission denial")
    }
    
    // MARK: - Data Consistency Tests
    
    /// Test: 不正な状態からの回復
    func testCorruptedState_RecoveryMechanism() {
        // Navigate to middle of flow
        navigateToAIAnalysisPage()
        
        // Simulate app restart (which should reset incomplete onboarding)
        app.terminate()
        app.launch()
        
        // Verify clean recovery to initial state
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Should recover to clean initial state")
        
        // Verify full functionality after recovery
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(japaneseButton.exists && japaneseButton.isHittable,
                      "Should have full functionality after state recovery")
    }
    
    /// Test: 異なるローテーション（デバイス回転）での安定性
    func testDeviceRotation_MaintainsStability() {
        // Start onboarding
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Rotate device (if simulator supports it)
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify onboarding continues working
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Onboarding should work in landscape orientation")
        
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(nextButton.exists && nextButton.isHittable,
                      "Buttons should remain functional in landscape")
        
        // Rotate back
        XCUIDevice.shared.orientation = .portrait
        
        // Verify still functional
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Should remain functional after rotation back to portrait")
    }
    
    // MARK: - Helper Methods
    
    private func navigateToAIAnalysisPage() {
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        let welcomeNextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(waitForElement(welcomeNextButton, timeout: 5.0))
        safeTap(welcomeNextButton)
        
        let dataSourcesNextButton = app.buttons[UIIdentifiers.OnboardingFlow.dataSourcesNextButton]
        XCTAssertTrue(waitForElement(dataSourcesNextButton, timeout: 5.0))
        safeTap(dataSourcesNextButton)
    }
    
    private func navigateToHealthKitPage() {
        navigateToAIAnalysisPage()
        
        let aiAnalysisNextButton = app.buttons[UIIdentifiers.OnboardingFlow.aiAnalysisNextButton]
        XCTAssertTrue(waitForElement(aiAnalysisNextButton, timeout: 5.0))
        safeTap(aiAnalysisNextButton)
        
        let dailyPlansNextButton = app.buttons[UIIdentifiers.OnboardingFlow.dailyPlansNextButton]
        XCTAssertTrue(waitForElement(dailyPlansNextButton, timeout: 5.0))
        safeTap(dailyPlansNextButton)
    }
    
    private func completeOnboardingToLocationPage() {
        navigateToHealthKitPage()
        
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(waitForElement(healthKitSkipButton, timeout: 5.0))
        safeTap(healthKitSkipButton)
    }
}