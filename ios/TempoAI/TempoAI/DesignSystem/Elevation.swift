import SwiftUI

/// Elevation system for depth hierarchy
enum Elevation {
    case none
    case low  // Subtle elevation for cards
    case medium  // Standard elevation for floating elements
    case high  // High elevation for modals
    case overlay  // Maximum elevation for overlays

    // MARK: - Shadow Properties

    var color: Color {
        switch self {
        case .none:
            return .clear
        case .low:
            return .black.opacity(0.1)
        case .medium:
            return .black.opacity(0.15)
        case .high:
            return .black.opacity(0.2)
        case .overlay:
            return .black.opacity(0.25)
        }
    }

    var radius: CGFloat {
        switch self {
        case .none:
            return 0
        case .low:
            return 3
        case .medium:
            return 6
        case .high:
            return 12
        case .overlay:
            return 24
        }
    }

    var offsetX: CGFloat {
        return 0
    }

    var offsetY: CGFloat {
        switch self {
        case .none:
            return 0
        case .low:
            return 1
        case .medium:
            return 2
        case .high:
            return 4
        case .overlay:
            return 8
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply elevation shadow to a view
    func elevation(_ level: Elevation) -> some View {
        self.shadow(
            color: level.color,
            radius: level.radius,
            x: level.offsetX,
            y: level.offsetY
        )
    }

    /// Apply custom shadow with blur and spread
    func customShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 10,
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 5
    ) -> some View {
        self.shadow(color: color, radius: radius, x: offsetX, y: offsetY)
    }
}

// MARK: - Elevation Modifiers

struct CardElevation: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .elevation(isPressed ? .low : .medium)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}

struct FloatingElevation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .elevation(.high)
    }
}

struct OverlayElevation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .elevation(.overlay)
            .background(Color.black.opacity(0.3).ignoresSafeArea())
    }
}

// MARK: - Convenience Methods

extension View {
    func cardElevation(isPressed: Bool = false) -> some View {
        self.modifier(CardElevation(isPressed: isPressed))
    }

    func floatingElevation() -> some View {
        self.modifier(FloatingElevation())
    }

    func overlayElevation() -> some View {
        self.modifier(OverlayElevation())
    }
}
