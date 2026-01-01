import Foundation

// MARK: - DailyAdvice

/// AI生成された1日のアドバイス
struct DailyAdvice: Equatable, Codable, Sendable {

    // MARK: - Properties

    /// 要約（100-150文字）
    let summary: String

    /// 詳細（400-600文字）
    let fullInsight: String

    /// 推奨アクション
    let recommendedAction: RecommendedAction

    /// 生成日時
    let generatedAt: Date

    /// オフラインフォールバックか
    let isOfflineFallback: Bool

    // MARK: - Initialization

    init(
        summary: String,
        fullInsight: String,
        recommendedAction: RecommendedAction,
        generatedAt: Date = Date(),
        isOfflineFallback: Bool = false
    ) {
        self.summary = summary
        self.fullInsight = fullInsight
        self.recommendedAction = recommendedAction
        self.generatedAt = generatedAt
        self.isOfflineFallback = isOfflineFallback
    }
}

// MARK: - RecommendedAction

/// 推奨アクション
struct RecommendedAction: Equatable, Codable, Sendable {

    // MARK: - Properties

    let type: ActionType
    let message: String

    // MARK: - ActionType

    enum ActionType: String, Codable, Sendable {
        case breathing = "breathing"
        case morningLight = "morning_light"
        case rest = "rest"
        case activity = "activity"

        /// SF Symbolsアイコン名
        var icon: String {
            switch self {
            case .breathing:
                return "wind"
            case .morningLight:
                return "sun.max"
            case .rest:
                return "moon.zzz"
            case .activity:
                return "figure.walk"
            }
        }

        /// 日本語表示名
        var displayName: String {
            switch self {
            case .breathing:
                return "深呼吸"
            case .morningLight:
                return "朝の光"
            case .rest:
                return "休息"
            case .activity:
                return "活動"
            }
        }
    }
}

// MARK: - DailyAdvice+Fallback

extension DailyAdvice {

    /// オフライン時のフォールバックアドバイス
    static func fallback() -> DailyAdvice {
        DailyAdvice(
            summary: "ネットワーク接続がないため、最新のアドバイスを取得できませんでした。",
            fullInsight: """
            現在、ネットワーク接続が確認できないため、パーソナライズされたアドバイスを生成できません。

            一般的な健康維持のポイント:
            - 規則正しい睡眠リズムを心がけましょう
            - 朝の光を浴びて体内時計をリセット
            - こまめな水分補給を忘れずに
            - 適度な運動で自律神経を整えましょう

            ネットワーク接続が回復したら、再度アドバイスを取得してください。
            """,
            recommendedAction: RecommendedAction(
                type: .breathing,
                message: "深呼吸で気持ちを落ち着けましょう"
            ),
            generatedAt: Date(),
            isOfflineFallback: true
        )
    }
}

// MARK: - CustomStringConvertible

extension DailyAdvice: CustomStringConvertible {

    var description: String {
        let fallbackLabel: String = isOfflineFallback ? " (offline fallback)" : ""
        return "DailyAdvice(summary: \(summary.prefix(30))..., action: \(recommendedAction.type.displayName))\(fallbackLabel)"
    }
}
