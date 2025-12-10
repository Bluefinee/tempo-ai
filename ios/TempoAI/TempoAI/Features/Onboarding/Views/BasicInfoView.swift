import SwiftUI

/// 基本情報入力画面（オンボーディング画面3）
struct BasicInfoView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState

  @State private var age: String = ""
  @State private var selectedGender: UserProfile.Gender = .notSpecified
  @State private var weight: String = ""
  @State private var height: String = ""

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "基本情報を教えてください"
      ) {
        onboardingState.goBack()
      }

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          Text("より正確なアドバイスのために\nいくつかの基本情報を教えてください")
            .font(.body)
            .foregroundColor(.tempoSecondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 24)

          // 入力フォーム
          VStack(spacing: 24) {
            // 年齢入力
            InputSection(title: "年齢", isRequired: true) {
              HStack {
                TextField("例: 28", text: $age)
                  .font(.body)
                  .keyboardType(.numberPad)
.onChange(of: age) { _, newValue in
                    age = String(newValue.prefix(3))
                    updateBasicInfo()
                  }

                Text("歳")
                  .font(.body)
                  .foregroundColor(.tempoSecondaryText)
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color.tempoInputBackground)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.tempoInputBorder, lineWidth: 1)
              )
            }

            // 性別選択
            InputSection(title: "性別", isRequired: true) {
              LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                  Button {
                    selectedGender = gender
                    updateBasicInfo()
                  } label: {
                    Text(gender.displayName)
                      .font(.body)
                      .foregroundStyle(
                        selectedGender == gender ? .white : Color.tempoPrimaryText
                      )
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 12)
                      .background(
                        RoundedRectangle(cornerRadius: 12)
                          .fill(
                            selectedGender == gender ? Color.tempoSageGreen : Color.tempoInputBackground
                          )
                          .stroke(
                            selectedGender == gender ? Color.tempoSageGreen : Color.tempoInputBorder,
                            lineWidth: 1
                          )
                      )
                  }
                  .buttonStyle(.plain)
                }
              }
            }

            // 体重・身長入力
            HStack(spacing: 16) {
              InputSection(title: "体重", isRequired: true) {
                HStack {
                  TextField("例: 55", text: $weight)
                    .font(.body)
                    .keyboardType(.decimalPad)
                    .onChange(of: weight) { _, newValue in
                      weight = formatDecimalInput(newValue)
                      updateBasicInfo()
                    }

                  Text("kg")
                    .font(.body)
                    .foregroundColor(.tempoSecondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.tempoInputBackground)
                    .stroke(Color.tempoInputBorder, lineWidth: 1)
                )
              }

              InputSection(title: "身長", isRequired: true) {
                HStack {
                  TextField("例: 160", text: $height)
                    .font(.body)
                    .keyboardType(.decimalPad)
                    .onChange(of: height) { _, newValue in
                      height = formatDecimalInput(newValue)
                      updateBasicInfo()
                    }

                  Text("cm")
                    .font(.body)
                    .foregroundColor(.tempoSecondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.tempoInputBackground)
                    .stroke(Color.tempoInputBorder, lineWidth: 1)
                )
              }
            }
          }
          .padding(.horizontal, 32)

          Spacer(minLength: 100)
        }
      }

      // 次へボタン
      Button {
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
              .fill(onboardingState.canProceedToNext ? Color.tempoSoftCoral : Color.tempoLightGray)
          )
      }
      .disabled(!onboardingState.canProceedToNext)
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      loadExistingData()
    }
  }

  // MARK: - Helper Methods

  private func loadExistingData() {
    if let basicInfo = onboardingState.basicInfo {
      age = String(basicInfo.age)
      selectedGender = basicInfo.gender
      weight = basicInfo.weightKg.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(basicInfo.weightKg))
        : String(format: "%.1f", basicInfo.weightKg)
      height = basicInfo.heightCm.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(basicInfo.heightCm))
        : String(format: "%.1f", basicInfo.heightCm)
    }
  }

  private func updateBasicInfo() {
    guard let ageInt = Int(age),
      let weightDouble = Double(weight),
      let heightDouble = Double(height)
    else {
      return
    }

    onboardingState.updateBasicInfo(
      age: ageInt,
      gender: selectedGender,
      weightKg: weightDouble,
      heightCm: heightDouble
    )
  }

  private func formatDecimalInput(_ input: String) -> String {
    let filtered = input.filter { $0.isNumber || $0 == "." }
    let components = filtered.components(separatedBy: ".")
    if components.count > 2 {
      return components[0] + "." + components[1]
    }
    return filtered
  }
}

// MARK: - Input Section

private struct InputSection<Content: View>: View {
  let title: String
  let isRequired: Bool
  let content: () -> Content

  init(title: String, isRequired: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.isRequired = isRequired
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
          .font(.headline)
          .fontWeight(.medium)
          .foregroundColor(.tempoPrimaryText)

        if isRequired {
          Text("*")
            .font(.headline)
            .foregroundColor(.tempoError)
        }

        Spacer()
      }

      content()
    }
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 3
  return BasicInfoView(onboardingState: state)
}
