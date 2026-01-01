import Foundation

// MARK: - UserProfile Entity

/// ユーザープロフィール情報
struct UserProfile: Codable, Equatable, Sendable {

    // MARK: - Properties

    let nickname: String
    let age: Int
    let gender: Gender
    let weight: Double
    let height: Double
    let occupation: Occupation?
    let chronotype: Chronotype
    let exerciseFrequency: ExerciseFrequency?
    let alcoholFrequency: AlcoholFrequency?
    let targetBedtime: Date

    // MARK: - Computed Properties

    /// BMI計算
    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightInMeters: Double = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
}

// MARK: - Gender

enum Gender: String, Codable, Sendable, CaseIterable {
    case male = "男性"
    case female = "女性"
    case other = "その他"
    case preferNotToSay = "回答しない"
}

// MARK: - Chronotype

/// クロノタイプ（体内時計の型）
enum Chronotype: String, Codable, Sendable, CaseIterable {
    case morning = "朝型"
    case intermediate = "中間型"
    case evening = "夜型"

    /// 推奨就寝時刻の目安
    var recommendedBedtimeRange: String {
        switch self {
        case .morning:
            return "21:00 - 22:30"
        case .intermediate:
            return "22:00 - 23:30"
        case .evening:
            return "23:00 - 00:30"
        }
    }
}

// MARK: - Occupation

enum Occupation: String, Codable, Sendable, CaseIterable {
    case deskWork = "デスクワーク"
    case standingWork = "立ち仕事"
    case physicalWork = "肉体労働"
    case hybrid = "ハイブリッド"
    case other = "その他"
}

// MARK: - ExerciseFrequency

enum ExerciseFrequency: String, Codable, Sendable, CaseIterable {
    case rarely = "ほとんどしない"
    case onceWeek = "週1回"
    case twiceWeek = "週2回"
    case threeOrMore = "週3回以上"
    case daily = "毎日"
}

// MARK: - AlcoholFrequency

enum AlcoholFrequency: String, Codable, Sendable, CaseIterable {
    case never = "飲まない"
    case rarely = "月に数回"
    case weekly = "週に数回"
    case daily = "ほぼ毎日"
}

// MARK: - CalibrationState

/// キャリブレーション期間の状態管理
struct CalibrationState: Codable, Equatable, Sendable {
    let startDate: Date
    var daysCompleted: Int

    static let requiredDays: Int = 7

    /// キャリブレーション完了状態（computed property）
    var isComplete: Bool {
        daysCompleted >= Self.requiredDays
    }

    init(startDate: Date = Date(), daysCompleted: Int = 0) {
        self.startDate = startDate
        self.daysCompleted = daysCompleted
    }

    mutating func updateProgress(healthDataDays: Int) {
        daysCompleted = min(healthDataDays, Self.requiredDays)
    }

    /// 進捗率（0.0 - 1.0）
    var progressRatio: Double {
        min(1.0, Double(daysCompleted) / Double(Self.requiredDays))
    }

    /// 残り日数
    var remainingDays: Int {
        max(0, Self.requiredDays - daysCompleted)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case startDate
        case daysCompleted
    }
}
