//
//  Typography.swift
//  TempoAI
//
//  Design System - Typography
//  Based on ui-spec.md Section 4
//

import SwiftUI

// MARK: - Tempo Typography

/// TempoAI アプリ全体で使用するタイポグラフィ定義
/// - Note: SF Pro（iOS標準）を使用、Dynamic Type対応
enum TempoTypography {

    // MARK: - Large Titles

    /// Large Title - 34pt Bold
    /// 使用場面: ページタイトル
    static let largeTitle: Font = .system(size: 34, weight: .bold, design: .default)

    /// Title - 28pt Bold
    /// 使用場面: セクションタイトル
    static let title: Font = .system(size: 28, weight: .bold, design: .default)

    /// Title 2 - 22pt Bold
    /// 使用場面: 中程度の見出し
    static let title2: Font = .system(size: 22, weight: .bold, design: .default)

    /// Title 3 - 20pt Semibold
    /// 使用場面: 小さな見出し
    static let title3: Font = .system(size: 20, weight: .semibold, design: .default)

    // MARK: - Body Text

    /// Headline - 17pt Semibold
    /// 使用場面: 強調テキスト
    static let headline: Font = .system(size: 17, weight: .semibold, design: .default)

    /// Body - 17pt Regular
    /// 使用場面: 本文
    static let body: Font = .system(size: 17, weight: .regular, design: .default)

    /// Callout - 16pt Regular
    /// 使用場面: 重要な説明
    static let callout: Font = .system(size: 16, weight: .regular, design: .default)

    /// Subheadline - 15pt Regular
    /// 使用場面: 副見出し
    static let subheadline: Font = .system(size: 15, weight: .regular, design: .default)

    // MARK: - Small Text

    /// Footnote - 13pt Regular
    /// 使用場面: 小さな注釈
    static let footnote: Font = .system(size: 13, weight: .regular, design: .default)

    /// Caption - 12pt Regular
    /// 使用場面: 画像キャプション等
    static let caption: Font = .system(size: 12, weight: .regular, design: .default)

    /// Caption 2 - 11pt Regular
    /// 使用場面: 最小テキスト
    static let caption2: Font = .system(size: 11, weight: .regular, design: .default)

    // MARK: - Score Display

    /// Score Value - 大きなスコア表示用
    static let scoreValue: Font = .system(size: 48, weight: .bold, design: .rounded)

    /// Score Label - スコアラベル表示用
    static let scoreLabel: Font = .system(size: 14, weight: .medium, design: .default)
}

// MARK: - Dynamic Type Support

extension TempoTypography {

    /// Dynamic Type対応のFont取得
    /// - Parameters:
    ///   - style: テキストスタイル
    ///   - weight: フォントウェイト
    /// - Returns: Dynamic Type対応Font
    static func dynamicFont(
        for style: Font.TextStyle,
        weight: Font.Weight = .regular
    ) -> Font {
        .system(style, design: .default, weight: weight)
    }

    /// Dynamic Type対応のシステムフォント
    enum Dynamic {
        /// Large Title - Dynamic Type対応
        static let largeTitle: Font = .system(.largeTitle, design: .default, weight: .bold)

        /// Title - Dynamic Type対応
        static let title: Font = .system(.title, design: .default, weight: .bold)

        /// Title 2 - Dynamic Type対応
        static let title2: Font = .system(.title2, design: .default, weight: .bold)

        /// Title 3 - Dynamic Type対応
        static let title3: Font = .system(.title3, design: .default, weight: .semibold)

        /// Headline - Dynamic Type対応
        static let headline: Font = .system(.headline, design: .default, weight: .semibold)

        /// Body - Dynamic Type対応
        static let body: Font = .system(.body, design: .default, weight: .regular)

        /// Callout - Dynamic Type対応
        static let callout: Font = .system(.callout, design: .default, weight: .regular)

        /// Subheadline - Dynamic Type対応
        static let subheadline: Font = .system(.subheadline, design: .default, weight: .regular)

        /// Footnote - Dynamic Type対応
        static let footnote: Font = .system(.footnote, design: .default, weight: .regular)

        /// Caption - Dynamic Type対応
        static let caption: Font = .system(.caption, design: .default, weight: .regular)

        /// Caption 2 - Dynamic Type対応
        static let caption2: Font = .system(.caption2, design: .default, weight: .regular)
    }
}

// MARK: - Text Style Modifier

/// テキストスタイルを一括適用するModifier
struct TempoTextStyle: ViewModifier {
    let font: Font
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
    }
}

extension View {
    /// TempoAIのテキストスタイルを適用
    /// - Parameters:
    ///   - font: フォント
    ///   - color: テキストカラー
    /// - Returns: スタイル適用済みView
    func tempoTextStyle(
        _ font: Font,
        color: Color = TempoColors.textPrimary
    ) -> some View {
        modifier(TempoTextStyle(font: font, color: color))
    }
}

// MARK: - Preview

#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Large Title")
                    .font(TempoTypography.largeTitle)
                Text("Title")
                    .font(TempoTypography.title)
                Text("Title 2")
                    .font(TempoTypography.title2)
                Text("Title 3")
                    .font(TempoTypography.title3)
            }

            Divider()

            Group {
                Text("Headline")
                    .font(TempoTypography.headline)
                Text("Body - 本文テキストのサンプルです。")
                    .font(TempoTypography.body)
                Text("Callout - 重要な説明文です。")
                    .font(TempoTypography.callout)
                Text("Subheadline - 副見出し")
                    .font(TempoTypography.subheadline)
            }

            Divider()

            Group {
                Text("Footnote - 注釈テキスト")
                    .font(TempoTypography.footnote)
                Text("Caption - キャプション")
                    .font(TempoTypography.caption)
                Text("Caption 2 - 最小テキスト")
                    .font(TempoTypography.caption2)
            }

            Divider()

            HStack(alignment: .lastTextBaseline) {
                Text("85")
                    .font(TempoTypography.scoreValue)
                    .foregroundStyle(TempoColors.primary)
                Text("自律神経")
                    .font(TempoTypography.scoreLabel)
                    .foregroundStyle(TempoColors.textSecondary)
            }
        }
        .padding()
        .foregroundStyle(TempoColors.textPrimary)
    }
    .background(TempoColors.background)
}
