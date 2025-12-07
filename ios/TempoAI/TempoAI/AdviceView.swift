import SwiftUI

// MARK: - Advice View
struct AdviceView: View {
    let advice: DailyAdvice

    private var sleepSummary: String {
        [
            "Bedtime: \(advice.sleepPreparation.bedtime)",
            "Routine: \(advice.sleepPreparation.routine.joined(separator: ", "))"
        ].joined(separator: "\n")
    }

    private var breathingSummary: String {
        [
            advice.breathing.technique,
            advice.breathing.duration,
            "(\(advice.breathing.frequency))"
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
        .accessibilityIdentifier(UIIdentifiers.AdviceView.mainView)
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
                .accessibilityIdentifier(UIIdentifiers.AdviceView.themeSummaryTitle)

            Text(advice.summary)
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityIdentifier(UIIdentifiers.AdviceView.themeSummaryContent)
        }
        .accessibilityIdentifier(UIIdentifiers.AdviceView.themeSummaryCard)
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
            content: advice.weatherConsiderations.warnings.isEmpty
                ? "No weather warnings today"
                : advice.weatherConsiderations.warnings.joined(separator: "\n"),
            color: .orange,
            icon: "cloud.sun.fill"
        )
        .accessibilityIdentifier(UIIdentifiers.AdviceView.weatherCard)
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
            .accessibilityIdentifier(UIIdentifiers.AdviceView.breakfastCard)

            AdviceCard(
                title: "Lunch",
                content: advice.lunch.recommendation,
                color: .blue,
                icon: "fork.knife"
            )
            .accessibilityIdentifier(UIIdentifiers.AdviceView.lunchCard)

            AdviceCard(
                title: "Dinner",
                content: advice.dinner.recommendation,
                color: .purple,
                icon: "moon.stars.fill"
            )
            .accessibilityIdentifier(UIIdentifiers.AdviceView.dinnerCard)
        }
        .accessibilityIdentifier(UIIdentifiers.AdviceView.mealCardsSection)
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
        .accessibilityIdentifier(UIIdentifiers.AdviceView.exerciseCard)
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
        .accessibilityIdentifier(UIIdentifiers.AdviceView.sleepCard)
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
        .accessibilityIdentifier(UIIdentifiers.AdviceView.breathingCard)
    }
}
