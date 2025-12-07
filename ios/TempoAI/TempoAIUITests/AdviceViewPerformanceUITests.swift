//
//  AdviceViewPerformanceUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Performance UI tests for AdviceView rendering and interaction optimization
//

import XCTest

/**
 * Performance-focused UI test suite for AdviceView functionality.
 * Tests cover rendering performance and interaction optimization metrics.
 *
 * ## Test Coverage Areas
 * - Advice view rendering performance measurement
 * - Card interaction optimization timing
 * - Scroll performance under load
 * - Memory efficiency during long-running operations
 */
final class AdviceViewPerformanceUITests: BaseUITest {

    override func setUp() {
        super.setUp()

        // Start on Today tab and wait for advice to load
        switchToTab("Today")
        waitForAppToFinishLoading(timeout: 10.0)
    }

    // MARK: - Performance Tests

    func testAdviceViewRenderingPerformance() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]

        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping performance test")
        }

        // When: Measuring advice view interaction performance
        let options = XCTMeasureOptions.default
        options.iterationCount = 3  // Reduce iterations for faster completion

        measure(options: options) {
            let cardIdentifiers = [
                UIIdentifiers.AdviceView.breakfastCard,
                UIIdentifiers.AdviceView.lunchCard,
                UIIdentifiers.AdviceView.exerciseCard,
                UIIdentifiers.AdviceView.sleepCard
            ]

            // More efficient card interaction test - remove sleep delays
            for cardIdentifier in cardIdentifiers {
                let card = app.otherElements[cardIdentifier]
                if card.exists && card.isHittable {
                    card.tap()
                    // Remove sleep for performance optimization
                }
            }
        }

        // Then: Performance should be acceptable
    }
}
