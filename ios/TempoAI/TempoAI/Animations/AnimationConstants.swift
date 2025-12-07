import SwiftUI

/// Animation constants for consistent timing and easing throughout the app
struct AnimationConstants {

    /// Animation duration constants
    enum Duration {
        /// 0.1s - Instant feedback (button press acknowledgment)
        static let instant: Double = 0.1

        /// 0.2s - Fast transitions (small state changes)
        static let fast: Double = 0.2

        /// 0.3s - Normal transitions (standard UI changes)
        static let normal: Double = 0.3

        /// 0.5s - Slow transitions (important changes)
        static let slow: Double = 0.5

        /// 0.8s - Emphasis transitions (celebration, achievements)
        static let emphasis: Double = 0.8

        /// 1.5s - Extended transitions (data loading, major state changes)
        static let extended: Double = 1.5
    }

    /// Predefined animation curves for consistent feel
    enum AnimationCurve {
        /// Ease out - Fast start, slow end (good for entrances)
        static let easeOut: Animation = .timingCurve(0.0, 0.0, 0.2, 1.0, duration: Duration.normal)

        /// Ease in - Slow start, fast end (good for exits)
        static let easeIn: Animation = .timingCurve(0.4, 0.0, 1.0, 1.0, duration: Duration.normal)

        /// Ease in-out - Balanced (good for movements)
        static let easeInOut: Animation = .timingCurve(0.4, 0.0, 0.2, 1.0, duration: Duration.normal)

        /// Spring - Natural bouncy feel (good for interactions)
        static let spring: Animation = .spring(response: 0.5, dampingFraction: 0.8)

        /// Gentle spring - Less bouncy (good for subtle interactions)
        static let gentleSpring: Animation = .spring(response: 0.4, dampingFraction: 0.9)

        /// Bouncy spring - More bouncy (good for playful interactions)
        static let bouncySpring: Animation = .spring(response: 0.6, dampingFraction: 0.6)
    }

    /// Common animation presets for specific use cases
    struct AnimationPresets {
        /// Button press feedback
        static let buttonPress: Animation = .spring(response: 0.3, dampingFraction: 0.6)

        /// Card expansion
        static let cardExpansion: Animation = .spring(response: 0.4, dampingFraction: 0.8)

        /// Sheet presentation
        static let sheetPresentation: Animation = .spring(response: 0.5, dampingFraction: 0.8)

        /// Page transition
        static let pageTransition: Animation = .timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.4)

        /// Loading state
        static let loadingPulse: Animation = .easeInOut(duration: 1.0).repeatForever(autoreverses: true)

        /// Success feedback
        static let successFeedback: Animation = .spring(response: 0.6, dampingFraction: 0.7)

        /// Error shake
        static let errorShake: Animation = .spring(response: 0.2, dampingFraction: 0.5)
    }

    /// Scale effect values for consistent sizing
    enum ScaleEffect {
        /// Pressed state (slightly smaller)
        static let pressed: CGFloat = 0.95

        /// Active state (slightly smaller)
        static let active: CGFloat = 0.98

        /// Hover state (slightly larger)
        static let hover: CGFloat = 1.05

        /// Emphasized state (noticeably larger)
        static let emphasized: CGFloat = 1.1

        /// Pop effect (significantly larger)
        static let pop: CGFloat = 1.2
    }

    /// Opacity values for consistent transparency
    enum OpacityLevel {
        /// Hidden
        static let hidden: Double = 0.0

        /// Barely visible
        static let subtle: Double = 0.1

        /// Light transparency
        static let light: Double = 0.3

        /// Medium transparency
        static let medium: Double = 0.5

        /// Heavy transparency
        static let heavy: Double = 0.7

        /// Almost opaque
        static let strong: Double = 0.9

        /// Fully visible
        static let opaque: Double = 1.0
    }
}
