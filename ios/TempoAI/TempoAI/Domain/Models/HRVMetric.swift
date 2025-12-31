import Foundation

/// HRV指標モデル
/// スコア = 基準比較（70点）+ トレンド（30点）
struct HRVMetric {
    let todayValue: Double
    let average7d: Double
    let yesterdayValue: Double

    /// スコア算出（0-100）
    var score: Int {
        let baselineScore = average7d > 0
            ? min(70, Int((todayValue / average7d) * 70))
            : 35

        let trendScore: Int
        if todayValue > yesterdayValue * 1.05 {
            trendScore = 30
        } else if todayValue >= yesterdayValue * 0.95 {
            trendScore = 20
        } else {
            trendScore = 10
        }

        return min(100, baselineScore + trendScore)
    }

    /// 7日平均との差分パーセント
    var differencePercent: Int {
        guard average7d > 0 else { return 0 }
        return Int(((todayValue - average7d) / average7d) * 100)
    }

    /// 差分表示テキスト（例: "+9%", "-5%"）
    var differenceText: String {
        let percent = differencePercent
        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
    }

    /// スコアに基づくコメント
    var comment: String {
        switch score {
        case 80...100: return "自律神経は最高の状態"
        case 60..<80: return "良いコンディションです"
        case 40..<60: return "少し疲れ気味かも"
        case 20..<40: return "休息を意識しましょう"
        default: return "しっかり休んでください"
        }
    }

    /// 5段階ゲージレベル
    var gaugeLevel: Int {
        RhythmMetrics.scoreToGauge(score)
    }

    /// 表示用値（ms）
    var displayValue: String {
        "\(Int(todayValue))ms"
    }
}

// MARK: - Mock Data

extension HRVMetric {
    static var mock: HRVMetric {
        HRVMetric(
            todayValue: 72,
            average7d: 66,
            yesterdayValue: 68
        )
    }

    static var mockPoor: HRVMetric {
        HRVMetric(
            todayValue: 45,
            average7d: 60,
            yesterdayValue: 55
        )
    }
}
