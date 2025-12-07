import SwiftUI

#if DEBUG
    struct EnhancedAdviceCard_Previews: PreviewProvider {
        static let sampleAdvice = DailyAdvice(
            theme: "Morning Walk Recommendation",
            summary:
                "Take a 20-minute walk to boost your energy and mood. Walking increases cardiovascular health, morning sunlight helps regulate circadian rhythm, and light exercise improves mental clarity.",
            breakfast: MealAdvice(
                recommendation: "Light breakfast before walk",
                reason: "Provides energy without heaviness",
                examples: ["Banana", "Toast"],
                timing: "30 minutes before",
                avoid: ["Heavy meals"]
            ),
            lunch: MealAdvice(
                recommendation: "Balanced lunch",
                reason: "Replenish energy after activity",
                examples: ["Salad", "Lean protein"],
                timing: "1-2 hours post walk",
                avoid: ["Processed foods"]
            ),
            dinner: MealAdvice(
                recommendation: "Light dinner",
                reason: "Easy digestion for sleep",
                examples: ["Soup", "Vegetables"],
                timing: "3 hours before bed",
                avoid: ["Spicy foods"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "20-minute brisk walk",
                intensity: .moderate,
                reason: "Improves cardiovascular health",
                timing: "Morning",
                avoid: ["Overexertion"]
            ),
            hydration: HydrationAdvice(
                target: "2 liters",
                schedule: HydrationSchedule(
                    morning: "500ml upon waking",
                    afternoon: "750ml during activity",
                    evening: "750ml before dinner"
                ),
                reason: "Maintains energy and performance"
            ),
            breathing: BreathingAdvice(
                technique: "Deep breathing during walk",
                duration: "5 minutes",
                frequency: "Throughout exercise",
                instructions: ["Inhale through nose", "Exhale through mouth"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "10:00 PM",
                routine: ["Gentle stretching", "Reading"],
                avoid: ["Screen time", "Caffeine"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: [],
                opportunities: ["Perfect weather for outdoor activities", "Enjoy the sunshine"]
            ),
            priorityActions: [
                "Choose a route with natural scenery",
                "Maintain a comfortable pace",
                "Stay hydrated",
            ]
        )

        static var previews: some View {
            VStack(spacing: Spacing.lg) {
                EnhancedAdviceCard(
                    advice: sampleAdvice,
                    priority: .high
                ) { action in
                    print("Action: \(action)")
                }

                EnhancedAdviceCard(
                    advice: sampleAdvice,
                    priority: .normal
                ) { action in
                    print("Action: \(action)")
                }
            }
            .padding()
            .background(ColorPalette.primaryBackground)
            .previewDisplayName("Enhanced Advice Cards")
        }
    }
#endif
