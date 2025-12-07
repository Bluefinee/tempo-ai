//
//  ComprehensiveHealthData.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//
//  Comprehensive health data models for Phase 2 real HealthKit integration.
//  Supports 20+ health data types with scoring algorithms and analysis.
//

import Foundation
import HealthKit

// MARK: - Comprehensive Health Data Container

/// Comprehensive health data structure containing all collected health metrics
/// Follows Swift coding standards with explicit types and structured organization
struct ComprehensiveHealthData: Codable {
    let vitalSigns: VitalSignsData
    let activity: EnhancedActivityData
    let bodyMeasurements: BodyMeasurementsData
    let sleep: EnhancedSleepData
    let nutrition: NutritionData?
    let timestamp: Date

    /// Calculated overall health score based on all metrics
    var overallHealthScore: HealthScore {
        return HealthScoreCalculator.calculate(from: self)
    }

    init(
        vitalSigns: VitalSignsData,
        activity: EnhancedActivityData,
        bodyMeasurements: BodyMeasurementsData,
        sleep: EnhancedSleepData,
        nutrition: NutritionData? = nil,
        timestamp: Date = Date()
    ) {
        self.vitalSigns = vitalSigns
        self.activity = activity
        self.bodyMeasurements = bodyMeasurements
        self.sleep = sleep
        self.nutrition = nutrition
        self.timestamp = timestamp
    }
}

// MARK: - Vital Signs Data

/// Comprehensive vital signs metrics from HealthKit
struct VitalSignsData: Codable {
    let heartRate: HeartRateMetrics?
    let heartRateVariability: HRVMetrics?
    let oxygenSaturation: Double?
    let respiratoryRate: Double?
    let bodyTemperature: Double?
    let bloodPressure: BloodPressureReading?

    init(
        heartRate: HeartRateMetrics? = nil,
        heartRateVariability: HRVMetrics? = nil,
        oxygenSaturation: Double? = nil,
        respiratoryRate: Double? = nil,
        bodyTemperature: Double? = nil,
        bloodPressure: BloodPressureReading? = nil
    ) {
        self.heartRate = heartRate
        self.heartRateVariability = heartRateVariability
        self.oxygenSaturation = oxygenSaturation
        self.respiratoryRate = respiratoryRate
        self.bodyTemperature = bodyTemperature
        self.bloodPressure = bloodPressure
    }
}

/// Enhanced heart rate metrics with detailed analysis
struct HeartRateMetrics: Codable {
    let current: Double?
    let resting: Double?
    let average: Double
    let min: Double
    let max: Double
    let variabilityScore: Double?

    /// Heart rate zone classification
    var zone: HeartRateZone {
        guard let resting = resting, current != nil else { return .unknown }
        return HeartRateZone.classify(heartRate: average, restingRate: resting)
    }

    init(
        current: Double? = nil,
        resting: Double? = nil,
        average: Double,
        min: Double,
        max: Double,
        variabilityScore: Double? = nil
    ) {
        self.current = current
        self.resting = resting
        self.average = average
        self.min = min
        self.max = max
        self.variabilityScore = variabilityScore
    }
}

/// Heart Rate Variability metrics for stress and recovery analysis
struct HRVMetrics: Codable {
    let sdnn: Double?
    let rmssd: Double?
    let pnn50: Double?
    let average: Double
    let trend: HRVTrend

    /// HRV-based recovery score (0-100)
    var recoveryScore: Double {
        return HRVAnalyzer.calculateRecoveryScore(from: self)
    }

    init(
        sdnn: Double? = nil,
        rmssd: Double? = nil,
        pnn50: Double? = nil,
        average: Double,
        trend: HRVTrend = .stable
    ) {
        self.sdnn = sdnn
        self.rmssd = rmssd
        self.pnn50 = pnn50
        self.average = average
        self.trend = trend
    }
}

/// Blood pressure reading with categorization
struct BloodPressureReading: Codable {
    let systolic: Double
    let diastolic: Double
    let timestamp: Date

    /// Blood pressure category based on medical guidelines
    var category: BloodPressureCategory {
        switch (systolic, diastolic) {
        case (..<120, ..<80): return .normal
        case (120 ..< 130, ..<80): return .elevated
        case (130 ..< 140, 80 ..< 90): return .stage1Hypertension
        case (140..., 90...): return .stage2Hypertension
        default: return .stage1Hypertension
        }
    }

    init(systolic: Double, diastolic: Double, timestamp: Date = Date()) {
        self.systolic = systolic
        self.diastolic = diastolic
        self.timestamp = timestamp
    }
}

// MARK: - Enhanced Activity Data

