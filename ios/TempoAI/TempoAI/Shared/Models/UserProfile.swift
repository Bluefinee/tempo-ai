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
    guard heightInMeters > 0 else { return 0.0 }
    return weightKg / (heightInMeters * heightInMeters)
  }

  /// プロフィール完成度（0.0〜1.0）
  var completionRate: Double {
    let totalFields: Double = 10.0
    var completedFields: Double = 5.0  // 必須フィールド（nickname, age, gender, weight, height）

    if occupation != nil { completedFields += 1.0 }
    if lifestyleRhythm != nil { completedFields += 1.0 }
    if exerciseFrequency != nil { completedFields += 1.0 }
    if alcoholFrequency != nil { completedFields += 1.0 }
    if !interests.isEmpty { completedFields += 1.0 }

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

// MARK: - LifestyleRhythm

extension UserProfile {
  enum LifestyleRhythm: String, Codable, CaseIterable, Sendable {
    case morning
    case night
    case irregular

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

// MARK: - Occupation

extension UserProfile {
  enum Occupation: String, Codable, CaseIterable, Sendable {
    case officeWork = "office_work"         // 事務・オフィスワーク
    case sales = "sales"                    // 営業・接客
    case serviceIndustry = "service_industry" // サービス業
    case medical = "medical"                // 医療・介護
    case education = "education"            // 教育・保育
    case manufacturing = "manufacturing"    // 製造・技術
    case transport = "transport"           // 運輸・物流
    case itEngineer = "it_engineer"        // IT・エンジニア
    case creative = "creative"             // クリエイティブ
    case homemaker = "homemaker"           // 主婦・主夫
    case student = "student"               // 学生
    case other = "other"                   // その他

    var displayName: String {
      switch self {
      case .officeWork:
        return "事務"
      case .sales:
        return "営業・接客"
      case .serviceIndustry:
        return "サービス業"
      case .medical:
        return "医療・介護"
      case .education:
        return "教育・保育"
      case .manufacturing:
        return "製造・技術"
      case .transport:
        return "運輸・物流"
      case .itEngineer:
        return "IT・エンジニア"
      case .creative:
        return "クリエイティブ"
      case .homemaker:
        return "主婦・主夫"
      case .student:
        return "学生"
      case .other:
        return "その他"
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
    case energyPerformance = "energy_performance"  // 1. エネルギー・パフォーマンス
    case nutrition = "nutrition"                   // 2. 栄養・食事
    case fitness = "fitness"                      // 3. 運動・フィットネス
    case mentalStress = "mental_stress"           // 4. メンタル・ストレス
    case beauty = "beauty"                        // 5. 美容・スキンケア
    case sleep = "sleep"                          // 6. 睡眠

    var displayName: String {
      switch self {
      case .energyPerformance:
        return "エネルギー・パフォーマンス"
      case .nutrition:
        return "栄養・食事"
      case .fitness:
        return "運動・フィットネス"
      case .mentalStress:
        return "メンタル・ストレス"
      case .beauty:
        return "美容・スキンケア"
      case .sleep:
        return "睡眠"
      }
    }

    var icon: String {
      switch self {
      case .energyPerformance:
        return "bolt.fill"
      case .nutrition:
        return "fork.knife"
      case .fitness:
        return "figure.run"
      case .mentalStress:
        return "brain.head.profile"
      case .beauty:
        return "sparkles"
      case .sleep:
        return "moon.fill"
      }
    }

    var description: String {
      switch self {
      case .energyPerformance:
        return "日中の活力や集中力、生産性向上に関するアドバイス"
      case .nutrition:
        return "食事や栄養バランスに関するアドバイス"
      case .fitness:
        return "運動や体力向上、フィットネスに関するアドバイス"
      case .mentalStress:
        return "ストレス管理や心の健康、リラクゼーションに関するアドバイス"
      case .beauty:
        return "肌の健康や美容ケアに関するアドバイス"
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
      occupation: .officeWork,
      lifestyleRhythm: .morning,
      exerciseFrequency: .oneToTwo,
      alcoholFrequency: .monthly,
      interests: [.energyPerformance, .nutrition, .sleep]
    )
  }
#endif
