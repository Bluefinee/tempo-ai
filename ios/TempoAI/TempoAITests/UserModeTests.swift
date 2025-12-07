import XCTest
@testable import TempoAI

class UserModeTests: XCTestCase {
    
    func testUserModeDisplayNames() {
        XCTAssertEqual(UserMode.standard.displayName, "スタンダード")
        XCTAssertEqual(UserMode.athlete.displayName, "アスリート")
    }
    
    func testUserModeDescriptions() {
        XCTAssertFalse(UserMode.standard.description.isEmpty)
        XCTAssertFalse(UserMode.athlete.description.isEmpty)
    }
    
    func testUserModeRawValues() {
        XCTAssertEqual(UserMode.standard.rawValue, "standard")
        XCTAssertEqual(UserMode.athlete.rawValue, "athlete")
    }
    
    func testUserModeInitFromRawValue() {
        XCTAssertEqual(UserMode(rawValue: "standard"), .standard)
        XCTAssertEqual(UserMode(rawValue: "athlete"), .athlete)
        XCTAssertNil(UserMode(rawValue: "invalid"))
    }
}

class UserProfileManagerTests: XCTestCase {
    var userProfileManager: UserProfileManager!
    
    override func setUp() {
        super.setUp()
        userProfileManager = UserProfileManager()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "user_mode")
        super.tearDown()
    }
    
    func testDefaultMode() {
        XCTAssertEqual(userProfileManager.currentMode, .standard)
    }
    
    func testUpdateMode() {
        userProfileManager.updateMode(.athlete)
        XCTAssertEqual(userProfileManager.currentMode, .athlete)
    }
    
    func testModePersistence() {
        userProfileManager.updateMode(.athlete)
        
        let newManager = UserProfileManager()
        XCTAssertEqual(newManager.currentMode, .athlete)
    }
}