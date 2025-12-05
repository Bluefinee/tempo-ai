import Foundation

// MARK: - Health Data Models

/// Comprehensive health data container for analysis
typealias HealthKitData = HealthData

struct HealthData: Codable {
    let sleep: SleepData?
    let hrv: HRVData?
    let heartRate: HeartRateData?
    let activity: ActivityData?
    let timestamp: Date

    init(
        sleep: SleepData? = nil,
        hrv: HRVData? = nil,
        heartRate: HeartRateData? = nil,
        activity: ActivityData? = nil,
        timestamp: Date = Date()
    ) {
        self.sleep = sleep
        self.hrv = hrv
        self.heartRate = heartRate
        self.activity = activity
        self.timestamp = timestamp
    }
}

struct SleepData: Codable {
    let duration: Double
    let deep: Double?
    let rem: Double?
    let light: Double?
    let awake: Double?
    let efficiency: Double

    // Computed properties for analysis
    var deepSleepHours: Double? { deep }
    var remSleepHours: Double? { rem }
    var lightSleepHours: Double? { light }
    var awakeHours: Double? { awake }

    init(
        duration: Double,
        deep: Double? = nil,
        rem: Double? = nil,
        light: Double? = nil,
        awake: Double? = nil,
        efficiency: Double
    ) {
        self.duration = duration
        self.deep = deep
        self.rem = rem
        self.light = light
        self.awake = awake
        self.efficiency = efficiency
    }
}

struct HRVData: Codable {
    let average: Double?
    let min: Double?
    let max: Double?

    // Computed properties for analysis compatibility
    var averageHRV: Double? { average }

    init(average: Double? = nil, min: Double? = nil, max: Double? = nil) {
        self.average = average
        self.min = min
        self.max = max
    }
}

struct HeartRateData: Codable {
    let resting: Double?
    let average: Double?
    let min: Double?
    let max: Double?

    // Computed properties for analysis compatibility
    var restingHeartRate: Double { resting ?? 70.0 }
    var averageHeartRate: Double { average ?? 80.0 }

    init(
        resting: Double? = nil,
        average: Double? = nil,
        min: Double? = nil,
        max: Double? = nil
    ) {
        self.resting = resting
        self.average = average
        self.min = min
        self.max = max
    }
}

struct ActivityData: Codable {
    let steps: Double
    let distance: Double?
    let calories: Double
    let activeMinutes: Double?

    // Computed properties for analysis
    var activeCalories: Double { calories }
    var exerciseMinutes: Double? { activeMinutes }

    init(
        steps: Double,
        distance: Double? = nil,
        calories: Double,
        activeMinutes: Double? = nil
    ) {
        self.steps = steps
        self.distance = distance
        self.calories = calories
        self.activeMinutes = activeMinutes
    }
}

// MARK: - Location & User Profile
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double

    var isValid: Bool {
        latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0 && !latitude.isInfinite
            && !latitude.isNaN && !longitude.isInfinite && !longitude.isNaN
    }
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
    let id: UUID
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

    // Memberwise initializer for testing and previews
    init(
        id: UUID = UUID(),
        theme: String,
        summary: String,
        breakfast: MealAdvice,
        lunch: MealAdvice,
        dinner: MealAdvice,
        exercise: ExerciseAdvice,
        hydration: HydrationAdvice,
        breathing: BreathingAdvice,
        sleepPreparation: SleepPreparationAdvice,
        weatherConsiderations: WeatherConsiderations,
        priorityActions: [String]
    ) {
        self.id = id
        self.theme = theme
        self.summary = summary
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
        self.exercise = exercise
        self.hydration = hydration
        self.breathing = breathing
        self.sleepPreparation = sleepPreparation
        self.weatherConsiderations = weatherConsiderations
        self.priorityActions = priorityActions
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
