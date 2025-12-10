import SwiftUI

/// 関心ごとタグ選択画面（オンボーディング画面5）
struct InterestsView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @State private var selectedInterests: Set<UserProfile.Interest> = []

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "あなたの関心ごとを教えてください"
      ) {
        onboardingState.goBack()
      }

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          VStack(spacing: 8) {
            Text("1〜3個選んでください")
              .font(.body)
              .foregroundStyle(.tempoSecondaryText)

            Text("選択した分野に特化したアドバイスをお届けします")
              .font(.subheadline)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 32)
          .padding(.top, 16)

          // Interest タググリッド
          LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
            spacing: 16
          ) {
            ForEach(UserProfile.Interest.allCases, id: \.self) { interest in
              InterestTagCard(
                interest: interest,
                isSelected: selectedInterests.contains(interest),
onTap: {
                  toggleInterest(interest)
                }
              )
            }
          }
          .padding(.horizontal, 32)

          Spacer(minLength: 100)
        }
      }

      // 次へボタン
      Button {
        saveSelectedInterests()
        onboardingState.proceedToNext()
      } label: {
        Text("次へ")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(isSelectionValid ? .tempoSoftCoral : .tempoLightGray)
          )
      }
      .disabled(!isSelectionValid)
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      selectedInterests = Set(onboardingState.interests)
    }
  }

  // MARK: - Computed Properties

  private var isSelectionValid: Bool {
    return selectedInterests.count >= 1 && selectedInterests.count <= 3
  }

  // MARK: - Methods

  private func toggleInterest(_ interest: UserProfile.Interest) {
    if selectedInterests.contains(interest) {
      selectedInterests.remove(interest)
    } else if selectedInterests.count < 3 {
      selectedInterests.insert(interest)
    }
  }

  private func saveSelectedInterests() {
    onboardingState.interests = Array(selectedInterests)
  }
}

// MARK: - Interest Tag Card

private struct InterestTagCard: View {
  let interest: UserProfile.Interest
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      VStack(spacing: 16) {
        // アイコン
        Image(systemName: interest.icon)
          .font(.system(size: 32, weight: .medium))
          .foregroundStyle(
            isSelected ? .white : Color.colorForInterest(interest)
          )
          .frame(width: 60, height: 60)
          .background(
            Circle()
              .fill(
                isSelected
                  ? Color.colorForInterest(interest)
                  : Color.colorForInterest(interest).opacity(0.15)
              )
          )

        // タイトルと説明
        VStack(spacing: 4) {
          Text(interest.displayName)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(
              isSelected ? .white : .tempoPrimaryText
            )
            .multilineTextAlignment(.center)
            .lineLimit(2)

          Text(interest.description)
            .font(.caption)
            .foregroundStyle(
              isSelected ? .white.opacity(0.9) : .tempoSecondaryText
            )
            .multilineTextAlignment(.center)
            .lineLimit(3)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            isSelected ? Color.colorForInterest(interest) : .white.opacity(0.8)
          )
          .stroke(
            isSelected ? Color.colorForInterest(interest) : .tempoLightGray.opacity(0.5),
            lineWidth: isSelected ? 2 : 1
          )
      )
    }
    .buttonStyle(.plain)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 5
  return InterestsView(onboardingState: state)
}
