//
//  AutonomicScoreCalculator.swift
//  TempoAI
//

import Foundation

// MARK: - AutonomicScoreCalculator

/// 自律神経スコアを計算するサービス
/// HRVベースライン比較と睡眠データによる補正を行う
struct AutonomicScoreCalculator: Sendable {

    // MARK: - Constants

    /// ベースラインスコア（HRVがベースラインと同等の場合）
    private let baseScore: Double = 70.0

    /// HRVの業界平均値（ベースラインがない場合に使用）
    private let industryAverageHRV: Double = 50.0

    /// 深い睡眠不足の閾値（15%未満で補正適用）
    private let deepSleepDeficiencyThreshold: Double = 0.15

    /// 睡眠時間不足の閾値（6時間未満で補正適用）
    private let sleepDurationDeficiencyHours: Double = 6.0

    /// 各補正要素の減点値
    private let adjustmentPenalty: Double = 5.0

    // MARK: - Public Methods

    /// 自律神経スコアを計算する
    /// - Parameters:
    ///   - hrv: HRVメトリクス
    ///   - sleep: 睡眠メトリクス（補正計算に使用、nilの場合は補正なし）
    /// - Returns: 計算されたスコア（0-100）
    func calculate(hrv: HRVMetrics, sleep: SleepMetrics?) -> Score {
        let rawScore: Double = calculateRawScore(hrv: hrv)
        let adjustments: Double = calculateAdjustments(sleep: sleep)
        let finalScore: Int = Int((rawScore + adjustments).rounded())

        return Score(finalScore)
    }

    // MARK: - Private Methods

    /// 生スコアを計算（HRVベースライン比較）
    private func calculateRawScore(hrv: HRVMetrics) -> Double {
        let baseline: Double = effectiveBaseline(from: hrv.baseline30d)
        let hrvRatio: Double = hrv.value / baseline
        let deviation: Double = (hrvRatio - 1.0) * 100

        return baseScore + deviation
    }

    /// 有効なベースライン値を取得（0以下の場合は業界平均を使用）
    private func effectiveBaseline(from baseline: Double) -> Double {
        baseline > 0 ? baseline : industryAverageHRV
    }

    /// 睡眠データに基づく補正値を計算
    private func calculateAdjustments(sleep: SleepMetrics?) -> Double {
        guard let sleep = sleep else { return 0 }

        var adjustment: Double = 0

        // 深い睡眠不足の補正
        if sleep.deepSleepRatio < deepSleepDeficiencyThreshold {
            adjustment -= adjustmentPenalty
        }

        // 睡眠時間不足の補正
        if sleep.durationHours < sleepDurationDeficiencyHours {
            adjustment -= adjustmentPenalty
        }

        return adjustment
    }
}
