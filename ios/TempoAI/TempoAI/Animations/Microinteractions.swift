import SwiftUI
import UIKit

// MARK: - Microinteractions

// MARK: - Haptic Feedback

enum HapticFeedback {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection

    func trigger() {
        switch self {
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .medium:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        case .heavy:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        case .success:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        case .warning:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        case .error:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        case .selection:
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
}

// MARK: - Tap Feedback Modifier

struct TapFeedbackModifier: ViewModifier {
    let haptic: HapticFeedback
    let scaleEffect: CGFloat
    let action: () -> Void

    @State private var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scaleEffect : 1.0)
            .animation(AnimationConstants.AnimationPresets.buttonPress, value: isPressed)
            .onTapGesture {
                haptic.trigger()
                action()
            }
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
                // Never triggered
            } onPressingChanged: { pressing in
                withAnimation(AnimationConstants.AnimationPresets.buttonPress) {
                    isPressed = pressing
                }
            }
    }
}

extension View {
    /// Add tap feedback with haptic and scale animation
    func tapFeedback(
        haptic: HapticFeedback = .light,
        scale: CGFloat = AnimationConstants.ScaleEffect.pressed,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            TapFeedbackModifier(
                haptic: haptic,
                scaleEffect: scale,
                action: action
            ))
    }
}

// MARK: - Skeleton Loading Animation

struct SkeletonModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    private let gradient = LinearGradient(
        colors: [
            ColorPalette.gray100.opacity(0.3),
            ColorPalette.gray100.opacity(0.1),
            ColorPalette.gray100.opacity(0.3),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    func body(content: Content) -> some View {
        content
            .overlay(
                gradient
                    .offset(x: phase * 400 - 200)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
            )
            .onAppear {
                phase = 1
            }
    }
}

extension View {
    /// Apply skeleton loading animation
    func skeleton() -> some View {
        self.modifier(SkeletonModifier())
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    let minOpacity: Double
    let maxOpacity: Double
    let duration: Double

    @State private var isAnimating: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? maxOpacity : minOpacity)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    /// Apply pulsing opacity animation
    func pulse(
        minOpacity: Double = 0.3,
        maxOpacity: Double = 1.0,
        duration: Double = 1.0
    ) -> some View {
        self.modifier(
            PulseModifier(
                minOpacity: minOpacity,
                maxOpacity: maxOpacity,
                duration: duration
            ))
    }
}

// MARK: - Shake Animation

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            ))
    }
}

extension View {
    /// Apply shake animation
    func shake(with amount: CGFloat = 10, shakesPerUnit: Int = 3, animationValue: CGFloat) -> some View {
        self.modifier(
            ShakeEffect(
                amount: amount,
                shakesPerUnit: shakesPerUnit,
                animatableData: animationValue
            ))
    }
}

// MARK: - Bounce Animation

struct BounceModifier: ViewModifier {
    @State private var isAnimating: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? AnimationConstants.ScaleEffect.pop : 1.0)
            .animation(AnimationConstants.AnimationPresets.successFeedback, value: isAnimating)
            .onAppear {
                withAnimation {
                    isAnimating = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        isAnimating = false
                    }
                }
            }
    }
}

extension View {
    /// Apply bounce animation on appearance
    func bounce() -> some View {
        self.modifier(BounceModifier())
    }
}

// MARK: - Slide Transition

struct SlideTransition {
    static let fromLeading = AnyTransition.asymmetric(
        insertion: .move(edge: .leading),
        removal: .move(edge: .trailing)
    )

    static let fromTrailing = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading)
    )

    static let fromTop = AnyTransition.asymmetric(
        insertion: .move(edge: .top),
        removal: .move(edge: .bottom)
    )

    static let fromBottom = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .top)
    )
}

// MARK: - Progress Ring Animation

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    color.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(.easeOut(duration: AnimationConstants.Duration.extended)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newProgress in
            withAnimation(.easeOut(duration: AnimationConstants.Duration.slow)) {
                animatedProgress = newProgress
            }
        }
    }

}
