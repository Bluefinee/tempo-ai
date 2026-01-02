import SwiftUI

// MARK: - LocationStepView

/// Step 8: 位置情報認証画面
struct LocationStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel
    @State private var hasRequestedPermission: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "location.fill")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // Title
            Text("位置情報")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            // Description
            VStack(spacing: TempoSpacing.md) {
                Text("お住まいの地域の気象データを取得し、\nより精度の高いアドバイスを提供します")
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Benefits Card
                CardView {
                    VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                        benefitRow(icon: "cloud.sun.fill", text: "天気に応じた活動提案")
                        benefitRow(icon: "thermometer.medium", text: "気温を考慮した睡眠アドバイス")
                        benefitRow(icon: "humidity.fill", text: "湿度による体調予測")
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)

                Text("位置情報は後から設定で変更できます")
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textTertiary)
            }

            Spacer()

            // Status Message
            if hasRequestedPermission {
                if viewModel.isLocationAuthorized {
                    HStack(spacing: TempoSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(TempoColors.primary)
                        Text("位置情報が許可されました")
                            .font(TempoTypography.body)
                            .foregroundStyle(TempoColors.primary)
                    }
                } else {
                    Text("位置情報へのアクセスが許可されていません")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textSecondary)
                }
            }

            // Buttons
            VStack(spacing: TempoSpacing.sm) {
                if !hasRequestedPermission {
                    PrimaryButton("位置情報を許可", icon: "location.fill") {
                        viewModel.requestLocationAuthorization()
                        hasRequestedPermission = true
                    }
                } else {
                    PrimaryButton("次へ") {
                        viewModel.nextStep()
                    }
                }

                TextButton("スキップ") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.bottom, TempoSpacing.xxl)
        }
    }

    // MARK: - Helper Views

    private func benefitRow(icon: String, text: String) -> some View {
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
    LocationStepView(viewModel: OnboardingViewModel())
}
#endif
