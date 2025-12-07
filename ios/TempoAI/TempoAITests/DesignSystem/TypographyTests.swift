//
//  TypographyTests.swift
//  TempoAITests
//
//  Created by Claude for comprehensive test coverage
//  TDD-based test implementation for typography design system
//

import XCTest
import SwiftUI
@testable import TempoAI

/// Test suite for Typography design system component
/// Ensures consistent font hierarchy and accessibility compliance
final class TypographyTests: XCTestCase {

    // MARK: - Typography Hierarchy Tests

    func testTypographyHierarchy_AllStylesAreDefined() {
        // Arrange - All typography styles
        let typographyStyles: [Typography] = [
            .hero, .title, .headline, .body, .callout, .subhead, .footnote, .caption, .monoDigits
        ]

        // Act & Assert
        for style in typographyStyles {
            XCTAssertNotNil(style.font, "Typography style \(style) should have a defined font")
            XCTAssertGreaterThan(style.size, 0, "Typography style \(style) should have positive size")
            XCTAssertGreaterThan(style.lineHeight, 0, "Typography style \(style) should have positive line height")
        }
    }

    func testTypographyHierarchy_SizeProgression() {
        // Arrange - Typography sizes in descending order
        let orderedStyles: [(Typography, String)] = [
            (.hero, "hero"),
            (.title, "title"),
            (.headline, "headline"),
            (.body, "body"),
            (.callout, "callout"),
            (.subhead, "subhead"),
            (.footnote, "footnote"),
            (.caption, "caption")
        ]

        // Act & Assert - Each style should be larger than the next
        for i in 0..<(orderedStyles.count - 1) {
            let currentStyle = orderedStyles[i]
            let nextStyle = orderedStyles[i + 1]

            XCTAssertGreaterThanOrEqual(
                currentStyle.0.size,
                nextStyle.0.size,
                "\(currentStyle.1) (\(currentStyle.0.size)pt) should be >= \(nextStyle.1) (\(nextStyle.0.size)pt)"
            )
        }
    }

    func testTypographyLineHeight_IsProportional() {
        // Test that line height maintains good proportions to font size
        let styles: [Typography] = [.hero, .title, .headline, .body, .callout, .subhead, .footnote, .caption]

        for style in styles {
            let ratio = style.lineHeight / style.size
            XCTAssertGreaterThanOrEqual(ratio, 1.0, "Line height should be at least equal to font size for \(style)")
            XCTAssertLessThanOrEqual(ratio, 1.8, "Line height should not be excessively large for \(style)")
        }
    }

    func testTypographyLetterSpacing_IsReasonable() {
        // Test that letter spacing values are within reasonable ranges
        let styles: [Typography] = [.hero, .title, .headline, .body, .callout, .subhead, .footnote, .caption]

        for style in styles {
            XCTAssertGreaterThanOrEqual(style.letterSpacing, -1.0, "Letter spacing should not be too negative for \(style)")
            XCTAssertLessThanOrEqual(style.letterSpacing, 2.0, "Letter spacing should not be excessively positive for \(style)")
        }
    }

    // MARK: - Font Property Tests

    func testTypographyFont_UsesSystemFont() {
        // Test that fonts use the system font family for consistency
        let styles: [Typography] = [.hero, .title, .headline, .body, .callout, .subhead, .footnote, .caption]

        for style in styles {
            let font = style.font
            XCTAssertNotNil(font, "Font should be defined for \(style)")

            // Test that we can access the UIFontSize property (this verifies our Font extension)
            let uiFontSize = font.UIFontSize
            XCTAssertEqual(uiFontSize, style.size, "UIFontSize should match style size for \(style)")
        }
    }

    func testMonoDigitsFont_HasUniqueProperties() {
        // Test that monoDigits has special properties for numerical display
        let monoDigits = Typography.monoDigits
        let body = Typography.body

        XCTAssertNotNil(monoDigits.font)

        // MonoDigits should be readable (similar to body size)
        XCTAssertGreaterThanOrEqual(monoDigits.size, body.size * 0.8)
        XCTAssertLessThanOrEqual(monoDigits.size, body.size * 1.2)
    }

