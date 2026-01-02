import SwiftUI

// MARK: - BedtimeGoalStepView

/// Step 6: 就寝目標設定画面（自動提案対応）
struct BedtimeGoalStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showTimePicker: Bool = false
    @State private var estimation: (Date, Bool) = (OnboardingState.defaultBedtime, false)

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "bed.double.fill")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // Title
            Text("就寝目標を設定")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            if estimation.1 && !showTimePicker {
                autoProposedView
            } else {
                timePickerView
            }

            Spacer()

            // Next Button
            PrimaryButton("次へ") {
                viewModel.nextStep()
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.bottom, TempoSpacing.xxl)
        }
        .onAppear {
            estimation = viewModel.estimateBedtimeGoal()
        }
    }

    // MARK: - Auto-Proposed View

    private var autoProposedView: some View {
        VStack(spacing: TempoSpacing.lg) {
            Text("睡眠データを分析した結果...")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            CardView {
                VStack(spacing: TempoSpacing.sm) {
                    Text("あなたの平均就寝時刻は")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)

                    Text(viewModel.formattedBedtime(estimation.0))
                        .font(TempoTypography.scoreValue)
                        .foregroundStyle(TempoColors.primary)

                    Text("です")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TempoSpacing.sm)
            }
            .padding(.horizontal, TempoSpacing.screenPadding)

            Text("これを目標にしますか？")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            HStack(spacing: TempoSpacing.md) {
                SecondaryButton("調整する") {
                    showTimePicker = true
                }

                PrimaryButton("このまま設定") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
        }
    }

    // MARK: - Time Picker View

    private var timePickerView: some View {
        VStack(spacing: TempoSpacing.lg) {
            Text("目標の就寝時刻を選んでください")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            // Time Picker
            DatePicker(
                "就寝時刻",
                selection: $viewModel.state.targetBedtime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxHeight: 150)
            .padding(.horizontal, TempoSpacing.screenPadding)

            // Current selection display
            CardView {
                HStack {
                    Text("設定する時刻")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                    Spacer()
                    Text(viewModel.formattedBedtime(viewModel.state.targetBedtime))
                        .font(TempoTypography.headline)
                        .foregroundStyle(TempoColors.primary)
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)

            if estimation.1 {
                TextButton("提案に戻る") {
                    viewModel.state.targetBedtime = estimation.0
                    showTimePicker = false
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Auto-proposed") {
    BedtimeGoalStepView(viewModel: OnboardingViewModel())
}

#Preview("Time picker") {
    let viewModel: OnboardingViewModel = OnboardingViewModel()
    return BedtimeGoalStepView(viewModel: viewModel)
}
#endif
