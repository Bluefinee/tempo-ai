//
//  InsightsCard.swift
//  TempoAI
//
//  インサイト表示カード
//

import SwiftUI

// MARK: - InsightsCard

/// AIが生成したインサイトを表示するカード
struct InsightsCard: View {

    // MARK: - Properties

    let insights: [String]

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                // Header
                Text("インサイト")
                    .font(TempoTypography.headline)
                    .foregroundStyle(TempoColors.textPrimary)

                // Insights list
                if insights.isEmpty {
                    EmptyInsightsView()
                } else {
                    ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                        InsightRow(text: insight)
                    }
                }
            }
        }
    }
}

// MARK: - InsightRow

/// 個別のインサイト行
private struct InsightRow: View {

    // MARK: - Properties

    let text: String

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: TempoSpacing.sm) {
            Text("💡")
                .font(.system(size: 16))

            Text(text)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - Empty Insights View

/// インサイトがない場合の表示
private struct EmptyInsightsView: View {
    var body: some View {
        HStack(spacing: TempoSpacing.sm) {
            Image(systemName: "lightbulb")
                .foregroundStyle(TempoColors.textTertiary)

            Text("データを蓄積中です。しばらくお待ちください。")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
        }
        .padding(.vertical, TempoSpacing.sm)
    }
}

// MARK: - Preview

#Preview("Insights Card") {
    VStack(spacing: TempoSpacing.lg) {
        // With insights
        InsightsCard(insights: [
            "睡眠7時間以上の日はスコアが平均+10pt",
            "23時前就寝で深い睡眠が20%増加傾向",
            "リズムが安定しており、コンディション維持に貢献",
            "水曜日は自律神経スコアが低下傾向"
        ])

        // Empty insights
        InsightsCard(insights: [])
    }
    .padding()
    .background(TempoColors.background)
}
