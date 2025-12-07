import SwiftUI

/// Enhanced advice card with Progressive Disclosure and microinteractions
struct EnhancedAdviceCard: View {
    let advice: DailyAdvice
    let priority: AdvicePriority
    let onAction: ((AdviceAction) -> Void)?

    @State private var isExpanded: Bool = false
    @State private var isPressed: Bool = false
    @State private var completionProgress: Double = 0

    init(
        advice: DailyAdvice,
        priority: AdvicePriority = .normal,
        onAction: ((AdviceAction) -> Void)? = nil
    ) {
        self.advice = advice
        self.priority = priority
        self.onAction = onAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            if isExpanded {
                expandedContent
            }
        }
        .background(backgroundColor)
        .cornerRadius(CornerRadius.md)
        .elevation(isPressed ? .low : cardElevation)
        .scaleEffect(isPressed ? ScaleEffect.active : 1.0)
        .animation(AnimationPresets.cardExpansion, value: isExpanded)
        .animation(AnimationPresets.buttonPress, value: isPressed)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("enhanced_advice_card_\(advice.category.rawValue)")
    }

    // MARK: - Header Section

    private var headerSection: some View {
        Button(action: toggleExpansion) {
            HStack(spacing: Spacing.sm) {
                categoryIcon

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    titleText
                    summaryText
                }

                Spacer(minLength: Spacing.xs)

                headerActions
            }
            .padding(Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
            // Never triggered
        } onPressingChanged: { pressing in
            withAnimation(AnimationPresets.buttonPress) {
                isPressed = pressing
            }
        }
    }

    private var categoryIcon: some View {
        Image(systemName: advice.category.icon)
            .font(.system(size: LayoutConstants.IconSize.medium, weight: .semibold))
            .foregroundColor(advice.category.color)
            .frame(width: 44, height: 44)
            .background(advice.category.color.opacity(0.1))
            .cornerRadius(CornerRadius.sm)
            .accessibilityHidden(true)
    }

    private var titleText: some View {
        Text(advice.title)
            .headlineStyle()
            .lineLimit(2)
            .accessibilityIdentifier("advice_card_title")
    }

    private var summaryText: some View {
        Text(advice.summary)
            .bodyStyle()
            .lineLimit(isExpanded ? nil : 2)
            .accessibilityIdentifier("advice_card_summary")
    }

    private var headerActions: some View {
        VStack(spacing: Spacing.xs) {
            priorityIndicator

            expandIcon
        }
    }

    private var priorityIndicator: some View {
        Group {
            if priority == .high {
                Circle()
                    .fill(ColorPalette.error)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel(NSLocalizedString("high_priority", comment: "High priority"))
            } else if completionProgress > 0 {
                CompactProgressRing(progress: completionProgress, size: 20)
                    .accessibilityLabel(NSLocalizedString("completion_progress", comment: "Completion progress"))
            }
        }
    }

    private var expandIcon: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(ColorPalette.gray500)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .accessibilityHidden(true)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Divider()
                .background(ColorPalette.gray100)
                .padding(.horizontal, Spacing.md)

            if !advice.details.isEmpty {
                detailsSection
            }

            if !advice.tips.isEmpty {
                tipsSection
            }

            if let weatherImpact = advice.weatherImpact {
                weatherSection(weatherImpact)
            }

            actionButtons
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: NSLocalizedString("details", comment: "Details"))

            ForEach(advice.details.prefix(3), id: \.self) { detail in
                DetailRow(text: detail)
            }

            if advice.details.count > 3 {
                Button(action: { showMoreDetails() }) {
                    Text(NSLocalizedString("show_more", comment: "Show more"))
                        .captionStyle()
                        .foregroundColor(ColorPalette.info)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: NSLocalizedString("tips", comment: "Tips"))

            ForEach(advice.tips.prefix(2), id: \.self) { tip in
                TipRow(text: tip)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func weatherSection(_ impact: String) -> some View {
        InfoCard(
            title: NSLocalizedString("weather_impact", comment: "Weather Impact"),
            message: impact,
            type: .info
        )
        .padding(.horizontal, Spacing.md)
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.sm) {
            SecondaryButton(NSLocalizedString("remind_later", comment: "Remind Later")) {
                handleAction(.remindLater)
            }

            PrimaryButton(NSLocalizedString("mark_complete", comment: "Mark Complete")) {
                handleAction(.markComplete)
            }
        }
        .padding(Spacing.md)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        switch priority {
        case .high:
            return ColorPalette.errorBackground
        case .normal:
            return ColorPalette.offWhite
        case .low:
            return ColorPalette.pearl
        }
    }

    private var cardElevation: Elevation {
        switch priority {
        case .high: return .medium
        case .normal: return .low
        case .low: return .none
        }
    }

    // MARK: - Actions

    private func toggleExpansion() {
        withAnimation(AnimationPresets.cardExpansion) {
            isExpanded.toggle()
        }

        HapticFeedback.light.trigger()
    }

    private func handleAction(_ action: AdviceAction) {
        HapticFeedback.success.trigger()
        onAction?(action)

        if action == .markComplete {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                completionProgress = 1.0
            }
        }
    }

    private func showMoreDetails() {
        onAction?(.showDetails)
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .captionStyle()
            .fontWeight(.medium)
            .foregroundColor(ColorPalette.gray700)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

struct DetailRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundColor(ColorPalette.gray300)
                .padding(.top, Spacing.xs)

            Text(text)
                .bodyStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundColor(ColorPalette.warning)
                .padding(.top, 2)

            Text(text)
                .bodyStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CompactProgressRing: View {
    let progress: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.gray100, lineWidth: 2)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ColorPalette.success, lineWidth: 2)
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Enums

