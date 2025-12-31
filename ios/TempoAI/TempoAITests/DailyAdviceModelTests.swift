import Foundation
import Testing

@testable import TempoAI

struct DailyAdviceModelTests {

    // MARK: - DailyAdvice Mock Creation Tests

    @Test("DailyAdvice.createMock() creates valid advice with all required fields")
    func dailyAdviceCreateMock() {
        let advice = DailyAdvice.createMock()

        #expect(!advice.greeting.isEmpty)
        #expect(!advice.energyComment.isEmpty)
        #expect(!advice.condition.summary.isEmpty)
        #expect(!advice.condition.detail.isEmpty)
        #expect(!advice.insight.isEmpty)
        #expect(!advice.closingMessage.isEmpty)
        #expect(!advice.dailyTry.title.isEmpty)
        #expect(!advice.dailyTry.detail.isEmpty)
        #expect(advice.scores.hrv >= 0 && advice.scores.hrv <= 100)
    }

    @Test("DailyAdvice respects time slot parameter")
    func dailyAdviceTimeSlots() {
        let morningAdvice = DailyAdvice.createMock(timeSlot: .morning)
        let afternoonAdvice = DailyAdvice.createMock(timeSlot: .afternoon)
        let eveningAdvice = DailyAdvice.createMock(timeSlot: .evening)

        #expect(morningAdvice.timeSlot == .morning)
        #expect(afternoonAdvice.timeSlot == .afternoon)
        #expect(eveningAdvice.timeSlot == .evening)
    }

    @Test("DailyAdvice respects custom scores parameter")
    func dailyAdviceCustomScores() {
        let customScores = HealthScores(hrv: 50, sleep: 60, rhythm: 70, activity: 80)
        let advice = DailyAdvice.createMock(scores: customScores)

        #expect(advice.scores.hrv == 50)
        #expect(advice.scores.sleep == 60)
        #expect(advice.scores.rhythm == 70)
        #expect(advice.scores.activity == 80)
    }

    @Test("DailyAdvice.createMock(withHrvScore:) sets correct HRV")
    func dailyAdviceWithHrvScore() {
        let advice = DailyAdvice.createMock(withHrvScore: 35)

        #expect(advice.scores.hrv == 35)
    }

    // MARK: - HealthScores Tests

    @Test("HealthScores energyLevel returns correct level for various HRV scores")
    func healthScoresEnergyLevel() {
        let excellent = HealthScores(hrv: 85, sleep: 80, rhythm: 75, activity: 70)
        let good = HealthScores(hrv: 70, sleep: 70, rhythm: 70, activity: 70)
        let moderate = HealthScores(hrv: 50, sleep: 50, rhythm: 50, activity: 50)
        let low = HealthScores(hrv: 30, sleep: 30, rhythm: 30, activity: 30)
        let veryLow = HealthScores(hrv: 10, sleep: 10, rhythm: 10, activity: 10)

        #expect(excellent.energyLevel == .excellent)
        #expect(good.energyLevel == .good)
        #expect(moderate.energyLevel == .moderate)
        #expect(low.energyLevel == .low)
        #expect(veryLow.energyLevel == .veryLow)
    }

    // MARK: - EnergyLevel Tests

    @Test("EnergyLevel color returns correct values")
    func energyLevelColors() {
        #expect(EnergyLevel.excellent.color == "Primary")
        #expect(EnergyLevel.good.color == "Primary")
        #expect(EnergyLevel.moderate.color == "Yellow")
        #expect(EnergyLevel.low.color == "Orange")
        #expect(EnergyLevel.veryLow.color == "Red")
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

    // MARK: - TryContent Tests

    @Test("TryContent has required fields")
    func tryContentFields() {
        let tryContent = TryContent(
            title: "テストタイトル",
            detail: "テスト詳細"
        )

        #expect(tryContent.title == "テストタイトル")
        #expect(tryContent.detail == "テスト詳細")
    }

    // MARK: - Codable Tests

    @Test("DailyAdvice can be encoded and decoded")
    func dailyAdviceCodable() throws {
        let advice = DailyAdvice.createMock()

        let encodedData = try JSONEncoder().encode(advice)
        #expect(encodedData.count > 0)

        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: encodedData)

        #expect(decodedAdvice.greeting == advice.greeting)
        #expect(decodedAdvice.energyComment == advice.energyComment)
        #expect(decodedAdvice.condition.summary == advice.condition.summary)
        #expect(decodedAdvice.insight == advice.insight)
        #expect(decodedAdvice.scores.hrv == advice.scores.hrv)
        #expect(decodedAdvice.timeSlot == advice.timeSlot)
    }

    @Test("HealthScores can be encoded and decoded")
    func healthScoresCodable() throws {
        let scores = HealthScores(hrv: 75, sleep: 80, rhythm: 70, activity: 65)

        let encodedData = try JSONEncoder().encode(scores)
        #expect(encodedData.count > 0)

        let decodedScores = try JSONDecoder().decode(HealthScores.self, from: encodedData)

        #expect(decodedScores.hrv == 75)
        #expect(decodedScores.sleep == 80)
        #expect(decodedScores.rhythm == 70)
        #expect(decodedScores.activity == 65)
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
