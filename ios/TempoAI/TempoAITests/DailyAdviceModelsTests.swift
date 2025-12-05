import XCTest
@testable import TempoAI

final class DailyAdviceModelsTests: XCTestCase {

    // MARK: - Daily Advice Model Tests

    func testDailyAdviceCreation() {
        // Given: Valid advice components
        let dailyAdvice = APIClientTestData.createMockDailyAdvice()

        // Then: Should create valid advice with unique ID
        XCTAssertNotNil(dailyAdvice.id)
        XCTAssertEqual(dailyAdvice.theme, "バランス調整の日")
        XCTAssertEqual(dailyAdvice.summary, "今日は適度な運動を。")
        XCTAssertNotNil(dailyAdvice.breakfast)
        XCTAssertNotNil(dailyAdvice.lunch)
        XCTAssertNotNil(dailyAdvice.dinner)
        XCTAssertNotNil(dailyAdvice.exercise)
        XCTAssertNotNil(dailyAdvice.hydration)
        XCTAssertNotNil(dailyAdvice.breathing)
        XCTAssertNotNil(dailyAdvice.sleepPreparation)
        XCTAssertNotNil(dailyAdvice.weatherConsiderations)
        XCTAssertGreaterThan(dailyAdvice.priorityActions.count, 0)
    }

    func testDailyAdviceUniqueIDs() {
        // Given: Multiple daily advice instances
        let advice1 = APIClientTestData.createMockDailyAdvice()
        let advice2 = APIClientTestData.createMockDailyAdvice()

        // Then: Should have unique IDs
        XCTAssertNotEqual(advice1.id, advice2.id)
    }

    func testMealAdviceValidation() {
        // Given: Meal advice with all optional fields
        let mealAdvice = MealAdvice(
            recommendation: "バランスの良い食事",
            reason: "エネルギー維持のため",
            examples: ["サラダ", "スープ", "玄米"],
            timing: "12:30 PM",
            avoid: ["揚げ物", "高糖質食品"]
        )

        // Then: Should maintain all fields
        XCTAssertEqual(mealAdvice.recommendation, "バランスの良い食事")
        XCTAssertEqual(mealAdvice.reason, "エネルギー維持のため")
        XCTAssertEqual(mealAdvice.examples?.count, 3)
        XCTAssertEqual(mealAdvice.timing, "12:30 PM")
        XCTAssertEqual(mealAdvice.avoid?.count, 2)
    }

    func testMealAdviceWithNilOptionalFields() {
        // Given: Meal advice with nil optional fields
        let mealAdvice = MealAdvice(
            recommendation: "簡単な食事",
            reason: "時間節約",
            examples: nil,
            timing: nil,
            avoid: nil
        )

        // Then: Should handle nil fields properly
        XCTAssertEqual(mealAdvice.recommendation, "簡単な食事")
        XCTAssertEqual(mealAdvice.reason, "時間節約")
        XCTAssertNil(mealAdvice.examples)
        XCTAssertNil(mealAdvice.timing)
        XCTAssertNil(mealAdvice.avoid)
    }

    func testExerciseAdviceValidation() {
        // Given: Exercise advice
        let exerciseAdvice = ExerciseAdvice(
            recommendation: "軽いジョギング",
            intensity: .moderate,
            reason: "心肺機能向上",
            timing: "午前中",
            avoid: ["高強度トレーニング", "長時間運動"]
        )

        // Then: Should maintain all fields
        XCTAssertEqual(exerciseAdvice.recommendation, "軽いジョギング")
        XCTAssertEqual(exerciseAdvice.intensity, .moderate)
        XCTAssertEqual(exerciseAdvice.reason, "心肺機能向上")
        XCTAssertEqual(exerciseAdvice.timing, "午前中")
        XCTAssertEqual(exerciseAdvice.avoid.count, 2)
    }

    func testHydrationAdviceValidation() {
        // Given: Hydration advice
        let schedule = HydrationSchedule(morning: "500ml", afternoon: "800ml", evening: "700ml")
        let hydrationAdvice = HydrationAdvice(
            target: "2L",
            schedule: schedule,
            reason: "代謝促進"
        )

        // Then: Should maintain all fields
        XCTAssertEqual(hydrationAdvice.target, "2L")
        XCTAssertEqual(hydrationAdvice.schedule.morning, "500ml")
        XCTAssertEqual(hydrationAdvice.schedule.afternoon, "800ml")
        XCTAssertEqual(hydrationAdvice.schedule.evening, "700ml")
        XCTAssertEqual(hydrationAdvice.reason, "代謝促進")
    }

    func testBreathingAdviceValidation() {
        // Given: Breathing advice
        let breathingAdvice = BreathingAdvice(
            technique: "4-7-8呼吸法",
            duration: "5分",
            frequency: "朝晩2回",
            instructions: ["4秒で吸う", "7秒止める", "8秒で吐く", "繰り返す"]
        )

        // Then: Should maintain all fields
        XCTAssertEqual(breathingAdvice.technique, "4-7-8呼吸法")
        XCTAssertEqual(breathingAdvice.duration, "5分")
        XCTAssertEqual(breathingAdvice.frequency, "朝晩2回")
        XCTAssertEqual(breathingAdvice.instructions.count, 4)
        XCTAssertEqual(breathingAdvice.instructions[0], "4秒で吸う")
    }

    func testSleepPreparationAdviceValidation() {
        // Given: Sleep preparation advice
        let sleepAdvice = SleepPreparationAdvice(
            bedtime: "22:30",
            routine: ["入浴", "読書", "瞑想"],
            avoid: ["スマホ", "カフェイン", "激しい運動"]
        )

        // Then: Should maintain all fields
        XCTAssertEqual(sleepAdvice.bedtime, "22:30")
        XCTAssertEqual(sleepAdvice.routine.count, 3)
        XCTAssertEqual(sleepAdvice.avoid.count, 3)
        XCTAssertEqual(sleepAdvice.routine[1], "読書")
        XCTAssertEqual(sleepAdvice.avoid[0], "スマホ")
    }

    func testWeatherConsiderationsValidation() {
        // Given: Weather considerations
        let weatherConsiderations = WeatherConsiderations(
            warnings: ["強風注意", "UV指数高"],
            opportunities: ["散歩に適した気温", "屋外運動可能"]
        )

        // Then: Should maintain all fields
        XCTAssertEqual(weatherConsiderations.warnings.count, 2)
        XCTAssertEqual(weatherConsiderations.opportunities.count, 2)
        XCTAssertEqual(weatherConsiderations.warnings[0], "強風注意")
        XCTAssertEqual(weatherConsiderations.opportunities[0], "散歩に適した気温")
    }
}
