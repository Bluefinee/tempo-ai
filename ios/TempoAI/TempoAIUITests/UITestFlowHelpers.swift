//
//  UITestFlowHelpers.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Helper methods for common UI flows and navigation
//

import XCTest

/**
 * Extension containing helper methods for common UI flows and navigation.
 * This includes tab navigation, view verification, and app-specific flows.
 */
extension BaseUITest {

    // MARK: - Tab Navigation

    /**
     * Verifies that a specific tab is currently selected in the tab bar
     *
     * - Parameter tabIdentifier: The accessibility identifier or label of the tab to verify
     * - Note: This method will fail the test if the tab doesn't exist or isn't selected
     */
    func verifyTabSelected(_ tabIdentifier: String) {
        let tab = app.tabBars.buttons[tabIdentifier]
        XCTAssertTrue(waitForElement(tab), "Tab should exist")
        XCTAssertTrue(tab.isSelected, "Tab should be selected")
    }

    /// Switches to a specific tab with error handling
    /// - Parameter tabIdentifier: The accessibility identifier of the tab
    /// - Parameter timeout: Maximum time to wait for tab switch
    func switchToTab(_ tabIdentifier: String, timeout: TimeInterval = 5.0) {
        let tab = app.tabBars.buttons[tabIdentifier]

        guard tab.exists else {
            XCTFail("Tab with identifier '\(tabIdentifier)' does not exist")
            return
        }

        safeTap(tab, timeout: timeout)

        // Wait for tab switch to complete
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if tab.isSelected {
                return
            }
            usleep(100_000) // 0.1 second
        }

        // If verification fails, try one more time
        if !tab.isSelected {
            safeTap(tab, timeout: timeout)
            usleep(500_000) // 0.5 second wait

            if !tab.isSelected {
                XCTFail("Tab '\(tabIdentifier)' was not selected after tapping")
            }
        }
    }

    // MARK: - View State Verification

    /// Verifies that an error view is displayed with the retry button
    func verifyErrorViewDisplayed() {
        XCTAssertTrue(waitForElement(app.otherElements[UIIdentifiers.HomeViewComponents.errorView]),
                      "Error view should be displayed")
        XCTAssertTrue(app.buttons[UIIdentifiers.HomeViewComponents.errorRetryButton].exists,
                      "Retry button should be visible")
    }

    /// Verifies that a loading view is displayed
    func verifyLoadingViewDisplayed() {
        XCTAssertTrue(waitForElement(app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]),
                      "Loading view should be displayed")
        XCTAssertTrue(app.staticTexts[UIIdentifiers.HomeViewComponents.loadingText].exists,
                      "Loading text should be visible")
    }

    /// Verifies that an empty state view is displayed
    func verifyEmptyStateViewDisplayed() {
        XCTAssertTrue(waitForElement(app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]),
                      "Empty state view should be displayed")
        XCTAssertTrue(app.buttons[UIIdentifiers.HomeViewComponents.emptyStateActionButton].exists,
                      "Empty state action button should be visible")
    }

    // MARK: - Shared Helper Methods for Common UI Flows

    /// Opens the permissions view from the home screen
    /// - Note: Should be called from Today tab with app loaded
    func openPermissionsView() {
        let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
        if settingsButton.exists && settingsButton.isHittable {
            safeTap(settingsButton)

            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            XCTAssertTrue(waitForElement(permissionsView, timeout: 5.0), "Permissions view should open")
        }
    }

    /// Closes the permissions view if it's currently open
    func closePermissionsViewIfOpen() {
        let doneButton = app.buttons[UIIdentifiers.PermissionsView.dismissButton]
        if doneButton.exists && doneButton.isHittable {
            safeTap(doneButton)

            let permissionsView = app.otherElements[UIIdentifiers.PermissionsView.mainView]
            waitForElementToDisappear(permissionsView)
        }
    }
}
