import SwiftUI

// MARK: - NicknameStepView

/// Step 3: ニックネーム入力画面
struct NicknameStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "person.crop.circle")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // Title
            Text("ニックネームを教えてください")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            // Description
            Text("「〇〇さん」とお呼びします")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            // Text Field
            VStack(alignment: .leading, spacing: TempoSpacing.xs) {
                TextField("ニックネーム", text: $viewModel.state.nickname)
                    .font(TempoTypography.body)
                    .padding(TempoSpacing.md)
                    .background(TempoColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.smallCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: TempoSpacing.smallCornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.canProceed {
                            viewModel.nextStep()
                        }
                    }
                    .accessibilityLabel("ニックネーム入力")
                    .accessibilityHint("1〜20文字で入力してください")

                // Character count / validation message
                HStack {
                    if !viewModel.state.nickname.isEmpty && !viewModel.state.isNicknameValid {
                        Text("1〜20文字で入力してください")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.danger)
                    }
                    Spacer()
                    Text("\(viewModel.state.nickname.count)/20")
                        .font(TempoTypography.caption)
                        .foregroundStyle(characterCountColor)
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)

            Spacer()

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
        .onAppear {
            isTextFieldFocused = true
        }
    }

    // MARK: - Computed Properties

    private var borderColor: Color {
        if viewModel.state.nickname.isEmpty {
            return TempoColors.textTertiary.opacity(0.3)
        } else if viewModel.state.isNicknameValid {
            return TempoColors.primary
        } else {
            return TempoColors.danger
        }
    }

    private var characterCountColor: Color {
        if viewModel.state.nickname.count > 20 {
            return TempoColors.danger
        } else {
            return TempoColors.textTertiary
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NicknameStepView(viewModel: OnboardingViewModel())
}
#endif
