import SwiftUI

/// Personalization page for health goals and preferences
struct PersonalizationPage: View {
    @Binding var healthGoal: HealthGoal
    @Binding var notificationTime: Date
    @Binding var activityLevel: ActivityLevel
    @Binding var interests: Set<HealthInterest>

    let onContinue: () -> Void
    let onBack: () -> Void

    @State private var contentOpacity: Double = 0.0
    @State private var currentStep: Int = 0
    @State private var showingTimePicker: Bool = false

    private let totalSteps: Int = 4

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            progressSection

            ScrollView {
                LazyVStack(spacing: Spacing.xl) {
                    Group {
                        switch currentStep {
                        case 0:
                            healthGoalSection
                        case 1:
                            activityLevelSection
                        case 2:
                            interestsSection
                        case 3:
                            notificationSection
                        default:
                            EmptyView()
                        }
                    }
                    .opacity(contentOpacity)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }

            navigationButtonsSection
        }
        .background(ColorPalette.primaryBackground)
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Text(NSLocalizedString("personalize_experience", comment: "Personalize Your Experience"))
                .font(Typography.title.font)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.richBlack)

            Text(stepSubtitle)
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: Spacing.sm) {
            ProgressRing(
                progress: Double(currentStep + 1) / Double(totalSteps),
                lineWidth: 4,
                color: ColorPalette.info
            )
            .frame(width: 60, height: 60)

            Text("\(currentStep + 1) / \(totalSteps)")
                .font(Typography.caption.font)
                .foregroundColor(ColorPalette.gray500)
        }
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Content Sections

    private var healthGoalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTitle(
                icon: "target",
                title: NSLocalizedString("health_goal_title", comment: "What's your main health goal?")
            )

            LazyVGrid(columns: gridColumns, spacing: Spacing.md) {
                ForEach(HealthGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: healthGoal == goal
                    ) {
                        selectHealthGoal(goal)
                    }
                }
            }
        }
    }

    private var activityLevelSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTitle(
                icon: "figure.walk.motion",
                title: NSLocalizedString("activity_level_title", comment: "How active are you?")
            )

            VStack(spacing: Spacing.md) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    ActivityLevelCard(
                        level: level,
                        isSelected: activityLevel == level
                    ) {
                        selectActivityLevel(level)
                    }
                }
            }
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTitle(
                icon: "heart.fill",
                title: NSLocalizedString("interests_title", comment: "What interests you most?"),
                subtitle: NSLocalizedString("interests_subtitle", comment: "Select all that apply")
            )

            LazyVGrid(columns: gridColumns, spacing: Spacing.md) {
                ForEach(HealthInterest.allCases, id: \.self) { interest in
                    InterestChip(
                        interest: interest,
                        isSelected: interests.contains(interest)
                    ) {
                        toggleInterest(interest)
                    }
                }
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTitle(
                icon: "bell.fill",
                title: NSLocalizedString("notification_time_title", comment: "When would you like daily reminders?")
            )

            VStack(spacing: Spacing.md) {
                NotificationTimeCard(
                    time: notificationTime,
                    onTap: {
                        showingTimePicker = true
                    }
                )

                if showingTimePicker {
                    Card {
                        DatePicker(
                            "",
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                NotificationToggleCard()
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtonsSection: some View {
        HStack(spacing: Spacing.md) {
            if currentStep > 0 {
                SecondaryButton(NSLocalizedString("back", comment: "Back")) {
                    goToPreviousStep()
                }
            }

            PrimaryButton(
                currentStep == totalSteps - 1
                    ? NSLocalizedString("finish_setup", comment: "Finish Setup")
                    : NSLocalizedString("next", comment: "Next")
            ) {
                goToNextStep()
            }
            .disabled(!isCurrentStepValid)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
        .background(ColorPalette.primaryBackground)
    }

    // MARK: - Computed Properties

    private var stepSubtitle: String {
        switch currentStep {
        case 0: return NSLocalizedString("goal_subtitle", comment: "Help us understand your priorities")
        case 1: return NSLocalizedString("activity_subtitle", comment: "We'll adjust recommendations accordingly")
        case 2: return NSLocalizedString("interests_subtitle_detail", comment: "Focus on what matters to you")
        case 3: return NSLocalizedString("notification_subtitle", comment: "Stay on track with gentle reminders")
        default: return ""
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md),
        ]
    }

    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return healthGoal != .none
        case 1: return activityLevel != .none
        case 2: return !interests.isEmpty
        case 3: return true
        default: return false
        }
    }

    // MARK: - Methods

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.6)) {
            contentOpacity = 1.0
        }
    }

    private func selectHealthGoal(_ goal: HealthGoal) {
        HapticFeedback.selection.trigger()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            healthGoal = goal
        }
    }

    private func selectActivityLevel(_ level: ActivityLevel) {
        HapticFeedback.selection.trigger()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            activityLevel = level
        }
    }

    private func toggleInterest(_ interest: HealthInterest) {
        HapticFeedback.light.trigger()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if interests.contains(interest) {
                interests.remove(interest)
            } else {
                interests.insert(interest)
            }
        }
    }

    private func goToNextStep() {
        HapticFeedback.light.trigger()

        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                contentOpacity = 0.0
                currentStep += 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    contentOpacity = 1.0
                }
            }
        } else {
            onContinue()
        }
    }

    private func goToPreviousStep() {
        HapticFeedback.light.trigger()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            contentOpacity = 0.0
            currentStep -= 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Supporting Views

struct SectionTitle: View {
    let icon: String
    let title: String
    let subtitle: String?

    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ColorPalette.info)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }
            }

            Spacer()
        }
    }
}

