//
//  BaseUITest.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Base class for UI tests with common setup and helper methods
//

import XCTest

/**
 * Base class for UI tests providing common setup, helper methods, and utilities
 * for reliable UI automation testing. This class handles app launch, element
 * interaction, waiting mechanisms, and test environment configuration.
 *
 * ## Key Features
 * - Automatic app launch with test environment setup
 * - Comprehensive element waiting and interaction methods
 * - Error handling and retry mechanisms
 * - Screenshot capture utilities
 * - Tab navigation helpers
 * - Pull-to-refresh gesture support
 *
 * ## Usage
 * Extend this class for specific UI test suites:
 * ```swift
 * final class HomeViewUITests: BaseUITest {
 *     func testHomeViewFeature() {
 *         // Test implementation using inherited helper methods
 *     }
 * }
 * ```
 */
class BaseUITest: XCTestCase {
    
    /// The main application instance for UI testing
    var app: XCUIApplication!
    
    /**
     * Sets up the test environment before each test method execution.
     * Configures the application with test-specific environment variables
     * and launches the app for UI automation.
     *
     * - Throws: Test setup errors if app launch fails
     */
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Enable UI testing mode for predictable app behavior
        app.launchEnvironment["UI_TESTING"] = "1"
        
        // Disable animations for more stable and faster tests
        app.launchEnvironment["UITESTING_DISABLE_ANIMATIONS"] = "1"
        
