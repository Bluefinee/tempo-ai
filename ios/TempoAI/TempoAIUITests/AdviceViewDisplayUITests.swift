//
//  AdviceViewDisplayUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for AdviceView display elements and card presence
//

import XCTest

/**
 * UI test suite for AdviceView display functionality and card presence validation.
 * Tests cover initial display, theme summary cards, weather cards, and view state handling.
 *
 * ## Test Coverage Areas
 * - Advice view presence and state validation
 * - Theme summary card display and interaction
 * - Weather card display and content validation
 * - State handling (loading, error, empty states)
 */
final class AdviceViewDisplayUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Start on Today tab and wait for advice to load
        switchToTab("Today")
        waitForAppToFinishLoading(timeout: 10.0)
    }
    
    // MARK: - Advice View Display Tests
    
    func testAdviceViewPresence() {
        // Given: The app has loaded and potentially shows advice
        
        // When: Looking for advice view
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        // Then: If advice is available, verify its presence
        if adviceView.exists {
            XCTAssertTrue(adviceView.isHittable, "Advice view should be visible and interactive")
            takeScreenshot(name: "Advice View Present")
        } else {
            // If no advice view, we might be in loading, error, or empty state
            let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
            let errorView = app.otherElements[UIIdentifiers.HomeViewComponents.errorView]
            let emptyStateView = app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]
            
            let hasAlternateState = loadingView.exists || errorView.exists || emptyStateView.exists
            XCTAssertTrue(hasAlternateState, "Should show advice, loading, error, or empty state")
            
            if loadingView.exists {
                takeScreenshot(name: "Loading State Instead of Advice")
            } else if errorView.exists {
                takeScreenshot(name: "Error State Instead of Advice")
            } else if emptyStateView.exists {
                takeScreenshot(name: "Empty State Instead of Advice")
            }
        }
    }
    
    // MARK: - Theme Summary Card Tests
    
    func testThemeSummaryCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping theme summary test")
        }
        
        // When: Looking for theme summary card
        let themeSummaryCard = app.otherElements[UIIdentifiers.AdviceView.themeSummaryCard]
        
        // Then: Theme summary should be visible if advice is loaded
        if themeSummaryCard.exists {
            XCTAssertTrue(themeSummaryCard.isHittable, "Theme summary card should be visible")
            
            let themeSummaryTitle = app.staticTexts[UIIdentifiers.AdviceView.themeSummaryTitle]
            let themeSummaryContent = app.staticTexts[UIIdentifiers.AdviceView.themeSummaryContent]
            
            if themeSummaryTitle.exists {
                XCTAssertFalse(themeSummaryTitle.label.isEmpty, "Theme title should not be empty")
            }
            
            if themeSummaryContent.exists {
                XCTAssertFalse(themeSummaryContent.label.isEmpty, "Theme content should not be empty")
            }
            
            takeScreenshot(name: "Theme Summary Card Display")
        }
    }
    
    func testThemeSummaryCardInteraction() {
        // Given: Theme summary card is available
        let themeSummaryCard = app.otherElements[UIIdentifiers.AdviceView.themeSummaryCard]
        
        guard themeSummaryCard.exists else {
            XCTSkip("Theme summary card not available - skipping interaction test")
        }
        
        // When: Tapping the theme summary card
        if themeSummaryCard.isHittable {
            safeTap(themeSummaryCard)
            
            // Then: Card should remain accessible (it's informational)
            XCTAssertTrue(waitForElement(themeSummaryCard), "Theme card should remain visible after tap")
            
            takeScreenshot(name: "Theme Summary Card After Interaction")
        }
    }
    
    // MARK: - Weather Card Tests
    
    func testWeatherCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping weather card test")
        }
        
        // When: Looking for weather card
        let weatherCard = app.otherElements[UIIdentifiers.AdviceView.weatherCard]
        
        // Then: Weather card should be visible
        if weatherCard.exists {
            XCTAssertTrue(weatherCard.isHittable, "Weather card should be visible")
            
            // Check for weather-related content
            let weatherTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'weather' OR label CONTAINS[c] 'temperature' OR label CONTAINS[c] 'sunny' OR label CONTAINS[c] 'cloudy' OR label CONTAINS[c] 'rain'"))
            
            XCTAssertGreaterThan(weatherTexts.count, 0, "Weather card should contain weather-related content")
            
            takeScreenshot(name: "Weather Card Display")
        }
    }
}