//
//  ActivityScoreCalculatorTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct ActivityScoreCalculatorTests {

    // MARK: - Test Helpers

    private func makeActivityMetrics(
        steps: Int,
        activeMinutes: Int
    ) -> ActivityMetrics {
        ActivityMetrics(
            stepsYesterday: steps,
            activeMinutesYesterday: activeMinutes
        )
    }

    // MARK: - Step Score Tests

    @Test("8000 or more steps returns step score of 100")
    func targetStepsReturns100() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:100 * 0.4 = 100
        #expect(score.value == 100)
    }

    @Test("10000 steps returns step score of 100 (capped)")
    func overTargetStepsReturns100() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 10000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        #expect(score.value == 100)
    }

    @Test("6000 steps (75%) returns step score of 80")
    func seventyFivePercentStepsReturns80() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 6000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps:80 * 0.6 + exercise:100 * 0.4 = 88
        #expect(score.value == 88)
    }

    @Test("4000 steps (50%) returns step score of 60")
    func fiftyPercentStepsReturns60() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 4000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps:60 * 0.6 + exercise:100 * 0.4 = 76
        #expect(score.value == 76)
    }

    @Test("2000 steps (25%) returns step score of 30")
    func twentyFivePercentStepsReturns30() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 2000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps: 2000/8000 * 120 = 30
        // 30 * 0.6 + exercise:100 * 0.4 = 58
        #expect(score.value == 58)
    }

    @Test("0 steps returns step score of 0")
    func zeroStepsReturns0() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 0, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps:0 * 0.6 + exercise:100 * 0.4 = 40
        #expect(score.value == 40)
    }

    // MARK: - Exercise Score Tests

    @Test("30 or more minutes of exercise returns score of 100")
    func targetExerciseReturns100() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        #expect(score.value == 100)
    }

    @Test("20-29 minutes of exercise returns score of 80")
    func twentyMinutesExerciseReturns80() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 25)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:80 * 0.4 = 92
        #expect(score.value == 92)
    }

    @Test("10-19 minutes of exercise returns score of 60")
    func tenMinutesExerciseReturns60() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 15)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:60 * 0.4 = 84
        #expect(score.value == 84)
    }

    @Test("5-9 minutes of exercise returns score of 40")
    func fiveMinutesExerciseReturns40() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 7)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:40 * 0.4 = 76
        #expect(score.value == 76)
    }

    @Test("Less than 5 minutes of exercise returns score of 20")
    func lessThanFiveMinutesExerciseReturns20() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 3)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:20 * 0.4 = 68
        #expect(score.value == 68)
    }

    // MARK: - Combined Score Tests

    @Test("Low steps and low exercise returns low combined score")
    func lowStepsAndExerciseReturnsLowScore() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 2000, activeMinutes: 5)

        let score: Score = calculator.calculate(activity: activity)

        // steps:30 * 0.6 + exercise:40 * 0.4 = 34
        #expect(score.value == 34)
    }

    @Test("High steps and low exercise returns moderate score")
    func highStepsLowExerciseReturnsModerateScore() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 8000, activeMinutes: 3)

        let score: Score = calculator.calculate(activity: activity)

        // steps:100 * 0.6 + exercise:20 * 0.4 = 68
        #expect(score.value == 68)
    }

    @Test("Low steps and high exercise returns moderate score")
    func lowStepsHighExerciseReturnsModerateScore() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 2000, activeMinutes: 30)

        let score: Score = calculator.calculate(activity: activity)

        // steps:30 * 0.6 + exercise:100 * 0.4 = 58
        #expect(score.value == 58)
    }

    // MARK: - Edge Case Tests

    @Test("Zero activity returns minimum score")
    func zeroActivityReturnsMinimumScore() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 0, activeMinutes: 0)

        let score: Score = calculator.calculate(activity: activity)

        // steps:0 * 0.6 + exercise:20 * 0.4 = 8
        #expect(score.value == 8)
    }

    @Test("Score is properly clamped between 0 and 100")
    func scoreIsClampedProperly() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()
        let activity: ActivityMetrics = makeActivityMetrics(steps: 20000, activeMinutes: 120)

        let score: Score = calculator.calculate(activity: activity)

        #expect(score.value >= 0 && score.value <= 100)
    }

    @Test("Step ratio calculation is accurate at boundaries")
    func stepRatioCalculationIsAccurate() {
        let calculator: ActivityScoreCalculator = ActivityScoreCalculator()

        // 75% boundary
        let activity75: ActivityMetrics = makeActivityMetrics(steps: 6000, activeMinutes: 30)
        let score75: Score = calculator.calculate(activity: activity75)

        // 50% boundary
        let activity50: ActivityMetrics = makeActivityMetrics(steps: 4000, activeMinutes: 30)
        let score50: Score = calculator.calculate(activity: activity50)

        #expect(score75.value > score50.value)
    }
}
