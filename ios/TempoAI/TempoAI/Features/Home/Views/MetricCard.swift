import SwiftUI

/**
 * Individual metric card displaying a single health metric with circular progress
 * Part of the 2x2 metrics grid on the home screen
 *
 * UX Concepts applied:
 * - Aesthetic-Usability Effect: Clean, refined visual design
 * - Von Restorff Effect: Bold score display for key metrics
 * - 8px grid system: Consistent spacing (8, 12, 16)
 * - Color-coded status: Green (good), Yellow (moderate), Red (needs attention)
 */
struct MetricCard: View {
    let metric: MetricData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Icon + Label
            HStack(spacing: 6) {
                Image(systemName: metric.type.systemImageName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(metric.progressBarColor)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(metric.progressBarColor.opacity(0.12))
                    )

                Text(metric.type.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tempoPrimaryText)
            }

            // Center: Circular progress with score (larger size)
            HStack {
                Spacer()
                CircularProgressView(
                    progress: metric.progressValue,
                    color: metric.progressBarColor,
                    displayValue: metric.displayValue
                )
                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 6,
                    x: 0,
                    y: 2
                )
        )
    }
}

// MARK: - Circular Progress View

private struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let displayValue: String

    private let lineWidth: CGFloat = 6
    private let size: CGFloat = 68

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.tempoProgressBackground,
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)

            // Score in center (Von Restorff Effect: make key metrics stand out)
            Text(displayValue)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.tempoPrimaryText)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview("Metrics Grid 2x2") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            MetricCard(
                metric: MetricData(type: .recovery, score: 78, displayValue: "78")
            )
            MetricCard(
                metric: MetricData(type: .sleep, score: 85, displayValue: "7.0h")
            )
        }
        HStack(spacing: 12) {
            MetricCard(
                metric: MetricData(type: .energy, score: 62, displayValue: "62")
            )
            MetricCard(
                metric: MetricData(type: .stress, score: 30, displayValue: "低")
            )
        }
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Single Card - Recovery") {
    MetricCard(
        metric: MetricData(type: .recovery, score: 92, displayValue: "92")
    )
    .frame(width: 160)
    .padding()
    .background(Color.tempoLightCream)
}
