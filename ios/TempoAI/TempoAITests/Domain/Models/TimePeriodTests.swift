//
//  TimePeriodTests.swift
//  TempoAITests
//

import Testing
@testable import TempoAI

struct TimePeriodTests {

    // MARK: - Days Tests

    @Test("Weekly returns 7 days")
    func weeklyReturnsSevenDays() {
        #expect(TimePeriod.weekly.days == 7)
    }

    @Test("Monthly returns 30 days")
    func monthlyReturnsThirtyDays() {
        #expect(TimePeriod.monthly.days == 30)
    }

    // MARK: - Display Name Tests

    @Test("Weekly displayName returns 週間")
    func weeklyDisplayName() {
        #expect(TimePeriod.weekly.displayName == "週間")
    }

    @Test("Monthly displayName returns 月間")
    func monthlyDisplayName() {
        #expect(TimePeriod.monthly.displayName == "月間")
    }

    // MARK: - RawValue Tests

    @Test("TimePeriod rawValue matches displayName")
    func rawValueMatchesDisplayName() {
        #expect(TimePeriod.weekly.rawValue == "週間")
        #expect(TimePeriod.monthly.rawValue == "月間")
    }

    // MARK: - CaseIterable Tests

    @Test("TimePeriod has exactly 2 cases")
    func hasExactlyTwoCases() {
        #expect(TimePeriod.allCases.count == 2)
        #expect(TimePeriod.allCases.contains(.weekly))
        #expect(TimePeriod.allCases.contains(.monthly))
    }
}
