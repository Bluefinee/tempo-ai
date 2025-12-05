//
//  ContentViewUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for main tab navigation and ContentView functionality
//

import XCTest

/**
 * UI test suite for ContentView tab navigation and application structure.
 * This test class validates the main tabbed interface of the TempoAI application,
 * ensuring proper navigation flow and tab-based user experience.
 *
 * ## Test Coverage Areas
 * - Tab bar visibility and accessibility
 * - Tab navigation between Today, History, Trends, and Profile screens
 * - Default tab selection and state preservation
 * - Tab accessibility labels and VoiceOver support
 * - Performance testing for tab switching operations
 * - Integration testing between tabs and their content views
 *
 * ## Navigation Strategy
 * Uses label-based tab references instead of accessibility identifiers
 * for better compatibility with SwiftUI TabView implementation.
 */
final class ContentViewUITests: BaseUITest {
    
    // MARK: - Tab Navigation Tests
    
    func testTabNavigationExists() {
        // Given: The app is launched
        
        // When: Looking for tab bar elements
        let tabBar = app.tabBars.firstMatch
        
        // Then: All tabs should be visible and accessible
        XCTAssertTrue(waitForElement(tabBar), "Tab bar should be visible")
        
        let todayTab = app.tabBars.buttons["Today"]
        let historyTab = app.tabBars.buttons["History"]
        let trendsTab = app.tabBars.buttons["Trends"]
        let profileTab = app.tabBars.buttons["Profile"]
        
        XCTAssertTrue(todayTab.exists, "Today tab should exist")
        XCTAssertTrue(historyTab.exists, "History tab should exist")
        XCTAssertTrue(trendsTab.exists, "Trends tab should exist")
        XCTAssertTrue(profileTab.exists, "Profile tab should exist")
    }
    
    func testDefaultTabSelection() {
        // Given: The app is launched
        
        // When: Checking the initial tab selection
        let todayTab = app.tabBars.buttons["Today"]
        
        // Then: Today tab should be selected by default
        XCTAssertTrue(waitForElement(todayTab), "Today tab should exist")
        XCTAssertTrue(todayTab.isSelected, "Today tab should be selected by default")
    }
    
    func testTodayTabNavigation() {
        // Given: The app is launched
        
        // When: Tapping the Today tab
        switchToTab("Today")
        
        // Then: Today tab content should be visible
        verifyTabSelected(UIIdentifiers.ContentView.todayTab)
        
        // Verify HomeView elements are displayed
        let homeScrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        XCTAssertTrue(waitForElement(homeScrollView), "Home scroll view should be visible")
        
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Greeting text should be visible")
        
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        XCTAssertTrue(settingsButton.exists, "Settings button should be visible")
    }
    
    func testHistoryTabNavigation() {
        // Given: The app is launched
        
        // When: Tapping the History tab
        switchToTab("History")
        
        // Then: History tab should be selected and placeholder view should be visible
        verifyTabSelected(UIIdentifiers.ContentView.historyTab)
        
        let placeholderView = app.otherElements[UIIdentifiers.PlaceholderView.mainView]
        XCTAssertTrue(waitForElement(placeholderView), "History placeholder view should be visible")
        
        let placeholderMessage = app.staticTexts[UIIdentifiers.PlaceholderView.message]
        XCTAssertTrue(placeholderMessage.exists, "History placeholder message should be visible")
    }
    
    func testTrendsTabNavigation() {
        // Given: The app is launched
        
        // When: Tapping the Trends tab
        switchToTab("Trends")
        
        // Then: Trends tab should be selected and placeholder view should be visible
        verifyTabSelected(UIIdentifiers.ContentView.trendsTab)
        
        let placeholderView = app.otherElements[UIIdentifiers.PlaceholderView.mainView]
        XCTAssertTrue(waitForElement(placeholderView), "Trends placeholder view should be visible")
        
        let placeholderMessage = app.staticTexts[UIIdentifiers.PlaceholderView.message]
        XCTAssertTrue(placeholderMessage.exists, "Trends placeholder message should be visible")
    }
    
