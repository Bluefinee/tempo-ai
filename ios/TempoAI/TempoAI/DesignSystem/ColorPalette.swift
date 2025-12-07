import SwiftUI

/// Tempo AI Color Palette - Black and white-based minimal design
/// Based on UI/UX renovation plan for cognitive load reduction and visual hierarchy
enum ColorPalette {
    // MARK: - Blacks

    /// Pure black for most important text
    static let pureBlack: Color = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Rich black for primary text
    static let richBlack: Color = Color(red: 0.039, green: 0.039, blue: 0.039)

    /// Charcoal for secondary backgrounds
    static let charcoal: Color = Color(red: 0.11, green: 0.11, blue: 0.118)

    // MARK: - Grays (5 levels)

    /// Gray 900 for borders and dividers
    static let gray900: Color = Color(red: 0.173, green: 0.173, blue: 0.18)

    /// Gray 700 for inactive elements
    static let gray700: Color = Color(red: 0.282, green: 0.282, blue: 0.29)

    /// Gray 600 for secondary text (darker)
    static let gray600: Color = Color(red: 0.335, green: 0.335, blue: 0.345)

    /// Gray 500 for secondary text
    static let gray500: Color = Color(red: 0.388, green: 0.388, blue: 0.4)

    /// Gray 400 for subtle text and borders
    static let gray400: Color = Color(red: 0.472, green: 0.472, blue: 0.488)

    /// Gray 300 for placeholders
    static let gray300: Color = Color(red: 0.557, green: 0.557, blue: 0.576)

    /// Gray 100 for light backgrounds
    static let gray100: Color = Color(red: 0.78, green: 0.78, blue: 0.8)

    // MARK: - Whites

    /// Pure white for primary backgrounds
    static let pureWhite: Color = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Off-white for card backgrounds
    static let offWhite: Color = Color(red: 0.98, green: 0.98, blue: 0.98)

    /// Pearl for section backgrounds
    static let pearl: Color = Color(red: 0.949, green: 0.949, blue: 0.969)

    // MARK: - Semantic Colors (minimal use)

    /// Success color for achievements and positive states
    static let success: Color = Color(red: 0.204, green: 0.78, blue: 0.349)

    /// Success background with 10% opacity
    static let successBackground: Color = success.opacity(0.1)

    /// Warning color for cautions
    static let warning: Color = Color(red: 1.0, green: 0.584, blue: 0.0)

    /// Warning background with 10% opacity
    static let warningBackground: Color = warning.opacity(0.1)

    /// Error color for critical states
    static let error: Color = Color(red: 1.0, green: 0.231, blue: 0.188)

    /// Error background with 10% opacity
    static let errorBackground: Color = error.opacity(0.1)

    /// Info color for neutral information
    static let info: Color = Color(red: 0.0, green: 0.478, blue: 1.0)

    /// Info background with 10% opacity
    static let infoBackground: Color = info.opacity(0.1)

    // MARK: - Dynamic Colors

    /// Primary text color that adapts to color scheme
    static var primaryText: Color {
        Color(UIColor.label)
    }

    /// Secondary text color that adapts to color scheme
    static var secondaryText: Color {
        Color(UIColor.secondaryLabel)
    }

    /// Primary background that adapts to color scheme
    static var primaryBackground: Color {
        Color(UIColor.systemBackground)
    }

    /// Secondary background that adapts to color scheme
    static var secondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }

    /// Card background that adapts to color scheme
    static var cardBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
