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
        case (120..<130, ..<80): return .elevated
        case (130..<140, 80..<90): return .stage1Hypertension
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
    var activityLevel: ActivityLevel {
        return ActivityLevel.classify(from: self)
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

// MARK: - Supporting Types and Enums

/// Heart rate training zones
enum HeartRateZone: String, CaseIterable, Codable {
    case resting = "resting"
    case fatBurn = "fat_burn"
    case cardio = "cardio"
    case anaerobic = "anaerobic"
    case maximum = "maximum"
    case unknown = "unknown"
    
    /// Classify heart rate into appropriate zone
    static func classify(heartRate: Double, restingRate: Double) -> HeartRateZone {
        let maxRate = 220 - 30 // Simplified age assumption
        let percentage = (heartRate - restingRate) / (Double(maxRate) - restingRate)
        
        switch percentage {
        case ..<0.5: return .fatBurn
        case 0.5..<0.7: return .cardio
        case 0.7..<0.9: return .anaerobic
        case 0.9...: return .maximum
        default: return .resting
        }
    }
}

/// HRV trend indicators
enum HRVTrend: String, CaseIterable, Codable {
    case improving = "improving"
    case stable = "stable"
    case declining = "declining"
    case unknown = "unknown"
}

/// Blood pressure categories following medical guidelines
enum BloodPressureCategory: String, CaseIterable, Codable {
    case normal = "normal"
    case elevated = "elevated"
    case stage1Hypertension = "stage1_hypertension"
    case stage2Hypertension = "stage2_hypertension"
    
    var description: String {
        switch self {
        case .normal: return "Normal"
        case .elevated: return "Elevated"
        case .stage1Hypertension: return "Stage 1 Hypertension"
        case .stage2Hypertension: return "Stage 2 Hypertension"
        }
    }
}

/// Activity level classifications
enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extremelyActive = "extremely_active"
    
    /// Classify activity level based on comprehensive metrics
    static func classify(from activity: EnhancedActivityData) -> ActivityLevel {
        let stepScore = min(activity.steps / 10000, 1.0)
        let exerciseScore = min(Double(activity.exerciseTime) / 60.0, 1.0)
        let combinedScore = (stepScore + exerciseScore) / 2.0
        
        switch combinedScore {
        case ..<0.2: return .sedentary
        case 0.2..<0.4: return .lightlyActive
        case 0.4..<0.7: return .moderatelyActive
        case 0.7..<0.9: return .veryActive
        default: return .extremelyActive
        }
    }
}

/// BMI category classifications
enum BMICategory: String, CaseIterable, Codable {
    case underweight = "underweight"
    case normal = "normal"
    case overweight = "overweight"
    case obese = "obese"
    
    /// Classify BMI into appropriate category
    static func classify(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        default: return .obese
        }
    }
}

/// Sleep stage breakdown percentages
struct SleepStageBreakdown: Codable {
    let deepPercentage: Double
    let remPercentage: Double
    let lightPercentage: Double
    
    /// Check if sleep stages are within healthy ranges
    var isHealthy: Bool {
        return deepPercentage >= 15 && deepPercentage <= 25 &&
               remPercentage >= 20 && remPercentage <= 30
    }
}

/// Overall health score container
struct HealthScore: Codable {
    let overall: Double
    let vitalSigns: Double
    let activity: Double
    let sleep: Double
    let recovery: Double
    let timestamp: Date
    
    init(
        overall: Double,
        vitalSigns: Double,
        activity: Double,
        sleep: Double,
        recovery: Double,
        timestamp: Date = Date()
    ) {
        self.overall = overall
        self.vitalSigns = vitalSigns
        self.activity = activity
        self.sleep = sleep
        self.recovery = recovery
        self.timestamp = timestamp
    }
}