import Foundation

/// Scoring algorithms for health metrics analysis.
///
/// This struct provides standardized scoring methods for converting raw health metrics
/// into normalized scores (0.0 to 1.0) that can be used for health status determination.
/// All scoring algorithms are based on evidence-based health research and population studies.
struct HealthMetricsScoring {


    // MARK: - HRV Scoring

    /// Calculate HRV score based on age-appropriate baseline
    static func calculateHRVScore(
        average: Double?,
        age: Int,
        activityLevel: ActivityLevel = .moderatelyActive
    ) -> Double {
        guard let hrv = average, hrv > 0 else { return 0.0 }

        let baseline = HealthMetricsBaselines.hrvBaseline(for: age)
        let adjustedBaseline = baseline * activityLevel.multiplier

        // Score calculation with sigmoid-like curve
        let ratio = hrv / adjustedBaseline
        let score = min(1.0, max(0.0, (ratio - 0.5) * 2.0))

        return score
    }

    // MARK: - Sleep Scoring

    /// Calculate comprehensive sleep score from multiple sleep metrics
    static func calculateSleepScore(
        duration: Double,
        efficiency: Double,
        deepSleep: Double?,
        remSleep: Double?
    ) -> Double {
        let durationScore = calculateDurationScore(duration)
        let efficiencyScore = calculateEfficiencyScore(efficiency)
        let deepSleepScore = calculateSleepPhaseScore(deepSleep, totalDuration: duration)
        let remSleepScore = calculateSleepPhaseScore(remSleep, totalDuration: duration)

        // Weighted average
        let totalScore =
            (durationScore * 0.4) + (efficiencyScore * 0.3) + (deepSleepScore * 0.15) + (remSleepScore * 0.15)

        return min(1.0, max(0.0, totalScore))
    }

    private static func calculateDurationScore(_ duration: Double) -> Double {
        switch duration {
        case 7.0 ... 9.0: return 1.0
        case 6.0 ... 10.0: return 0.8
        case 5.0 ... 11.0: return 0.6
        default: return 0.3
        }
    }

    private static func calculateEfficiencyScore(_ efficiency: Double) -> Double {
        switch efficiency {
        case HealthMetricsBaselines.optimalSleepEfficiency...: return 1.0
        case HealthMetricsBaselines.goodSleepEfficiency...: return 0.8
        case HealthMetricsBaselines.fairSleepEfficiency...: return 0.6
        default: return 0.3
        }
    }

    private static func calculateSleepPhaseScore(_ phase: Double?, totalDuration: Double) -> Double {
        guard let phase = phase, phase > 0 else { return 0.8 }
        let percentage = phase / totalDuration
        switch percentage {
        case 0.20 ... 0.25: return 1.0
        case 0.15 ... 0.30: return 0.8
        default: return 0.6
        }
    }

    // MARK: - Activity Scoring

    /// Calculate activity score based on steps, calories, and active minutes
    static func calculateActivityScore(
        steps: Double,
        calories: Double,
        activeMinutes: Double?,
        age: Int,
        activityLevel: ActivityLevel = .moderatelyActive
    ) -> Double {
        // Steps score
        let adjustedStepsTarget = HealthMetricsBaselines.optimalSteps * activityLevel.multiplier
        let stepsScore = min(1.0, steps / adjustedStepsTarget)

        // Calories score (age and activity adjusted)
        let baseCalories = 300.0 + Double(max(0, 40 - age)) * 5.0  // Age adjustment
        let adjustedCaloriesTarget = baseCalories * activityLevel.multiplier
        let caloriesScore = min(1.0, calories / adjustedCaloriesTarget)

        // Active minutes score (150 minutes per week = ~21 minutes per day)
        var activeScore = 0.8  // Default if no data
        if let active = activeMinutes {
            activeScore = min(1.0, active / 21.0)
        }

        // Weighted average
        let totalScore = (stepsScore * 0.4) + (caloriesScore * 0.3) + (activeScore * 0.3)
        return min(1.0, max(0.0, totalScore))
    }

    // MARK: - Heart Rate Scoring

    /// Calculate heart rate score based on resting and average heart rate
    static func calculateHeartRateScore(
        resting: Double?,
        average: Double?,
        age: Int,
        gender: String,
        activityLevel: ActivityLevel = .moderatelyActive
    ) -> Double {
        let baseline = HealthMetricsBaselines.restingHRBaseline(for: age, gender: gender)

        // Resting heart rate score
        var restingScore = 0.8  // Default if no data
        if let restingHR = resting {
            let difference = abs(restingHR - baseline) / baseline
            if difference <= 0.1 {
                restingScore = 1.0
            } else if difference <= 0.2 {
                restingScore = 0.8
            } else if difference <= 0.3 {
                restingScore = 0.6
            } else {
                restingScore = 0.4
            }
        }

        // Average heart rate score (should be reasonable above resting)
        var averageScore = 0.8  // Default if no data
        if let avgHR = average, let restingHR = resting {
            let expectedRange = restingHR + 20 ... restingHR + 50
            if expectedRange.contains(avgHR) {
                averageScore = 1.0
            } else {
                let difference = min(
                    abs(avgHR - expectedRange.lowerBound),
                    abs(avgHR - expectedRange.upperBound))
                averageScore = max(0.4, 1.0 - (difference / 30.0))
            }
        }

        // Activity level adjustment
        let adjustmentFactor = activityLevel.multiplier
        let adjustedScore = ((restingScore * 0.7) + (averageScore * 0.3)) * adjustmentFactor

        return min(1.0, max(0.0, adjustedScore))
    }
}
