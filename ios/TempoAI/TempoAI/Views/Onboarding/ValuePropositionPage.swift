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
    @State private var resumeAutoScrollWorkItem: DispatchWorkItem?

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
            resumeAutoScrollWorkItem?.cancel()
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

        // Cancel any existing work item to ensure proper debouncing
        resumeAutoScrollWorkItem?.cancel()

        // Resume auto-scroll after 8 seconds of no interaction
        let workItem = DispatchWorkItem {
            isInteracting = false
        }
        resumeAutoScrollWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: workItem)
    }

    private func handleFeatureChange() {
        HapticFeedback.selection.trigger()
    }
}
