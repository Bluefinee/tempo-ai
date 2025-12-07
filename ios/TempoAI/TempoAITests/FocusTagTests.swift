import XCTest
@testable import TempoAI

class FocusTagTests: XCTestCase {
    
    func testFocusTagEmojis() {
        XCTAssertEqual(FocusTag.work.emoji, "🧠")
        XCTAssertEqual(FocusTag.beauty.emoji, "✨")
        XCTAssertEqual(FocusTag.diet.emoji, "🥗")
        XCTAssertEqual(FocusTag.chill.emoji, "🍃")
    }
    
    func testFocusTagDisplayNames() {
        XCTAssertEqual(FocusTag.work.displayName, "深い集中（仕事）")
        XCTAssertEqual(FocusTag.beauty.displayName, "美容・肌")
        XCTAssertEqual(FocusTag.diet.displayName, "食事・代謝")
        XCTAssertEqual(FocusTag.chill.displayName, "リラックス")
    }
    
    func testFocusTagDescriptions() {
        XCTAssertFalse(FocusTag.work.description.isEmpty)
        XCTAssertFalse(FocusTag.beauty.description.isEmpty)
        XCTAssertFalse(FocusTag.diet.description.isEmpty)
        XCTAssertFalse(FocusTag.chill.description.isEmpty)
    }
    
    func testAnalysisLensStructure() {
        let workLens = FocusTag.work.analysisLens
        XCTAssertTrue(workLens.focusAreas.contains("脳のパフォーマンス"))
        XCTAssertTrue(workLens.keyMetrics.contains("HRV"))
        XCTAssertTrue(workLens.environmentFactors.contains("気圧"))
    }
}

class FocusTagManagerTests: XCTestCase {
    var tagManager: FocusTagManager!
    
    override func setUp() {
        super.setUp()
        tagManager = FocusTagManager()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "active_focus_tags")
        UserDefaults.standard.removeObject(forKey: "focus_tags_onboarding_completed")
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(tagManager.activeTags.isEmpty)
        XCTAssertFalse(tagManager.hasCompletedOnboarding)
    }
    
    func testToggleTag() {
        tagManager.toggleTag(.work)
        XCTAssertTrue(tagManager.activeTags.contains(.work))
        
        tagManager.toggleTag(.work)
        XCTAssertFalse(tagManager.activeTags.contains(.work))
    }
    
    func testMultipleTagSelection() {
        tagManager.toggleTag(.work)
        tagManager.toggleTag(.beauty)
        
        XCTAssertEqual(tagManager.activeTags.count, 2)
        XCTAssertTrue(tagManager.activeTags.contains(.work))
        XCTAssertTrue(tagManager.activeTags.contains(.beauty))
    }
    
    func testOnboardingCompletion() {
        tagManager.toggleTag(.work)
        tagManager.completeOnboarding()
        
        XCTAssertTrue(tagManager.hasCompletedOnboarding)
        
        let newManager = FocusTagManager()
        XCTAssertTrue(newManager.hasCompletedOnboarding)
        XCTAssertTrue(newManager.activeTags.contains(.work))
    }
}