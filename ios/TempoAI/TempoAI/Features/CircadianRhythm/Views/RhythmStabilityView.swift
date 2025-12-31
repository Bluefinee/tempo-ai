import SwiftUI

/// Displays rhythm stability with dot indicators and status text
struct RhythmStabilityView: View {
  let data: CircadianData

  private let totalDots = 5

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header
      Text("リズム安定度")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.tempoPrimaryText)

      // Dots and status
      HStack(spacing: 12) {
        // Dot indicators
        HStack(spacing: 4) {
          ForEach(0..<totalDots, id: \.self) { index in
            Circle()
              .fill(index < data.rhythmStatus.filledDots ? statusColor : Color.gray.opacity(0.3))
              .frame(width: 10, height: 10)
          }
        }

        // Status label
        Text(data.rhythmStatus.statusLabel)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(statusColor)
      }

      // Description text
      Text(data.rhythmStatus.displayText)
        .font(.footnote)
        .foregroundColor(.tempoSecondaryText)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.tempoLightCream)
        .shadow(
          color: Color.black.opacity(0.04),
          radius: 4,
          x: 0,
          y: 2
        )
    )
  }

  private var statusColor: Color {
    switch data.rhythmStatus {
    case .excellent, .good:
      return .tempoSuccess
    case .unstable:
      return .tempoWarning
    case .poor:
      return .tempoError
    }
  }
}

// MARK: - Preview

#if DEBUG
#Preview("Rhythm Stability - Excellent") {
  let data = CircadianData(
    hrvValue: 72,
    hrvAverage: 66,
    bedtime: Date(),
    wakeTime: Date(),
    rhythmScore: 85,
    consecutiveStableDays: 5,
    scores: HealthScores(hrv: 85, sleep: 82, rhythm: 85, activity: 70),
    insight: ""
  )
  return RhythmStabilityView(data: data)
    .padding()
}

#Preview("Rhythm Stability - Good") {
  RhythmStabilityView(data: .mock)
    .padding()
}

#Preview("Rhythm Stability - Unstable") {
  let data = CircadianData(
    hrvValue: 55,
    hrvAverage: 60,
    bedtime: Date(),
    wakeTime: Date(),
    rhythmScore: 55,
    consecutiveStableDays: 1,
    scores: HealthScores(hrv: 55, sleep: 60, rhythm: 55, activity: 65),
    insight: ""
  )
  return RhythmStabilityView(data: data)
    .padding()
}

#Preview("Rhythm Stability - Poor") {
  RhythmStabilityView(data: .mockPoorRhythm)
    .padding()
}
#endif
