import SwiftUI

// MARK: - HealthKitStepView

/// Step 2: HealthKit認証画面
struct HealthKitStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "heart.text.square")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // Title
            Text("HealthKitに接続")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            // Description
            VStack(spacing: TempoSpacing.md) {
                Text("睡眠、心拍変動、活動量データを\n取得して分析します")
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Data types
                CardView {
                    VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                        dataRow(icon: "bed.double.fill", text: "睡眠データ")
                        dataRow(icon: "heart.fill", text: "心拍変動（HRV）")
                        dataRow(icon: "figure.walk", text: "活動量・歩数")
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)

                Text("あなたのデータはデバイス内で\n安全に保管されます")
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Error Message
            if let error: OnboardingError = viewModel.error {
                VStack(spacing: TempoSpacing.xs) {
                    Text(error.localizedDescription)
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.danger)
                        .multilineTextAlignment(.center)

                    if let suggestion: String = error.recoverySuggestion {
                        Text(suggestion)
                            .font(TempoTypography.caption2)
                            .foregroundStyle(TempoColors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
            }

            // Connect Button
            PrimaryButton(
                "HealthKitに接続",
                icon: "link",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.requestHealthKitAuthorization()
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.bottom, TempoSpacing.xxl)
        }
    }

    // MARK: - Helper Views

    private func dataRow(icon: String, text: String) -> some View {
        HStack(spacing: TempoSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(TempoColors.primary)
                .frame(width: 24)
            Text(text)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textPrimary)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    HealthKitStepView(viewModel: OnboardingViewModel())
}
#endif
