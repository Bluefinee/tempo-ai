import SwiftUI

/// ライフスタイル入力画面（オンボーディング画面4）
struct LifestyleView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @State private var selectedOccupation: UserProfile.Occupation?
  @State private var selectedLifestyleRhythm: UserProfile.LifestyleRhythm?
  @State private var selectedExerciseFrequency: UserProfile.ExerciseFrequency?
  @State private var selectedAlcoholFrequency: UserProfile.AlcoholFrequency?

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "もう少し教えてください",
        onBack: {
          onboardingState.goBack()
        }
      )

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          VStack(spacing: 8) {
            Text("あなたの生活スタイルに合わせたアドバイスができます")
              .font(.body)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)

            Text("以下の項目は任意です。スキップすることもできます。")
              .font(.subheadline)
              .foregroundStyle(.tempoSecondaryText)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 32)
          .padding(.top, 16)

          // 入力セクション
          VStack(spacing: 24) {
            // 職業選択
            SelectionSection(title: "職業カテゴリー", description: "お仕事の種類を教えてください") {
              LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(UserProfile.Occupation.allCases, id: \.self) { occupation in
                  SelectionCard(
                    title: occupation.displayName,
                    isSelected: selectedOccupation == occupation
                  ) {
                    selectedOccupation = selectedOccupation == occupation ? nil : occupation
                    updateLifestyle()
                  }
                }
              }
            }

            // 生活リズム選択
            SelectionSection(title: "生活リズム", description: "いつ活動的になりますか？") {
              VStack(spacing: 12) {
                ForEach(UserProfile.LifestyleRhythm.allCases, id: \.self) { rhythm in
                  SelectionCard(
                    title: rhythm.displayName,
                    subtitle: rhythm.description,
                    isSelected: selectedLifestyleRhythm == rhythm,
                    style: .full
                  ) {
                    selectedLifestyleRhythm = selectedLifestyleRhythm == rhythm ? nil : rhythm
                    updateLifestyle()
                  }
                }
              }
            }
          }
          .padding(.horizontal, 32)

          Spacer(minLength: 120)
        }
      }

      // ボタンエリア
      VStack(spacing: 12) {
        // スキップボタン
        Button(action: {
          onboardingState.proceedToNext()
        }) {
          Text("スキップ")
            .font(.body)
            .foregroundStyle(.tempoSageGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }

        // 次へボタン
        Button(action: {
          updateLifestyle()
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
                .fill(.tempoSoftCoral)
            )
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
  }

  // MARK: - Helper Methods

  private func updateLifestyle() {
    onboardingState.updateLifestyle(
      occupation: selectedOccupation,
      lifestyleRhythm: selectedLifestyleRhythm,
      exerciseFrequency: selectedExerciseFrequency,
      alcoholFrequency: selectedAlcoholFrequency
    )
  }
}

// MARK: - Selection Section

private struct SelectionSection<Content: View>: View {
  let title: String
  let description: String
  let content: () -> Content

  init(title: String, description: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.description = description
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.tempoPrimaryText)

        Text(description)
          .font(.subheadline)
          .foregroundStyle(.tempoSecondaryText)
      }

      content()
    }
  }
}

// MARK: - Selection Card

private struct SelectionCard: View {
  let title: String
  let subtitle: String?
  let isSelected: Bool
  let style: Style
  let action: () -> Void

  enum Style {
    case compact
    case full
  }

  init(
    title: String,
    subtitle: String? = nil,
    isSelected: Bool,
    style: Style = .compact,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isSelected = isSelected
    self.style = style
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: subtitle != nil ? 4 : 0) {
        Text(title)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(
            isSelected ? .white : .tempoPrimaryText
          )
          .multilineTextAlignment(.leading)

        if let subtitle = subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(
              isSelected ? .white.opacity(0.9) : .tempoSecondaryText
            )
            .multilineTextAlignment(.leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, style == .compact ? 12 : 16)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(
            isSelected ? .tempoSageGreen : .tempoInputBackground
          )
          .stroke(
            isSelected ? .tempoSageGreen : .tempoInputBorder,
            lineWidth: 1
          )
      )
    }
    .buttonStyle(.plain)
    .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 4
  return LifestyleView(onboardingState: state)
}
