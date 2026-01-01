//
//  ActivityScoreCalculator.swift
//  TempoAI
//

import Foundation

// MARK: - ActivityScoreCalculator

/// 活動量スコアを計算するサービス
/// 歩数と運動時間で評価する
struct ActivityScoreCalculator: Sendable {

    // MARK: - Constants

    /// 歩数の重み
    private let stepsWeight: Double = 0.6

    /// 運動時間の重み
    private let exerciseWeight: Double = 0.4

    /// 目標歩数
    private let targetSteps: Double = 8000

    /// 目標運動時間（分）
    private let targetExerciseMinutes: Int = 30

    // MARK: - Public Methods

    /// 活動量スコアを計算する
    /// - Parameter activity: 活動量メトリクス
    /// - Returns: 計算されたスコア（0-100）
    func calculate(activity: ActivityMetrics) -> Score {
        let stepScore: Double = calculateStepScore(steps: activity.stepsYesterday)
        let exerciseScore: Double = calculateExerciseScore(minutes: activity.activeMinutesYesterday)

        let finalScore: Double = stepScore * stepsWeight + exerciseScore * exerciseWeight

        return Score(Int(finalScore.rounded()))
    }

    // MARK: - Private Methods

    /// 歩数スコアを計算
    private func calculateStepScore(steps: Int) -> Double {
        let stepRatio: Double = Double(steps) / targetSteps

        if stepRatio >= 1.0 {
            return 100
        } else if stepRatio >= 0.75 {
            // 80-100の範囲で線形補間
            return 80 + (stepRatio - 0.75) * 80
        } else if stepRatio >= 0.5 {
            // 60-80の範囲で線形補間
            return 60 + (stepRatio - 0.5) * 80
        } else {
            // 0-60の範囲で線形補間
            return stepRatio * 120
        }
    }

    /// 運動時間スコアを計算
    private func calculateExerciseScore(minutes: Int) -> Double {
        switch minutes {
        case 30...:
            return 100
        case 20..<30:
            return 80
        case 10..<20:
            return 60
        case 5..<10:
            return 40
        default:
            return 20
        }
    }
}
