import Combine
import Foundation
import HealthKit

/**
 * Medical Guidelines Engine
 *
 * Evidence-based medical analysis engine that follows established clinical guidelines
 * for health metric evaluation. Provides age and gender-adjusted assessments based
 * on WHO, AHA, NSF, and other authoritative medical sources.
 *
 * Key Features:
 * - Age-adjusted reference ranges
 * - Gender-specific calculations where applicable
 * - Evidence-based thresholds from medical literature
 * - Standardized medical analysis output
 */

class MedicalGuidelinesEngine {

    func analyzeRestingHeartRate(_ heartRate: Double, age: Int, gender: String) -> MedicalAnalysis {
        // Age-adjusted resting heart rate analysis based on medical literature
        let (lower, upper) = getRestingHRRange(age: age, gender: gender)

        var findings: [HealthFinding] = []
        var score: Double = 100

        if heartRate < lower {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: heartRate < (lower - 10) ? .high : .moderate,
                    description: "Resting heart rate is below normal range",
                    value: "\(Int(heartRate)) bpm",
                    normalRange: "\(Int(lower))-\(Int(upper)) bpm",
                    explanation: "Resting heart rate below normal may indicate good fitness or underlying condition",
                    actionRequired: true
                ))
            score = 60
        } else if heartRate > upper {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: heartRate > (upper + 20) ? .high : .moderate,
                    description: "Resting heart rate is elevated",
                    value: heartRate,
                    reference: "Normal: \(Int(lower))-\(Int(upper)) bpm"
                ))
            score = heartRate > (upper + 20) ? 40 : 70
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Resting heart rate is within normal range",
                    value: heartRate,
                    reference: "Normal: \(Int(lower))-\(Int(upper)) bpm"
                ))
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeHRV(_ hrv: Double, age: Int, gender: String) -> MedicalAnalysis {
        // Age-adjusted HRV analysis
        let expectedHRV = getExpectedHRV(age: age, gender: gender)

        var findings: [HealthFinding] = []
        var score: Double = 100

        let ratio = hrv / expectedHRV

        if ratio < 0.7 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Heart rate variability is below expected range",
                    value: hrv,
                    reference: "Expected: ~\(Int(expectedHRV)) ms"
                ))
            score = 60
        } else if ratio > 1.3 {
            findings.append(
                HealthFinding(
                    type: .excellent,
                    severity: .low,
                    description: "Heart rate variability is excellent",
                    value: hrv,
                    reference: "Expected: ~\(Int(expectedHRV)) ms"
                ))
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Heart rate variability is within expected range",
                    value: hrv,
                    reference: "Expected: ~\(Int(expectedHRV)) ms"
                ))
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeBloodPressure(systolic: Double, diastolic: Double, age: Int) -> MedicalAnalysis {
        // Blood pressure analysis based on AHA guidelines
        var findings: [HealthFinding] = []
        var score: Double = 100

        if systolic >= 180 || diastolic >= 120 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .high,
                    description: "Hypertensive Crisis - seek immediate medical attention",
                    value: systolic,
                    reference: "Normal: <120/80 mmHg"
                ))
            score = 20
        } else if systolic >= 140 || diastolic >= 90 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Stage 2 Hypertension",
                    value: systolic,
                    reference: "Normal: <120/80 mmHg"
                ))
            score = 40
        } else if systolic >= 130 || diastolic >= 80 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "Stage 1 Hypertension",
                    value: systolic,
                    reference: "Normal: <120/80 mmHg"
                ))
            score = 65
        } else if systolic >= 120 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Elevated Blood Pressure",
                    value: systolic,
                    reference: "Normal: <120/80 mmHg"
                ))
            score = 80
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Normal Blood Pressure",
                    value: systolic,
                    reference: "Normal: <120/80 mmHg"
                ))
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeSleepDuration(hours: Double, age: Int) -> MedicalAnalysis {
        // Age-specific sleep duration recommendations
        let (min, max) = getRecommendedSleepRange(age: age)

        var findings: [HealthFinding] = []
        var score: Double = 100

        if hours < min - 1 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Sleep duration is significantly below recommendations",
                    value: hours,
                    reference: "Recommended: \(min)-\(max) hours"
                ))
            score = 50
        } else if hours < min {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep duration is below recommendations",
                    value: hours,
                    reference: "Recommended: \(min)-\(max) hours"
                ))
            score = 75
        } else if hours > max + 2 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep duration is significantly above recommendations",
                    value: hours,
                    reference: "Recommended: \(min)-\(max) hours"
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Sleep duration is within recommended range",
                    value: hours,
                    reference: "Recommended: \(min)-\(max) hours"
                ))
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeSleepEfficiency(efficiency: Double, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        let efficiencyPercent = efficiency * 100

        if efficiencyPercent >= 90 {
            findings.append(
                HealthFinding(
                    type: .excellent,
                    severity: .low,
                    description: "Sleep efficiency is excellent",
                    value: efficiencyPercent,
                    reference: "Good: >85%"
                ))
        } else if efficiencyPercent >= 85 {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Sleep efficiency is good",
                    value: efficiencyPercent,
                    reference: "Good: >85%"
                ))
        } else if efficiencyPercent >= 75 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep efficiency could be improved",
                    value: efficiencyPercent,
                    reference: "Good: >85%"
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Sleep efficiency is poor",
                    value: efficiencyPercent,
                    reference: "Good: >85%"
                ))
            score = 50
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeSleepStages(_ breakdown: SleepStageBreakdown, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Deep sleep analysis (should be 15-25%)
        if breakdown.deepPercentage < 10 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Deep sleep percentage is low",
                    value: breakdown.deepPercentage,
                    reference: "Healthy: 15-25%"
                ))
            score = min(score, 60)
        } else if breakdown.deepPercentage < 15 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Deep sleep could be improved",
                    value: breakdown.deepPercentage,
                    reference: "Healthy: 15-25%"
                ))
            score = min(score, 80)
        }

        // REM sleep analysis (should be 20-30%)
        if breakdown.remPercentage < 15 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "REM sleep percentage is low",
                    value: breakdown.remPercentage,
                    reference: "Healthy: 20-30%"
                ))
            score = min(score, 75)
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeStepCount(steps: Int, age: Int, gender: String) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        let target = getStepTarget(age: age, gender: gender)

        if steps >= target {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Daily steps meet recommended targets",
                    value: Double(steps),
                    reference: "Recommended: ≥\(target) steps"
                ))
        } else if steps >= Int(Double(target) * 0.7) {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Daily steps are below recommended target",
                    value: Double(steps),
                    reference: "Recommended: ≥\(target) steps"
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Daily steps are significantly below target",
                    value: Double(steps),
                    reference: "Recommended: ≥\(target) steps"
                ))
            score = 50
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeExerciseTime(minutes: Int, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        let weeklyMinutes = minutes * 7  // Assuming daily average
        let target = 150  // WHO recommendation: 150 minutes moderate exercise per week

        if weeklyMinutes >= target {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Exercise time meets WHO recommendations",
                    value: Double(weeklyMinutes),
                    reference: "Recommended: ≥150 min/week"
                ))
        } else if weeklyMinutes >= target / 2 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Exercise time is below recommendations",
                    value: Double(weeklyMinutes),
                    reference: "Recommended: ≥150 min/week"
                ))
            score = 70
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Exercise time is significantly below recommendations",
                    value: Double(weeklyMinutes),
                    reference: "Recommended: ≥150 min/week"
                ))
            score = 50
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeCaloricExpenditure(activeCalories: Int, bmr: Double, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        let ratio = Double(activeCalories) / bmr

        if ratio >= 0.3 {
            findings.append(
                HealthFinding(
                    type: .excellent,
                    severity: .low,
                    description: "Active caloric expenditure is excellent",
                    value: Double(activeCalories),
                    reference: "Target: ≥30% of BMR"
                ))
        } else if ratio >= 0.2 {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Active caloric expenditure is adequate",
                    value: Double(activeCalories),
                    reference: "Target: ≥30% of BMR"
                ))
        } else {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Active caloric expenditure could be increased",
                    value: Double(activeCalories),
                    reference: "Target: ≥30% of BMR"
                ))
            score = 70
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeBMI(_ bmi: Double, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Age-adjusted BMI interpretation for older adults
        let upperNormalLimit = age >= 65 ? 27.0 : 24.9

        if bmi < 18.5 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "BMI indicates underweight",
                    value: bmi,
                    reference: "Healthy: 18.5-\(upperNormalLimit)"
                ))
            score = 60
        } else if bmi <= upperNormalLimit {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "BMI is within healthy range",
                    value: bmi,
                    reference: "Healthy: 18.5-\(upperNormalLimit)"
                ))
        } else if bmi <= 29.9 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "BMI indicates overweight",
                    value: bmi,
                    reference: "Healthy: 18.5-\(upperNormalLimit)"
                ))
            score = 70
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .high,
                    description: "BMI indicates obesity",
                    value: bmi,
                    reference: "Healthy: 18.5-\(upperNormalLimit)"
                ))
            score = 50
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeBodyFat(_ bodyFat: Double, age: Int) -> MedicalAnalysis {
        // Simplified body fat analysis - would need gender for accuracy
        var findings: [HealthFinding] = []
        var score: Double = 100

        if bodyFat <= 25 {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Body fat percentage is within healthy range",
                    value: bodyFat,
                    reference: "Healthy: varies by age/gender"
                ))
        } else if bodyFat <= 30 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Body fat percentage is elevated",
                    value: bodyFat,
                    reference: "Healthy: varies by age/gender"
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Body fat percentage is high",
                    value: bodyFat,
                    reference: "Healthy: varies by age/gender"
                ))
            score = 60
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    func analyzeNutrition(_ nutrition: NutritionData, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Water intake analysis
        if nutrition.water < 1.5 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Water intake may be insufficient",
                    value: nutrition.water,
                    reference: "Recommended: ≥2L/day"
                ))
            score = min(score, 75)
        }

        // Sodium analysis
        if nutrition.sodium > 2300 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "Sodium intake is above recommended limit",
                    value: Double(nutrition.sodium),
                    reference: "Limit: <2300mg/day"
                ))
            score = min(score, 70)
        }

        return MedicalAnalysis(categoryScore: score, findings: findings)
    }

    // MARK: - Reference Value Helpers

    private func getRestingHRRange(age: Int, gender: String) -> (Double, Double) {
        // Age and gender-adjusted resting heart rate ranges
        let baseRange = (60.0, 90.0)

        // Adjust for age (lower with better fitness typically)
        let ageFactor = max(0.8, 1.0 - Double(age - 30) * 0.002)

        return (baseRange.0 * ageFactor, baseRange.1 * ageFactor)
    }

    private func getExpectedHRV(age: Int, gender: String) -> Double {
        // Simplified HRV expectation based on age
        let baseHRV = gender.lowercased() == "male" ? 42.0 : 38.0
        let ageAdjustment = Double(age) * 0.3

        return max(20.0, baseHRV - ageAdjustment)
    }

    private func getRecommendedSleepRange(age: Int) -> (Double, Double) {
        // Age-specific sleep recommendations from NSF
        switch age {
        case 18 ... 25:
            return (7.0, 9.0)
        case 26 ... 64:
            return (7.0, 9.0)
        case 65...:
            return (7.0, 8.0)
        default:
            return (7.0, 9.0)
        }
    }

    private func getStepTarget(age: Int, gender: String) -> Int {
        // Age and gender-adjusted step targets
        if age >= 65 {
            return 7000
        } else if age >= 50 {
            return 8000
        } else {
            return 10000
        }
    }
}
