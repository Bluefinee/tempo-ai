import Foundation
import HealthKit

/**
 * Local Health Analyzer
 *
 * Evidence-based health data analysis engine that operates without AI dependency.
 * Provides comprehensive health insights using medical literature-based algorithms,
 * age/gender-adjusted thresholds, and personalized recommendations.
 *
 * Key Features:
 * - Evidence-based analysis algorithms
 * - Age and gender-adjusted health thresholds
 * - Comprehensive risk factor assessment
 * - Personalized recommendation generation
 * - Multi-language support (Japanese/English)
 * - Fast local processing (<500ms response time)
 */

@MainActor
class LocalHealthAnalyzer: ObservableObject {

    // MARK: - Properties

    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?
    @Published var analysisCache: [String: LocalHealthInsights] = [:]

    private let medicalGuidelines = MedicalGuidelinesEngine()
    private let riskAssessment = AdvancedRiskAssessment()
    private let recommendationEngine = PersonalizedRecommendationEngine()

    // MARK: - Public Analysis Methods

    /// Perform comprehensive local health analysis
    /// - Parameters:
    ///   - healthData: Complete health data for analysis
    ///   - userProfile: User demographics and preferences
    ///   - language: Analysis language (japanese/english)
    /// - Returns: Comprehensive local health insights
    func analyzeComprehensiveHealth(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        language: String = "english"
    ) async -> LocalHealthInsights {

        isAnalyzing = true
        defer { isAnalyzing = false }

        // Check cache first
        let cacheKey = generateCacheKey(healthData: healthData, userProfile: userProfile)
        if let cached = analysisCache[cacheKey],
            Calendar.current.isDate(cached.generatedAt, inSameDayAs: Date())
        {
            return cached
        }

        // Perform comprehensive analysis
        let analysisStart = Date()

        // 1. Cardiovascular Health Analysis
        let cardiovascularInsights = analyzeCardiovascularHealth(
            healthData.vitalSigns,
            age: userProfile.age,
            gender: userProfile.gender
        )

        // 2. Sleep Quality Assessment
        let sleepInsights = analyzeSleepQuality(
            healthData.sleep,
            age: userProfile.age,
            lifestyle: userProfile.exerciseFrequency
        )

        // 3. Activity and Fitness Analysis
        let activityInsights = analyzeActivityPatterns(
            healthData.activity,
            bodyMeasurements: healthData.bodyMeasurements,
            age: userProfile.age,
            gender: userProfile.gender
        )

        // 4. Metabolic Health Assessment
        let metabolicInsights = analyzeMetabolicHealth(
            bodyMeasurements: healthData.bodyMeasurements,
            activity: healthData.activity,
            nutrition: healthData.nutrition,
            age: userProfile.age
        )

        // 5. Risk Factor Identification
        let riskFactors = identifyComprehensiveRiskFactors(
            healthData: healthData,
            userProfile: userProfile
        )

        // 6. Trend Analysis (if historical data available)
        let trends = analyzeTrends(healthData: healthData)

        // 7. Generate Personalized Recommendations
        let recommendations = generatePersonalizedRecommendations(
            insights: [cardiovascularInsights, sleepInsights, activityInsights, metabolicInsights],
            riskFactors: riskFactors,
            userProfile: userProfile,
            language: language
        )

        // 8. Calculate Overall Health Score
        let overallScore = calculateOverallHealthScore(
            cardiovascular: cardiovascularInsights,
            sleep: sleepInsights,
            activity: activityInsights,
            metabolic: metabolicInsights
        )

        // 9. Generate Key Insights
        let keyInsights = generateKeyInsights(
            overallScore: overallScore,
            categoryInsights: [cardiovascularInsights, sleepInsights, activityInsights, metabolicInsights],
            language: language
        )

        let analysisTime = Date().timeIntervalSince(analysisStart)
        print("📊 Local analysis completed in \(Int(analysisTime * 1000))ms")

        let result = LocalHealthInsights(
            overallScore: overallScore,
            keyInsights: keyInsights,
            categoryInsights: CategoryInsights(
                cardiovascular: cardiovascularInsights,
                sleep: sleepInsights,
                activity: activityInsights,
                metabolic: metabolicInsights
            ),
            riskFactors: riskFactors,
            recommendations: recommendations,
            trends: trends,
            dataQuality: assessDataQuality(healthData),
            confidenceScore: calculateConfidenceScore(healthData, userProfile),
            analysisMethod: .evidenceBased,
            generatedAt: Date(),
            language: language
        )

        // Cache the result
        analysisCache[cacheKey] = result
        lastAnalysisDate = Date()

        return result
    }

