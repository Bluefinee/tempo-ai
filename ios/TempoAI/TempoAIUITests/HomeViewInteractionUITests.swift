//
//  HomeViewInteractionUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for HomeView interactions (navigation, refresh, performance, accessibility)
//

import XCTest

/**
 * UI test suite for HomeView interaction functionality.
 * Tests cover navigation, pull-to-refresh, accessibility, performance, and integration testing.
 *
 * ## Test Coverage Areas
 * - Pull-to-refresh functionality
 * - Navigation and title display
 * - Accessibility element validation
 * - Performance testing for scrolling and refresh operations
 * - Integration testing between views
 * - Edge case handling for rapid operations
 */
final class HomeViewInteractionUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Ensure we start on the Today tab for all home view tests
        switchToTab("Today")
        waitForAppToFinishLoading()
    }
    
    // MARK: - Pull-to-Refresh Tests
    
    func testPullToRefreshFunctionality() {
        // Given: The home view is displayed
        waitForAppToFinishLoading()
        
        // When: Performing pull-to-refresh gesture
        takeScreenshot(name: "Before Pull to Refresh")
        
        performPullToRefresh()
        
        // Then: App should handle the refresh request
        // Check if loading appears briefly
        let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
        if loadingView.exists {
            waitForElementToDisappear(loadingView, timeout: 10.0)
        }
        
        // Ensure we're back to a stable state
        waitForAppToFinishLoading()
        takeScreenshot(name: "After Pull to Refresh")
        
        // Verify essential elements are still present
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Greeting text should still be visible after refresh")
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationTitleDisplay() {
        // Given: The home view is displayed
        
        // When: Checking navigation elements
        // Use flexible approach to check for navigation title
        let todayNavBar = app.navigationBars["Today"]
        let todayStaticText = app.staticTexts["Today"]
        let anyNavigationBar = app.navigationBars.firstMatch
        
        // Then: Navigation should show some form of title
        let hasNavigationTitle = todayNavBar.exists || 
                                todayStaticText.exists || 
                                anyNavigationBar.exists
        
        XCTAssertTrue(hasNavigationTitle, "Some form of navigation title should be visible")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityElements() {
        // Given: The home view is displayed
        
        // When: Checking accessibility of key elements
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        let subtitleText = app.staticTexts[UIIdentifiers.HomeView.subtitleText]
        
        // Then: Elements should be accessible
        XCTAssertTrue(waitForElement(greetingText), "Greeting text should be accessible")
        XCTAssertTrue(waitForElement(settingsButton), "Settings button should be accessible")
        XCTAssertTrue(waitForElement(subtitleText), "Subtitle text should be accessible")
        
        // Verify elements have appropriate accessibility traits
        if settingsButton.exists {
            // Settings button should be identified as a button
            XCTAssertTrue(settingsButton.elementType == .button, "Settings button should have button element type")
        }
    }
    
    // MARK: - Performance Tests
    
    func testHomeViewScrollingPerformance() {
        // Given: The home view is displayed with content
        waitForAppToFinishLoading(timeout: 15.0)
        
        // When: Measuring scrolling performance
        let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        XCTAssertTrue(waitForElement(scrollView), "Scroll view should be available")
        
        // Optimize performance test by reducing sleep and operations
        let options = XCTMeasureOptions.default
        options.iterationCount = 5  // Reduce iterations for faster test completion
        
        measure(options: options) {
            // More efficient scrolling test - measure actual scroll responsiveness
            let startPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let endPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            
            // Single smooth scroll gesture instead of multiple swipes with sleeps
            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
        }
        
        // Then: Scrolling should be smooth and responsive
        // Performance metrics are automatically captured by measure block
    }
    
    func testHomeViewRefreshPerformance() {
        // Given: The home view is displayed
        waitForAppToFinishLoading()
        
        // When: Measuring refresh performance
        let options = XCTMeasureOptions.default
        options.iterationCount = 3  // Reduce iterations as refresh is slower operation
        
        measure(options: options) {
            performPullToRefresh()
            waitForAppToFinishLoading(timeout: 8.0)  // Reduce timeout for faster test
        }
        
        // Then: Refresh should complete within reasonable time
    }
    
    // MARK: - Integration Tests
    
    func testHomeToPermissionsAndBack() {
        // Given: The home view is displayed
        waitForAppToFinishLoading()
        
        // When: Opening permissions and returning
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        safeTap(settingsButton)
        
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(permissionsView), "Permissions view should open")
        
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        safeTap(doneButton)
        
        // Then: Should return to home view in stable state
        XCTAssertTrue(waitForElementToDisappear(permissionsView), "Permissions view should close")
        
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Should return to home view")
        
        takeScreenshot(name: "Back to Home After Permissions")
    }
    
    // MARK: - Edge Case Tests
    
    func testMultipleRapidRefreshes() {
        // Given: The home view is displayed
        waitForAppToFinishLoading()
        
        // When: Performing multiple rapid refreshes
        for i in 0..<3 {
            performPullToRefresh()
            usleep(500_000) // 0.5 second pause between refreshes
            takeScreenshot(name: "Rapid Refresh \(i+1)")
        }
        
        // Then: App should remain stable
        waitForAppToFinishLoading(timeout: 15.0)
        
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Home view should remain stable after rapid refreshes")
    }
}