import SwiftUI

// MARK: - LifestyleStepView

/// Step 7: ライフスタイル入力画面（任意）
struct LifestyleStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: TempoSpacing.xl) {
                // Title
                VStack(spacing: TempoSpacing.sm) {
                    Text("ライフスタイル")
                        .font(TempoTypography.title2)
                        .foregroundStyle(TempoColors.textPrimary)

                    Text("より正確なアドバイスのために\nご回答ください（任意）")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, TempoSpacing.xl)

                // Form Fields
                VStack(spacing: TempoSpacing.md) {
                    // Occupation Picker
                    formRow(label: "職業", icon: "briefcase.fill") {
                        Picker("職業", selection: occupationBinding) {
                            Text("未選択").tag(Occupation?.none)
                            ForEach(Occupation.allCases, id: \.self) { occupation in
                                Text(occupation.rawValue).tag(Occupation?.some(occupation))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(TempoColors.textPrimary)
                    }

                    // Exercise Frequency Picker
                    formRow(label: "運動頻度", icon: "figure.run") {
                        Picker("運動頻度", selection: exerciseBinding) {
                            Text("未選択").tag(ExerciseFrequency?.none)
                            ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(ExerciseFrequency?.some(frequency))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(TempoColors.textPrimary)
                    }

                    // Alcohol Frequency Picker
                    formRow(label: "飲酒頻度", icon: "wineglass.fill") {
                        Picker("飲酒頻度", selection: alcoholBinding) {
                            Text("未選択").tag(AlcoholFrequency?.none)
                            ForEach(AlcoholFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(AlcoholFrequency?.some(frequency))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(TempoColors.textPrimary)
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)

                Spacer(minLength: TempoSpacing.xxl)

                // Buttons
                VStack(spacing: TempoSpacing.sm) {
                    PrimaryButton("次へ") {
                        viewModel.nextStep()
                    }

                    SecondaryButton("スキップ") {
                        // Clear all lifestyle data
                        viewModel.state.occupation = nil
                        viewModel.state.exerciseFrequency = nil
                        viewModel.state.alcoholFrequency = nil
                        viewModel.nextStep()
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .padding(.bottom, TempoSpacing.xxl)
            }
        }
    }

    // MARK: - Bindings

    private var occupationBinding: Binding<Occupation?> {
        Binding(
            get: { viewModel.state.occupation },
            set: { viewModel.state.occupation = $0 }
        )
    }

    private var exerciseBinding: Binding<ExerciseFrequency?> {
        Binding(
            get: { viewModel.state.exerciseFrequency },
            set: { viewModel.state.exerciseFrequency = $0 }
        )
    }

    private var alcoholBinding: Binding<AlcoholFrequency?> {
        Binding(
            get: { viewModel.state.alcoholFrequency },
            set: { viewModel.state.alcoholFrequency = $0 }
        )
    }

    // MARK: - Helper Views

    private func formRow<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text(label)
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                content()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    LifestyleStepView(viewModel: OnboardingViewModel())
}
#endif
