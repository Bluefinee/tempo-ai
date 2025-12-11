import XCTest
@testable import TempoAI

final class DailyAdviceExtensionTests: XCTestCase {
    
    // MARK: - DailyAdvice Tests
    
    func testDailyAdviceCreation() {
        let advice = DailyAdvice.createMock()
        
        XCTAssertFalse(advice.greeting.isEmpty, "Greeting should not be empty")
        XCTAssertFalse(advice.condition.summary.isEmpty, "Condition summary should not be empty")
        XCTAssertFalse(advice.condition.detail.isEmpty, "Condition detail should not be empty")
        XCTAssertGreaterThan(advice.actionSuggestions.count, 0, "Should have action suggestions")
        XCTAssertFalse(advice.closingMessage.isEmpty, "Closing message should not be empty")
        XCTAssertFalse(advice.dailyTry.title.isEmpty, "Daily try title should not be empty")
    }
    
    func testDailyAdviceTimeSlotSpecific() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)
        
        XCTAssertEqual(morningAdvice.timeSlot, .morning, "Morning advice should have morning time slot")
        XCTAssertEqual(afternoonAdvice.timeSlot, .afternoon, "Afternoon advice should have afternoon time slot")
        XCTAssertEqual(eveningAdvice.timeSlot, .evening, "Evening advice should have evening time slot")
        
        // Morning should have weekly try, others should not
        XCTAssertNotNil(morningAdvice.weeklyTry, "Morning advice should have weekly try")
        XCTAssertNil(afternoonAdvice.weeklyTry, "Afternoon advice should not have weekly try")
        XCTAssertNil(eveningAdvice.weeklyTry, "Evening advice should not have weekly try")
    }
    
    func testDailyAdviceGreetingConsistency() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)
        
        XCTAssertTrue(morningAdvice.greeting.contains("おはようございます"), "Morning greeting should contain morning phrase")
        XCTAssertTrue(afternoonAdvice.greeting.contains("お疲れさまです"), "Afternoon greeting should contain afternoon phrase")
        XCTAssertTrue(eveningAdvice.greeting.contains("お疲れさまでした"), "Evening greeting should contain evening phrase")
    }
    
    // MARK: - TimeSlot Tests
    
    func testTimeSlotDisplayNames() {
        XCTAssertEqual(TimeSlot.morning.displayName, "朝", "Morning display name should be correct")
        XCTAssertEqual(TimeSlot.afternoon.displayName, "昼", "Afternoon display name should be correct")
        XCTAssertEqual(TimeSlot.evening.displayName, "夜", "Evening display name should be correct")
    }
    
    func testTimeSlotGreetings() {
        XCTAssertEqual(TimeSlot.morning.greeting, "おはようございます", "Morning greeting should be correct")
        XCTAssertEqual(TimeSlot.afternoon.greeting, "お疲れさまです", "Afternoon greeting should be correct")
        XCTAssertEqual(TimeSlot.evening.greeting, "お疲れさまでした", "Evening greeting should be correct")
    }
    
    // MARK: - IconType Tests
    
    func testIconTypeSystemImageNames() {
        XCTAssertEqual(IconType.fitness.systemImageName, "figure.strengthtraining.functional", "Fitness icon should be correct")
        XCTAssertEqual(IconType.stretch.systemImageName, "figure.yoga", "Stretch icon should be correct")
        XCTAssertEqual(IconType.nutrition.systemImageName, "fork.knife", "Nutrition icon should be correct")
        XCTAssertEqual(IconType.hydration.systemImageName, "drop.fill", "Hydration icon should be correct")
        XCTAssertEqual(IconType.sleep.systemImageName, "moon.stars.fill", "Sleep icon should be correct")
    }
    
    func testIconTypeDisplayNames() {
        XCTAssertEqual(IconType.fitness.displayName, "フィットネス", "Fitness display name should be correct")
        XCTAssertEqual(IconType.stretch.displayName, "ストレッチ", "Stretch display name should be correct")
        XCTAssertEqual(IconType.nutrition.displayName, "栄養", "Nutrition display name should be correct")
        XCTAssertEqual(IconType.mental.displayName, "メンタル", "Mental display name should be correct")
        XCTAssertEqual(IconType.beauty.displayName, "美容", "Beauty display name should be correct")
    }
    
    // MARK: - ActionSuggestion Tests
    
    func testActionSuggestionCreation() {
        let advice = DailyAdvice.createMock()
        let firstAction = advice.actionSuggestions.first
        
        XCTAssertNotNil(firstAction, "Should have at least one action suggestion")
        XCTAssertFalse(firstAction!.title.isEmpty, "Action title should not be empty")
        XCTAssertFalse(firstAction!.detail.isEmpty, "Action detail should not be empty")
        XCTAssertNotNil(firstAction!.icon, "Action should have an icon")
    }
    
    // MARK: - TryContent Tests
    
    func testTryContentStructure() {
        let advice = DailyAdvice.createMock()
        let dailyTry = advice.dailyTry
        
        XCTAssertFalse(dailyTry.title.isEmpty, "Daily try title should not be empty")
        XCTAssertFalse(dailyTry.summary.isEmpty, "Daily try summary should not be empty")
        XCTAssertFalse(dailyTry.detail.isEmpty, "Daily try detail should not be empty")
        
        // Test weekly try for morning advice
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        if let weeklyTry = morningAdvice.weeklyTry {
            XCTAssertFalse(weeklyTry.title.isEmpty, "Weekly try title should not be empty")
            XCTAssertFalse(weeklyTry.summary.isEmpty, "Weekly try summary should not be empty")
            XCTAssertFalse(weeklyTry.detail.isEmpty, "Weekly try detail should not be empty")
        }
    }
    
    // MARK: - Codable Tests
    
    func testDailyAdviceCodable() throws {
        let advice = DailyAdvice.createMock()
        
        // Test encoding
        let encodedData = try JSONEncoder().encode(advice)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        // Test decoding
        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: encodedData)
        
        XCTAssertEqual(decodedAdvice.greeting, advice.greeting, "Decoded greeting should match")
        XCTAssertEqual(decodedAdvice.condition.summary, advice.condition.summary, "Decoded condition summary should match")
        XCTAssertEqual(decodedAdvice.timeSlot, advice.timeSlot, "Decoded time slot should match")
        XCTAssertEqual(decodedAdvice.actionSuggestions.count, advice.actionSuggestions.count, "Decoded action suggestions count should match")
    }
    
    func testConditionCodable() throws {
        let condition = Condition(summary: "テストサマリー", detail: "テスト詳細")
        
        let encodedData = try JSONEncoder().encode(condition)
        let decodedCondition = try JSONDecoder().decode(Condition.self, from: encodedData)
        
        XCTAssertEqual(decodedCondition.summary, condition.summary, "Decoded summary should match")
        XCTAssertEqual(decodedCondition.detail, condition.detail, "Decoded detail should match")
    }
    
    func testActionSuggestionCodable() throws {
        let action = ActionSuggestion(icon: .fitness, title: "テストタイトル", detail: "テスト詳細")
        
        let encodedData = try JSONEncoder().encode(action)
        let decodedAction = try JSONDecoder().decode(ActionSuggestion.self, from: encodedData)
        
        XCTAssertEqual(decodedAction.icon, action.icon, "Decoded icon should match")
        XCTAssertEqual(decodedAction.title, action.title, "Decoded title should match")
        XCTAssertEqual(decodedAction.detail, action.detail, "Decoded detail should match")
    }
    
    // MARK: - MockData Tests Extension
    
    func testMockDataTimeZoneHandling() {
        #if DEBUG
        let dateString = MockData.getCurrentDateString()
        
        // Should be in Japanese format
        XCTAssertTrue(dateString.contains("月"), "Date should contain Japanese month character")
        XCTAssertTrue(dateString.contains("日"), "Date should contain Japanese day character")
        
        // Check for Japanese weekday
        let weekdays = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
        let containsWeekday = weekdays.contains { dateString.contains($0) }
        XCTAssertTrue(containsWeekday, "Date should contain Japanese weekday")
        #endif
    }
    
    func testMockDataGreetingEdgeCases() {
        #if DEBUG
        let testNickname = "エッジケース"
        
        // Test with empty nickname
        let emptyNicknameGreeting = MockData.getCurrentGreeting(nickname: "")
        XCTAssertTrue(emptyNicknameGreeting.contains("さん、"), "Should still contain san even with empty nickname")
        
        // Test with special characters
        let specialCharNickname = "テスト★♪"
        let specialCharGreeting = MockData.getCurrentGreeting(nickname: specialCharNickname)
        XCTAssertTrue(specialCharGreeting.contains(specialCharNickname), "Should handle special characters in nickname")
        #endif
    }
    
    func testMockWeatherDataConsistency() {
        #if DEBUG
        let weather1 = MockData.mockWeather
        let weather2 = MockData.mockWeather
        
        XCTAssertEqual(weather1.cityName, weather2.cityName, "Mock weather city should be consistent")
        XCTAssertEqual(weather1.temperature, weather2.temperature, "Mock weather temperature should be consistent")
        XCTAssertEqual(weather1.weatherIcon, weather2.weatherIcon, "Mock weather icon should be consistent")
        #endif
    }
}