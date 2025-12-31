import Foundation

/// 5指標統合モデル
struct RhythmMetrics {
    let hrv: HRVMetric
    let sleep: SleepMetric
    let steps: StepsMetric
    let daylight: DaylightMetric
    let temperature: TemperatureMetric?

    let sunriseTime: Date
    let sunsetTime: Date
    let insight: String
    let fetchedAt: Date

    /// スコア（0-100）を5段階ゲージレベル（1-5）に変換
    static func scoreToGauge(_ score: Int) -> Int {
        switch score {
        case 80...100: return 5
        case 60..<80: return 4
        case 40..<60: return 3
        case 20..<40: return 2
        default: return 1
        }
    }
}

// MARK: - Mock Data

extension RhythmMetrics {
    static var mock: RhythmMetrics {
        let calendar = Calendar.current
        let now = Date()
        let sunrise = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now) ?? now
        let sunset = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now) ?? now

        return RhythmMetrics(
            hrv: .mock,
            sleep: .mock,
            steps: .mock,
            daylight: .mock,
            temperature: .mock,
            sunriseTime: sunrise,
            sunsetTime: sunset,
            insight: "昨夜は就寝が30分早かったため、HRVが+9%改善しました。3日連続でリズムが安定しているため、回復効率がアップしています。",
            fetchedAt: now
        )
    }

    static var mockWithoutTemperature: RhythmMetrics {
        let calendar = Calendar.current
        let now = Date()
        let sunrise = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now) ?? now
        let sunset = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now) ?? now

        return RhythmMetrics(
            hrv: .mock,
            sleep: .mock,
            steps: .mock,
            daylight: .mock,
            temperature: nil,
            sunriseTime: sunrise,
            sunsetTime: sunset,
            insight: "今朝の睡眠は7.2時間でした。十分な睡眠時間を確保できています。",
            fetchedAt: now
        )
    }

    static var mockPoor: RhythmMetrics {
        let calendar = Calendar.current
        let now = Date()
        let sunrise = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now) ?? now
        let sunset = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now) ?? now

        return RhythmMetrics(
            hrv: .mockPoor,
            sleep: .mockPoor,
            steps: .mockPoor,
            daylight: .mockPoor,
            temperature: .mockLate,
            sunriseTime: sunrise,
            sunsetTime: sunset,
            insight: "睡眠リズムが不安定なため、HRVが低下しています。まずは就寝時刻を一定に保つことから始めてみましょう。",
            fetchedAt: now
        )
    }
}
