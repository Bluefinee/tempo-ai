import SwiftUI

/// オンボーディング全体を管理するコンテナビュー
/// 7画面の遷移と状態管理を担当
struct OnboardingContainerView: View {

  // MARK: - Properties

  @State private var onboardingState: OnboardingState = OnboardingState()
  @Environment(\.dismiss) private var dismiss

  let onComplete: (UserProfile) -> Void

  // MARK: - Initialization

  init(onComplete: @escaping (UserProfile) -> Void) {
    self.onComplete = onComplete
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      ZStack {
        // 背景色
        backgroundGradient
          .ignoresSafeArea()

        // メインコンテンツ
        Group {
          switch onboardingState.currentStep {
          case 1:
            WelcomeView(onboardingState: onboardingState)
          case 2:
            NicknameInputView(onboardingState: onboardingState)
          case 3:
            BasicInfoView(onboardingState: onboardingState)
          case 4:
            LifestyleView(onboardingState: onboardingState)
          case 5:
            InterestsView(onboardingState: onboardingState)
          case 6:
            PermissionsView(onboardingState: onboardingState)
          case 7:
            OnboardingLoadingView(
              onboardingState: onboardingState, onComplete: handleOnboardingComplete)
          default:
            EmptyView()
          }
        }
      }
    }
    .navigationBarHidden(true)
  }

  // MARK: - Components

  @ViewBuilder
  private var backgroundGradient: some View {
    LinearGradient(
      colors: [
        Color.tempoLightCream,
        Color.tempoWarmBeige.opacity(0.3)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  // MARK: - Methods

  private func handleOnboardingComplete() {
    guard let userProfile = onboardingState.createUserProfile() else {
      onboardingState.setError("プロフィールの作成に失敗しました")
      return
    }

    // UserProfile を保存
    do {
      try CacheManager.shared.saveUserProfile(userProfile)
      CacheManager.shared.saveOnboardingCompleted(true)

      // 完了コールバックを実行
      onComplete(userProfile)
    } catch {
      onboardingState.setError("データの保存に失敗しました: \(error.localizedDescription)")
    }
  }
}

// MARK: - Welcome View

struct WelcomeView: View {
  @Bindable var onboardingState: OnboardingState

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      // メインビジュアル
      VStack(spacing: 32) {
        // アプリアイコン／イメージ
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  Color.tempoSageGreen.opacity(0.8),
                  Color.tempoSageGreen.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 120, height: 120)

          Image(systemName: "heart.fill")
            .font(.system(size: 60))
            .foregroundStyle(.white)
        }

        // キャッチコピー
        VStack(spacing: 16) {
          Text("あなたのテンポで、\n健やかな毎日を")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.tempoPrimaryText)
            .multilineTextAlignment(.center)
            .lineLimit(nil)

          Text("AI があなたの健康データを分析し、\nパーソナライズされたアドバイスをお届けします")
            .font(.body)
            .foregroundStyle(.tempoSecondaryText)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, 16)
        }

        // 特徴リスト
        VStack(spacing: 16) {
          FeatureRow(
            icon: "brain.head.profile",
            text: "あなた専用のAIアドバイス"
          )

          FeatureRow(
            icon: "heart.text.square",
            text: "HealthKitとの自動連携"
          )

          FeatureRow(
            icon: "cloud.sun",
            text: "天気や環境に配慮した提案"
          )
        }
        .padding(.horizontal, 32)
      }

      Spacer()

      // 開始ボタン
      VStack(spacing: 16) {
        Button {
          onboardingState.proceedToNext()
        } label: {
          Text("始める")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(.tempoSoftCoral)
            )
        }
        .padding(.horizontal, 32)

        Text("セットアップには約3分かかります")
          .font(.caption)
          .foregroundStyle(.tempoSecondaryText)
      }
      .padding(.bottom, 32)
    }
  }
}

// MARK: - Feature Row

private struct FeatureRow: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundStyle(.tempoSageGreen)
        .frame(width: 24, alignment: .center)

      Text(text)
        .font(.body)
        .foregroundStyle(.tempoPrimaryText)
        .multilineTextAlignment(.leading)

      Spacer()
    }
  }
}

// MARK: - Progress Header

struct ProgressHeader: View {
  let currentStep: Int
  let totalSteps: Int = 7
  let title: String
  let onBack: () -> Void

  @Environment(\.dismiss) private var dismiss
  init(currentStep: Int, title: String, onBack: @escaping () -> Void) {
    self.currentStep = currentStep
    self.title = title
    self.onBack = onBack
  }

  var body: some View {
    VStack(spacing: 16) {
      // ナビゲーションバー
      HStack {
        Button(action: onBack) {
          Image(systemName: "chevron.left")
            .font(.title2)
            .foregroundStyle(.tempoPrimaryText)
        }

        Spacer()
      }

      // プログレス表示（画面2-6のみ）
      if currentStep > 1 && currentStep <= 6 {
        VStack(spacing: 8) {
          HStack {
            Text("\(currentStep - 1)/7")
              .font(.caption)
              .foregroundStyle(.tempoSecondaryText)

            Spacer()
          }

          ProgressView(value: Double(currentStep - 1), total: 7.0)
            .progressViewStyle(LinearProgressViewStyle(tint: .tempoSageGreen))
            .background(Color.tempoProgressBackground)
        }
      }

      // タイトル
      HStack {
        Text(title)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.tempoPrimaryText)

        Spacer()
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 8)
  }
}

// MARK: - Preview

#Preview {
  OnboardingContainerView { userProfile in
    print("Onboarding completed with profile: \(userProfile.nickname)")
  }
}
