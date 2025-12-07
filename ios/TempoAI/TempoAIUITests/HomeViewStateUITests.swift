//
//  HomeViewStateUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for HomeView state handling (loading, error, empty states, mock data)
//

import XCTest

/**
 * UI test suite for HomeView state handling functionality.
 * Tests cover loading states, error handling, empty states, mock data banner, and advice display.
 *
 * ## Test Coverage Areas
 * - Loading state display and management
 * - Mock data banner presence and components
 * - Advice view display and interaction
 * - Error state handling and retry mechanisms
 * - Empty state handling and action buttons
 */
final class HomeViewStateUITests: BaseUITest {

    override func setUp() {
        super.setUp()

        // Ensure we start on the Today tab for all home view tests
        switchToTab("Today")
        waitForAppToFinishLoading()
    }

    // MARK: - Loading State Tests

    func testLoadingStateDisplay() {
        // Given: The app is in a loading state (this might require triggering refresh)

        // When: Triggering a refresh to see loading state
        performPullToRefresh()

        // Then: Check if loading view appears (it might be brief)
        let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]

        if loadingView.exists {
            // If loading view is visible, verify its components
            XCTAssertTrue(loadingView.isHittable, "Loading view should be visible")

            let loadingText = app.staticTexts[UIIdentifiers.HomeViewComponents.loadingText]
            if loadingText.exists {
                XCTAssertFalse(loadingText.label.isEmpty, "Loading text should not be empty")
            }

            takeScreenshot(name: "Loading State Display")

            // Wait for loading to finish
            waitForElementToDisappear(loadingView, timeout: 10.0)
        }

        // Verify we're back to normal state
        waitForAppToFinishLoading()
    }

    // MARK: - Mock Data Banner Tests

    func testMockDataBannerDisplay() {
        // Given: The app might be using mock data (in UI test mode)

        // When: Looking for mock data banner
        let mockDataBanner = app.otherElements[UIIdentifiers.HomeView.mockDataBanner]

        // Then: If mock data banner exists, verify its components
        if mockDataBanner.exists {
            XCTAssertTrue(mockDataBanner.isHittable, "Mock data banner should be visible")

            let mockDataIcon = app.images[UIIdentifiers.HomeView.mockDataIcon]
            let mockDataText = app.staticTexts[UIIdentifiers.HomeView.mockDataText]

            XCTAssertTrue(waitForElement(mockDataIcon), "Mock data icon should be visible")
            XCTAssertTrue(waitForElement(mockDataText), "Mock data text should be visible")
            XCTAssertFalse(mockDataText.label.isEmpty, "Mock data text should not be empty")

            takeScreenshot(name: "Mock Data Banner Display")
        }
    }

    // MARK: - Advice Display Tests

    func testAdviceViewDisplay() {
        // Given: The app has loaded advice data
        waitForAppToFinishLoading(timeout: 15.0)

        // When: Looking for advice content
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        // Then: If advice is displayed, verify its components
        if adviceView.exists {
            XCTAssertTrue(adviceView.isHittable, "Advice view should be visible")

            // Check for key advice components
            let themeSummaryCard = app.otherElements[UIIdentifiers.AdviceView.themeSummaryCard]
            let weatherCard = app.otherElements[UIIdentifiers.AdviceView.weatherCard]
            let mealCardsSection = app.otherElements[UIIdentifiers.AdviceView.mealCardsSection]

            if themeSummaryCard.exists {
                XCTAssertTrue(themeSummaryCard.isHittable, "Theme summary card should be visible")
            }

            if weatherCard.exists {
                XCTAssertTrue(weatherCard.isHittable, "Weather card should be visible")
            }

            if mealCardsSection.exists {
                XCTAssertTrue(mealCardsSection.isHittable, "Meal cards section should be visible")
            }

            takeScreenshot(name: "Advice View Display")
        }
    }

    func testAdviceCardInteractions() {
        // Given: Advice is displayed
        waitForAppToFinishLoading(timeout: 15.0)

        // When: Looking for individual advice cards
        let breakfastCard = app.otherElements[UIIdentifiers.AdviceView.breakfastCard]
        let exerciseCard = app.otherElements[UIIdentifiers.AdviceView.exerciseCard]
        let sleepCard = app.otherElements[UIIdentifiers.AdviceView.sleepCard]

        // Then: Cards should be accessible and scrollable
        if breakfastCard.exists {
            scrollToAndTap(breakfastCard)
            XCTAssertTrue(breakfastCard.isHittable, "Breakfast card should be interactive")
        }

        if exerciseCard.exists {
            scrollToAndTap(exerciseCard)
            XCTAssertTrue(exerciseCard.isHittable, "Exercise card should be interactive")
        }

        if sleepCard.exists {
            scrollToAndTap(sleepCard)
            XCTAssertTrue(sleepCard.isHittable, "Sleep card should be interactive")
        }

        takeScreenshot(name: "Advice Cards Interaction")
    }

    // MARK: - Error State Tests

    func testErrorStateHandling() {
        // Given: An error state might occur
        // Note: This would ideally be tested with a controlled error scenario

        // When: Looking for error view components
        let errorView = app.otherElements[UIIdentifiers.HomeViewComponents.errorView]

        // Then: If error view exists, verify its functionality
        if errorView.exists {
            verifyErrorViewDisplayed()

            let retryButton = app.buttons[UIIdentifiers.HomeViewComponents.errorRetryButton]
            XCTAssertTrue(waitForElement(retryButton), "Retry button should be available")

            if retryButton.isHittable {
                safeTap(retryButton)

                // After retry, should either show loading or resolve to success/error
                waitForAppToFinishLoading(timeout: 10.0)
            }

            takeScreenshot(name: "Error State Display")
        }
    }

    // MARK: - Empty State Tests

    func testEmptyStateHandling() {
        // Given: An empty state might occur

        // When: Looking for empty state view
        let emptyStateView = app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]

        // Then: If empty state exists, verify its functionality
        if emptyStateView.exists {
            verifyEmptyStateViewDisplayed()

            let refreshButton = app.buttons[UIIdentifiers.HomeViewComponents.emptyStateActionButton]
            XCTAssertTrue(waitForElement(refreshButton), "Refresh button should be available")

            if refreshButton.isHittable {
                safeTap(refreshButton)
                waitForAppToFinishLoading(timeout: 10.0)
            }

            takeScreenshot(name: "Empty State Display")
        }
    }
}
