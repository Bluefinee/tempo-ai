import Foundation
import Testing

@testable import TempoAI

struct DailyAdviceModelTests {

    // MARK: - DailyAdvice Mock Creation Tests

    @Test("DailyAdvice.createMock() creates valid advice with all required fields")
    func dailyAdviceCreateMock() {
        let advice = DailyAdvice.createMock()

        #expect(!advice.greeting.isEmpty)
        #expect(!advice.condition.summary.isEmpty)
        #expect(!advice.condition.detail.isEmpty)
        #expect(advice.actionSuggestions.count > 0)
        #expect(!advice.closingMessage.isEmpty)
        #expect(!advice.dailyTry.title.isEmpty)
    }

    @Test("DailyAdvice respects time slot parameter")
    func dailyAdviceTimeSlots() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)

        #expect(morningAdvice.timeSlot == .morning)
        #expect(afternoonAdvice.timeSlot == .afternoon)
        #expect(eveningAdvice.timeSlot == .evening)

        // Morning should have weekly try, others should not
        #expect(morningAdvice.weeklyTry != nil)
        #expect(afternoonAdvice.weeklyTry == nil)
        #expect(eveningAdvice.weeklyTry == nil)
    }

    // MARK: - TimeSlot Tests

    @Test("TimeSlot display names are correctly localized")
    func timeSlotDisplayNames() {
        #expect(TimeSlot.morning.displayName == "朝")
        #expect(TimeSlot.afternoon.displayName == "昼")
        #expect(TimeSlot.evening.displayName == "夜")
    }

    @Test("TimeSlot greetings are correctly localized")
    func timeSlotGreetings() {
        #expect(TimeSlot.morning.greeting == "おはようございます")
        #expect(TimeSlot.afternoon.greeting == "お疲れさまです")
        #expect(TimeSlot.evening.greeting == "お疲れさまでした")
    }

    // MARK: - IconType Tests

    @Test("IconType system images are correct")
    func iconTypeSystemImages() {
        #expect(IconType.fitness.systemImageName == "figure.strengthtraining.functional")
        #expect(IconType.nutrition.systemImageName == "fork.knife")
        #expect(IconType.sleep.systemImageName == "moon.stars.fill")
    }

    @Test("IconType display names are correctly localized")
    func iconTypeDisplayNames() {
        #expect(IconType.fitness.displayName == "フィットネス")
        #expect(IconType.nutrition.displayName == "栄養")
        #expect(IconType.sleep.displayName == "睡眠")
    }

    // MARK: - Codable Tests

    @Test("DailyAdvice can be encoded and decoded")
    func dailyAdviceCodable() throws {
        let advice = DailyAdvice.createMock()

        let encodedData = try JSONEncoder().encode(advice)
        #expect(encodedData.count > 0)

        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: encodedData)

        #expect(decodedAdvice.greeting == advice.greeting)
        #expect(decodedAdvice.condition.summary == advice.condition.summary)
        #expect(decodedAdvice.timeSlot == advice.timeSlot)
    }

    // MARK: - MockData Tests

    #if DEBUG
    @Test("MockData greeting contains nickname and time-based greeting")
    func mockDataGreetingLogic() {
        let testNickname = "テストユーザー"
        let greeting = MockData.getCurrentGreeting(nickname: testNickname)

        #expect(greeting.contains(testNickname))
        #expect(greeting.contains("さん、"))

        // Should contain one of the time-based greetings
        let timeGreetings = ["おはようございます", "こんにちは", "お疲れさまです"]
        let containsTimeGreeting = timeGreetings.contains { greeting.contains($0) }
        #expect(containsTimeGreeting)
    }

    @Test("MockData date formatting includes Japanese month and day")
    func mockDataDateFormatting() {
        let dateString = MockData.getCurrentDateString()

        #expect(dateString.contains("月"))
        #expect(dateString.contains("日"))
        #expect(!dateString.isEmpty)
    }

    @Test("MockData weather has consistent Tokyo values")
    func mockWeatherConsistency() {
        let weather = MockData.mockWeather

        #expect(weather.cityName == "東京")
        #expect(weather.temperature == 24)
        #expect(weather.weatherIcon == "☀️")
    }
    #endif
}
