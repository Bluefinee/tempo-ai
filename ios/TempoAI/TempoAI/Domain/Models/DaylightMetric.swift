import Foundation

/// 日光浴指標モデル
/// スコア = 時間（70点）+ 朝ボーナス（30点）
struct DaylightMetric {
    let totalMinutes: Int
    let morningMinutes: Int

    static let targetMinutes: Int = 30

    /// スコア算出（0-100）
    var score: Int {
        // 時間（70点）
        let durationScore = min(70, (totalMinutes * 70) / Self.targetMinutes)

        // 朝ボーナス（30点）- 午前中の光を重視
        let timingScore: Int
        if morningMinutes >= 10 {
            timingScore = 30
        } else if totalMinutes > 0 {
            timingScore = 15
        } else {
            timingScore = 0
        }

        return min(100, durationScore + timingScore)
    }

    /// 目標までの残り分数
    var remainingMinutes: Int {
        max(0, Self.targetMinutes - totalMinutes)
    }

    /// 警告が必要か（20分未満）
    var needsWarning: Bool {
        totalMinutes < 20
    }

    /// スコアに基づくコメント
    var comment: String {
        if remainingMinutes > 0 {
            return "あと\(remainingMinutes)分浴びましょう"
        }
        switch score {
        case 80...100: return "十分な日光を浴びています"
        case 60..<80: return "あと少しで目標達成"
        default: return "外に出て日光を浴びましょう"
        }
    }

    /// 5段階ゲージレベル
    var gaugeLevel: Int {
        RhythmMetrics.scoreToGauge(score)
    }

    /// 表示用値
    var displayValue: String {
        "\(totalMinutes)分"
    }
}

// MARK: - Mock Data

extension DaylightMetric {
    static var mock: DaylightMetric {
        DaylightMetric(
            totalMinutes: 18,
            morningMinutes: 8
        )
    }

    static var mockGood: DaylightMetric {
        DaylightMetric(
            totalMinutes: 35,
            morningMinutes: 20
        )
    }

    static var mockPoor: DaylightMetric {
        DaylightMetric(
            totalMinutes: 5,
            morningMinutes: 0
        )
    }
}
