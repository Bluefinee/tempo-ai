//
//  TempoAIUITestsLaunchTests.swift
//  TempoAIUITests
//
//  Created by 岩原正和 on 2026/01/01.
//

import XCTest

final class TempoAIUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Capture screenshot of initial launch state
        // TODO: Add navigation to key screens once implemented
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
