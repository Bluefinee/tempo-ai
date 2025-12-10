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
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "もう少し教えてください"
      ) {
        onboardingState.goBack()
      }
      
      LifestyleContentView(
        selectedOccupation: $selectedOccupation,
        selectedLifestyleRhythm: $selectedLifestyleRhythm,
        onUpdate: updateLifestyle
      )
      
      LifestyleActionButtons(
        onSkip: { onboardingState.proceedToNext() },
        onNext: {
          updateLifestyle()
          onboardingState.proceedToNext()
        },
        hasSelections: hasSelections
      )
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
  }

  // MARK: - Computed Properties

  private var hasSelections: Bool {
    selectedOccupation != nil || selectedLifestyleRhythm != nil
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

// MARK: - Components

private struct LifestyleContentView: View {
  @Binding var selectedOccupation: UserProfile.Occupation?
  @Binding var selectedLifestyleRhythm: UserProfile.LifestyleRhythm?
  let onUpdate: () -> Void
  
  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        // 説明テキスト
        VStack(spacing: 8) {
          Text("あなたの生活スタイルに合わせたアドバイスができます")
            .font(.body)
            .foregroundColor(.tempoSecondaryText)
            .multilineTextAlignment(.center)

          Text("以下の項目は任意です。スキップすることもできます。")
            .font(.subheadline)
            .foregroundColor(.tempoSecondaryText)
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
                  isSelected: selectedOccupation == occupation,
                  action: {
                    selectedOccupation = selectedOccupation == occupation ? nil : occupation
                    onUpdate()
                  }
                )
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
                  style: .full,
                  action: {
                    selectedLifestyleRhythm = selectedLifestyleRhythm == rhythm ? nil : rhythm
                    onUpdate()
                  }
                )
              }
            }
          }
        }
        .padding(.horizontal, 32)

        Spacer(minLength: 120)
      }
    }
  }
}

private struct LifestyleActionButtons: View {
  let onSkip: () -> Void
  let onNext: () -> Void
  let hasSelections: Bool
  
  var body: some View {
    VStack(spacing: 12) {
      // スキップボタン
      Button {
        onSkip()
      } label: {
        Text("スキップ")
          .font(.body)
          .foregroundColor(.tempoSageGreen)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
      }

      // 次へボタン
      Button {
        onNext()
      } label: {
        Text("次へ")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(hasSelections ? Color.tempoSoftCoral : Color.tempoLightGray)
          )
      }
      .disabled(!hasSelections)
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 32)
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
          .foregroundColor(.tempoPrimaryText)

        Text(description)
          .font(.subheadline)
          .foregroundColor(.tempoSecondaryText)
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
            isSelected ? .white : Color.tempoPrimaryText
          )
          .multilineTextAlignment(.leading)

        if let subtitle = subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(
              isSelected ? .white.opacity(0.9) : Color.tempoSecondaryText
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
            isSelected ? Color.tempoSageGreen : Color.tempoInputBackground
          )
          .stroke(
            isSelected ? Color.tempoSageGreen : Color.tempoInputBorder,
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
