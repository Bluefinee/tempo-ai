import Combine
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
    private let activityLevel: HealthMetricsScoring.ActivityLevel

    // MARK: - Initialization

    init(
        userAge: Int = 30,
        userGender: String = "male",
        activityLevel: HealthMetricsScoring.ActivityLevel = .moderatelyActive
    ) {
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

        // Calculate individual metric scores using new scoring algorithms
        let hrvScore = analyzeHRV(healthData.hrv)
        let sleepScore = analyzeSleep(healthData.sleep)
        let activityScore = analyzeActivity(healthData.activity)
        let heartRateScore = analyzeHeartRate(healthData.heartRate)

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
            scores: [hrvScore, sleepScore, activityScore, heartRateScore]
        )

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

    private func analyzeHRV(_ hrvData: HRVData?) -> Double {
        guard let hrv = hrvData?.average else { return 0.5 }
        return HealthMetricsScoring.calculateHRVScore(
            average: hrv,
            age: userAge,
            activityLevel: activityLevel
        )
    }

    private func analyzeSleep(_ sleepData: SleepData?) -> Double {
        guard let sleep = sleepData else { return 0.5 }
        return HealthMetricsScoring.calculateSleepScore(
            duration: sleep.duration,
            efficiency: sleep.efficiency,
            deepSleep: sleep.deep,
            remSleep: sleep.rem
        )
    }

    private func analyzeActivity(_ activityData: ActivityData?) -> Double {
        guard let activity = activityData else { return 0.5 }
        return HealthMetricsScoring.calculateActivityScore(
            steps: activity.steps,
            calories: activity.calories,
            activeMinutes: activity.activeMinutes,
            age: userAge,
            activityLevel: activityLevel
        )
    }

    private func analyzeHeartRate(_ heartRateData: HeartRateData?) -> Double {
        guard let heartRate = heartRateData else { return 0.5 }
        return HealthMetricsScoring.calculateHeartRateScore(
            resting: heartRate.resting,
            average: heartRate.average,
            age: userAge,
            gender: userGender,
            activityLevel: activityLevel
        )
    }

    // MARK: - Support Methods

    private func assessDataQuality(_ healthData: HealthKitData) -> DataQuality {
        var dataPoints = 0

        if healthData.hrv?.average != nil { dataPoints += 1 }
        if healthData.sleep != nil { dataPoints += 1 }
        if healthData.activity != nil { dataPoints += 1 }
        if healthData.heartRate?.resting != nil { dataPoints += 1 }

        switch dataPoints {
        case 4: return .excellent
        case 3: return .good
        case 2: return .fair
        default: return .poor
        }
    }

    private func calculateOverallScore(
        hrvScore: Double,
        sleepScore: Double,
        activityScore: Double,
        heartRateScore: Double
    ) -> Double {
        let weights: [Double] = [0.3, 0.4, 0.2, 0.1]  // HRV, Sleep, Activity, HR weights
        let scores = [hrvScore, sleepScore, activityScore, heartRateScore]

        let weightedSum = zip(scores, weights).map { $0 * $1 }.reduce(0, +)
        return min(1.0, max(0.0, weightedSum))
    }

    private func calculateConfidence(dataQuality: DataQuality, scores: [Double]) -> Double {
        let dataQualityScore = dataQuality.score
        let scoreVariance = calculateVariance(scores)
        let consistencyScore = max(0.5, 1.0 - scoreVariance)

        return (dataQualityScore * 0.6) + (consistencyScore * 0.4)
    }

    private func calculateVariance(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return squaredDifferences.reduce(0, +) / Double(values.count)
    }

    // MARK: - Detailed Analysis Support

    private func generateMetricBreakdown(from healthData: HealthKitData) -> MetricBreakdown {
        // Simplified breakdown generation
        return MetricBreakdown(
            hrvDetails: HRVDetails(score: analyzeHRV(healthData.hrv), baseline: 0, status: ""),
            sleepDetails: SleepDetails(score: analyzeSleep(healthData.sleep), efficiency: 0, duration: 0, status: ""),
            activityDetails: ActivityDetails(
                score: analyzeActivity(healthData.activity), steps: 0, calories: 0, status: ""),
            heartRateDetails: HeartRateDetails(
                score: analyzeHeartRate(healthData.heartRate), resting: 0, average: 0, status: "")
        )
    }

    private func analyzeTrends(from healthData: HealthKitData) -> [TrendAnalysis] {
        return []
    }

    private func generateRecommendations(for status: HealthStatus) -> [HealthRecommendation] {
        return status.recommendedActions.map { action in
            HealthRecommendation(category: .lifestyle, title: action, description: action, priority: status.priority)
        }
    }

    private func generateInsights(from healthData: HealthKitData, analysis: HealthAnalysis) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        if let hrvScore = analysis.hrvScore, hrvScore < 0.5 {
            insights.append(
                HealthInsight(type: .warning, title: "HRV Below Baseline", message: "Consider rest", actionable: true))
        }
        return insights
    }
}

// MARK: - Supporting Types

enum AnalysisError: LocalizedError {
    case insufficientData
    case dataProcessingFailed(Error)
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .insufficientData:
            return "Insufficient health data for analysis"
        case .dataProcessingFailed(let error):
            return "Data processing failed: \(error.localizedDescription)"
        case .invalidInput:
            return "Invalid input data provided"
        }
    }
}

struct DetailedHealthAnalysis {
    let primaryAnalysis: HealthAnalysis
    let metricBreakdown: MetricBreakdown
    let trends: [TrendAnalysis]
    let recommendations: [HealthRecommendation]
    let insights: [HealthInsight]
}

struct MetricBreakdown {
    let hrvDetails: HRVDetails
    let sleepDetails: SleepDetails
    let activityDetails: ActivityDetails
    let heartRateDetails: HeartRateDetails
}

struct HRVDetails {
    let score: Double
    let baseline: Double
    let status: String
}

struct SleepDetails {
    let score: Double
    let efficiency: Double
    let duration: Double
    let status: String
}

struct ActivityDetails {
    let score: Double
    let steps: Int
    let calories: Int
    let status: String
}

struct HeartRateDetails {
    let score: Double
    let resting: Int
    let average: Int
    let status: String
}

struct TrendAnalysis {
    let metric: String
    let direction: String
    let significance: String
}

struct HealthRecommendation {
    let category: RecommendationCategory
    let title: String
    let description: String
    let priority: AlertPriority
}

enum RecommendationCategory {
    case sleep, exercise, nutrition, stress, lifestyle
}

struct HealthInsight {
    let type: InsightType
    let title: String
    let message: String
    let actionable: Bool
}

enum InsightType {
    case positive, warning, recommendation, information
}
