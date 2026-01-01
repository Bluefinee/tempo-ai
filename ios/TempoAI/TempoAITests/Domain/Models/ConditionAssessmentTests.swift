//
//  ConditionAssessmentTests.swift
//  TempoAITests
//

import Testing
@testable import TempoAI

struct ConditionAssessmentTests {

    // MARK: - Helper

    private func makeRhythmAnalysis() -> RhythmAnalysis {
        RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
    }

    // MARK: - Weakest Area Tests

    @Test("ConditionAssessment returns weakest area correctly")
    func weakestAreaReturnsLowestScore() {
        let assessment: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(70),
            autonomicScore: Score(80),
            rhythmScore: Score(65),
            activityScore: Score(50),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(assessment.weakestArea == .activity)
    }

    @Test("ConditionAssessment returns sleep when it's the weakest")
    func weakestAreaReturnsSleepWhenLowest() {
        let assessment: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(40),
            autonomicScore: Score(80),
            rhythmScore: Score(65),
            activityScore: Score(70),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(assessment.weakestArea == .sleep)
    }

    @Test("ConditionAssessment returns first area on tie")
    func weakestAreaTieBreaker() {
        let assessment: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(50),
            autonomicScore: Score(50),
            rhythmScore: Score(50),
            activityScore: Score(50),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(assessment.weakestArea == .sleep)
    }

    // MARK: - Average Score Tests

    @Test("ConditionAssessment calculates average score correctly")
    func averageScoreCalculation() {
        let assessment: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(80),
            autonomicScore: Score(70),
            rhythmScore: Score(60),
            activityScore: Score(50),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(assessment.averageScore == 65)
    }

    // MARK: - Overall Status Tests

    @Test("ConditionAssessment returns correct overall status")
    func overallStatusCorrect() {
        let excellent: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(85),
            autonomicScore: Score(90),
            rhythmScore: Score(80),
            activityScore: Score(85),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(excellent.overallStatus == .excellent)

        let good: ConditionAssessment = ConditionAssessment(
            sleepScore: Score(70),
            autonomicScore: Score(75),
            rhythmScore: Score(65),
            activityScore: Score(70),
            rhythmAnalysis: makeRhythmAnalysis()
        )
        #expect(good.overallStatus == .good)
    }

    // MARK: - Area Tests

    @Test("Area has correct improvement hints")
    func areaImprovementHints() {
        #expect(ConditionAssessment.Area.sleep.improvementHint.contains("睡眠"))
        #expect(ConditionAssessment.Area.autonomic.improvementHint.contains("休憩"))
        #expect(ConditionAssessment.Area.rhythm.improvementHint.contains("リズム"))
        #expect(ConditionAssessment.Area.activity.improvementHint.contains("体を動かす"))
    }
}
