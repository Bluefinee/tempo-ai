import CoreGraphics
import UIKit

/// Spacing system based on 8px grid
/// Provides consistent spacing throughout the application
enum Spacing {
    /// 2px - Minimal spacing for very tight layouts
    static let xxs: CGFloat = 2

    /// 4px - Extra small spacing for compact elements
    static let xs: CGFloat = 4

    /// 8px - Small spacing for related elements
    static let sm: CGFloat = 8

    /// 16px - Standard spacing for most use cases
    static let md: CGFloat = 16

    /// 24px - Large spacing for section separation
    static let lg: CGFloat = 24

    /// 32px - Extra large spacing for major sections
    static let xl: CGFloat = 32

    /// 48px - Double extra large spacing
    static let xxl: CGFloat = 48

    /// 64px - Huge spacing for prominent separation
    static let huge: CGFloat = 64

    // MARK: - Dynamic Spacing

    /// Returns appropriate spacing based on size class
    static func dynamic(_ base: CGFloat, compact: CGFloat? = nil) -> CGFloat {
        #if os(iOS)
            let isCompact = UIScreen.main.bounds.width < 375
            return isCompact ? (compact ?? base * 0.75) : base
        #else
            return base
        #endif
    }

    // MARK: - Grid Helpers

    /// Returns a value aligned to 8px grid
    static func grid(_ multiplier: Int) -> CGFloat {
        return CGFloat(multiplier * 8)
    }

    /// Rounds a value to nearest 8px grid point
    static func alignToGrid(_ value: CGFloat) -> CGFloat {
        return round(value / 8) * 8
    }
}
// swiftlint:enable identifier_name

// MARK: - Insets

struct EdgeInsets {
    let top: CGFloat
    let leading: CGFloat
    let bottom: CGFloat
    let trailing: CGFloat

    /// Uniform insets on all sides
    static func all(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Horizontal and vertical insets
    static func symmetric(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> EdgeInsets {
        EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    /// Common preset insets
    static let none = EdgeInsets.all(0)
    static let small = EdgeInsets.all(Spacing.sm)
    static let medium = EdgeInsets.all(Spacing.md)
    static let large = EdgeInsets.all(Spacing.lg)

    /// Content insets for cards and containers
    static let cardContent = EdgeInsets.all(Spacing.md)
    static let screenContent = EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.lg)
}

// MARK: - Layout Constants

struct LayoutConstants {
    /// Minimum tap target size (Apple HIG recommendation)
    static let minTapTarget: CGFloat = 44

    /// Standard button height
    static let buttonHeight: CGFloat = 48

    /// Compact button height
    static let compactButtonHeight: CGFloat = 36

    /// Standard card height
    static let cardMinHeight: CGFloat = 80

    /// Navigation bar height
    static let navigationBarHeight: CGFloat = 44

    /// Tab bar height
    static let tabBarHeight: CGFloat = 49

    /// Maximum content width for readability
    static let maxContentWidth: CGFloat = 640

    /// Icon sizes
    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let xlarge: CGFloat = 48
    }

    /// Avatar sizes
    struct AvatarSize {
        static let small: CGFloat = 32
        static let medium: CGFloat = 48
        static let large: CGFloat = 64
        static let xlarge: CGFloat = 96
    }
}
