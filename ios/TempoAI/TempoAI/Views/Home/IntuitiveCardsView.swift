import SwiftUI

struct IntuitiveCardsView: View {
    let healthData: HealthData
    let userMode: UserMode

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            StressLevelCard(stressLevel: healthData.stressLevel)
            RecoveryCard(recoveryScore: calculateRecoveryScore())
            ContextMetricCard(metric: contextMetric)
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3)

    private var contextMetric: ContextMetric {
        switch userMode {
        case .standard:
            return .activity(steps: healthData.activityData.stepCount)
        case .athlete:
            return .exertion(strain: calculateStrainScore())
        }
    }

    private let strainDivisor: Double = 10.0

    private func calculateRecoveryScore() -> Double {
        let sleepScore = healthData.sleepData.quality * 100
        let hrvScore: Double =
            healthData.hrvData.baseline > 0
            ? min(100, (healthData.hrvData.current / healthData.hrvData.baseline) * 100)
            : 50.0  // baseline未設定時のデフォルト値
        return (sleepScore + hrvScore) / 2
    }

    private func calculateStrainScore() -> Double {
        return min(100, healthData.activeEnergy / strainDivisor)
    }
}

enum ContextMetric {
    case activity(steps: Int)
    case exertion(strain: Double)

    var title: String {
        switch self {
        case .activity: return "活動"
        case .exertion: return "負荷"
        }
    }

    var value: String {
        switch self {
        case .activity(let steps): return "\(steps)"
        case .exertion(let strain): return "\(Int(strain))"
        }
    }

    var unit: String {
        switch self {
        case .activity: return "歩"
        case .exertion: return "pts"
        }
    }

    var icon: String {
        switch self {
        case .activity: return "figure.walk"
        case .exertion: return "flame"
        }
    }

    var color: Color {
        switch self {
        case .activity: return ColorPalette.info
        case .exertion: return ColorPalette.warning
        }
    }
}

struct StressLevelCard: View {
    let stressLevel: Double

    var body: some View {
        MetricCard(
            title: "ストレス",
            value: "\(Int(stressLevel))",
            unit: "%",
            color: stressColor,
            icon: "brain.head.profile"
        )
    }

    private var stressColor: Color {
        switch stressLevel {
        case 0 ..< 30: return ColorPalette.success
        case 30 ..< 70: return ColorPalette.warning
        default: return ColorPalette.error
        }
    }
}

struct RecoveryCard: View {
    let recoveryScore: Double

    var body: some View {
        MetricCard(
            title: "回復",
            value: "\(Int(recoveryScore))",
            unit: "%",
            color: recoveryColor,
            icon: "heart.circle"
        )
    }

    private var recoveryColor: Color {
        switch recoveryScore {
        case 70 ..< 101: return ColorPalette.success
        case 40 ..< 70: return ColorPalette.warning
        default: return ColorPalette.error
        }
    }
}

struct ContextMetricCard: View {
    let metric: ContextMetric

    var body: some View {
        MetricCard(
            title: metric.title,
            value: metric.value,
            unit: metric.unit,
            color: metric.color,
            icon: metric.icon
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(spacing: 2) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(value)
                        .typography(.headline)
                        .foregroundColor(ColorPalette.richBlack)

                    if !unit.isEmpty {
                        Text(unit)
                            .typography(.caption)
                            .foregroundColor(ColorPalette.gray500)
                    }
                }

                Text(title)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    IntuitiveCardsView(
        healthData: HealthData.mock(),
        userMode: .standard
    )
    .padding()
}
