import Foundation

/// オンボーディングの進行状態を管理するObservableクラス
@MainActor
@Observable
final class OnboardingState {

  // MARK: - Properties

  /// 現在のステップ（1〜7）
  var currentStep: Int = 1

  /// ニックネーム
  var nickname: String = ""

  /// 基本情報
  var basicInfo: BasicInfo?

  /// ライフスタイル情報
  var lifestyle: Lifestyle?

  /// 関心ごとタグ
  var interests: [UserProfile.Interest] = []

  /// HealthKit認証済みフラグ
  var healthKitAuthorized: Bool = false

  /// 位置情報認証済みフラグ
  var locationAuthorized: Bool = false

  /// オンボーディング完了フラグ
  var isCompleted: Bool = false

  /// エラー状態
  var errorMessage: String?

  /// ローディング状態
  var isLoading: Bool = false

  // MARK: - Computed Properties

  /// 進捗割合（0.0〜1.0）
  var progress: Double {
    return Double(currentStep - 1) / 6.0  // 画面2〜7で進捗表示（6ステップ）
  }

  /// 進捗表示用テキスト（例: "2/7"）
  var progressText: String {
    guard currentStep > 1 && currentStep <= 6 else { return "" }
    return "\(currentStep - 1)/7"
  }

  /// 現在のステップで「次へ」ボタンが活性化可能か
  var canProceedToNext: Bool {
    switch currentStep {
    case 1:
      return true  // ウェルカム画面では常に進行可能
    case 2:
      return !nickname.isEmpty && nickname.count <= 20
    case 3:
      return basicInfo != nil && isBasicInfoValid
    case 4:
      return true  // ライフスタイル画面は任意なのでスキップ可能
    case 5:
      return interests.count >= 1 && interests.count <= 3
    case 6:
      return true  // 権限リクエスト画面では常に進行可能
    case 7:
      return isCompleted  // データ取得完了まで待機
    default:
      return false
    }
  }

  /// 基本情報のバリデーション
  private var isBasicInfoValid: Bool {
    guard let info = basicInfo else { return false }
    return (18...100).contains(info.age) && (30.0...200.0).contains(info.weightKg)
      && (100.0...250.0).contains(info.heightCm)
  }

  // MARK: - Navigation Methods

  /// 次の画面に進む
  func proceedToNext() {
    guard canProceedToNext else { return }

    if currentStep < 7 {
      currentStep += 1
    }
  }

  /// 前の画面に戻る
  func goBack() {
    if currentStep > 1 {
      currentStep -= 1
    }
  }

  /// 特定のステップにジャンプ
  func jumpToStep(_ step: Int) {
    guard (1...7).contains(step) else { return }
    currentStep = step
  }

  // MARK: - Data Update Methods

  /// ニックネームを更新
  func updateNickname(_ name: String) {
    nickname = name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// 基本情報を更新
  func updateBasicInfo(age: Int, gender: UserProfile.Gender, weightKg: Double, heightCm: Double) {
    basicInfo = BasicInfo(
      age: age,
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm
    )
  }

  /// ライフスタイル情報を更新
  func updateLifestyle(
    occupation: UserProfile.Occupation?,
    lifestyleRhythm: UserProfile.LifestyleRhythm?,
    exerciseFrequency: UserProfile.ExerciseFrequency?,
    alcoholFrequency: UserProfile.AlcoholFrequency?
  ) {
    lifestyle = Lifestyle(
      occupation: occupation,
      lifestyleRhythm: lifestyleRhythm,
      exerciseFrequency: exerciseFrequency,
      alcoholFrequency: alcoholFrequency
    )
  }

  /// 関心ごとタグを追加
  func addInterest(_ interest: UserProfile.Interest) {
    if !interests.contains(interest) && interests.count < 3 {
      interests.append(interest)
    }
  }

  /// 関心ごとタグを削除
  func removeInterest(_ interest: UserProfile.Interest) {
    interests.removeAll { $0 == interest }
  }

  /// 関心ごとタグの選択状態をトグル
  func toggleInterest(_ interest: UserProfile.Interest) {
    if interests.contains(interest) {
      removeInterest(interest)
    } else {
      addInterest(interest)
    }
  }

  /// 権限状態を更新
  func updateAuthorizationStatus(healthKit: Bool, location: Bool) {
    healthKitAuthorized = healthKit
    locationAuthorized = location
  }

  /// エラーメッセージを設定
  func setError(_ message: String) {
    errorMessage = message
  }

  /// エラーをクリア
  func clearError() {
    errorMessage = nil
  }

  /// ローディング状態を設定
  func setLoading(_ loading: Bool) {
    isLoading = loading
  }

  /// オンボーディング完了を設定
  func completeOnboarding() {
    isCompleted = true
    currentStep = 7
  }

  /// 完成されたUserProfileを生成
  func createUserProfile() -> UserProfile? {
    guard let basicInfo = basicInfo,
      !nickname.isEmpty,
      !interests.isEmpty
    else {
      return nil
    }

    return UserProfile(
      nickname: nickname,
      age: basicInfo.age,
      gender: basicInfo.gender,
      weightKg: basicInfo.weightKg,
      heightCm: basicInfo.heightCm,
      occupation: lifestyle?.occupation,
      lifestyleRhythm: lifestyle?.lifestyleRhythm,
      exerciseFrequency: lifestyle?.exerciseFrequency,
      alcoholFrequency: lifestyle?.alcoholFrequency,
      interests: interests
    )
  }

  /// オンボーディング状態をリセット
  func reset() {
    currentStep = 1
    nickname = ""
    basicInfo = nil
    lifestyle = nil
    interests = []
    healthKitAuthorized = false
    locationAuthorized = false
    isCompleted = false
    errorMessage = nil
    isLoading = false
  }
}

// MARK: - Supporting Types

extension OnboardingState {
  /// 基本情報
  struct BasicInfo: Sendable {
    let age: Int
    let gender: UserProfile.Gender
    let weightKg: Double
    let heightCm: Double
  }

  /// ライフスタイル情報
  struct Lifestyle: Sendable {
    let occupation: UserProfile.Occupation?
    let lifestyleRhythm: UserProfile.LifestyleRhythm?
    let exerciseFrequency: UserProfile.ExerciseFrequency?
    let alcoholFrequency: UserProfile.AlcoholFrequency?
  }
}

// MARK: - Sample Data

#if DEBUG
  extension OnboardingState {
    static let sampleData: OnboardingState = {
      let state = OnboardingState()
      state.currentStep = 3
      state.nickname = "さくら"
      state.basicInfo = BasicInfo(
        age: 25,
        gender: .female,
        weightKg: 52.0,
        heightCm: 158.0
      )
      state.interests = [.beauty, .sleep]
      return state
    }()
  }
#endif
