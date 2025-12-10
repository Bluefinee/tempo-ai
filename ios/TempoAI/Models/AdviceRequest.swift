import Foundation

// MARK: - Advice Request Models

/**
 * Request model for daily advice generation
 * Matches the backend AdviceRequest interface
 */
struct AdviceRequest: Codable {
    let userProfile: UserProfile
    let healthData: HealthData
    let location: LocationData
    let context: RequestContext
}

// MARK: - User Profile

struct UserProfile: Codable {
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
    
    enum Gender: String, Codable, CaseIterable {
        case male = "male"
        case female = "female"
        case other = "other"
        case notSpecified = "not_specified"
        
        var displayName: String {
            switch self {
            case .male: return "男性"
            case .female: return "女性"
            case .other: return "その他"
            case .notSpecified: return "回答しない"
            }
        }
    }
    
    enum Occupation: String, Codable, CaseIterable {
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
            case .itEngineer: return "IT・エンジニア"
            case .sales: return "営業・接客"
            case .standingWork: return "立ち仕事"
            case .medical: return "医療・介護"
            case .creative: return "クリエイティブ"
            case .homemaker: return "主婦・主夫"
            case .student: return "学生"
            case .freelance: return "フリーランス"
            case .other: return "その他"
            }
        }
    }
    
    enum LifestyleRhythm: String, Codable, CaseIterable {
        case morning = "morning"
        case night = "night"
        case irregular = "irregular"
        
        var displayName: String {
            switch self {
            case .morning: return "朝型"
            case .night: return "夜型"
            case .irregular: return "不規則"
            }
        }
    }
    
    enum ExerciseFrequency: String, Codable, CaseIterable {
        case daily = "daily"
        case threeToFour = "three_to_four"
        case oneToTwo = "one_to_two"
        case rarely = "rarely"
        
        var displayName: String {
            switch self {
            case .daily: return "ほぼ毎日"
            case .threeToFour: return "週3〜4回"
            case .oneToTwo: return "週1〜2回"
            case .rarely: return "ほとんどしない"
            }
        }
    }
    
    enum AlcoholFrequency: String, Codable, CaseIterable {
        case never = "never"
        case monthly = "monthly"
        case oneToTwo = "one_to_two"
        case threeOrMore = "three_or_more"
        
        var displayName: String {
            switch self {
            case .never: return "飲まない"
            case .monthly: return "月に数回程度"
            case .oneToTwo: return "週1〜2回"
            case .threeOrMore: return "週3回以上"
            }
        }
    }
    
    enum Interest: String, Codable, CaseIterable {
        case beauty = "beauty"
        case fitness = "fitness"
        case mentalHealth = "mental_health"
        case workPerformance = "work_performance"
        case nutrition = "nutrition"
        case sleep = "sleep"
        
        var displayName: String {
            switch self {
            case .beauty: return "美容・スキンケア"
            case .fitness: return "フィットネス・筋トレ"
            case .mentalHealth: return "メンタルヘルス"
            case .workPerformance: return "仕事のパフォーマンス"
            case .nutrition: return "栄養・食事"
            case .sleep: return "睡眠の質"
            }
        }
        
        var emoji: String {
            switch self {
            case .beauty: return "✨"
            case .fitness: return "💪"
            case .mentalHealth: return "🧘"
            case .workPerformance: return "💼"
            case .nutrition: return "🥗"
            case .sleep: return "😴"
            }
        }
    }
}

// MARK: - Health Data

struct HealthData: Codable {
    let date: String // ISO 8601
    let sleep: SleepData?
    let morningVitals: MorningVitals?
    let yesterdayActivity: ActivityData?
    let weekTrends: WeekTrends?
}

struct SleepData: Codable {
    let bedtime: String? // ISO 8601
    let wakeTime: String? // ISO 8601
    let durationHours: Double
    let deepSleepHours: Double?
    let remSleepHours: Double?
    let awakenings: Int
    let avgHeartRate: Int?
}

struct MorningVitals: Codable {
    let restingHeartRate: Int?
    let hrvMs: Double?
    let bloodOxygen: Int?
}

struct ActivityData: Codable {
    let steps: Int
    let workoutMinutes: Int?
    let workoutType: String?
    let caloriesBurned: Int?
}

struct WeekTrends: Codable {
    let avgSleepHours: Double
    let avgHrv: Double?
    let avgRestingHeartRate: Int?
    let avgSteps: Int
    let totalWorkoutHours: Double?
}

// MARK: - Location Data

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let city: String?
}

// MARK: - Request Context

struct RequestContext: Codable {
    let currentTime: String // ISO 8601
    let dayOfWeek: DayOfWeek
    let isMonday: Bool
    let recentDailyTries: [String] // 過去2週間のトピック
    let lastWeeklyTry: String?
    
    enum DayOfWeek: String, Codable, CaseIterable {
        case monday = "monday"
        case tuesday = "tuesday"
        case wednesday = "wednesday"
        case thursday = "thursday"
        case friday = "friday"
        case saturday = "saturday"
        case sunday = "sunday"
        
        var displayName: String {
            switch self {
            case .monday: return "月曜日"
            case .tuesday: return "火曜日"
            case .wednesday: return "水曜日"
            case .thursday: return "木曜日"
            case .friday: return "金曜日"
            case .saturday: return "土曜日"
            case .sunday: return "日曜日"
            }
        }
    }
}