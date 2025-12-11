import XCTest
@testable import TempoAI

final class DailyAdviceModelTests: XCTestCase {
    
    // MARK: - DailyAdvice Mock Creation Tests
    
    func testDailyAdviceCreateMock() {
        let advice = DailyAdvice.createMock()
        
        XCTAssertFalse(advice.greeting.isEmpty, "Greeting should not be empty")
        XCTAssertFalse(advice.condition.summary.isEmpty, "Condition summary should not be empty")
        XCTAssertFalse(advice.condition.detail.isEmpty, "Condition detail should not be empty")
        XCTAssertGreaterThan(advice.actionSuggestions.count, 0, "Should have action suggestions")
        XCTAssertFalse(advice.closingMessage.isEmpty, "Closing message should not be empty")
        XCTAssertFalse(advice.dailyTry.title.isEmpty, "Daily try title should not be empty")
    }
    
    func testDailyAdviceTimeSlots() {
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
    
    func testIconTypeSystemImages() {
        XCTAssertEqual(IconType.fitness.systemImageName, "figure.strengthtraining.functional", "Fitness icon should be correct")
        XCTAssertEqual(IconType.nutrition.systemImageName, "fork.knife", "Nutrition icon should be correct")
        XCTAssertEqual(IconType.sleep.systemImageName, "moon.stars.fill", "Sleep icon should be correct")
    }
    
    func testIconTypeDisplayNames() {
        XCTAssertEqual(IconType.fitness.displayName, "フィットネス", "Fitness display name should be correct")
        XCTAssertEqual(IconType.nutrition.displayName, "栄養", "Nutrition display name should be correct")
        XCTAssertEqual(IconType.sleep.displayName, "睡眠", "Sleep display name should be correct")
    }
    
    // MARK: - Codable Tests
    
    func testDailyAdviceCodable() throws {
        let advice = DailyAdvice.createMock()
        
        let encodedData = try JSONEncoder().encode(advice)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: encodedData)
        
        XCTAssertEqual(decodedAdvice.greeting, advice.greeting, "Decoded greeting should match")
        XCTAssertEqual(decodedAdvice.condition.summary, advice.condition.summary, "Decoded condition summary should match")
        XCTAssertEqual(decodedAdvice.timeSlot, advice.timeSlot, "Decoded time slot should match")
    }
    
    // MARK: - MockData Tests
    
    func testMockDataGreetingLogic() {
        #if DEBUG
        let testNickname = "テストユーザー"
        let greeting = MockData.getCurrentGreeting(nickname: testNickname)
        
        XCTAssertTrue(greeting.contains(testNickname), "Greeting should contain nickname")
        XCTAssertTrue(greeting.contains("さん、"), "Greeting should contain honorific")
        
        // Should contain one of the time-based greetings
        let timeGreetings = ["おはようございます", "こんにちは", "お疲れさまです"]
        let containsTimeGreeting = timeGreetings.contains { greeting.contains($0) }
        XCTAssertTrue(containsTimeGreeting, "Greeting should contain time-based greeting")
        #endif
    }
    
    func testMockDataDateFormatting() {
        #if DEBUG
        let dateString = MockData.getCurrentDateString()
        
        XCTAssertTrue(dateString.contains("月"), "Date should contain Japanese month")
        XCTAssertTrue(dateString.contains("日"), "Date should contain Japanese day")
        XCTAssertFalse(dateString.isEmpty, "Date string should not be empty")
        #endif
    }
    
    func testMockWeatherConsistency() {
        #if DEBUG
        let weather = MockData.mockWeather
        
        XCTAssertEqual(weather.cityName, "東京", "Mock city should be Tokyo")
        XCTAssertEqual(weather.temperature, 24, "Mock temperature should be 24")
        XCTAssertEqual(weather.weatherIcon, "☀️", "Mock weather icon should be sunny")
        #endif
    }
}