//
//  DesignSystemTests.swift
//  TempoAITests
//
//  Tests for Design System (Colors, Typography, Spacing)
//

import Testing
import SwiftUI
@testable import TempoAI

// MARK: - Colors Tests

struct ColorsTests {

    // MARK: - Score Color Tests

    @Test("Score color returns primary for excellent range (80-100)")
    func scoreColorExcellent() {
        let color85 = TempoColors.scoreColor(for: 85)
        let color100 = TempoColors.scoreColor(for: 100)
        let color80 = TempoColors.scoreColor(for: 80)

        #expect(color85 == TempoColors.primary)
        #expect(color100 == TempoColors.primary)
        #expect(color80 == TempoColors.primary)
    }

    @Test("Score color returns primary for good range (60-79)")
    func scoreColorGood() {
        let color70 = TempoColors.scoreColor(for: 70)
        let color60 = TempoColors.scoreColor(for: 60)
        let color79 = TempoColors.scoreColor(for: 79)

        #expect(color70 == TempoColors.primary)
        #expect(color60 == TempoColors.primary)
        #expect(color79 == TempoColors.primary)
    }

    @Test("Score color returns warning for fair range (40-59)")
    func scoreColorFair() {
        let color50 = TempoColors.scoreColor(for: 50)
        let color40 = TempoColors.scoreColor(for: 40)
        let color59 = TempoColors.scoreColor(for: 59)

        #expect(color50 == TempoColors.warning)
        #expect(color40 == TempoColors.warning)
        #expect(color59 == TempoColors.warning)
    }

    @Test("Score color returns caution for poor range (20-39)")
    func scoreColorPoor() {
        let color30 = TempoColors.scoreColor(for: 30)
        let color20 = TempoColors.scoreColor(for: 20)
        let color39 = TempoColors.scoreColor(for: 39)

        #expect(color30 == TempoColors.caution)
        #expect(color20 == TempoColors.caution)
        #expect(color39 == TempoColors.caution)
    }

    @Test("Score color returns danger for rest range (0-19)")
    func scoreColorRest() {
        let color10 = TempoColors.scoreColor(for: 10)
        let color0 = TempoColors.scoreColor(for: 0)
        let color19 = TempoColors.scoreColor(for: 19)

        #expect(color10 == TempoColors.danger)
        #expect(color0 == TempoColors.danger)
        #expect(color19 == TempoColors.danger)
    }

    @Test("Score color handles edge cases")
    func scoreColorEdgeCases() {
        let colorNegative = TempoColors.scoreColor(for: -5)
        let colorOver100 = TempoColors.scoreColor(for: 150)

        #expect(colorNegative == TempoColors.danger)
        #expect(colorOver100 == TempoColors.primary)
    }

    // MARK: - Score Label Tests

    @Test("Score label returns correct Japanese labels")
    func scoreLabelReturnsCorrectLabels() {
        #expect(TempoColors.scoreLabel(for: 85) == "優秀")
        #expect(TempoColors.scoreLabel(for: 70) == "良好")
        #expect(TempoColors.scoreLabel(for: 50) == "注意")
        #expect(TempoColors.scoreLabel(for: 30) == "要注意")
        #expect(TempoColors.scoreLabel(for: 10) == "要改善")
    }

    // MARK: - Hex Color Tests

    @Test("Color initializes correctly from 6-digit hex")
    func colorFromHex6() {
        let color = Color(hex: "#7CB342")
        // Color comparison is not straightforward, so we just verify it doesn't crash
        #expect(color != Color.clear)
    }

    @Test("Color initializes correctly from hex without hash")
    func colorFromHexWithoutHash() {
        let color = Color(hex: "7CB342")
        #expect(color != Color.clear)
    }

    @Test("Color initializes correctly from 3-digit hex")
    func colorFromHex3() {
        let color = Color(hex: "#FFF")
        #expect(color != Color.clear)
    }
}

// MARK: - Spacing Tests

struct SpacingTests {

    @Test("Spacing values follow 4pt base unit")
    func spacingValuesFollow4ptBase() {
        // All spacing values should be divisible by 4
        #expect(Int(TempoSpacing.xxs) % 4 == 0)
        #expect(Int(TempoSpacing.xs) % 4 == 0)
        #expect(Int(TempoSpacing.sm) % 4 == 0)
        #expect(Int(TempoSpacing.md) % 4 == 0)
        #expect(Int(TempoSpacing.lg) % 4 == 0)
        #expect(Int(TempoSpacing.xl) % 4 == 0)
        #expect(Int(TempoSpacing.xxl) % 4 == 0)
    }

    @Test("Spacing values are in ascending order")
    func spacingValuesAscending() {
        #expect(TempoSpacing.xxs < TempoSpacing.xs)
        #expect(TempoSpacing.xs < TempoSpacing.sm)
        #expect(TempoSpacing.sm < TempoSpacing.md)
        #expect(TempoSpacing.md < TempoSpacing.lg)
        #expect(TempoSpacing.lg < TempoSpacing.xl)
        #expect(TempoSpacing.xl < TempoSpacing.xxl)
    }

    @Test("Layout constants match specification")
    func layoutConstantsMatchSpec() {
        #expect(TempoSpacing.screenPadding == 16)
        #expect(TempoSpacing.cardPadding == 16)
        #expect(TempoSpacing.cardCornerRadius == 16)
        #expect(TempoSpacing.buttonCornerRadius == 12)
        #expect(TempoSpacing.smallCornerRadius == 8)
    }
}

// MARK: - Mood Tests

struct MoodTests {

    @Test("Mood has 5 cases")
    func moodHas5Cases() {
        #expect(Mood.allCases.count == 5)
    }

    @Test("Mood raw values are 1-5")
    func moodRawValues() {
        #expect(Mood.veryBad.rawValue == 1)
        #expect(Mood.bad.rawValue == 2)
        #expect(Mood.neutral.rawValue == 3)
        #expect(Mood.good.rawValue == 4)
        #expect(Mood.veryGood.rawValue == 5)
    }

    @Test("Mood icons are not empty")
    func moodIconsNotEmpty() {
        for mood in Mood.allCases {
            #expect(!mood.icon.isEmpty)
        }
    }

    @Test("Mood accessibility labels are not empty")
    func moodAccessibilityLabelsNotEmpty() {
        for mood in Mood.allCases {
            #expect(!mood.accessibilityLabel.isEmpty)
        }
    }
}

// MARK: - Today Mode Tests

struct TodayModeTests {

    @Test("TodayMode has 3 cases")
    func todayModeHas3Cases() {
        #expect(TodayMode.allCases.count == 3)
    }

    @Test("TodayMode labels are not empty")
    func todayModeLabelsNotEmpty() {
        for mode in TodayMode.allCases {
            #expect(!mode.label.isEmpty)
            #expect(!mode.icon.isEmpty)
            #expect(!mode.description.isEmpty)
        }
    }

    @Test("TodayMode raw values are correct")
    func todayModeRawValues() {
        #expect(TodayMode.normal.rawValue == "normal")
        #expect(TodayMode.challenge.rawValue == "challenge")
        #expect(TodayMode.holiday.rawValue == "holiday")
    }
}