    /// Quick health assessment for immediate insights
    func quickHealthAssessment(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        language: String = "english"
    ) -> QuickHealthInsights {

        let overallScore = calculateQuickHealthScore(healthData, age: userProfile.age)
        let priority = identifyTopPriority(healthData, userProfile: userProfile)
        let quickTip = generateQuickTip(priority: priority, language: language)

        return QuickHealthInsights(
            score: Int(overallScore),
            summary: generateQuickSummary(score: overallScore, language: language),
            topPriority: priority,
            quickTip: quickTip,
            dataQuality: assessDataQuality(healthData).rawValue,
            timestamp: Date()
        )
    }

    // MARK: - Cardiovascular Health Analysis

    private func analyzeCardiovascularHealth(
        _ vitals: VitalSignsData,
        age: Int,
        gender: String
    ) -> HealthCategoryInsight {

        var findings: [HealthFinding] = []
        var score: Double = 100

        // Analyze Resting Heart Rate with age/gender adjustment
        if let heartRate = vitals.heartRate {
            let restingHRAnalysis = medicalGuidelines.analyzeRestingHeartRate(
                heartRate.resting,
                age: age,
                gender: gender
            )
            findings.append(contentsOf: restingHRAnalysis.findings)
            score = min(score, restingHRAnalysis.categoryScore)
        }

        // Heart Rate Variability Analysis
        if let hrv = vitals.heartRateVariability {
            let hrvAnalysis = medicalGuidelines.analyzeHRV(
                hrv.average,
                age: age,
                gender: gender
            )
            findings.append(contentsOf: hrvAnalysis.findings)
            score = min(score, hrvAnalysis.categoryScore)
        }

        // Blood Pressure Analysis (if available)
        if let bp = vitals.bloodPressure {
            let bpAnalysis = medicalGuidelines.analyzeBloodPressure(
                systolic: bp.systolic,
                diastolic: bp.diastolic,
                age: age
            )
            findings.append(contentsOf: bpAnalysis.findings)
            score = min(score, bpAnalysis.categoryScore)
        }

        return HealthCategoryInsight(
            category: .cardiovascular,
            score: score,
            findings: findings,
            trends: [],
            recommendations: []
        )
    }

    // MARK: - Sleep Quality Assessment

    private func analyzeSleepQuality(
        _ sleep: EnhancedSleepData,
        age: Int,
        lifestyle: String
    ) -> HealthCategoryInsight {

        var findings: [HealthFinding] = []
        var score: Double = 100

        // Sleep Duration Analysis
        let sleepHours = sleep.totalDuration / 3600
        let durationAnalysis = medicalGuidelines.analyzeSleepDuration(
            hours: sleepHours,
            age: age
        )
        findings.append(contentsOf: durationAnalysis.findings)
        score = min(score, durationAnalysis.categoryScore)

        // Sleep Efficiency Analysis
        let efficiencyAnalysis = medicalGuidelines.analyzeSleepEfficiency(
            efficiency: sleep.sleepEfficiency,
            age: age
        )
        findings.append(contentsOf: efficiencyAnalysis.findings)
        score = min(score, efficiencyAnalysis.categoryScore)

        // Sleep Stage Analysis
        let stageBreakdown = calculateSleepStageBreakdown(sleep)
        let stageAnalysis = medicalGuidelines.analyzeSleepStages(stageBreakdown, age: age)
        findings.append(contentsOf: stageAnalysis.findings)
        score = min(score, stageAnalysis.categoryScore)

        return HealthCategoryInsight(
            category: .sleep,
            score: score,
            findings: findings,
            trends: [],
            recommendations: []
        )
    }

    // MARK: - Activity Pattern Analysis

