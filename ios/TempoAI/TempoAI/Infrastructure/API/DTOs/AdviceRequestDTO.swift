import Foundation

// MARK: - AdviceRequestDTO

/// アドバイスリクエストDTO（API用）
struct AdviceRequestDTO: Codable, Equatable, Sendable {
    let profile: ProfileDTO
    let healthData: HealthDataDTO
    let location: LocationDTO
    let context: ContextDTO
    let weather: WeatherDTO?
}

// MARK: - ProfileDTO

/// プロフィールDTO
struct ProfileDTO: Codable, Equatable, Sendable {
    let nickname: String
    let age: Int
    let gender: String
    let chronotype: String
    let occupation: String?
    let exerciseFrequency: String?
    let targetBedtime: String

    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case nickname
        case age
        case gender
        case chronotype
        case occupation
        case exerciseFrequency
        case targetBedtime
    }
}

// MARK: - ProfileDTO+Domain

extension ProfileDTO {

    /// ドメインモデルからDTOを生成
    /// - Parameter profile: UserProfile
    /// - Returns: ProfileDTO
    static func from(_ profile: UserProfile) -> ProfileDTO {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return ProfileDTO(
            nickname: profile.nickname,
            age: profile.age,
            gender: profile.gender.apiValue,
            chronotype: profile.chronotype.apiValue,
            occupation: profile.occupation?.apiValue,
            exerciseFrequency: profile.exerciseFrequency?.apiValue,
            targetBedtime: formatter.string(from: profile.targetBedtime)
        )
    }
}

// MARK: - HealthDataDTO

/// 健康データDTO
struct HealthDataDTO: Codable, Equatable, Sendable {
    let scores: ScoresDTO
    let rhythmAnalysis: RhythmAnalysisDTO
    let sleep: SleepDTO?
    let hrv: HRVDTO?
    let activity: ActivityDTO?
    let auxiliary: AuxiliaryDTO?
}

// MARK: - ScoresDTO

/// スコアDTO
struct ScoresDTO: Codable, Equatable, Sendable {
    let autonomic: Int
    let sleep: Int
    let rhythm: Int
    let activity: Int
}

// MARK: - RhythmAnalysisDTO

/// リズム分析DTO
struct RhythmAnalysisDTO: Codable, Equatable, Sendable {
    let bedtimeStddevMinutes: Double
    let wakeTimeStddevMinutes: Double
    let consecutiveStableDays: Int
    let status: String
}

// MARK: - RhythmAnalysisDTO+Domain

extension RhythmAnalysisDTO {

    /// ドメインモデルからDTOを生成
    static func from(_ analysis: RhythmAnalysis) -> RhythmAnalysisDTO {
        RhythmAnalysisDTO(
            bedtimeStddevMinutes: analysis.bedtimeStddevMinutes,
            wakeTimeStddevMinutes: analysis.wakeTimeStddevMinutes,
            consecutiveStableDays: analysis.consecutiveStableDays,
            status: analysis.status.apiValue
        )
    }
}

// MARK: - SleepDTO

/// 睡眠DTO
struct SleepDTO: Codable, Equatable, Sendable {
    let bedtime: String
    let wakeTime: String
    let durationHours: Double
    let deepSleepMinutes: Int
    let remSleepMinutes: Int
    let deepSleepRatio: Double
}

// MARK: - SleepDTO+Domain

extension SleepDTO {

    /// ドメインモデルからDTOを生成
    static func from(_ sleep: SleepMetrics) -> SleepDTO {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return SleepDTO(
            bedtime: formatter.string(from: sleep.bedtime),
            wakeTime: formatter.string(from: sleep.wakeTime),
            durationHours: sleep.durationHours,
            deepSleepMinutes: sleep.deepSleepMinutes,
            remSleepMinutes: sleep.remSleepMinutes,
            deepSleepRatio: sleep.deepSleepRatio
        )
    }
}

// MARK: - HRVDTO

