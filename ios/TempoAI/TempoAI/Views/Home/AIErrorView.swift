/**
 * @fileoverview AI Error Display Components
 *
 * AI分析接続エラー時の表示コンポーネント。
 * ユーザーにエラー状況を明確に伝えつつ、
 * 基本機能は継続使用可能であることを示します。
 */

import SwiftUI

/// AI接続エラー表示ビュー
/// エラー状況を明示しつつ、代替手段を提供
struct AIErrorView: View {
    let error: AnalysisError?
    let fallbackAvailable: Bool
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // エラーアイコンとメッセージ
            VStack(spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(ColorPalette.warning)

                VStack(spacing: Spacing.sm) {
                    Text("AI分析に接続できません")
                        .typography(.headline)
                        .foregroundColor(ColorPalette.richBlack)
                        .multilineTextAlignment(.center)

                    Text(errorMessage)
                        .typography(.body)
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.center)
                }
            }

            // 代替手段の説明
            if fallbackAvailable {
                VStack(spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorPalette.success)

                        Text("基本分析は継続中")
                            .typography(.subhead)
                            .foregroundColor(ColorPalette.success)
                    }

                    Text("エネルギー計算やヘルスケアデータ表示は正常に動作しています。AI分析は後で再試行できます。")
                        .typography(.caption)
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(ColorPalette.success.opacity(0.1))
                )
            }

            // アクションボタン
            VStack(spacing: Spacing.sm) {
                Button("AI分析を再試行") {
                    onRetry()
                }
                .typography(.subhead)
                .foregroundColor(ColorPalette.pureWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(ColorPalette.primaryAccent)
                .cornerRadius(CornerRadius.md)

                Button("基本分析のみで継続") {
                    // 基本分析モードに切り替え
                    // TODO: 基本分析モード実装
                }
                .typography(.caption)
                .foregroundColor(ColorPalette.gray600)
            }
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(ColorPalette.pureWhite)
                .shadow(color: ColorPalette.richBlack.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(ColorPalette.warning.opacity(0.3), lineWidth: 1)
        )
    }

    private var errorMessage: String {
        if let error = error {
            switch error {
            case .aiServiceUnavailable:
                return "AI分析サービスに接続できません。ネットワーク接続を確認してください。"
            case .healthDataUnavailable:
                return "HealthKitデータが取得できません。設定でアクセス許可を確認してください。"
            case .weatherDataUnavailable:
                return "気象データが取得できません。位置情報の許可を確認してください。"
            default:
                return "一時的な問題が発生しています。しばらく待ってから再試行してください。"
            }
        } else {
            return "AI分析サービスとの接続に問題があります。"
        }
    }
}

/// データソース表示バッジ
/// AI/Fallback/キャッシュ等の状態を明示
struct DataSourceBadge: View {
    let source: AnalysisSource

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: sourceIcon)
                .font(.caption)
                .foregroundColor(sourceColor)

            Text(sourceText)
                .typography(.caption)
                .foregroundColor(sourceColor)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(sourceColor.opacity(0.1))
        )
    }

    private var sourceIcon: String {
        switch source {
        case .hybrid: return "brain.head.profile"
        case .cached: return "clock.arrow.circlepath"
        case .fallback: return "exclamationmark.triangle"
        case .aiError: return "wifi.slash"
        case .staticOnly: return "function"
        }
    }

    private var sourceText: String {
        switch source {
        case .hybrid: return "AI分析"
        case .cached: return "キャッシュ"
        case .fallback: return "基本分析"
        case .aiError: return "接続エラー"
        case .staticOnly: return "静的分析"
        }
    }

    private var sourceColor: Color {
        switch source {
        case .hybrid: return ColorPalette.success
        case .cached: return ColorPalette.info
        case .fallback: return ColorPalette.warning
        case .aiError: return ColorPalette.error
        case .staticOnly: return ColorPalette.gray500
        }
    }
}

/// AI分析結果の有効期限表示
/// 朝の分析が一日中有効であることを示す
struct AnalysisValidityIndicator: View {
    let generatedAt: Date
    let validUntil: Date?

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(ColorPalette.gray500)

                Text("分析時刻: \(formattedGeneratedTime)")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }

            if let validUntil = validUntil {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(ColorPalette.success)

                    Text("有効期限: \(formattedValidUntil)")
                        .typography(.caption)
                        .foregroundColor(ColorPalette.success)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(ColorPalette.gray50)
        )
    }

    private var formattedGeneratedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: generatedAt)
    }

    private var formattedValidUntil: String {
        guard let validUntil = validUntil else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: validUntil)
    }
}
