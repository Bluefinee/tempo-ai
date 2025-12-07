//
//  SpacingTests.swift
//  TempoAITests
//
//  Created by Claude for comprehensive test coverage
//  TDD-based test implementation for spacing design system
//

import XCTest
import SwiftUI
@testable import TempoAI

/// Test suite for Spacing design system component
/// Ensures consistent 8px grid system and proper layout constants
final class SpacingTests: XCTestCase {

    // MARK: - Core Spacing Tests
    
    func testSpacingValues_AreDefinedCorrectly() {
        // Test that all spacing values are defined and positive
        XCTAssertEqual(Spacing.xxs, 2, "XXS spacing should be 2px")
        XCTAssertEqual(Spacing.xs, 4, "XS spacing should be 4px") 
        XCTAssertEqual(Spacing.sm, 8, "SM spacing should be 8px")
        XCTAssertEqual(Spacing.md, 16, "MD spacing should be 16px")
        XCTAssertEqual(Spacing.lg, 24, "LG spacing should be 24px")
        XCTAssertEqual(Spacing.xl, 32, "XL spacing should be 32px")
        XCTAssertEqual(Spacing.xxl, 48, "XXL spacing should be 48px")
        XCTAssertEqual(Spacing.huge, 64, "Huge spacing should be 64px")
    }
    
    func testSpacingProgression_Follows8pxGrid() {
        // Test that spacing follows 8px grid system where applicable
        let spacings: [(String, CGFloat)] = [
            ("xs", Spacing.xs),
            ("sm", Spacing.sm), 
            ("md", Spacing.md),
            ("lg", Spacing.lg),
            ("xl", Spacing.xl),
            ("xxl", Spacing.xxl),
            ("huge", Spacing.huge)
        ]
        
        for (name, value) in spacings {
            if value >= 8 {
                let remainder = value.truncatingRemainder(dividingBy: 8)
                XCTAssertEqual(remainder, 0, "\(name) spacing (\(value)) should align to 8px grid")
            }
        }
    }
    
    func testSpacingProgression_IsLogical() {
        // Test that spacing values increase in logical progression
        XCTAssertLessThan(Spacing.xxs, Spacing.xs)
        XCTAssertLessThan(Spacing.xs, Spacing.sm)
        XCTAssertLessThan(Spacing.sm, Spacing.md)
        XCTAssertLessThan(Spacing.md, Spacing.lg)
        XCTAssertLessThan(Spacing.lg, Spacing.xl)
        XCTAssertLessThan(Spacing.xl, Spacing.xxl)
        XCTAssertLessThan(Spacing.xxl, Spacing.huge)
    }
    
    // MARK: - Dynamic Spacing Tests
    
    func testDynamicSpacing_WithDefaults() {
        // Test dynamic spacing with default compact value
        let baseValue: CGFloat = 16
        let result = Spacing.dynamic(baseValue)
        
        XCTAssertGreaterThan(result, 0, "Dynamic spacing should return positive value")
        // Result should be either base value or 75% of it for compact
        XCTAssertTrue(result == baseValue || result == baseValue * 0.75)
    }
    
    func testDynamicSpacing_WithCustomCompactValue() {
        // Test dynamic spacing with custom compact value
        let baseValue: CGFloat = 24
        let compactValue: CGFloat = 16
        let result = Spacing.dynamic(baseValue, compact: compactValue)
        
        XCTAssertGreaterThan(result, 0, "Dynamic spacing should return positive value")
        // Result should be either base value or custom compact value
        XCTAssertTrue(result == baseValue || result == compactValue)
    }
    
    func testDynamicSpacing_RespondsToScreenSize() {
        // This test is more about API correctness since UIScreen.main in tests
        // might not reflect actual device behavior
        let testValues: [CGFloat] = [8, 16, 24, 32, 48]
        
        for value in testValues {
            let result = Spacing.dynamic(value)
            XCTAssertGreaterThan(result, 0)
            XCTAssertLessThanOrEqual(result, value, "Dynamic spacing should not exceed base value")
        }
    }
    
    // MARK: - Grid Helper Tests
    
    func testGridMultiplier_ReturnsCorrectValues() {
        // Test grid multiplier function
        XCTAssertEqual(Spacing.grid(1), 8, "Grid(1) should return 8")
        XCTAssertEqual(Spacing.grid(2), 16, "Grid(2) should return 16")
        XCTAssertEqual(Spacing.grid(3), 24, "Grid(3) should return 24")
        XCTAssertEqual(Spacing.grid(0), 0, "Grid(0) should return 0")
    }
    
