//
//  HomeViewModel+RhythmCalculations.swift
//  TempoAI
//
//  リズム分析の計算ロジック
//

import Foundation

extension HomeViewModel {

    // MARK: - Rhythm Analysis

    /// 睡眠履歴からリズム分析を計算
    func calculateRhythmAnalysis(from sleepHistory: [SleepMetrics]) -> RhythmAnalysis {
        guard sleepHistory.count >= 2 else {
            return RhythmAnalysis(
                bedtimeStddevMinutes: 60,
                wakeTimeStddevMinutes: 60,
                consecutiveStableDays: 0,
                wristTemperature: nil
            )
        }

        // 就寝時刻の標準偏差を計算
        let bedtimes: [Double] = sleepHistory.map { $0.bedtime.timeIntervalSince1970 }
        let wakeTimes: [Double] = sleepHistory.map { $0.wakeTime.timeIntervalSince1970 }

        let bedtimeStddev: Double = standardDeviation(bedtimes) / 60 // 秒→分
        let wakeTimeStddev: Double = standardDeviation(wakeTimes) / 60

        // 連続安定日数を計算
        let stableDays: Int = countConsecutiveStableDays(from: sleepHistory)

        return RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: stableDays,
            wristTemperature: nil
        )
    }

    // MARK: - Statistical Helpers

    /// 標準偏差を計算
    func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean: Double = values.reduce(0, +) / Double(values.count)
        let squaredDiffs: Double = values.reduce(0) { $0 + pow($1 - mean, 2) }
        return sqrt(squaredDiffs / Double(values.count - 1))
    }

    /// 連続安定日数を計算（直近から逆算）
    ///
    /// 睡眠リズムが安定している（前日との就寝時刻差が30分以内）日数を
    /// 直近から遡ってカウントする
    func countConsecutiveStableDays(from sleepHistory: [SleepMetrics]) -> Int {
        guard sleepHistory.count >= 2 else { return 0 }

        // 日付順にソート（新しい順）
        let sortedHistory: [SleepMetrics] = sleepHistory.sorted {
            $0.bedtime > $1.bedtime
        }

        var consecutiveDays: Int = 1 // 最新の日は1日としてカウント

        for index in 0..<(sortedHistory.count - 1) {
            let current: SleepMetrics = sortedHistory[index]
            let previous: SleepMetrics = sortedHistory[index + 1]

            // 就寝時刻の差（分単位）
            let bedtimeDiff: Double = abs(
                current.bedtime.timeIntervalSince(previous.bedtime)
            ) / 60

            // 起床時刻の差（分単位）
            let wakeTimeDiff: Double = abs(
                current.wakeTime.timeIntervalSince(previous.wakeTime)
            ) / 60

            // 両方とも30分以内なら安定とみなす
            if bedtimeDiff <= 30 && wakeTimeDiff <= 30 {
                consecutiveDays += 1
            } else {
                // 連続が途切れたら終了
                break
            }
        }

        return consecutiveDays
    }
}
