import SwiftUI

/// Health status display card showing current wellness level with visual indicators.
///
/// Displays the user's current health status with color-coded indicators, emoji,
/// score display, and recommended actions. Provides an accessible and intuitive
/// view of the user's health condition based on comprehensive analysis.
struct HealthStatusCard: View {
    let healthAnalysis: HealthAnalysis
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection

            if isLoading {
                loadingSection
            } else {
                statusContent
            }
        }
        .padding()
        .background(healthAnalysis.status.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(healthAnalysis.status.color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Health Status")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(healthAnalysis.status.localizedTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(healthAnalysis.status.color)
            }

            Spacer()

            VStack(spacing: 8) {
                Text(healthAnalysis.status.emoji)
                    .font(.title)

                Circle()
                    .fill(healthAnalysis.status.color)
                    .frame(width: 12, height: 12)
            }
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Analyzing health data...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }

            // Placeholder for metrics
            VStack(spacing: 8) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.3))
                            .frame(width: 60, height: 12)

                        Spacer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.2))
                            .frame(width: 40, height: 12)
                    }
                }
            }
        }
    }

    private var statusContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Score display
            scoreSection

            // Key metrics
            metricsSection

            // Recommendations
            recommendationsSection
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Overall Score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(healthAnalysis.overallScore * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(healthAnalysis.status.color)
            }

            // Score bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(healthAnalysis.status.color)
                        .frame(width: geometry.size.width * healthAnalysis.overallScore, height: 6)
                        .animation(.easeInOut(duration: 0.6), value: healthAnalysis.overallScore)
                }
            }
            .frame(height: 6)
        }
    }

    private var metricsSection: some View {
        VStack(spacing: 8) {
            if let hrvScore = healthAnalysis.hrvScore {
                MetricRow(title: "HRV", score: hrvScore, icon: "heart.fill")
            }

            if let sleepScore = healthAnalysis.sleepScore {
                MetricRow(title: "Sleep", score: sleepScore, icon: "bed.double.fill")
            }

            if let activityScore = healthAnalysis.activityScore {
                MetricRow(title: "Activity", score: activityScore, icon: "figure.walk")
            }

            if let heartRateScore = healthAnalysis.heartRateScore {
                MetricRow(title: "Heart Rate", score: heartRateScore, icon: "heart.circle.fill")
            }
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !healthAnalysis.recommendedActions.isEmpty {
                Text("Recommendations")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(healthAnalysis.recommendedActions.prefix(3)), id: \.self) { action in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(healthAnalysis.status.color)
                                .offset(y: 2)

                            Text(action)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var accessibilityLabel: String {
        let statusText = "Health status: \(healthAnalysis.status.localizedTitle)"
        let scoreText = "Overall score: \(Int(healthAnalysis.overallScore * 100)) percent"
        let confidenceText = "Analysis confidence: \(Int(healthAnalysis.confidence * 100)) percent"
        return "\(statusText). \(scoreText). \(confidenceText)"
    }
}

/// Individual metric display row
private struct MetricRow: View {
    let title: String
    let score: Double
    let icon: String

    private var scoreColor: Color {
        switch score {
        case 0.8 ... 1.0: return .green
        case 0.6 ..< 0.8: return .yellow
        case 0.4 ..< 0.6: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(scoreColor)
                .frame(width: 16)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text("\(Int(score * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(scoreColor)
        }
    }
}

#Preview("Optimal Status") {
    HealthStatusCard(
        healthAnalysis: HealthAnalysis(
            status: .optimal,
            overallScore: 0.85,
            confidence: 0.9,
            hrvScore: 0.8,
            sleepScore: 0.9,
            activityScore: 0.8,
            heartRateScore: 0.85
        ),
        isLoading: false
    )
    .padding()
}

#Preview("Care Status") {
    HealthStatusCard(
        healthAnalysis: HealthAnalysis(
            status: .care,
            overallScore: 0.55,
            confidence: 0.8,
            hrvScore: 0.4,
            sleepScore: 0.6,
            activityScore: 0.7,
            heartRateScore: 0.5
        ),
        isLoading: false
    )
    .padding()
}

#Preview("Loading State") {
    HealthStatusCard(
        healthAnalysis: HealthAnalysis(
            status: .unknown,
            overallScore: 0.0,
            confidence: 0.0
        ),
        isLoading: true
    )
    .padding()
}
