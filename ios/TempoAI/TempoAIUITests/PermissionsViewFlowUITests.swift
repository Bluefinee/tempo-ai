//
//  PermissionsViewFlowUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for PermissionsView navigation flows and integration
//

import XCTest

/**
 * UI test suite for PermissionsView flow and integration functionality.
 * Tests cover navigation flows, home integration, error handling, and performance.
 *
 * ## Test Coverage Areas
 * - Done button functionality and navigation
 * - Layout validation and element positioning
 * - Integration with home view
 * - Error handling and alert management
 * - Performance testing for open/close operations
 * - State preservation across view transitions
 */
final class PermissionsViewFlowUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Start on Today tab and navigate to permissions
        switchToTab("Today")
        waitForAppToFinishLoading()
        
        // Open permissions view
        openPermissionsView()
    }
    
    override func tearDown() {
        // Close permissions view if still open
        closePermissionsViewIfOpen()
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func openPermissionsView() {
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        if settingsButton.exists && settingsButton.isHittable {
            safeTap(settingsButton)
            
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            XCTAssertTrue(waitForElement(permissionsView, timeout: 5.0), "Permissions view should open")
        }
    }
    
    private func closePermissionsViewIfOpen() {
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        if doneButton.exists && doneButton.isHittable {
            safeTap(doneButton)
            
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            waitForElementToDisappear(permissionsView)
        }
    }
    
    // MARK: - Navigation Tests
    
    func testDoneButtonFunctionality() {
        // Given: Permissions view is opened
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(permissionsView), "Permissions view should be visible")
        
        // When: Tapping the Done button
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        XCTAssertTrue(waitForElementToBeHittable(doneButton), "Done button should be tappable")
        safeTap(doneButton)
        
        // Then: Should return to home view
        XCTAssertTrue(waitForElementToDisappear(permissionsView, timeout: 5.0), "Permissions view should close")
        
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        XCTAssertTrue(waitForElement(greetingText), "Should return to home view")
        
        takeScreenshot(name: "Returned to Home After Done")
    }
    
    // MARK: - Layout Tests
    
    func testPermissionsViewLayout() {
        // Given: Permissions view is opened
        
        // When: Checking layout elements
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        let permissionsList = app.otherElements[UIIdentifiers.PermissionsView.permissionsList]
        
        // Then: Layout should be properly structured
        XCTAssertTrue(waitForElement(permissionsView), "Main permissions view should exist")
        XCTAssertTrue(waitForElement(permissionsList), "Permissions list should exist")
        
        // Check that both permission rows are visible without needing to scroll
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        
        XCTAssertTrue(healthKitRow.exists && healthKitRow.isHittable, "HealthKit row should be visible")
        XCTAssertTrue(locationRow.exists && locationRow.isHittable, "Location row should be visible")
        
        takeScreenshot(name: "Permissions View Layout")
    }
    
    // MARK: - Integration Tests
    
    func testPermissionsToHomeIntegration() {
        // Given: Permissions view is opened
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(permissionsView.exists, "Starting in permissions view")
        
        // When: Dismissing permissions and checking home state
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        safeTap(doneButton)
        
        waitForElementToDisappear(permissionsView)
        
        // Then: Should be back in home view with all elements functional
        let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        
        XCTAssertTrue(waitForElement(greetingText), "Greeting text should be visible")
        XCTAssertTrue(waitForElement(settingsButton), "Settings button should be functional")
        XCTAssertTrue(waitForElement(scrollView), "Scroll view should be functional")
        
        // Verify we can open permissions again
        safeTap(settingsButton)
        let reopenedPermissions = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(reopenedPermissions), "Should be able to reopen permissions")
        
        takeScreenshot(name: "Reopened Permissions View")
    }
    
    // MARK: - Error Handling Tests
    
    func testPermissionErrorHandling() {
        // Given: Permissions view is opened
        
        // When: Looking for potential error alerts
        // Note: In UI tests, permission errors might not occur, but we can check the structure
        
        // Check if alert handling is properly set up by looking for alert elements
        let alerts = app.alerts
        
        if alerts.count > 0 {
            // If an alert appears, verify it has proper buttons
            let alert = alerts.firstMatch
            let okButton = alert.buttons["OK"]
            
            if okButton.exists {
                XCTAssertTrue(okButton.isHittable, "Alert OK button should be tappable")
                takeScreenshot(name: "Permission Error Alert")
                safeTap(okButton)
            }
        }
        
        // Verify we're still in permissions view after any error handling
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(permissionsView), "Should remain in permissions view")
    }
    
    // MARK: - Performance Tests
    
    func testPermissionsViewOpenClosePerformance() {
        // Given: Starting from home view
        closePermissionsViewIfOpen() // Ensure we start from home
        
        // When: Measuring permissions view open/close performance
        let options = XCTMeasureOptions.default
        options.iterationCount = 3  // Reduce iterations for faster completion
        
        measure(options: options) {
            // Open permissions with optimized timeouts
            let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
            safeTap(settingsButton, timeout: 2.0)
            
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            waitForElement(permissionsView, timeout: 2.0)
            
            // Close permissions with optimized timeouts
            let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
            safeTap(doneButton, timeout: 2.0)
            
            waitForElementToDisappear(permissionsView, timeout: 2.0)
        }
        
        // Then: Performance should be acceptable (measured automatically)
    }
    
    // MARK: - State Preservation Tests
    
    func testPermissionsStatePreservation() {
        // Given: Permissions view is opened
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(permissionsView.exists, "Starting in permissions view")
        
        // When: Going to background and foreground (simulated by navigation)
        // Close and reopen permissions to test state preservation
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        safeTap(doneButton)
        
        waitForElementToDisappear(permissionsView)
        
        // Reopen permissions
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        safeTap(settingsButton)
        
        // Then: Permissions view should reopen in consistent state
        let reopenedPermissions = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(reopenedPermissions), "Permissions should reopen consistently")
        
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        
        XCTAssertTrue(waitForElement(healthKitRow), "HealthKit row should be preserved")
        XCTAssertTrue(waitForElement(locationRow), "Location row should be preserved")
        
        takeScreenshot(name: "State Preserved After Reopen")
    }
}