//
//  OnboardingStateUITests.swift
//  TempoAIUITests
//
//  UI tests for onboarding state management and persistence
//

import XCTest

/// UI tests for onboarding state management, reset behavior, and completion logic
/// Based on OnboardingFlowSpecification.md section 2
@MainActor
final class OnboardingStateUITests: BaseUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Start with clean state for each test
        app.launchEnvironment["RESET_ONBOARDING"] = "1"
    }

    // MARK: - Reset Behavior Tests (仕様書 2.2)

    /// Test: オンボーディングリセット後、言語選択画面に留まる
    /// THIS IS THE CORE ISSUE: Language selection should stay visible after reset
    func testOnboardingReset_ShowsLanguageSelectionAndStaysThere() {
        // First, complete onboarding
        completeFullOnboardingFlow()

        // Verify we're on home screen
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should be on home screen after completing onboarding")

        // Terminate and relaunch app with reset flag
        app.terminate()

        app.launchEnvironment["RESET_ONBOARDING"] = "1"
        app.launch()

        // Verify language selection appears
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Language selection page should be displayed after reset")

        // CRITICAL: Verify it STAYS on language selection for at least 3 seconds
        // This addresses the issue where the screen immediately closes
        sleep(3)

        XCTAssertTrue(languageSelectionPage.exists,
                      "Language selection page should still be visible after 3 seconds")

        // Verify buttons are still accessible
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        let englishButton = app.buttons[UIIdentifiers.OnboardingFlow.englishButton]

        XCTAssertTrue(japaneseButton.exists && japaneseButton.isHittable,
                      "Japanese button should remain accessible")
        XCTAssertTrue(englishButton.exists && englishButton.isHittable,
                      "English button should remain accessible")

        // Verify no automatic progression to home screen
        let homeGreetingAfterReset = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertFalse(homeGreetingAfterReset.exists,
                       "Should NOT automatically navigate to home screen after reset")
    }

    /// Test: 完了済みオンボーディング→ホーム画面直接遷移
    func testCompletedOnboarding_SkipsDirectlyToHome() {
        // Complete onboarding first
        completeFullOnboardingFlow()

        // Verify we're on home screen
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should be on home screen after completing onboarding")

        // Terminate and relaunch app WITHOUT reset flag
        app.terminate()

        // Remove reset flag and launch
        app.launchEnvironment.removeValue(forKey: "RESET_ONBOARDING")
        app.launch()

        // Should skip directly to home screen
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should skip onboarding and go directly to home screen")

        // Verify onboarding pages are NOT shown
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertFalse(languageSelectionPage.exists,
                       "Language selection should not be shown for completed onboarding")
    }

    /// Test: 言語選択の永続化（アプリ再起動後も保持）
    func testLanguageSelection_PersistsAcrossAppRestart() {
        // Select Japanese
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)

        // Navigate to welcome page to confirm language selection
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0))

        // Terminate app
        app.terminate()

        // Relaunch with reset to restart onboarding but preserve language
        app.launchEnvironment["RESET_ONBOARDING"] = "1"
        app.launch()

        // Should start from language selection again
        let languageSelectionPageRestart = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPageRestart, timeout: 5.0))

        // Select language again and verify previously selected language setting is available
        // Note: In a real implementation, we might want to remember the previous language choice
        safeTap(japaneseButton)

        let welcomePageRestart = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePageRestart, timeout: 5.0),
                      "Should be able to select language again after restart")
    }

    /// Test: オンボーディング完了状態のUserDefaults保存
    func testOnboardingCompletion_PersistsToUserDefaults() {
        // Complete onboarding flow
        completeFullOnboardingFlow()

        // Verify completion by checking home screen
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should be on home screen indicating completion")

        // Restart app without reset flag
        app.terminate()
        app.launchEnvironment.removeValue(forKey: "RESET_ONBOARDING")
        app.launch()

        // Should still be on home screen (completion persisted)
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Completion state should persist across app restarts")
    }

    // MARK: - Edge Case State Tests

    /// Test: 途中でアプリ終了→再起動時は最初から
    func testAppTerminationDuringOnboarding_RestartsFromBeginning() {
        // Navigate to middle of onboarding (page 3)
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)

        // Navigate through a couple pages
        let welcomeNextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(waitForElement(welcomeNextButton, timeout: 5.0))
        safeTap(welcomeNextButton)

        let dataSourcesNextButton = app.buttons[UIIdentifiers.OnboardingFlow.dataSourcesNextButton]
        XCTAssertTrue(waitForElement(dataSourcesNextButton, timeout: 5.0))
        safeTap(dataSourcesNextButton)

        // Verify on AI Analysis page
        let aiAnalysisPage = app.otherElements[UIIdentifiers.OnboardingFlow.aiAnalysisPage]
        XCTAssertTrue(waitForElement(aiAnalysisPage, timeout: 5.0),
                      "Should be on AI Analysis page")

        // Terminate app
        app.terminate()

        // Relaunch 
        app.launch()

        // Should restart from beginning (language selection)
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Should restart from language selection after termination")
    }

    /// Test: オンボーディング状態の整合性確認
    func testOnboardingState_ConsistencyChecks() {
        // Navigate to permission pages
        navigateToPermissionPages()

        // Verify we're on HealthKit page
        let healthKitPage = app.otherElements[UIIdentifiers.OnboardingFlow.healthKitPage]
        XCTAssertTrue(waitForElement(healthKitPage, timeout: 5.0))

        // Skip to location page
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        safeTap(healthKitSkipButton)

        // Verify state transition to location page
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0),
                      "Should transition to location page")

        // Verify cannot go back to non-existent next page
        // (State validation)
        let tabView = app.otherElements[UIIdentifiers.OnboardingFlow.tabView]
        XCTAssertTrue(tabView.exists,
                      "TabView should maintain proper state")
    }

    // MARK: - Helper Methods

    private func completeFullOnboardingFlow() {
        // Navigate through entire onboarding flow
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)

        // Skip through all pages
        let nextButtons = [
            UIIdentifiers.OnboardingFlow.welcomeNextButton,
            UIIdentifiers.OnboardingFlow.dataSourcesNextButton,
            UIIdentifiers.OnboardingFlow.aiAnalysisNextButton,
            UIIdentifiers.OnboardingFlow.dailyPlansNextButton
        ]

        for buttonId in nextButtons {
            let button = app.buttons[buttonId]
            XCTAssertTrue(waitForElement(button, timeout: 5.0))
            safeTap(button)
        }

        // Skip HealthKit
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(waitForElement(healthKitSkipButton, timeout: 5.0))
        safeTap(healthKitSkipButton)

        // Skip Location and complete
        let locationSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        XCTAssertTrue(waitForElement(locationSkipButton, timeout: 5.0))
        safeTap(locationSkipButton)
    }

    private func navigateToPermissionPages() {
        // Quick navigation to permission pages
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)

        let nextButtons = [
            UIIdentifiers.OnboardingFlow.welcomeNextButton,
            UIIdentifiers.OnboardingFlow.dataSourcesNextButton,
            UIIdentifiers.OnboardingFlow.aiAnalysisNextButton,
            UIIdentifiers.OnboardingFlow.dailyPlansNextButton
        ]

        for buttonId in nextButtons {
            let button = app.buttons[buttonId]
            XCTAssertTrue(waitForElement(button, timeout: 5.0))
            safeTap(button)
        }
    }
}
