import Foundation
import HealthKit
import SwiftUI

/// Advanced health status analyzer that processes HealthKit data to determine overall wellness.
///
/// This service analyzes multiple health metrics including HRV, sleep patterns, activity levels,
/// and heart rate data to provide a comprehensive 4-tier health status assessment. Uses
/// age-appropriate baselines and personalized scoring algorithms for accurate status determination.
@MainActor
final class HealthStatusAnalyzer: ObservableObject {

    // MARK: - Published Properties

    @Published var currentAnalysis: HealthAnalysis?
    @Published var isAnalyzing = false
    @Published var lastError: AnalysisError?

    // MARK: - Private Properties

    private let userAge: Int
    private let userGender: String
    private let activityLevel: ActivityLevel

    // MARK: - Analysis Constants

    private struct BaslineMetrics {
        // HRV baselines by age group (milliseconds)
        static let hrvBaselines: [Int: Double] = [
            20: 55.0, 25: 50.0, 30: 45.0, 35: 42.0, 40: 38.0,
            45: 35.0, 50: 32.0, 55: 29.0, 60: 26.0, 65: 24.0,
        ]

        // Resting heart rate baselines by age and gender
        static let restingHRBaselines: [String: [Int: Double]] = [
            "male": [20: 60, 30: 62, 40: 64, 50: 66, 60: 68],
            "female": [20: 65, 30: 67, 40: 69, 50: 71, 60: 73],
        ]

        // Sleep efficiency targets
        static let optimalSleepEfficiency = 0.85
        static let goodSleepEfficiency = 0.75
        static let fairSleepEfficiency = 0.65

        // Activity targets (steps per day)
        static let optimalSteps = 10000.0
        static let goodSteps = 8000.0
        static let fairSteps = 5000.0
    }

    // MARK: - Initialization

    init(userAge: Int = 30, userGender: String = "male", activityLevel: ActivityLevel = .moderate) {
        self.userAge = userAge
        self.userGender = userGender
        self.activityLevel = activityLevel
    }

    // MARK: - Public Analysis Methods

