import Foundation

/// ユーザープロフィールデータモデル
/// オンボーディングで収集される基本情報と設定を管理
struct UserProfile: Codable, Sendable {

  // MARK: - Properties

  let nickname: String
  let age: Int
  let gender: Gender
  let weightKg: Double
  let heightCm: Double
  let occupation: Occupation?
  let lifestyleRhythm: LifestyleRhythm?
  let exerciseFrequency: ExerciseFrequency?
  let alcoholFrequency: AlcoholFrequency?
  let interests: [Interest]

  // MARK: - Computed Properties

  /// BMI計算
  var bmi: Double {
    let heightInMeters: Double = heightCm / 100.0
    return weightKg / (heightInMeters * heightInMeters)
  }

  /// プロフィール完成度（0.0〜1.0）
  var completionRate: Double {
    let totalFields: Double = 9.0
    var completedFields: Double = 5.0  // 必須フィールド（nickname, age, gender, weight, height）

    if occupation != nil { completedFields += 1.0 }
    if lifestyleRhythm != nil { completedFields += 1.0 }
    if exerciseFrequency != nil { completedFields += 1.0 }
    if alcoholFrequency != nil { completedFields += 1.0 }

    return completedFields / totalFields
  }
}

// MARK: - Gender

extension UserProfile {
  enum Gender: String, Codable, CaseIterable, Sendable {
    case male = "male"
    case female = "female"
    case other = "other"
    case notSpecified = "not_specified"

    var displayName: String {
      switch self {
      case .male:
        return "男性"
      case .female:
        return "女性"
      case .other:
        return "その他"
      case .notSpecified:
        return "回答しない"
      }
    }
  }
}

// MARK: - Occupation

extension UserProfile {
  enum Occupation: String, Codable, CaseIterable, Sendable {
    case itEngineer = "it_engineer"
    case sales = "sales"
    case standingWork = "standing_work"
    case medical = "medical"
    case creative = "creative"
    case homemaker = "homemaker"
    case student = "student"
    case freelance = "freelance"
    case other = "other"

    var displayName: String {
      switch self {
      case .itEngineer:
        return "IT・エンジニア"
      case .sales:
        return "営業・販売"
      case .standingWork:
        return "立ち仕事"
      case .medical:
        return "医療・介護"
      case .creative:
        return "クリエイティブ"
      case .homemaker:
        return "主婦・主夫"
      case .student:
        return "学生"
      case .freelance:
        return "フリーランス"
      case .other:
        return "その他"
      }
    }
  }
}

// MARK: - LifestyleRhythm

extension UserProfile {
  enum LifestyleRhythm: String, Codable, CaseIterable, Sendable {
    case morning = "morning"
    case night = "night"
    case irregular = "irregular"

    var displayName: String {
      switch self {
      case .morning:
        return "朝型"
      case .night:
        return "夜型"
      case .irregular:
        return "不規則"
      }
    }

    var description: String {
      switch self {
      case .morning:
        return "朝早く起きて夜は早めに就寝"
      case .night:
        return "夜遅くまで活動し朝はゆっくり"
      case .irregular:
        return "日によって異なる生活リズム"
      }
    }
  }
}

// MARK: - ExerciseFrequency

extension UserProfile {
  enum ExerciseFrequency: String, Codable, CaseIterable, Sendable {
    case daily = "daily"
    case threeToFour = "three_to_four"
    case oneToTwo = "one_to_two"
    case rarely = "rarely"

    var displayName: String {
      switch self {
      case .daily:
        return "ほぼ毎日"
      case .threeToFour:
        return "週3〜4回"
      case .oneToTwo:
        return "週1〜2回"
      case .rarely:
        return "ほとんどしない"
      }
    }

    var description: String {
      switch self {
      case .daily:
        return "定期的な運動習慣がある"
      case .threeToFour:
        return "運動することが多い"
      case .oneToTwo:
        return "たまに運動する"
      case .rarely:
        return "運動習慣がない"
      }
    }
  }
}

// MARK: - AlcoholFrequency

extension UserProfile {
  enum AlcoholFrequency: String, Codable, CaseIterable, Sendable {
    case never = "never"
    case monthly = "monthly"
    case oneToTwo = "one_to_two"
    case threeOrMore = "three_or_more"