    private func analyzeActivityPatterns(
        _ activity: EnhancedActivityData,
        bodyMeasurements: BodyMeasurementsData,
        age: Int,
        gender: String
    ) -> HealthCategoryInsight {

        var findings: [HealthFinding] = []
        var score: Double = 100

        // Daily Steps Analysis
        let stepsAnalysis = medicalGuidelines.analyzeStepCount(
            steps: activity.steps,
            age: age,
            gender: gender
        )
        findings.append(contentsOf: stepsAnalysis.findings)
        score = min(score, stepsAnalysis.categoryScore)

        // Exercise Time Analysis
        let exerciseAnalysis = medicalGuidelines.analyzeExerciseTime(
            minutes: activity.exerciseTime,
            age: age
        )
        findings.append(contentsOf: exerciseAnalysis.findings)
        score = min(score, exerciseAnalysis.categoryScore)

        // Caloric Expenditure Analysis
        if let bmr = calculateBMR(bodyMeasurements: bodyMeasurements, age: age, gender: gender) {
            let caloricAnalysis = medicalGuidelines.analyzeCaloricExpenditure(
                activeCalories: activity.activeEnergyBurned,
                bmr: bmr,
                age: age
            )
            findings.append(contentsOf: caloricAnalysis.findings)
            score = min(score, caloricAnalysis.categoryScore)
        }

        return HealthCategoryInsight(
            category: .activity,
            score: score,
            findings: findings,
            trends: [],
            recommendations: []
        )
    }

    // MARK: - Metabolic Health Assessment

    private func analyzeMetabolicHealth(
        bodyMeasurements: BodyMeasurementsData,
        activity: EnhancedActivityData,
        nutrition: NutritionData,
        age: Int
    ) -> HealthCategoryInsight {

        var findings: [HealthFinding] = []
        var score: Double = 100

        // BMI Analysis
        if let bmi = bodyMeasurements.bodyMassIndex {
            let bmiAnalysis = medicalGuidelines.analyzeBMI(bmi, age: age)
            findings.append(contentsOf: bmiAnalysis.findings)
            score = min(score, bmiAnalysis.categoryScore)
        }

        // Body Fat Percentage Analysis
        if let bodyFat = bodyMeasurements.bodyFatPercentage {
            let bodyFatAnalysis = medicalGuidelines.analyzeBodyFat(bodyFat, age: age)
            findings.append(contentsOf: bodyFatAnalysis.findings)
            score = min(score, bodyFatAnalysis.categoryScore)
        }

        // Nutrition Analysis
        let nutritionAnalysis = medicalGuidelines.analyzeNutrition(nutrition, age: age)
        findings.append(contentsOf: nutritionAnalysis.findings)
        score = min(score, nutritionAnalysis.categoryScore)

        return HealthCategoryInsight(
            category: .metabolic,
            score: score,
            findings: findings,
            trends: [],
            recommendations: []
        )
    }

    // MARK: - Risk Factor Assessment

    private func identifyComprehensiveRiskFactors(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile
    ) -> [HealthRiskFactor] {

        return riskAssessment.assessComprehensiveRisks(
            healthData: healthData,
            userProfile: userProfile
        )
    }

    // MARK: - Recommendation Generation

    private func generatePersonalizedRecommendations(
        insights: [HealthCategoryInsight],
        riskFactors: [HealthRiskFactor],
        userProfile: UserProfile,
        language: String
    ) -> PersonalizedRecommendations {

        return recommendationEngine.generateRecommendations(
            categoryInsights: insights,
            riskFactors: riskFactors,
            userProfile: userProfile,
            language: language
        )
    }

    // MARK: - Scoring Algorithms

    private func calculateOverallHealthScore(
        cardiovascular: HealthCategoryInsight,
        sleep: HealthCategoryInsight,
        activity: HealthCategoryInsight,
        metabolic: HealthCategoryInsight
    ) -> Double {

        // Weighted scoring based on medical importance
        let weights: [HealthCategory: Double] = [
            .cardiovascular: 0.3,
            .sleep: 0.25,
            .activity: 0.25,
            .metabolic: 0.2,
        ]

        var totalScore: Double = 0
        var totalWeight: Double = 0

        for insight in [cardiovascular, sleep, activity, metabolic] {
            if let weight = weights[insight.category] {
                totalScore += insight.score * weight
                totalWeight += weight
            }
        }

        return totalWeight > 0 ? totalScore / totalWeight : 0
    }

