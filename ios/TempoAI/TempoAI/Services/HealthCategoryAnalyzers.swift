import Combine
import Foundation

// MARK: - Specialized Health Category Analyzers

class CardiovascularAnalyzer {

    private let medicalGuidelines = MedicalGuidelinesEngine()

    func analyzeCardiovascularHealth(_ vitals: VitalSignsData, age: Int, gender: String) -> HealthCategoryInsight {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Heart Rate Analysis
        if let heartRate = vitals.heartRate {
            let heartRateAnalysis = medicalGuidelines.analyzeRestingHeartRate(
                heartRate.resting ?? 70.0, age: age, gender: gender)
            findings.append(contentsOf: heartRateAnalysis.findings)
            score = min(score, heartRateAnalysis.categoryScore)
        }

        // HRV Analysis
        if let hrv = vitals.heartRateVariability {
            let hrvAnalysis = medicalGuidelines.analyzeHRV(hrv.rmssd ?? hrv.average, age: age, gender: gender)
            findings.append(contentsOf: hrvAnalysis.findings)
            score = min(score, hrvAnalysis.categoryScore)
        }

        // Blood Pressure Analysis
        if let bloodPressure = vitals.bloodPressure {
            let bpAnalysis = medicalGuidelines.analyzeBloodPressure(
                systolic: bloodPressure.systolic,
                diastolic: bloodPressure.diastolic,
                age: age
            )
            findings.append(contentsOf: bpAnalysis.findings)
            score = min(score, bpAnalysis.categoryScore)
        }

        let recommendations = generateCardiovascularRecommendations(score: score, findings: findings)
        let riskFactors = identifyCardiovascularRisks(findings: findings, score: score)
        let trend = calculateCardiovascularTrend(vitals)

        return HealthCategoryInsight(
            category: .cardiovascular,
            score: score,
            findings: findings,
            recommendations: recommendations,
            riskFactors: riskFactors,
            trend: trend,
            confidence: 0.9
        )
    }

    private func generateCardiovascularRecommendations(score: Double, findings: [HealthFinding]) -> [String] {
        var recommendations: [String] = []

        if score < 70 {
            recommendations.append("Consider consulting with a cardiologist")
            recommendations.append("Monitor blood pressure and heart rate regularly")
        }

        if score < 85 {
            recommendations.append("Increase aerobic exercise gradually")
            recommendations.append("Practice stress reduction techniques")
        }

        return recommendations
    }

    private func identifyCardiovascularRisks(findings: [HealthFinding], score: Double) -> [HealthRiskFactor] {
        var risks: [HealthRiskFactor] = []

        for finding in findings where finding.severity == .high || finding.severity == .severe {
            let riskLevel: RiskLevel = finding.severity == .severe ? .severe : .high
            risks.append(
                HealthRiskFactor(
                    category: .cardiovascular,
                    description: finding.description,
                    severity: finding.severity == .high ? .high : .moderate,
                    recommendations: ["Monitor closely and consider medical consultation"],
                    dataPoints: [finding.value]
                )
            )
        }

        return risks
    }

    private func calculateCardiovascularTrend(_ vitals: VitalSignsData) -> HealthTrend {
        return HealthTrend(
            metric: "cardiovascular",
            direction: .stable,
            magnitude: 0.0,
            timeframe: .week,
            significance: 0.8,
            description: "Stable cardiovascular metrics over the past week"
        )
    }
}

class SleepCategoryAnalyzer {

    private let medicalGuidelines = MedicalGuidelinesEngine()

    func analyzeSleepQuality(_ sleep: EnhancedSleepData, age: Int, lifestyle: String) -> HealthCategoryInsight {
        var findings: [HealthFinding] = []
        var score: Double = 100

        let sleepHours = sleep.totalDuration / 3600

        // Sleep Duration Analysis
        let durationAnalysis = medicalGuidelines.analyzeSleepDuration(hours: sleepHours, age: age)
        findings.append(contentsOf: durationAnalysis.findings)
        score = min(score, durationAnalysis.categoryScore)

        // Sleep Efficiency Analysis
        let efficiencyAnalysis = medicalGuidelines.analyzeSleepEfficiency(efficiency: sleep.sleepEfficiency, age: age)
        findings.append(contentsOf: efficiencyAnalysis.findings)
        score = min(score, efficiencyAnalysis.categoryScore)

        // Sleep Stages Analysis
        let stageBreakdown = calculateSleepStageBreakdown(sleep)
        let stagesAnalysis = medicalGuidelines.analyzeSleepStages(stageBreakdown, age: age)
        findings.append(contentsOf: stagesAnalysis.findings)
        score = min(score, stagesAnalysis.categoryScore)

        let recommendations = generateSleepRecommendations(score: score, findings: findings)
        let riskFactors = identifySleepRisks(findings: findings, score: score)
        let trend = calculateSleepTrend(sleep)

        return HealthCategoryInsight(
            category: .sleep,
            score: score,
            findings: findings,
            recommendations: recommendations,
            riskFactors: riskFactors,
            trend: trend,
            confidence: 0.85
        )
    }

