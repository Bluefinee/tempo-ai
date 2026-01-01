//
//  ScoreCalculatorTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct ScoreCalculatorTests {

    // MARK: - Test Helpers

    private func makeHealthMetrics(
        sleep: SleepMetrics? = nil,
        hrv: HRVMetrics? = nil,
        activity: ActivityMetrics? = nil
    ) -> HealthMetrics {
        HealthMetrics(
            date: Date(),
            sleep: sleep,
            hrv: hrv,
            activity: activity,
            auxiliary: nil
        )
    }

    private func makeSleepMetrics(
        durationMinutes: Int = 420,
        deepSleepMinutes: Int = 84,
        remSleepMinutes: Int = 92
    ) -> SleepMetrics {
        SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: durationMinutes,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes
        )
    }

    private func makeHRVMetrics(value: Double = 50, baseline: Double = 50) -> HRVMetrics {
        HRVMetrics(value: value, baseline30d: baseline)
    }

    private func makeActivityMetrics(steps: Int = 8000, activeMinutes: Int = 30) -> ActivityMetrics {
        ActivityMetrics(stepsYesterday: steps, activeMinutesYesterday: activeMinutes)
    }

    private func makeRhythmAnalysis(
        bedtimeStddev: Double = 15,
        wakeTimeStddev: Double = 15
    ) -> RhythmAnalysis {
        RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
    }

    // MARK: - Complete Data Tests

    @Test("All data available returns complete ConditionAssessment")
    func allDataAvailableReturnsCompleteAssessment() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(),
            hrv: makeHRVMetrics(),
            activity: makeActivityMetrics()
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.sleepScore.value > 0)
        #expect(assessment.autonomicScore.value > 0)
        #expect(assessment.rhythmScore.value > 0)
        #expect(assessment.activityScore.value > 0)
    }

    @Test("Optimal data returns high scores")
    func optimalDataReturnsHighScores() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(
                durationMinutes: 450,  // 7.5 hours
                deepSleepMinutes: 90,  // 20%
                remSleepMinutes: 99    // 22%
            ),
            hrv: makeHRVMetrics(value: 65, baseline: 50),  // 130% of baseline
            activity: makeActivityMetrics(steps: 10000, activeMinutes: 45)
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis(
            bedtimeStddev: 10,
            wakeTimeStddev: 12
        )

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.sleepScore.value >= 90)
        #expect(assessment.autonomicScore.value >= 90)
        #expect(assessment.rhythmScore.value >= 90)
        #expect(assessment.activityScore.value == 100)
    }

    // MARK: - Partial Data Tests

    @Test("Missing sleep data returns default sleep score")
    func missingSleepDataReturnsDefaultScore() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: nil,
            hrv: makeHRVMetrics(),
            activity: makeActivityMetrics()
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.sleepScore.value == ScoreCalculator.defaultScore)
    }

    @Test("Missing HRV data returns default autonomic score")
    func missingHRVDataReturnsDefaultScore() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(),
            hrv: nil,
            activity: makeActivityMetrics()
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.autonomicScore.value == ScoreCalculator.defaultScore)
    }

    @Test("Missing activity data returns default activity score")
    func missingActivityDataReturnsDefaultScore() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(),
            hrv: makeHRVMetrics(),
            activity: nil
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.activityScore.value == ScoreCalculator.defaultScore)
    }

    // MARK: - Edge Case Tests

    @Test("All data missing returns all default scores")
    func allDataMissingReturnsAllDefaultScores() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: nil,
            hrv: nil,
            activity: nil
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.sleepScore.value == ScoreCalculator.defaultScore)
        #expect(assessment.autonomicScore.value == ScoreCalculator.defaultScore)
        #expect(assessment.activityScore.value == ScoreCalculator.defaultScore)
        // Rhythm score is always calculated from RhythmAnalysis
        #expect(assessment.rhythmScore.value > 0)
    }

    @Test("Rhythm analysis is always included in assessment")
    func rhythmAnalysisAlwaysIncluded() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics()
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.rhythmAnalysis.bedtimeStddevMinutes == rhythmAnalysis.bedtimeStddevMinutes)
        #expect(assessment.rhythmAnalysis.wakeTimeStddevMinutes == rhythmAnalysis.wakeTimeStddevMinutes)
    }

    // MARK: - Weakest Area Tests

    @Test("Weakest area is correctly identified")
    func weakestAreaIsCorrectlyIdentified() {
        let calculator: ScoreCalculator = ScoreCalculator()
        // Low activity score
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(),
            hrv: makeHRVMetrics(),
            activity: makeActivityMetrics(steps: 1000, activeMinutes: 5)
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        #expect(assessment.weakestArea == .activity)
    }

    @Test("Average score is calculated correctly")
    func averageScoreIsCalculatedCorrectly() {
        let calculator: ScoreCalculator = ScoreCalculator()
        let metrics: HealthMetrics = makeHealthMetrics(
            sleep: makeSleepMetrics(),
            hrv: makeHRVMetrics(),
            activity: makeActivityMetrics()
        )
        let rhythmAnalysis: RhythmAnalysis = makeRhythmAnalysis()

        let assessment: ConditionAssessment = calculator.calculateAll(
            healthMetrics: metrics,
            rhythmAnalysis: rhythmAnalysis
        )

        let expectedAverage: Int = (
            assessment.sleepScore.value
            + assessment.autonomicScore.value
            + assessment.rhythmScore.value
            + assessment.activityScore.value
        ) / 4

        #expect(assessment.averageScore == expectedAverage)
    }
}
