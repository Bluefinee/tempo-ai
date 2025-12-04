import Foundation

// MARK: - Health Data Models
struct HealthData: Codable {
    let sleep: SleepData
    let hrv: HRVData
    let heartRate: HeartRateData
    let activity: ActivityData
}

struct SleepData: Codable {
    let duration: Double
    let deep: Double
    let rem: Double
    let light: Double
    let awake: Double
    let efficiency: Int
}

struct HRVData: Codable {
    let average: Double
    let min: Double
    let max: Double
}

struct HeartRateData: Codable {
    let resting: Int
    let average: Int
    let min: Int
    let max: Int
}

struct ActivityData: Codable {
    let steps: Int
    let distance: Double
    let calories: Int
    let activeMinutes: Int
}

// MARK: - Location & User Profile
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
}

struct UserProfile: Codable {
    let age: Int
    let gender: String
    let goals: [String]
    let dietaryPreferences: String
    let exerciseHabits: String
    let exerciseFrequency: String
}

// MARK: - API Request Models
struct AnalysisRequest: Codable {
    let healthData: HealthData
    let location: LocationData
    let userProfile: UserProfile
}

// MARK: - AI Response Models
struct DailyAdvice: Codable, Identifiable {
    var id: UUID = UUID()
    let theme: String
    let summary: String
    let breakfast: MealAdvice
    let lunch: MealAdvice
    let dinner: MealAdvice
    let exercise: ExerciseAdvice
    let hydration: HydrationAdvice
    let breathing: BreathingAdvice
    let sleepPreparation: SleepPreparationAdvice
    let weatherConsiderations: WeatherConsiderations
    let priorityActions: [String]

    private enum CodingKeys: String, CodingKey {
        case id, theme, summary, breakfast, lunch, dinner, exercise, hydration, breathing
        case sleepPreparation = "sleep_preparation"
        case weatherConsiderations = "weather_considerations"
        case priorityActions = "priority_actions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.theme = try container.decode(String.self, forKey: .theme)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.breakfast = try container.decode(MealAdvice.self, forKey: .breakfast)
        self.lunch = try container.decode(MealAdvice.self, forKey: .lunch)
        self.dinner = try container.decode(MealAdvice.self, forKey: .dinner)
        self.exercise = try container.decode(ExerciseAdvice.self, forKey: .exercise)
        self.hydration = try container.decode(HydrationAdvice.self, forKey: .hydration)
        self.breathing = try container.decode(BreathingAdvice.self, forKey: .breathing)
        self.sleepPreparation = try container.decode(SleepPreparationAdvice.self, forKey: .sleepPreparation)
        self.weatherConsiderations = try container.decode(WeatherConsiderations.self, forKey: .weatherConsiderations)
        self.priorityActions = try container.decode([String].self, forKey: .priorityActions)
    }
}

struct MealAdvice: Codable {
    let recommendation: String
    let reason: String
    let examples: [String]?
    let timing: String?
    let avoid: [String]?
}

enum ExerciseIntensity: String, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

struct ExerciseAdvice: Codable {
    let recommendation: String
    let intensity: ExerciseIntensity
    let reason: String
    let timing: String
    let avoid: [String]
}

struct HydrationAdvice: Codable {
    let target: String
    let schedule: HydrationSchedule
    let reason: String
}

struct HydrationSchedule: Codable {
    let morning: String
    let afternoon: String
    let evening: String
}

struct BreathingAdvice: Codable {
    let technique: String
    let duration: String
    let frequency: String
    let instructions: [String]
}

struct SleepPreparationAdvice: Codable {
    let bedtime: String
    let routine: [String]
    let avoid: [String]
}

struct WeatherConsiderations: Codable {
    let warnings: [String]
    let opportunities: [String]
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

struct MockAdviceResponse: Codable {
    let advice: DailyAdvice
}
