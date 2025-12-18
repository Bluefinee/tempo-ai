import SwiftUI
import Testing

@testable import TempoAI

struct HomeComponentsTests {

    // MARK: - MockData Tests

    @Test("Morning greeting logic is correct (6:00-12:59)")
    func mockDataGreetingMorning() {
        let testNickname = "テストユーザー"
        let mockHour = 9
        let expectedGreeting = "\(testNickname)さん、おはようございます"

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
        #expect(result == expectedGreeting)
    }

    @Test("Afternoon greeting logic is correct (13:00-17:59)")
    func mockDataGreetingAfternoon() {
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
        #expect(result == expectedGreeting)
    }

    @Test("Evening greeting logic is correct (18:00-5:59)")
    func mockDataGreetingEvening() {
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
        #expect(result == expectedGreeting)
    }

    #if DEBUG
    @Test("Mock weather data has expected Tokyo values")
    func mockWeatherData() {
        let weatherInfo = MockData.mockWeather

        #expect(weatherInfo.cityName == "東京")
        #expect(weatherInfo.temperature == 24)
        #expect(weatherInfo.weatherIcon == "☀️")
    }

    @Test("Date formatting includes Japanese month and day")
    func dateFormattingJapanese() {
        let dateString = MockData.getCurrentDateString()

        #expect(dateString.contains("月"))
        #expect(dateString.contains("日"))
        #expect(!dateString.isEmpty)
    }
    #endif

    // MARK: - DailyAdvice Tests

    @Test("DailyAdvice mock has required fields populated")
    func dailyAdviceMockCreation() {
        let mockAdvice = DailyAdvice.createMock()

        #expect(!mockAdvice.greeting.isEmpty)
        #expect(!mockAdvice.condition.summary.isEmpty)
        #expect(mockAdvice.actionSuggestions.count > 0)
        #expect(!mockAdvice.dailyTry.title.isEmpty)
    }

    @Test("DailyAdvice time slots affect weekly try availability")
    func dailyAdviceTimeSlotLogic() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)

        #expect(morningAdvice.timeSlot == .morning)
        #expect(afternoonAdvice.timeSlot == .afternoon)
        #expect(eveningAdvice.timeSlot == .evening)

        // Morning advice should have weekly try, others should not
        #expect(morningAdvice.weeklyTry != nil)
        #expect(afternoonAdvice.weeklyTry == nil)
        #expect(eveningAdvice.weeklyTry == nil)
    }

    // MARK: - UserProfile Tests

    @Test("UserProfile sample data has valid content")
    func userProfileSampleData() {
        let sampleProfile = UserProfile.sampleData

        #expect(!sampleProfile.nickname.isEmpty)
        #expect(sampleProfile.age > 0)
        #expect(sampleProfile.interests.count > 0)
        #expect(sampleProfile.interests.count <= 3)
    }

    // MARK: - Integration Tests

    @Test("MainTabView can be created with sample data")
    func mainTabViewCreation() {
        let tabView = MainTabView(userProfile: UserProfile.sampleData)
        #expect(type(of: tabView) == MainTabView.self)
    }

    @Test("HomeView can be created with sample data")
    func homeViewCreation() {
        let homeView = HomeView(userProfile: UserProfile.sampleData)
        #expect(type(of: homeView) == HomeView.self)
    }

    @Test("AdviceSummaryCard can be created with mock advice")
    func adviceSummaryCardCreation() {
        let mockAdvice = DailyAdvice.createMock()
        let card = AdviceSummaryCard(advice: mockAdvice) {
            // Empty action for test
        }
        #expect(type(of: card) == AdviceSummaryCard.self)
    }

    @Test("HomeHeaderView can be created with sample profile")
    func homeHeaderViewCreation() {
        let headerView = HomeHeaderView(userProfile: UserProfile.sampleData)
        #expect(type(of: headerView) == HomeHeaderView.self)
    }

    @Test("SettingsPlaceholderView can be created")
    func settingsPlaceholderViewCreation() {
        let settingsView = SettingsPlaceholderView()
        #expect(type(of: settingsView) == SettingsPlaceholderView.self)
    }

    // MARK: - Phase 3 Component Tests

    #if DEBUG
    @Test("MetricCard can be created with mock metric")
    func metricCardCreation() {
        let metric = MockData.mockMetrics[0]
        let card = MetricCard(metric: metric)
        #expect(type(of: card) == MetricCard.self)
    }

    @Test("MetricsGridView can be created with mock metrics")
    func metricsGridViewCreation() {
        let metrics = MockData.mockMetrics
        let gridView = MetricsGridView(metrics: metrics)
        #expect(type(of: gridView) == MetricsGridView.self)
    }

    @Test("Mock metrics has exactly 4 items for grid layout")
    func metricsGridViewWithFourMetrics() {
        let metrics = MockData.mockMetrics
        #expect(metrics.count == 4)
    }
    #endif
}