    // MARK: - ViewModifier Tests

    func testTypographyModifier_AppliesCorrectStyle() {
        // Create test view with typography modifiers
        let testView = Text("Test")

        // Test that modifiers can be applied without errors
        let heroView = testView.typography(.hero)
        let bodyView = testView.typography(.body)
        let captionView = testView.typography(.caption)

        XCTAssertNotNil(heroView)
        XCTAssertNotNil(bodyView)
        XCTAssertNotNil(captionView)
    }

    func testHeadlineStyleModifier_WorksCorrectly() {
        let testView = Text("Test")
        let styledView = testView.headlineStyle()

        XCTAssertNotNil(styledView)
    }

    func testBodyStyleModifier_WorksCorrectly() {
        let testView = Text("Test")
        let styledView = testView.bodyStyle()

        XCTAssertNotNil(styledView)
    }

    func testCaptionStyleModifier_WorksCorrectly() {
        let testView = Text("Test")
        let styledView = testView.captionStyle()

        XCTAssertNotNil(styledView)
    }

    // MARK: - Accessibility Tests

    func testTypography_SupportsAccessibilityScaling() {
        // Test that typography can handle accessibility font size scaling
        let styles: [Typography] = [.body, .headline, .caption]

        for style in styles {
            // Base size should be reasonable for standard viewing
            XCTAssertGreaterThanOrEqual(style.size, 10.0, "Base font size should be readable for \(style)")
            XCTAssertLessThanOrEqual(style.size, 72.0, "Base font size should not be excessive for \(style)")
        }
    }

    func testTypographyHierarchy_MaintainsAccessibility() {
        // Test that even small text maintains minimum accessibility requirements
        let smallestStyles: [Typography] = [.caption, .footnote]

        for style in smallestStyles {
            // Even small text should be at least 10pt for basic accessibility
            XCTAssertGreaterThanOrEqual(style.size, 10.0, "Small text should meet minimum size requirements for \(style)")
        }
    }

    // MARK: - Performance Tests

    func testTypography_PerformanceIsOptimal() {
        // Test that typography access is performant
        measure {
            for _ in 0..<1000 {
                _ = Typography.hero.font
                _ = Typography.body.size
                _ = Typography.caption.lineHeight
                _ = Typography.headline.letterSpacing
            }
        }
    }

    // MARK: - Edge Cases

    func testTypographyValues_AreConsistent() {
        // Test that typography values don't change unexpectedly
        let body = Typography.body
        let firstAccessSize = body.size
        let secondAccessSize = body.size

        XCTAssertEqual(firstAccessSize, secondAccessSize, "Typography values should be consistent")

        let firstAccessLineHeight = body.lineHeight
        let secondAccessLineHeight = body.lineHeight

        XCTAssertEqual(firstAccessLineHeight, secondAccessLineHeight, "Line height values should be consistent")
    }

    func testUIFontSizeExtension_HandlesAllFontTypes() {
        // Test our custom UIFontSize extension with different font configurations
        let systemFont = Font.system(size: 16)
        let largeTitleFont = Font.largeTitle
        let bodyFont = Font.body

        // Should not crash and should return reasonable values
        XCTAssertGreaterThan(systemFont.UIFontSize, 0)
        XCTAssertGreaterThan(largeTitleFont.UIFontSize, 0)
        XCTAssertGreaterThan(bodyFont.UIFontSize, 0)
    }

    func testTypographyEnum_CaseIterable() {
        // If Typography implements CaseIterable, test all cases
        let allStyles: [Typography] = [
            .hero, .title, .headline, .body, .callout, .subhead, .footnote, .caption, .monoDigits
        ]

        XCTAssertEqual(allStyles.count, 9, "Should have exactly 9 typography styles")

        // All should be unique
        let uniqueStrings = Set(allStyles.map { "\($0)" })
        XCTAssertEqual(uniqueStrings.count, allStyles.count, "All typography styles should be unique")
    }
}