    private func calculateQuickHealthScore(
        _ healthData: ComprehensiveHealthData,
        age: Int
    ) -> Double {
        // Simplified scoring for quick assessment
        let sleepScore = min((healthData.sleep.sleepEfficiency * 100), 100)
        let activityScore = min((Double(healthData.activity.steps) / 10000.0) * 100, 100)
        let hrvScore = healthData.vitalSigns.heartRateVariability?.average ?? 50

        return (sleepScore + activityScore + min(hrvScore, 100)) / 3.0
    }

    // MARK: - Helper Methods

    private func generateCacheKey(healthData: ComprehensiveHealthData, userProfile: UserProfile) -> String {
        let dataHash = "\(healthData.timestamp.timeIntervalSince1970)"
        let profileHash = "\(userProfile.age)-\(userProfile.gender)"
        return "\(dataHash)-\(profileHash)"
    }

    private func assessDataQuality(_ healthData: ComprehensiveHealthData) -> DataQuality {
        var completeness: Double = 0
        var reliability: Double = 100

        // Check vital signs completeness
        if healthData.vitalSigns.heartRate != nil { completeness += 25 }
        if healthData.vitalSigns.heartRateVariability != nil { completeness += 15 }
        if healthData.vitalSigns.bloodPressure != nil { completeness += 10 }

        // Check activity data
        if healthData.activity.steps > 0 { completeness += 25 }
        if healthData.activity.exerciseTime > 0 { completeness += 15 }

        // Check sleep data
        if healthData.sleep.totalDuration > 0 { completeness += 10 }

        return DataQuality(
            completeness: completeness,
            reliability: reliability,
            recency: calculateDataRecency(healthData.timestamp)
        )
    }

    private func calculateConfidenceScore(_ healthData: ComprehensiveHealthData, _ userProfile: UserProfile) -> Double {
        let dataQuality = assessDataQuality(healthData)
        let profileCompleteness = calculateProfileCompleteness(userProfile)

        return (dataQuality.completeness + profileCompleteness) / 2.0
    }

    private func calculateProfileCompleteness(_ userProfile: UserProfile) -> Double {
        var completeness: Double = 50  // Base score for age and gender

        if !userProfile.goals.isEmpty { completeness += 20 }
        if !userProfile.dietaryPreferences.isEmpty { completeness += 15 }
        if !userProfile.exerciseHabits.isEmpty { completeness += 15 }

        return min(completeness, 100)
    }

    private func calculateDataRecency(_ timestamp: Date) -> Double {
        let hoursSince = Date().timeIntervalSince(timestamp) / 3600

        if hoursSince <= 1 { return 100 }
        if hoursSince <= 6 { return 90 }
        if hoursSince <= 24 { return 80 }
        if hoursSince <= 72 { return 60 }
        return 40
    }

    private func calculateSleepStageBreakdown(_ sleep: EnhancedSleepData) -> SleepStageBreakdown {
        let totalSleep = sleep.deepSleep + sleep.remSleep + sleep.lightSleep
        guard totalSleep > 0 else {
            return SleepStageBreakdown(deepPercentage: 0, remPercentage: 0, lightPercentage: 0)
        }

        return SleepStageBreakdown(
            deepPercentage: (sleep.deepSleep / totalSleep) * 100,
            remPercentage: (sleep.remSleep / totalSleep) * 100,
            lightPercentage: (sleep.lightSleep / totalSleep) * 100
        )
    }

    private func calculateBMR(bodyMeasurements: BodyMeasurementsData, age: Int, gender: String) -> Double? {
        guard let weight = bodyMeasurements.weight, let height = bodyMeasurements.height else {
            return nil
        }

        // Mifflin-St Jeor Equation
        let bmr = (10 * weight) + (6.25 * height) - (5 * Double(age))
        return gender.lowercased() == "male" ? bmr + 5 : bmr - 161
    }

    private func analyzeTrends(healthData: ComprehensiveHealthData) -> [HealthTrend] {
        // Placeholder for trend analysis - would require historical data
        return []
    }

