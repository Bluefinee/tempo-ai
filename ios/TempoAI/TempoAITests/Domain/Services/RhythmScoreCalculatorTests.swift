//
//  RhythmScoreCalculatorTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct RhythmScoreCalculatorTests {

    // MARK: - Test Helpers

    private func makeRhythmAnalysis(
        bedtimeStddev: Double,
        wakeTimeStddev: Double,
        consecutiveStableDays: Int = 3,
        wristTemperature: WristTemperatureMetrics? = nil
    ) -> RhythmAnalysis {
        RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: consecutiveStableDays,
            wristTemperature: wristTemperature
        )
    }

    private func makeWristTemperature(deviation: Double) -> WristTemperatureMetrics {
        WristTemperatureMetrics(deviation: deviation)
    }

    // MARK: - Consistency Score Tests

    @Test("Very stable rhythm (stddev <= 15 min) returns consistency score of 100")
    func veryStableRhythmReturns100() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 10,
            wakeTimeStddev: 12
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.45 + waketime:100 * 0.45 + stage:70 * 0.10 = 97
        #expect(score.value == 97)
    }

    @Test("Stable rhythm (stddev 15-30 min) returns consistency score of 85")
    func stableRhythmReturns85() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 20,
            wakeTimeStddev: 25
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:85 * 0.45 + waketime:85 * 0.45 + stage:70 * 0.10 = 83.5 → 84
        #expect(score.value == 84)
    }

    @Test("Slightly stable rhythm (stddev 30-45 min) returns consistency score of 70")
    func slightlyStableRhythmReturns70() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 35,
            wakeTimeStddev: 40
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:70 * 0.45 + waketime:70 * 0.45 + stage:70 * 0.10 = 70
        #expect(score.value == 70)
    }

    @Test("Slightly unstable rhythm (stddev 45-60 min) returns consistency score of 55")
    func slightlyUnstableRhythmReturns55() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 50,
            wakeTimeStddev: 55
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:55 * 0.45 + waketime:55 * 0.45 + stage:70 * 0.10 = 56.5 → 57
        #expect(score.value == 57)
    }

    @Test("Unstable rhythm (stddev 60-90 min) returns consistency score of 40")
    func unstableRhythmReturns40() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 70,
            wakeTimeStddev: 80
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:40 * 0.45 + waketime:40 * 0.45 + stage:70 * 0.10 = 43
        #expect(score.value == 43)
    }

    @Test("Very unstable rhythm (stddev > 90 min) returns consistency score of 25")
    func veryUnstableRhythmReturns25() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 100,
            wakeTimeStddev: 120
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:25 * 0.45 + waketime:25 * 0.45 + stage:70 * 0.10 = 29.5 → 30
        #expect(score.value == 30)
    }

    // MARK: - With Wrist Temperature Tests

    @Test("Stable temperature returns temperature score of 100")
    func stableTemperatureReturns100() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 15,
            wristTemperature: makeWristTemperature(deviation: 0.1)
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.35 + waketime:100 * 0.35 + temp:100 * 0.20 + stage:70 * 0.10 = 97
        #expect(score.value == 97)
    }

    @Test("Slightly variable temperature returns temperature score of 70")
    func slightlyVariableTemperatureReturns70() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 15,
            wristTemperature: makeWristTemperature(deviation: 0.3)
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.35 + waketime:100 * 0.35 + temp:70 * 0.20 + stage:70 * 0.10 = 91
        #expect(score.value == 91)
    }

    @Test("Variable temperature returns temperature score of 40")
    func variableTemperatureReturns40() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 15,
            wristTemperature: makeWristTemperature(deviation: 0.6)
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.35 + waketime:100 * 0.35 + temp:40 * 0.20 + stage:70 * 0.10 = 85
        #expect(score.value == 85)
    }

    // MARK: - Weight Redistribution Tests

    @Test("Without wrist temperature, weights are redistributed")
    func withoutWristTemperatureWeightsRedistributed() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysisWithTemp: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 15,
            wristTemperature: makeWristTemperature(deviation: 0.1)
        )
        let analysisWithoutTemp: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 15,
            wristTemperature: nil
        )

        let scoreWithTemp: Score = calculator.calculate(analysis: analysisWithTemp)
        let scoreWithoutTemp: Score = calculator.calculate(analysis: analysisWithoutTemp)

        // Both should be valid scores
        #expect(scoreWithTemp.value >= 0 && scoreWithTemp.value <= 100)
        #expect(scoreWithoutTemp.value >= 0 && scoreWithoutTemp.value <= 100)
    }

    // MARK: - Edge Case Tests

    @Test("Mixed stability returns appropriate weighted score")
    func mixedStabilityReturnsWeightedScore() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        // Stable bedtime, unstable wake time
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 15,
            wakeTimeStddev: 70
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.45 + waketime:40 * 0.45 + stage:70 * 0.10 = 70
        #expect(score.value == 70)
    }

    @Test("Zero standard deviation returns maximum consistency score")
    func zeroStddevReturnsMaxScore() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 0,
            wakeTimeStddev: 0
        )

        let score: Score = calculator.calculate(analysis: analysis)

        // bedtime:100 * 0.45 + waketime:100 * 0.45 + stage:70 * 0.10 = 97
        #expect(score.value == 97)
    }

    @Test("Score is properly clamped between 0 and 100")
    func scoreIsClampedProperly() {
        let calculator: RhythmScoreCalculator = RhythmScoreCalculator()
        let analysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 200,
            wakeTimeStddev: 200
        )

        let score: Score = calculator.calculate(analysis: analysis)

        #expect(score.value >= 0 && score.value <= 100)
    }
}