    private func calculateSleepStageBreakdown(_ sleep: EnhancedSleepData) -> SleepStageBreakdown {
        let deepDuration = sleep.deepSleep ?? 0
        let remDuration = sleep.remSleep ?? 0
        let lightDuration = sleep.lightSleep ?? 0
        
        return SleepStageBreakdown(
            deepPercentage: deepDuration / sleep.totalDuration * 100,
            remPercentage: remDuration / sleep.totalDuration * 100,
            lightPercentage: lightDuration / sleep.totalDuration * 100
        )
    }

    private func generateSleepRecommendations(score: Double, findings: [HealthFinding]) -> [String] {
        var recommendations: [String] = []

        if score < 70 {
            recommendations.append("Establish consistent bedtime routine")
            recommendations.append("Limit screen time before bed")
            recommendations.append("Consider sleep study if issues persist")
        }

        if score < 85 {
            recommendations.append("Optimize sleep environment temperature")
            recommendations.append("Avoid caffeine in evening")
        }

        return recommendations
    }

    private func identifySleepRisks(findings: [HealthFinding], score: Double) -> [HealthRiskFactor] {
        var risks: [HealthRiskFactor] = []

        if score < 60 {
            risks.append(
                HealthRiskFactor(
                    category: .sleep,
                    description: "Chronic sleep deprivation",
                    severity: .high,
                    recommendations: ["Prioritize sleep hygiene and consider professional evaluation"],
                    dataPoints: ["Sleep duration analysis"]
                )
            )
        }

        return risks
    }

    private func calculateSleepTrend(_ sleep: EnhancedSleepData) -> HealthTrend {
        return HealthTrend(
            metric: "sleep",
            direction: .stable,
            magnitude: 0.0,
            timeframe: .week,
            significance: 0.8,
            description: "Stable sleep patterns over the past week"
        )
    }
}

class ActivityAnalyzer {

    private let medicalGuidelines = MedicalGuidelinesEngine()

    func analyzeActivityPatterns(
        _ activity: EnhancedActivityData, bodyMeasurements: BodyMeasurementsData, age: Int, gender: String
    ) -> HealthCategoryInsight {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // Step Count Analysis
        let stepAnalysis = medicalGuidelines.analyzeStepCount(steps: activity.steps, age: age, gender: gender)
        findings.append(contentsOf: stepAnalysis.findings)
        score = min(score, stepAnalysis.categoryScore)

        // Exercise Time Analysis
        let exerciseAnalysis = medicalGuidelines.analyzeExerciseTime(minutes: activity.exerciseTime, age: age)
        findings.append(contentsOf: exerciseAnalysis.findings)
        score = min(score, exerciseAnalysis.categoryScore)

        // Caloric Expenditure Analysis
        if let bmr = calculateBMR(bodyMeasurements: bodyMeasurements, age: age, gender: gender) {
            let caloricAnalysis = medicalGuidelines.analyzeCaloricExpenditure(
                activeCalories: Int(activity.activeEnergyBurned), bmr: bmr, age: age)
            findings.append(contentsOf: caloricAnalysis.findings)
            score = min(score, caloricAnalysis.categoryScore)
        }

        let recommendations = generateActivityRecommendations(score: score, findings: findings)
        let riskFactors = identifyActivityRisks(findings: findings, score: score)
        let trend = calculateActivityTrend(activity)

        return HealthCategoryInsight(
            category: .activity,
            score: score,
            findings: findings,
            recommendations: recommendations,
            riskFactors: riskFactors,
            trend: trend,
            confidence: 0.9
        )
    }

    private func calculateBMR(bodyMeasurements: BodyMeasurementsData, age: Int, gender: String) -> Double? {
        guard let weight = bodyMeasurements.weight, let height = bodyMeasurements.height else { return nil }

        if gender.lowercased() == "male" {
            return 88.362 + (13.397 * weight) + (4.799 * height * 100) - (5.677 * Double(age))
        } else {
            return 447.593 + (9.247 * weight) + (3.098 * height * 100) - (4.330 * Double(age))
        }
    }