    var displayName: String {
      switch self {
      case .never:
        return "飲まない"
      case .monthly:
        return "月数回"
      case .oneToTwo:
        return "週1〜2回"
      case .threeOrMore:
        return "週3回以上"
      }
    }

    var description: String {
      switch self {
      case .never:
        return "アルコールは飲まない"
      case .monthly:
        return "特別な機会のみ"
      case .oneToTwo:
        return "適度に飲む"
      case .threeOrMore:
        return "定期的に飲む"
      }
    }
  }
}

// MARK: - Interest

extension UserProfile {
  enum Interest: String, Codable, CaseIterable, Sendable {
    case beauty = "beauty"
    case fitness = "fitness"
    case mentalHealth = "mental_health"
    case workPerformance = "work_performance"
    case nutrition = "nutrition"
    case sleep = "sleep"

    var displayName: String {
      switch self {
      case .beauty:
        return "美容・スキンケア"
      case .fitness:
        return "フィットネス・トレーニング"
      case .mentalHealth:
        return "メンタルヘルス・マインドフルネス"
      case .workPerformance:
        return "仕事・パフォーマンス向上"
      case .nutrition:
        return "栄養・食事管理"
      case .sleep:
        return "睡眠改善"
      }
    }

    var icon: String {
      switch self {
      case .beauty:
        return "sparkles"
      case .fitness:
        return "figure.run"
      case .mentalHealth:
        return "brain.head.profile"
      case .workPerformance:
        return "briefcase.fill"
      case .nutrition:
        return "fork.knife"
      case .sleep:
        return "moon.fill"
      }
    }

    var description: String {
      switch self {
      case .beauty:
        return "肌の健康や美容に関するアドバイス"
      case .fitness:
        return "運動や体力向上に関するアドバイス"
      case .mentalHealth:
        return "ストレス管理や心の健康に関するアドバイス"
      case .workPerformance:
        return "集中力や生産性向上に関するアドバイス"
      case .nutrition:
        return "食事や栄養バランスに関するアドバイス"
      case .sleep:
        return "睡眠の質向上に関するアドバイス"
      }
    }
  }
}

// MARK: - Validation

extension UserProfile {
  /// プロフィールの基本バリデーション
  func validate() throws {
    guard !nickname.isEmpty else {
      throw ValidationError.emptyNickname
    }

    guard nickname.count <= 20 else {
      throw ValidationError.nicknameTooLong
    }

    guard (18...100).contains(age) else {
      throw ValidationError.invalidAge
    }

    guard (30.0...200.0).contains(weightKg) else {
      throw ValidationError.invalidWeight
    }

    guard (100.0...250.0).contains(heightCm) else {
      throw ValidationError.invalidHeight
    }

    guard (1...3).contains(interests.count) else {
      throw ValidationError.invalidInterestsCount
    }
  }

  enum ValidationError: Error, LocalizedError {
    case emptyNickname
    case nicknameTooLong
    case invalidAge
    case invalidWeight
    case invalidHeight
    case invalidInterestsCount

    var errorDescription: String? {
      switch self {
      case .emptyNickname:
        return "ニックネームを入力してください"
      case .nicknameTooLong:
        return "ニックネームは20文字以内で入力してください"
      case .invalidAge:
        return "年齢は18歳から100歳の間で入力してください"
      case .invalidWeight:
        return "体重は30kgから200kgの間で入力してください"
      case .invalidHeight:
        return "身長は100cmから250cmの間で入力してください"
      case .invalidInterestsCount:
        return "関心ごとは1つから3つまで選択してください"
      }
    }
  }
}

// MARK: - Sample Data

#if DEBUG
  extension UserProfile {
    static let sampleData: UserProfile = UserProfile(
      nickname: "ゆき",
      age: 28,
      gender: .female,
      weightKg: 55.0,
      heightCm: 160.0,
      occupation: .itEngineer,
      lifestyleRhythm: .morning,
      exerciseFrequency: .oneToTwo,
      alcoholFrequency: .monthly,
      interests: [.sleep, .nutrition, .mentalHealth]
    )
  }
#endif