    private func generateKeyInsights(
        overallScore: Double,
        categoryInsights: [HealthCategoryInsight],
        language: String
    ) -> [String] {
        var insights: [String] = []

        // Overall assessment
        if language == "japanese" {
            if overallScore >= 80 {
                insights.append("総合的な健康状態は非常に良好です")
            } else if overallScore >= 60 {
                insights.append("健康状態は概ね良好ですが、改善の余地があります")
            } else {
                insights.append("健康状態の改善が推奨されます")
            }
        } else {
            if overallScore >= 80 {
                insights.append("Your overall health status is excellent")
            } else if overallScore >= 60 {
                insights.append("Your health is generally good with room for improvement")
            } else {
                insights.append("Health improvements are recommended")
            }
        }

        // Category-specific insights
        let lowestCategory = categoryInsights.min { $0.score < $1.score }
        if let category = lowestCategory, category.score < 70 {
            let insight = generateCategoryInsight(category: category.category, language: language)
            insights.append(insight)
        }

        return insights
    }

    private func generateCategoryInsight(category: HealthCategory, language: String) -> String {
        if language == "japanese" {
            switch category {
            case .cardiovascular:
                return "心血管系の健康に注意が必要です"
            case .sleep:
                return "睡眠の質の改善が重要です"
            case .activity:
                return "日常的な活動量を増やすことをお勧めします"
            case .metabolic:
                return "代謝の健康状態に改善の余地があります"
            }
        } else {
            switch category {
            case .cardiovascular:
                return "Cardiovascular health requires attention"
            case .sleep:
                return "Sleep quality improvement is important"
            case .activity:
                return "Increasing daily activity is recommended"
            case .metabolic:
                return "Metabolic health could benefit from improvement"
            }
        }
    }

    private func identifyTopPriority(_ healthData: ComprehensiveHealthData, userProfile: UserProfile) -> String {
        // Simple priority identification for quick assessment
        let sleepHours = healthData.sleep.totalDuration / 3600

        if sleepHours < 6 {
            return "sleep"
        } else if healthData.activity.steps < 5000 {
            return "activity"
        } else if healthData.vitalSigns.heartRate?.resting ?? 60 > 90 {
            return "cardiovascular"
        } else {
            return "nutrition"
        }
    }

    private func generateQuickTip(priority: String, language: String) -> String {
        if language == "japanese" {
            switch priority {
            case "sleep":
                return "今夜は早めの就寝を心がけましょう"
            case "activity":
                return "今日は10分多く歩いてみましょう"
            case "cardiovascular":
                return "深呼吸とリラクゼーションを取り入れましょう"
            default:
                return "水分補給と栄養バランスに注意しましょう"
            }
        } else {
            switch priority {
            case "sleep":
                return "Try going to bed 30 minutes earlier tonight"
            case "activity":
                return "Add 10 minutes of walking to your day"
            case "cardiovascular":
                return "Practice deep breathing and relaxation"
            default:
                return "Focus on hydration and balanced nutrition"
            }
        }
    }

    private func generateQuickSummary(score: Double, language: String) -> String {
        if language == "japanese" {
            if score >= 80 {
                return "健康状態は優秀です"
            } else if score >= 60 {
                return "健康状態は良好です"
            } else {
                return "健康状態の改善が推奨されます"
            }
        } else {
            if score >= 80 {
                return "Your health status is excellent"
            } else if score >= 60 {
                return "Your health status is good"
            } else {
                return "Health improvements are recommended"
            }
        }
    }
}

// MARK: - Supporting Types

enum HealthCategory: String, CaseIterable {
    case cardiovascular
    case sleep
    case activity
    case metabolic
}

struct HealthFinding {
    let type: FindingType
    let severity: Severity
    let description: String
    let value: Double?
    let reference: String?
}

enum FindingType: String {
    case normal
    case warning
    case concerning
    case excellent
}

enum Severity: String {
    case low
    case moderate
    case high
}

struct LocalHealthInsights {
    let overallScore: Double
    let keyInsights: [String]
    let categoryInsights: CategoryInsights
    let riskFactors: [HealthRiskFactor]
    let recommendations: PersonalizedRecommendations
    let trends: [HealthTrend]
    let dataQuality: DataQuality
    let confidenceScore: Double
    let analysisMethod: AnalysisMethod
    let generatedAt: Date
    let language: String
}

struct CategoryInsights {
    let cardiovascular: HealthCategoryInsight
    let sleep: HealthCategoryInsight
    let activity: HealthCategoryInsight
    let metabolic: HealthCategoryInsight
}

enum AnalysisMethod: String {
    case evidenceBased = "evidence_based"
    case aiPowered = "ai_powered"
    case hybrid = "hybrid"
}

