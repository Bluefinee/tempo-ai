//
//  UITestAdvancedHelpers.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Advanced helper methods for retry logic, multiple element waiting, and alerts
//

import XCTest

/**
 * Extension containing advanced helper methods for UI testing.
 * This includes retry mechanisms, waiting for multiple elements, and alert handling.
 */
extension BaseUITest {
    
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
            for element in elements where element.exists {
                return element
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
                usleep(UInt32(delay * 1_000_000)) // Convert to microseconds
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
        usleep(500_000) // 0.5 second instead of Thread.sleep
    }
}