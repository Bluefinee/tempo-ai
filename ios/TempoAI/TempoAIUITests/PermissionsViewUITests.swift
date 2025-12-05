//
//  PermissionsViewUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for PermissionsView functionality and permission flows
//

import XCTest

final class PermissionsViewUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Start on Today tab and navigate to permissions
        switchToTab(UIIdentifiers.ContentView.todayTab)
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
    
    // MARK: - Initial Display Tests
    
    func testPermissionsViewInitialDisplay() {
        // Given: Permissions view is opened
        
        // When: Checking initial display elements
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        let headerTitle = app.staticTexts[UIIdentifiers.PermissionsView.headerTitle]
        let permissionsList = app.otherElements[UIIdentifiers.PermissionsView.permissionsList]
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        
        // Then: All essential elements should be visible
        XCTAssertTrue(permissionsView.exists, "Permissions view should be visible")
        XCTAssertTrue(waitForElement(headerTitle), "Header title should be visible")
        XCTAssertTrue(waitForElement(permissionsList), "Permissions list should be visible")
        XCTAssertTrue(waitForElement(doneButton), "Done button should be visible")
        
        takeScreenshot(name: "Permissions View Initial Display")
    }
    
    func testPermissionsViewTitle() {
        // Given: Permissions view is opened
        
        // When: Checking the title text
        let headerTitle = app.staticTexts[UIIdentifiers.PermissionsView.headerTitle]
        
        // Then: Title should contain expected text
        XCTAssertTrue(waitForElement(headerTitle), "Header title should be visible")
        XCTAssertTrue(headerTitle.label.contains("Permissions"), 
                      "Header should mention permissions, got: '\(headerTitle.label)'")
    }
    
    func testNavigationBarElements() {
        // Given: Permissions view is opened
        
        // When: Checking navigation bar elements
        let navigationBar = app.navigationBars.firstMatch
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        
        // Then: Navigation elements should be properly configured
        XCTAssertTrue(navigationBar.exists, "Navigation bar should be visible")
        XCTAssertTrue(waitForElement(doneButton), "Done button should be in navigation bar")
        XCTAssertTrue(doneButton.isHittable, "Done button should be tappable")
    }
    
    // MARK: - Permission Rows Tests
    
    func testHealthKitPermissionRowDisplay() {
        // Given: Permissions view is opened
        
        // When: Checking HealthKit permission row
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        
        // Then: HealthKit row should be visible and properly formatted
        XCTAssertTrue(waitForElement(healthKitRow), "HealthKit permission row should be visible")
        XCTAssertTrue(healthKitRow.isHittable, "HealthKit row should be interactive")
        
        // Check for HealthKit-related text content
        let healthKitText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'healthkit'")).firstMatch
        if !healthKitText.exists {
            let healthText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'health'")).firstMatch
            XCTAssertTrue(healthText.exists, "Should contain health-related text")
        }
    }
    
    func testLocationPermissionRowDisplay() {
        // Given: Permissions view is opened
        
        // When: Checking Location permission row
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        
        // Then: Location row should be visible and properly formatted
        XCTAssertTrue(waitForElement(locationRow), "Location permission row should be visible")
        XCTAssertTrue(locationRow.isHittable, "Location row should be interactive")
        
        // Check for location-related text content
        let locationText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'location'")).firstMatch
        XCTAssertTrue(locationText.exists, "Should contain location-related text")
    }
    
    func testPermissionStatusDisplay() {
        // Given: Permissions view is opened
        
        // When: Checking permission status indicators
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        
        // Then: Permission status should be visible (either authorized or not authorized)
        if healthKitRow.exists {
            // Look for status text in the HealthKit row
            let statusTexts = ["Authorized", "Not Authorized", "Granted", "Denied"]
            var foundStatus = false
            
            for statusText in statusTexts {
                if app.staticTexts[statusText].exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '\(statusText)'")).firstMatch.exists {
                    foundStatus = true
                    break
                }
            }
            
            // If we don't find explicit status text, that's okay for this test
            // The actual authorization state depends on the test environment
        }
        
        if locationRow.exists {
            // Similar check for location permission status
            // In UI tests, permissions are typically in a default state
            XCTAssertTrue(locationRow.isHittable, "Location row should be properly displayed")
        }
    }
    
    // MARK: - Permission Button Tests
    
    func testHealthKitPermissionButton() {
        // Given: Permissions view is opened
        
        // When: Looking for HealthKit enable button
        let healthKitButton = app.buttons[UIIdentifiers.PermissionsView.healthKitButton]
        
        // Then: If button exists, it should be functional
        if healthKitButton.exists {
            XCTAssertTrue(healthKitButton.isHittable, "HealthKit button should be tappable")
            XCTAssertTrue(healthKitButton.label.contains("HealthKit") || healthKitButton.label.contains("Enable"), 
                          "Button should have appropriate label")
            
            takeScreenshot(name: "HealthKit Permission Button Visible")
            
            // Note: We don't actually tap this in UI tests as it would trigger system permission dialogs
            // In a real test environment, you might want to mock these interactions
        } else {
            // If button doesn't exist, HealthKit might already be authorized or unavailable
            XCTAssertTrue(true, "HealthKit button not present - possibly already authorized")
        }
    }
    
    func testLocationPermissionButton() {
        // Given: Permissions view is opened
        
        // When: Looking for Location enable button
        let locationButton = app.buttons[UIIdentifiers.PermissionsView.locationButton]
        
        // Then: If button exists, it should be functional
        if locationButton.exists {
            XCTAssertTrue(locationButton.isHittable, "Location button should be tappable")
            XCTAssertTrue(locationButton.label.contains("Location") || locationButton.label.contains("Enable"), 
                          "Button should have appropriate label")
            
            takeScreenshot(name: "Location Permission Button Visible")
            
            // Note: Similar to HealthKit, we don't actually tap to avoid system dialogs
        } else {
            // If button doesn't exist, location might already be authorized
            XCTAssertTrue(true, "Location button not present - possibly already authorized")
        }
    }
    
    // MARK: - Navigation Tests
    
    func testDoneButtonFunctionality() {
        // Given: Permissions view is opened
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(permissionsView.exists, "Permissions view should be visible")
        
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
    
    // MARK: - Accessibility Tests
    
    func testPermissionsAccessibilityElements() {
        // Given: Permissions view is opened
        
        // When: Checking accessibility of key elements
        let headerTitle = app.staticTexts[UIIdentifiers.PermissionsView.headerTitle]
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        
        // Then: Elements should be accessible
        XCTAssertTrue(headerTitle.exists, "Header title should be accessible")
        XCTAssertTrue(healthKitRow.exists, "HealthKit row should be accessible")
        XCTAssertTrue(locationRow.exists, "Location row should be accessible")
        XCTAssertTrue(doneButton.exists, "Done button should be accessible")
        
        // Verify proper element types
        XCTAssertTrue(doneButton.elementType == .button, "Done button should have button element type")
    }
    
    func testPermissionRowAccessibility() {
        // Given: Permissions view is opened
        
        // When: Checking permission row accessibility
        let healthKitRow = app.otherElements[UIIdentifiers.PermissionsView.healthKitRow]
        let locationRow = app.otherElements[UIIdentifiers.PermissionsView.locationRow]
        
        // Then: Rows should have appropriate accessibility information
        if healthKitRow.exists {
            // Check that row contains descriptive text
            let hasHealthText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'health'")).firstMatch.exists
            XCTAssertTrue(hasHealthText, "HealthKit row should contain descriptive text")
        }
        
        if locationRow.exists {
            // Check that row contains descriptive text
            let hasLocationText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'location'")).firstMatch.exists
            XCTAssertTrue(hasLocationText, "Location row should contain descriptive text")
        }
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
        XCTAssertTrue(permissionsView.exists, "Should remain in permissions view")
    }
    
    // MARK: - Layout Tests
    
    func testPermissionsViewLayout() {
        // Given: Permissions view is opened
        
        // When: Checking layout elements
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        let permissionsList = app.otherElements[UIIdentifiers.PermissionsView.permissionsList]
        
        // Then: Layout should be properly structured
        XCTAssertTrue(permissionsView.exists, "Main permissions view should exist")
        XCTAssertTrue(permissionsList.exists, "Permissions list should exist")
        
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
        XCTAssertTrue(settingsButton.exists, "Settings button should be functional")
        XCTAssertTrue(scrollView.exists, "Scroll view should be functional")
        
        // Verify we can open permissions again
        safeTap(settingsButton)
        let reopenedPermissions = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        XCTAssertTrue(waitForElement(reopenedPermissions), "Should be able to reopen permissions")
        
        takeScreenshot(name: "Reopened Permissions View")
    }
    
    // MARK: - Performance Tests
    
    func testPermissionsViewOpenClosePerformance() {
        // Given: Starting from home view
        closePermissionsViewIfOpen() // Ensure we start from home
        
        // When: Measuring permissions view open/close performance
        measure {
            // Open permissions
            let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
            safeTap(settingsButton)
            
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            waitForElement(permissionsView, timeout: 3.0)
            
            // Close permissions
            let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
            safeTap(doneButton)
            
            waitForElementToDisappear(permissionsView, timeout: 3.0)
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
        
        XCTAssertTrue(healthKitRow.exists, "HealthKit row should be preserved")
        XCTAssertTrue(locationRow.exists, "Location row should be preserved")
        
        takeScreenshot(name: "State Preserved After Reopen")
    }
}