struct GoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: goal.icon)
                    .font(.system(size: 32))
                    .foregroundColor(goal.color)

                Text(goal.title)
                    .font(Typography.callout.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ColorPalette.success)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .background(isSelected ? ColorPalette.successBackground : ColorPalette.offWhite)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isSelected ? ColorPalette.success : ColorPalette.gray100, lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: level.icon)
                    .font(.system(size: 24))
                    .foregroundColor(level.color)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(level.title)
                        .font(Typography.callout.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Text(level.description)
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ColorPalette.success)
                }
            }
        }
    }
}

struct InterestChip: View {
    let interest: HealthInterest
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: interest.icon)
                    .font(.system(size: 16))

                Text(interest.title)
                    .font(Typography.footnote.font)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? ColorPalette.pureWhite : ColorPalette.richBlack)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? ColorPalette.info : ColorPalette.offWhite)
            .cornerRadius(CornerRadius.pill(height: 32))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.pill(height: 32))
                    .stroke(isSelected ? ColorPalette.info : ColorPalette.gray100, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct NotificationTimeCard: View {
    let time: Date
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 20))
                    .foregroundColor(ColorPalette.info)

                Text(DateFormatter.timeOnly.string(from: time))
                    .font(Typography.headline.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)

                Spacer()

                Text(NSLocalizedString("tap_to_change", comment: "Tap to change"))
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray500)

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.gray300)
            }
        }
    }
}

