import SwiftUI

// MARK: - Advice View
struct AdviceView: View {
    let advice: DailyAdvice

    var body: some View {
        VStack(spacing: 16) {
            // Theme and Summary
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

            // Weather Considerations
            AdviceCard(
                title: "Weather Considerations",
                content: advice.weatherConsiderations.warnings.first ?? "No weather warnings today",
                color: .orange,
                icon: "cloud.sun.fill"
            )

            // Meals
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

            // Exercise
            AdviceCard(
                title: "Exercise",
                content: "\(advice.exercise.recommendation) - \(advice.exercise.timing) (\(advice.exercise.intensity))",
                color: .red,
                icon: "figure.run"
            )

            // Sleep preparation
            let sleepSummary = [
                "Bedtime: \(advice.sleepPreparation.bedtime)",
                "Routine: \(advice.sleepPreparation.routine.joined(separator: ", "))",
            ].joined(separator: "\n")
            AdviceCard(
                title: "Sleep",
                content: sleepSummary,
                color: .indigo,
                icon: "bed.double.fill"
            )

            // Breathing / mindfulness
            let breathingSummary = [
                advice.breathing.technique,
                advice.breathing.duration,
                "(\(advice.breathing.frequency))",
            ].joined(separator: " ")
            AdviceCard(
                title: "Breathing",
                content: breathingSummary,
                color: .mint,
                icon: "leaf.fill"
            )
        }
    }
}
