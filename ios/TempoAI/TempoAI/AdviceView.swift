import SwiftUI

// MARK: - Advice View
struct AdviceView: View {
    let advice: DailyAdvice

    private var sleepSummary: String {
        [
            "Bedtime: \(advice.sleepPreparation.bedtime)",
            "Routine: \(advice.sleepPreparation.routine.joined(separator: ", "))",
        ].joined(separator: "\n")
    }

    private var breathingSummary: String {
        [
            advice.breathing.technique,
            advice.breathing.duration,
            "(\(advice.breathing.frequency))",
        ].joined(separator: " ")
    }

    var body: some View {
        VStack(spacing: 16) {
            ThemeSummaryCard(advice: advice)
            WeatherCard(advice: advice)
            MealCardsSection(advice: advice)
            ExerciseCard(advice: advice)
            SleepCard(sleepSummary: sleepSummary)
            BreathingCard(breathingSummary: breathingSummary)
        }
    }
}

// MARK: - Subviews

private struct ThemeSummaryCard: View {
    let advice: DailyAdvice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(advice.theme)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(advice.summary)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

private struct WeatherCard: View {
    let advice: DailyAdvice

    var body: some View {
        AdviceCard(
            title: "Weather Considerations",
            content: advice.weatherConsiderations.warnings.first ?? "No weather warnings today",
            color: .orange,
            icon: "cloud.sun.fill"
        )
    }
}

private struct MealCardsSection: View {
    let advice: DailyAdvice

    var body: some View {
        VStack(spacing: 12) {
            AdviceCard(
                title: "Breakfast",
                content: advice.breakfast.recommendation,
                color: .green,
                icon: "cup.and.saucer.fill"
            )

            AdviceCard(
                title: "Lunch",
                content: advice.lunch.recommendation,
                color: .blue,
                icon: "fork.knife"
            )

            AdviceCard(
                title: "Dinner",
                content: advice.dinner.recommendation,
                color: .purple,
                icon: "moon.stars.fill"
            )
        }
    }
}

private struct ExerciseCard: View {
    let advice: DailyAdvice

    var body: some View {
        AdviceCard(
            title: "Exercise",
            content: "\(advice.exercise.recommendation) - \(advice.exercise.timing) (\(advice.exercise.intensity))",
            color: .red,
            icon: "figure.run"
        )
    }
}

private struct SleepCard: View {
    let sleepSummary: String

    var body: some View {
        AdviceCard(
            title: "Sleep",
            content: sleepSummary,
            color: .indigo,
            icon: "bed.double.fill"
        )
    }
}

private struct BreathingCard: View {
    let breathingSummary: String

    var body: some View {
        AdviceCard(
            title: "Breathing",
            content: breathingSummary,
            color: .mint,
            icon: "leaf.fill"
        )
    }
}