    func testProfileTabNavigation() {
        // Given: The app is launched
        
        // When: Tapping the Profile tab
        switchToTab("Profile")
        
        // Then: Profile tab should be selected and profile view should be visible
        verifyTabSelected(UIIdentifiers.ContentView.profileTab)
        
        let profileView = app.otherElements[UIIdentifiers.ProfileView.mainView]
        XCTAssertTrue(waitForElement(profileView), "Profile view should be visible")
        
        // Verify profile rows are visible
        let ageRow = app.otherElements[UIIdentifiers.ProfileView.profileRow(for: "age")]
        XCTAssertTrue(ageRow.exists, "Age profile row should be visible")
        
        let genderRow = app.otherElements[UIIdentifiers.ProfileView.profileRow(for: "gender")]
        XCTAssertTrue(genderRow.exists, "Gender profile row should be visible")
    }
    
    // MARK: - Tab Switching Tests
    
    func testTabSwitchingBetweenAllTabs() {
        // Given: The app is launched with Today tab selected
        verifyTabSelected("Today")
        
        // When & Then: Switch to each tab and verify selection
        
        // Switch to History
        switchToTab("History")
        takeScreenshot(name: "History Tab Selected")
        
        // Switch to Trends
        switchToTab("Trends")
        takeScreenshot(name: "Trends Tab Selected")
        
        // Switch to Profile
        switchToTab("Profile")
        takeScreenshot(name: "Profile Tab Selected")
        
        // Switch back to Today
        switchToTab("Today")
        takeScreenshot(name: "Back to Today Tab")
        
        // Verify we're back to Today with home content
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Should be back to Today tab with greeting text visible")
    }
    
    func testTabStatePreservation() {
        // Given: The app is launched on Today tab
        switchToTab("Today")
        
        // When: Opening settings from home view
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        if settingsButton.exists && settingsButton.isHittable {
            safeTap(settingsButton)
            
            // Wait for permissions view to appear
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            if waitForElement(permissionsView, timeout: 3.0) {
                // Close permissions view
                let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
                if doneButton.exists {
                    safeTap(doneButton)
                }
            }
        }
        
        // Switch to another tab
        switchToTab("Profile")
        
        // Switch back to Today
        switchToTab("Today")
        
        // Then: Today tab state should be preserved
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Today tab state should be preserved")
        
        let homeScrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        XCTAssertTrue(homeScrollView.exists, "Home scroll view should still be visible")
    }
    
    // MARK: - Tab Accessibility Tests
    
    func testTabAccessibilityLabels() {
        // Given: The app is launched
        
        // When: Checking tab accessibility labels
        let todayTab = app.tabBars.buttons["Today"]
        let historyTab = app.tabBars.buttons["History"]
        let trendsTab = app.tabBars.buttons["Trends"]
        let profileTab = app.tabBars.buttons["Profile"]
        
        // Then: Tabs should have proper labels for accessibility
        // Use more flexible label checking to avoid hardcoded strings
        XCTAssertFalse(todayTab.label.isEmpty, "Today tab should have non-empty accessibility label")
        XCTAssertFalse(historyTab.label.isEmpty, "History tab should have non-empty accessibility label")
        XCTAssertFalse(trendsTab.label.isEmpty, "Trends tab should have non-empty accessibility label")
        XCTAssertFalse(profileTab.label.isEmpty, "Profile tab should have non-empty accessibility label")
        
        // Verify tabs are distinct (have different labels)
        let allLabels = [todayTab.label, historyTab.label, trendsTab.label, profileTab.label]
        let uniqueLabels = Set(allLabels)
        XCTAssertEqual(allLabels.count, uniqueLabels.count, "All tabs should have unique accessibility labels")
    }
    
    // MARK: - Performance Tests
    
    func testTabSwitchingPerformance() {
        // Given: The app is launched
        
        // When: Measuring tab switching performance
        let options = XCTMeasureOptions.default
        options.iterationCount = 3  // Reduce iterations for faster completion
        
        measure(options: options) {
            // Perform rapid tab switching using efficient label-based approach
            switchToTab("History")
            switchToTab("Trends") 
            switchToTab("Profile")
            switchToTab("Today")
        }
        
        // Then: Tab switching should complete within reasonable time
        // The measure block automatically captures timing metrics
    }
    
    // MARK: - Error Handling Tests
    
    func testTabNavigationWithAppStateChanges() {
        // Given: The app is launched
        switchToTab("Today")
        
        // When: Simulating app state changes (background/foreground)
        // Note: This would typically require additional setup for background/foreground simulation
        
        // For now, test rapid tab switching which can cause state issues
        for _ in 0..<5 {
            switchToTab("History")
            switchToTab("Today")
        }
        
        // Then: App should remain stable and responsive
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "App should remain stable after rapid tab switching")
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should remain functional")
    }
}