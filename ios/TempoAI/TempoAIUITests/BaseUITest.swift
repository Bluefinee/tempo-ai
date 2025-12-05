//
//  BaseUITest.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Base class for UI tests with common setup
//

import XCTest

/**
 * Base class for UI tests providing common setup and basic configuration.
 * Helper methods are organized in separate extension files for better maintainability.
 *
 * ## Key Features
 * - Automatic app launch with test environment setup
 * - Basic app instance management
 * - Test environment configuration
 *
 * ## Helper Methods Available Through Extensions
 * - UITestHelpers: Element waiting, tapping, and scrolling
 * - UITestAdvancedHelpers: Retry logic, screenshots, and alerts
 * - UITestFlowHelpers: Tab navigation and common UI flows
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
}