import Foundation

/// Baseline health metrics for age and gender-appropriate health status analysis.
///
/// This struct provides standardized baseline values for various health metrics
/// used in health status calculation, including HRV, heart rate, sleep efficiency,
/// and activity targets based on age and gender demographics.
struct HealthMetricsBaselines {

    // MARK: - HRV Baselines

    /// HRV baselines by age group (milliseconds)
    /// Based on population studies for healthy individuals
    static let hrvBaselines: [Int: Double] = [
        20: 55.0, 25: 50.0, 30: 45.0, 35: 42.0, 40: 38.0,
        45: 35.0, 50: 32.0, 55: 29.0, 60: 26.0, 65: 24.0,
    ]

    // MARK: - Heart Rate Baselines

    /// Resting heart rate baselines by age and gender
    /// Values represent healthy population averages
    static let restingHRBaselines: [String: [Int: Double]] = [
        "male": [20: 60, 30: 62, 40: 64, 50: 66, 60: 68],
        "female": [20: 65, 30: 67, 40: 69, 50: 71, 60: 73],
    ]

    // MARK: - Sleep Baselines

    /// Sleep efficiency targets for health status classification
    static let optimalSleepEfficiency = 0.85
    static let goodSleepEfficiency = 0.75
    static let fairSleepEfficiency = 0.65

    // MARK: - Activity Baselines

    /// Daily step targets for health status classification
    static let optimalSteps = 10000.0
    static let goodSteps = 8000.0
    static let fairSteps = 5000.0

    // MARK: - Baseline Calculation Methods

    /// Calculate age-appropriate HRV baseline
    static func hrvBaseline(for age: Int) -> Double {
        let ageGroups = Array(hrvBaselines.keys).sorted()
        let closestAge = ageGroups.min { abs($0 - age) < abs($1 - age) } ?? 30
        return hrvBaselines[closestAge] ?? 45.0
    }

    /// Calculate age and gender-appropriate resting heart rate baseline
    static func restingHRBaseline(for age: Int, gender: String) -> Double {
        let genderKey = gender.lowercased()
        let baselines = restingHRBaselines[genderKey] ?? restingHRBaselines["male"]!
        let ageGroups = Array(baselines.keys).sorted()
        let closestAge = ageGroups.min { abs($0 - age) < abs($1 - age) } ?? 30
        return baselines[closestAge] ?? 65.0
    }
}
