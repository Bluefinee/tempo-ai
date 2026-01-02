//
//  InsightFeedbackView.swift
//  TempoAI
//
//  Feedback UI for AI Insight
//

import SwiftUI

// MARK: - InsightFeedbackView

/// AI Insightフィードバックビュー
/// 「このアドバイスは役立ちましたか？」の質問とボタン
struct InsightFeedbackView: View {

    // MARK: - Properties

    let isSubmitted: Bool
    let onFeedback: (Bool) -> Void

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(spacing: TempoSpacing.md) {
                if isSubmitted {
                    submittedContent
                } else {
                    questionContent
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Question Content

    private var questionContent: some View {
        VStack(spacing: TempoSpacing.md) {
            Text("このアドバイスは役立ちましたか？")
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: TempoSpacing.lg) {
                // Helpful button
                feedbackButton(
                    emoji: "👍",
                    label: "はい",
                    isHelpful: true
                )

                // Not helpful button
                feedbackButton(
                    emoji: "👎",
                    label: "いいえ",
                    isHelpful: false
                )
            }
        }
    }

    // MARK: - Feedback Button

    private func feedbackButton(
        emoji: String,
        label: String,
        isHelpful: Bool
    ) -> some View {
        Button {
            onFeedback(isHelpful)
        } label: {
            VStack(spacing: TempoSpacing.xs) {
                Text(emoji)
                    .font(.system(size: 32))

                Text(label)
                    .font(TempoTypography.subheadline)
                    .foregroundStyle(TempoColors.textSecondary)
            }
            .frame(width: 80, height: 80)
            .background(TempoColors.secondary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius))
        }
        .accessibilityLabel("\(label)、\(isHelpful ? "役に立った" : "役に立たなかった")")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Submitted Content

    private var submittedContent: some View {
        VStack(spacing: TempoSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(TempoColors.primary)

            Text("フィードバックありがとうございます！")
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)

            Text("今後のアドバイス改善に活用させていただきます")
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, TempoSpacing.md)
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        if isSubmitted {
            return "フィードバック完了。ありがとうございます。"
        } else {
            return "このアドバイスは役立ちましたか？はい、またはいいえをタップしてください。"
        }
    }
}

// MARK: - Preview

#Preview("InsightFeedbackView - Not Submitted") {
    VStack {
        InsightFeedbackView(
            isSubmitted: false,
            onFeedback: { isHelpful in
                print("Helpful: \(isHelpful)")
            }
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("InsightFeedbackView - Submitted") {
    VStack {
        InsightFeedbackView(
            isSubmitted: true,
            onFeedback: { _ in }
        )
    }
    .padding()
    .background(TempoColors.background)
}
