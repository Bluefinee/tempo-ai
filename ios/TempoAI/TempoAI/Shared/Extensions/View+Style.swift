//
//  View+Style.swift
//  TempoAI
//
//  View Extensions for Styling
//

import SwiftUI

// MARK: - Conditional Modifiers

extension View {

    /// 条件付きでモディファイアを適用
    /// - Parameters:
    ///   - condition: 条件
    ///   - transform: 適用するモディファイア
    /// - Returns: モディファイア適用済み（または未適用）のView
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// オプショナル値が存在する場合にモディファイアを適用
    /// - Parameters:
    ///   - value: オプショナル値
    ///   - transform: 適用するモディファイア
    /// - Returns: モディファイア適用済み（または未適用）のView
    @ViewBuilder
    func ifLet<T, Content: View>(
        _ value: T?,
        transform: (Self, T) -> Content
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Navigation & Presentation

extension View {

    /// フルスクリーンカバーのプレゼンテーション
    /// - Parameters:
    ///   - isPresented: 表示フラグ
    ///   - onDismiss: 閉じた時のコールバック
    ///   - content: コンテンツ
    /// - Returns: プレゼンテーション設定済みView
    func tempoFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .background(TempoColors.background)
        }
    }

    /// シートプレゼンテーション
    /// - Parameters:
    ///   - isPresented: 表示フラグ
    ///   - onDismiss: 閉じた時のコールバック
    ///   - content: コンテンツ
    /// - Returns: プレゼンテーション設定済みView
    func tempoSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .background(TempoColors.background)
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Frame & Layout

extension View {

    /// 最大幅いっぱいに広げる
    /// - Parameter alignment: アライメント
    /// - Returns: 幅設定済みView
    func fillWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    /// 最大高さいっぱいに広げる
    /// - Parameter alignment: アライメント
    /// - Returns: 高さ設定済みView
    func fillHeight(alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

    /// 画面全体に広げる
    /// - Parameter alignment: アライメント
    /// - Returns: サイズ設定済みView
    func fillScreen(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Appearance

extension View {

    /// Tempoアプリの標準背景を適用
    func tempoBackground() -> some View {
        self.background(TempoColors.background)
    }

    /// タップ可能な外観を適用
    /// - Parameter isEnabled: 有効かどうか
    /// - Returns: 外観設定済みView
    func tappableAppearance(isEnabled: Bool = true) -> some View {
        self
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1.0 : 0.5)
    }

    /// ボーダー付きカプセル形状を適用
    /// - Parameters:
    ///   - isSelected: 選択状態
    ///   - fillColor: 塗りつぶし色
    ///   - borderColor: ボーダー色
    /// - Returns: スタイル適用済みView
    func capsuleStyle(
        isSelected: Bool = false,
        fillColor: Color = TempoColors.cardBackground,
        borderColor: Color = TempoColors.textTertiary
    ) -> some View {
        self
            .padding(.horizontal, TempoSpacing.sm)
            .padding(.vertical, TempoSpacing.xs)
            .background(isSelected ? TempoColors.primary : fillColor)
            .foregroundStyle(isSelected ? .white : TempoColors.textPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : borderColor.opacity(0.3),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Animation

extension View {

    /// 標準のTempoアニメーションを適用
    /// - Parameter value: アニメーショントリガー値
    /// - Returns: アニメーション設定済みView
    func tempoAnimation<V: Equatable>(_ value: V) -> some View {
        self.animation(.easeInOut(duration: 0.2), value: value)
    }

    /// スプリングアニメーションを適用
    /// - Parameter value: アニメーショントリガー値
    /// - Returns: アニメーション設定済みView
    func tempoSpringAnimation<V: Equatable>(_ value: V) -> some View {
        self.animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
    }

    /// フェードインアニメーションを適用
    /// - Parameters:
    ///   - isVisible: 表示状態
    ///   - duration: アニメーション時間
    /// - Returns: アニメーション設定済みView
    func fadeIn(
        isVisible: Bool,
        duration: Double = 0.3
    ) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .animation(.easeIn(duration: duration), value: isVisible)
    }

    /// スケールアニメーションを適用
    /// - Parameter isPressed: 押下状態
    /// - Returns: アニメーション設定済みView
    func pressedScale(_ isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

// MARK: - Shadow

extension View {

    /// Tempoスタイルのシャドウを適用
    /// - Parameter intensity: シャドウの強さ（0-1）
    /// - Returns: シャドウ設定済みView
    func tempoShadow(intensity: Double = 0.08) -> some View {
        self.shadow(
            color: Color.black.opacity(intensity),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    /// 浮き上がりシャドウを適用
    func elevatedShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )
    }
}

// MARK: - Interaction

extension View {

    /// Hapticフィードバックを追加
    /// - Parameter style: フィードバックスタイル
    /// - Returns: フィードバック設定済みView
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }
}

// MARK: - Preview

#Preview("Style Extensions") {
    ScrollView {
        VStack(spacing: TempoSpacing.lg) {
            Text("Style Extensions")
                .font(TempoTypography.title2)

            // Conditional modifier
            Text("Conditional (true)")
                .if(true) { view in
                    view.foregroundStyle(TempoColors.primary)
                }

            Text("Conditional (false)")
                .if(false) { view in
                    view.foregroundStyle(TempoColors.primary)
                }

            Divider()

            // Fill width
            Text("Fill Width")
                .padding()
                .fillWidth()
                .background(TempoColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

            Divider()

            // Capsule style
            HStack(spacing: TempoSpacing.sm) {
                Text("通常")
                    .capsuleStyle(isSelected: false)

                Text("選択中")
                    .capsuleStyle(isSelected: true)
            }

            Divider()

            // Shadow
            Text("Tempo Shadow")
                .padding()
                .background(TempoColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
                .tempoShadow()

            Text("Elevated Shadow")
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
                .elevatedShadow()
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .tempoBackground()
}
