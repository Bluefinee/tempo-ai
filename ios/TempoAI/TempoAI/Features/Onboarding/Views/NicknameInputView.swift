import SwiftUI

/// ニックネーム入力画面（オンボーディング画面2）
struct NicknameInputView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @FocusState private var isTextFieldFocused: Bool

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "あなたのお名前を教えてください"
      ) {
        onboardingState.goBack()
      }

      ScrollView {
        VStack(spacing: 32) {
          DescriptionTextSection()
          
          NicknameInputField(
            onboardingState: onboardingState,
            isTextFieldFocused: $isTextFieldFocused
          )

          Spacer(minLength: 100)
        }
      }

      NextButton(
        action: { onboardingState.proceedToNext() },
        isEnabled: onboardingState.canProceedToNext
      )
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isTextFieldFocused = true
      }
    }
  }
}

// MARK: - Components

private struct DescriptionTextSection: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("ニックネームや下のお名前など、\nお好きな呼び方を教えてください")
        .font(.body)
        .foregroundColor(.tempoSecondaryText)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 32)
    .padding(.top, 32)
  }
}

private struct NicknameInputField: View {
  @Bindable var onboardingState: OnboardingState
  @FocusState.Binding var isTextFieldFocused: Bool
  
  var body: some View {
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
          .fill(Color.tempoInputBackground)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(
            isTextFieldFocused ? Color.tempoInputBorderActive : Color.tempoInputBorder,
            lineWidth: isTextFieldFocused ? 2 : 1
          )
      )
      .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)

      HStack {
        Text("\(onboardingState.nickname.count)/20")
          .font(.caption)
          .foregroundColor(
            onboardingState.nickname.count > 20 ? Color.tempoError : Color.tempoSecondaryText
          )

        Spacer()
      }
    }
    .padding(.horizontal, 32)
  }
}

private struct NextButton: View {
  let action: () -> Void
  let isEnabled: Bool
  
  var body: some View {
    Button(action: action) {
      Text("次へ")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(isEnabled ? Color.tempoSoftCoral : Color.tempoLightGray)
        )
    }
    .disabled(!isEnabled)
    .padding(.horizontal, 32)
    .padding(.bottom, 32)
  }
}

// MARK: - Preview

#Preview {
  NicknameInputView(onboardingState: OnboardingState())
}
