//
//  SecondaryButton.swift
//  TempoAI
//
//  Secondary Button Component
//

import SwiftUI

// MARK: - Secondary Button

/// セカンダリボタン - 補助アクション用
/// - Note: 枠線のみ、Primary色テキスト
struct SecondaryButton: View {

    // MARK: - Properties

    let title: String
    let icon: String?
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: TempoSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(TempoTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(isEnabled ? TempoColors.primary : TempoColors.textTertiary)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius)
                    .stroke(
                        isEnabled ? TempoColors.primary : TempoColors.textTertiary,
                        lineWidth: 2
                    )
            )
        }
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Text Button

/// テキストボタン - 軽量なアクション用
/// - Note: 背景・枠線なし
struct TextButton: View {

    // MARK: - Properties

    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = TempoColors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: TempoSpacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(TempoTypography.subheadline)
            }
            .foregroundStyle(color)
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Icon Button

/// アイコンボタン - アイコンのみのアクション用
struct IconButton: View {

    // MARK: - Properties

    let icon: String
    let size: CGFloat
    let color: Color
    let accessibilityLabel: String
    let action: () -> Void

    // MARK: - Initialization

    init(
        icon: String,
        size: CGFloat = 24,
        color: Color = TempoColors.primary,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(color)
                .frame(width: size + 16, height: size + 16)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview("Secondary Buttons") {
    VStack(spacing: TempoSpacing.lg) {
        SecondaryButton("キャンセル") {
            print("Cancel")
        }

        SecondaryButton("戻る", icon: "arrow.left") {
            print("Back")
        }

        SecondaryButton("無効", isEnabled: false) {
            print("Disabled")
        }

        Divider()

        HStack(spacing: TempoSpacing.md) {
            TextButton("続きを読む", icon: "arrow.right") {
                print("Read more")
            }

            TextButton("スキップ", color: TempoColors.textSecondary) {
                print("Skip")
            }
        }

        Divider()

        HStack(spacing: TempoSpacing.lg) {
            IconButton(icon: "heart", accessibilityLabel: "お気に入り") {
                print("Heart")
            }

            IconButton(icon: "gear", accessibilityLabel: "設定") {
                print("Settings")
            }

            IconButton(icon: "xmark", color: TempoColors.textSecondary, accessibilityLabel: "閉じる") {
                print("Close")
            }
        }
    }
    .padding()
    .background(TempoColors.background)
}
