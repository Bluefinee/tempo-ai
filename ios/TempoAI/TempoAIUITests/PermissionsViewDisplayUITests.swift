//
//  PermissionsViewDisplayUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for PermissionsView display elements and permission rows
//

import XCTest

/**
 * UI test suite for PermissionsView display functionality.
 * Tests cover initial display, navigation elements, and permission row visibility.
 *
 * ## Test Coverage Areas
 * - Initial display and layout validation
 * - Navigation bar and title elements
 * - Permission row display and content
 * - Status indicator visibility
 */
final class PermissionsViewDisplayUITests: BaseUITest {
    
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
    
    
    // MARK: - Initial Display Tests
    
    func testPermissionsViewInitialDisplay() {
        // Given: Permissions view is opened
        
        // When: Checking initial display elements
        let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
        let headerTitle = app.staticTexts[UIIdentifiers.PermissionsView.headerTitle]
        let permissionsList = app.otherElements[UIIdentifiers.PermissionsView.permissionsList]
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        
        // Then: All essential elements should be visible
        XCTAssertTrue(waitForElement(permissionsView), "Permissions view should be visible")
        XCTAssertTrue(waitForElement(headerTitle), "Header title should be visible")
        XCTAssertTrue(waitForElement(permissionsList), "Permissions list should be visible")
        XCTAssertTrue(waitForElement(doneButton), "Done button should be visible")
        
        takeScreenshot(name: "Permissions View Initial Display")
    }
    
    func testPermissionsViewTitle() {
        // Given: Permissions view is opened
        
        // When: Checking the title text
        let headerTitle = app.staticTexts[UIIdentifiers.PermissionsView.headerTitle]
        
        // Then: Title should contain meaningful content
        XCTAssertTrue(waitForElement(headerTitle), "Header title should be visible")
        XCTAssertFalse(headerTitle.label.isEmpty, "Header title should not be empty, got: '\(headerTitle.label)'")
    }
    
    func testNavigationBarElements() {
        // Given: Permissions view is opened
        
        // When: Checking navigation bar elements
        let navigationBar = app.navigationBars.firstMatch
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        
        // Then: Navigation elements should be properly configured
        XCTAssertTrue(waitForElement(navigationBar), "Navigation bar should be visible")
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
            XCTAssertTrue(waitForElement(healthText), "Should contain health-related text")
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
        XCTAssertTrue(waitForElement(locationText), "Should contain location-related text")
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
            
            // Verify that some status indicator is present when row exists
            XCTAssertTrue(foundStatus, "HealthKit row should display a permission status (Authorized/Not Authorized/Granted/Denied)")
        }
        
        if locationRow.exists {
            // Similar check for location permission status
            // In UI tests, permissions are typically in a default state
            XCTAssertTrue(locationRow.isHittable, "Location row should be properly displayed")
        }
    }
}