import SwiftUI

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