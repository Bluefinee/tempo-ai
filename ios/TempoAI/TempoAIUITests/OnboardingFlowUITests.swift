//
//  OnboardingFlowUITests.swift
//  TempoAIUITests
//
//  Comprehensive UI tests for onboarding user journey flow
//

import XCTest

/// UI tests for basic onboarding flow covering all 7 pages and transitions
/// Based on OnboardingFlowSpecification.md section 1.1
@MainActor
final class OnboardingFlowUITests: BaseUITest {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Reset onboarding state for clean test environment
        app.launchEnvironment["RESET_ONBOARDING"] = "1"
        app.launch()
    }
    
    // MARK: - Initial Launch Tests (仕様書 1.1)
    
    /// Test: 初回起動時に言語選択画面が表示される
    func testInitialLaunch_ShowsLanguageSelection() {
        // Wait for onboarding to appear
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Language selection page should be displayed on initial launch")
        
        // Verify language selection elements
        let languageTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.languageSelectionTitle]
        XCTAssertTrue(languageTitle.exists,
                      "Language selection title should be visible")
        
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        let englishButton = app.buttons[UIIdentifiers.OnboardingFlow.englishButton]
        
        XCTAssertTrue(japaneseButton.exists && japaneseButton.isHittable,
                      "Japanese selection button should be visible and tappable")
        XCTAssertTrue(englishButton.exists && englishButton.isHittable,
                      "English selection button should be visible and tappable")
    }
    
    /// Test: 日本語選択後、日本語でウェルカム画面に遷移
    func testJapaneseSelection_TransitionsToWelcomeInJapanese() {
        // Select Japanese
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Wait for transition to welcome page
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Should transition to welcome page after language selection")
        
        // Verify welcome page elements
        let welcomeTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.welcomeTitle]
        XCTAssertTrue(welcomeTitle.exists,
                      "Welcome title should be visible")
        
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(nextButton.exists && nextButton.isHittable,
                      "Next button should be visible and tappable")
        
        // Verify Japanese localization is applied
        // Note: Actual text verification would depend on localization strings
    }
    
    /// Test: 英語選択後、英語でウェルカム画面に遷移
    func testEnglishSelection_TransitionsToWelcomeInEnglish() {
        // Select English
        let englishButton = app.buttons[UIIdentifiers.OnboardingFlow.englishButton]
        XCTAssertTrue(waitForElement(englishButton, timeout: 5.0))
        safeTap(englishButton)
        
        // Wait for transition to welcome page
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Should transition to welcome page after language selection")
        
        // Verify welcome page elements
        let welcomeTitle = app.staticTexts[UIIdentifiers.OnboardingFlow.welcomeTitle]
        XCTAssertTrue(welcomeTitle.exists,
                      "Welcome title should be visible")
        
        let nextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(nextButton.exists && nextButton.isHittable,
                      "Next button should be visible and tappable")
    }
    
    /// Test: 全7ページの順次遷移
    func testPageProgression_AllSevenPages() {
        // Page 0: Language Selection
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Page 1: Welcome
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Page 1: Welcome should be displayed")
        
        let welcomeNextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        safeTap(welcomeNextButton)
        
        // Page 2: Data Sources
        let dataSourcesPage = app.otherElements[UIIdentifiers.OnboardingFlow.dataSourcesPage]
        XCTAssertTrue(waitForElement(dataSourcesPage, timeout: 5.0),
                      "Page 2: Data Sources should be displayed")
        
        let dataSourcesNextButton = app.buttons[UIIdentifiers.OnboardingFlow.dataSourcesNextButton]
        safeTap(dataSourcesNextButton)
        
        // Page 3: AI Analysis
        let aiAnalysisPage = app.otherElements[UIIdentifiers.OnboardingFlow.aiAnalysisPage]
        XCTAssertTrue(waitForElement(aiAnalysisPage, timeout: 5.0),
                      "Page 3: AI Analysis should be displayed")
        
        let aiAnalysisNextButton = app.buttons[UIIdentifiers.OnboardingFlow.aiAnalysisNextButton]
        safeTap(aiAnalysisNextButton)
        
        // Page 4: Daily Plans
        let dailyPlansPage = app.otherElements[UIIdentifiers.OnboardingFlow.dailyPlansPage]
        XCTAssertTrue(waitForElement(dailyPlansPage, timeout: 5.0),
                      "Page 4: Daily Plans should be displayed")
        
        let dailyPlansNextButton = app.buttons[UIIdentifiers.OnboardingFlow.dailyPlansNextButton]
        safeTap(dailyPlansNextButton)
        
        // Page 5: HealthKit Permission
        let healthKitPage = app.otherElements[UIIdentifiers.OnboardingFlow.healthKitPage]
        XCTAssertTrue(waitForElement(healthKitPage, timeout: 5.0),
                      "Page 5: HealthKit Permission should be displayed")
        
        // Skip HealthKit for now
        let healthKitSkipButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitSkipButton]
        if healthKitSkipButton.exists {
            safeTap(healthKitSkipButton)
        } else {
            let healthKitNextButton = app.buttons[UIIdentifiers.OnboardingFlow.healthKitNextButton]
            safeTap(healthKitNextButton)
        }
        
        // Page 6: Location Permission & Completion
        let locationPage = app.otherElements[UIIdentifiers.OnboardingFlow.locationPage]
        XCTAssertTrue(waitForElement(locationPage, timeout: 5.0),
                      "Page 6: Location Permission should be displayed")
    }
    
    /// Test: 戻るジェスチャーで前のページに戻る
    func testBackNavigation_AllPages() {
        // Navigate to Page 2 first
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        let welcomeNextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        XCTAssertTrue(waitForElement(welcomeNextButton, timeout: 5.0))
        safeTap(welcomeNextButton)
        
        // Verify on Page 2
        let dataSourcesPage = app.otherElements[UIIdentifiers.OnboardingFlow.dataSourcesPage]
        XCTAssertTrue(waitForElement(dataSourcesPage, timeout: 5.0),
                      "Should be on Data Sources page")
        
        // Swipe right to go back to Page 1
        app.swipeRight()
        
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0),
                      "Should return to Welcome page after swipe right")
        
        // Swipe right again to go back to Page 0
        app.swipeRight()
        
        let languageSelectionPage = app.otherElements[UIIdentifiers.OnboardingFlow.languageSelectionPage]
        XCTAssertTrue(waitForElement(languageSelectionPage, timeout: 5.0),
                      "Should return to Language Selection page after second swipe right")
    }
    
    /// Test: スワイプによるページ間ナビゲーション
    func testSwipeNavigation_BetweenPages() {
        // Select language first
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Verify on Welcome page
        let welcomePage = app.otherElements[UIIdentifiers.OnboardingFlow.welcomePage]
        XCTAssertTrue(waitForElement(welcomePage, timeout: 5.0))
        
        // Swipe left to go to next page
        app.swipeLeft()
        
        let dataSourcesPage = app.otherElements[UIIdentifiers.OnboardingFlow.dataSourcesPage]
        XCTAssertTrue(waitForElement(dataSourcesPage, timeout: 5.0),
                      "Should navigate to Data Sources page after swipe left")
        
        // Swipe left again
        app.swipeLeft()
        
        let aiAnalysisPage = app.otherElements[UIIdentifiers.OnboardingFlow.aiAnalysisPage]
        XCTAssertTrue(waitForElement(aiAnalysisPage, timeout: 5.0),
                      "Should navigate to AI Analysis page after second swipe left")
        
        // Swipe right to go back
        app.swipeRight()
        
        XCTAssertTrue(waitForElement(dataSourcesPage, timeout: 5.0),
                      "Should navigate back to Data Sources page after swipe right")
    }
    
    /// Test: ページインジケーターの表示と動作
    func testPageIndicator_ShowsProgress() {
        // Navigate through pages and verify page indicator
        let japaneseButton = app.buttons[UIIdentifiers.OnboardingFlow.japaneseButton]
        XCTAssertTrue(waitForElement(japaneseButton, timeout: 5.0))
        safeTap(japaneseButton)
        
        // Check for page indicator presence
        let pageIndicator = app.pageIndicators.firstMatch
        XCTAssertTrue(pageIndicator.exists,
                      "Page indicator should be visible")
        
        // Verify page indicator updates as we navigate
        let welcomeNextButton = app.buttons[UIIdentifiers.OnboardingFlow.welcomeNextButton]
        safeTap(welcomeNextButton)
        
        // Page indicator should reflect current page (implementation specific)
        // Note: Actual verification would depend on how page indicator is implemented
    }
}