import SwiftUI

// MARK: - CompleteStepView

/// Step 9: 完了画面（Peak-End Rule活用）
struct CompleteStepView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    // MARK: - Animation State

    @State private var showCheckmark: Bool = false
    @State private var showContent: Bool = false
    @State private var confettiParticles: [ConfettiParticle] = []

    // MARK: - Body

    var body: some View {
        ZStack {
            // Confetti
            ForEach(confettiParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }

            VStack(spacing: TempoSpacing.xl) {
                Spacer()

                // Checkmark Animation
                ZStack {
                    Circle()
                        .fill(TempoColors.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                        .opacity(showCheckmark ? 1 : 0)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(TempoColors.primary)
                        .scaleEffect(showCheckmark ? 1 : 0.3)
                        .opacity(showCheckmark ? 1 : 0)
                }

                // Message
                VStack(spacing: TempoSpacing.sm) {
                    Text("準備完了です！")
                        .font(TempoTypography.title)
                        .foregroundStyle(TempoColors.textPrimary)

                    Text("\(viewModel.state.nickname)さん、\nTempoAIへようこそ")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Summary Card
                CardView {
                    VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                        summaryRow(
                            icon: "moon.fill",
                            label: "クロノタイプ",
                            value: viewModel.state.chronotype.rawValue
                        )
                        summaryRow(
                            icon: "bed.double.fill",
                            label: "目標就寝時刻",
                            value: viewModel.formattedBedtime(viewModel.state.targetBedtime)
                        )
                        if viewModel.state.healthKitAuthorized {
                            summaryRow(
                                icon: "heart.fill",
                                label: "HealthKit",
                                value: "接続済み"
                            )
                        }
                        if viewModel.state.locationAuthorized {
                            summaryRow(
                                icon: "location.fill",
                                label: "位置情報",
                                value: "許可済み"
                            )
                        }
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Calibration Notice
                CardView(backgroundColor: TempoColors.primary.opacity(0.1)) {
                    HStack(spacing: TempoSpacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(TempoColors.primary)
                        VStack(alignment: .leading, spacing: TempoSpacing.xxs) {
                            Text("7日間のキャリブレーション期間")
                                .font(TempoTypography.headline)
                                .foregroundStyle(TempoColors.textPrimary)
                            Text("データを蓄積して、より精度の高い分析を行います")
                                .font(TempoTypography.caption)
                                .foregroundStyle(TempoColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Complete Button
                AccentButton(
                    "ホーム画面へ",
                    icon: "house.fill",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        let success: Bool = await viewModel.completeOnboarding()
                        if success {
                            onComplete()
                        }
                        // エラー時はviewModel.showErrorがtrueになり、
                        // OnboardingContainerViewのalertでエラー表示される
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .padding(.bottom, TempoSpacing.xxl)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Helper Views

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            HStack(spacing: TempoSpacing.sm) {
                Image(systemName: icon)
                    .foregroundStyle(TempoColors.primary)
                    .frame(width: 24)
                Text(label)
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)
            }
            Spacer()
            Text(value)
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Checkmark animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            showCheckmark = true
        }

        // Content fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            createConfetti()
        }
    }

    private func createConfetti() {
        let colors: [Color] = [
            TempoColors.primary,
            TempoColors.accent,
            Color.yellow,
            Color.orange
        ]

        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height

        for i in 0..<20 {
            let particle: ConfettiParticle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? TempoColors.primary,
                size: CGFloat.random(in: 6...12),
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: -50...0)
                ),
                opacity: 1.0
            )
            confettiParticles.append(particle)
        }

        // Animate confetti falling
        for i in 0..<confettiParticles.count {
            let delay: Double = Double(i) * 0.05
            withAnimation(.easeIn(duration: 2.0).delay(delay)) {
                confettiParticles[i].position.y = screenHeight + 50
                confettiParticles[i].position.x += CGFloat.random(in: -50...50)
                confettiParticles[i].opacity = 0
            }
        }

        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiParticles.removeAll()
        }
    }
}

// MARK: - ConfettiParticle

private struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

// MARK: - Preview

#if DEBUG
#Preview {
    let viewModel: OnboardingViewModel = OnboardingViewModel()
    viewModel.state.nickname = "太郎"
    viewModel.state.chronotype = .morning
    viewModel.state.healthKitAuthorized = true
    return CompleteStepView(viewModel: viewModel) {
        print("Completed!")
    }
}
#endif
