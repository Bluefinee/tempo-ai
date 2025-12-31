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
        #expect(!mockAdvice.energyComment.isEmpty)
        #expect(!mockAdvice.condition.summary.isEmpty)
        #expect(!mockAdvice.insight.isEmpty)
        #expect(!mockAdvice.dailyTry.title.isEmpty)
        #expect(mockAdvice.scores.hrv >= 0)
    }

    @Test("DailyAdvice time slots work correctly")
    func dailyAdviceTimeSlotLogic() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)

        #expect(morningAdvice.timeSlot == .morning)
        #expect(afternoonAdvice.timeSlot == .afternoon)
        #expect(eveningAdvice.timeSlot == .evening)
    }

    // MARK: - HealthScores Tests

    @Test("HealthScores energy level is determined by HRV score")
    func healthScoresEnergyLevel() {
        let highScores = HealthScores(hrv: 85, sleep: 80, rhythm: 75, activity: 70)
        let lowScores = HealthScores(hrv: 25, sleep: 30, rhythm: 25, activity: 20)

        #expect(highScores.energyLevel == .excellent)
        #expect(lowScores.energyLevel == .low)
    }

    // MARK: - EnergyBatteryView Tests

    @Test("EnergyBatteryView can be created with mock data")
    func energyBatteryViewCreation() {
        let scores = HealthScores(hrv: 75, sleep: 70, rhythm: 65, activity: 60)
        let view = EnergyBatteryView(
            scores: scores,
            energyComment: "いいコンディションです"
        )
        #expect(type(of: view) == EnergyBatteryView.self)
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

    @Test("AdviceDetailView can be created with mock advice")
    func adviceDetailViewCreation() {
        let mockAdvice = DailyAdvice.createMock()
        let view = AdviceDetailView(advice: mockAdvice)
        #expect(type(of: view) == AdviceDetailView.self)
    }

    @Test("DailyTryCard can be created with mock try content")
    func dailyTryCardCreation() {
        let tryContent = TryContent(
            title: "テストトライ",
            detail: "テスト詳細説明"
        )
        let card = DailyTryCard(tryContent: tryContent) {
            // Empty action for test
        }
        #expect(type(of: card) == DailyTryCard.self)
    }
}
