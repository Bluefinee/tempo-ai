import Combine
import Foundation

class AdvancedRiskAssessment {

    func assessComprehensiveRisks(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile
    ) -> [HealthRiskFactor] {

        var riskFactors: [HealthRiskFactor] = []

        // Cardiovascular Risk Assessment
        riskFactors.append(
            contentsOf: assessCardiovascularRisk(
                vitals: healthData.vitalSigns,
                activity: healthData.activity,
                age: userProfile.age,
                gender: userProfile.gender
            ))

        // Metabolic Risk Assessment
        riskFactors.append(
            contentsOf: assessMetabolicRisk(
                bodyMeasurements: healthData.bodyMeasurements,
                nutrition: healthData.nutrition,
                activity: healthData.activity,
                age: userProfile.age
            ))

        // Sleep-Related Risk Assessment
        riskFactors.append(
            contentsOf: assessSleepRisk(
                sleep: healthData.sleep,
                age: userProfile.age
            ))

        return riskFactors
    }

    private func assessCardiovascularRisk(
        vitals: VitalSignsData,
        activity: EnhancedActivityData,
        age: Int,
        gender: String
    ) -> [HealthRiskFactor] {

        var risks: [HealthRiskFactor] = []

        // Elevated resting heart rate risk
        if let heartRate = vitals.heartRate, heartRate.resting > 90 {
            let riskLevel: RiskLevel = heartRate.resting > 100 ? .high : .moderate
            risks.append(
                HealthRiskFactor(
                    category: .cardiovascular,
                    riskLevel: riskLevel,
                    description: "Elevated resting heart rate may indicate cardiovascular stress",
                    recommendations: [
                        "Increase aerobic exercise gradually",
                        "Consider stress reduction techniques",
                        "Consult healthcare provider if persists",
                    ],
                    timeframe: "Monitor over 2-4 weeks"
                ))
        }

        // Low activity cardiovascular risk
        if activity.steps < 5000 && activity.exerciseTime < 20 {
            risks.append(
                HealthRiskFactor(
                    category: .cardiovascular,
                    riskLevel: .moderate,
                    description: "Low physical activity increases cardiovascular disease risk",
                    recommendations: [
                        "Aim for 150 minutes moderate exercise weekly",
                        "Start with 10-minute walking sessions",
                        "Take stairs instead of elevators",
                    ],
                    timeframe: "Build up over 6-8 weeks"
                ))
        }

        return risks
    }

    private func assessMetabolicRisk(
        bodyMeasurements: BodyMeasurementsData,
        nutrition: NutritionData,
        activity: EnhancedActivityData,
        age: Int
    ) -> [HealthRiskFactor] {

        var risks: [HealthRiskFactor] = []

        // BMI-related metabolic risk
        if let bmi = bodyMeasurements.bodyMassIndex, bmi >= 30 {
            risks.append(
                HealthRiskFactor(
                    category: .metabolic,
                    riskLevel: .high,
                    description: "Obesity increases risk of diabetes and metabolic syndrome",
                    recommendations: [
                        "Aim for 5-10% weight loss initially",
                        "Focus on portion control",
                        "Increase physical activity",
                        "Consider nutritionist consultation",
                    ],
                    timeframe: "6-12 months for sustainable change"
                ))
        }

        // High sodium intake risk
        if nutrition.sodium > 3000 {
            risks.append(
                HealthRiskFactor(
                    category: .metabolic,
                    riskLevel: .moderate,
                    description: "High sodium intake may lead to hypertension",
                    recommendations: [
                        "Reduce processed food consumption",
                        "Cook more meals at home",
                        "Read nutrition labels carefully",
                        "Use herbs and spices instead of salt",
                    ],
                    timeframe: "4-6 weeks to develop habits"
                ))
        }

        return risks
    }

    private func assessSleepRisk(
        sleep: EnhancedSleepData,
        age: Int
    ) -> [HealthRiskFactor] {

        var risks: [HealthRiskFactor] = []

        let sleepHours = sleep.totalDuration / 3600

        // Chronic sleep deprivation risk
        if sleepHours < 6 {
            risks.append(
                HealthRiskFactor(
                    category: .sleep,
                    riskLevel: .high,
                    description: "Chronic sleep deprivation affects immune function and metabolism",
                    recommendations: [
                        "Establish consistent bedtime routine",
                        "Limit screen time 1 hour before bed",
                        "Create sleep-conducive environment",
                        "Consider sleep study if issues persist",
                    ],
                    timeframe: "2-4 weeks to establish routine"
                ))
        }

        // Poor sleep efficiency risk
        if sleep.sleepEfficiency < 0.8 {
            risks.append(
                HealthRiskFactor(
                    category: .sleep,
                    riskLevel: .moderate,
                    description: "Poor sleep efficiency may indicate sleep disorders",
                    recommendations: [
                        "Limit daytime naps",
                        "Avoid caffeine after 2 PM",
                        "Exercise regularly but not close to bedtime",
                        "Manage stress and anxiety",
                    ],
                    timeframe: "4-6 weeks for improvement"
                ))
        }

        return risks
    }
}
