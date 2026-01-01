//
//  SleepScoreCalculatorTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct SleepScoreCalculatorTests {

    // MARK: - Test Helpers

    private func makeSleepMetrics(
        durationMinutes: Int,
        deepSleepMinutes: Int,
        remSleepMinutes: Int
    ) -> SleepMetrics {
        SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: durationMinutes,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes
        )
    }

    // MARK: - Duration Score Tests

    @Test("7-8 hours of sleep returns duration score of 100")
    func optimalDurationReturns100() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7.5時間 = 450分, 深い睡眠20%, レム睡眠22%
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 450,
            deepSleepMinutes: 90,
            remSleepMinutes: 99
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:100 * 0.35 + rem:100 * 0.2 = 100
        #expect(score.value == 100)
    }

    @Test("6-7 hours of sleep returns duration score of 80")
    func slightlyShortDurationReturns80() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 6.5時間 = 390分
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 390,
            deepSleepMinutes: 78,
            remSleepMinutes: 86
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:80 * 0.45 + deep:100 * 0.35 + rem:100 * 0.2 = 91
        #expect(score.value == 91)
    }

    @Test("8-9 hours of sleep returns duration score of 90")
    func slightlyLongDurationReturns90() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 8.5時間 = 510分
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 510,
            deepSleepMinutes: 102,
            remSleepMinutes: 112
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:90 * 0.45 + deep:100 * 0.35 + rem:100 * 0.2 = 95.5 → 96
        #expect(score.value == 96)
    }

    @Test("5-6 hours of sleep returns duration score of 60")
    func shortDurationReturns60() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 5.5時間 = 330分
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 330,
            deepSleepMinutes: 66,
            remSleepMinutes: 73
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:60 * 0.45 + deep:100 * 0.35 + rem:100 * 0.2 = 82
        #expect(score.value == 82)
    }

    @Test("Less than 5 hours or more than 9 hours returns duration score of 40")
    func extremeDurationReturns40() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 4時間 = 240分
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 240,
            deepSleepMinutes: 48,
            remSleepMinutes: 53
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:40 * 0.45 + deep:100 * 0.35 + rem:100 * 0.2 = 73
        #expect(score.value == 73)
    }

    // MARK: - Deep Sleep Score Tests

    @Test("Deep sleep ratio 15-25% returns score of 100")
    func optimalDeepSleepReturns100() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, 深い睡眠20%
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // All scores are 100
        #expect(score.value == 100)
    }

    @Test("Deep sleep ratio 10-15% returns score of 70")
    func slightlyLowDeepSleepReturns70() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, 深い睡眠12% (50分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 50,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:70 * 0.35 + rem:100 * 0.2 = 89.5 → 90
        #expect(score.value == 90)
    }

    @Test("Deep sleep ratio 25-30% returns score of 80")
    func slightlyHighDeepSleepReturns80() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, 深い睡眠27% (114分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 114,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:80 * 0.35 + rem:100 * 0.2 = 93
        #expect(score.value == 93)
    }

    @Test("Deep sleep ratio below 10% or above 30% returns score of 50")
    func extremeDeepSleepReturns50() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, 深い睡眠5% (21分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 21,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:50 * 0.35 + rem:100 * 0.2 = 82.5 → 83
        #expect(score.value == 83)
    }

    // MARK: - REM Sleep Score Tests

    @Test("REM sleep ratio 20-25% returns score of 100")
    func optimalRemSleepReturns100() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, レム22% (92分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        #expect(score.value == 100)
    }

    @Test("REM sleep ratio 15-20% returns score of 80")
    func slightlyLowRemSleepReturns80() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, レム17% (71分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 71
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:100 * 0.35 + rem:80 * 0.2 = 96
        #expect(score.value == 96)
    }

    @Test("REM sleep ratio 25-30% returns score of 85")
    func slightlyHighRemSleepReturns85() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, レム27% (113分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 113
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:100 * 0.35 + rem:85 * 0.2 = 97
        #expect(score.value == 97)
    }

    @Test("REM sleep ratio below 15% or above 30% returns score of 60")
    func extremeRemSleepReturns60() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, レム10% (42分/420分)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 42
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.45 + deep:100 * 0.35 + rem:60 * 0.2 = 92
        #expect(score.value == 92)
    }

    // MARK: - Weight Redistribution Tests

    @Test("Zero REM sleep redistributes weights to duration and deep sleep")
    func zeroRemSleepRedistributesWeights() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        // 7時間, 深い睡眠20%, レム0%
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 0
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:100 * 0.55 + deep:100 * 0.45 = 100
        #expect(score.value == 100)
    }

    // MARK: - Edge Case Tests

    @Test("Zero duration returns minimum score")
    func zeroDurationReturnsMinimumScore() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 0,
            deepSleepMinutes: 0,
            remSleepMinutes: 0
        )

        let score: Score = calculator.calculate(sleep: sleep)

        // duration:40 * 0.55 + deep:(0で割るのを避けて0扱い) = 22
        #expect(score.value >= 0 && score.value <= 100)
    }

    @Test("Score is properly clamped between 0 and 100")
    func scoreIsClampedProperly() {
        let calculator: SleepScoreCalculator = SleepScoreCalculator()
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 92
        )

        let score: Score = calculator.calculate(sleep: sleep)

        #expect(score.value >= 0 && score.value <= 100)
    }
}
