//
//  InsightDetailView.swift
//  TempoAI
//
//  AI Insight Detail View with Full Content
//

import SwiftUI

// MARK: - InsightDetailView

/// AI Insight詳細画面
/// フルInsight表示とフィードバック機能
struct InsightDetailView: View {

    // MARK: - Properties

    let advice: DailyAdvice
    let onFeedback: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var feedbackSubmitted: Bool = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TempoSpacing.lg) {
                // Full Insight Content
                insightContent

                Divider()

                // Feedback Section
                feedbackSection
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.vertical, TempoSpacing.md)
        }
        .background(TempoColors.background)
        .navigationTitle("今日のインサイト")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: TempoSpacing.xxs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("戻る")
                    }
                    .foregroundStyle(TempoColors.primary)
                }
            }
        }
    }

    // MARK: - Insight Content

    private var insightContent: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                // Generated at timestamp
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(TempoColors.primary)

                    Text("AI生成")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textSecondary)

                    Spacer()

                    Text(formattedDate)
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textTertiary)
                }

                Divider()

                // Full insight text
                Text(advice.fullInsight)
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textPrimary)
                    .lineSpacing(4)

                // Recommended action
                if !advice.recommendedAction.message.isEmpty {
                    Divider()

                    recommendedActionView
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日のインサイト。\(advice.fullInsight)")
    }

    // MARK: - Recommended Action View

    private var recommendedActionView: some View {
        HStack(spacing: TempoSpacing.md) {
            ZStack {
                Circle()
                    .fill(TempoColors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: advice.recommendedAction.type.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(TempoColors.primary)
            }

            VStack(alignment: .leading, spacing: TempoSpacing.xxs) {
                Text("おすすめアクション")
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textSecondary)

                Text(advice.recommendedAction.message)
                    .font(TempoTypography.subheadline)
                    .foregroundStyle(TempoColors.textPrimary)
            }

            Spacer()
        }
    }

    // MARK: - Feedback Section

    private var feedbackSection: some View {
        InsightFeedbackView(
            isSubmitted: feedbackSubmitted,
            onFeedback: { isHelpful in
                onFeedback(isHelpful)
                withAnimation {
                    feedbackSubmitted = true
                }
            }
        )
    }

    // MARK: - Computed Properties

    private var formattedDate: String {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 H:mm"
        return formatter.string(from: advice.generatedAt)
    }
}

// MARK: - Preview

#Preview("InsightDetailView") {
    NavigationStack {
        InsightDetailView(
            advice: DailyAdvice(
                summary: "今日は睡眠の質が良好です。",
                fullInsight: """
                おはようございます、マサさん。

                📊 今日のコンディション
                昨夜は7時間半の深い睡眠が取れました。睡眠効率も95%と非常に良好です。

                ☽ 睡眠分析
                入眠までの時間が15分と理想的で、深い睡眠の割合も20%を超えています。レム睡眠も適切な時間が確保できており、記憶の定着や感情の処理がスムーズに行われたと考えられます。

                ◎ リズム分析
                5日連続で安定したリズムを維持できています。体内時計が整っている証拠です。このリズムを継続することで、より良いコンディションが期待できます。

                ☁ 環境影響
                本日は気圧が安定しており、自律神経への影響は少なそうです。紫外線指数は5で、中程度の注意が必要です。

                💡 今日の過ごし方
                午前中は集中力が高まる時間帯です。重要なタスクはこの時間に取り組むことをおすすめします。午後3時頃に軽い休憩を入れると、夕方までパフォーマンスを維持できます。

                今日も良い1日になりますように。
                """,
                recommendedAction: RecommendedAction(
                    type: .breathing,
                    message: "1分間の深呼吸で朝のスタートを整えましょう"
                ),
                generatedAt: Date()
            ),
            onFeedback: { isHelpful in
                print("Feedback: \(isHelpful)")
            }
        )
    }
}
