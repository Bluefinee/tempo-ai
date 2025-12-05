//
//  PermissionsViewAccessibilityUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for PermissionsView accessibility and permission button functionality
//

import XCTest

/**
 * UI test suite for PermissionsView accessibility and permission button functionality.
 * Tests cover accessibility validation and permission button interactions.
 *
 * ## Test Coverage Areas
 * - Permission button display and functionality
 * - Accessibility element validation
 * - Permission row accessibility
 * - Element type verification
 */
final class PermissionsViewAccessibilityUITests: BaseUITest {
    
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
    
    // MARK: - Permission Button Tests
    
    func testHealthKitPermissionButton() {
        // Given: Permissions view is opened
        
        // When: Looking for HealthKit enable button
        let healthKitButton = app.buttons[UIIdentifiers.PermissionsView.healthKitButton]
        
        // Then: If button exists, it should be functional
        if healthKitButton.exists {
            XCTAssertTrue(healthKitButton.isHittable, "HealthKit button should be tappable")
            XCTAssertFalse(healthKitButton.label.isEmpty, "Button should have non-empty label")
            
            takeScreenshot(name: "HealthKit Permission Button Visible")
            
            // Note: We don't actually tap this in UI tests as it would trigger system permission dialogs
            // In a real test environment, you might want to mock these interactions
        } else {
            // If button doesn't exist, HealthKit might already be authorized or unavailable
            // This is expected behavior when HealthKit is already authorized
            // Verify we're still in a valid permissions view state
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            XCTAssertTrue(permissionsView.exists, "Should remain in permissions view when button is not present")
        }
    }
    
    func testLocationPermissionButton() {
        // Given: Permissions view is opened
        
        // When: Looking for Location enable button
        let locationButton = app.buttons[UIIdentifiers.PermissionsView.locationButton]
        
        // Then: If button exists, it should be functional
        if locationButton.exists {
            XCTAssertTrue(locationButton.isHittable, "Location button should be tappable")
            XCTAssertFalse(locationButton.label.isEmpty, "Button should have non-empty label")
            
            takeScreenshot(name: "Location Permission Button Visible")
            
            // Note: Similar to HealthKit, we don't actually tap to avoid system dialogs
        } else {
            // If button doesn't exist, location might already be authorized
            // This is expected behavior when location is already authorized
            // Verify we're still in a valid permissions view state
            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            XCTAssertTrue(permissionsView.exists, "Should remain in permissions view when button is not present")
        }
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
        XCTAssertTrue(waitForElement(headerTitle), "Header title should be accessible")
        XCTAssertTrue(waitForElement(healthKitRow), "HealthKit row should be accessible")
        XCTAssertTrue(waitForElement(locationRow), "Location row should be accessible")
        XCTAssertTrue(waitForElement(doneButton), "Done button should be accessible")
        
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
}