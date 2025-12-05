//
//  BaseUITest.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Base class for UI tests with common setup and helper methods
//

import XCTest

class BaseUITest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Enable UI testing mode
        app.launchEnvironment["UI_TESTING"] = "1"
        
        // Disable animations for more stable tests
        app.launchEnvironment["UITESTING_DISABLE_ANIMATIONS"] = "1"
        
        app.launch()
    }

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
    func safeTap(_ element: XCUIElement, timeout: TimeInterval = 5.0) {
        XCTAssertTrue(waitForElement(element, timeout: timeout), "Element should exist before tapping")
        XCTAssertTrue(waitForElementToBeHittable(element, timeout: timeout), "Element should be hittable before tapping")
        element.tap()
    }
    
    /// Scrolls to find and tap an element
    /// - Parameters:
    ///   - element: The UI element to find and tap
    ///   - scrollView: The scroll view to search in (optional)
    func scrollToAndTap(_ element: XCUIElement, in scrollView: XCUIElement? = nil) {
        let targetScrollView = scrollView ?? app.scrollViews.firstMatch
        
        // Try to find the element first without scrolling
        if element.exists && element.isHittable {
            element.tap()
            return
        }
        
        // Scroll to find the element
        var attempts = 0
        let maxAttempts = 10
        
        while !element.isHittable && attempts < maxAttempts {
            targetScrollView.swipeUp()
            attempts += 1
            
            if element.exists && element.isHittable {
                element.tap()
                return
            }
        }
        
        XCTFail("Could not find and tap element after scrolling")
    }
    
    /// Verifies that a specific tab is selected
    /// - Parameter tabIdentifier: The accessibility identifier of the tab
    func verifyTabSelected(_ tabIdentifier: String) {
        let tab = app.tabBars.buttons[tabIdentifier]
        XCTAssertTrue(waitForElement(tab), "Tab should exist")
        XCTAssertTrue(tab.isSelected, "Tab should be selected")
    }
    
    /// Switches to a specific tab
    /// - Parameter tabIdentifier: The accessibility identifier of the tab
    func switchToTab(_ tabIdentifier: String) {
        let tab = app.tabBars.buttons[tabIdentifier]
        safeTap(tab)
        verifyTabSelected(tabIdentifier)
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
    
    /// Takes a screenshot with a descriptive name
    /// - Parameter name: The name for the screenshot
    func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Waits for the app to finish loading (no loading indicators visible)
    /// - Parameter timeout: Maximum time to wait
    func waitForAppToFinishLoading(timeout: TimeInterval = 10.0) {
        let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
        if loadingView.exists {
            waitForElementToDisappear(loadingView, timeout: timeout)
        }
        
        // Wait a bit more for any animations to finish
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    /// Pulls to refresh on the home screen
    func performPullToRefresh() {
        let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        XCTAssertTrue(waitForElement(scrollView), "Scroll view should exist")
        
        // Perform pull-to-refresh gesture
        let startPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let endPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
}

// MARK: - UIIdentifiers Helper

/// Import UIIdentifiers for UI testing
/// This allows the test files to access the same identifiers used in the main app
private enum UIIdentifiers {
    enum ContentView {
        static let todayTab = "contentView.tab.today"
        static let historyTab = "contentView.tab.history"
        static let trendsTab = "contentView.tab.trends"
        static let profileTab = "contentView.tab.profile"
        static let tabView = "contentView.tabView"
    }
    
    enum HomeView {
        static let navigationTitle = "homeView.navigation.title"
        static let greetingText = "homeView.greeting.text"
        static let settingsButton = "homeView.settings.button"
        static let subtitleText = "homeView.subtitle.text"
        static let scrollView = "homeView.scrollView"
        static let headerSection = "homeView.header.section"
        static let refreshControl = "homeView.refresh.control"
        static let mockDataBanner = "homeView.mockData.banner"
        static let mockDataIcon = "homeView.mockData.icon"
        static let mockDataText = "homeView.mockData.text"
        
        static func greetingText(for timeOfDay: String) -> String {
            return "homeView.greeting.\(timeOfDay.lowercased())"
        }
    }
    
    enum HomeViewComponents {
        static let loadingView = "homeViewComponents.loading.view"
        static let loadingText = "homeViewComponents.loading.text"
        static let loadingSpinner = "homeViewComponents.loading.spinner"
        static let errorView = "homeViewComponents.error.view"
        static let errorIcon = "homeViewComponents.error.icon"
        static let errorTitle = "homeViewComponents.error.title"
        static let errorMessage = "homeViewComponents.error.message"
        static let errorRetryButton = "homeViewComponents.error.retry.button"
        static let emptyStateView = "homeViewComponents.emptyState.view"
        static let emptyStateIcon = "homeViewComponents.emptyState.icon"
        static let emptyStateTitle = "homeViewComponents.emptyState.title"
        static let emptyStateMessage = "homeViewComponents.emptyState.message"
        static let emptyStateActionButton = "homeViewComponents.emptyState.action.button"
        static let adviceCard = "homeViewComponents.advice.card"
        static let adviceCardContent = "homeViewComponents.advice.card.content"
    }
    
    enum AdviceView {
        static let mainView = "adviceView.main.view"
        static let scrollView = "adviceView.scrollView"
        static let themeSummaryCard = "adviceView.themeSummary.card"
        static let themeSummaryIcon = "adviceView.themeSummary.icon"
        static let themeSummaryTitle = "adviceView.themeSummary.title"
        static let themeSummaryContent = "adviceView.themeSummary.content"
        static let weatherCard = "adviceView.weather.card"
        static let weatherIcon = "adviceView.weather.icon"
        static let weatherTitle = "adviceView.weather.title"
        static let mealCardsSection = "adviceView.meals.section"
        static let breakfastCard = "adviceView.meal.breakfast.card"
        static let lunchCard = "adviceView.meal.lunch.card"
        static let dinnerCard = "adviceView.meal.dinner.card"
        static let exerciseCard = "adviceView.exercise.card"
        static let sleepCard = "adviceView.sleep.card"
        static let breathingCard = "adviceView.breathing.card"
    }
    
    enum PermissionsView {
        static let mainView = "permissionsView.main.view"
        static let navigationTitle = "permissionsView.navigation.title"
        static let scrollView = "permissionsView.scrollView"
        static let headerTitle = "permissionsView.header.title"
        static let headerSubtitle = "permissionsView.header.subtitle"
        static let permissionsList = "permissionsView.permissions.list"
        static let dismissButton = "permissionsView.dismiss.button"
        static let healthKitRow = "permissionsView.healthKit.row"
        static let healthKitButton = "permissionsView.healthKit.button"
        static let locationRow = "permissionsView.location.row"
        static let locationButton = "permissionsView.location.button"
        
        static func permissionStatus(for permissionType: String) -> String {
            return "permissionsView.\(permissionType.lowercased()).status"
        }
        
        static func permissionButton(for permissionType: String) -> String {
            return "permissionsView.\(permissionType.lowercased()).button"
        }
    }
    
    enum PlaceholderView {
        static let mainView = "placeholderView.main.view"
        static let icon = "placeholderView.icon"
        static let title = "placeholderView.title"
        static let message = "placeholderView.message"
    }
    
    enum ProfileView {
        static let mainView = "profileView.main.view"
        static let navigationTitle = "profileView.navigation.title"
        
        static func profileRow(for rowType: String) -> String {
            return "profileView.row.\(rowType.lowercased())"
        }
    }
    
    enum Common {
        static let navigationBackButton = "common.navigation.back.button"
        static let closeButton = "common.close.button"
        static let doneButton = "common.done.button"
        static let cancelButton = "common.cancel.button"
        static let saveButton = "common.save.button"
        static let alertView = "common.alert.view"
        static let alertTitle = "common.alert.title"
        static let alertMessage = "common.alert.message"
        static let alertOKButton = "common.alert.ok.button"
        static let alertCancelButton = "common.alert.cancel.button"
    }
}