import SwiftUI

/// Displays three health metrics in a triangle layout
/// HRV (top) = Result, Sleep (bottom-left) = Recovery, Activity (bottom-right) = Movement
struct MetricsTriangleView: View {
  let scores: HealthScores

  var body: some View {
    VStack(spacing: 16) {
      // Header
      Text("3つの指標")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.tempoPrimaryText)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Triangle layout
      VStack(spacing: 24) {
        // Top: HRV (Result)
        MetricIndicator(
          icon: "heart.fill",
          label: "HRV",
          value: "\(scores.hrv)",
          unit: "点",
          role: "結果",
          score: scores.hrv
        )

        // Bottom row: Sleep and Activity
        HStack(spacing: 40) {
          // Bottom-left: Sleep (Recovery)
          MetricIndicator(
            icon: "moon.zzz.fill",
            label: "睡眠",
            value: "\(scores.sleep)",
            unit: "点",
            role: "回復",
            score: scores.sleep
          )

          // Bottom-right: Activity (Movement)
          MetricIndicator(
            icon: "figure.walk",
            label: "活動",
            value: "\(scores.activity)",
            unit: "点",
            role: "活動",
            score: scores.activity
          )
        }
      }

      // Connection lines (visual triangle)
      TriangleConnector()
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        .frame(height: 60)
        .offset(y: -100)
    }
    .padding(16)
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
}

// MARK: - Metric Indicator

private struct MetricIndicator: View {
  let icon: String
  let label: String
  let value: String
  let unit: String
  let role: String
  let score: Int

  var body: some View {
    VStack(spacing: 6) {
      // Icon
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(scoreColor)

      // Value
      HStack(alignment: .lastTextBaseline, spacing: 2) {
        Text(value)
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundColor(.tempoPrimaryText)

        Text(unit)
          .font(.system(size: 12))
          .foregroundColor(.tempoSecondaryText)
      }

      // Label and role
      VStack(spacing: 2) {
        Text(label)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.tempoPrimaryText)

        Text("（\(role)）")
          .font(.system(size: 11))
          .foregroundColor(.tempoSecondaryText)
      }
    }
  }

  private var scoreColor: Color {
    switch score {
    case 80...100:
      return .tempoSuccess
    case 60..<80:
      return .tempoSageGreen
    case 40..<60:
      return .tempoWarning
    case 20..<40:
      return .orange
    default:
      return .tempoError
    }
  }
}

// MARK: - Triangle Connector Shape

private struct TriangleConnector: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let topCenter = CGPoint(x: rect.midX, y: rect.minY)
    let bottomLeft = CGPoint(x: rect.minX + 40, y: rect.maxY)
    let bottomRight = CGPoint(x: rect.maxX - 40, y: rect.maxY)

    path.move(to: topCenter)
    path.addLine(to: bottomLeft)
    path.addLine(to: bottomRight)
    path.addLine(to: topCenter)

    return path
  }
}

// MARK: - Preview

#if DEBUG
#Preview("Metrics Triangle - Good") {
  MetricsTriangleView(scores: HealthScores(hrv: 85, sleep: 82, rhythm: 78, activity: 70))
    .padding()
}

#Preview("Metrics Triangle - Mixed") {
  MetricsTriangleView(scores: HealthScores(hrv: 65, sleep: 45, rhythm: 55, activity: 80))
    .padding()
}

#Preview("Metrics Triangle - Low") {
  MetricsTriangleView(scores: HealthScores(hrv: 35, sleep: 40, rhythm: 30, activity: 25))
    .padding()
}
#endif
