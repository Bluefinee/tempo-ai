import Combine
import Foundation

// MARK: - AI Analysis Service

/// Advanced AI analysis service for personalized health insights
/// Integrates Claude AI with local health analytics for comprehensive recommendations
@MainActor
class AIAnalysisService: ObservableObject {

    // MARK: - Properties

    private let apiClient: TempoAIAPIClient
    private let localizationManager: LocalizationManager

    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?
    @Published var analysisError: String?

    // MARK: - Initialization

    init(
        apiClient: TempoAIAPIClient = TempoAIAPIClient.shared,
        localizationManager: LocalizationManager = LocalizationManager.shared
    ) {
        self.apiClient = apiClient
        self.localizationManager = localizationManager
    }

    // MARK: - Public Interface

    /// Generate comprehensive personalized insights combining AI and local analysis
    /// - Parameters:
    ///   - healthData: Complete health data from HealthKit
    ///   - weatherData: Current environmental/weather data
    ///   - userProfile: User's personal preferences and goals
    /// - Returns: Personalized insights with recommendations
    func generatePersonalizedInsights(
        healthData: ComprehensiveHealthData,
        weatherData: WeatherData?,
        userProfile: UserProfile
    ) async throws -> PersonalizedInsights {

        print("🤖 AIAnalysisService: Starting personalized analysis...")
        isAnalyzing = true
        analysisError = nil

        defer {
            isAnalyzing = false
            lastAnalysisDate = Date()
        }

        do {
            // Create analysis request with comprehensive context
            let analysisRequest = AnalysisRequest(
                healthData: healthData,
                environmentalData: weatherData,
                userProfile: userProfile,
                analysisType: .comprehensive,
                language: localizationManager.currentLanguage.rawValue
            )

            // Parallel execution: AI analysis and local processing
            async let aiInsights = apiClient.analyzeHealth(request: analysisRequest)
            async let localAnalysis = performLocalAnalysis(healthData)

            let (aiResult, localResult) = try await (aiInsights, localAnalysis)

            // Generate actionable recommendations combining AI and local insights
            let recommendations = generateActionableRecommendations(
                aiInsights: aiResult,
                localAnalysis: localResult,
                userProfile: userProfile,
                weatherData: weatherData
            )

            let insights = PersonalizedInsights(
                aiInsights: aiResult,
                localAnalysis: localResult,
                recommendations: recommendations,
                confidenceScore: calculateConfidenceScore(aiResult, localResult),
                timestamp: Date()
            )

            print("✅ Personalized insights generated successfully")
            return insights

        } catch {
            let errorMessage = "分析中にエラーが発生しました: \(error.localizedDescription)"
            print("❌ AI Analysis failed: \(errorMessage)")
            analysisError = errorMessage
            throw AIAnalysisError.analysisFailure(details: error.localizedDescription)
        }
    }

    /// Generate quick insights for immediate display (e.g., notifications)
    /// - Parameters:
    ///   - healthData: Latest health data
    ///   - context: Brief context for analysis focus
    /// - Returns: Quick insights summary
    func generateQuickInsights(
        healthData: ComprehensiveHealthData,
        context: QuickAnalysisContext = .daily
    ) async throws -> QuickInsights {

        print("⚡ Generating quick insights...")

        // Lightweight local analysis for immediate results
        let localAnalysis = await performLocalAnalysis(healthData)

        // Generate brief recommendations based on local analysis
        let quickRecommendations = generateQuickRecommendations(
            localAnalysis: localAnalysis,
            context: context
        )

        return QuickInsights(
            summary: localAnalysis.primaryInsight,
            recommendations: quickRecommendations,
            score: Int(localAnalysis.overallScore),
            timestamp: Date()
        )
    }

    // MARK: - Private Methods

    /// Perform comprehensive local health analysis
    /// - Parameter data: Comprehensive health data to analyze
    /// - Returns: Local analysis results
    private func performLocalAnalysis(_ data: ComprehensiveHealthData) async -> LocalHealthAnalysis {

        print("📊 Performing local health analysis...")

        return await withTaskGroup(of: Void.self) { group in
            var riskFactors: [HealthRiskFactor] = []
            var trends: [HealthTrend] = []
            var alerts: [HealthAlert] = []
            var overallScore: Double = 0.0
            var primaryInsight: String = ""

            // Parallel local analysis tasks
            group.addTask {
                riskFactors = HealthRiskAssessor.assess(data)
            }

            group.addTask {
                trends = TrendAnalyzer.analyzeTrends(data)
            }

            group.addTask {
                alerts = AlertManager.generateAlerts(data)
            }

            group.addTask {
                overallScore = HealthScoreCalculator.calculate(from: data).overall
            }

            await group.waitForAll()

            // Generate primary insight based on local analysis
            primaryInsight = generatePrimaryInsight(
                score: overallScore,
                trends: trends,
                riskFactors: riskFactors
            )

            return LocalHealthAnalysis(
                riskFactors: riskFactors,
                trends: trends,
                alerts: alerts,
                overallScore: overallScore,
                primaryInsight: primaryInsight,
                analysisTimestamp: Date()
            )
        }
    }

