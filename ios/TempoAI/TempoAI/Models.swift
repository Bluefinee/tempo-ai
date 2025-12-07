import Foundation
import SwiftUI

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

/// Weather data for contextual health analysis
struct WeatherData: Codable {
    let temperature: Double
    let humidity: Double
    let condition: String
    let uvIndex: Double?
    let airQuality: String?

    init(
        temperature: Double,
        humidity: Double,
        condition: String,
        uvIndex: Double? = nil,
        airQuality: String? = nil
    ) {
        self.temperature = temperature
        self.humidity = humidity
        self.condition = condition
        self.uvIndex = uvIndex
        self.airQuality = airQuality
    }
}

// MARK: - API Request Models

struct RequestContext: Codable {
    let timeOfDay: String
    let dayOfWeek: String
    let season: String
    let previousAdviceFollowed: Bool?
    let userFeedback: String?
    let urgencyLevel: String
    let preferredLanguage: String

    init(
        timeOfDay: String? = nil,
        dayOfWeek: String? = nil,
        season: String? = nil,
        previousAdviceFollowed: Bool? = nil,
        userFeedback: String? = nil,
        urgencyLevel: String = "normal",
        preferredLanguage: String = "en"
    ) {
        let now = Date()
        let calendar = Calendar.current

        // Auto-generate time context if not provided
        self.timeOfDay = timeOfDay ?? RequestContext.generateTimeOfDay(from: now)
        self.dayOfWeek = dayOfWeek ?? RequestContext.generateDayOfWeek(from: now)
        self.season = season ?? RequestContext.generateSeason(from: now)

        self.previousAdviceFollowed = previousAdviceFollowed
        self.userFeedback = userFeedback
        self.urgencyLevel = urgencyLevel
        self.preferredLanguage = preferredLanguage
    }

    private static func generateTimeOfDay(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5 ..< 12: return "morning"
        case 12 ..< 17: return "afternoon"
        case 17 ..< 22: return "evening"
        default: return "night"
        }
    }

    private static func generateDayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).lowercased()
    }

    private static func generateSeason(from date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 12, 1, 2: return "winter"
        case 3, 4, 5: return "spring"
        case 6, 7, 8: return "summer"
        case 9, 10, 11: return "autumn"
        default: return "spring"
        }
    }
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
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id, theme, summary, breakfast, lunch, dinner, exercise, hydration, breathing
        case sleepPreparation = "sleep_preparation"
        case weatherConsiderations = "weather_considerations"
        case priorityActions = "priority_actions"
        case createdAt = "created_at"
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
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
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
        priorityActions: [String],
        createdAt: Date = Date()
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
        self.createdAt = createdAt
    }
}

// MARK: - DailyAdvice Extensions

extension DailyAdvice {
    /// Check if this advice was created today (same calendar day)
    var isFromToday: Bool {
        Calendar.current.isDateInToday(createdAt)
    }

    /// Check if this advice was created on the specified date
    func isFrom(date: Date) -> Bool {
        Calendar.current.isDate(createdAt, inSameDayAs: date)
    }

    /// Get age of this advice in hours
    var ageInHours: Double {
        Date().timeIntervalSince(createdAt) / 3600
    }

    // MARK: - EnhancedAdviceCard Compatibility

    /// Category for advice card display
    var category: Category {
        .general  // Default category, can be made more sophisticated later
    }

    /// Title for display in advice card
    var title: String {
        theme
    }

    /// Detailed information for expanded view
    var details: [String] {
        // Convert summary to an array, split by sentences
        let sentences = summary.components(separatedBy: ". ").filter { !$0.isEmpty }
        return sentences.map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Tips array for display
    var tips: [String] {
        priorityActions
    }

    /// Weather impact information
    var weatherImpact: String? {
        // Extract weather information from weather considerations
        if !weatherConsiderations.opportunities.isEmpty {
            return weatherConsiderations.opportunities.first
        } else if !weatherConsiderations.warnings.isEmpty {
            return weatherConsiderations.warnings.first
        }
        return nil
    }
}

// MARK: - DailyAdvice Category

extension DailyAdvice {
    enum Category {
        case general
        case exercise
        case nutrition
        case sleep
        case mindfulness

        var icon: String {
            switch self {
            case .general: return "sparkles"
            case .exercise: return "figure.run"
            case .nutrition: return "leaf.fill"
            case .sleep: return "moon.stars.fill"
            case .mindfulness: return "brain.head.profile"
            }
        }

        var color: Color {
            switch self {
            case .general: return ColorPalette.info
            case .exercise: return ColorPalette.success
            case .nutrition: return ColorPalette.warning
            case .sleep: return ColorPalette.info
            case .mindfulness: return ColorPalette.info
            }
        }

        var rawValue: String {
            switch self {
            case .general: return "general"
            case .exercise: return "exercise"
            case .nutrition: return "nutrition"
            case .sleep: return "sleep"
            case .mindfulness: return "mindfulness"
            }
        }
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
