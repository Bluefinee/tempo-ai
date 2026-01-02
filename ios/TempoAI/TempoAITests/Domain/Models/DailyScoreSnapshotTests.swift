//
//  DailyScoreSnapshotTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

struct DailyScoreSnapshotTests {

    // MARK: - Initialization Tests

    @Test("DailyScoreSnapshot initializes with valid values")
    func initializesWithValidValues() {
        let date: Date = Date()
        let snapshot: DailyScoreSnapshot = DailyScoreSnapshot(
            date: date,
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )

        #expect(snapshot.autonomicScore == 80)
        #expect(snapshot.sleepScore == 75)
        #expect(snapshot.rhythmScore == 70)
        #expect(snapshot.activityScore == 65)
    }

    // MARK: - Clamping Tests

    @Test("DailyScoreSnapshot clamps values above 100")
    func clampsValuesAbove100() {
        let snapshot: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 150,
            sleepScore: 200,
            rhythmScore: 110,
            activityScore: 999
        )

        #expect(snapshot.autonomicScore == 100)
        #expect(snapshot.sleepScore == 100)
        #expect(snapshot.rhythmScore == 100)
        #expect(snapshot.activityScore == 100)
    }

    @Test("DailyScoreSnapshot clamps negative values to 0")
    func clampsNegativeValues() {
        let snapshot: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: -10,
            sleepScore: -50,
            rhythmScore: -1,
            activityScore: -100
        )

        #expect(snapshot.autonomicScore == 0)
        #expect(snapshot.sleepScore == 0)
        #expect(snapshot.rhythmScore == 0)
        #expect(snapshot.activityScore == 0)
    }

    @Test("DailyScoreSnapshot preserves boundary values")
    func preservesBoundaryValues() {
        let snapshotZero: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 0,
            sleepScore: 0,
            rhythmScore: 0,
            activityScore: 0
        )
        #expect(snapshotZero.autonomicScore == 0)
        #expect(snapshotZero.sleepScore == 0)

        let snapshot100: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 100,
            sleepScore: 100,
            rhythmScore: 100,
            activityScore: 100
        )
        #expect(snapshot100.autonomicScore == 100)
        #expect(snapshot100.sleepScore == 100)
    }

    // MARK: - Equatable Tests

    @Test("DailyScoreSnapshot with same values are equal")
    func snapshotsWithSameValuesAreEqual() {
        let date: Date = Date()
        let id: UUID = UUID()
        let snapshot1: DailyScoreSnapshot = DailyScoreSnapshot(
            id: id,
            date: date,
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )
        let snapshot2: DailyScoreSnapshot = DailyScoreSnapshot(
            id: id,
            date: date,
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )

        #expect(snapshot1 == snapshot2)
    }

    @Test("DailyScoreSnapshot with different values are not equal")
    func snapshotsWithDifferentValuesAreNotEqual() {
        let snapshot1: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )
        let snapshot2: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 60
        )

        #expect(snapshot1 != snapshot2)
    }

    // MARK: - Identifiable Tests

    @Test("DailyScoreSnapshot generates unique IDs")
    func generatesUniqueIds() {
        let snapshot1: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )
        let snapshot2: DailyScoreSnapshot = DailyScoreSnapshot(
            date: Date(),
            autonomicScore: 80,
            sleepScore: 75,
            rhythmScore: 70,
            activityScore: 65
        )

        #expect(snapshot1.id != snapshot2.id)
    }
}
