import SwiftUI

// MARK: - WelcomeStepView

/// Step 1: ウェルカム画面
struct WelcomeStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xxl) {
            Spacer()

            // App Logo
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 80))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // App Name & Tagline
            VStack(spacing: TempoSpacing.sm) {
                Text("TempoAI")
                    .font(TempoTypography.largeTitle)
                    .foregroundStyle(TempoColors.textPrimary)

                Text("Tune Your Rhythm")
                    .font(TempoTypography.title3)
                    .foregroundStyle(TempoColors.textSecondary)
            }

            // Description
            Text("あなたの生体リズムを分析し、\n毎日の過ごし方をパーソナライズします")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, TempoSpacing.lg)

            Spacer()

            // Start Button
            AccentButton("始める", icon: "arrow.right") {
                viewModel.nextStep()
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.bottom, TempoSpacing.xxl)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("TempoAIへようこそ。Tune Your Rhythm。始めるにはボタンをタップしてください")
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WelcomeStepView(viewModel: OnboardingViewModel())
}
#endif
