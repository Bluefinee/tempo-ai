import Foundation

// MARK: - OnboardingStep

/// オンボーディングのステップを表す列挙型
enum OnboardingStep: Int, CaseIterable, Sendable {
    case welcome = 1
    case healthKit = 2
    case nickname = 3
    case basicInfo = 4
    case chronotype = 5
    case bedtimeGoal = 6
    case lifestyle = 7
    case location = 8
    case complete = 9

    /// ステップのタイトル
    var title: String {
        switch self {
        case .welcome:
            return "ようこそ"
        case .healthKit:
            return "HealthKit接続"
        case .nickname:
            return "ニックネーム"
        case .basicInfo:
            return "基本情報"
        case .chronotype:
            return "クロノタイプ"
        case .bedtimeGoal:
            return "就寝目標"
        case .lifestyle:
            return "ライフスタイル"
        case .location:
            return "位置情報"
        case .complete:
            return "完了"
        }
    }

    /// プログレス値（0.0〜1.0）
    var progressValue: Double {
        Double(rawValue) / Double(OnboardingStep.allCases.count)
    }

    /// プログレス表示用のステップ（welcome/completeを除く）
    static var progressSteps: [OnboardingStep] {
        allCases.filter { $0 != .welcome && $0 != .complete }
    }
}

// MARK: - OnboardingState

/// オンボーディングの状態を保持する構造体
struct OnboardingState: Codable, Equatable, Sendable {

    // MARK: - User Input Properties

    var nickname: String = ""
    var age: Int = 30
    var gender: Gender = .preferNotToSay
    var weight: Double = 60.0
    var height: Double = 170.0
    var chronotype: Chronotype = .intermediate
    var targetBedtime: Date = Self.defaultBedtime
    var occupation: Occupation? = nil
    var exerciseFrequency: ExerciseFrequency? = nil
    var alcoholFrequency: AlcoholFrequency? = nil

    // MARK: - Authorization States

    var healthKitAuthorized: Bool = false
    var locationAuthorized: Bool = false

    // MARK: - Auto-Estimation Flags

    var chronotypeAutoEstimated: Bool = false
    var bedtimeAutoEstimated: Bool = false

    // MARK: - Computed Properties

    /// BMI計算
    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightInMeters: Double = height / 100
        return weight / (heightInMeters * heightInMeters)
    }

    /// BMI表示文字列
    var bmiDisplayText: String {
        String(format: "%.1f", bmi)
    }

    /// ニックネームバリデーション
    var isNicknameValid: Bool {
        let trimmed: String = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 20
    }

    /// 基本情報バリデーション
    var isBasicInfoValid: Bool {
        weight > 0 && height > 0 && age >= 18 && age <= 100
    }

    // MARK: - Static Properties

    /// デフォルトの就寝目標時刻（23:00）
    static var defaultBedtime: Date {
        var components: DateComponents = DateComponents()
        components.hour = 23
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Conversion to UserProfile

    /// UserProfileに変換
    func toUserProfile() -> UserProfile {
        UserProfile(
            nickname: nickname,
            age: age,
            gender: gender,
            weight: weight,
            height: height,
            occupation: occupation,
            chronotype: chronotype,
            exerciseFrequency: exerciseFrequency,
            alcoholFrequency: alcoholFrequency,
            targetBedtime: targetBedtime
        )
    }
}

// MARK: - OnboardingError

/// オンボーディング関連のエラー型
enum OnboardingError: Error, LocalizedError, Sendable {
    case healthKitNotAvailable
    case healthKitAuthorizationFailed
    case healthKitDataFetchFailed
    case locationAuthorizationFailed
    case saveError(String)
    case invalidNickname
    case invalidBasicInfo

    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable:
            return "HealthKitはこのデバイスでは利用できません"
        case .healthKitAuthorizationFailed:
            return "HealthKitへのアクセスが許可されませんでした"
        case .healthKitDataFetchFailed:
            return "HealthKitからデータを取得できませんでした"
        case .locationAuthorizationFailed:
            return "位置情報へのアクセスが許可されませんでした"
        case .saveError(let message):
            return "データの保存に失敗しました: \(message)"
        case .invalidNickname:
            return "ニックネームが無効です"
        case .invalidBasicInfo:
            return "基本情報が無効です"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .healthKitNotAvailable:
            return "iPhoneまたはApple Watchでお使いください"
        case .healthKitAuthorizationFailed:
            return "設定アプリからHealthKitへのアクセスを許可してください"
        case .healthKitDataFetchFailed:
            return "しばらく時間をおいて再試行してください"
        case .locationAuthorizationFailed:
            return "位置情報は後から設定で有効にできます"
        case .saveError:
            return "アプリを再起動してやり直してください"
        case .invalidNickname:
            return "1〜20文字のニックネームを入力してください"
        case .invalidBasicInfo:
            return "正しい値を入力してください"
        }
    }
}
