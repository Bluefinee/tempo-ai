import SwiftUI
import UIKit

/// Celebration page with completion animation and motivational message
struct CelebrationPage: View {
    let userPreferences: UserPreferences
    let onComplete: () -> Void

    @State private var celebrationPhase: CelebrationPhase = .initial
    @State private var confettiOpacity: Double = 0.0
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var messageOpacity: Double = 0.0
    @State private var buttonOpacity: Double = 0.0
    @State private var personalizedMessageOpacity: Double = 0.0

    private let animationDuration: Double = 0.6
    private let staggerDelay: Double = 0.3

    var body: some View {
        ZStack {
            backgroundGradient

            if celebrationPhase != .initial {
                confettiLayer
            }

            VStack(spacing: Spacing.xl) {
                Spacer()

                celebrationIcon

                titleSection

                personalizedMessageSection

                Spacer()

                actionSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .onAppear {
            startCelebrationSequence()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("setup_complete", comment: "Setup complete"))
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                ColorPalette.primaryBackground,
                ColorPalette.successBackground.opacity(0.3),
                ColorPalette.primaryBackground,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Confetti Layer

    private var confettiLayer: some View {
        ZStack {
            ForEach(0 ..< 12, id: \.self) { index in
                ConfettiParticle(
                    color: confettiColors[index % confettiColors.count],
                    delay: Double(index) * 0.1
                )
            }
        }
        .opacity(confettiOpacity)
    }

    private var confettiColors: [Color] {
        [
            ColorPalette.success,
            ColorPalette.info,
            ColorPalette.warning,
            ColorPalette.error.opacity(0.8),
        ]
    }

    // MARK: - Celebration Icon

    private var celebrationIcon: some View {
        ZStack {
            // Outer ring animation
            Circle()
                .stroke(ColorPalette.success.opacity(0.3), lineWidth: 4)
                .frame(width: 140, height: 140)
                .scaleEffect(celebrationPhase == .completed ? 1.2 : 1.0)
                .opacity(celebrationPhase == .completed ? 0.0 : 1.0)
                .animation(.easeOut(duration: 1.5), value: celebrationPhase)

            // Inner circle
            Circle()
                .fill(ColorPalette.success)
                .frame(width: 120, height: 120)
                .scaleEffect(checkmarkScale)

            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(ColorPalette.pureWhite)
                .scaleEffect(checkmarkScale)
        }
        .accessibilityIdentifier("celebration_checkmark")
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: Spacing.sm) {
            Text(NSLocalizedString("congratulations", comment: "Congratulations!"))
                .font(Typography.hero.font)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.richBlack)
                .opacity(titleOpacity)
                .accessibilityIdentifier("celebration_title")

            Text(NSLocalizedString("setup_complete_message", comment: "Your health journey begins now"))
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
                .opacity(messageOpacity)
                .accessibilityIdentifier("celebration_subtitle")
        }
    }

    // MARK: - Personalized Message

    private var personalizedMessageSection: some View {
        Card {
            VStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(ColorPalette.warning)

                    Text(NSLocalizedString("personalized_for_you", comment: "Personalized for you"))
                        .font(Typography.headline.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    PersonalizedInsight(
                        icon: userPreferences.healthGoal.icon,
                        text: String(
                            format: NSLocalizedString("goal_insight", comment: "Focused on %@"),
                            userPreferences.healthGoal.title),
                        color: userPreferences.healthGoal.color
                    )

                    PersonalizedInsight(
                        icon: userPreferences.activityLevel.icon,
                        text: String(
                            format: NSLocalizedString("activity_insight", comment: "%@ lifestyle adapted"),
                            userPreferences.activityLevel.title),
                        color: userPreferences.activityLevel.color
                    )

                    if !userPreferences.interests.isEmpty {
                        PersonalizedInsight(
                            icon: "heart.fill",
                            text: String(
                                format: NSLocalizedString("interests_insight", comment: "%d focus areas selected"),
                                userPreferences.interests.count),
                            color: ColorPalette.info
                        )
                    }
                }
            }
        }
        .opacity(personalizedMessageOpacity)
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: Spacing.md) {
            PrimaryButton(NSLocalizedString("start_your_journey", comment: "Start Your Journey")) {
                completeOnboarding()
            }
            .opacity(buttonOpacity)

            Text(NSLocalizedString("journey_motivation", comment: "Every small step counts towards a healthier you"))
                .font(Typography.caption.font)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
                .opacity(buttonOpacity)
        }
    }

    // MARK: - Animation Methods

    private func startCelebrationSequence() {
        // Phase 1: Checkmark appears
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
            checkmarkScale = 1.0
            celebrationPhase = .checkmarkAppeared
        }

        // Phase 2: Confetti and title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            HapticFeedback.success.trigger()

            withAnimation(.easeOut(duration: animationDuration)) {
                confettiOpacity = 1.0
                titleOpacity = 1.0
                celebrationPhase = .confettiStarted
            }
        }

        // Phase 3: Message appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: animationDuration)) {
                messageOpacity = 1.0
            }
        }

        // Phase 4: Personalized section
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: animationDuration)) {
                personalizedMessageOpacity = 1.0
            }
        }

        // Phase 5: Button appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeOut(duration: animationDuration)) {
                buttonOpacity = 1.0
                celebrationPhase = .completed
            }
        }
    }

    private func completeOnboarding() {
        HapticFeedback.success.trigger()

        // Brief scale animation for button feedback
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            checkmarkScale = 1.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                checkmarkScale = 1.0
            }
        }

        // Complete onboarding after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete()
        }
    }
}

// MARK: - Supporting Views

struct PersonalizedInsight: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(Typography.callout.font)
                .foregroundColor(ColorPalette.gray700)

            Spacer()
        }
    }
}

struct ConfettiParticle: View {
    let color: Color
    let delay: Double

    @State private var yOffset: CGFloat = -50
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                startAnimation()
            }
    }

    private func startAnimation() {
        let randomX = CGFloat.random(in: -150 ... 150)
        let randomRotation = Double.random(in: 0 ... 360)
        let randomScale = CGFloat.random(in: 0.5 ... 1.5)

        withAnimation(
            .easeOut(duration: 2.0)
                .delay(delay)
        ) {
            yOffset = UIScreen.main.bounds.height + 100
            xOffset = randomX
            scale = randomScale
        }

        withAnimation(
            .linear(duration: 2.0)
                .delay(delay)
        ) {
            rotation = randomRotation
        }

        withAnimation(
            .easeIn(duration: 0.5)
                .delay(delay + 1.5)
        ) {
            opacity = 0
        }
    }
}

// MARK: - Data Types

enum CelebrationPhase {
    case initial
    case checkmarkAppeared
    case confettiStarted
    case completed
}

struct OnboardingPreferences {
    let healthGoal: HealthGoal
    let activityLevel: ActivityLevel
    let interests: Set<HealthInterest>
    let notificationTime: Date
}

// MARK: - Preview

#if DEBUG
    struct CelebrationPage_Previews: PreviewProvider {
        static let mockPreferences = UserPreferences(
            notificationFrequency: .daily,
            analysisDetailLevel: .balanced,
            recommendationStyle: .encouraging,
            privacyLevel: .standard
        )

        static var previews: some View {
            CelebrationPage(
                userPreferences: mockPreferences
            ) {
                print("Onboarding completed!")
            }
            .previewDisplayName("Celebration Page")
        }
    }
#endif
