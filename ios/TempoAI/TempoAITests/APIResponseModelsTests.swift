import XCTest
@testable import TempoAI

final class APIResponseModelsTests: XCTestCase {

    // MARK: - API Response Model Tests

    func testAPIResponseSuccessCreation() {
        // Given: Successful API response
        let mockAdvice = createMockDailyAdvice()
        let apiResponse = APIResponse(success: true, data: mockAdvice, error: nil)

        // Then: Should create valid response
        XCTAssertTrue(apiResponse.success)
        XCTAssertNotNil(apiResponse.data)
        XCTAssertNil(apiResponse.error)
        XCTAssertEqual(apiResponse.data?.theme, "バランス調整の日")
    }

    func testAPIResponseErrorCreation() {
        // Given: Error API response
        let apiResponse = APIResponse<DailyAdvice>(success: false, data: nil, error: "Server error")

        // Then: Should create valid error response
        XCTAssertFalse(apiResponse.success)
        XCTAssertNil(apiResponse.data)
        XCTAssertEqual(apiResponse.error, "Server error")
    }

    func testMockAdviceResponseCreation() {
        // Given: Mock advice response
        let mockAdvice = createMockDailyAdvice()
        let mockResponse = MockAdviceResponse(advice: mockAdvice)

        // Then: Should create valid mock response
        XCTAssertEqual(mockResponse.advice.theme, "バランス調整の日")
        XCTAssertNotNil(mockResponse.advice.breakfast)
    }
}

// MARK: - Test Data Helpers

extension APIResponseModelsTests {
    func createMockDailyAdvice() -> DailyAdvice {
        return DailyAdvice(
            theme: "バランス調整の日",
            summary: "今日は適度な運動を。",
            breakfast: MealAdvice(
                recommendation: "タンパク質豊富な朝食を",
                reason: "筋肉合成を促進",
                examples: ["ゆで卵", "ヨーグルト"],
                timing: nil,
                avoid: nil
            ),
            lunch: MealAdvice(
                recommendation: "バランス食",
                reason: "エネルギー維持",
                examples: ["サラダ"],
                timing: "12:30 PM",
                avoid: ["揚げ物"]
            ),
            dinner: MealAdvice(
                recommendation: "軽い食事",
                reason: "睡眠の質保持",
                examples: ["魚料理"],
                timing: "6:30 PM",
                avoid: ["遅い食事"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "有酸素運動30分",
                intensity: "Moderate",
                reason: "回復状態が良好",
                timing: "午前10時頃",
                avoid: ["高強度運動"]
            ),
            hydration: HydrationAdvice(
                target: "2.5L",
                schedule: HydrationSchedule(morning: "500ml", afternoon: "1000ml", evening: "1000ml"),
                reason: "活動量に対応"
            ),
            breathing: BreathingAdvice(
                technique: "4-7-8 breathing",
                duration: "5分",
                frequency: "2回",
                instructions: ["吸う", "止める", "吐く"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "22:30",
                routine: ["お風呂", "読書"],
                avoid: ["スマホ"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: ["日焼け止めを"],
                opportunities: ["散歩に最適"]
            ),
            priorityActions: ["朝食を摂る", "運動する", "水分摂取"]
        )
    }
}
