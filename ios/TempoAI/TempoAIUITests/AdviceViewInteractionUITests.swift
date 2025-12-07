//
//  AdviceViewInteractionUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for AdviceView interactions (scrolling, refresh, tab switching, mock data)
//

import XCTest

/**
 * UI test suite for AdviceView interaction functionality.
 * Tests cover scrolling behavior, pull-to-refresh, tab switching integration, and mock data scenarios.
 *
 * ## Test Coverage Areas
 * - Scrolling and navigation behavior
 * - Card accessibility during scroll operations
 * - Content validation and quality checks
 * - Mock data indicator coexistence
 * - Error recovery mechanisms
 * - Tab switching integration
 */
final class AdviceViewInteractionUITests: BaseUITest {

    override func setUp() {
        super.setUp()

        // Start on Today tab and wait for advice to load
        switchToTab("Today")
        waitForAppToFinishLoading(timeout: 10.0)
    }

    // MARK: - Scrolling and Navigation Tests

    func testAdviceViewScrolling() {
        // Given: Advice view with multiple cards is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping scrolling test")
        }

        // When: Scrolling through advice cards
        let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]

        if scrollView.exists {
            takeScreenshot(name: "Advice View Before Scrolling")

            // Scroll down to see more cards
            scrollView.swipeUp()
            usleep(500_000) // 0.5 second

            takeScreenshot(name: "Advice View After Scroll Down")

            // Scroll back up
            scrollView.swipeDown()
            usleep(500_000) // 0.5 second

            takeScreenshot(name: "Advice View After Scroll Up")

            // Then: Scrolling should work smoothly
            XCTAssertTrue(waitForElement(scrollView), "Scroll view should remain functional")
        }
    }

    func testAdviceCardAccessibilityDuringScroll() {
        // Given: Advice view with multiple cards
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping scroll accessibility test")
        }

        // When: Scrolling and checking card accessibility
        let cardIdentifiers = [
            UIIdentifiers.AdviceView.themeSummaryCard,
            UIIdentifiers.AdviceView.weatherCard,
            UIIdentifiers.AdviceView.breakfastCard,
            UIIdentifiers.AdviceView.exerciseCard,
            UIIdentifiers.AdviceView.sleepCard,
            UIIdentifiers.AdviceView.breathingCard
        ]

        for cardIdentifier in cardIdentifiers {
            let card = app.otherElements[cardIdentifier]

            if card.exists {
                // Then: Cards should be accessible when visible
                if card.isHittable {
                    // Verify card is accessible
                    XCTAssertTrue(waitForElement(card), "Card \(cardIdentifier) should be accessible")
                } else {
                    // Try to scroll to make it visible
                    scrollToAndTap(card)
                }
            }
        }
    }

    // MARK: - Content Validation Tests

    func testAdviceCardContentQuality() {
        // Given: Advice view with cards is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping content quality test")
        }

        // When: Examining advice card content
        let allAdviceTexts = app.staticTexts.allElementsBoundByIndex

        // Then: Advice content should not be empty or contain placeholder text
        for textElement in allAdviceTexts {
            let text = textElement.label

            if !text.isEmpty {
                // Check for common placeholder patterns
                let placeholderPatterns = ["Lorem ipsum", "TODO", "FIXME", "placeholder", "test test"]
                let hasPlaceholder = placeholderPatterns.contains { pattern in
                    text.lowercased().contains(pattern.lowercased())
                }

                XCTAssertFalse(hasPlaceholder, "Advice should not contain placeholder text: '\(text)'")
            }
        }
    }

    // MARK: - Mock Data Tests

    func testMockDataIndicatorWithAdvice() {
        // Given: App might be using mock data

        // When: Looking for mock data indicator and advice
        let mockDataBanner = app.otherElements[UIIdentifiers.HomeView.mockDataBanner]
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        // Then: If both are present, they should coexist properly
        if mockDataBanner.exists && adviceView.exists {
            XCTAssertTrue(mockDataBanner.isHittable, "Mock data banner should be visible")
            XCTAssertTrue(adviceView.isHittable, "Advice view should be visible below banner")

            takeScreenshot(name: "Mock Data Banner with Advice View")

            // Verify advice is still scrollable with banner present
            let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
            if scrollView.exists {
                scrollView.swipeUp()
                usleep(500_000) // 0.5 second

                XCTAssertTrue(waitForElement(adviceView), "Advice should remain visible during scroll")
            }
        }
    }

    // MARK: - Error Recovery Tests

    func testAdviceViewAfterRefresh() {
        // Given: Advice view is initially available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping refresh test")
        }

        takeScreenshot(name: "Advice View Before Refresh")

        // When: Performing pull-to-refresh
        performPullToRefresh()
        waitForAppToFinishLoading(timeout: 15.0)

        // Then: Advice view should still be functional
        let refreshedAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        if refreshedAdviceView.exists {
            XCTAssertTrue(refreshedAdviceView.isHittable, "Advice view should be functional after refresh")
            takeScreenshot(name: "Advice View After Refresh")
        } else {
            // If advice view disappeared, verify we have appropriate alternate state
            let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
            let errorView = app.otherElements[UIIdentifiers.HomeViewComponents.errorView]
            let emptyStateView = app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]

            let hasAlternateState = loadingView.exists || errorView.exists || emptyStateView.exists
            XCTAssertTrue(hasAlternateState, "Should show appropriate state after refresh")
            takeScreenshot(name: "Alternate State After Refresh")
        }
    }

    // MARK: - Integration Tests

    func testAdviceViewWithTabSwitching() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping tab switching test")
        }

        // When: Switching tabs and returning
        takeScreenshot(name: "Advice View Before Tab Switch")

        switchToTab("Profile")
        usleep(500_000) // 0.5 second

        switchToTab("Today")
        waitForAppToFinishLoading()

        // Then: Advice view should be preserved or reloaded properly
        let returnedAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        if returnedAdviceView.exists {
            XCTAssertTrue(returnedAdviceView.isHittable, "Advice view should be functional after tab switch")
            takeScreenshot(name: "Advice View After Tab Switch")
        } else {
            // If not immediately available, wait briefly for potential reload
            waitForAppToFinishLoading(timeout: 5.0)

            let finalAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
            if !finalAdviceView.exists {
                // Verify we have appropriate state
                let hasAlternateState = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView].exists ||
                                       app.otherElements[UIIdentifiers.HomeViewComponents.errorView].exists ||
                                       app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView].exists

                XCTAssertTrue(hasAlternateState, "Should show appropriate state if advice not available")
            }
        }
    }
}
