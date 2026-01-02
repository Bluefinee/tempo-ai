//
//  MorningCheckInSection.swift
//  TempoAI
//
//  Morning Check-in Section with Header
//

import SwiftUI

// MARK: - MorningCheckInSection

/// Morning Check-inセクション
/// 既存のMorningCheckInCardをラップしてセクションヘッダーを追加
struct MorningCheckInSection: View {

    // MARK: - Properties

    @Binding var mood: Mood?
    @Binding var todayMode: TodayMode?
    let isCompleted: Bool
    let onComplete: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.sm) {
            // Section Header
            SectionHeader(
                "今日の気分",
                icon: isCompleted ? "checkmark.circle.fill" : "face.smiling"
            )

            if isCompleted {
                completedView
            } else {
                MorningCheckInCard(
                    mood: $mood,
                    todayMode: $todayMode,
                    onComplete: onComplete
                )
            }
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        CardView {
            HStack(spacing: TempoSpacing.md) {
                // Mood display
                if let mood = mood {
                    VStack(spacing: TempoSpacing.xxs) {
                        Text(mood.icon)
                            .font(.system(size: 28))
                        Text("気分")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.textSecondary)
                    }
                }

                Divider()
                    .frame(height: 40)

                // Today mode display
                if let mode = todayMode {
                    VStack(spacing: TempoSpacing.xxs) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(TempoColors.primary)
                        Text(mode.label)
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.textSecondary)
                    }
                }

                Spacer()

                // Completed indicator
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(TempoColors.primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(completedAccessibilityLabel)
    }

    // MARK: - Accessibility

    private var completedAccessibilityLabel: String {
        var parts: [String] = ["チェックイン完了"]
        if let mood = mood {
            parts.append("気分: \(mood.accessibilityLabel)")
        }
        if let mode = todayMode {
            parts.append("モード: \(mode.label)")
        }
        return parts.joined(separator: "。")
    }
}

// MARK: - Preview

#Preview("MorningCheckInSection - Not Completed") {
    struct PreviewContainer: View {
        @State private var mood: Mood? = nil
        @State private var todayMode: TodayMode? = nil

        var body: some View {
            MorningCheckInSection(
                mood: $mood,
                todayMode: $todayMode,
                isCompleted: false,
                onComplete: {}
            )
            .padding()
            .background(TempoColors.background)
        }
    }
    return PreviewContainer()
}

#Preview("MorningCheckInSection - Completed") {
    struct PreviewContainer: View {
        @State private var mood: Mood? = .good
        @State private var todayMode: TodayMode? = .normal

        var body: some View {
            MorningCheckInSection(
                mood: $mood,
                todayMode: $todayMode,
                isCompleted: true,
                onComplete: {}
            )
            .padding()
            .background(TempoColors.background)
        }
    }
    return PreviewContainer()
}
