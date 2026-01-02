import SwiftUI

// MARK: - BasicInfoStepView

/// Step 4: 基本情報入力画面（年齢・性別・体重・身長）
struct BasicInfoStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: - Local State

    @State private var weightText: String = ""
    @State private var heightText: String = ""

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: TempoSpacing.xl) {
                // Title
                VStack(spacing: TempoSpacing.sm) {
                    Text("基本情報")
                        .font(TempoTypography.title2)
                        .foregroundStyle(TempoColors.textPrimary)

                    Text("パーソナライズに使用します")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                }
                .padding(.top, TempoSpacing.xl)

                // Form Fields
                VStack(spacing: TempoSpacing.lg) {
                    // Age Picker
                    formRow(label: "年齢") {
                        Picker("年齢", selection: $viewModel.state.age) {
                            ForEach(18...80, id: \.self) { age in
                                Text("\(age)歳").tag(age)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(TempoColors.textPrimary)
                    }

                    // Gender Picker
                    formRow(label: "性別") {
                        Picker("性別", selection: $viewModel.state.gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(TempoColors.textPrimary)
                    }

                    // Weight Input
                    formRow(label: "体重") {
                        HStack(spacing: TempoSpacing.xs) {
                            TextField("60.0", text: $weightText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: weightText) { _, newValue in
                                    if let weight: Double = Double(newValue) {
                                        viewModel.state.weight = weight
                                    }
                                }
                            Text("kg")
                                .foregroundStyle(TempoColors.textSecondary)
                        }
                    }

                    // Height Input
                    formRow(label: "身長") {
                        HStack(spacing: TempoSpacing.xs) {
                            TextField("170.0", text: $heightText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: heightText) { _, newValue in
                                    if let height: Double = Double(newValue) {
                                        viewModel.state.height = height
                                    }
                                }
                            Text("cm")
                                .foregroundStyle(TempoColors.textSecondary)
                        }
                    }

                    // BMI Display
                    if viewModel.state.weight > 0 && viewModel.state.height > 0 {
                        formRow(label: "BMI") {
                            Text(viewModel.state.bmiDisplayText)
                                .foregroundStyle(TempoColors.textPrimary)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)

                Spacer(minLength: TempoSpacing.xxl)

                // Next Button
                PrimaryButton(
                    "次へ",
                    isEnabled: viewModel.canProceed
                ) {
                    viewModel.nextStep()
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .padding(.bottom, TempoSpacing.xxl)
            }
        }
        .onAppear {
            weightText = String(format: "%.1f", viewModel.state.weight)
            heightText = String(format: "%.1f", viewModel.state.height)
        }
    }

    // MARK: - Helper Views

    private func formRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        CardView {
            HStack {
                Text(label)
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textPrimary)
                Spacer()
                content()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    BasicInfoStepView(viewModel: OnboardingViewModel())
}
#endif