    /// Analyze health status from HealthKit data
    func analyzeHealthStatus(from healthData: HealthKitData) async -> HealthAnalysis {
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let analysis = try await performComprehensiveAnalysis(healthData)
            currentAnalysis = analysis
            lastError = nil
            return analysis
        } catch {
            let analysisError = error as? AnalysisError ?? .dataProcessingFailed(error)
            lastError = analysisError

            // Return fallback analysis
            let fallbackAnalysis = HealthAnalysis(
                status: .unknown,
                overallScore: 0.0,
                confidence: 0.0,
                dataQuality: .poor
            )
            currentAnalysis = fallbackAnalysis
            return fallbackAnalysis
        }
    }

    /// Generate detailed health analysis with explanations
    func generateDetailedAnalysis(from healthData: HealthKitData) async -> DetailedHealthAnalysis {
        isAnalyzing = true
        defer { isAnalyzing = false }

        let analysis = await analyzeHealthStatus(from: healthData)

        return DetailedHealthAnalysis(
            primaryAnalysis: analysis,
            metricBreakdown: generateMetricBreakdown(from: healthData),
            trends: analyzeTrends(from: healthData),
            recommendations: generateRecommendations(for: analysis.status),
            insights: generateInsights(from: healthData, analysis: analysis)
        )
    }

    // MARK: - Private Analysis Methods

    private func performComprehensiveAnalysis(_ healthData: HealthKitData) async throws -> HealthAnalysis {
        // Validate data availability
        let dataQuality = assessDataQuality(healthData)

        if dataQuality == .poor {
            throw AnalysisError.insufficientData
        }

        // Calculate individual metric scores
        let hrvScore = await analyzeHRV(healthData.hrv)
        let sleepScore = await analyzeSleep(healthData.sleep)
        let activityScore = await analyzeActivity(healthData.activity)
        let heartRateScore = await analyzeHeartRate(healthData.heartRate)

        // Calculate overall status
        let status = HealthStatus.from(
            hrvScore: hrvScore,
            sleepScore: sleepScore,
            activityScore: activityScore,
            heartRateScore: heartRateScore
        )

        let overallScore = calculateOverallScore(
            hrvScore: hrvScore,
            sleepScore: sleepScore,
            activityScore: activityScore,
            heartRateScore: heartRateScore
        )

        let confidence = calculateConfidence(
            dataQuality: dataQuality,
            scores: [
                hrvScore, sleepScore, activityScore, heartRateScore,
            ])

        return HealthAnalysis(
            status: status,
            overallScore: overallScore,
            confidence: confidence,
            hrvScore: hrvScore,
            sleepScore: sleepScore,
            activityScore: activityScore,
            heartRateScore: heartRateScore,
            dataQuality: dataQuality
        )
    }

    // MARK: - Individual Metric Analysis

    private func analyzeHRV(_ data: HRVData?) async -> Double {
        guard let hrv = data?.averageHRV, hrv > 0 else {
            return 0.5  // Default score when no data available
        }

        let ageBasedBaseline = getAgeBasedHRVBaseline(age: userAge)
        let ratio = hrv / ageBasedBaseline

        // HRV scoring with diminishing returns
        let score = min(ratio / 1.2, 1.0)  // 120% of baseline = perfect score
        return max(score, 0.0)
    }

    private func analyzeSleep(_ data: SleepData?) async -> Double {
        guard let sleep = data else { return 0.5 }

        // Duration scoring (target 7-9 hours)
        let durationScore = calculateSleepDurationScore(sleep.duration)

        // Efficiency scoring
        let efficiencyScore = calculateSleepEfficiencyScore(sleep.efficiency)

        // Deep sleep scoring (target 15-25% of total sleep)
        let deepSleepScore = calculateDeepSleepScore(
            deepSleepHours: sleep.deepSleepHours ?? 0,
            totalSleepHours: sleep.duration
        )

        // Weighted average
        let weights: [Double] = [0.4, 0.4, 0.2]  // Duration, Efficiency, Deep Sleep
        let scores = [durationScore, efficiencyScore, deepSleepScore]

        return zip(scores, weights).map { $0 * $1 }.reduce(0, +)
    }

    private func analyzeActivity(_ data: ActivityData?) async -> Double {
        guard let activity = data else { return 0.5 }

        // Steps scoring
        let stepsScore = calculateStepsScore(activity.steps)

        // Active calories scoring (adjusted for user profile)
        let caloriesScore = calculateCaloriesScore(
            activity.activeCalories,
            userAge: userAge,
            userGender: userGender
        )

        // Exercise minutes scoring
        let exerciseScore = calculateExerciseScore(activity.exerciseMinutes ?? 0)

        // Weighted average based on activity level
        let weights: [Double] = activityLevel.analysisWeights
        let scores = [stepsScore, caloriesScore, exerciseScore]

        return zip(scores, weights).map { $0 * $1 }.reduce(0, +)
    }

    private func analyzeHeartRate(_ data: HeartRateData?) async -> Double {
        guard let heartRate = data else { return 0.5 }

        let restingHRScore = calculateRestingHeartRateScore(
            heartRate.restingHeartRate,
            age: userAge,
            gender: userGender
        )

        let variabilityScore = calculateHeartRateVariabilityScore(
            average: heartRate.averageHeartRate,
            resting: heartRate.restingHeartRate
        )

        // Combine scores
        return (restingHRScore * 0.7) + (variabilityScore * 0.3)
    }

    // MARK: - Scoring Helper Methods

    private func calculateSleepDurationScore(_ duration: Double) -> Double {
        switch duration {
        case 7.0 ... 9.0: return 1.0
        case 6.5 ..< 7.0, 9.0 ..< 9.5: return 0.8
        case 6.0 ..< 6.5, 9.5 ..< 10.0: return 0.6
        case 5.5 ..< 6.0, 10.0 ..< 11.0: return 0.4
        default: return 0.2
        }
    }

    private func calculateSleepEfficiencyScore(_ efficiency: Double) -> Double {
        switch efficiency {
        case BaslineMetrics.optimalSleepEfficiency ... 1.0: return 1.0
        case BaslineMetrics.goodSleepEfficiency ..< BaslineMetrics.optimalSleepEfficiency: return 0.8
        case BaslineMetrics.fairSleepEfficiency ..< BaslineMetrics.goodSleepEfficiency: return 0.6
        default: return 0.4
        }
    }

    private func calculateDeepSleepScore(deepSleepHours: Double, totalSleepHours: Double) -> Double {
        let deepSleepPercentage = deepSleepHours / totalSleepHours

        switch deepSleepPercentage {
        case 0.15 ... 0.25: return 1.0
        case 0.10 ..< 0.15, 0.25 ..< 0.30: return 0.8
        case 0.05 ..< 0.10, 0.30 ..< 0.35: return 0.6
        default: return 0.4
        }
    }

    private func calculateStepsScore(_ steps: Double) -> Double {
        switch steps {
        case BaslineMetrics.optimalSteps...: return 1.0
        case BaslineMetrics.goodSteps ..< BaslineMetrics.optimalSteps: return 0.8
        case BaslineMetrics.fairSteps ..< BaslineMetrics.goodSteps: return 0.6
        default: return 0.4
        }
    }

    private func calculateCaloriesScore(_ calories: Double, userAge: Int, userGender: String) -> Double {
        // Age and gender-adjusted calorie targets
        let baseTarget: Double = userGender == "male" ? 400 : 300
        let ageAdjustment = max(0.5, 1.0 - Double(userAge - 30) * 0.01)
        let target = baseTarget * ageAdjustment

        let ratio = calories / target
        return min(ratio, 1.0)
    }

    private func calculateExerciseScore(_ exerciseMinutes: Double) -> Double {
        switch exerciseMinutes {
        case 30...: return 1.0
        case 20 ..< 30: return 0.8
        case 10 ..< 20: return 0.6
        default: return 0.4
        }
    }

    private func calculateRestingHeartRateScore(
        _ restingHR: Double,
        age: Int,
        gender: String
    ) -> Double {
        guard let baseline = getRestingHRBaseline(age: age, gender: gender) else {
            return 0.5
        }

        let difference = abs(restingHR - baseline)

        switch difference {
        case 0 ... 5: return 1.0
        case 5 ... 10: return 0.8
        case 10 ... 15: return 0.6
        case 15 ... 20: return 0.4
        default: return 0.2
        }
    }

    private func calculateHeartRateVariabilityScore(average: Double, resting: Double) -> Double {
        let reserve = average - resting

        switch reserve {
        case 40...: return 1.0
        case 30 ..< 40: return 0.8
        case 20 ..< 30: return 0.6
        case 10 ..< 20: return 0.4
        default: return 0.2
        }
    }

    // MARK: - Baseline Helper Methods

    private func getAgeBasedHRVBaseline(age: Int) -> Double {
        let ageGroups = BaslineMetrics.hrvBaselines.keys.sorted()

        // Find closest age group
        guard let closestAge = ageGroups.min(by: { abs($0 - age) < abs($1 - age) }) else {
            return 40.0  // Default baseline
        }

        return BaslineMetrics.hrvBaselines[closestAge] ?? 40.0
    }

    private func getRestingHRBaseline(age: Int, gender: String) -> Double? {
        guard let genderBaselines = BaslineMetrics.restingHRBaselines[gender.lowercased()] else {
            return nil
        }

        let ageGroups = genderBaselines.keys.sorted()
        guard let closestAge = ageGroups.min(by: { abs($0 - age) < abs($1 - age) }) else {
            return nil
        }

        return genderBaselines[closestAge]
    }

    // MARK: - Data Quality & Confidence

    private func assessDataQuality(_ healthData: HealthKitData) -> DataQuality {
        var availableMetrics = 0
        var totalMetrics = 0

        // Check HRV data
        totalMetrics += 1
        if healthData.hrv?.averageHRV != nil { availableMetrics += 1 }

        // Check sleep data
        totalMetrics += 1
        if healthData.sleep != nil { availableMetrics += 1 }

        // Check activity data
        totalMetrics += 1
        if healthData.activity != nil { availableMetrics += 1 }

        // Check heart rate data
        totalMetrics += 1
        if healthData.heartRate?.restingHeartRate != nil { availableMetrics += 1 }

        let completeness = Double(availableMetrics) / Double(totalMetrics)

        switch completeness {
        case 1.0: return .excellent
        case 0.75 ..< 1.0: return .good
        case 0.5 ..< 0.75: return .fair
        default: return .poor
        }
    }

    private func calculateOverallScore(
        hrvScore: Double,
        sleepScore: Double,
        activityScore: Double,
        heartRateScore: Double
    ) -> Double {
        let weights: [Double] = [0.3, 0.4, 0.2, 0.1]  // HRV, Sleep, Activity, HR
        let scores = [hrvScore, sleepScore, activityScore, heartRateScore]

        return zip(scores, weights).map { $0 * $1 }.reduce(0, +)
    }

    private func calculateConfidence(dataQuality: DataQuality, scores: [Double]) -> Double {
        let qualityFactor = dataQuality.score
        let scoringConsistency = 1.0 - standardDeviation(scores)

        return (qualityFactor + scoringConsistency) / 2.0
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }
}

