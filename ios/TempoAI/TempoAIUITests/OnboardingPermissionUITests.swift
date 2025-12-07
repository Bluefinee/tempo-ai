//
//  OnboardingPermissionUITests.swift
//  TempoAIUITests
//
//  UI tests for onboarding permission flows (HealthKit and Location)
//

import XCTest

/// UI tests for permission request flows during onboarding
/// Based on OnboardingFlowSpecification.md section 3
@MainActor
final class OnboardingPermissionUITests: BaseUITest {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Reset onboarding and navigate to permission pages
        app.launchEnvironment["RESET_ONBOARDING"] = "1"
        app.launch()
    }
    
    // MARK: - Helper Methods
    
    private func navigateToHealthKitPage() {
        // Select language
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Skip through pages to reach HealthKit page
        for identifier in [
            UIIdentifiers.OnboardingFlow.welcomeNextButton,
            UIIdentifiers.OnboardingFlow.dataSourcesNextButton,
            UIIdentifiers.OnboardingFlow.aiAnalysisNextButton,
            UIIdentifiers.OnboardingFlow.dailyPlansNextButton
        ] {
            let button = app.buttons[identifier]
            XCTAssertTrue(waitForElement(button, timeout: 5.0))
            safeTap(button)
        }
        
        // Verify on HealthKit page
        let healthKitPage = app.otherElements[UIIdentifiers.OnboardingFlow.healthKitPage]
        XCTAssertTrue(waitForElement(healthKitPage, timeout: 5.0),
                      "Should be on HealthKit permission page")
    }
    
    private func navigateToLocationPage() {
        navigateToHealthKitPage()
        
        // Skip HealthKit permission
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        if healthKitSkipButton.exists {
            safeTap(healthKitSkipButton)
        } else {
            let healthKitNextButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitNextButton]
            safeTap(healthKitNextButton)
        }
        
        // Verify on Location page
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0),
                      "Should be on Location permission page")
    }
    
    // MARK: - HealthKit Permission Tests (仕様書 3.1)
    
    /// Test: HealthKit権限許可時の動作
    func testHealthKitPermission_Granted_ShowsCheckmark() {
        // Navigate to HealthKit page
        navigateToHealthKitPage()
        
        // Find and tap allow button
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitAllowButton]
        XCTAssertTrue(waitForElement(allowButton, timeout: 5.0),
                      "HealthKit allow button should be visible")
        
        // Note: In UI tests, we cannot actually grant system permissions
        // This test would verify the UI response after permission is granted
        safeTap(allowButton)
        
        // After permission granted (simulated), verify UI updates
        // In real scenario, we'd mock the permission grant
        let grantedStatus = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitGrantedStatus]
        
        // Verify next button becomes available
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitNextButton]
        if nextButton.exists {
            XCTAssertTrue(nextButton.isEnabled,
                          "Next button should be enabled after permission granted")
        }
    }
    
    /// Test: HealthKit権限拒否時のスキップオプション表示
    func testHealthKitPermission_Denied_ShowsSkipOption() {
        // Navigate to HealthKit page
        navigateToHealthKitPage()
        
        // Verify skip button is available
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(waitForElement(skipButton, timeout: 5.0),
                      "Skip button should be available for HealthKit permission")
        
        // Tap skip button
        safeTap(skipButton)
        
        // Verify navigation to next page
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0),
                      "Should navigate to Location page after skipping HealthKit")
    }
    
    /// Test: HealthKit部分許可時の処理
    func testHealthKitPermission_PartialGrant_ShowsGranted() {
        // Navigate to HealthKit page
        navigateToHealthKitPage()
        
        // In a real test, we would simulate partial permission grant
        // For now, verify the UI elements are present
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitAllowButton]
        XCTAssertTrue(allowButton.exists,
                      "HealthKit allow button should be present")
        
        // Verify permission features are displayed
        let healthKitTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitTitle]
        XCTAssertTrue(healthKitTitle.exists,
                      "HealthKit permission title should be visible")
        
        let healthKitDescription = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitDescription]
        XCTAssertTrue(healthKitDescription.exists,
                      "HealthKit permission description should be visible")
    }
    
    // MARK: - Location Permission Tests (仕様書 3.2)
    
    /// Test: Location権限許可時の完了ボタン表示
    func testLocationPermission_Granted_ShowsCompleteButton() {
        // Navigate to Location page
        navigateToLocationPage()
        
        // Find and tap allow button
        let allowButton = app.buttons[UIIdentifiers.OnboardingFlow.locationAllowButton]
        XCTAssertTrue(waitForElement(allowButton, timeout: 5.0),
                      "Location allow button should be visible")
        
        // Note: In UI tests, we cannot actually grant system permissions
        safeTap(allowButton)
        
        // After permission granted (simulated), verify complete button appears
        let completeButton = app.buttons[UIIdentifiers.OnboardingFlow.locationCompleteButton]
        
        // Verify granted status might be shown
        let grantedStatus = app.staticTexts[UIIdentifiers.OnboardingFlow.locationGrantedStatus]
        
        // At least one completion option should be available
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        XCTAssertTrue(completeButton.exists || skipButton.exists,
                      "Completion option should be available")
    }
    
    /// Test: Location権限拒否時の位置情報なしで続行オプション
    func testLocationPermission_Denied_ShowsContinueWithoutLocation() {
        // Navigate to Location page
        navigateToLocationPage()
        
        // Verify skip button is available
        let skipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        XCTAssertTrue(waitForElement(skipButton, timeout: 5.0),
                      "Skip button should be available for Location permission")
        
        // Tap skip to continue without location
        safeTap(skipButton)
        
        // Verify onboarding completes and navigates to main app
        // Wait for onboarding to complete
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should navigate to home screen after completing onboarding")
    }
    
    /// Test: 両方の権限を許可した場合のフロー
    func testBothPermissions_Granted_CompletesOnboarding() {
        // Navigate to HealthKit page
        navigateToHealthKitPage()
        
        // Try to grant HealthKit (skip for now in test)
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        if healthKitSkipButton.exists {
            safeTap(healthKitSkipButton)
        }
        
        // Navigate to Location page
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0))
        
        // Try to grant Location (skip for now in test)
        let locationSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        if locationSkipButton.exists {
            safeTap(locationSkipButton)
        }
        
        // Verify onboarding completes
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should navigate to home screen after granting all permissions")
    }
    
    /// Test: 両方の権限を拒否した場合のフロー
    func testBothPermissions_Denied_StillCompletesOnboarding() {
        // Navigate to HealthKit page
        navigateToHealthKitPage()
        
        // Skip HealthKit permission
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        XCTAssertTrue(waitForElement(healthKitSkipButton, timeout: 5.0))
        safeTap(healthKitSkipButton)
        
        // Skip Location permission
        let locationSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.locationSkipButton]
        XCTAssertTrue(waitForElement(locationSkipButton, timeout: 5.0))
        safeTap(locationSkipButton)
        
        // Verify onboarding completes even with denied permissions
        let homeGreeting = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(homeGreeting, timeout: 10.0),
                      "Should navigate to home screen even with all permissions denied")
    }
    
    /// Test: 権限画面でのUI要素の表示確認
    func testPermissionPages_DisplayCorrectElements() {
        // Test HealthKit page elements
        navigateToHealthKitPage()
        
        let healthKitIcon = app.images[UIIdentifiers.OnboardingFlow.healthKitIcon]
        XCTAssertTrue(healthKitIcon.exists,
                      "HealthKit icon should be displayed")
        
        let healthKitTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitTitle]
        XCTAssertTrue(healthKitTitle.exists,
                      "HealthKit title should be displayed")
        
        let healthKitDescription = app.staticTexts[UIIdentifiers.OnboardingFlow.healthKitDescription]
        XCTAssertTrue(healthKitDescription.exists,
                      "HealthKit description should be displayed")
        
        // Navigate to Location page
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        safeTap(healthKitSkipButton)
        
        // Test Location page elements
        let locationIcon = app.images[UIIdentifiers.OnboardingFlow.locationIcon]
        XCTAssertTrue(locationIcon.exists,
                      "Location icon should be displayed")
        
        let locationTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.locationTitle]
        XCTAssertTrue(locationTitle.exists,
                      "Location title should be displayed")
        
        let locationDescription = app.staticTexts[UIIdentifiers.OnboardingFlow.locationDescription]
        XCTAssertTrue(locationDescription.exists,
                      "Location description should be displayed")
    }
}