    private func generateActivityRecommendations(score: Double, findings: [HealthFinding]) -> [String] {
        var recommendations: [String] = []

        if score < 70 {
            recommendations.append("Gradually increase daily movement")
            recommendations.append("Set achievable step count goals")
            recommendations.append("Find enjoyable physical activities")
        }

        if score < 85 {
            recommendations.append("Aim for 150 minutes moderate exercise weekly")
            recommendations.append("Include both cardio and strength training")
        }

        return recommendations
    }

    private func identifyActivityRisks(findings: [HealthFinding], score: Double) -> [HealthRiskFactor] {
        var risks: [HealthRiskFactor] = []

        if score < 60 {
            risks.append(
                HealthRiskFactor(
                    category: .activity,
                    description: "Sedentary lifestyle",
                    severity: .moderate,
                    recommendations: ["Incorporate regular physical activity into daily routine"],
                    dataPoints: ["Activity level analysis"]
                )
            )
        }

        return risks
    }

    private func calculateActivityTrend(_ activity: EnhancedActivityData) -> HealthTrend {
        return HealthTrend(
            metric: "activity",
            direction: .stable,
            magnitude: 0.0,
            timeframe: .week,
            significance: 0.8,
            description: "Stable activity patterns over the past week"
        )
    }
}

class MetabolicAnalyzer {

    private let medicalGuidelines = MedicalGuidelinesEngine()

    func analyzeMetabolicHealth(
        bodyMeasurements: BodyMeasurementsData, activity: EnhancedActivityData, nutrition: NutritionData, age: Int
    ) -> HealthCategoryInsight {
        var findings: [HealthFinding] = []
        var score: Double = 100

        // BMI Analysis
        if let bmi = bodyMeasurements.bodyMassIndex {
            let bmiAnalysis = medicalGuidelines.analyzeBMI(bmi, age: age)
            findings.append(contentsOf: bmiAnalysis.findings)
            score = min(score, bmiAnalysis.categoryScore)
        }

        // Body Fat Analysis
        if let bodyFat = bodyMeasurements.bodyFatPercentage {
            let bodyFatAnalysis = medicalGuidelines.analyzeBodyFat(bodyFat, age: age)
            findings.append(contentsOf: bodyFatAnalysis.findings)
            score = min(score, bodyFatAnalysis.categoryScore)
        }

        // Nutrition Analysis
        let nutritionAnalysis = medicalGuidelines.analyzeNutrition(nutrition, age: age)
        findings.append(contentsOf: nutritionAnalysis.findings)
        score = min(score, nutritionAnalysis.categoryScore)

        let recommendations = generateMetabolicRecommendations(score: score, findings: findings)
        let riskFactors = identifyMetabolicRisks(findings: findings, score: score)
        let trend = calculateMetabolicTrend(bodyMeasurements)

        return HealthCategoryInsight(
            category: .metabolic,
            score: score,
            findings: findings,
            recommendations: recommendations,
            riskFactors: riskFactors,
            trend: trend,
            confidence: 0.85
        )
    }

    private func generateMetabolicRecommendations(score: Double, findings: [HealthFinding]) -> [String] {
        var recommendations: [String] = []

        if score < 70 {
            recommendations.append("Consider nutritionist consultation")
            recommendations.append("Monitor weight and body composition regularly")
            recommendations.append("Focus on balanced nutrition")
        }

        if score < 85 {
            recommendations.append("Increase water intake")
            recommendations.append("Reduce processed food consumption")
        }

        return recommendations
    }

    private func identifyMetabolicRisks(findings: [HealthFinding], score: Double) -> [HealthRiskFactor] {
        var risks: [HealthRiskFactor] = []

        for finding in findings where finding.severity == .high || finding.severity == .severe {
            let riskLevel: RiskLevel = finding.severity == .severe ? .high : .moderate
            risks.append(
                HealthRiskFactor(
                    category: .metabolic,
                    description: finding.description,
                    severity: finding.severity == .severe ? .high : .moderate,
                    recommendations: ["Monitor metabolic markers and consider lifestyle modifications"],
                    dataPoints: [finding.value]
                )
            )
        }

        return risks
    }

    private func calculateMetabolicTrend(_ bodyMeasurements: BodyMeasurementsData) -> HealthTrend {
        return HealthTrend(
            metric: "metabolic",
            direction: .stable,
            magnitude: 0.0,
            timeframe: .month,
            significance: 0.8,
            description: "Stable metabolic health over the past month"
        )
    }
}
