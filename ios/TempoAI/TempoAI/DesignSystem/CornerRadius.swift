import CoreGraphics

// swiftlint:disable identifier_name

/// Corner radius system for consistent rounded corners
enum CornerRadius {
    /// 4px - Small radius for button elements
    static let xs: CGFloat = 4

    /// 8px - Small components
    static let sm: CGFloat = 8

    /// 12px - Standard cards
    static let md: CGFloat = 12

    /// 16px - Modal dialogs
    static let lg: CGFloat = 16

    /// 20px - Large cards
    static let xl: CGFloat = 20

    /// Infinity - Full circular elements
    static let full: CGFloat = .infinity

    /// Dynamic corner radius based on element size
    static func dynamic(for size: CGFloat) -> CGFloat {
        return min(size * 0.2, lg)
    }

    /// Pill-shaped corner radius (half of height)
    static func pill(height: CGFloat) -> CGFloat {
        return height / 2
    }
}
// swiftlint:enable identifier_name
