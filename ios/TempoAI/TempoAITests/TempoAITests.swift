import XCTest

@testable import TempoAI

final class TempoAITests: XCTestCase {

  func testAppInitialization() throws {
    // Test that the app initializes without crashing
    XCTAssertNotNil(TempoAIApp(), "TempoAI app should initialize properly")
  }

  func testContentViewCreation() throws {
    // Test that ContentView can be created
    let contentView = ContentView()
    XCTAssertNotNil(contentView, "ContentView should be created successfully")
  }
}
