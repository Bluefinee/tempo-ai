//
//  View+Accessibility.swift
//  TempoAI
//
//  View Extensions for Accessibility (VoiceOver, Dynamic Type)
//

import SwiftUI

// MARK: - Accessibility Extensions

extension View {

    // MARK: - Score Accessibility

    /// スコア表示用のアクセシビリティ設定
    /// - Parameters:
    ///   - label: スコアラベル（例: "自律神経"）
    ///   - value: スコア値
    ///   - isCalibrating: キャリブレーション中かどうか
    /// - Returns: アクセシビリティ設定済みView
    func scoreAccessibility(
        label: String,
        value: Int?,
        isCalibrating: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(scoreAccessibilityLabel(label: label, value: value, isCalibrating: isCalibrating))
    }

    private func scoreAccessibilityLabel(label: String, value: Int?, isCalibrating: Bool) -> String {
        if isCalibrating {
            return "\(label)スコア、学習中"
        } else if let value = value {
            return "\(label)スコア、\(value)点、\(TempoColors.scoreLabel(for: value))"
        } else {
            return "\(label)スコア、データなし"
        }
    }

    // MARK: - Card Accessibility

    /// カード用のアクセシビリティ設定
    /// - Parameters:
    ///   - label: カードのラベル
    ///   - hint: ヒント（タップ可能な場合の説明）
    ///   - isTappable: タップ可能かどうか
    /// - Returns: アクセシビリティ設定済みView
    func cardAccessibility(
        label: String,
        hint: String? = nil,
        isTappable: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(isTappable ? (hint ?? "詳細を表示するにはダブルタップ") : (hint ?? ""))
            .accessibilityAddTraits(isTappable ? .isButton : [])
    }

    // MARK: - Button Accessibility

    /// ボタン用のアクセシビリティ設定
    /// - Parameters:
    ///   - label: ボタンのラベル
    ///   - hint: ヒント
    ///   - isLoading: 読み込み中かどうか
    /// - Returns: アクセシビリティ設定済みView
    func buttonAccessibility(
        label: String,
        hint: String? = nil,
        isLoading: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(isLoading ? "読み込み中" : (hint ?? ""))
            .accessibilityAddTraits(.isButton)
    }

    // MARK: - Section Header Accessibility

    /// セクションヘッダー用のアクセシビリティ設定
    /// - Parameter title: セクションタイトル
    /// - Returns: アクセシビリティ設定済みView
    func sectionHeaderAccessibility(_ title: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Progress Accessibility

    /// プログレス表示用のアクセシビリティ設定
    /// - Parameters:
    ///   - label: ラベル
    ///   - current: 現在値
    ///   - total: 合計値
    /// - Returns: アクセシビリティ設定済みView
    func progressAccessibility(
        label: String,
        current: Int,
        total: Int
    ) -> some View {
        let percentage = total > 0 ? Int(Double(current) / Double(total) * 100) : 0
        return self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue("\(current)/\(total)、\(percentage)パーセント完了")
    }

    // MARK: - Hide from Accessibility

    /// アクセシビリティから非表示にする
    /// - Note: 装飾的な要素に使用
    func hideFromAccessibility() -> some View {
        self
            .accessibilityHidden(true)
    }
}

// MARK: - Semantic Accessibility

extension View {

    /// アクセシビリティ用のセマンティックラベルを追加
    /// - Parameter text: テキスト
    /// - Returns: ラベル設定済みView
    func semanticLabel(text: String) -> some View {
        self.accessibilityLabel(text)
    }

    /// 読み上げ順序を設定
    /// - Parameter priority: 優先度（高いほど先に読まれる）
    /// - Returns: 順序設定済みView
    func readingOrder(_ priority: Double) -> some View {
        self.accessibilitySortPriority(priority)
    }
}

// MARK: - Dynamic Type Support

extension View {

    /// Dynamic Type対応のスケーリングを適用
    /// - Returns: スケーリング設定済みView
    func dynamicTypeScaling() -> some View {
        self.dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }

    /// テキストサイズに応じてレイアウトを調整
    /// - Note: 大きなテキストサイズでは縦並びに変更
    @ViewBuilder
    func adaptiveStack<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ViewThatFits {
            HStack(spacing: TempoSpacing.md) {
                content()
            }
            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                content()
            }
        }
    }
}

// MARK: - Announcement

extension View {

    /// VoiceOverに変更を通知
    /// - Parameters:
    ///   - announcement: 通知メッセージ
    ///   - trigger: トリガー値
    /// - Returns: 通知設定済みView
    func announceChange<T: Equatable>(
        _ announcement: String,
        trigger: T
    ) -> some View {
        self.onChange(of: trigger) { _, _ in
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - Preview

#Preview("Accessibility Examples") {
    ScrollView {
        VStack(spacing: TempoSpacing.lg) {
            Text("Accessibility Examples")
                .font(TempoTypography.title2)
                .sectionHeaderAccessibility("アクセシビリティサンプル")

            // Score with accessibility
            HStack {
                Text("85")
                    .font(TempoTypography.scoreValue)
                Text("自律神経")
                    .font(TempoTypography.caption)
            }
            .scoreAccessibility(label: "自律神経", value: 85)
            .padding()
            .background(TempoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

            // Card with accessibility
            VStack(alignment: .leading) {
                Text("AI Daily Insight")
                    .font(TempoTypography.headline)
                Text("今日のアドバイスを表示します")
                    .font(TempoTypography.body)
            }
            .cardAccessibility(label: "AI Daily Insight、今日のアドバイスを表示します", isTappable: true)
            .padding()
            .background(TempoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

            // Decorative element (hidden from accessibility)
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(TempoColors.primary.opacity(0.3))
                .hideFromAccessibility()
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .background(TempoColors.background)
}