/// Comprehensive physical activity metrics
struct EnhancedActivityData: Codable {
    let steps: Int
    let distance: Double
    let activeEnergyBurned: Double
    let basalEnergyBurned: Double
    let exerciseTime: Int
    let standHours: Int
    let flights: Int?
    let activeMinutes: Int

    /// Activity level classification based on total metrics
    var activityLevel: HealthDataTypes.ActivityLevel {
        return HealthDataTypes.ActivityLevel.classify(from: self)
    }

    /// Daily activity score (0-100)
    var activityScore: Double {
        return ActivityScorer.calculateScore(from: self)
    }

    init(
        steps: Int,
        distance: Double,
        activeEnergyBurned: Double,
        basalEnergyBurned: Double,
        exerciseTime: Int,
        standHours: Int,
        flights: Int? = nil,
        activeMinutes: Int
    ) {
        self.steps = steps
        self.distance = distance
        self.activeEnergyBurned = activeEnergyBurned
        self.basalEnergyBurned = basalEnergyBurned
        self.exerciseTime = exerciseTime
        self.standHours = standHours
        self.flights = flights
        self.activeMinutes = activeMinutes
    }
}

// MARK: - Body Measurements

/// Comprehensive body measurement data
struct BodyMeasurementsData: Codable {
    let weight: Double?
    let height: Double?
    let bodyMassIndex: Double?
    let bodyFatPercentage: Double?
    let leanBodyMass: Double?
    let waistCircumference: Double?

    /// BMI category classification
    var bmiCategory: BMICategory? {
        guard let bmi = bodyMassIndex else { return nil }
        return BMICategory.classify(bmi: bmi)
    }

    init(
        weight: Double? = nil,
        height: Double? = nil,
        bodyMassIndex: Double? = nil,
        bodyFatPercentage: Double? = nil,
        leanBodyMass: Double? = nil,
        waistCircumference: Double? = nil
    ) {
        self.weight = weight
        self.height = height
        self.bodyMassIndex = bodyMassIndex
        self.bodyFatPercentage = bodyFatPercentage
        self.leanBodyMass = leanBodyMass
        self.waistCircumference = waistCircumference
    }
}

// MARK: - Enhanced Sleep Data

/// Comprehensive sleep analysis data
struct EnhancedSleepData: Codable {
    let totalDuration: TimeInterval
    let inBedTime: TimeInterval
    let deepSleep: TimeInterval?
    let remSleep: TimeInterval?
    let lightSleep: TimeInterval?
    let awakeDuration: TimeInterval?
    let sleepEfficiency: Double
    let bedtime: Date?
    let wakeTime: Date?

    /// Sleep quality score (0-100)
    var qualityScore: Double {
        return SleepAnalyzer.calculateQualityScore(from: self)
    }

    /// Sleep stage breakdown percentages
    var stageBreakdown: SleepStageBreakdown? {
        guard let deep = deepSleep, let rem = remSleep, let light = lightSleep else { return nil }
        return SleepStageBreakdown(
            deepPercentage: (deep / totalDuration) * 100,
            remPercentage: (rem / totalDuration) * 100,
            lightPercentage: (light / totalDuration) * 100
        )
    }

    init(
        totalDuration: TimeInterval,
        inBedTime: TimeInterval,
        deepSleep: TimeInterval? = nil,
        remSleep: TimeInterval? = nil,
        lightSleep: TimeInterval? = nil,
        awakeDuration: TimeInterval? = nil,
        sleepEfficiency: Double,
        bedtime: Date? = nil,
        wakeTime: Date? = nil
    ) {
        self.totalDuration = totalDuration
        self.inBedTime = inBedTime
        self.deepSleep = deepSleep
        self.remSleep = remSleep
        self.lightSleep = lightSleep
        self.awakeDuration = awakeDuration
        self.sleepEfficiency = sleepEfficiency
        self.bedtime = bedtime
        self.wakeTime = wakeTime
    }
}

// MARK: - Nutrition Data

/// Basic nutrition tracking data (when available)
struct NutritionData: Codable {
    let water: Double?
    let calories: Double?
    let protein: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let sodium: Double?

    /// Nutrition balance score based on macronutrient ratios
    var balanceScore: Double? {
        guard let protein = protein, let carbs = carbohydrates, let fat = fat else { return nil }
        return NutritionAnalyzer.calculateBalanceScore(protein: protein, carbs: carbs, fat: fat)
    }

    init(
        water: Double? = nil,
        calories: Double? = nil,
        protein: Double? = nil,
        carbohydrates: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sodium: Double? = nil
    ) {
        self.water = water
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
    }
}