    func testGridMultiplier_HandlesNegativeValues() {
        // Test that grid function handles negative multipliers appropriately
        XCTAssertEqual(Spacing.grid(-1), -8, "Grid(-1) should return -8")
        XCTAssertEqual(Spacing.grid(-2), -16, "Grid(-2) should return -16")
    }
    
    func testAlignToGrid_RoundsCorrectly() {
        // Test grid alignment function
        XCTAssertEqual(Spacing.alignToGrid(0), 0)
        XCTAssertEqual(Spacing.alignToGrid(4), 0, "4px should round to 0")
        XCTAssertEqual(Spacing.alignToGrid(5), 8, "5px should round to 8")
        XCTAssertEqual(Spacing.alignToGrid(12), 8, "12px should round to 8")
        XCTAssertEqual(Spacing.alignToGrid(16), 16, "16px should stay 16")
        XCTAssertEqual(Spacing.alignToGrid(20), 16, "20px should round to 16")
        XCTAssertEqual(Spacing.alignToGrid(24), 24, "24px should stay 24")
    }
    
    // MARK: - EdgeInsets Tests
    
    func testEdgeInsets_AllMethod() {
        // Test uniform insets
        let insets = EdgeInsets.all(16)
        XCTAssertEqual(insets.top, 16)
        XCTAssertEqual(insets.leading, 16)
        XCTAssertEqual(insets.bottom, 16)
        XCTAssertEqual(insets.trailing, 16)
    }
    
    func testEdgeInsets_SymmetricMethod() {
        // Test symmetric insets
        let insets = EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        XCTAssertEqual(insets.top, 10)
        XCTAssertEqual(insets.bottom, 10)
        XCTAssertEqual(insets.leading, 20)
        XCTAssertEqual(insets.trailing, 20)
    }
    
    func testEdgeInsets_PresetValues() {
        // Test preset inset values
        XCTAssertEqual(EdgeInsets.none.top, 0)
        XCTAssertEqual(EdgeInsets.small.top, Spacing.sm)
        XCTAssertEqual(EdgeInsets.medium.top, Spacing.md)
        XCTAssertEqual(EdgeInsets.large.top, Spacing.lg)
        
        // Test card content insets
        let cardInsets = EdgeInsets.cardContent
        XCTAssertEqual(cardInsets.top, Spacing.md)
        XCTAssertEqual(cardInsets.leading, Spacing.md)
        XCTAssertEqual(cardInsets.bottom, Spacing.md)
        XCTAssertEqual(cardInsets.trailing, Spacing.md)
        
        // Test custom screen content insets (equivalent to old screenContent)
        let screenInsets = EdgeInsets(top: Spacing.lg, leading: Spacing.md, bottom: Spacing.lg, trailing: Spacing.md)
        XCTAssertEqual(screenInsets.top, Spacing.lg)
        XCTAssertEqual(screenInsets.bottom, Spacing.lg)
        XCTAssertEqual(screenInsets.leading, Spacing.md)
        XCTAssertEqual(screenInsets.trailing, Spacing.md)
    }
    
    // MARK: - Layout Constants Tests
    
    func testLayoutConstants_MinTapTarget() {
        // Test minimum tap target meets Apple HIG guidelines (44pt)
        XCTAssertEqual(LayoutConstants.minTapTarget, 44, "Min tap target should be 44pt per Apple HIG")
    }
    
    func testLayoutConstants_ButtonHeights() {
        // Test button height values
        XCTAssertEqual(LayoutConstants.buttonHeight, 48, "Standard button should be 48pt")
        XCTAssertEqual(LayoutConstants.compactButtonHeight, 36, "Compact button should be 36pt")
        
        // Button heights should meet or exceed minimum tap target
        XCTAssertGreaterThanOrEqual(LayoutConstants.buttonHeight, LayoutConstants.minTapTarget)
    }
    
    func testLayoutConstants_SystemElements() {
        // Test system element heights
        XCTAssertEqual(LayoutConstants.navigationBarHeight, 44)
        XCTAssertEqual(LayoutConstants.tabBarHeight, 49)
        XCTAssertEqual(LayoutConstants.cardMinHeight, 80)
        XCTAssertEqual(LayoutConstants.maxContentWidth, 640)
    }
    
