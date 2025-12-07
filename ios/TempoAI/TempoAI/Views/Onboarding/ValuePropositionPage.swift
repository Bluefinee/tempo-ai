import SwiftUI

/// Interactive value proposition page with feature carousel and demos
struct ValuePropositionPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var currentFeature: Int = 0
    @State private var autoScrollTimer: Timer?
    @State private var isInteracting: Bool = false
    @State private var featuresOpacity: Double = 0.0
    @State private var demoViewOpacity: Double = 0.0

    private let features: [HealthFeature] = [
        HealthFeature(
            icon: "heart.text.square.fill",
            title: NSLocalizedString("feature_analysis_title", comment: "AI Health Analysis"),
            description: NSLocalizedString(
                "feature_analysis_desc", comment: "Get personalized insights from your health data"),
            color: ColorPalette.error,
            demoType: .healthAnalysis
        ),
        HealthFeature(
            icon: "cloud.sun.fill",
            title: NSLocalizedString("feature_weather_title", comment: "Weather-Adaptive Advice"),
            description: NSLocalizedString(
                "feature_weather_desc", comment: "Recommendations that adapt to today's weather"),
            color: ColorPalette.info,
            demoType: .weatherAdaptive
        ),
        HealthFeature(
            icon: "sparkles",
            title: NSLocalizedString("feature_personalization_title", comment: "Smart Personalization"),
            description: NSLocalizedString(
                "feature_personalization_desc", comment: "AI learns your preferences and lifestyle"),
            color: ColorPalette.warning,
            demoType: .personalization
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            featureCarousel

            interactiveDemoSection

            actionButtonsSection
        }
        .background(ColorPalette.primaryBackground)
        .onAppear {
            startInitialAnimation()
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Text(NSLocalizedString("discover_features", comment: "Discover TempoAI"))
                .font(Typography.title.font)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.richBlack)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("value_proposition_subtitle", comment: "Your personalized health companion"))
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
        .opacity(featuresOpacity)
    }

    // MARK: - Feature Carousel

    private var featureCarousel: some View {
        VStack(spacing: Spacing.lg) {
            // Feature cards
            TabView(selection: $currentFeature) {
                ForEach(features.indices, id: \.self) { index in
                    FeatureCard(feature: features[index])
                        .tag(index)
                        .onTapGesture {
                            handleFeatureInteraction()
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)

            // Custom page indicator
            PageIndicator(
                currentPage: currentFeature,
                totalPages: features.count,
                activeColor: features[currentFeature].color
            )
        }
        .opacity(featuresOpacity)
        .onChange(of: currentFeature) { _ in
            handleFeatureChange()
        }
    }

    // MARK: - Interactive Demo Section

    private var interactiveDemoSection: some View {
        VStack(spacing: Spacing.md) {
            Text(NSLocalizedString("see_it_in_action", comment: "See it in action"))
                .font(Typography.headline.font)
                .fontWeight(.medium)
                .foregroundColor(ColorPalette.richBlack)

            InteractiveDemoView(demoType: features[currentFeature].demoType)
                .frame(height: 180)
                .cornerRadius(CornerRadius.lg)
                .elevation(.medium)
        }
        .padding(.horizontal, Spacing.lg)
        .opacity(demoViewOpacity)
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        VStack(spacing: Spacing.md) {
            PrimaryButton(NSLocalizedString("get_started", comment: "Get Started")) {
                onContinue()
            }

            TextButton(NSLocalizedString("skip_for_now", comment: "Skip for now")) {
                onSkip()
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
        .opacity(demoViewOpacity)
    }

    // MARK: - Animation Methods

    private func startInitialAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            featuresOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            demoViewOpacity = 1.0
        }
    }

    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if !isInteracting {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentFeature = (currentFeature + 1) % features.count
                }
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    private func handleFeatureInteraction() {
        HapticFeedback.light.trigger()
        isInteracting = true

        // Resume auto-scroll after 8 seconds of no interaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            isInteracting = false
        }
    }

    private func handleFeatureChange() {
        HapticFeedback.selection.trigger()
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let feature: HealthFeature
    @State private var isHovered: Bool = false

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isHovered ? 1.1 : 1.0)

                Image(systemName: feature.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(feature.color)
            }

            VStack(spacing: Spacing.sm) {
                Text(feature.title)
                    .font(Typography.headline.font)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text(feature.description)
                    .font(Typography.body.font)
                    .foregroundColor(ColorPalette.gray500)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(ColorPalette.offWhite)
        .cornerRadius(CornerRadius.lg)
        .elevation(.low)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isHovered = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isHovered = false
                }
            }
        }
    }
}

// MARK: - Interactive Demo View

struct InteractiveDemoView: View {
    let demoType: DemoType
    @State private var animationProgress: Double = 0.0

    var body: some View {
        ZStack {
            ColorPalette.pearl.opacity(0.5)

            Group {
                switch demoType {
                case .healthAnalysis:
                    HealthAnalysisDemoView(progress: animationProgress)
                case .weatherAdaptive:
                    WeatherAdaptiveDemoView(progress: animationProgress)
                case .personalization:
                    PersonalizationDemoView(progress: animationProgress)
                }
            }
        }
        .onAppear {
            startDemoAnimation()
        }
    }

    private func startDemoAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animationProgress = 1.0
        }
    }
}

// MARK: - Demo Views

struct HealthAnalysisDemoView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    CompactHealthScoreRing(
                        score: 0.3 + (progress * 0.5),
                        size: 40
                    )
                }
            }

            Text("AI analyzing your health data...")
                .font(Typography.caption.font)
                .foregroundColor(ColorPalette.gray500)
        }
    }
}

struct WeatherAdaptiveDemoView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.lg) {
                Image(systemName: progress > 0.5 ? "sun.max.fill" : "cloud.rain.fill")
                    .font(.system(size: 32))
                    .foregroundColor(progress > 0.5 ? .orange : .blue)

                Text("→")
                    .font(.title2)
                    .foregroundColor(ColorPalette.gray300)

                Text(progress > 0.5 ? "☀️ Perfect day for outdoor exercise!" : "🌧️ Indoor yoga recommended")
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray700)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct PersonalizationDemoView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("Learning...")
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray500)

                ProgressRing(
                    progress: progress,
                    lineWidth: 3,
                    color: ColorPalette.warning
                )
                .frame(width: 20, height: 20)
            }

            Text("Personalizing recommendations")
                .font(Typography.footnote.font)
                .foregroundColor(ColorPalette.gray400)
        }
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    let activeColor: Color

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? activeColor : ColorPalette.gray300)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
            }
        }
    }
}

// MARK: - Supporting Types

struct HealthFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let demoType: DemoType
}

enum DemoType {
    case healthAnalysis
    case weatherAdaptive
    case personalization
}

// MARK: - Preview

#if DEBUG
    struct ValuePropositionPage_Previews: PreviewProvider {
        static var previews: some View {
            ValuePropositionPage(
                onContinue: { print("Continue") },
                onSkip: { print("Skip") }
            )
            .previewDisplayName("Value Proposition")
        }
    }
#endif
