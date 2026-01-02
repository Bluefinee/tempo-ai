//
//  RhythmAnalysisTests.swift
//  TempoAITests
//

import Testing
@testable import TempoAI

struct RhythmAnalysisTests {

    // MARK: - Status Tests

    @Test("RhythmAnalysis returns stable status for 5+ consecutive days")
    func rhythmStatusStable() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(analysis.status == .stable)

        let analysis7: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 7,
            wristTemperature: nil
        )
        #expect(analysis7.status == .stable)
    }

    @Test("RhythmAnalysis returns recovering status for 3-4 consecutive days")
    func rhythmStatusRecovering() {
        let analysis3: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 3,
            wristTemperature: nil
        )
        #expect(analysis3.status == .recovering)

        let analysis4: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 4,
            wristTemperature: nil
        )
        #expect(analysis4.status == .recovering)
    }

    @Test("RhythmAnalysis returns unstable status for less than 3 consecutive days")
    func rhythmStatusUnstable() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 25,
            consecutiveStableDays: 2,
            wristTemperature: nil
        )
        #expect(analysis.status == .unstable)

        let analysis0: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 40,
            wakeTimeStddevMinutes: 50,
            consecutiveStableDays: 0,
            wristTemperature: nil
        )
        #expect(analysis0.status == .unstable)
    }

    // MARK: - isStable Tests

    @Test("RhythmAnalysis isStable when both stddev under 30 minutes")
    func rhythmIsStableWhenBothUnder30() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 25,
            wakeTimeStddevMinutes: 28,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(analysis.isStable == true)
    }

    @Test("RhythmAnalysis is not stable when bedtime stddev over 30")
    func rhythmNotStableWhenBedtimeOver30() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 35,
            wakeTimeStddevMinutes: 20,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(analysis.isStable == false)
    }

    @Test("RhythmAnalysis is not stable when wakeTime stddev over 30")
    func rhythmNotStableWhenWakeTimeOver30() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 20,
            wakeTimeStddevMinutes: 40,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(analysis.isStable == false)
    }

    // MARK: - Consistency Score Tests

    @Test("RhythmAnalysis calculates consistency score correctly")
    func rhythmConsistencyScores() {
        let veryStable: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 10,
            wakeTimeStddevMinutes: 12,
            consecutiveStableDays: 7,
            wristTemperature: nil
        )
        #expect(veryStable.bedtimeConsistencyScore == 100)
        #expect(veryStable.wakeTimeConsistencyScore == 100)

        let moderate: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 25,
            wakeTimeStddevMinutes: 35,
            consecutiveStableDays: 4,
            wristTemperature: nil
        )
        #expect(moderate.bedtimeConsistencyScore == 85)
        #expect(moderate.wakeTimeConsistencyScore == 70)

        let unstable: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 100,
            wakeTimeStddevMinutes: 95,
            consecutiveStableDays: 0,
            wristTemperature: nil
        )
        #expect(unstable.bedtimeConsistencyScore == 25)
        #expect(unstable.wakeTimeConsistencyScore == 25)
    }

    // MARK: - Consistency Status Tests

    @Test("RhythmAnalysis returns stable consistency status for stddev <= 30")
    func consistencyStatusStable() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 25,
            wakeTimeStddevMinutes: 30,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(analysis.bedtimeConsistencyStatus == .stable)
        #expect(analysis.wakeTimeConsistencyStatus == .stable)
    }

    @Test("RhythmAnalysis returns recovering consistency status for stddev 30-45")
    func consistencyStatusRecovering() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 35,
            wakeTimeStddevMinutes: 40,
            consecutiveStableDays: 3,
            wristTemperature: nil
        )
        #expect(analysis.bedtimeConsistencyStatus == .recovering)
        #expect(analysis.wakeTimeConsistencyStatus == .recovering)
    }

    @Test("RhythmAnalysis returns unstable consistency status for stddev > 45")
    func consistencyStatusUnstable() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 50,
            wakeTimeStddevMinutes: 60,
            consecutiveStableDays: 1,
            wristTemperature: nil
        )
        #expect(analysis.bedtimeConsistencyStatus == .unstable)
        #expect(analysis.wakeTimeConsistencyStatus == .unstable)
    }

    @Test("RhythmAnalysis consistency status handles boundary values correctly")
    func consistencyStatusBoundary() {
        let atBoundary30: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 30,
            wakeTimeStddevMinutes: 30,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )
        #expect(atBoundary30.bedtimeConsistencyStatus == .stable)
        #expect(atBoundary30.wakeTimeConsistencyStatus == .stable)

        let atBoundary45: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 44.9,
            wakeTimeStddevMinutes: 45,
            consecutiveStableDays: 3,
            wristTemperature: nil
        )
        #expect(atBoundary45.bedtimeConsistencyStatus == .recovering)
        #expect(atBoundary45.wakeTimeConsistencyStatus == .unstable)
    }
}
