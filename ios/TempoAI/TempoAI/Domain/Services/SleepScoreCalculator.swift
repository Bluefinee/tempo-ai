//
//  SleepScoreCalculator.swift
//  TempoAI
//

import Foundation

// MARK: - SleepScoreCalculator

/// 睡眠スコアを計算するサービス
/// 睡眠時間、深い睡眠、レム睡眠の3要素で評価する
struct SleepScoreCalculator: Sendable {

    // MARK: - Constants

    /// 睡眠時間の重み（入眠効率がないため40%→45%に再配分）
    private let durationWeight: Double = 0.45

    /// 深い睡眠の重み（入眠効率がないため30%→35%に再配分）
    private let deepSleepWeight: Double = 0.35

    /// レム睡眠の重み
    private let remSleepWeight: Double = 0.2

    /// レム睡眠なしの場合の睡眠時間の重み
    private let durationWeightNoRem: Double = 0.55

    /// レム睡眠なしの場合の深い睡眠の重み
    private let deepSleepWeightNoRem: Double = 0.45

    // MARK: - Public Methods

    /// 睡眠スコアを計算する
    /// - Parameter sleep: 睡眠メトリクス
    /// - Returns: 計算されたスコア（0-100）
    func calculate(sleep: SleepMetrics) -> Score {
        let durationScore: Double = calculateDurationScore(hours: sleep.durationHours)
        let deepScore: Double = calculateDeepSleepScore(ratio: sleep.deepSleepRatio)

        let finalScore: Double

        // レム睡眠データがない場合は重みを再配分
        if sleep.remSleepMinutes == 0 {
            finalScore = durationScore * durationWeightNoRem + deepScore * deepSleepWeightNoRem
        } else {
            let remScore: Double = calculateRemSleepScore(ratio: sleep.remSleepRatio)
            finalScore = durationScore * durationWeight + deepScore * deepSleepWeight + remScore * remSleepWeight
        }

        return Score(Int(finalScore.rounded()))
    }

    // MARK: - Private Methods

    /// 睡眠時間スコアを計算
    private func calculateDurationScore(hours: Double) -> Double {
        switch hours {
        case 7...8:
            return 100
        case 6..<7:
            return 80
        case 8.01...9:
            return 90
        case 5..<6:
            return 60
        default:
            return 40
        }
    }

    /// 深い睡眠スコアを計算
    private func calculateDeepSleepScore(ratio: Double) -> Double {
        switch ratio {
        case 0.15...0.25:
            return 100
        case 0.10..<0.15:
            return 70
        case 0.2501...0.30:
            return 80
        default:
            return 50
        }
    }

    /// レム睡眠スコアを計算
    private func calculateRemSleepScore(ratio: Double) -> Double {
        switch ratio {
        case 0.20...0.25:
            return 100
        case 0.15..<0.20:
            return 80
        case 0.2501...0.30:
            return 85
        default:
            return 60
        }
    }
}