// MARK: - Supporting Extensions and Helper Methods

extension HealthStatusAnalyzer {

    private func generateMetricBreakdown(from healthData: HealthKitData) -> [String: Double] {
        return [
            "hrv": healthData.hrv?.averageHRV ?? 0,
            "sleep_duration": healthData.sleep?.duration ?? 0,
            "sleep_efficiency": healthData.sleep?.efficiency ?? 0,
            "steps": healthData.activity?.steps ?? 0,
            "resting_hr": healthData.heartRate?.restingHeartRate ?? 0,
        ]
    }

    private func analyzeTrends(from healthData: HealthKitData) -> [String] {
        // This would typically analyze historical data
        // For now, return empty array as we're focusing on current state
        return []
    }

    private func generateRecommendations(for status: HealthStatus) -> [String] {
        return status.recommendedActions
    }

    private func generateInsights(
        from healthData: HealthKitData,
        analysis: HealthAnalysis
    ) -> [HealthInsight] {
        var insights: [HealthInsight] = []

        // HRV insight
        if let hrvScore = analysis.hrvScore, hrvScore < 0.6 {
            insights.append(
                HealthInsight(
                    type: .hrv,
                    severity: .medium,
                    message: "Your heart rate variability is below optimal. Consider stress management techniques.",
                    recommendation: "Try meditation, deep breathing, or gentle yoga."
                ))
        }

        // Sleep insight
        if let sleepScore = analysis.sleepScore, sleepScore < 0.6 {
            insights.append(
                HealthInsight(
                    type: .sleep,
                    severity: .high,
                    message: "Your sleep quality could be improved.",
                    recommendation: "Aim for 7-9 hours of sleep with consistent bedtime routine."
                ))
        }

        return insights
    }
}

