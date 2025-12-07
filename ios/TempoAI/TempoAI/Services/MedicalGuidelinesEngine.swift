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
                    value: "\(Int(heartRate)) bpm",
                    normalRange: "\(Int(lower))-\(Int(upper)) bpm",
                    explanation: "Elevated resting heart rate may indicate stress or cardiovascular issues",
                    actionRequired: true
                ))
            score = heartRate > (upper + 20) ? 40 : 70
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Resting heart rate is within normal range",
                    value: "\(Int(heartRate)) bpm",
                    normalRange: "\(Int(lower))-\(Int(upper)) bpm",
                    explanation: "Resting heart rate within normal range indicates good cardiovascular health",
                    actionRequired: false
                ))
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(Int(hrv)) ms",
                    normalRange: "~\(Int(expectedHRV)) ms",
                    explanation: "Low HRV may indicate stress or reduced cardiovascular fitness",
                    actionRequired: true
                ))
            score = 60
        } else if ratio > 1.3 {
            findings.append(
                HealthFinding(
                    type: .excellent,
                    severity: .low,
                    description: "Heart rate variability is excellent",
                    value: "\(Int(hrv)) ms",
                    normalRange: "~\(Int(expectedHRV)) ms",
                    explanation: "High HRV indicates excellent cardiovascular fitness and stress resilience",
                    actionRequired: false
                ))
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Heart rate variability is within expected range",
                    value: "\(Int(hrv)) ms",
                    normalRange: "~\(Int(expectedHRV)) ms",
                    explanation: "Normal HRV indicates good cardiovascular health",
                    actionRequired: false
                ))
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(Int(systolic))/\(Int(diastolic)) mmHg",
                    normalRange: "<120/80 mmHg",
                    explanation: "Hypertensive crisis requires immediate medical intervention",
                    actionRequired: true
                ))
            score = 20
        } else if systolic >= 140 || diastolic >= 90 {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Stage 2 Hypertension",
                    value: "\(Int(systolic))/\(Int(diastolic)) mmHg",
                    normalRange: "<120/80 mmHg",
                    explanation: "Stage 2 hypertension requires medical management",
                    actionRequired: true
                ))
            score = 40
        } else if systolic >= 130 || diastolic >= 80 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "Stage 1 Hypertension",
                    value: "\(Int(systolic))/\(Int(diastolic)) mmHg",
                    normalRange: "<120/80 mmHg",
                    explanation: "Stage 1 hypertension - consider lifestyle modifications",
                    actionRequired: true
                ))
            score = 65
        } else if systolic >= 120 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Elevated Blood Pressure",
                    value: "\(Int(systolic))/\(Int(diastolic)) mmHg",
                    normalRange: "<120/80 mmHg",
                    explanation: "Slightly elevated blood pressure - monitor closely",
                    actionRequired: false
                ))
            score = 80
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Normal Blood Pressure",
                    value: "\(Int(systolic))/\(Int(diastolic)) mmHg",
                    normalRange: "<120/80 mmHg",
                    explanation: "Blood pressure is within normal range",
                    actionRequired: false
                ))
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(String(format: "%.1f", hours)) hours",
                    normalRange: "\(min)-\(max) hours",
                    explanation: "Insufficient sleep may impact cognitive function and health",
                    actionRequired: true
                ))
            score = 50
        } else if hours < min {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep duration is below recommendations",
                    value: "\(String(format: "%.1f", hours)) hours",
                    normalRange: "\(min)-\(max) hours",
                    explanation: "Below recommended sleep duration may affect daily performance",
                    actionRequired: false
                ))
            score = 75
        } else if hours > max + 2 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep duration is significantly above recommendations",
                    value: "\(String(format: "%.1f", hours)) hours",
                    normalRange: "\(min)-\(max) hours",
                    explanation: "Excessive sleep may indicate underlying health issues",
                    actionRequired: false
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Sleep duration is within recommended range",
                    value: "\(String(format: "%.1f", hours)) hours",
                    normalRange: "\(min)-\(max) hours",
                    explanation: "Sleep duration meets age-appropriate recommendations",
                    actionRequired: false
                ))
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(String(format: "%.1f", efficiencyPercent))%",
                    normalRange: ">85%",
                    explanation: "Excellent sleep efficiency indicates good sleep quality",
                    actionRequired: false
                ))
        } else if efficiencyPercent >= 85 {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Sleep efficiency is good",
                    value: "\(String(format: "%.1f", efficiencyPercent))%",
                    normalRange: ">85%",
                    explanation: "Good sleep efficiency supports healthy rest",
                    actionRequired: false
                ))
        } else if efficiencyPercent >= 75 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Sleep efficiency could be improved",
                    value: "\(String(format: "%.1f", efficiencyPercent))%",
                    normalRange: ">85%",
                    explanation: "Sleep efficiency below optimal may indicate sleep fragmentation",
                    actionRequired: false
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Sleep efficiency is poor",
                    value: "\(String(format: "%.1f", efficiencyPercent))%",
                    normalRange: ">85%",
                    explanation: "Poor sleep efficiency indicates sleep quality issues requiring attention",
                    actionRequired: true
                ))
            score = 50
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(String(format: "%.1f", breakdown.deepPercentage))%",
                    normalRange: "15-25%",
                    explanation: "Insufficient deep sleep may affect physical recovery and memory consolidation",
                    actionRequired: true
                ))
            score = min(score, 60)
        } else if breakdown.deepPercentage < 15 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Deep sleep could be improved",
                    value: "\(String(format: "%.1f", breakdown.deepPercentage))%",
                    normalRange: "15-25%",
                    explanation: "Below optimal deep sleep may impact recovery and immune function",
                    actionRequired: false
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
                    value: "\(String(format: "%.1f", breakdown.remPercentage))%",
                    normalRange: "20-30%",
                    explanation: "Low REM sleep may affect cognitive function and emotional regulation",
                    actionRequired: false
                ))
            score = min(score, 75)
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(steps) steps",
                    normalRange: "≥\(target) steps",
                    explanation: "Meeting daily step targets supports cardiovascular health and weight management",
                    actionRequired: false
                ))
        } else if steps >= Int(Double(target) * 0.7) {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Daily steps are below recommended target",
                    value: "\(steps) steps",
                    normalRange: "≥\(target) steps",
                    explanation: "Increasing daily activity can improve cardiovascular health and energy levels",
                    actionRequired: false
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Daily steps are significantly below target",
                    value: "\(steps) steps",
                    normalRange: "≥\(target) steps",
                    explanation: "Low activity levels may increase risk of cardiovascular disease and metabolic issues",
                    actionRequired: true
                ))
            score = 50
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(weeklyMinutes) min/week",
                    normalRange: "≥150 min/week",
                    explanation: "Meeting exercise guidelines supports optimal cardiovascular and metabolic health",
                    actionRequired: false
                ))
        } else if weeklyMinutes >= target / 2 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Exercise time is below recommendations",
                    value: "\(weeklyMinutes) min/week",
                    normalRange: "≥150 min/week",
                    explanation: "Increasing exercise duration can improve cardiovascular health and reduce disease risk",
                    actionRequired: false
                ))
            score = 70
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Exercise time is significantly below recommendations",
                    value: "\(weeklyMinutes) min/week",
                    normalRange: "≥150 min/week",
                    explanation: "Insufficient exercise may significantly increase risk of cardiovascular disease and diabetes",
                    actionRequired: true
                ))
            score = 50
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(activeCalories) calories",
                    normalRange: "≥30% of BMR",
                    explanation: "Excellent caloric expenditure indicates high activity levels and metabolic health",
                    actionRequired: false
                ))
        } else if ratio >= 0.2 {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "Active caloric expenditure is adequate",
                    value: "\(activeCalories) calories",
                    normalRange: "≥30% of BMR",
                    explanation: "Adequate caloric expenditure supports healthy weight management and fitness",
                    actionRequired: false
                ))
        } else {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Active caloric expenditure could be increased",
                    value: "\(activeCalories) calories",
                    normalRange: "≥30% of BMR",
                    explanation: "Increasing activity could improve metabolic health and weight management",
                    actionRequired: false
                ))
            score = 70
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(String(format: "%.1f", bmi))",
                    normalRange: "18.5-\(String(format: "%.1f", upperNormalLimit))",
                    explanation: "Underweight BMI may indicate nutritional deficiency or underlying health issues",
                    actionRequired: true
                ))
            score = 60
        } else if bmi <= upperNormalLimit {
            findings.append(
                HealthFinding(
                    type: .normal,
                    severity: .low,
                    description: "BMI is within healthy range",
                    value: "\(String(format: "%.1f", bmi))",
                    normalRange: "18.5-\(String(format: "%.1f", upperNormalLimit))",
                    explanation: "Healthy BMI indicates appropriate weight for height",
                    actionRequired: false
                ))
        } else if bmi <= 29.9 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "BMI indicates overweight",
                    value: "\(String(format: "%.1f", bmi))",
                    normalRange: "18.5-\(String(format: "%.1f", upperNormalLimit))",
                    explanation: "Overweight BMI may increase risk of cardiovascular disease and diabetes",
                    actionRequired: true
                ))
            score = 70
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .high,
                    description: "BMI indicates obesity",
                    value: "\(String(format: "%.1f", bmi))",
                    normalRange: "18.5-\(String(format: "%.1f", upperNormalLimit))",
                    explanation: "Obesity significantly increases risk of cardiovascular disease, diabetes, and other health complications",
                    actionRequired: true
                ))
            score = 50
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
                    value: "\(String(format: "%.1f", bodyFat))%",
                    normalRange: "varies by age/gender",
                    explanation: "Healthy body fat percentage supports optimal metabolic function",
                    actionRequired: false
                ))
        } else if bodyFat <= 30 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Body fat percentage is elevated",
                    value: "\(String(format: "%.1f", bodyFat))%",
                    normalRange: "varies by age/gender",
                    explanation: "Elevated body fat may increase risk of metabolic disorders",
                    actionRequired: false
                ))
            score = 75
        } else {
            findings.append(
                HealthFinding(
                    type: .concerning,
                    severity: .moderate,
                    description: "Body fat percentage is high",
                    value: "\(String(format: "%.1f", bodyFat))%",
                    normalRange: "varies by age/gender",
                    explanation: "High body fat percentage significantly increases risk of cardiovascular disease and diabetes",
                    actionRequired: true
                ))
            score = 60
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
    }

    func analyzeNutrition(_ nutrition: NutritionData, age: Int) -> MedicalAnalysis {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Water intake analysis
        if let water = nutrition.water, water < 1.5 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .low,
                    description: "Water intake may be insufficient",
                    value: "\(String(format: "%.1f", water))L",
                    normalRange: "≥2L/day",
                    explanation: "Adequate hydration is essential for cellular function and metabolic processes",
                    actionRequired: false
                ))
            score = min(score, 75)
        }

        // Sodium analysis
        if let sodium = nutrition.sodium, sodium > 2300 {
            findings.append(
                HealthFinding(
                    type: .warning,
                    severity: .moderate,
                    description: "Sodium intake is above recommended limit",
                    value: "\(Int(sodium))mg",
                    normalRange: "<2300mg/day",
                    explanation: "Excessive sodium intake may increase blood pressure and cardiovascular disease risk",
                    actionRequired: true
                ))
            score = min(score, 70)
        }

        return MedicalAnalysis(
            categoryScore: score,
            findings: findings,
            riskFactors: [],
            recommendations: [],
            referrals: [],
            followUpNeeded: false,
            urgencyLevel: .low
        )
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
