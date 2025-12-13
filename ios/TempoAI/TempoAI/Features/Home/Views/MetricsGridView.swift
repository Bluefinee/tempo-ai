import SwiftUI

/**
 * 2x2 grid container for displaying health metrics
 * Shows 4 metrics: Recovery, Sleep, Energy, Stress
 *
 * UX Concepts applied:
 * - 8px grid system (spacing: 12 = 8 + 4)
 * - Consistent visual hierarchy
 * - Clear information architecture
 */
struct MetricsGridView: View {
    let metrics: [MetricData]

    var body: some View {
        VStack(spacing: 12) {
            // Top row: Recovery, Sleep
            HStack(spacing: 12) {
                if metrics.count > 0 {
                    MetricCard(metric: metrics[0])
                }
                if metrics.count > 1 {
                    MetricCard(metric: metrics[1])
                }
            }

            // Bottom row: Energy, Stress
            HStack(spacing: 12) {
                if metrics.count > 2 {
                    MetricCard(metric: metrics[2])
                }
                if metrics.count > 3 {
                    MetricCard(metric: metrics[3])
                }
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
