//
//  ScoreCalculator.swift
//  TempoAI
//

import Foundation

// MARK: - ScoreCalculator

/// 全スコアを統合して計算するファサード
/// 各個別のスコア計算機を使用してConditionAssessmentを生成する
struct ScoreCalculator: Sendable {

    // MARK: - Constants

    /// データ不足時のデフォルトスコア
    static let defaultScore: Int = 50

    // MARK: - Dependencies

    private let autonomicCalculator: AutonomicScoreCalculator
    private let sleepCalculator: SleepScoreCalculator
    private let rhythmCalculator: RhythmScoreCalculator
    private let activityCalculator: ActivityScoreCalculator

    // MARK: - Initialization

    init(
        autonomicCalculator: AutonomicScoreCalculator = AutonomicScoreCalculator(),
        sleepCalculator: SleepScoreCalculator = SleepScoreCalculator(),
        rhythmCalculator: RhythmScoreCalculator = RhythmScoreCalculator(),
        activityCalculator: ActivityScoreCalculator = ActivityScoreCalculator()
    ) {
        self.autonomicCalculator = autonomicCalculator
        self.sleepCalculator = sleepCalculator
        self.rhythmCalculator = rhythmCalculator
        self.activityCalculator = activityCalculator
    }

    // MARK: - Public Methods

    /// 全スコアを計算してConditionAssessmentを生成する
    /// - Parameters:
    ///   - healthMetrics: HealthKitから取得した健康データ
    ///   - rhythmAnalysis: リズム分析データ
    /// - Returns: 全スコアを含む状態評価
    func calculateAll(
        healthMetrics: HealthMetrics,
        rhythmAnalysis: RhythmAnalysis
    ) -> ConditionAssessment {
        let sleepScore: Score = calculateSleepScore(from: healthMetrics)
        let autonomicScore: Score = calculateAutonomicScore(from: healthMetrics)
        let rhythmScore: Score = rhythmCalculator.calculate(analysis: rhythmAnalysis)
        let activityScore: Score = calculateActivityScore(from: healthMetrics)

        return ConditionAssessment(
            sleepScore: sleepScore,
            autonomicScore: autonomicScore,
            rhythmScore: rhythmScore,
            activityScore: activityScore,
            rhythmAnalysis: rhythmAnalysis
        )
    }

    // MARK: - Private Methods

    /// 睡眠スコアを計算（データがない場合はデフォルト値）
    private func calculateSleepScore(from metrics: HealthMetrics) -> Score {
        guard let sleep = metrics.sleep else {
            return Score(Self.defaultScore)
        }
        return sleepCalculator.calculate(sleep: sleep)
    }

    /// 自律神経スコアを計算（データがない場合はデフォルト値）
    private func calculateAutonomicScore(from metrics: HealthMetrics) -> Score {
        guard let hrv = metrics.hrv else {
            return Score(Self.defaultScore)
        }
        return autonomicCalculator.calculate(hrv: hrv, sleep: metrics.sleep)
    }

    /// 活動量スコアを計算（データがない場合はデフォルト値）
    private func calculateActivityScore(from metrics: HealthMetrics) -> Score {
        guard let activity = metrics.activity else {
            return Score(Self.defaultScore)
        }
        return activityCalculator.calculate(activity: activity)
    }
}
