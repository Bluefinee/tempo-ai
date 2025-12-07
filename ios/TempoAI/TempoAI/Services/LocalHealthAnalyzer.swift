import Combine
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

    // Category-specific analyzers
    private let cardiovascularAnalyzer = CardiovascularAnalyzer()
    private let sleepAnalyzer = SleepCategoryAnalyzer()
    private let activityAnalyzer = ActivityAnalyzer()
    private let metabolicAnalyzer = MetabolicAnalyzer()

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
        let cardiovascularInsights = cardiovascularAnalyzer.analyzeCardiovascularHealth(
            healthData.vitalSigns,
            age: userProfile.age ?? 30,
            gender: userProfile.gender?.rawValue ?? "unknown"
        )

        // 2. Sleep Quality Assessment
        let sleepInsights = sleepAnalyzer.analyzeSleepQuality(
            healthData.sleep,
            age: userProfile.age ?? 30,
            lifestyle: userProfile.exerciseFrequency ?? "moderate"
        )

        // 3. Activity and Fitness Analysis
        let activityInsights = activityAnalyzer.analyzeActivityPatterns(
            healthData.activity,
            bodyMeasurements: healthData.bodyMeasurements,
            age: userProfile.age ?? 30,
            gender: userProfile.gender?.rawValue ?? "unknown"
        )

        // 4. Metabolic Health Assessment
        let metabolicInsights = metabolicAnalyzer.analyzeMetabolicHealth(
            bodyMeasurements: healthData.bodyMeasurements,
            activity: healthData.activity,
            nutrition: healthData.nutrition ?? NutritionData(),
            age: userProfile.age ?? 30
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

        let overallScore = calculateQuickHealthScore(healthData, age: userProfile.age ?? 30)
        let priority = identifyTopPriority(healthData, userProfile: userProfile)
        let quickTip = generateQuickTip(priority: priority, language: language)

        return QuickHealthInsights(
            score: Int(overallScore),
            summary: generateQuickSummary(score: overallScore, language: language),
            topPriority: priority,
            quickTip: quickTip,
            dataQuality: "\(String(format: "%.1f", assessDataQuality(healthData).overallScore * 100))%",
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
                heartRate.resting ?? 70.0,
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
            recommendations: [],
            riskFactors: [],
            trend: HealthTrend(
                metric: "cardiovascular",
                direction: .stable,
                magnitude: 0.0,
                timeframe: .week,
                significance: 0.5,
                description: "Stable cardiovascular metrics"
            ),
            confidence: 0.8
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
            recommendations: [],
            riskFactors: [],
            trend: HealthTrend(
                metric: "sleep",
                direction: .stable,
                magnitude: 0.0,
                timeframe: .week,
                significance: 0.5,
                description: "Stable sleep patterns"
            ),
            confidence: 0.8
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
                activeCalories: Int(activity.activeEnergyBurned),
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
            recommendations: [],
            riskFactors: [],
            trend: HealthTrend(
                metric: "activity",
                direction: .stable,
                magnitude: 0.0,
                timeframe: .week,
                significance: 0.5,
                description: "Stable activity patterns"
            ),
            confidence: 0.8
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
            recommendations: [],
            riskFactors: [],
            trend: HealthTrend(
                metric: "metabolic",
                direction: .stable,
                magnitude: 0.0,
                timeframe: .week,
                significance: 0.5,
                description: "Stable metabolic health"
            ),
            confidence: 0.8
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
            completeness: completeness / 100.0,
            recency: calculateDataRecency(healthData.timestamp),
            accuracy: 0.85,
            consistency: 0.9,
            overallScore: (completeness / 100.0 + calculateDataRecency(healthData.timestamp)) / 2.0,
            recommendations: []
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
        let deepSleep = sleep.deepSleep ?? 0
        let remSleep = sleep.remSleep ?? 0
        let lightSleep = sleep.lightSleep ?? 0
        let totalSleep = deepSleep + remSleep + lightSleep
        
        guard totalSleep > 0 else {
            return SleepStageBreakdown(deepPercentage: 0, remPercentage: 0, lightPercentage: 0)
        }

        return SleepStageBreakdown(
            deepPercentage: (deepSleep / totalSleep) * 100,
            remPercentage: (remSleep / totalSleep) * 100,
            lightPercentage: (lightSleep / totalSleep) * 100
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
            case .respiratory:
                return "呼吸器系の健康に注意が必要です"
            case .nutrition:
                return "栄養バランスの改善が重要です"
            case .mental:
                return "メンタルヘルスのサポートが必要です"
            case .recovery:
                return "回復力の向上が重要です"
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
            case .respiratory:
                return "Respiratory health requires attention"
            case .nutrition:
                return "Nutrition balance improvement needed"
            case .mental:
                return "Mental health support recommended"
            case .recovery:
                return "Recovery enhancement is important"
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
