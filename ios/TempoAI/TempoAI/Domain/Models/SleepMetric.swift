import Foundation

/// 睡眠指標モデル
/// スコア = 時間（50点）+ 深睡眠（30点）+ タイミング（20点）
struct SleepMetric {
    let duration: TimeInterval
    let deepSleep: TimeInterval?
    let bedtime: Date

    /// 睡眠時間（時）
    var hours: Double {
        duration / 3600
    }

    /// 深睡眠時間（時）
    var deepSleepHours: Double? {
        guard let deepSleep else { return nil }
        return deepSleep / 3600
    }

    /// スコア算出（0-100）
    var score: Int {
        // 睡眠時間（50点）
        let durationScore: Int
        switch hours {
        case 7...9: durationScore = 50
        case 6..<7: durationScore = 35
        case 5..<6: durationScore = 25
        default: durationScore = 15
        }

        // 深睡眠比率（30点）
        let deepRatio: Double
        if let deepSleep, duration > 0 {
            deepRatio = deepSleep / duration
        } else {
            // フォールバック: 深睡眠データがない場合は17%と推定
            deepRatio = 0.17
        }

        let deepScore: Int
        switch deepRatio {
        case 0.15...: deepScore = 30
        case 0.10..<0.15: deepScore = 20
        default: deepScore = 10
        }

        // 就寝タイミング（20点）
        let hour = Calendar.current.component(.hour, from: bedtime)
        let timingScore: Int
        switch hour {
        case 22, 23: timingScore = 20
        case 0: timingScore = 15
        case 1: timingScore = 10
        default: timingScore = 5
        }

        return durationScore + deepScore + timingScore
    }

    /// スコアに基づくコメント
    var comment: String {
        switch score {
        case 80...100: return "理想的な睡眠でした"
        case 60..<80: return "十分な睡眠時間"
        case 40..<60: return "もう少し眠れると◎"
        case 20..<40: return "睡眠不足気味です"
        default: return "睡眠を優先しましょう"
        }
    }

    /// 5段階ゲージレベル
    var gaugeLevel: Int {
        RhythmMetrics.scoreToGauge(score)
    }

    /// 表示用時間（例: "7.2h"）
    var displayValue: String {
        String(format: "%.1fh", hours)
    }
}

// MARK: - Mock Data

extension SleepMetric {
    static var mock: SleepMetric {
        let calendar = Calendar.current
        let now = Date()
        var bedtimeComponents = calendar.dateComponents([.year, .month, .day], from: now)
        bedtimeComponents.day! -= 1
        bedtimeComponents.hour = 23
        bedtimeComponents.minute = 0
        let bedtime = calendar.date(from: bedtimeComponents) ?? now

        return SleepMetric(
            duration: 7.2 * 3600,
            deepSleep: 1.5 * 3600,
            bedtime: bedtime
        )
    }

    static var mockPoor: SleepMetric {
        let calendar = Calendar.current
        let now = Date()
        var bedtimeComponents = calendar.dateComponents([.year, .month, .day], from: now)
        bedtimeComponents.hour = 2
        bedtimeComponents.minute = 30
        let bedtime = calendar.date(from: bedtimeComponents) ?? now

        return SleepMetric(
            duration: 5.0 * 3600,
            deepSleep: 0.5 * 3600,
            bedtime: bedtime
        )
    }
}
