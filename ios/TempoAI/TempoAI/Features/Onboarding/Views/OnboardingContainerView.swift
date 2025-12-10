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
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // ヒーロー画像エリア（画面上部40%）
        ZStack {
          // メイン画像（画面幅いっぱい）
          Image("WelcomeHeroImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
            .clipped()
            .offset(y: -25)
            .accessibilityLabel("落ち着いた環境で座っている女性のイラスト。穏やかで集中したライフスタイルを表現")
            .mask(
              // 画像自体にマスクを適用して下部をソフトにフェードアウト
              Rectangle()
                .fill(
                  LinearGradient(
                    colors: [
                      Color.black,
                      Color.black,
                      Color.black,
                      Color.black.opacity(0.9),
                      Color.black.opacity(0.6),
                      Color.black.opacity(0.2),
                      Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                  )
                )
            )
          
          // 上部フェードイン効果（背景から自然に浮き出る）
          VStack(spacing: 0) {
            LinearGradient(
              colors: [
                Color.tempoLightCream.opacity(1.0),
                Color.tempoLightCream.opacity(0.9),
                Color.tempoLightCream.opacity(0.7),
                Color.tempoLightCream.opacity(0.4),
                Color.tempoLightCream.opacity(0.2),
                Color.tempoLightCream.opacity(0.05),
                Color.clear
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: geometry.size.height * 0.4 * 0.18)
            
            Spacer()
          }
          
          // 下部ソフトトランジション効果（複層的なアプローチ）
          VStack(spacing: 0) {
            Spacer()
            
            // レイヤー1: 基本グラデーション
            ZStack {
              LinearGradient(
                colors: [
                  Color.clear,
                  Color.tempoLightCream.opacity(0.1),
                  Color.tempoLightCream.opacity(0.3),
                  Color.tempoLightCream.opacity(0.6),
                  Color.tempoLightCream.opacity(0.8),
                  Color.tempoLightCream.opacity(0.95),
                  Color.tempoLightCream.opacity(1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
              )
              
              // レイヤー2: 追加のソフトブレンド効果
              Rectangle()
                .fill(Color.tempoLightCream.opacity(0.1))
                .background(.ultraThinMaterial, in: Rectangle())
                .clipShape(
                  .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                  )
                )
                .mask(
                  LinearGradient(
                    colors: [
                      Color.clear,
                      Color.black.opacity(0.3),
                      Color.black.opacity(0.7),
                      Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                  )
                )
            }
            .frame(height: geometry.size.height * 0.4 * 0.25)
          }
        }

        // コンテンツエリア（画面下部60%）
        ScrollView {
          VStack(spacing: 32) {
            // ブランドタイトルセクション
            VStack(spacing: 16) {
              Text("Tempo AI")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.tempoSageGreen)
                .multilineTextAlignment(.center)
              
              Text("あなたのテンポで\n健やかな毎日を")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.tempoPrimaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

              Text("AIがあなたのヘルスケアデータを分析し\nパーソナライズしたアドバイスを\n毎日お届けします")
                .font(.body)
                .foregroundColor(.tempoSecondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            }
            .padding(.top, 24)

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

            // 開始ボタンエリア
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
                      .fill(Color.tempoSoftCoral)
                  )
              }
              .padding(.horizontal, 32)
            }
            .padding(.bottom, 48)
          }
        }
        .frame(height: geometry.size.height * 0.6)
      }
    }
  }
}

// MARK: - Feature Row

private struct FeatureRow: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(.tempoSageGreen)
        .frame(width: 24, alignment: .leading)

      Text(text)
        .font(.body)
        .foregroundColor(.tempoPrimaryText)
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
            .foregroundColor(.tempoPrimaryText)
        }

        Spacer()
      }

      // プログレス表示（画面2-6のみ）
      if currentStep > 1 && currentStep <= 6 {
        VStack(spacing: 8) {
          HStack {
            Text("\(currentStep - 1)/7")
              .font(.caption)
              .foregroundColor(.tempoSecondaryText)

            Spacer()
          }

          ProgressView(value: Double(currentStep - 1), total: 7.0)
            .progressViewStyle(LinearProgressViewStyle(tint: Color.tempoSageGreen))
            .background(Color.tempoProgressBackground)
        }
      }

      // タイトル
      HStack {
        Text(title)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.tempoPrimaryText)

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