struct PersonalizedRecommendations {
    let immediate: [ActionableRecommendation]
    let shortTerm: [ActionableRecommendation]
    let longTerm: [ActionableRecommendation]
    let priority: String
}

struct ActionableRecommendation {
    let title: String
    let description: String
    let category: HealthCategory
    let priority: Priority
    let timeframe: String
    let steps: [String]
    let expectedBenefit: String
}

enum Priority: String {
    case low
    case medium
    case high
    case urgent
}

struct DataQuality {
    let completeness: Double
    let reliability: Double
    let recency: Double

    var overall: Double {
        return (completeness + reliability + recency) / 3.0
    }

    var rawValue: String {
        switch overall {
        case 80...:
            return "high"
        case 60 ..< 80:
            return "medium"
        default:
            return "low"
        }
    }
}

struct QuickHealthInsights {
    let score: Int
    let summary: String
    let topPriority: String
    let quickTip: String
    let dataQuality: String
    let timestamp: Date
}

// MARK: - Medical Guidelines Engine

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
                    value: heartRate,
                    reference: "Normal: \(Int(lower))-\(Int(upper)) bpm"
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

struct MedicalAnalysis {
    let categoryScore: Double
    let findings: [HealthFinding]
}

// MARK: - Risk Assessment Engine

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

// MARK: - Personalized Recommendation Engine

class PersonalizedRecommendationEngine {

    func generateRecommendations(
        categoryInsights: [HealthCategoryInsight],
        riskFactors: [HealthRiskFactor],
        userProfile: UserProfile,
        language: String
    ) -> PersonalizedRecommendations {

        // Identify priority areas
        let priorityCategory = identifyPriorityCategory(
            insights: categoryInsights,
            riskFactors: riskFactors
        )

        // Generate immediate recommendations
        let immediate = generateImmediateRecommendations(
            category: priorityCategory,
            userProfile: userProfile,
            language: language
        )

        // Generate short-term recommendations
        let shortTerm = generateShortTermRecommendations(
            categoryInsights: categoryInsights,
            userProfile: userProfile,
            language: language
        )

        // Generate long-term recommendations
        let longTerm = generateLongTermRecommendations(
            riskFactors: riskFactors,
            userProfile: userProfile,
            language: language
        )

        return PersonalizedRecommendations(
            immediate: immediate,
            shortTerm: shortTerm,
            longTerm: longTerm,
            priority: priorityCategory.rawValue
        )
    }

    private func identifyPriorityCategory(
        insights: [HealthCategoryInsight],
        riskFactors: [HealthRiskFactor]
    ) -> HealthCategory {

        // Find category with lowest score
        let lowestScoreCategory = insights.min { $0.score < $1.score }?.category ?? .cardiovascular

        // Check for high-risk factors
        let highRiskCategories =
            riskFactors
            .filter { $0.riskLevel == .high || $0.riskLevel == .critical }
            .map { $0.category }

        return highRiskCategories.first ?? lowestScoreCategory
    }

