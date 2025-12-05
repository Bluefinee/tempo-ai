//
//  UITestHelpers.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Helper methods for element waiting, tapping, and scrolling
//

import XCTest

/**
 * Extension containing helper methods for UI element interaction and waiting.
 * This includes safe tapping, element waiting, and scrolling functionality.
 */
extension BaseUITest {
    
    // MARK: - Element Waiting Methods
    
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
    
    // MARK: - Element Interaction Methods
    
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
    
    // MARK: - Scrolling Methods
    
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
}