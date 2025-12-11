import SwiftUI

/**
 * 2x2 grid container for displaying health metrics
 * Shows 4 metrics: Recovery, Sleep, Energy, Stress
 */
struct MetricsGridView: View {
  let metrics: [MetricData]

  // Grid columns: 2 equal width columns
  private let columns: [GridItem] = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(metrics) { metric in
        MetricCard(metric: metric)
          .frame(height: 120)
      }
    }
  }
}

// MARK: - Preview

#Preview("Metrics Grid") {
  #if DEBUG
    MetricsGridView(metrics: MockData.mockMetrics)
      .padding(.horizontal, 24)
      .background(Color.tempoLightCream)
  #else
    MetricsGridView(
      metrics: [
        MetricData(type: .recovery, score: 78, displayValue: "78"),
        MetricData(type: .sleep, score: 85, displayValue: "7.0h"),
        MetricData(type: .energy, score: 62, displayValue: "62"),
        MetricData(type: .stress, score: 45, displayValue: "低")
      ]
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
  #endif
}
