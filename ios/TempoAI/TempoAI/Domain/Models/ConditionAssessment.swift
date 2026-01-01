import Foundation

// MARK: - ConditionAssessment Aggregate

/// 全スコアを統合した状態評価の集約ルート
struct ConditionAssessment: Equatable, Codable, Sendable {

    // MARK: - Properties

    let sleepScore: Score
    let autonomicScore: Score
    let rhythmScore: Score
    let activityScore: Score
    let rhythmAnalysis: RhythmAnalysis

    // MARK: - Computed Properties

    /// 最も改善が必要な領域
    var weakestArea: Area {
        let scores: [(Area, Int)] = [
            (.sleep, sleepScore.value),
            (.autonomic, autonomicScore.value),
            (.rhythm, rhythmScore.value),
            (.activity, activityScore.value)
        ]
        return scores.min(by: { $0.1 < $1.1 })?.0 ?? .sleep
    }

    /// 全スコアの平均値
    var averageScore: Int {
        let total: Int = sleepScore.value + autonomicScore.value + rhythmScore.value + activityScore.value
        return total / 4
    }

    /// 総合的な状態
    var overallStatus: Score.Status {
        Score(averageScore).status
    }

    // MARK: - Area Enum

    enum Area: String, Codable, Sendable {
        case sleep = "睡眠"
        case autonomic = "自律神経"
        case rhythm = "リズム"
        case activity = "活動量"

        /// 改善のためのヒント
        var improvementHint: String {
            switch self {
            case .sleep:
                return "睡眠の質を高めることで、明日はもっと良いコンディションになりそうです。"
            case .autonomic:
                return "今日は無理せず、こまめに休憩を取りながら過ごしましょう。"
            case .rhythm:
                return "リズムを整えるために、朝の光を浴びることを意識してみてください。"
            case .activity:
                return "少し体を動かすと、気分もリフレッシュできますよ。"
            }
        }
    }
}
