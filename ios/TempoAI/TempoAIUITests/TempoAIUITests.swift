//
//  TempoAIUITests.swift
//  TempoAIUITests
//
//  Created by 岩原正和 on 2026/01/01.
//

import XCTest

final class TempoAIUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        // Verify that the app launches successfully
        let app = XCUIApplication()
        app.launch()

        // TODO: Add UI assertions when main screens are implemented
        // Example: XCTAssertTrue(app.staticTexts["TempoAI"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
