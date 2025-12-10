import SwiftUI

/// ニックネーム入力画面（オンボーディング画面2）
struct NicknameInputView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @FocusState private var isTextFieldFocused: Bool

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "あなたのお名前を教えてください",
        onBack: {
          onboardingState.goBack()
        }
      )

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          VStack(spacing: 16) {
            Text("毎朝、あなたの名前でご挨拶します")
              .font(.body)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)

            Text("ニックネームや下のお名前など、\nお好きな呼び方を教えてください")
              .font(.subheadline)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 32)
          .padding(.top, 32)

          // 入力フィールド
          VStack(spacing: 16) {
            TextField(
              "例: さくら",
              text: Binding(
                get: { onboardingState.nickname },
                set: { newValue in
                  onboardingState.updateNickname(newValue)
                }
              )
            )
            .font(.title2)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .focused($isTextFieldFocused)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(.tempoInputBackground)
                .stroke(
                  isTextFieldFocused ? .tempoInputBorderActive : .tempoInputBorder,
                  lineWidth: isTextFieldFocused ? 2 : 1
                )
            )
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)

            HStack {
              Text("\(onboardingState.nickname.count)/20")
                .font(.caption)
                .foregroundStyle(
                  onboardingState.nickname.count > 20 ? .tempoError : .tempoSecondaryText
                )

              Spacer()
            }
          }
          .padding(.horizontal, 32)

          Spacer(minLength: 100)
        }
      }

      // 次へボタン
      Button(action: {
        onboardingState.proceedToNext()
      }) {
        Text("次へ")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(onboardingState.canProceedToNext ? .tempoSoftCoral : .tempoLightGray)
          )
      }
      .disabled(!onboardingState.canProceedToNext)
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      // フィールドに自動フォーカス
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isTextFieldFocused = true
      }
    }
  }
}

// MARK: - Preview

#Preview {
  NicknameInputView(onboardingState: OnboardingState())
}