        app.launch()
    }

    /**
     * Cleans up test resources after each test method execution.
     * Ensures proper cleanup of app instance and test state.
     *
     * - Throws: Cleanup errors if resource deallocation fails
     */
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    // MARK: - Helper Methods
    
    /// Waits for an element to exist with a timeout
    /// - Parameters:
    ///   - element: The UI element to wait for
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: True if element exists within timeout
    @discardableResult
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for an element to disappear with a timeout
    /// - Parameters:
    ///   - element: The UI element to wait for disappearance
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: True if element disappears within timeout
    @discardableResult
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for an element to be hittable (visible and can be tapped)
    /// - Parameters:
    ///   - element: The UI element to wait for
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: True if element becomes hittable within timeout
    @discardableResult
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Safely taps an element after ensuring it exists and is hittable
    /// - Parameter element: The UI element to tap
    /// - Parameter timeout: Maximum time to wait for element
    /// - Parameter retryCount: Number of retry attempts if tap fails
    func safeTap(_ element: XCUIElement, timeout: TimeInterval = 5.0, retryCount: Int = 2) {
        guard waitForElement(element, timeout: timeout) else {
            XCTFail("Element does not exist: \(element.debugDescription)")
            return
        }
        
        guard waitForElementToBeHittable(element, timeout: timeout) else {
            XCTFail("Element is not hittable: \(element.debugDescription)")
            return
        }
        
        var attempts = 0
        while attempts <= retryCount {
            do {
                element.tap()
                // Small delay to ensure tap was processed
                usleep(100_000) // 0.1 second
                return
            } catch {
                attempts += 1
                if attempts > retryCount {
                    XCTFail("Failed to tap element after \(retryCount + 1) attempts: \(error.localizedDescription)")
                    return
                }
                // Wait a bit before retrying
                usleep(500_000) // 0.5 second
            }
        }
    }
    
    /// Scrolls to find and tap an element with comprehensive error handling
    /// - Parameters:
    ///   - element: The UI element to find and tap
    ///   - scrollView: The scroll view to search in (optional)
    ///   - timeout: Maximum time to spend searching
    func scrollToAndTap(_ element: XCUIElement, in scrollView: XCUIElement? = nil, timeout: TimeInterval = 10.0) {
        let targetScrollView = scrollView ?? app.scrollViews.firstMatch
        
        // Verify scroll view exists
        guard targetScrollView.exists else {
            XCTFail("Scroll view does not exist for scrolling to element")
            return
        }
        
        // Try to find the element first without scrolling
        if element.exists && element.isHittable {
            safeTap(element)
            return
        }
        
        let startTime = Date()
        var attempts = 0
        let maxAttempts = 15
        var lastElementFound = false
        
        while Date().timeIntervalSince(startTime) < timeout && attempts < maxAttempts {
            // Check if element became visible
            if element.exists {
                lastElementFound = true
                if element.isHittable {
                    safeTap(element)
                    return
                }
            }
            
            // Try scrolling up first
            do {
                targetScrollView.swipeUp()
                usleep(300_000) // 0.3 second wait after swipe
            } catch {
                // If scrolling fails, try alternative approach
                if attempts < maxAttempts / 2 {
                    targetScrollView.swipeDown()
                    usleep(300_000)
                }
            }
            
            attempts += 1
            
            // Check again after scrolling
            if element.exists && element.isHittable {
                safeTap(element)
                return
            }
        }
        
        // Provide detailed failure information
        let errorMessage = lastElementFound ? 
            "Element was found but not hittable after scrolling for \(timeout) seconds (\(attempts) attempts)" :
            "Element was not found after scrolling for \(timeout) seconds (\(attempts) attempts)"
        
        XCTFail(errorMessage + ": \(element.debugDescription)")
    }
    
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
    
    /// Takes a screenshot with a descriptive name and error handling
    /// - Parameter name: The name for the screenshot
    /// - Parameter includeTimestamp: Whether to include timestamp in name
    func takeScreenshot(name: String, includeTimestamp: Bool = true) {
        do {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            
            let finalName = includeTimestamp ? 
                "\(name) - \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))" : 
                name
            
            attachment.name = finalName
            attachment.lifetime = .keepAlways
            add(attachment)
            
        } catch {
            print("Failed to capture screenshot '\(name)': \(error.localizedDescription)")
            // Don't fail test for screenshot issues, just log
        }
    }
    
    /// Waits for the app to finish loading (no loading indicators visible)
    /// - Parameter timeout: Maximum time to wait
    func waitForAppToFinishLoading(timeout: TimeInterval = 10.0) {
        let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
        let loadingSpinner = app.otherElements[UIIdentifiers.HomeViewComponents.loadingSpinner]
        
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            // Check if any loading indicators are visible
            let hasLoadingView = loadingView.exists && loadingView.isHittable
            let hasLoadingSpinner = loadingSpinner.exists && loadingSpinner.isHittable
            
            if !hasLoadingView && !hasLoadingSpinner {
                // Wait a bit more to ensure loading is truly finished
                usleep(500_000) // 0.5 second
                
                // Double check
                if !loadingView.exists && !loadingSpinner.exists {
                    return
                }
            }
            
            usleep(200_000) // 0.2 second between checks
        }
        
        // Log warning if loading didn't finish in time
        if loadingView.exists || loadingSpinner.exists {
            print("Warning: App may still be loading after \(timeout) seconds timeout")
        }
        
        // Wait a bit more for any animations to finish
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    /// Performs pull-to-refresh gesture with error handling
    /// - Parameter scrollView: Optional specific scroll view to refresh
    func performPullToRefresh(on scrollView: XCUIElement? = nil) {
        let targetScrollView = scrollView ?? app.scrollViews[UIIdentifiers.HomeView.scrollView]
        
        guard waitForElement(targetScrollView, timeout: 5.0) else {
            XCTFail("Scroll view should exist for pull-to-refresh")
            return
        }
        
        // Ensure scroll view is at the top for pull-to-refresh to work
        targetScrollView.swipeDown()
        usleep(300_000) // 0.3 second wait
        
        do {
            // Perform pull-to-refresh gesture
            let startPoint = targetScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let endPoint = targetScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            
            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            
            // Wait for refresh to start
            usleep(500_000) // 0.5 second
            
        } catch {
            XCTFail("Failed to perform pull-to-refresh gesture: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Advanced Helper Methods
    
    /// Waits for any one of multiple elements to appear
    /// - Parameters:
    ///   - elements: Array of elements to wait for
    ///   - timeout: Maximum time to wait
    /// - Returns: The first element that appeared, or nil if none appeared
    @discardableResult
    func waitForAnyElement(_ elements: [XCUIElement], timeout: TimeInterval = 5.0) -> XCUIElement? {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            for element in elements {
                if element.exists {
                    return element
                }
            }
            usleep(100_000) // 0.1 second
        }
        
        return nil
    }
    
    /// Retry a block of code multiple times with delay
    /// - Parameters:
    ///   - maxAttempts: Maximum number of attempts
    ///   - delay: Delay between attempts in seconds
    ///   - action: The action to retry
    /// - Returns: True if action succeeded, false otherwise
    @discardableResult
    func retry(maxAttempts: Int = 3, delay: TimeInterval = 1.0, action: () throws -> Bool) -> Bool {
        var attempts = 0
        
        while attempts < maxAttempts {
            do {
                if try action() {
                    return true
                }
            } catch {
                print("Retry attempt \(attempts + 1) failed: \(error.localizedDescription)")
            }
            
            attempts += 1
            if attempts < maxAttempts {
                Thread.sleep(forTimeInterval: delay)
            }
        }
        
        return false
    }
    
    /// Dismisses any alerts that might be present
    func dismissAnyAlerts() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alerts = springboard.alerts
        
        if alerts.count > 0 {
            let alert = alerts.firstMatch
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
            } else if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            } else if alert.buttons["Cancel"].exists {
                alert.buttons["Cancel"].tap()
            }
        }
        
        // Also check for app alerts
        let appAlerts = app.alerts
        if appAlerts.count > 0 {
            let alert = appAlerts.firstMatch
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            }
        }
    }
}