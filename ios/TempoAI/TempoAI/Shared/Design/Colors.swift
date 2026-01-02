//
//  Colors.swift
//  TempoAI
//
//  Design System - Color Palette
//  Based on ui-spec.md Section 2
//

import SwiftUI

// MARK: - Tempo Colors

/// TempoAI アプリ全体で使用するカラーパレット
/// - Note: ui-spec.md に基づく定義
enum TempoColors {

    // MARK: - Primary Colors

    /// Primary (Soft Sage Green) - ボタン、アイコン、プログレスバー
    static let primary = Color(hex: "#7CB342")

    /// Secondary (Warm Beige) - 背景色
    static let secondary = Color(hex: "#F5F0E8")

    /// Accent (Soft Coral) - CTAボタン、重要な通知
    static let accent = Color(hex: "#E8A598")

    // MARK: - Background Colors

    /// Light Cream - メイン背景
    static let background = Color(hex: "#FAF8F5")

    /// Warm Beige - カード背景
    static let cardBackground = Color(hex: "#F5F0E8")

    /// Progress Background - プログレスバー背景
    static let progressBackground = Color(hex: "#E0E0E0")

    // MARK: - Text Colors

    /// Primary Text - 見出し、本文
    static let textPrimary = Color(hex: "#2D3436")

    /// Secondary Text - 補足、キャプション
    static let textSecondary = Color(hex: "#636E72")

    /// Tertiary Text - プレースホルダー
    static let textTertiary = Color(hex: "#B2BEC3")

    // MARK: - Score Status Colors

    /// Yellow - 注意（スコア40-59）
    static let warning = Color(hex: "#FFC107")

    /// Orange - 要注意（スコア20-39）
    static let caution = Color(hex: "#FF9800")

    /// Red - 要改善（スコア0-19）
    static let danger = Color(hex: "#F44336")

    // MARK: - Consistency Status Colors

    /// 安定 - Green（Primary色）
    static let good: Color = primary

    /// 回復中 - Yellow
    static let fair: Color = warning

    /// 乱れ気味 - Orange
    static let poor: Color = caution

    /// ConsistencyStatusに応じた色を返す
    /// - Parameter status: ConsistencyStatus
    /// - Returns: ステータスに応じた Color
    static func consistencyColor(for status: ConsistencyStatus) -> Color {
        switch status {
        case .stable:
            return good
        case .recovering:
            return fair
        case .unstable:
            return poor
        }
    }

    // MARK: - Score Color Function

    /// スコア値に応じた色を返す
    /// - Parameter value: スコア値（0-100）
    /// - Returns: スコア状態に応じた Color
    static func scoreColor(for value: Int) -> Color {
        switch value {
        case 60...:
            return primary
        case 40..<60:
            return warning
        case 20..<40:
            return caution
        default:
            return danger
        }
    }

    /// スコア状態のラベルを返す
    /// - Parameter value: スコア値（0-100）
    /// - Returns: 状態ラベル
    static func scoreLabel(for value: Int) -> String {
        switch value {
        case 80...:
            return "優秀"
        case 60..<80:
            return "良好"
        case 40..<60:
            return "注意"
        case 20..<40:
            return "要注意"
        default:
            return "要改善"
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Hex文字列からColorを生成
    /// - Parameter hex: 16進数カラーコード（#付き or なし）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

// MARK: - Preview

#Preview("Color Palette") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Primary Colors")
                    .font(.headline)
                ColorRow(name: "Primary", color: TempoColors.primary)
                ColorRow(name: "Secondary", color: TempoColors.secondary)
                ColorRow(name: "Accent", color: TempoColors.accent)
            }

            Group {
                Text("Background Colors")
                    .font(.headline)
                ColorRow(name: "Background", color: TempoColors.background)
                ColorRow(name: "Card Background", color: TempoColors.cardBackground)
            }

            Group {
                Text("Text Colors")
                    .font(.headline)
                ColorRow(name: "Text Primary", color: TempoColors.textPrimary)
                ColorRow(name: "Text Secondary", color: TempoColors.textSecondary)
                ColorRow(name: "Text Tertiary", color: TempoColors.textTertiary)
            }

            Group {
                Text("Score Colors")
                    .font(.headline)
                ColorRow(name: "Score 85 (Excellent)", color: TempoColors.scoreColor(for: 85))
                ColorRow(name: "Score 65 (Good)", color: TempoColors.scoreColor(for: 65))
                ColorRow(name: "Score 50 (Fair)", color: TempoColors.scoreColor(for: 50))
                ColorRow(name: "Score 30 (Poor)", color: TempoColors.scoreColor(for: 30))
                ColorRow(name: "Score 10 (Rest)", color: TempoColors.scoreColor(for: 10))
            }
        }
        .padding()
    }
    .background(TempoColors.background)
}

private struct ColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
            Text(name)
                .foregroundStyle(TempoColors.textPrimary)
            Spacer()
        }
    }
}
