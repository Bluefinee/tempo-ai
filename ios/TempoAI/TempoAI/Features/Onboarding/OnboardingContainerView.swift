import SwiftUI

// MARK: - OnboardingContainerView

/// オンボーディングフロー全体を管理するコンテナビュー
struct OnboardingContainerView: View {

    // MARK: - Properties

    @StateObject private var viewModel: OnboardingViewModel = OnboardingViewModel()

    // MARK: - Completion Handler

    let onComplete: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator (Step 2〜8で表示)
            if shouldShowProgress {
                progressIndicator
            }

            // Step Content
            stepContent
                .frame(maxHeight: .infinity)
        }
        .tempoBackground()
        .alert(
            "エラー",
            isPresented: $viewModel.showError,
            presenting: viewModel.error
        ) { _ in
            Button("OK") {
                viewModel.dismissError()
            }
        } message: { error in
            VStack {
                Text(error.localizedDescription)
                if let suggestion: String = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                }
            }
        }
    }

    // MARK: - Progress Visibility

    private var shouldShowProgress: Bool {
        viewModel.currentStep != .welcome && viewModel.currentStep != .complete
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: TempoSpacing.xs) {
            // Step dots
            HStack(spacing: TempoSpacing.xs) {
                ForEach(OnboardingStep.progressSteps, id: \.self) { step in
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 8, height: 8)
                }
            }
            .tempoAnimation(viewModel.currentStep)

            // Progress bar
            ProgressBar(progress: viewModel.currentStep.progressValue)
                .frame(height: 4)
                .padding(.horizontal, TempoSpacing.screenPadding)
        }
        .padding(.top, TempoSpacing.md)
        .padding(.bottom, TempoSpacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("オンボーディング進捗")
        .accessibilityValue("ステップ\(viewModel.currentStep.rawValue)／9")
    }

    private func stepColor(for step: OnboardingStep) -> Color {
        if step.rawValue < viewModel.currentStep.rawValue {
            return TempoColors.primary
        } else if step == viewModel.currentStep {
            return TempoColors.primary
        } else {
            return TempoColors.progressBackground
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeStepView(viewModel: viewModel)
        case .healthKit:
            HealthKitStepView(viewModel: viewModel)
        case .nickname:
            NicknameStepView(viewModel: viewModel)
        case .basicInfo:
            BasicInfoStepView(viewModel: viewModel)
        case .chronotype:
            ChronotypeStepView(viewModel: viewModel)
        case .bedtimeGoal:
            BedtimeGoalStepView(viewModel: viewModel)
        case .lifestyle:
            LifestyleStepView(viewModel: viewModel)
        case .location:
            LocationStepView(viewModel: viewModel)
        case .complete:
            CompleteStepView(viewModel: viewModel, onComplete: onComplete)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    OnboardingContainerView {
        print("Onboarding completed")
    }
}
#endif
