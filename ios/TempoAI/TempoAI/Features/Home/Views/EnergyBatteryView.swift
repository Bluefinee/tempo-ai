import SwiftUI

/**
 * Energy Battery View displaying HRV-based energy level
 * Displays as a percentage with progress bar and AI comment
 *
 * Design specs (from ui-spec.md):
 * - Percentage font: 32pt
 * - AI comment font: 14pt
 * - Progress bar height: 8pt
 * - Card padding: 16pt
 *
 * Color rules:
 * - 80-100: Primary (green)
 * - 60-79: Primary (green)
 * - 40-59: Yellow
 * - 20-39: Orange
 * - 0-19: Red
 */
struct EnergyBatteryView: View {
    let scores: HealthScores
    let energyComment: String

    /// Energy percentage (HRV score)
    private var energyPercentage: Int {
        scores.hrv
    }

    /// Progress ratio for bar (0.0 - 1.0)
    private var progressRatio: CGFloat {
        CGFloat(scores.hrv) / 100.0
    }

    /// Color based on HRV score
    private var energyColor: Color {
        switch scores.hrv {
        case 80...100: return .tempoSuccess
        case 60..<80: return .tempoSageGreen
        case 40..<60: return .tempoWarning
        case 20..<40: return .orange
        default: return .tempoError
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Energy percentage label
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("エネルギー:")
                    .font(.subheadline)
                    .foregroundColor(.tempoSecondaryText)

                Text("\(energyPercentage)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(energyColor)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Filled portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(energyColor)
                        .frame(
                            width: geometry.size.width * progressRatio,
                            height: 8
                        )
                        .animation(.easeOut(duration: 0.5), value: progressRatio)
                }
            }
            .frame(height: 8)

            // AI energy comment
            Text(energyComment)
                .font(.system(size: 14))
                .foregroundColor(.tempoSecondaryText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tempoLightCream)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 6,
                    x: 0,
                    y: 2
                )
        )
    }
}

// MARK: - Previews

#Preview("Excellent (85%)") {
    EnergyBatteryView(
        scores: HealthScores(hrv: 85, sleep: 82, rhythm: 78, activity: 70),
        energyComment: "今日は絶好調ですね"
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Good (70%)") {
    EnergyBatteryView(
        scores: HealthScores(hrv: 70, sleep: 72, rhythm: 68, activity: 65),
        energyComment: "いい感じですね"
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Moderate (50%)") {
    EnergyBatteryView(
        scores: HealthScores(hrv: 50, sleep: 55, rhythm: 48, activity: 52),
        energyComment: "今日はマイペースでいきましょ"
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Low (30%)") {
    EnergyBatteryView(
        scores: HealthScores(hrv: 30, sleep: 35, rhythm: 28, activity: 32),
        energyComment: "今日はゆるめに過ごしましょ"
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Very Low (15%)") {
    EnergyBatteryView(
        scores: HealthScores(hrv: 15, sleep: 20, rhythm: 18, activity: 12),
        energyComment: "ゆっくり休んでくださいね"
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}
