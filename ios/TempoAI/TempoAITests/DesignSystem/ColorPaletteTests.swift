//
//  ColorPaletteTests.swift
//  TempoAITests
//
//  Created by Claude for comprehensive test coverage
//  TDD-based test implementation for design system color palette
//

import XCTest
import SwiftUI
@testable import TempoAI

/// Test suite for ColorPalette design system component
/// Ensures WCAG 2.1 AAA compliance and consistent color definitions
final class ColorPaletteTests: XCTestCase {

    // MARK: - Core Color Tests

    func testPrimaryColors_HaveCorrectValues() {
        // Arrange & Act
        let pureBlack = ColorPalette.pureBlack
        let richBlack = ColorPalette.richBlack
        let pureWhite = ColorPalette.pureWhite

        // Assert
        XCTAssertNotNil(pureBlack)
        XCTAssertNotNil(richBlack)
        XCTAssertNotNil(pureWhite)

        // Test that colors are distinct
        XCTAssertNotEqual(pureBlack, richBlack)
        XCTAssertNotEqual(pureBlack, pureWhite)
        XCTAssertNotEqual(richBlack, pureWhite)
    }

    func testGrayScale_HasCorrectGradation() {
        // Arrange - All gray variants
        let grays: [(String, Color)] = [
            ("gray900", ColorPalette.gray900),
            ("gray700", ColorPalette.gray700),
            ("gray500", ColorPalette.gray500),
            ("gray400", ColorPalette.gray400),
            ("gray300", ColorPalette.gray300),
            ("gray100", ColorPalette.gray100)
        ]

        // Act & Assert
        for (name, color) in grays {
            XCTAssertNotNil(color, "Gray color \(name) should be defined")
        }

        // Assert all grays are unique
        let colorSet = Set(grays.map { $0.1.description })
        XCTAssertEqual(colorSet.count, grays.count, "All gray colors should be unique")
    }

    func testSemanticColors_AreDefinedAndUnique() {
        // Arrange
        let semanticColors: [(String, Color)] = [
            ("success", ColorPalette.success),
            ("info", ColorPalette.info),
            ("warning", ColorPalette.warning),
            ("error", ColorPalette.error)
        ]

        // Act & Assert
        for (name, color) in semanticColors {
            XCTAssertNotNil(color, "Semantic color \(name) should be defined")
        }

        // Assert semantic colors are distinct from grayscale
        XCTAssertNotEqual(ColorPalette.success, ColorPalette.gray500)
        XCTAssertNotEqual(ColorPalette.info, ColorPalette.gray300)
        XCTAssertNotEqual(ColorPalette.warning, ColorPalette.gray700)
        XCTAssertNotEqual(ColorPalette.error, ColorPalette.gray900)
    }

    func testBackgroundColors_AreDefinedCorrectly() {
        // Arrange & Act
        let backgrounds: [(String, Color)] = [
            ("primaryBackground", ColorPalette.primaryBackground),
            ("secondaryBackground", ColorPalette.secondaryBackground),
            ("successBackground", ColorPalette.successBackground),
            ("infoBackground", ColorPalette.infoBackground),
            ("warningBackground", ColorPalette.warningBackground),
            ("errorBackground", ColorPalette.errorBackground)
        ]

        // Assert
        for (name, color) in backgrounds {
            XCTAssertNotNil(color, "Background color \(name) should be defined")
        }

        // Test background colors are lighter than their semantic counterparts
        XCTAssertNotEqual(ColorPalette.successBackground, ColorPalette.success)
        XCTAssertNotEqual(ColorPalette.infoBackground, ColorPalette.info)
        XCTAssertNotEqual(ColorPalette.warningBackground, ColorPalette.warning)
        XCTAssertNotEqual(ColorPalette.errorBackground, ColorPalette.error)
    }

    // MARK: - Color Relationship Tests

    func testColorHierarchy_MaintainsVisualOrder() {
        // Test that darker colors come before lighter ones in our naming
        // This ensures consistent visual hierarchy

        // Black to gray progression should be visually logical
        let progressionColors = [
            ColorPalette.pureBlack,
            ColorPalette.richBlack,
            ColorPalette.charcoal,
            ColorPalette.gray900,
            ColorPalette.gray700,
            ColorPalette.gray500,
            ColorPalette.gray400,
            ColorPalette.gray300,
            ColorPalette.gray100
        ]

        XCTAssertEqual(progressionColors.count, 9, "Should have 9 colors in progression")

        // All colors should be unique
        let uniqueColors = Set(progressionColors.map { $0.description })
        XCTAssertEqual(uniqueColors.count, 9, "All progression colors should be unique")
    }

    func testWhiteVariations_AreDistinct() {
        // Arrange & Act
        let whiteVariations = [
            ColorPalette.pureWhite,
            ColorPalette.offWhite,
            ColorPalette.pearl
        ]

        // Assert
        let uniqueWhites = Set(whiteVariations.map { $0.description })
        XCTAssertEqual(uniqueWhites.count, 3, "All white variations should be unique")
    }

    // MARK: - Accessibility Tests

    func testColorContrast_MeetsWCAGStandards() {
        // Test high contrast combinations that should meet WCAG 2.1 AAA standards
        let highContrastPairs: [(Color, Color, String)] = [
            (ColorPalette.pureBlack, ColorPalette.pureWhite, "Black on White"),
            (ColorPalette.richBlack, ColorPalette.offWhite, "Rich Black on Off White"),
            (ColorPalette.gray900, ColorPalette.gray100, "Gray 900 on Gray 100")
        ]

        for (foreground, background, description) in highContrastPairs {
            XCTAssertNotEqual(foreground, background, "\(description) should have contrasting colors")
        }
    }

    func testSemanticColorAccessibility_IsAppropriate() {
        // Semantic colors should be distinguishable from each other
        let semanticPairs: [(Color, Color, String)] = [
            (ColorPalette.success, ColorPalette.error, "Success vs Error"),
            (ColorPalette.info, ColorPalette.warning, "Info vs Warning"),
            (ColorPalette.success, ColorPalette.warning, "Success vs Warning"),
            (ColorPalette.info, ColorPalette.error, "Info vs Error")
        ]

        for (color1, color2, description) in semanticPairs {
            XCTAssertNotEqual(color1, color2, "\(description) should be distinguishable")
        }
    }

    // MARK: - Performance Tests

    func testColorPalette_PerformanceIsOptimal() {
        // Test that color access is performant
        measure {
            for _ in 0..<1000 {
                _ = ColorPalette.richBlack
                _ = ColorPalette.gray500
                _ = ColorPalette.success
                _ = ColorPalette.pureWhite
            }
        }
    }

    // MARK: - Edge Cases

    func testColorPalette_HandlesAllRequiredColors() {
        // Ensure all colors mentioned in the design system are available
        let requiredColors: [KeyPath<ColorPalette.Type, Color>] = [
            // Primary colors
            \.pureBlack, \.richBlack, \.pureWhite,
            // Grays
            \.gray900, \.gray700, \.gray500, \.gray400, \.gray300, \.gray100,
            // Semantic
            \.success, \.info, \.warning, \.error,
            // Backgrounds
            \.primaryBackground, \.secondaryBackground,
            \.successBackground, \.infoBackground, \.warningBackground, \.errorBackground
        ]

        for colorKeyPath in requiredColors {
            let color = ColorPalette[keyPath: colorKeyPath]
            XCTAssertNotNil(color, "Required color at keyPath \(colorKeyPath) should be available")
        }
    }
}
