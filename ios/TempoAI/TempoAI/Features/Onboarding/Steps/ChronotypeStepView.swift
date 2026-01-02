import SwiftUI

// MARK: - ChronotypeStepView

/// Step 5: クロノタイプ選択画面（自動推定対応）
struct ChronotypeStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showManualSelection: Bool = false
    @State private var estimation: (Chronotype, Bool) = (.intermediate, false)

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "clock.arrow.2.circlepath")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)
                .accessibilityHidden(true)

            // Title
            Text("あなたのクロノタイプ")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            if estimation.1 && !showManualSelection {
                autoEstimatedView
            } else {
                manualSelectionView
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
            estimation = viewModel.estimateChronotype()
        }
    }

    // MARK: - Auto-Estimated View

    private var autoEstimatedView: some View {
        VStack(spacing: TempoSpacing.lg) {
            Text("睡眠データを分析した結果...")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            CardView {
                VStack(spacing: TempoSpacing.sm) {
                    Text("あなたは")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)

                    Text(estimation.0.rawValue)
                        .font(TempoTypography.title)
                        .foregroundStyle(TempoColors.primary)

                    Text("のようです")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)

                    Text("推奨就寝時刻: \(estimation.0.recommendedBedtimeRange)")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textTertiary)
                        .padding(.top, TempoSpacing.xs)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TempoSpacing.sm)
            }
            .padding(.horizontal, TempoSpacing.screenPadding)

            TextButton("別の選択肢を見る") {
                showManualSelection = true
            }
        }
    }

    // MARK: - Manual Selection View

    private var manualSelectionView: some View {
        VStack(spacing: TempoSpacing.md) {
            Text("あなたに最も近いタイプを\n選んでください")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: TempoSpacing.sm) {
                ForEach(Chronotype.allCases, id: \.self) { type in
                    chronotypeButton(type)
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)

            if estimation.1 {
                TextButton("推定結果に戻る") {
                    viewModel.state.chronotype = estimation.0
                    showManualSelection = false
                }
            }
        }
    }

    // MARK: - Chronotype Button

    private func chronotypeButton(_ type: Chronotype) -> some View {
        Button {
            viewModel.state.chronotype = type
            viewModel.state.chronotypeAutoEstimated = false
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: TempoSpacing.xxs) {
                    Text(type.rawValue)
                        .font(TempoTypography.headline)
                        .foregroundStyle(TempoColors.textPrimary)
                    Text("推奨: \(type.recommendedBedtimeRange)")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textSecondary)
                }
                Spacer()
                if viewModel.state.chronotype == type {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TempoColors.primary)
                        .font(.title3)
                }
            }
            .padding(TempoSpacing.md)
            .background(
                viewModel.state.chronotype == type
                    ? TempoColors.primary.opacity(0.1)
                    : TempoColors.cardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(type.rawValue)、推奨就寝時刻\(type.recommendedBedtimeRange)")
        .accessibilityAddTraits(viewModel.state.chronotype == type ? .isSelected : [])
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Auto-estimated") {
    let viewModel: OnboardingViewModel = OnboardingViewModel()
    return ChronotypeStepView(viewModel: viewModel)
}

#Preview("Manual selection") {
    ChronotypeStepView(viewModel: OnboardingViewModel())
}
#endif
