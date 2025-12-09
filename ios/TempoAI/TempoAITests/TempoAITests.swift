import XCTest
@testable import TempoAI

final class TempoAITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

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