struct NotificationToggleCard: View {
    @State private var isEnabled: Bool = true

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(NSLocalizedString("enable_notifications", comment: "Enable notifications"))
                        .font(Typography.callout.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Text(NSLocalizedString("notification_help", comment: "You can change this in Settings later"))
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .toggleStyle(SwitchToggleStyle())
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Data Types

enum HealthGoal: CaseIterable {
    case none, weightLoss, muscleGain, generalFitness, stressReduction, betterSleep, heartHealth

    var title: String {
        switch self {
        case .none: return ""
        case .weightLoss: return NSLocalizedString("goal_weight_loss", comment: "Weight Loss")
        case .muscleGain: return NSLocalizedString("goal_muscle_gain", comment: "Muscle Gain")
        case .generalFitness: return NSLocalizedString("goal_general_fitness", comment: "General Fitness")
        case .stressReduction: return NSLocalizedString("goal_stress_reduction", comment: "Stress Reduction")
        case .betterSleep: return NSLocalizedString("goal_better_sleep", comment: "Better Sleep")
        case .heartHealth: return NSLocalizedString("goal_heart_health", comment: "Heart Health")
        }
    }

    var icon: String {
        switch self {
        case .none: return ""
        case .weightLoss: return "scalemass"
        case .muscleGain: return "dumbbell"
        case .generalFitness: return "figure.run"
        case .stressReduction: return "leaf"
        case .betterSleep: return "bed.double"
        case .heartHealth: return "heart"
        }
    }

    var color: Color {
        switch self {
        case .none: return ColorPalette.gray300
        case .weightLoss: return ColorPalette.error
        case .muscleGain: return ColorPalette.success
        case .generalFitness: return ColorPalette.info
        case .stressReduction: return ColorPalette.warning
        case .betterSleep: return ColorPalette.gray700
        case .heartHealth: return Color.red
        }
    }
}

enum ActivityLevel: CaseIterable {
    case none, sedentary, lightlyActive, moderatelyActive, veryActive, extremelyActive

    var title: String {
        switch self {
        case .none: return ""
        case .sedentary: return NSLocalizedString("activity_sedentary", comment: "Sedentary")
        case .lightlyActive: return NSLocalizedString("activity_lightly_active", comment: "Lightly Active")
        case .moderatelyActive: return NSLocalizedString("activity_moderately_active", comment: "Moderately Active")
        case .veryActive: return NSLocalizedString("activity_very_active", comment: "Very Active")
        case .extremelyActive: return NSLocalizedString("activity_extremely_active", comment: "Extremely Active")
        }
    }

    var description: String {
        switch self {
        case .none: return ""
        case .sedentary: return NSLocalizedString("activity_sedentary_desc", comment: "Little to no exercise")
        case .lightlyActive:
            return NSLocalizedString("activity_lightly_active_desc", comment: "Light exercise 1-3 days/week")
        case .moderatelyActive:
            return NSLocalizedString("activity_moderately_active_desc", comment: "Moderate exercise 3-5 days/week")
        case .veryActive: return NSLocalizedString("activity_very_active_desc", comment: "Hard exercise 6-7 days/week")
        case .extremelyActive:
            return NSLocalizedString("activity_extremely_active_desc", comment: "Very hard exercise, physical job")
        }
    }

    var icon: String {
        switch self {
        case .none: return ""
        case .sedentary: return "figure.seated.side"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.run"
        case .veryActive: return "figure.strengthtraining.traditional"
        case .extremelyActive: return "bolt"
        }
    }

    var color: Color {
        switch self {
        case .none: return ColorPalette.gray300
        case .sedentary: return ColorPalette.gray500
        case .lightlyActive: return ColorPalette.warning.opacity(0.7)
        case .moderatelyActive: return ColorPalette.warning
        case .veryActive: return ColorPalette.success
        case .extremelyActive: return ColorPalette.error
        }
    }
}

enum HealthInterest: CaseIterable {
    case nutrition, exercise, sleep, mentalHealth, heartHealth, weightManagement

    var title: String {
        switch self {
        case .nutrition: return NSLocalizedString("interest_nutrition", comment: "Nutrition")
        case .exercise: return NSLocalizedString("interest_exercise", comment: "Exercise")
        case .sleep: return NSLocalizedString("interest_sleep", comment: "Sleep")
        case .mentalHealth: return NSLocalizedString("interest_mental_health", comment: "Mental Health")
        case .heartHealth: return NSLocalizedString("interest_heart_health", comment: "Heart Health")
        case .weightManagement: return NSLocalizedString("interest_weight_management", comment: "Weight Management")
        }
    }

    var icon: String {
        switch self {
        case .nutrition: return "fork.knife"
        case .exercise: return "figure.run"
        case .sleep: return "bed.double"
        case .mentalHealth: return "brain.head.profile"
        case .heartHealth: return "heart"
        case .weightManagement: return "scalemass"
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct PersonalizationPage_Previews: PreviewProvider {
        @State static var healthGoal: HealthGoal = .generalFitness
        @State static var notificationTime: Date = Date()
        @State static var activityLevel: ActivityLevel = .moderatelyActive
        @State static var interests: Set<HealthInterest> = [.exercise, .nutrition]

        static var previews: some View {
            PersonalizationPage(
                healthGoal: $healthGoal,
                notificationTime: $notificationTime,
                activityLevel: $activityLevel,
                interests: $interests,
                onContinue: { print("Continue") },
                onBack: { print("Back") }
            )
            .previewDisplayName("Personalization Page")
        }
    }
#endif