    private func generateImmediateRecommendations(
        category: HealthCategory,
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        switch category {
        case .cardiovascular:
            recommendations.append(
                generateCardiovascularRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .sleep:
            recommendations.append(
                generateSleepRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .activity:
            recommendations.append(
                generateActivityRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .metabolic:
            recommendations.append(
                generateMetabolicRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))
        }

        return recommendations
    }

    private func generateShortTermRecommendations(
        categoryInsights: [HealthCategoryInsight],
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        // Generate recommendations for categories scoring below 75
        for insight in categoryInsights where insight.score < 75 {
            let recommendation = generateCategoryRecommendation(
                category: insight.category,
                type: .shortTerm,
                userProfile: userProfile,
                language: language
            )
            recommendations.append(recommendation)
        }

        return recommendations
    }

    private func generateLongTermRecommendations(
        riskFactors: [HealthRiskFactor],
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        return riskFactors.map { riskFactor in
            generateRiskMitigationRecommendation(
                riskFactor: riskFactor,
                userProfile: userProfile,
                language: language
            )
        }
    }

    // MARK: - Category-Specific Recommendation Generators

    private func generateCardiovascularRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "心血管健康の改善",
                    description: "今日から始められる心血管健康の向上策",
                    category: .cardiovascular,
                    priority: .high,
                    timeframe: "今日から",
                    steps: [
                        "10分間の軽い散歩をする",
                        "深呼吸を5分間行う",
                        "水分を十分に摂取する",
                    ],
                    expectedBenefit: "血行改善とストレス軽減"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "心血管フィットネスの向上",
                    description: "持続的な心血管健康の改善計画",
                    category: .cardiovascular,
                    priority: .medium,
                    timeframe: "4-8週間",
                    steps: [
                        "週3回の有酸素運動",
                        "階段利用の習慣化",
                        "定期的な心拍数モニタリング",
                    ],
                    expectedBenefit: "心血管疾患リスクの低減"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Cardiovascular Health Boost",
                    description: "Immediate actions to support heart health",
                    category: .cardiovascular,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Take a 10-minute light walk",
                        "Practice 5 minutes of deep breathing",
                        "Stay well-hydrated",
                    ],
                    expectedBenefit: "Improved circulation and stress reduction"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Cardiovascular Fitness Improvement",
                    description: "Sustainable plan for heart health enhancement",
                    category: .cardiovascular,
                    priority: .medium,
                    timeframe: "4-8 weeks",
                    steps: [
                        "Engage in aerobic exercise 3x per week",
                        "Take stairs instead of elevators",
                        "Monitor heart rate regularly",
                    ],
                    expectedBenefit: "Reduced cardiovascular disease risk"
                )
            }
        }
    }

    private func generateSleepRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "今夜の睡眠改善",
                    description: "今夜からできる睡眠の質向上",
                    category: .sleep,
                    priority: .high,
                    timeframe: "今夜から",
                    steps: [
                        "就寝1時間前にスクリーンタイムを止める",
                        "室温を18-21℃に調整する",
                        "リラクゼーション音楽を聴く",
                    ],
                    expectedBenefit: "睡眠の質と回復の向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "睡眠習慣の最適化",
                    description: "長期的な睡眠の質向上計画",
                    category: .sleep,
                    priority: .medium,
                    timeframe: "2-4週間",
                    steps: [
                        "一定の就寝時間を確立する",
                        "就寝前ルーティンを作る",
                        "カフェイン摂取時間を管理する",
                    ],
                    expectedBenefit: "総合的な健康と認知機能の向上"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Tonight's Sleep Enhancement",
                    description: "Immediate actions for better sleep tonight",
                    category: .sleep,
                    priority: .high,
                    timeframe: "Tonight",
                    steps: [
                        "Stop screen time 1 hour before bed",
                        "Set room temperature to 65-70°F",
                        "Listen to calming music or sounds",
                    ],
                    expectedBenefit: "Improved sleep quality and recovery"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Sleep Habit Optimization",
                    description: "Long-term plan for sleep quality improvement",
                    category: .sleep,
                    priority: .medium,
                    timeframe: "2-4 weeks",
                    steps: [
                        "Establish consistent bedtime",
                        "Create pre-sleep routine",
                        "Manage caffeine intake timing",
                    ],
                    expectedBenefit: "Enhanced overall health and cognitive function"
                )
            }
        }
    }

    private func generateActivityRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "今日の活動量アップ",
                    description: "今日すぐにできる活動量の増加",
                    category: .activity,
                    priority: .high,
                    timeframe: "今日",
                    steps: [
                        "階段を使って移動する",
                        "15分間の散歩をする",
                        "立って仕事や作業を行う",
                    ],
                    expectedBenefit: "エネルギーレベルと気分の向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "活動習慣の構築",
                    description: "持続可能な運動習慣の確立",
                    category: .activity,
                    priority: .medium,
                    timeframe: "4-6週間",
                    steps: [
                        "週150分の中強度運動を目指す",
                        "日常生活に運動を組み込む",
                        "進歩を追跡・記録する",
                    ],
                    expectedBenefit: "長期的な健康と体力の向上"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Today's Activity Boost",
                    description: "Immediate ways to increase daily movement",
                    category: .activity,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Take stairs instead of elevators",
                        "Go for a 15-minute walk",
                        "Stand while working when possible",
                    ],
                    expectedBenefit: "Increased energy levels and mood"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Activity Habit Building",
                    description: "Sustainable exercise routine development",
                    category: .activity,
                    priority: .medium,
                    timeframe: "4-6 weeks",
                    steps: [
                        "Aim for 150 minutes moderate exercise weekly",
                        "Integrate movement into daily routines",
                        "Track and celebrate progress",
                    ],
                    expectedBenefit: "Long-term health and fitness improvements"
                )
            }
        }
    }

    private func generateMetabolicRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "代謝の活性化",
                    description: "今日からできる代謝改善策",
                    category: .metabolic,
                    priority: .high,
                    timeframe: "今日",
                    steps: [
                        "水分摂取を増やす",
                        "バランスの取れた食事を心がける",
                        "食後に軽い散歩をする",
                    ],
                    expectedBenefit: "代謝機能とエネルギーの向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "代謝健康の最適化",
                    description: "長期的な代謝改善計画",
                    category: .metabolic,
                    priority: .medium,
                    timeframe: "6-12週間",
                    steps: [
                        "栄養バランスの見直し",
                        "適正体重の維持",
                        "定期的な健康チェック",
                    ],
                    expectedBenefit: "生活習慣病の予防と健康寿命の延伸"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Metabolic Activation",
                    description: "Immediate steps to boost metabolism",
                    category: .metabolic,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Increase water intake",
                        "Choose balanced, nutritious meals",
                        "Take a light walk after meals",
                    ],
                    expectedBenefit: "Enhanced metabolic function and energy"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Metabolic Health Optimization",
                    description: "Long-term metabolic improvement strategy",
                    category: .metabolic,
                    priority: .medium,
                    timeframe: "6-12 weeks",
                    steps: [
                        "Review and improve nutritional balance",
                        "Maintain healthy weight range",
                        "Schedule regular health checkups",
                    ],
                    expectedBenefit: "Prevention of lifestyle diseases and longevity"
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func generateCategoryRecommendation(
        category: HealthCategory,
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        switch category {
        case .cardiovascular:
            return generateCardiovascularRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .sleep:
            return generateSleepRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .activity:
            return generateActivityRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .metabolic:
            return generateMetabolicRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        }
    }

    private func generateRiskMitigationRecommendation(
        riskFactor: HealthRiskFactor,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        let priority: Priority = {
            switch riskFactor.riskLevel {
            case .critical: return .urgent
            case .high: return .high
            case .moderate: return .medium
            case .low: return .low
            }
        }()

        return ActionableRecommendation(
            title: language == "japanese"
                ? "\(riskFactor.category.rawValue)リスクの軽減"
                : "\(riskFactor.category.rawValue.capitalized) Risk Mitigation",
            description: riskFactor.description,
            category: riskFactor.category,
            priority: priority,
            timeframe: riskFactor.timeframe,
            steps: riskFactor.recommendations,
            expectedBenefit: language == "japanese" ? "健康リスクの軽減" : "Reduced health risk"
        )
    }
}