/// HRV DTO
struct HRVDTO: Codable, Equatable, Sendable {
    let value: Double
    let baseline30d: Double
    let deviationPercent: Double
}

// MARK: - HRVDTO+Domain

extension HRVDTO {

    /// ドメインモデルからDTOを生成
    static func from(_ hrv: HRVMetrics) -> HRVDTO {
        HRVDTO(
            value: hrv.value,
            baseline30d: hrv.baseline30d,
            deviationPercent: hrv.deviationPercent
        )
    }
}

// MARK: - ActivityDTO

/// 活動量DTO
struct ActivityDTO: Codable, Equatable, Sendable {
    let stepsYesterday: Int
    let activeMinutesYesterday: Int
}

// MARK: - ActivityDTO+Domain

extension ActivityDTO {

    /// ドメインモデルからDTOを生成
    static func from(_ activity: ActivityMetrics) -> ActivityDTO {
        ActivityDTO(
            stepsYesterday: activity.stepsYesterday,
            activeMinutesYesterday: activity.activeMinutesYesterday
        )
    }
}

// MARK: - AuxiliaryDTO

/// 補助データDTO
struct AuxiliaryDTO: Codable, Equatable, Sendable {
    let daylightMinutesYesterday: Int?
    let wristTemperatureDeviation: Double?
}

// MARK: - AuxiliaryDTO+Domain

extension AuxiliaryDTO {

    /// ドメインモデルからDTOを生成
    static func from(_ auxiliary: AuxiliaryMetrics) -> AuxiliaryDTO {
        AuxiliaryDTO(
            daylightMinutesYesterday: auxiliary.daylight?.minutesYesterday,
            wristTemperatureDeviation: auxiliary.wristTemperature?.deviation
        )
    }
}

// MARK: - LocationDTO

/// 位置情報DTO
struct LocationDTO: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    let city: String
}

// MARK: - ContextDTO

/// コンテキストDTO
struct ContextDTO: Codable, Equatable, Sendable {
    let currentTime: String
    let dayOfWeek: String
    let todayMode: String
    let mood: Int?
}

// MARK: - WeatherDTO

/// 天気DTO
struct WeatherDTO: Codable, Equatable, Sendable {
    let temperature: Double
    let humidity: Double
    let pressure: Double
    let weatherCode: Int
    let uvIndexMax: Double
}

// MARK: - API Value Extensions

extension Gender {
    /// API用の値
    var apiValue: String {
        switch self {
        case .male: return "male"
        case .female: return "female"
        case .other: return "other"
        case .preferNotToSay: return "preferNotToSay"
        }
    }
}

extension Chronotype {
    /// API用の値
    var apiValue: String {
        switch self {
        case .morning: return "morning"
        case .intermediate: return "intermediate"
        case .evening: return "evening"
        }
    }
}

extension Occupation {
    /// API用の値
    var apiValue: String {
        switch self {
        case .deskWork: return "deskWork"
        case .standingWork: return "standingWork"
        case .physicalWork: return "physicalWork"
        case .hybrid: return "hybrid"
        case .other: return "other"
        }
    }
}

extension ExerciseFrequency {
    /// API用の値
    var apiValue: String {
        switch self {
        case .rarely: return "rarely"
        case .onceWeek: return "onceWeek"
        case .twiceWeek: return "twiceWeek"
        case .threeOrMore: return "threeOrMore"
        case .daily: return "daily"
        }
    }
}

extension RhythmStatus {
    /// API用の値
    var apiValue: String {
        switch self {
        case .stable: return "stable"
        case .recovering: return "recovering"
        case .unstable: return "unstable"
        }
    }
}

// MARK: - TodayMode

/// 今日のモード
enum TodayMode: String, Codable, Sendable {
    case normal = "normal"
    case challenge = "challenge"
    case holiday = "holiday"

    var displayName: String {
        switch self {
        case .normal: return "通常"
        case .challenge: return "頑張る日"
        case .holiday: return "休日"
        }
    }
}
