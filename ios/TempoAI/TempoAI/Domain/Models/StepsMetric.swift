import Foundation

/// 歩数指標モデル
/// スコア = 達成（70点）+ 7日平均比較（30点）
struct StepsMetric {
    let todaySteps: Int
    let average7d: Int

    static let targetSteps: Int = 8000

    /// スコア算出（0-100）
    var score: Int {
        // 達成（70点）
        let achievementScore = min(70, (todaySteps * 70) / Self.targetSteps)

        // 7日平均比較（30点）
        let ratio = average7d > 0 ? Double(todaySteps) / Double(average7d) : 1.0
        let comparisonScore: Int
        switch ratio {
        case 1.0...: comparisonScore = 30
        case 0.8..<1.0: comparisonScore = 20
        default: comparisonScore = 10
        }

        return min(100, achievementScore + comparisonScore)
    }

    /// スコアに基づくコメント
    var comment: String {
        switch score {
        case 80...100: return "素晴らしい活動量"
        case 60..<80: return "良いペースです"
        case 40..<60: return "もう少し動けると◎"
        case 20..<40: return "少し歩いてみましょう"
        default: return "体を動かしましょう"
        }
    }

    /// 5段階ゲージレベル
    var gaugeLevel: Int {
        RhythmMetrics.scoreToGauge(score)
    }

    private static let stepsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    /// 表示用値（カンマ区切り）
    var displayValue: String {
        Self.stepsFormatter.string(from: NSNumber(value: todaySteps)) ?? "\(todaySteps)"
    }
}

// MARK: - Mock Data

extension StepsMetric {
    static var mock: StepsMetric {
        StepsMetric(
            todaySteps: 6500,
            average7d: 7200
        )
    }

    static var mockGood: StepsMetric {
        StepsMetric(
            todaySteps: 9500,
            average7d: 8000
        )
    }

    static var mockPoor: StepsMetric {
        StepsMetric(
            todaySteps: 2000,
            average7d: 6000
        )
    }
}
