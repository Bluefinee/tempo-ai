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

            Text("\\(currentStep + 1) / \\(totalSteps)")
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
