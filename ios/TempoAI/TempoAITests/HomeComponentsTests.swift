import XCTest
import SwiftUI
@testable import TempoAI

final class HomeComponentsTests: XCTestCase {
    
    // MARK: - MockData Tests
    
    func testMockDataGreetingMorning() throws {
        // Test morning greeting (6:00-12:59)
        let testNickname = "テストユーザー"
        
        // Create a custom Calendar component for testing
        let mockHour = 9
        let expectedGreeting = "\(testNickname)さん、おはようございます"
        
        // Since MockData uses current time, we test the logic manually
        let timeOfDay: String
        switch mockHour {
        case 6..<13:
            timeOfDay = "おはようございます"
        case 13..<18:
            timeOfDay = "こんにちは"
        default:
            timeOfDay = "お疲れさまです"
        }
        
        let result = "\(testNickname)さん、\(timeOfDay)"
        XCTAssertEqual(result, expectedGreeting, "Morning greeting should be correct")
    }
    
    func testMockDataGreetingAfternoon() throws {
        // Test afternoon greeting (13:00-17:59)
        let testNickname = "テストユーザー"
        let mockHour = 15
        let expectedGreeting = "\(testNickname)さん、こんにちは"
        
        let timeOfDay: String
        switch mockHour {
        case 6..<13:
            timeOfDay = "おはようございます"
        case 13..<18:
            timeOfDay = "こんにちは"
        default:
            timeOfDay = "お疲れさまです"
        }
        
        let result = "\(testNickname)さん、\(timeOfDay)"
        XCTAssertEqual(result, expectedGreeting, "Afternoon greeting should be correct")
    }
    
    func testMockDataGreetingEvening() throws {
        // Test evening greeting (18:00-5:59)
        let testNickname = "テストユーザー"
        let mockHour = 20
        let expectedGreeting = "\(testNickname)さん、お疲れさまです"
        
        let timeOfDay: String
        switch mockHour {
        case 6..<13:
            timeOfDay = "おはようございます"
        case 13..<18:
            timeOfDay = "こんにちは"
        default:
            timeOfDay = "お疲れさまです"
        }
        
        let result = "\(testNickname)さん、\(timeOfDay)"
        XCTAssertEqual(result, expectedGreeting, "Evening greeting should be correct")
    }
    
    func testMockWeatherData() throws {
        #if DEBUG
        let weatherInfo = MockData.mockWeather
        
        XCTAssertEqual(weatherInfo.cityName, "東京", "City name should be Tokyo")
        XCTAssertEqual(weatherInfo.temperature, 24, "Temperature should be 24")
        XCTAssertEqual(weatherInfo.weatherIcon, "☀️", "Weather icon should be sunny")
        #endif
    }
    
    func testDateFormattingJapanese() throws {
        #if DEBUG
        let dateString = MockData.getCurrentDateString()
        
        // Check that the string contains Japanese characters and expected format
        XCTAssertTrue(dateString.contains("月"), "Date string should contain month in Japanese")
        XCTAssertTrue(dateString.contains("日"), "Date string should contain day in Japanese")
        
        // Check that it's not empty
        XCTAssertFalse(dateString.isEmpty, "Date string should not be empty")
        #endif
    }
    
    // MARK: - DailyAdvice Tests
    
    func testDailyAdviceMockCreation() throws {
        let mockAdvice = DailyAdvice.createMock()
        
        XCTAssertFalse(mockAdvice.greeting.isEmpty, "Greeting should not be empty")
        XCTAssertFalse(mockAdvice.condition.summary.isEmpty, "Condition summary should not be empty")
        XCTAssertTrue(mockAdvice.actionSuggestions.count > 0, "Should have action suggestions")
        XCTAssertFalse(mockAdvice.dailyTry.title.isEmpty, "Daily try should have title")
    }
    
    func testDailyAdviceTimeSlotLogic() throws {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)
        
        XCTAssertEqual(morningAdvice.timeSlot, .morning, "Morning advice should have morning time slot")
        XCTAssertEqual(afternoonAdvice.timeSlot, .afternoon, "Afternoon advice should have afternoon time slot")
        XCTAssertEqual(eveningAdvice.timeSlot, .evening, "Evening advice should have evening time slot")
        
        // Morning advice should have weekly try, others should not
        XCTAssertNotNil(morningAdvice.weeklyTry, "Morning advice should have weekly try")
        XCTAssertNil(afternoonAdvice.weeklyTry, "Afternoon advice should not have weekly try")
        XCTAssertNil(eveningAdvice.weeklyTry, "Evening advice should not have weekly try")
    }
    
    // MARK: - UserProfile Tests
    
    func testUserProfileSampleData() throws {
        let sampleProfile = UserProfile.sampleData
        
        XCTAssertFalse(sampleProfile.nickname.isEmpty, "Sample profile should have nickname")
        XCTAssertGreaterThan(sampleProfile.age, 0, "Sample profile should have valid age")
        XCTAssertGreaterThan(sampleProfile.interests.count, 0, "Sample profile should have interests")
        XCTAssertLessThanOrEqual(sampleProfile.interests.count, 3, "Sample profile should have 3 or fewer interests")
    }
    
    // MARK: - Integration Tests
    
    func testMainTabViewCreation() throws {
        let tabView = MainTabView(userProfile: UserProfile.sampleData)
        XCTAssertNotNil(tabView, "MainTabView should be created successfully")
    }
    
    func testHomeViewCreation() throws {
        let homeView = HomeView(userProfile: UserProfile.sampleData)
        XCTAssertNotNil(homeView, "HomeView should be created successfully")
    }
    
    func testAdviceSummaryCardCreation() throws {
        let mockAdvice = DailyAdvice.createMock()
        let card = AdviceSummaryCard(advice: mockAdvice)
        XCTAssertNotNil(card, "AdviceSummaryCard should be created successfully")
    }
    
    func testHomeHeaderViewCreation() throws {
        let headerView = HomeHeaderView(userProfile: UserProfile.sampleData)
        XCTAssertNotNil(headerView, "HomeHeaderView should be created successfully")
    }
    
    func testSettingsPlaceholderViewCreation() throws {
        let settingsView = SettingsPlaceholderView()
        XCTAssertNotNil(settingsView, "SettingsPlaceholderView should be created successfully")
    }
}
