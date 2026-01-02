//
//  CardView.swift
//  TempoAI
//
//  Card View Component
//

import SwiftUI

// MARK: - Card View

/// 汎用カードコンポーネント
/// - Note: Warm Beige背景、角丸16pt
struct CardView<Content: View>: View {

    // MARK: - Properties

    let content: Content
    let backgroundColor: Color
    let hasShadow: Bool
    let onTap: (() -> Void)?

    // MARK: - Initialization

    init(
        backgroundColor: Color = TempoColors.cardBackground,
        hasShadow: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.hasShadow = hasShadow
        self.onTap = onTap
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle())
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        content
            .padding(TempoSpacing.cardPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
            .if(hasShadow) { view in
                view.tempoShadow()
            }
    }
}

// MARK: - Card Button Style

/// カードタップ時のアニメーションスタイル
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .pressedScale(configuration.isPressed)
    }
}

// MARK: - Info Card

/// 情報表示用カード（タイトル + サブタイトル + 詳細ボタン）
struct InfoCard: View {

    // MARK: - Properties

    let title: String
    let subtitle: String?
    let icon: String?
    let showDetailButton: Bool
    let onDetailTap: (() -> Void)?

    // MARK: - Initialization

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        showDetailButton: Bool = false,
        onDetailTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.showDetailButton = showDetailButton
        self.onDetailTap = onDetailTap
    }

    // MARK: - Body

    var body: some View {
        CardView(onTap: showDetailButton ? onDetailTap : nil) {
            HStack(alignment: .top, spacing: TempoSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 32)
                }

                VStack(alignment: .leading, spacing: TempoSpacing.xxs) {
                    Text(title)
                        .font(TempoTypography.headline)
                        .foregroundStyle(TempoColors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(TempoTypography.subheadline)
                            .foregroundStyle(TempoColors.textSecondary)
                            .lineLimit(3)
                    }
                }

                Spacer()

                if showDetailButton {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(TempoColors.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)\(subtitle.map { ", \($0)" } ?? "")")
        .accessibilityHint(showDetailButton ? "詳細を表示するにはダブルタップ" : "")
    }
}

// MARK: - Section Header

/// セクションヘッダー
struct SectionHeader: View {

    // MARK: - Properties

    let title: String
    let icon: String?
    let actionTitle: String?
    let onAction: (() -> Void)?

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(TempoColors.textSecondary)
            }

            Text(title)
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)

            Spacer()

            if let actionTitle = actionTitle, let onAction = onAction {
                TextButton(actionTitle, icon: "arrow.right", action: onAction)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

// MARK: - Preview

#Preview("Card Views") {
    ScrollView {
        VStack(spacing: TempoSpacing.lg) {
            SectionHeader("今日のコンディション", icon: "heart.fill")

            CardView {
                VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                    Text("シンプルなカード")
                        .font(TempoTypography.headline)
                    Text("これは基本的なカードコンポーネントです。")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                }
            }

            CardView(hasShadow: true, onTap: { print("Tapped") }) {
                HStack {
                    Text("タップ可能なカード")
                        .font(TempoTypography.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(TempoColors.textTertiary)
                }
            }

            InfoCard(
                title: "睡眠分析",
                subtitle: "昨夜は7時間半の深い睡眠が取れました。",
                icon: "moon.fill",
                showDetailButton: true,
                onDetailTap: { print("Detail tapped") }
            )

            SectionHeader(
                "分析",
                actionTitle: "すべて見る",
                onAction: { print("See all") }
            )

            InfoCard(
                title: "リズム安定",
                subtitle: "5日連続でリズムが安定しています。"
            )
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .background(TempoColors.background)
}
