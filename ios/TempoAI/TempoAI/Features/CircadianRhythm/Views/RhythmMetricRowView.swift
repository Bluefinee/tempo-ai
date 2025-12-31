import SwiftUI

/// リズム指標の行表示
/// アイコン + タイトル + 値 + サブ値 + ゲージ + コメント
struct RhythmMetricRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subvalue: String?
    let gaugeLevel: Int
    let comment: String
    let showWarning: Bool

    init(
        icon: String,
        iconColor: Color = .tempoSageGreen,
        title: String,
        value: String,
        subvalue: String? = nil,
        gaugeLevel: Int,
        comment: String,
        showWarning: Bool = false
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.subvalue = subvalue
        self.gaugeLevel = gaugeLevel
        self.comment = comment
        self.showWarning = showWarning
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 上段: アイコン、タイトル、値、ゲージ
            HStack(spacing: 12) {
                // アイコン
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)

                // タイトル
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.tempoPrimaryText)
                    .frame(width: 44, alignment: .leading)

                // 値
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.tempoPrimaryText)

                // サブ値（差分パーセント等）
                if let subvalue {
                    Text(subvalue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.tempoSecondaryText)
                }

                // 警告アイコン
                if showWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gaugeOrange)
                }

                Spacer()

                // ゲージ
                if gaugeLevel > 0 {
                    FiveStageGaugeView(level: gaugeLevel)
                }
            }

            // コメント
            Text(comment)
                .font(.system(size: 12))
                .foregroundColor(.tempoSecondaryText)
                .padding(.leading, 36)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Convenience Initializers

extension RhythmMetricRowView {
    /// HRV指標から行を生成
    static func hrv(_ metric: HRVMetric) -> RhythmMetricRowView {
        RhythmMetricRowView(
            icon: "heart.fill",
            iconColor: .tempoSageGreen,
            title: "HRV",
            value: metric.displayValue,
            subvalue: metric.differenceText,
            gaugeLevel: metric.gaugeLevel,
            comment: metric.comment
        )
    }

    /// 睡眠指標から行を生成
    static func sleep(_ metric: SleepMetric) -> RhythmMetricRowView {
        RhythmMetricRowView(
            icon: "moon.zzz.fill",
            iconColor: .tempoSageGreen,
            title: "睡眠",
            value: metric.displayValue,
            gaugeLevel: metric.gaugeLevel,
            comment: metric.comment
        )
    }

    /// 歩数指標から行を生成
    static func steps(_ metric: StepsMetric) -> RhythmMetricRowView {
        RhythmMetricRowView(
            icon: "figure.walk",
            iconColor: .tempoSageGreen,
            title: "歩数",
            value: "\(metric.displayValue)歩",
            gaugeLevel: metric.gaugeLevel,
            comment: metric.comment
        )
    }

    /// 日光浴指標から行を生成
    static func daylight(_ metric: DaylightMetric) -> RhythmMetricRowView {
        RhythmMetricRowView(
            icon: "sun.max.fill",
            iconColor: .gaugeYellow,
            title: "日光",
            value: metric.displayValue,
            gaugeLevel: metric.gaugeLevel,
            comment: metric.comment,
            showWarning: metric.needsWarning
        )
    }

    /// 体温位相指標から行を生成
    static func temperature(_ metric: TemperatureMetric) -> RhythmMetricRowView {
        RhythmMetricRowView(
            icon: "thermometer.medium",
            iconColor: .tempoSageGreen,
            title: "体温",
            value: metric.displayValue,
            gaugeLevel: metric.gaugeLevel,
            comment: metric.comment,
            showWarning: metric.showWarningIcon
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Metric Row - HRV") {
    RhythmMetricRowView.hrv(.mock)
        .background(Color.tempoLightCream)
}

#Preview("Metric Row - All Types") {
    let metrics = RhythmMetrics.mock

    return VStack(spacing: 0) {
        RhythmMetricRowView.hrv(metrics.hrv)
        Divider().padding(.horizontal, 16)
        RhythmMetricRowView.sleep(metrics.sleep)
        Divider().padding(.horizontal, 16)
        RhythmMetricRowView.steps(metrics.steps)
        Divider().padding(.horizontal, 16)
        RhythmMetricRowView.daylight(metrics.daylight)
        if let temp = metrics.temperature {
            Divider().padding(.horizontal, 16)
            RhythmMetricRowView.temperature(temp)
        }
    }
    .background(Color.tempoLightCream)
    .cornerRadius(12)
    .padding()
    .background(Color.tempoBackground)
}
#endif