    /// Generate actionable recommendations combining AI and local insights
    /// - Parameters:
    ///   - aiInsights: AI-generated insights from Claude
    ///   - localAnalysis: Local analysis results
    ///   - userProfile: User preferences and goals
    ///   - weatherData: Environmental context
    /// - Returns: Array of actionable recommendations
    private func generateActionableRecommendations(
        aiInsights: AIHealthInsights,
        localAnalysis: LocalHealthAnalysis,
        userProfile: UserProfile,
        weatherData: WeatherData?
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        // Combine AI recommendations with local insights
        recommendations.append(
            contentsOf: aiInsights.recommendations.map { aiRec in
                ActionableRecommendation(
                    category: aiRec.category,
                    title: aiRec.title,
                    description: aiRec.description,
                    priority: aiRec.priority,
                    actionableSteps: aiRec.actionableSteps,
                    estimatedBenefit: aiRec.estimatedBenefit,
                    source: .aiGenerated
                )
            })

        // Add environment-specific recommendations
        if let weather = weatherData {
            let environmentalRecs = generateEnvironmentalRecommendations(
                weather: weather,
                healthData: localAnalysis,
                userProfile: userProfile
            )
            recommendations.append(contentsOf: environmentalRecs)
        }

        // Prioritize and limit recommendations (Miller's Law: 7±2)
        return Array(recommendations.sorted { $0.priority > $1.priority }.prefix(5))
    }

    /// Generate environmental context recommendations
    private func generateEnvironmentalRecommendations(
        weather: WeatherData,
        healthData: LocalHealthAnalysis,
        userProfile: UserProfile
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        // UV Index recommendations
        if weather.uvIndex > 6 {
            recommendations.append(
                ActionableRecommendation(
                    category: .lifestyle,
                    title: localizationManager.currentLanguage == .japanese ? "紫外線対策" : "UV Protection",
                    description: localizationManager.currentLanguage == .japanese
                        ? "UV指数が高めです。屋外活動時は日焼け止めの使用をおすすめします"
                        : "UV index is high. Consider using sunscreen for outdoor activities",
                    priority: .medium,
                    actionableSteps: [
                        localizationManager.currentLanguage == .japanese ? "SPF30以上の日焼け止めを使用" : "Use SPF 30+ sunscreen",
                        localizationManager.currentLanguage == .japanese ? "帽子やサングラスの着用" : "Wear hat and sunglasses",
                    ],
                    estimatedBenefit: "皮膚の健康保護",
                    source: .environmental
                ))
        }

        // Temperature-based exercise recommendations
        if weather.temperature < 10 || weather.temperature > 30 {
            let isHot = weather.temperature > 30
            recommendations.append(
                ActionableRecommendation(
                    category: .exercise,
                    title: localizationManager.currentLanguage == .japanese ? "運動環境調整" : "Exercise Environment",
                    description: localizationManager.currentLanguage == .japanese
                        ? (isHot ? "気温が高めです。屋内運動や涼しい時間帯の活動がおすすめです" : "気温が低めです。屋内運動やウォームアップを十分に行いましょう")
                        : (isHot
                            ? "Temperature is high. Consider indoor exercise or cooler time periods"
                            : "Temperature is low. Consider indoor exercise and proper warm-up"),
                    priority: .medium,
                    actionableSteps: [
                        localizationManager.currentLanguage == .japanese
                            ? (isHot ? "早朝または夕方の運動" : "十分なウォームアップ")
                            : (isHot ? "Exercise in early morning or evening" : "Adequate warm-up period"),
                        localizationManager.currentLanguage == .japanese ? "水分補給の意識" : "Stay hydrated",
                    ],
                    estimatedBenefit: localizationManager.currentLanguage == .japanese
                        ? "安全で効果的な運動" : "Safe and effective exercise",
                    source: .environmental
                ))
        }

        return recommendations
    }

    /// Generate quick recommendations for immediate use
    private func generateQuickRecommendations(
        localAnalysis: LocalHealthAnalysis,
        context: QuickAnalysisContext
    ) -> [QuickRecommendation] {

        var recommendations: [QuickRecommendation] = []

        // Score-based quick recommendations
        if localAnalysis.overallScore < 60 {
            recommendations.append(
                QuickRecommendation(
                    text: localizationManager.currentLanguage == .japanese
                        ? "今日は休息を優先してみませんか？" : "Consider prioritizing rest today",
                    category: .lifestyle
                ))
        } else if localAnalysis.overallScore > 80 {
            recommendations.append(
                QuickRecommendation(
                    text: localizationManager.currentLanguage == .japanese
                        ? "素晴らしい健康状態です！この調子で続けましょう" : "Excellent health status! Keep up the great work",
                    category: .motivation
                ))
        }

        // Trend-based recommendations
        for trend in localAnalysis.trends {
            if trend.direction == .declining && trend.significance > 0.7 {
                let trendRec = QuickRecommendation(
                    text: localizationManager.currentLanguage == .japanese
                        ? "\(trend.metric)の改善に注目してみませんか？" : "Consider focusing on improving your \(trend.metric)",
                    category: .improvement
                )
                recommendations.append(trendRec)
                break  // Limit to one trend recommendation for quick insights
            }
        }

        return Array(recommendations.prefix(2))  // Keep it brief for quick insights
    }

