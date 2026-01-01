//
//  HealthMetricsTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct HealthMetricsTests {

    // MARK: - SleepMetrics Tests

    @Test("SleepMetrics calculates duration hours correctly")
    func sleepMetricsDurationHoursCalculation() {
        let sleep: SleepMetrics = SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: 450,
            deepSleepMinutes: 90,
            remSleepMinutes: 100
        )
        #expect(sleep.durationHours == 7.5)
    }

    @Test("SleepMetrics calculates deep sleep ratio correctly")
    func sleepMetricsDeepSleepRatioCalculation() {
        let sleep: SleepMetrics = SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: 450,
            deepSleepMinutes: 90,
            remSleepMinutes: 100
        )
        #expect(sleep.deepSleepRatio == 0.2)
    }

    @Test("SleepMetrics handles zero duration safely")
    func sleepMetricsZeroDurationSafe() {
        let sleep: SleepMetrics = SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: 0,
            deepSleepMinutes: 0,
            remSleepMinutes: 0
        )
        #expect(sleep.durationHours == 0)
        #expect(sleep.deepSleepRatio == 0)
        #expect(sleep.remSleepRatio == 0)
        #expect(sleep.lightSleepRatio == 0)
    }

    @Test("SleepMetrics calculates light sleep correctly")
    func sleepMetricsLightSleepCalculation() {
        let sleep: SleepMetrics = SleepMetrics(
            bedtime: Date(),
            wakeTime: Date(),
            durationMinutes: 450,
            deepSleepMinutes: 90,
            remSleepMinutes: 100
        )
        #expect(sleep.lightSleepMinutes == 260)
    }

    // MARK: - HRVMetrics Tests

    @Test("HRVMetrics calculates deviation percent correctly")
    func hrvMetricsDeviationPercentCalculation() {
        let hrv: HRVMetrics = HRVMetrics(value: 60, baseline30d: 50)
        #expect(hrv.deviationPercent == 20.0)
    }

    @Test("HRVMetrics handles zero baseline safely")
    func hrvMetricsZeroBaselineSafe() {
        let hrv: HRVMetrics = HRVMetrics(value: 60, baseline30d: 0)
        #expect(hrv.deviationPercent == 0)
    }

    @Test("HRVMetrics returns correct status for elevated HRV")
    func hrvMetricsElevatedStatus() {
        let hrv: HRVMetrics = HRVMetrics(value: 60, baseline30d: 50)
        #expect(hrv.status == .elevated)
    }

    @Test("HRVMetrics returns correct status for normal HRV")
    func hrvMetricsNormalStatus() {
        let hrv: HRVMetrics = HRVMetrics(value: 52, baseline30d: 50)
        #expect(hrv.status == .normal)
    }

    @Test("HRVMetrics returns correct status for low HRV")
    func hrvMetricsLowStatus() {
        let hrv: HRVMetrics = HRVMetrics(value: 35, baseline30d: 50)
        #expect(hrv.status == .low)
    }

    // MARK: - DaylightMetrics Tests

    @Test("DaylightMetrics returns sufficient status for 45+ minutes")
    func daylightStatusSufficient() {
        #expect(DaylightMetrics(minutesYesterday: 45).status == .sufficient)
        #expect(DaylightMetrics(minutesYesterday: 60).status == .sufficient)
    }

    @Test("DaylightMetrics returns slightlyInsufficient status for 30-44 minutes")
    func daylightStatusSlightlyInsufficient() {
        #expect(DaylightMetrics(minutesYesterday: 30).status == .slightlyInsufficient)
        #expect(DaylightMetrics(minutesYesterday: 44).status == .slightlyInsufficient)
    }

    @Test("DaylightMetrics returns insufficient status for under 30 minutes")
    func daylightStatusInsufficient() {
        #expect(DaylightMetrics(minutesYesterday: 29).status == .insufficient)
        #expect(DaylightMetrics(minutesYesterday: 0).status == .insufficient)
    }

    // MARK: - WristTemperatureMetrics Tests

    @Test("WristTemperature returns stable status for deviation under 0.2")
    func temperatureStatusStable() {
        #expect(WristTemperatureMetrics(deviation: 0.1).status == .stable)
        #expect(WristTemperatureMetrics(deviation: -0.1).status == .stable)
        #expect(WristTemperatureMetrics(deviation: 0.19).status == .stable)
    }

    @Test("WristTemperature returns slightlyVariable status for 0.2-0.5")
    func temperatureStatusSlightlyVariable() {
        #expect(WristTemperatureMetrics(deviation: 0.2).status == .slightlyVariable)
        #expect(WristTemperatureMetrics(deviation: 0.4).status == .slightlyVariable)
        #expect(WristTemperatureMetrics(deviation: -0.3).status == .slightlyVariable)
    }

    @Test("WristTemperature returns variable status for 0.5+")
    func temperatureStatusVariable() {
        #expect(WristTemperatureMetrics(deviation: 0.5).status == .variable)
        #expect(WristTemperatureMetrics(deviation: 0.8).status == .variable)
        #expect(WristTemperatureMetrics(deviation: -0.6).status == .variable)
    }

    // MARK: - ActivityMetrics Tests

    @Test("ActivityMetrics calculates step achievement rate correctly")
    func activityMetricsStepAchievementRate() {
        let activity: ActivityMetrics = ActivityMetrics(stepsYesterday: 8000, activeMinutesYesterday: 30)
        #expect(activity.stepAchievementRate() == 1.0)
        #expect(activity.stepAchievementRate(target: 10000) == 0.8)
    }
}
