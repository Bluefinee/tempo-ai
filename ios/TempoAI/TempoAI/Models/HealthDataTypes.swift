import Foundation
import HealthKit

// MARK: - Supporting Types and Enums

/// Heart rate zones based on percentage of maximum heart rate
enum HeartRateZone: String, CaseIterable, Codable {
    case resting = "resting"  // <60% HRmax
    case fatBurn = "fat_burn"  // 60-70% HRmax
    case aerobic = "aerobic"  // 70-80% HRmax
    case anaerobic = "anaerobic"  // 80-90% HRmax
    case maxEffort = "max_effort"  // >90% HRmax
    case unknown = "unknown"  // Unable to determine

    /// Calculate zone based on heart rate and age
    static func zone(heartRate: Double, age: Int) -> HeartRateZone {
        let maxHR = Double(220 - age)
        let percentage = heartRate / maxHR

        switch percentage {
        case ..<0.6: return .resting
        case 0.6 ..< 0.7: return .fatBurn
        case 0.7 ..< 0.8: return .aerobic
        case 0.8 ..< 0.9: return .anaerobic
        default: return .maxEffort
        }
    }

    /// Classify heart rate zone based on current and resting heart rate
    static func classify(heartRate: Double?, restingRate: Double) -> HeartRateZone {
        guard let heartRate = heartRate else { return .unknown }

        // Estimate age as 30 for general classification
        // In a real app, this would come from user profile
        return zone(heartRate: heartRate, age: 30)
    }
}

/// HRV trend indicators
enum HRVTrend: String, CaseIterable, Codable {
    case improving
    case stable
    case declining
    case unknown
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

/// BMI category classifications
enum BMICategory: String, CaseIterable, Codable {
    case underweight
    case normal
    case overweight
    case obese

    /// Classify BMI into appropriate category
    static func classify(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5 ..< 25: return .normal
        case 25 ..< 30: return .overweight
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
        return deepPercentage >= 15 && deepPercentage <= 25 && remPercentage >= 20 && remPercentage <= 30
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

/// Health data availability assessment structure
struct HealthDataAvailabilityStatus {
    /// Health data types that are available and have recent data
    let availableTypes: [HKQuantityTypeIdentifier]

    /// Health data types missing due to permissions or device limitations
    let missingTypes: [HKQuantityTypeIdentifier]

    /// Health data types with permissions but limited or no recent data
    let limitedTypes: [HKQuantityTypeIdentifier]

    /// Core data sufficiency score (0.0 - 1.0)
    let coreSufficiency: Double

    /// Extended data sufficiency score (0.0 - 1.0)
    let extendedSufficiency: Double

    /// Overall data sufficiency score (0.0 - 1.0)
    let overallSufficiency: Double

    /// User-actionable recommendations to improve data availability
    let recommendations: [String]

    /// Computed properties for easy assessment
    var hasMinimalData: Bool {
        return coreSufficiency >= 0.3  // At least 30% of core data
    }

    var hasSufficientData: Bool {
        return coreSufficiency >= 0.7  // At least 70% of core data
    }

    var hasComprehensiveData: Bool {
        return coreSufficiency >= 0.9 && extendedSufficiency >= 0.5  // 90% core + 50% extended
    }

    /// Generate user-facing data quality message
    var qualityDescription: String {
        if hasComprehensiveData {
            return "Comprehensive health data available"
        } else if hasSufficientData {
            return "Sufficient health data for analysis"
        } else if hasMinimalData {
            return "Limited health data available"
        } else {
            return "Insufficient health data for analysis"
        }
    }
}