// MARK: - Supporting Types

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"

    var analysisWeights: [Double] {
        switch self {
        case .sedentary: return [0.6, 0.2, 0.2]  // Steps, Calories, Exercise
        case .light: return [0.5, 0.3, 0.2]
        case .moderate: return [0.4, 0.3, 0.3]
        case .active: return [0.3, 0.3, 0.4]
        case .veryActive: return [0.2, 0.3, 0.5]
        }
    }
}

enum AnalysisError: LocalizedError {
    case insufficientData
    case invalidHealthData
    case dataProcessingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .insufficientData:
            return "Insufficient health data for accurate analysis"
        case .invalidHealthData:
            return "Health data format is invalid"
        case .dataProcessingFailed(let error):
            return "Analysis failed: \(error.localizedDescription)"
        }
    }
}

struct DetailedHealthAnalysis {
    let primaryAnalysis: HealthAnalysis
    let metricBreakdown: [String: Double]
    let trends: [String]
    let recommendations: [String]
    let insights: [HealthInsight]
}

struct HealthInsight {
    let type: InsightType
    let severity: InsightSeverity
    let message: String
    let recommendation: String

    enum InsightType {
        case hrv, sleep, activity, heartRate, overall
    }

    enum InsightSeverity {
        case low, medium, high
    }
}
