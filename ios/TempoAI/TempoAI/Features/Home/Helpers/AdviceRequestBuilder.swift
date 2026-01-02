//
//  AdviceRequestBuilder.swift
//  TempoAI
//
//  AI Adviceリクエストの構築
//

import CoreLocation
import Foundation

/// AI Adviceリクエストを構築するヘルパー
struct AdviceRequestBuilder {

    // MARK: - Dependencies

    private let profile: UserProfile
    private let conditionAssessment: ConditionAssessment?
    private let rhythmAnalysis: RhythmAnalysis
    private let healthMetrics: HealthMetrics?
    private let weather: WeatherData?
    private let location: CLLocation?
    private let city: String?
    private let todayMode: TodayMode?
    private let mood: Mood?

    // MARK: - Initialization

    init(
        profile: UserProfile,
        conditionAssessment: ConditionAssessment?,
        rhythmAnalysis: RhythmAnalysis,
        healthMetrics: HealthMetrics?,
        weather: WeatherData?,
        location: CLLocation?,
        city: String?,
        todayMode: TodayMode?,
        mood: Mood?
    ) {
        self.profile = profile
        self.conditionAssessment = conditionAssessment
        self.rhythmAnalysis = rhythmAnalysis
        self.healthMetrics = healthMetrics
        self.weather = weather
        self.location = location
        self.city = city
        self.todayMode = todayMode
        self.mood = mood
    }

    // MARK: - Public Methods

    /// AdviceRequestDTOを構築
    func build() -> AdviceRequestDTO {
        let profileDTO: ProfileDTO = ProfileDTO.from(profile)
        let scoresDTO: ScoresDTO = buildScoresDTO()
        let rhythmAnalysisDTO: RhythmAnalysisDTO = RhythmAnalysisDTO.from(rhythmAnalysis)
        let healthDataDTO: HealthDataDTO = buildHealthDataDTO(
            scoresDTO: scoresDTO,
            rhythmAnalysisDTO: rhythmAnalysisDTO
        )
        let contextDTO: ContextDTO = buildContextDTO()
        let locationDTO: LocationDTO = buildLocationDTO()
        let weatherDTO: WeatherDTO? = buildWeatherDTO()

        return AdviceRequestDTO(
            profile: profileDTO,
            healthData: healthDataDTO,
            location: locationDTO,
            context: contextDTO,
            weather: weatherDTO
        )
    }

    // MARK: - Private Methods

    private func buildScoresDTO() -> ScoresDTO {
        ScoresDTO(
            autonomic: conditionAssessment?.autonomicScore.value ?? 50,
            sleep: conditionAssessment?.sleepScore.value ?? 50,
            rhythm: conditionAssessment?.rhythmScore.value ?? 50,
            activity: conditionAssessment?.activityScore.value ?? 50
        )
    }

    private func buildHealthDataDTO(
        scoresDTO: ScoresDTO,
        rhythmAnalysisDTO: RhythmAnalysisDTO
    ) -> HealthDataDTO {
        var sleepDTO: SleepDTO?
        if let sleep = healthMetrics?.sleep {
            sleepDTO = SleepDTO.from(sleep)
        }

        var hrvDTO: HRVDTO?
        if let hrv = healthMetrics?.hrv {
            hrvDTO = HRVDTO.from(hrv)
        }

        var activityDTO: ActivityDTO?
        if let activity = healthMetrics?.activity {
            activityDTO = ActivityDTO.from(activity)
        }

        var auxiliaryDTO: AuxiliaryDTO?
        if let auxiliary = healthMetrics?.auxiliary {
            auxiliaryDTO = AuxiliaryDTO.from(auxiliary)
        }

        return HealthDataDTO(
            scores: scoresDTO,
            rhythmAnalysis: rhythmAnalysisDTO,
            sleep: sleepDTO,
            hrv: hrvDTO,
            activity: activityDTO,
            auxiliary: auxiliaryDTO
        )
    }

    private func buildContextDTO() -> ContextDTO {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime: String = formatter.string(from: Date())

        let weekdaySymbols: [String] = ["", "日", "月", "火", "水", "木", "金", "土"]
        let weekday: Int = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek: String = weekdaySymbols[weekday]

        return ContextDTO(
            currentTime: currentTime,
            dayOfWeek: dayOfWeek,
            todayMode: (todayMode ?? .normal).rawValue,
            mood: mood?.rawValue
        )
    }

    private func buildLocationDTO() -> LocationDTO {
        if let loc = location {
            return LocationDTO(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                city: city ?? "不明"
            )
        } else {
            // デフォルト値（東京）
            return LocationDTO(
                latitude: 35.6762,
                longitude: 139.6503,
                city: "東京"
            )
        }
    }

    private func buildWeatherDTO() -> WeatherDTO? {
        guard let w = weather else { return nil }
        return WeatherDTO(
            temperature: w.temperature,
            humidity: Double(w.humidity),
            pressure: w.pressure,
            weatherCode: w.weatherCode,
            uvIndexMax: Double(w.uvIndex)
        )
    }
}