    func testLayoutConstants_IconSizes() {
        // Test icon size progression
        XCTAssertEqual(LayoutConstants.IconSize.small, 16)
        XCTAssertEqual(LayoutConstants.IconSize.medium, 24) 
        XCTAssertEqual(LayoutConstants.IconSize.large, 32)
        XCTAssertEqual(LayoutConstants.IconSize.xlarge, 48)
        
        // Icon sizes should be in logical progression
        XCTAssertLessThan(LayoutConstants.IconSize.small, LayoutConstants.IconSize.medium)
        XCTAssertLessThan(LayoutConstants.IconSize.medium, LayoutConstants.IconSize.large)
        XCTAssertLessThan(LayoutConstants.IconSize.large, LayoutConstants.IconSize.xlarge)
    }
    
    func testLayoutConstants_AvatarSizes() {
        // Test avatar size progression
        XCTAssertEqual(LayoutConstants.AvatarSize.small, 32)
        XCTAssertEqual(LayoutConstants.AvatarSize.medium, 48)
        XCTAssertEqual(LayoutConstants.AvatarSize.large, 64)
        XCTAssertEqual(LayoutConstants.AvatarSize.xlarge, 96)
        
        // Avatar sizes should be in logical progression
        XCTAssertLessThan(LayoutConstants.AvatarSize.small, LayoutConstants.AvatarSize.medium)
        XCTAssertLessThan(LayoutConstants.AvatarSize.medium, LayoutConstants.AvatarSize.large)
        XCTAssertLessThan(LayoutConstants.AvatarSize.large, LayoutConstants.AvatarSize.xlarge)
    }
    
    // MARK: - Performance Tests
    
    func testSpacing_PerformanceIsOptimal() {
        // Test that spacing calculations are performant
        measure {
            for _ in 0..<1000 {
                _ = Spacing.md
                _ = Spacing.dynamic(16)
                _ = Spacing.grid(3)
                _ = Spacing.alignToGrid(20)
            }
        }
    }
    
    func testEdgeInsets_PerformanceIsOptimal() {
        // Test that EdgeInsets calculations are performant  
        measure {
            for _ in 0..<1000 {
                _ = EdgeInsets.all(16)
                _ = EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                _ = EdgeInsets.cardContent
                _ = EdgeInsets(top: Spacing.lg, leading: Spacing.md, bottom: Spacing.lg, trailing: Spacing.md)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testSpacing_HandlesZeroValues() {
        // Test that zero values work correctly
        XCTAssertEqual(Spacing.grid(0), 0)
        XCTAssertEqual(Spacing.alignToGrid(0), 0)
        XCTAssertEqual(Spacing.dynamic(0), 0)
    }
    
    func testEdgeInsets_HandlesZeroValues() {
        // Test that zero insets work correctly
        let zeroInsets = EdgeInsets.all(0)
        XCTAssertEqual(zeroInsets.top, 0)
        XCTAssertEqual(zeroInsets.leading, 0)
        XCTAssertEqual(zeroInsets.bottom, 0)
        XCTAssertEqual(zeroInsets.trailing, 0)
    }
    
    func testLayoutConstants_ArePositive() {
        // Test that all layout constants are positive values
        XCTAssertGreaterThan(LayoutConstants.minTapTarget, 0)
        XCTAssertGreaterThan(LayoutConstants.buttonHeight, 0)
        XCTAssertGreaterThan(LayoutConstants.compactButtonHeight, 0)
        XCTAssertGreaterThan(LayoutConstants.cardMinHeight, 0)
        XCTAssertGreaterThan(LayoutConstants.maxContentWidth, 0)
        
        // Icon sizes
        XCTAssertGreaterThan(LayoutConstants.IconSize.small, 0)
        XCTAssertGreaterThan(LayoutConstants.IconSize.medium, 0)
        XCTAssertGreaterThan(LayoutConstants.IconSize.large, 0)
        XCTAssertGreaterThan(LayoutConstants.IconSize.xlarge, 0)
        
        // Avatar sizes
        XCTAssertGreaterThan(LayoutConstants.AvatarSize.small, 0)
        XCTAssertGreaterThan(LayoutConstants.AvatarSize.medium, 0)
        XCTAssertGreaterThan(LayoutConstants.AvatarSize.large, 0)
        XCTAssertGreaterThan(LayoutConstants.AvatarSize.xlarge, 0)
    }
}