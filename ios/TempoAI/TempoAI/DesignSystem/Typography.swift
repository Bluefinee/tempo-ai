import SwiftUI

/// Typography system using SF Pro font family
/// Implements clear hierarchy for cognitive load management
enum Typography {
    case hero  // 34pt bold for large displays
    case title  // 28pt semibold for titles
    case headline  // 20pt semibold for headlines
    case body  // 17pt regular for body text
    case callout  // 16pt regular for callouts
    case subhead  // 15pt regular for subheadings
    case footnote  // 13pt regular for footnotes
    case caption  // 12pt regular for captions
    case monoDigits  // Monospaced for numbers

    // MARK: - Font

    var font: Font {
        switch self {
        case .hero:
            return .system(size: 34, weight: .bold, design: .default)
        case .title:
            return .system(size: 28, weight: .semibold, design: .default)
        case .headline:
            return .system(size: 20, weight: .semibold, design: .default)
        case .body:
            return .system(size: 17, weight: .regular, design: .default)
        case .callout:
            return .system(size: 16, weight: .regular, design: .default)
        case .subhead:
            return .system(size: 15, weight: .regular, design: .default)
        case .footnote:
            return .system(size: 13, weight: .regular, design: .default)
        case .caption:
            return .system(size: 12, weight: .regular, design: .default)
        case .monoDigits:
            return .system(.body, design: .monospaced)
        }
    }

    // MARK: - Line Height

    var lineHeight: CGFloat {
        switch self {
        case .hero: return 41
        case .title: return 34
        case .headline: return 25
        case .body: return 22
        case .callout: return 21
        case .subhead: return 20
        case .footnote: return 18
        case .caption: return 16
        case .monoDigits: return 22
        }
    }

    // MARK: - Letter Spacing

    var letterSpacing: CGFloat {
        switch self {
        case .hero: return 0.37
        case .title: return 0.36
        case .headline: return 0.38
        case .body: return -0.4
        case .callout: return -0.32
        case .subhead: return -0.24
        case .footnote: return -0.08
        case .caption: return 0
        case .monoDigits: return 0
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply typography style to a view
    func typography(_ style: Typography) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineHeight - style.font.UIFontSize)
            .tracking(style.letterSpacing)
    }
}

// MARK: - Font Extension

extension Font {
    /// Get UIFont size for line spacing calculation
    fileprivate var UIFontSize: CGFloat {
        // For now, return standard body size since we're using our own typography system
        return 17  // Default body size that works with most system fonts
    }
}

// MARK: - Text Style Modifiers

struct HeroTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.hero)
            .foregroundColor(ColorPalette.pureBlack)
    }
}

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.title)
            .foregroundColor(ColorPalette.richBlack)
    }
}

struct HeadlineTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.headline)
            .foregroundColor(ColorPalette.richBlack)
    }
}

struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.body)
            .foregroundColor(ColorPalette.gray700)
    }
}

struct SubheadTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.subhead)
            .foregroundColor(ColorPalette.gray500)
    }
}

struct CaptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .typography(.caption)
            .foregroundColor(ColorPalette.gray300)
    }
}

// MARK: - View Extension for Text Styles

extension View {
    func heroStyle() -> some View {
        self.modifier(HeroTextStyle())
    }

    func titleStyle() -> some View {
        self.modifier(TitleTextStyle())
    }

    func headlineStyle() -> some View {
        self.modifier(HeadlineTextStyle())
    }

    func bodyStyle() -> some View {
        self.modifier(BodyTextStyle())
    }

    func subheadStyle() -> some View {
        self.modifier(SubheadTextStyle())
    }

    func captionStyle() -> some View {
        self.modifier(CaptionTextStyle())
    }
}