    /// Calculate confidence score for the combined analysis
    private func calculateConfidenceScore(
        _ aiInsights: AIHealthInsights,
        _ localAnalysis: LocalHealthAnalysis
    ) -> Double {

        // Base confidence from AI insights
        let aiConfidence = aiInsights.confidenceScore

        // Local analysis confidence based on data completeness
        let dataCompleteness = localAnalysis.dataCompleteness
        let localConfidence = min(dataCompleteness * 100, 95)  // Cap at 95%

        // Weighted average: 60% AI, 40% local
        return (aiConfidence * 0.6) + (localConfidence * 0.4)
    }

    /// Generate primary insight summary from local analysis
    private func generatePrimaryInsight(
        score: Double,
        trends: [HealthTrend],
        riskFactors: [HealthRiskFactor]
    ) -> String {

        if score >= 80 {
            return localizationManager.currentLanguage == .japanese
                ? "健康状態は良好です。この調子で継続しましょう" : "Your health status is excellent. Keep up the great work"
        } else if score >= 60 {
            let improvingTrends = trends.filter { $0.direction == .improving }
            if !improvingTrends.isEmpty {
                return localizationManager.currentLanguage == .japanese
                    ? "改善傾向が見られます。良い方向に向かっています" : "Positive trends detected. You're moving in the right direction"
            } else {
                return localizationManager.currentLanguage == .japanese
                    ? "いくつかの改善点があります。一歩ずつ前進しましょう" : "Some areas for improvement identified. Let's take it step by step"
            }
        } else {
            return localizationManager.currentLanguage == .japanese
                ? "今日は休息を重視してみませんか？" : "Consider prioritizing rest and recovery today"
        }
    }
}

// MARK: - Supporting Types

/// Analysis request structure for API communication
struct AnalysisRequest: Codable {
    let healthData: ComprehensiveHealthData
    let environmentalData: WeatherData?
    let userProfile: UserProfile
    let analysisType: AnalysisType
    let language: String
    let requestTimestamp: Date

    init(
        healthData: ComprehensiveHealthData,
        environmentalData: WeatherData?,
        userProfile: UserProfile,
        analysisType: AnalysisType,
        language: String
    ) {
        self.healthData = healthData
        self.environmentalData = environmentalData
        self.userProfile = userProfile
        self.analysisType = analysisType
        self.language = language
        self.requestTimestamp = Date()
    }
}

/// Type of analysis to perform
enum AnalysisType: String, Codable {
    case comprehensive
    case focused
    case quick
}

/// Comprehensive personalized insights structure
struct PersonalizedInsights: Codable {
    let aiInsights: AIHealthInsights
    let localAnalysis: LocalHealthAnalysis
    let recommendations: [ActionableRecommendation]
    let confidenceScore: Double
    let timestamp: Date
}

/// Local health analysis results
struct LocalHealthAnalysis {
    let riskFactors: [HealthRiskFactor]
    let trends: [HealthTrend]
    let alerts: [HealthAlert]
    let overallScore: Double
    let primaryInsight: String
    let analysisTimestamp: Date

    /// Calculate data completeness percentage
    var dataCompleteness: Double {
        // Simple heuristic based on available data points
        var completeness = 0.0

        // Add weights for different data categories
        completeness += riskFactors.isEmpty ? 0.0 : 0.3
        completeness += trends.isEmpty ? 0.0 : 0.3
        completeness += overallScore > 0 ? 0.4 : 0.0

        return completeness
    }
}

/// Quick insights for immediate display
struct QuickInsights {
    let summary: String
    let recommendations: [QuickRecommendation]
    let score: Int
    let timestamp: Date
}

/// Quick recommendation structure
struct QuickRecommendation {
    let text: String
    let category: QuickRecommendationCategory
}

/// Quick recommendation categories
enum QuickRecommendationCategory {
    case lifestyle
    case motivation
    case improvement
    case safety
}

/// Context for quick analysis
enum QuickAnalysisContext {
    case daily
    case postWorkout
    case morning
    case evening
}

/// AI Analysis specific errors
enum AIAnalysisError: LocalizedError {
    case analysisFailure(details: String)
    case invalidData(field: String)
    case networkTimeout
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .analysisFailure(let details):
            return "AI分析に失敗しました: \(details)"
        case .invalidData(let field):
            return "無効なデータです: \(field)"
        case .networkTimeout:
            return "ネットワークタイムアウトが発生しました"
        case .rateLimitExceeded:
            return "分析リクエスト上限に達しました。しばらく待ってから再試行してください"
        }
    }
}
