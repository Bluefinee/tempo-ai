//
//  HealthScoreCalculator.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//
//  Main health score calculator that combines all health metrics.
//  Split from HealthScoring.swift to meet file length requirements.
//

import Foundation

// MARK: - Health Score Calculator

/// Main health score calculator that combines all health metrics
enum HealthScoreCalculator {

    /// Calculate overall health score from comprehensive health data
    /// - Parameter data: Complete health data for analysis
    /// - Returns: Structured health score with component breakdowns
    static func calculate(from data: ComprehensiveHealthData) -> HealthScore {
        let vitalSignsScore = calculateVitalSignsScore(data.vitalSigns)
        let activityScore = ActivityScorer.calculateScore(from: data.activity)
        let sleepScore = SleepAnalyzer.calculateQualityScore(from: data.sleep)
        let recoveryScore = calculateRecoveryScore(data.vitalSigns.heartRateVariability)

        // Weighted average of all components
        let overallScore = (vitalSignsScore * 0.25 + activityScore * 0.25 + sleepScore * 0.3 + recoveryScore * 0.2)

        return HealthScore(
            overall: min(max(overallScore, 0), 100),
            vitalSigns: vitalSignsScore,
            activity: activityScore,
            sleep: sleepScore,
            recovery: recoveryScore
        )
    }

    /// Calculate vital signs composite score
    /// - Parameter vitalSigns: Vital signs data
    /// - Returns: Score from 0-100
    private static func calculateVitalSignsScore(_ vitalSigns: VitalSignsData) -> Double {
        var scores: [Double] = []

        // Heart rate score
        if let heartRate = vitalSigns.heartRate {
            scores.append(calculateHeartRateScore(heartRate))
        }

        // HRV is calculated separately as recoveryScore to avoid double counting

        // Blood pressure score
        if let bp = vitalSigns.bloodPressure {
            scores.append(calculateBloodPressureScore(bp))
        }

        // Oxygen saturation score
        if let spo2 = vitalSigns.oxygenSaturation {
            scores.append(calculateOxygenSaturationScore(spo2))
        }

        return scores.isEmpty ? 50.0 : scores.reduce(0, +) / Double(scores.count)
    }

    /// Calculate heart rate score based on resting rate and variability
    /// - Parameter heartRate: Heart rate metrics
    /// - Returns: Score from 0-100
    private static func calculateHeartRateScore(_ heartRate: HeartRateMetrics) -> Double {
        guard let resting = heartRate.resting else { return 50.0 }

        // Age-adjusted ideal resting heart rate ranges
        let idealRange: ClosedRange<Double> = 50 ... 70
        let acceptableRange: ClosedRange<Double> = 60 ... 100

        if idealRange.contains(resting) {
            return 90.0 + (10.0 * (70 - resting) / 20)  // 90-100 for ideal range
        } else if acceptableRange.contains(resting) {
            if resting < 60 {
                return 70.0 + (20.0 * (resting - 40) / 20)  // 70-90 for below ideal
            } else {
                return 70.0 + (20.0 * (100 - resting) / 30)  // 70-90 for above ideal
            }
        } else {
            return resting < 40 ? 30.0 : (resting > 120 ? 20.0 : 40.0)
        }
    }

    /// Calculate blood pressure score
    /// - Parameter bp: Blood pressure reading
    /// - Returns: Score from 0-100
    private static func calculateBloodPressureScore(_ bp: BloodPressureReading) -> Double {
        switch bp.category {
        case .normal: return 95.0
        case .elevated: return 75.0
        case .stage1Hypertension: return 45.0
        case .stage2Hypertension: return 20.0
        }
    }

    /// Calculate oxygen saturation score
    /// - Parameter spo2: Oxygen saturation percentage
    /// - Returns: Score from 0-100
    private static func calculateOxygenSaturationScore(_ spo2: Double) -> Double {
        switch spo2 {
        case 98...: return 100.0
        case 95 ..< 98: return 85.0
        case 90 ..< 95: return 60.0
        case 85 ..< 90: return 30.0
        default: return 10.0
        }
    }

    /// Calculate recovery score from HRV
    /// - Parameter hrv: HRV metrics (optional)
    /// - Returns: Recovery score from 0-100
    private static func calculateRecoveryScore(_ hrv: HRVMetrics?) -> Double {
        guard let hrv = hrv else { return 50.0 }
        return HRVAnalyzer.calculateRecoveryScore(from: hrv)
    }
}
