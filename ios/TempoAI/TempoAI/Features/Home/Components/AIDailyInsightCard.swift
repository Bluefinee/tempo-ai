//
//  AIDailyInsightCard.swift
//  TempoAI
//
//  AI Daily Insight Card with Loading State
//

import SwiftUI

// MARK: - AIDailyInsightCard

/// AI Dailyインサイト要約カード
/// ニックネーム + 挨拶 + 要約（100-150文字）を表示
struct AIDailyInsightCard: View {

    // MARK: - Properties

    let greeting: String
    let insight: DailyAdvice?
    let isLoading: Bool
    let loadingStep: Int
    let onReadMore: () -> Void

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                // Greeting
                Text(greeting)
                    .font(TempoTypography.title3)
                    .foregroundStyle(TempoColors.textPrimary)

                if isLoading {
                    loadingContent
                } else if let insight = insight {
                    insightContent(insight)
                } else {
                    placeholderContent
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Loading Content

    private var loadingContent: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.sm) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(TempoColors.primary)

                Text(loadingMessage)
                    .font(TempoTypography.subheadline)
                    .foregroundStyle(TempoColors.textSecondary)
            }

            // Progress indicator
            ProgressBar(progress: loadingProgress)
                .frame(height: 4)
        }
    }

    // MARK: - Insight Content

    private func insightContent(_ insight: DailyAdvice) -> some View {
        VStack(alignment: .leading, spacing: TempoSpacing.sm) {
            // Summary text
            Text(insight.summary)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
                .lineLimit(4)

            // Read more button
            TextButton("続きを読む", icon: "chevron.right", action: onReadMore)
        }
    }

    // MARK: - Placeholder Content

    private var placeholderContent: some View {
        Text("今日のアドバイスを取得中...")
            .font(TempoTypography.body)
            .foregroundStyle(TempoColors.textTertiary)
    }

    // MARK: - Computed Properties

    private var loadingMessage: String {
        let steps: [String] = HomeViewModel.loadingSteps
        let index: Int = min(loadingStep, steps.count - 1)
        return steps[index]
    }

    private var loadingProgress: Double {
        Double(loadingStep + 1) / Double(HomeViewModel.loadingSteps.count)
    }

    private var accessibilityLabel: String {
        if isLoading {
            return "\(greeting)。\(loadingMessage)"
        } else if let insight = insight {
            return "\(greeting)。\(insight.summary)"
        } else {
            return greeting
        }
    }
}

// MARK: - Preview

#Preview("AIDailyInsightCard - Loading") {
    VStack {
        AIDailyInsightCard(
            greeting: "おはようございます、マサさん",
            insight: nil,
            isLoading: true,
            loadingStep: 2,
            onReadMore: {}
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("AIDailyInsightCard - With Insight") {
    VStack {
        AIDailyInsightCard(
            greeting: "おはようございます、マサさん",
            insight: DailyAdvice(
                summary: "今日は睡眠の質が良好で、自律神経も安定しています。午前中は集中力が高まる時間帯なので、重要なタスクに取り組むのに最適です。",
                fullInsight: "...",
                recommendedAction: RecommendedAction(
                    type: .breathing,
                    message: "1分間の深呼吸"
                ),
                generatedAt: Date()
            ),
            isLoading: false,
            loadingStep: 0,
            onReadMore: { print("Read more tapped") }
        )
    }
    .padding()
    .background(TempoColors.background)
}
