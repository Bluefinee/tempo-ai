//
//  RhythmScoreCalculator.swift
//  TempoAI
//

import Foundation

// MARK: - RhythmScoreCalculator

/// リズムスコアを計算するサービス
/// 就寝・起床時刻の一貫性、手首体温、睡眠ステージ移行で評価する
struct RhythmScoreCalculator: Sendable {

    // MARK: - Constants (With Wrist Temperature)

    /// 就寝時刻一貫性の重み（手首体温あり）
    private let bedtimeWeightWithTemp: Double = 0.35

    /// 起床時刻一貫性の重み（手首体温あり）
    private let wakeTimeWeightWithTemp: Double = 0.35

    /// 手首体温パターンの重み
    private let temperatureWeight: Double = 0.20

    /// 睡眠ステージ移行の重み
    private let stageTransitionWeight: Double = 0.10

    // MARK: - Constants (Without Wrist Temperature)

    /// 就寝時刻一貫性の重み（手首体温なし）
    private let bedtimeWeightNoTemp: Double = 0.45

    /// 起床時刻一貫性の重み（手首体温なし）
    private let wakeTimeWeightNoTemp: Double = 0.45

    /// デフォルトの睡眠ステージ移行スコア
    /// 現在はステージ移行データがないため、中間値を使用
    private let defaultStageTransitionScore: Double = 70.0

    // MARK: - Public Methods

    /// リズムスコアを計算する
    /// - Parameter analysis: リズム分析データ
    /// - Returns: 計算されたスコア（0-100）
    func calculate(analysis: RhythmAnalysis) -> Score {
        let bedtimeScore: Double = analysis.bedtimeConsistencyScore
        let wakeTimeScore: Double = analysis.wakeTimeConsistencyScore
        let stageScore: Double = defaultStageTransitionScore

        let finalScore: Double

        if let wristTemp = analysis.wristTemperature {
            let tempScore: Double = calculateTemperatureScore(status: wristTemp.status)
            finalScore = bedtimeScore * bedtimeWeightWithTemp
                + wakeTimeScore * wakeTimeWeightWithTemp
                + tempScore * temperatureWeight
                + stageScore * stageTransitionWeight
        } else {
            finalScore = bedtimeScore * bedtimeWeightNoTemp
                + wakeTimeScore * wakeTimeWeightNoTemp
                + stageScore * stageTransitionWeight
        }

        return Score(Int(finalScore.rounded()))
    }

    // MARK: - Private Methods

    /// 手首体温ステータスからスコアを算出
    private func calculateTemperatureScore(status: TemperatureStatus) -> Double {
        switch status {
        case .stable:
            return 100
        case .slightlyVariable:
            return 70
        case .variable:
            return 40
        }
    }
}
