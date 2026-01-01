//
//  ScoreTests.swift
//  TempoAITests
//

import Testing
@testable import TempoAI

struct ScoreTests {

    // MARK: - Value Clamping Tests

    @Test("Score clamps value above 100 to 100")
    func scoreClampsTooHighValue() {
        let score: Score = Score(150)
        #expect(score.value == 100)
    }

    @Test("Score clamps negative value to 0")
    func scoreClampsNegativeValue() {
        let score: Score = Score(-10)
        #expect(score.value == 0)
    }

    @Test("Score preserves valid values")
    func scorePreservesValidValue() {
        let score: Score = Score(75)
        #expect(score.value == 75)
    }

    @Test("Score preserves boundary values")
    func scorePreservesBoundaryValues() {
        #expect(Score(0).value == 0)
        #expect(Score(100).value == 100)
    }

    // MARK: - Status Tests

    @Test("Score returns excellent status for 80-100")
    func scoreReturnsExcellentStatus() {
        #expect(Score(100).status == .excellent)
        #expect(Score(80).status == .excellent)
        #expect(Score(90).status == .excellent)
    }

    @Test("Score returns good status for 60-79")
    func scoreReturnsGoodStatus() {
        #expect(Score(79).status == .good)
        #expect(Score(60).status == .good)
        #expect(Score(70).status == .good)
    }

    @Test("Score returns fair status for 40-59")
    func scoreReturnsFairStatus() {
        #expect(Score(59).status == .fair)
        #expect(Score(40).status == .fair)
        #expect(Score(50).status == .fair)
    }

    @Test("Score returns poor status for 20-39")
    func scoreReturnsPoorStatus() {
        #expect(Score(39).status == .poor)
        #expect(Score(20).status == .poor)
        #expect(Score(30).status == .poor)
    }

    @Test("Score returns rest status for 0-19")
    func scoreReturnsRestStatus() {
        #expect(Score(19).status == .rest)
        #expect(Score(0).status == .rest)
        #expect(Score(10).status == .rest)
    }

    // MARK: - Icon Tests

    @Test("Score returns correct icons for each status")
    func scoreReturnsCorrectIcons() {
        #expect(Score(85).icon == "☀️")
        #expect(Score(70).icon == "⛅")
        #expect(Score(50).icon == "🌥️")
        #expect(Score(30).icon == "🌧️")
        #expect(Score(10).icon == "⛈️")
    }

    // MARK: - Display Value Tests

    @Test("Score displays value when not calibrating")
    func scoreDisplaysValueWhenNotCalibrating() {
        let score: Score = Score(75)
        #expect(score.displayValue(isCalibrating: false) == "75")
    }

    @Test("Score displays dashes when calibrating")
    func scoreDisplaysDashesWhenCalibrating() {
        let score: Score = Score(75)
        #expect(score.displayValue(isCalibrating: true) == "---")
    }

    // MARK: - Equatable Tests

    @Test("Scores with same value are equal")
    func scoresWithSameValueAreEqual() {
        #expect(Score(80) == Score(80))
    }

    @Test("Scores with different values are not equal")
    func scoresWithDifferentValuesAreNotEqual() {
        #expect(Score(80) != Score(81))
    }
}
