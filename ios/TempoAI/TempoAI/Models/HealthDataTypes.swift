import Foundation

// MARK: - Supporting Types and Enums

/// Heart rate zones based on percentage of maximum heart rate
enum HeartRateZone: String, CaseIterable, Codable {
    case resting = "resting"           // <60% HRmax
    case fatBurn = "fat_burn"          // 60-70% HRmax
    case aerobic = "aerobic"           // 70-80% HRmax
    case anaerobic = "anaerobic"       // 80-90% HRmax
    case maxEffort = "max_effort"      // >90% HRmax
    
    /// Calculate zone based on heart rate and age
    static func zone(heartRate: Double, age: Int) -> HeartRateZone {
        let maxHR = Double(220 - age)
        let percentage = heartRate / maxHR
        
        switch percentage {
        case ..<0.6: return .resting
        case 0.6..<0.7: return .fatBurn
        case 0.7..<0.8: return .aerobic
        case 0.8..<0.9: return .anaerobic
        default: return .maxEffort
        }
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
        case 0.2 ..< 0.4: return .lightlyActive
        case 0.4 ..< 0.7: return .moderatelyActive
        case 0.7 ..< 0.9: return .veryActive
        default: return .extremelyActive
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