enum RecommendationType {
    case immediate
    case shortTerm
    case longTerm
}

// MARK: - User Profile Extension

extension UserProfile {
    var estimatedFitnessLevel: String {
        switch exerciseFrequency {
        case "daily":
            return "high"
        case "weekly":
            return "moderate"
        case "monthly":
            return "low"
        default:
            return "sedentary"
        }
    }
}

// MARK: - LocalHealthInsights Extensions for Notifications

extension LocalHealthInsights {

    /// Check if insights have significant findings that warrant notifications
    var hasSignificantFindings: Bool {
        return overallScore < 70  // Overall health score is concerning
            || riskFactors.contains { $0.severity >= 7 }  // High-severity risk factors
            || recommendations.contains { $0.priority == "high" }  // High-priority recommendations
    }

    /// Convert LocalHealthInsights to AIHealthInsights for notification compatibility
    func toAIHealthInsights() -> AIHealthInsights {
        return AIHealthInsights(
            id: UUID().uuidString,
            summary: "健康分析が完了しました。全体スコア: \(Int(overallScore))点",
            analysisDate: Date(),
            overallScore: Int(overallScore),
            riskFactors: riskFactors.map { factor in
                RiskFactor(
                    category: factor.category,
                    severity: Int(factor.severity),
                    description: factor.factor,
                    recommendation: factor.recommendation ?? "定期的なモニタリングをお勧めします"
                )
            },
            recommendations: recommendations.map { rec in
                Recommendation(
                    title: rec.title,
                    description: rec.description,
                    priority: rec.priority,
                    category: rec.category ?? "general",
                    estimatedImpact: rec.estimatedBenefit
                )
            },
            language: language
        )
    }
}
