import SwiftUI

/// データ取得中画面（オンボーディング画面7）
struct OnboardingLoadingView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  let onComplete: () -> Void

  @State private var loadingProgress: Double = 0.0
  @State private var currentTask: String = "準備中..."

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      VStack(spacing: 40) {
        // ローディングアニメーション
        loadingAnimation

        // タスクメッセージ
        VStack(spacing: 16) {
          Text(currentTask)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.tempoPrimaryText)
            .multilineTextAlignment(.center)
            .animation(.easeInOut(duration: 0.3), value: currentTask)

          Text("あなたの健康データから\nパーソナライズされたアドバイスを準備しています")
            .font(.body)
            .foregroundStyle(.tempoSecondaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
        }
        .padding(.horizontal, 32)

        // プログレスバー
        VStack(spacing: 12) {
          ProgressView(value: loadingProgress, total: 1.0)
            .progressViewStyle(LinearProgressViewStyle(tint: .tempoSageGreen))
            .frame(maxWidth: 280)
            .background(Color.tempoProgressBackground)

          Text("\(Int(loadingProgress * 100))% 完了")
            .font(.caption)
            .foregroundStyle(.tempoSecondaryText)
        }
      }

      Spacer()

      Text("しばらくお待ちください...")
        .font(.subheadline)
        .foregroundStyle(.tempoSecondaryText)
        .padding(.bottom, 40)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      startLoadingProcess()
    }
  }

  // MARK: - Loading Animation

  @ViewBuilder
  private var loadingAnimation: some View {
    ZStack {
      // 外側のリング
      Circle()
        .stroke(.tempoSageGreen.opacity(0.2), lineWidth: 8)
        .frame(width: 120, height: 120)

      // 内側のリング（アニメーション）
      Circle()
        .trim(from: 0, to: loadingProgress * 0.8)
        .stroke(
          .tempoSageGreen,
          style: StrokeStyle(lineWidth: 8, lineCap: .round)
        )
        .frame(width: 120, height: 120)
        .rotationEffect(.degrees(-90))
        .animation(.easeInOut(duration: 0.5), value: loadingProgress)

      // 中央のアイコン
      VStack(spacing: 8) {
        Image(systemName: "heart.circle.fill")
          .font(.system(size: 36, weight: .medium))
          .foregroundStyle(.tempoSoftCoral)

        Text("Tempo")
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundStyle(.tempoPrimaryText)
      }
    }
  }

  // MARK: - Methods

  private func startLoadingProcess() {
    onboardingState.setLoading(true)

    let steps = [
      "HealthKit データを取得中...",
      "睡眠データを分析中...",
      "心拍数データを分析中...",
      "あなた専用のプロフィールを作成中...",
    ]

    for (index, step) in steps.enumerated() {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
        withAnimation(.easeInOut(duration: 0.5)) {
          currentTask = step
          loadingProgress = Double(index + 1) / Double(steps.count)
        }

        if index == steps.count - 1 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completeLoading()
          }
        }
      }
    }
  }

  private func completeLoading() {
    onboardingState.setLoading(false)
    onboardingState.completeOnboarding()

    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      loadingProgress = 1.0
      currentTask = "完了！"
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      onComplete()
    }
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 7
  state.nickname = "さくら"
  state.interests = [.sleep, .nutrition]

  return OnboardingLoadingView(onboardingState: state) {
    print("Loading completed")
  }
}
