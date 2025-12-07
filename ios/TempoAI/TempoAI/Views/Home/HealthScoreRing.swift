import SwiftUI

/// Animated health score ring with gradient and smooth transitions
struct HealthScoreRing: View {
    let score: Double  // 0.0 - 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let showDetails: Bool

    @State private var animatedScore: Double = 0
    @State private var isAnimating: Bool = false
    @State private var pulseAnimation: Bool = false

    init(
        score: Double,
        size: CGFloat = 200,
        lineWidth: CGFloat = 20,
        showDetails: Bool = true
    ) {
        self.score = max(0, min(1, score))
        self.size = size
        self.lineWidth = lineWidth
        self.showDetails = showDetails
    }

    var body: some View {
        ZStack {
            backgroundRing

            progressRing

            if showDetails {
                centerContent
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimation()
        }
        .onChange(of: score) { newScore in
            updateScore(newScore)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityValue(String(format: "%.0f%%", score * 100))
    }

    private var backgroundRing: some View {
        Circle()
            .stroke(
                ColorPalette.gray100,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
    }

    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: animatedScore)
            .stroke(
                scoreGradient,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .scaleEffect(pulseAnimation ? 1.02 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: pulseAnimation
            )
    }

    private var centerContent: some View {
        VStack(spacing: Spacing.xs) {
            scoreText

            statusText
        }
    }

    private var scoreText: some View {
        Text(formattedScore)
            .font(Typography.hero.font)
            .fontWeight(.bold)
            .foregroundColor(scoreColor)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedScore)
            .accessibilityIdentifier("health_score_value")
    }

    private var statusText: some View {
        Text(scoreStatusText)
            .captionStyle()
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("health_score_status")
    }

    // MARK: - Computed Properties

    private var formattedScore: String {
        String(format: "%.0f", animatedScore * 100)
    }

    private var scoreGradient: LinearGradient {
        LinearGradient(
            colors: scoreGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var scoreGradientColors: [Color] {
        switch score {
        case 0.8 ... 1.0:
            return [ColorPalette.success, ColorPalette.success.opacity(0.8)]
        case 0.6 ..< 0.8:
            return [ColorPalette.warning, ColorPalette.warning.opacity(0.8)]
        case 0.4 ..< 0.6:
            return [ColorPalette.warning.opacity(0.8), ColorPalette.error.opacity(0.8)]
        default:
            return [ColorPalette.error, ColorPalette.error.opacity(0.8)]
        }
    }

    private var scoreColor: Color {
        switch score {
        case 0.8 ... 1.0:
            return ColorPalette.success
        case 0.6 ..< 0.8:
            return ColorPalette.warning
        default:
            return ColorPalette.error
        }
    }

    private var scoreStatusText: String {
        switch score {
        case 0.9 ... 1.0:
            return NSLocalizedString("health_excellent", comment: "Excellent")
        case 0.8 ..< 0.9:
            return NSLocalizedString("health_very_good", comment: "Very Good")
        case 0.7 ..< 0.8:
            return NSLocalizedString("health_good", comment: "Good")
        case 0.6 ..< 0.7:
            return NSLocalizedString("health_fair", comment: "Fair")
        case 0.4 ..< 0.6:
            return NSLocalizedString("health_needs_improvement", comment: "Needs Improvement")
        default:
            return NSLocalizedString("health_poor", comment: "Poor")
        }
    }

    private var accessibilityDescription: String {
        return NSLocalizedString("health_score_accessibility", comment: "Health score ring")
    }

    // MARK: - Animation Methods

    private func startAnimation() {
        // Delay initial animation for dramatic effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: AnimationDuration.extended)) {
                animatedScore = score
            }

            // Start pulse animation after main animation
            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDuration.extended + 0.3) {
                pulseAnimation = true

                // Haptic feedback for completion
                HapticFeedback.success.trigger()
            }
        }
    }

    private func updateScore(_ newScore: Double) {
        let clampedScore = max(0, min(1, newScore))

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animatedScore = clampedScore
        }

        // Haptic feedback for score change
        if abs(clampedScore - score) > 0.1 {
            HapticFeedback.light.trigger()
        }
    }
}

// MARK: - Compact Version

struct CompactHealthScoreRing: View {
    let score: Double
    let size: CGFloat

    init(score: Double, size: CGFloat = 60) {
        self.score = max(0, min(1, score))
        self.size = size
    }

    var body: some View {
        HealthScoreRing(
            score: score,
            size: size,
            lineWidth: size * 0.15,
            showDetails: false
        )
        .overlay(
            Text(String(format: "%.0f", score * 100))
                .font(.system(size: size * 0.25, weight: .semibold, design: .rounded))
                .foregroundColor(scoreColor)
        )
    }

    private var scoreColor: Color {
        switch score {
        case 0.8 ... 1.0: return ColorPalette.success
        case 0.6 ..< 0.8: return ColorPalette.warning
        default: return ColorPalette.error
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct HealthScoreRing_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: Spacing.xl) {
                HealthScoreRing(score: 0.85)

                HStack(spacing: Spacing.lg) {
                    CompactHealthScoreRing(score: 0.85)
                    CompactHealthScoreRing(score: 0.65)
                    CompactHealthScoreRing(score: 0.35)
                }
            }
            .padding()
            .background(ColorPalette.primaryBackground)
            .previewDisplayName("Health Score Rings")
        }
    }
#endif
