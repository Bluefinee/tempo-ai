import SwiftUI

/// 権限リクエスト画面（オンボーディング画面6）
struct PermissionsView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @State private var isRequestingPermissions: Bool = false

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "Tempo AIに必要な権限",
        onBack: {
          onboardingState.goBack()
        }
      )

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          VStack(spacing: 12) {
            Text("よりパーソナライズされたアドバイスのために")
              .font(.body)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)

            Text("以下の権限が必要です。許可していただくとより正確で有用なアドバイスをお届けできます。")
              .font(.subheadline)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 32)
          .padding(.top, 16)

          // 権限説明セクション
          VStack(spacing: 24) {
            PermissionCard(
              icon: "heart.text.square.fill",
              title: "ヘルスケアデータ",
              description: "睡眠や心拍数などのデータを分析し、あなたの健康状態に基づいたアドバイスを提供します。",
              color: .tempoSoftCoral
            )

            PermissionCard(
              icon: "location.fill",
              title: "位置情報",
              description: "天気や大気汚染の情報を取得し、環境に配慮したアドバイスをお届けします。",
              color: .tempoSageGreen
            )
          }
          .padding(.horizontal, 32)

          Spacer(minLength: 100)
        }
      }

      // 許可ボタン
      VStack(spacing: 12) {
        Button(action: {
          requestPermissions()
        }) {
          HStack {
            if isRequestingPermissions {
              ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Image(systemName: "checkmark.shield.fill")
                .font(.title3)
            }

            Text(isRequestingPermissions ? "権限を確認中..." : "許可して始める")
              .font(.headline)
              .fontWeight(.semibold)
          }
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(isRequestingPermissions ? .tempoMediumGray : .tempoSoftCoral)
          )
        }
        .disabled(isRequestingPermissions)

        Button(action: {
          onboardingState.proceedToNext()
        }) {
          Text("スキップ（後で設定）")
            .font(.body)
            .foregroundStyle(.tempoSecondaryText)
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
  }

  // MARK: - Methods

  private func requestPermissions() {
    isRequestingPermissions = true

    // 権限リクエストシミュレーション
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      onboardingState.updateAuthorizationStatus(healthKit: true, location: true)
      isRequestingPermissions = false
      onboardingState.proceedToNext()
    }
  }
}

// MARK: - Permission Card

private struct PermissionCard: View {
  let icon: String
  let title: String
  let description: String
  let color: Color

  var body: some View {
    HStack(spacing: 16) {
      // アイコン
      Image(systemName: icon)
        .font(.system(size: 28, weight: .medium))
        .foregroundStyle(color)
        .frame(width: 48, height: 48)
        .background(
          Circle()
            .fill(color.opacity(0.15))
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.tempoPrimaryText)

        Text(description)
          .font(.body)
          .foregroundStyle(.tempoSecondaryText)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.white.opacity(0.8))
        .stroke(color.opacity(0.3), lineWidth: 1)
    )
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 6
  return PermissionsView(onboardingState: state)
}
