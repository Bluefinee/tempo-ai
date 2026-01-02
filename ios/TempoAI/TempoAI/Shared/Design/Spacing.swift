//
//  Spacing.swift
//  TempoAI
//
//  Design System - Spacing
//  Based on ui-spec.md Section 5
//

import SwiftUI

// MARK: - Tempo Spacing

/// TempoAI アプリ全体で使用するスペーシング定義
/// - Note: 4ptベースのスペーシングシステム
enum TempoSpacing {

    // MARK: - Base Spacing Units

    /// 2xs - 4pt - 最小間隔
    static let xxs: CGFloat = 4

    /// xs - 8pt - アイコンとテキスト間
    static let xs: CGFloat = 8

    /// sm - 12pt - 関連要素間
    static let sm: CGFloat = 12

    /// md - 16pt - セクション内パディング
    static let md: CGFloat = 16

    /// lg - 20pt - セクション間
    static let lg: CGFloat = 20

    /// xl - 24pt - 大きなセクション間
    static let xl: CGFloat = 24

    /// 2xl - 32pt - 画面セクション間
    static let xxl: CGFloat = 32

    // MARK: - Layout Constants

    /// 画面端余白
    static let screenPadding: CGFloat = 16

    /// カード内パディング
    static let cardPadding: CGFloat = 16

    /// カード角丸
    static let cardCornerRadius: CGFloat = 16

    /// ボタン角丸
    static let buttonCornerRadius: CGFloat = 12

    /// 小さい角丸（アイコン等）
    static let smallCornerRadius: CGFloat = 8
}

// MARK: - Edge Insets Presets

extension TempoSpacing {

    /// 画面全体のパディング
    static let screenInsets = EdgeInsets(
        top: md,
        leading: screenPadding,
        bottom: md,
        trailing: screenPadding
    )

    /// カード内のパディング
    static let cardInsets = EdgeInsets(
        top: cardPadding,
        leading: cardPadding,
        bottom: cardPadding,
        trailing: cardPadding
    )

    /// セクション間のパディング
    static let sectionInsets = EdgeInsets(
        top: lg,
        leading: 0,
        bottom: lg,
        trailing: 0
    )
}

// MARK: - Spacing View Modifiers

/// 画面パディングを適用するModifier
struct ScreenPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, TempoSpacing.screenPadding)
    }
}

/// カードスタイルを適用するModifier
struct CardStyleModifier: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(TempoSpacing.cardPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
    }
}

extension View {
    /// 画面の左右パディングを適用
    func screenPadding() -> some View {
        modifier(ScreenPaddingModifier())
    }

    /// カードスタイルを適用
    /// - Parameter backgroundColor: 背景色（デフォルト: cardBackground）
    func cardStyle(backgroundColor: Color = TempoColors.cardBackground) -> some View {
        modifier(CardStyleModifier(backgroundColor: backgroundColor))
    }
}

// MARK: - Preview

#Preview("Spacing System") {
    ScrollView {
        VStack(alignment: .leading, spacing: TempoSpacing.lg) {
            Text("Spacing Scale")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                SpacingRow(name: "xxs (4pt)", spacing: TempoSpacing.xxs)
                SpacingRow(name: "xs (8pt)", spacing: TempoSpacing.xs)
                SpacingRow(name: "sm (12pt)", spacing: TempoSpacing.sm)
                SpacingRow(name: "md (16pt)", spacing: TempoSpacing.md)
                SpacingRow(name: "lg (20pt)", spacing: TempoSpacing.lg)
                SpacingRow(name: "xl (24pt)", spacing: TempoSpacing.xl)
                SpacingRow(name: "xxl (32pt)", spacing: TempoSpacing.xxl)
            }

            Divider()

            Text("Card Style Example")
                .font(TempoTypography.title3)
                .foregroundStyle(TempoColors.textPrimary)

            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                Text("This is a card with cardStyle modifier")
                    .font(TempoTypography.body)
                Text("It has proper padding and rounded corners")
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textSecondary)
            }
            .cardStyle()

            Text("Corner Radius")
                .font(TempoTypography.title3)
                .foregroundStyle(TempoColors.textPrimary)

            HStack(spacing: TempoSpacing.md) {
                RoundedRectangle(cornerRadius: TempoSpacing.smallCornerRadius)
                    .fill(TempoColors.primary)
                    .frame(width: 48, height: 48)
                    .overlay(Text("8").foregroundStyle(.white))

                RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius)
                    .fill(TempoColors.accent)
                    .frame(width: 48, height: 48)
                    .overlay(Text("12").foregroundStyle(.white))

                RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius)
                    .fill(TempoColors.secondary)
                    .frame(width: 48, height: 48)
                    .overlay(Text("16").foregroundStyle(TempoColors.textPrimary))
            }
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .background(TempoColors.background)
}

private struct SpacingRow: View {
    let name: String
    let spacing: CGFloat

    var body: some View {
        HStack {
            Text(name)
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textSecondary)
                .frame(width: 100, alignment: .leading)
            Rectangle()
                .fill(TempoColors.primary)
                .frame(width: spacing, height: 16)
        }
    }
}
