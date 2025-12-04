/**
 * @fileoverview API Client Test Data Helpers
 * 
 * APIClientのテストで使用するテストデータファクトリを提供します。
 * 
 * @author Tempo AI Team
 * @since 1.0.0
 */

import Foundation
@testable import TempoAI

extension APIClientTestData {
    static func createMockHealthData() -> HealthData {
        return HealthData(
            sleep: SleepData(
                duration: 7.5,
                deep: 1.2,
                rem: 1.8,
                light: 4.5,
                awake: 0.0,
                efficiency: 88
            ),
            hrv: HRVData(
                average: 45.2,
                min: 38.1,
                max: 52.7
            ),
            heartRate: HeartRateData(
                resting: 58,
                average: 72,
                min: 55,
                max: 85
            ),
            activity: ActivityData(
                steps: 8234,
                distance: 6.2,
                calories: 420,
                activeMinutes: 35
            )
        )
    }

    static func createMockUserProfile() -> UserProfile {
        return UserProfile(
            age: 30,
            gender: "male",
            goals: ["疲労回復", "集中力向上"],
            dietaryPreferences: "バランス重視",
            exerciseHabits: "週3回ジム",
            exerciseFrequency: "3回/週"
        )
    }

    static func createMockDailyAdvice() -> DailyAdvice {
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
                target: "2.5",
                schedule: HydrationSchedule(
                    morning: "500",
                    afternoon: "1000",
                    evening: "1000"
                ),
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

struct APIClientTestData {
    // This struct acts as a namespace for the static methods above
}
