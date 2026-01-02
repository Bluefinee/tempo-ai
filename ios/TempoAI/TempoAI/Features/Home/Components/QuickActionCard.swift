//
//  QuickActionCard.swift
//  TempoAI
//
//  Quick Action Card for Recommended Actions
//

import SwiftUI

// MARK: - QuickActionCard

/// クイックアクションカード
/// スコア・AI提案に基づく即時アクションを表示
struct QuickActionCard: View {

    // MARK: - Properties

    let action: RecommendedAction?
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        CardView(onTap: action != nil ? onTap : nil) {
            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                // Header
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(TempoColors.accent)

                    Text("今すぐできること")
                        .font(TempoTypography.subheadline)
                        .foregroundStyle(TempoColors.textSecondary)

                    Spacer()

                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(TempoColors.textTertiary)
                    }
                }

                if let action = action {
                    actionContent(action)
                } else {
                    placeholderContent
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .if(action != nil) { view in
            view.accessibilityHint("タップしてアクションを開始")
        }
    }

    // MARK: - Action Content

    private func actionContent(_ action: RecommendedAction) -> some View {
        HStack(spacing: TempoSpacing.md) {
            // Action Icon
            ZStack {
                Circle()
                    .fill(actionBackgroundColor(for: action.type))
                    .frame(width: 44, height: 44)

                Image(systemName: action.type.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(actionIconColor(for: action.type))
            }

            // Action Text
            VStack(alignment: .leading, spacing: TempoSpacing.xxs) {
                Text(action.type.displayName)
                    .font(TempoTypography.headline)
                    .foregroundStyle(TempoColors.textPrimary)

                Text(action.message)
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
    }

    // MARK: - Placeholder Content

    private var placeholderContent: some View {
        HStack {
            Spacer()
            Text("アクションを準備中...")
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textTertiary)
            Spacer()
        }
    }

    // MARK: - Helper Methods

    private func actionBackgroundColor(for type: RecommendedAction.ActionType) -> Color {
        switch type {
        case .breathing:
            return TempoColors.primary.opacity(0.15)
        case .morningLight:
            return Color.yellow.opacity(0.2)
        case .rest:
            return TempoColors.secondary.opacity(0.5)
        case .activity:
            return TempoColors.accent.opacity(0.2)
        }
    }

    private func actionIconColor(for type: RecommendedAction.ActionType) -> Color {
        switch type {
        case .breathing:
            return TempoColors.primary
        case .morningLight:
            return .orange
        case .rest:
            return TempoColors.textSecondary
        case .activity:
            return TempoColors.accent
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        guard let action = action else {
            return "今すぐできること: 準備中"
        }
        return "今すぐできること。\(action.type.displayName)。\(action.message)"
    }
}

// MARK: - Preview

#Preview("QuickActionCard - Breathing") {
    VStack {
        QuickActionCard(
            action: RecommendedAction(
                type: .breathing,
                message: "1分間の深呼吸で自律神経を整えましょう"
            ),
            onTap: { print("Action tapped") }
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("QuickActionCard - Morning Light") {
    VStack {
        QuickActionCard(
            action: RecommendedAction(
                type: .morningLight,
                message: "朝の光を10分間浴びて体内時計をリセット"
            ),
            onTap: { print("Action tapped") }
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("QuickActionCard - Loading") {
    VStack {
        QuickActionCard(
            action: nil,
            onTap: {}
        )
    }
    .padding()
    .background(TempoColors.background)
}