enum AdvicePriority {
    case high
    case normal
    case low
}

enum AdviceAction {
    case markComplete
    case remindLater
    case showDetails
}

// Extensions are now defined in Models.swift

// MARK: - Preview

#if DEBUG
    struct EnhancedAdviceCard_Previews: PreviewProvider {
        static let sampleAdvice = DailyAdvice(
            theme: "Morning Walk Recommendation",
            summary:
                "Take a 20-minute walk to boost your energy and mood. Walking increases cardiovascular health, morning sunlight helps regulate circadian rhythm, and light exercise improves mental clarity.",
            breakfast: MealAdvice(
                recommendation: "Light breakfast before walk",
                reason: "Provides energy without heaviness",
                examples: ["Banana", "Toast"],
                timing: "30 minutes before",
                avoid: ["Heavy meals"]
            ),
            lunch: MealAdvice(
                recommendation: "Balanced lunch",
                reason: "Replenish energy after activity",
                examples: ["Salad", "Lean protein"],
                timing: "1-2 hours post walk",
                avoid: ["Processed foods"]
            ),
            dinner: MealAdvice(
                recommendation: "Light dinner",
                reason: "Easy digestion for sleep",
                examples: ["Soup", "Vegetables"],
                timing: "3 hours before bed",
                avoid: ["Spicy foods"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "20-minute brisk walk",
                intensity: .moderate,
                reason: "Improves cardiovascular health",
                timing: "Morning",
                avoid: ["Overexertion"]
            ),
            hydration: HydrationAdvice(
                target: "2 liters",
                schedule: HydrationSchedule(
                    morning: "500ml upon waking",
                    afternoon: "750ml during activity",
                    evening: "750ml before dinner"
                ),
                reason: "Maintains energy and performance"
            ),
            breathing: BreathingAdvice(
                technique: "Deep breathing during walk",
                duration: "5 minutes",
                frequency: "Throughout exercise",
                instructions: ["Inhale through nose", "Exhale through mouth"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "10:00 PM",
                routine: ["Gentle stretching", "Reading"],
                avoid: ["Screen time", "Caffeine"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: [],
                opportunities: ["Perfect weather for outdoor activities", "Enjoy the sunshine"]
            ),
            priorityActions: [
                "Choose a route with natural scenery",
                "Maintain a comfortable pace",
                "Stay hydrated",
            ]
        )

        static var previews: some View {
            VStack(spacing: Spacing.lg) {
                EnhancedAdviceCard(
                    advice: sampleAdvice,
                    priority: .high
                ) { action in
                    print("Action: \(action)")
                }

                EnhancedAdviceCard(
                    advice: sampleAdvice,
                    priority: .normal
                ) { action in
                    print("Action: \(action)")
                }
            }
            .padding()
            .background(ColorPalette.primaryBackground)
            .previewDisplayName("Enhanced Advice Cards")
        }
    }
#endif
