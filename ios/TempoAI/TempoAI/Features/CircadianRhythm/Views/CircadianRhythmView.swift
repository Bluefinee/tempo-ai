import SwiftUI

/// サーカディアンリズム画面
/// Phase 12.5: SolarSyncサークル + 5指標リスト + AIインサイト
struct CircadianRhythmView: View {
    let metrics: RhythmMetrics

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 24時間サークル（Solar Sync）
                    SolarSyncCircleView(
                        sunriseTime: metrics.sunriseTime,
                        sunsetTime: metrics.sunsetTime,
                        phaseShiftHours: metrics.temperature?.phaseShiftHours
                    )
                    .frame(height: 280)
                    .padding(.horizontal, 16)

                    // 位相ズレ警告（1時間以上のズレがある場合）
                    if let temp = metrics.temperature, temp.showWarningIcon {
                        phaseShiftWarning(temp)
                            .padding(.horizontal, 16)
                    }

                    // 5指標カード
                    metricsCard
                        .padding(.horizontal, 16)

                    // AIインサイト
                    InsightCardView(insight: metrics.insight)
                        .padding(.horizontal, 16)

                    // タブバー用余白
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.top, 16)
            }
            .background(Color.tempoBackground)
            .navigationTitle("リズム")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Phase Shift Warning

    @ViewBuilder
    private func phaseShiftWarning(_ temp: TemperatureMetric) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.gaugeOrange)

            let shiftText = temp.phaseShiftHours >= 0
                ? "+\(String(format: "%.1f", temp.phaseShiftHours))h 遅れ"
                : "\(String(format: "%.1f", temp.phaseShiftHours))h 進み"

            Text("体内時計が\(shiftText)気味")
                .font(.system(size: 13))
                .foregroundColor(.tempoPrimaryText)

            Spacer()
        }
        .padding(12)
        .background(Color.gaugeOrange.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Metrics Card

    private var metricsCard: some View {
        VStack(spacing: 0) {
            RhythmMetricRowView.hrv(metrics.hrv)
            Divider().padding(.horizontal, 16)
            RhythmMetricRowView.sleep(metrics.sleep)
            Divider().padding(.horizontal, 16)
            RhythmMetricRowView.steps(metrics.steps)
            Divider().padding(.horizontal, 16)
            RhythmMetricRowView.daylight(metrics.daylight)

            // 体温（対応機種のみ）
            if let temp = metrics.temperature {
                Divider().padding(.horizontal, 16)
                RhythmMetricRowView.temperature(temp)
            }
        }
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

// MARK: - Preview

#if DEBUG
#Preview("Circadian Rhythm - Good") {
    CircadianRhythmView(metrics: .mock)
}

#Preview("Circadian Rhythm - Poor") {
    CircadianRhythmView(metrics: .mockPoor)
}

#Preview("Circadian Rhythm - No Temperature") {
    CircadianRhythmView(metrics: .mockWithoutTemperature)
}
#endif
