//
//  AutonomicScoreCalculatorTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct AutonomicScoreCalculatorTests {

    // MARK: - Test Helpers

    private func makeHRVMetrics(value: Double, baseline: Double) -> HRVMetrics {
        HRVMetrics(value: value, baseline30d: baseline)
    }

    private func makeSleepMetrics(
        durationMinutes: Int = 420,
        deepSleepMinutes: Int = 90,
        remSleepMinutes: Int = 100
    ) -> SleepMetrics {
        SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: durationMinutes,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes
        )
    }

    // MARK: - Basic Score Calculation Tests

    @Test("HRV equal to baseline returns 70 points")
    func hrvEqualToBaselineReturns70() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 70)
    }

    @Test("HRV at 130% of baseline returns 100 points")
    func hrv130PercentOfBaselineReturns100() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 65, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 100)
    }

    @Test("HRV at 70% of baseline returns 40 points")
    func hrv70PercentOfBaselineReturns40() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 35, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 40)
    }

    @Test("HRV at 150% of baseline is clamped to 100")
    func hrvExtremeHighIsClamped() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 75, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 100)
    }

    @Test("HRV at 30% of baseline is clamped to 0")
    func hrvExtremeLowIsClamped() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 15, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 0)
    }

    // MARK: - Adjustment Tests

    @Test("Deep sleep deficiency applies -5 adjustment")
    func deepSleepDeficiencyAppliesAdjustment() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 50)
        // 深い睡眠 10% (< 15%)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 42,
            remSleepMinutes: 100
        )

        let score: Score = calculator.calculate(hrv: hrv, sleep: sleep)

        #expect(score.value == 65)  // 70 - 5
    }

    @Test("Sleep duration deficiency applies -5 adjustment")
    func sleepDurationDeficiencyAppliesAdjustment() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 50)
        // 睡眠時間 5時間 (< 6時間)
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 300,
            deepSleepMinutes: 60,
            remSleepMinutes: 60
        )

        let score: Score = calculator.calculate(hrv: hrv, sleep: sleep)

        #expect(score.value == 65)  // 70 - 5
    }

    @Test("Multiple adjustments stack")
    func multipleAdjustmentsStack() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 50)
        // 深い睡眠 10% + 睡眠時間 5時間
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 300,
            deepSleepMinutes: 30,
            remSleepMinutes: 60
        )

        let score: Score = calculator.calculate(hrv: hrv, sleep: sleep)

        #expect(score.value == 60)  // 70 - 5 - 5
    }

    @Test("No adjustment when sleep is sufficient")
    func noAdjustmentWhenSleepIsSufficient() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 50)
        // 深い睡眠 20% + 睡眠時間 7時間
        let sleep: SleepMetrics = makeSleepMetrics(
            durationMinutes: 420,
            deepSleepMinutes: 84,
            remSleepMinutes: 100
        )

        let score: Score = calculator.calculate(hrv: hrv, sleep: sleep)

        #expect(score.value == 70)
    }

    // MARK: - Edge Case Tests

    @Test("Zero baseline uses industry average of 50ms")
    func zeroBaselineUsesIndustryAverage() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: 0)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 70)
    }

    @Test("Negative baseline uses industry average of 50ms")
    func negativeBaselineUsesIndustryAverage() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 50, baseline: -10)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 70)
    }

    @Test("Nil sleep does not affect base score")
    func nilSleepDoesNotAffectBaseScore() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        let hrv: HRVMetrics = makeHRVMetrics(value: 60, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 90)  // 70 + 20 (20% above baseline)
    }

    @Test("Score correctly rounds to integer")
    func scoreCorrectlyRoundsToInteger() {
        let calculator: AutonomicScoreCalculator = AutonomicScoreCalculator()
        // 55 / 50 = 1.10 → deviation = 10 → 70 + 10 = 80
        let hrv: HRVMetrics = makeHRVMetrics(value: 55, baseline: 50)

        let score: Score = calculator.calculate(hrv: hrv, sleep: nil)

        #expect(score.value == 80)
    }
}
