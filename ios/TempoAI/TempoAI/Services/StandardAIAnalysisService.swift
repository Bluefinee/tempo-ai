//
//  StandardAIAnalysisService.swift
//  TempoAI
//
//  Created for standard iOS AI Analysis Service following 2025 best practices
//

import Foundation
import os.log

/// Type alias to resolve ambiguity
typealias AIBatteryTrend = BatteryTrend

/// Standard API Response wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

/// AI Analysis Service using standard NetworkManager
final class StandardAIAnalysisService: AIAnalysisServiceProtocol {
    // MARK: - Properties
    private let networkManager: NetworkManager
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TempoAI", category: "AIAnalysisService")

    // MARK: - Endpoints
    private enum Endpoint {
        static let focusAnalysis = "/api/health/ai/focus-analysis"
        static let healthCheck = "/api/health/ai/health-check"
    }

    // MARK: - Initialization
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        logger.info("StandardAIAnalysisService initialized")
    }

    // MARK: - AIAnalysisServiceProtocol Implementation
    func generateAnalysis(from staticResult: AnalysisResult) async throws -> AIAnalysisResponse {
        logger.info("Starting AI analysis generation")

        guard let staticAnalysis = staticResult.staticAnalysis else {
            logger.error("No static analysis available")
            throw NetworkError.invalidRequest
        }

        let startTime = Date()

        do {
            // Build AI analysis request
            let aiRequest = try await buildStandardAIAnalysisRequest(from: staticAnalysis)
            logger.debug("Built AI analysis request")

            // Execute API request using NetworkManager
            let response: APIResponse<AIAnalysisResponse> = try await networkManager.request(
                endpoint: Endpoint.focusAnalysis,
                method: .POST,
                body: aiRequest,
                retryCount: 2
            )

            // Validate response
            guard response.success, let analysisResponse = response.data else {
                let errorMessage = response.error ?? "Unknown API error"
                logger.error("API returned error: \(errorMessage)")
                throw NetworkError.serverError(500, errorMessage)
            }

            let elapsed = Date().timeIntervalSince(startTime)
            logger.info("AI analysis completed successfully in \(String(format: "%.3f", elapsed))s")

            return analysisResponse
        } catch {
            let elapsed = Date().timeIntervalSince(startTime)
            logger.error("AI analysis failed after \(String(format: "%.3f", elapsed))s: \(error.localizedDescription)")

            // Return intelligent fallback for better user experience
            return generateIntelligentFallback(from: staticAnalysis)
        }
    }

    // MARK: - Health Check
    func performHealthCheck() async throws -> Bool {
        logger.info("Performing AI service health check")

        do {
            struct HealthCheckResponse: Codable {
                let status: String
                let service: String
                let timestamp: String
            }
            
            let response: APIResponse<HealthCheckResponse> = try await networkManager.request(
                endpoint: Endpoint.healthCheck,
                method: .GET,
                retryCount: 1
            )

            let isHealthy = response.success && response.data != nil
            logger.info("Health check result: \(isHealthy ? "Healthy" : "Unhealthy")")
            return isHealthy
        } catch {
            logger.warning("Health check failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Request Building
    private func buildStandardAIAnalysisRequest(from staticAnalysis: StaticAnalysis) async throws -> AIAnalysisRequest {
        logger.debug("Building standard AI analysis request")

        let userProfile = UserProfileManager.shared
        let focusTagManager = FocusTagManager.shared

        // Get current health data
        let healthData = try await BatteryEngine(
            healthService: HealthService(),
            weatherService: WeatherService()
        ).getLatestHealthData()

        // Get weather data
        let weatherService = WeatherService()
        let weatherData = await weatherService.getCurrentWeather() ?? WeatherData.mock()

        // Build biological context
        let biologicalContext = BiologicalContext(
            hrvStatus: healthData.hrvData.current - healthData.hrvData.baseline,
            rhrStatus: healthData.heartRate.resting - 65.0,
            sleepDeep: Int(healthData.sleepData.deepSleepDuration * 60),
            sleepRem: Int(healthData.sleepData.duration * 0.25 * 60),
            respiratoryRate: calculateRespiratoryRate(from: healthData.hrvData),
            steps: healthData.activityData.stepCount,
            activeCalories: healthData.activityData.activeEnergyBurned
        )

        // Build environmental context
        let environmentalContext = EnvironmentalContext(
            pressureTrend: weatherData.pressureChange,
            humidity: weatherData.humidity,
            feelsLike: weatherData.temperature,
            uvIndex: 3.0,  // TODO: Get real UV data
            weatherCode: 0  // TODO: Get real weather code
        )

        // Build user context
        let userContext = UserContext(
            activeTags: Array(focusTagManager.activeTags),
            timeOfDay: getCurrentTimeOfDay(),
            language: .japanese,
            userMode: userProfile.currentMode
        )

        return AIAnalysisRequest(
            batteryLevel: staticAnalysis.energyLevel,
            batteryTrend: determineBatteryTrend(from: staticAnalysis),
            biologicalContext: biologicalContext,
            environmentalContext: environmentalContext,
            userContext: userContext
        )
    }

    // MARK: - Intelligent Fallback
    private func generateIntelligentFallback(from staticAnalysis: StaticAnalysis) -> AIAnalysisResponse {
        logger.info("Generating intelligent fallback response")

        let headline = generateContextualHeadline(energyLevel: staticAnalysis.energyLevel)
        let energyComment = generateContextualEnergyComment(staticAnalysis: staticAnalysis)
        let suggestions = generateContextualSuggestions(staticAnalysis: staticAnalysis)

        return AIAnalysisResponse(
            headline: headline,
            energyComment: energyComment,
            tagInsights: generateTagBasedInsights(),
            aiActionSuggestions: suggestions,
            detailAnalysis: generateDetailedAnalysis(staticAnalysis: staticAnalysis),
            dataQuality: DataQuality(
                healthDataCompleteness: 85.0,
                weatherDataAge: 30,
                analysisTimestamp: Date()
            ),
            generatedAt: Date()
        )
    }

    // MARK: - Helper Methods
    private func determineBatteryTrend(from staticAnalysis: StaticAnalysis) -> AIBatteryTrend {
        // Simple trend determination - could be enhanced with historical data
        switch staticAnalysis.batteryState {
        case .high:
            return .recovering
        case .medium:
            return .stable
        case .low, .critical:
            return .declining
        }
    }

    private func calculateRespiratoryRate(from hrvData: HRVData) -> Double {
        let baseRate = 16.0
        let variation = (hrvData.current - hrvData.baseline) / hrvData.baseline * 2.0
        return max(12.0, min(20.0, baseRate + variation))
    }

    private func getCurrentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6 ..< 12: return .morning
        case 12 ..< 17: return .afternoon
        case 17 ..< 21: return .evening
        default: return .night
        }
    }

    private func generateContextualHeadline(energyLevel: Double) -> HeadlineInsight {
        let focusTagManager = FocusTagManager.shared
        let activeTags = Array(focusTagManager.activeTags)

        if activeTags.contains(.work) && energyLevel > 70 {
            return HeadlineInsight(
                title: "集中力の黄金時間",
                subtitle: "今朝の調子なら重要タスクに最適です",
                impactLevel: .low,
                confidence: 80.0
            )
        } else if activeTags.contains(.beauty) && energyLevel < 50 {
            return HeadlineInsight(
                title: "回復美容の時間",
                subtitle: "お疲れ気味。今夜はスペシャルケアを",
                impactLevel: .medium,
                confidence: 75.0
            )
        } else {
            return HeadlineInsight(
                title: energyLevel > 60 ? "良好なコンディション" : "穏やかなペース",
                subtitle: energyLevel > 60 ? "今日は積極的に過ごせそうです" : "無理せず進めましょう",
                impactLevel: energyLevel > 60 ? .low : .medium,
                confidence: 70.0
            )
        }
    }

    private func generateContextualEnergyComment(staticAnalysis: StaticAnalysis) -> String {
        switch staticAnalysis.batteryState {
        case .high:
            return "エネルギーが充実しています。今日は挑戦的なことにも取り組めそうです。"
        case .medium:
            return "バランスの取れた状態です。安定したペースで進めましょう。"
        case .low:
            return "少しお疲れのようです。無理をせず、今日は自分を労ってください。"
        case .critical:
            return "しっかりとした休息が必要です。今日は回復を最優先にしましょう。"
        }
    }

    private func generateContextualSuggestions(staticAnalysis: StaticAnalysis) -> [AIActionSuggestion] {
        var suggestions: [AIActionSuggestion] = []

        if staticAnalysis.energyLevel < 50 {
            suggestions.append(
                AIActionSuggestion(
                    title: "3回の深呼吸",
                    description: "30秒で気持ちをリセットしませんか？",
                    actionType: .rest,
                    estimatedTime: "30秒",
                    difficulty: .easy
                ))
        } else {
            suggestions.append(
                AIActionSuggestion(
                    title: "5分間の散歩",
                    description: "外の空気で気分転換してみましょう",
                    actionType: .exercise,
                    estimatedTime: "5分",
                    difficulty: .easy
                ))
        }

        return suggestions
    }

    private func generateTagBasedInsights() -> [TagInsight] {
        let focusTagManager = FocusTagManager.shared

        return Array(focusTagManager.activeTags).prefix(2).map { tag in
            TagInsight(
                tag: tag,
                icon: tag.systemIcon,
                message: generateTagMessage(for: tag),
                urgency: .info
            )
        }
    }

    private func generateTagMessage(for tag: FocusTag) -> String {
        switch tag {
        case .work: return "集中力維持のため、適度な休憩を心がけましょう"
        case .beauty: return "肌の状態を考慮して、水分補給を意識してください"
        case .diet: return "栄養バランスを保ち、規則正しい食事を続けましょう"
        case .sleep: return "質の良い睡眠のため、就寝前のリラックスを大切に"
        case .fitness: return "体調に合わせて、無理のない運動を続けましょう"
        case .chill: return "ストレス管理のため、リラックスタイムを確保しましょう"
        }
    }

    private func generateDetailedAnalysis(staticAnalysis: StaticAnalysis) -> String {
        return """
            現在のエネルギーレベル \(Int(staticAnalysis.energyLevel))% は、睡眠スコア \(Int(staticAnalysis.basicMetrics.sleepScore))点、活動スコア \(Int(staticAnalysis.basicMetrics.activityScore))点、ストレス管理スコア \(Int(staticAnalysis.basicMetrics.stressScore))点の総合評価です。

            今日の調子は \(staticAnalysis.batteryState == .high ? "良好" : staticAnalysis.batteryState == .medium ? "安定" : "注意が必要") で、無理のないペースでの活動をお勧めします。
            """
    }
}

