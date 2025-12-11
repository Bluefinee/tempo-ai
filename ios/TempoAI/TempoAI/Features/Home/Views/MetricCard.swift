import SwiftUI

/**
 * Individual metric card displaying a single health metric
 * Part of the 2x2 metrics grid on the home screen
 */
struct MetricCard: View {
  let metric: MetricData

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Icon + Label row
      HStack(spacing: 6) {
        Text(metric.type.icon)
          .font(.title3)

        Text(metric.type.label)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)
      }

      Spacer()

      // Status text
      Text(metric.status)
        .font(.caption)
        .foregroundColor(.tempoSecondaryText)

      // Progress bar with score
      HStack(spacing: 8) {
        // Progress bar
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: 4)
              .fill(Color.tempoProgressBackground)
              .frame(height: 6)

            // Progress fill
            RoundedRectangle(cornerRadius: 4)
              .fill(metric.progressBarColor)
              .frame(
                width: geometry.size.width * metric.progressValue,
                height: 6
              )
          }
        }
        .frame(height: 6)

        // Score text
        Text(metric.displayValue)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.tempoPrimaryText)
          .frame(width: 35, alignment: .trailing)
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(
          color: Color.black.opacity(0.08),
          radius: 8,
          x: 0,
          y: 2
        )
    )
  }
}

// MARK: - Preview

#Preview("Recovery Metric") {
  MetricCard(
    metric: MetricData(
      type: .recovery,
      score: 78,
      displayValue: "78"
    )
  )
  .frame(width: 160, height: 120)
  .padding()
  .background(Color.tempoLightCream)
}

#Preview("Sleep Metric") {
  MetricCard(
    metric: MetricData(
      type: .sleep,
      score: 85,
      displayValue: "7.0h"
    )
  )
  .frame(width: 160, height: 120)
  .padding()
  .background(Color.tempoLightCream)
}

#Preview("Low Score") {
  MetricCard(
    metric: MetricData(
      type: .stress,
      score: 30,
      displayValue: "高"
    )
  )
  .frame(width: 160, height: 120)
  .padding()
  .background(Color.tempoLightCream)
}
