import Foundation
import Combine

// MARK: - Tempo AI API Client

/// Enhanced API client for Claude AI analysis integration
/// Extends existing APIClient functionality with comprehensive health analysis support
@MainActor
class TempoAIAPIClient: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = TempoAIAPIClient()
    
    private let baseAPIClient: APIClient
    private let baseURL: String
    private let urlSession: URLSessionProtocol
    
    // MARK: - Initialization
    
    init(
        baseAPIClient: APIClient = APIClient.shared,
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.baseAPIClient = baseAPIClient
        self.urlSession = urlSession
        
        #if DEBUG
            self.baseURL = "https://tempo-ai-backend.workers.dev/api"
            print("🌐 TempoAIAPIClient: Using production backend")
        #else
            self.baseURL = "https://tempo-ai-backend.workers.dev/api"
        #endif
    }
    
    // MARK: - Public AI Analysis Methods
    
    /// Analyze comprehensive health data using Claude AI
    /// - Parameter request: Analysis request with comprehensive health data
    /// - Returns: AI-generated health insights
    func analyzeHealth(request: AnalysisRequest) async throws -> AIHealthInsights {
        
        print("🤖 TempoAIAPIClient: Starting AI health analysis...")
        
        do {
            let apiResponse: APIResponse<AIHealthInsights> = try await performRequestWithRetry(
                endpoint: "ai/analyze-comprehensive",
                request: request
            )
            
            if let insights = apiResponse.data {
                print("✅ AI analysis completed successfully")
                return insights
            } else {
                let errorMessage = apiResponse.error ?? "Unknown AI analysis error"
                print("❌ AI analysis failed: \(errorMessage)")
                throw TempoAIAPIError.analysisError(errorMessage)
            }
            
        } catch {
            print("❌ AI analysis request failed: \(error.localizedDescription)")
            
            // Return fallback insights in case of API failure
            return createFallbackInsights(from: request)
        }
    }
    
    /// Quick analysis for immediate insights
    /// - Parameters:
    ///   - healthData: Comprehensive health data
    ///   - language: User's preferred language
    /// - Returns: Quick AI insights
    func quickAnalyze(
        healthData: ComprehensiveHealthData,
        language: String = "japanese"
    ) async throws -> QuickAIInsights {
        
        print("⚡ TempoAIAPIClient: Starting quick AI analysis...")
        
        let quickRequest = QuickAnalysisRequest(
            healthData: healthData,
            language: language,
            analysisType: .quick,
            timestamp: Date()
        )
        
        do {
            let apiResponse: APIResponse<QuickAIInsights> = try await performRequestWithRetry(
                endpoint: "ai/quick-analyze",
                request: quickRequest
            )
            
            if let insights = apiResponse.data {
                print("✅ Quick analysis completed")
                return insights
            } else {
                throw TempoAIAPIError.analysisError(apiResponse.error ?? "Quick analysis failed")
            }
            
        } catch {
            // Return simplified fallback for quick analysis
            return createFallbackQuickInsights(from: healthData, language: language)
        }
    }
    
    /// Test Claude AI connectivity and response
    /// - Returns: Boolean indicating successful connection
    func testAIConnection() async -> Bool {
        
        guard let url = URL(string: "\(baseURL)/ai/health-check") else {
            return false
        }
        
        do {
            let (_, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("❌ AI connection test failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Perform HTTP request with retry logic
    private func performRequestWithRetry<T: Codable, R: Codable>(
        endpoint: String,
        request: R,
        maxRetries: Int = 3
    ) async throws -> T {
        
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await performRequest(endpoint: endpoint, request: request)
            } catch {
                lastError = error
                
                // Don't retry on client errors
                if let apiError = error as? TempoAIAPIError,
                   case .clientError = apiError {
                    throw error
                }
                
                // Retry with exponential backoff
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) + Double.random(in: 0...1)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? TempoAIAPIError.networkError("Max retries exceeded")
    }
    
    /// Perform individual HTTP request
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        request: R
    ) async throws -> T {
        
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw TempoAIAPIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("TempoAI-iOS/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.timeoutInterval = 30.0
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw TempoAIAPIError.encodingError
        }
        
        // Perform request
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TempoAIAPIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw TempoAIAPIError.decodingError
                }
                
            case 400...499:
                throw TempoAIAPIError.clientError(httpResponse.statusCode)
                
            case 500...599:
                throw TempoAIAPIError.serverError(httpResponse.statusCode)
                
            default:
                throw TempoAIAPIError.httpError(httpResponse.statusCode)
            }
            
        } catch let error as TempoAIAPIError {
            throw error
        } catch {
            throw TempoAIAPIError.networkError(error.localizedDescription)
        }
    }
    
    /// Create fallback insights when API is unavailable
    private func createFallbackInsights(from request: AnalysisRequest) -> AIHealthInsights {
        
        print("⚠️ Creating fallback AI insights...")
        
        let healthData = request.healthData
        let language = request.language
        
        // Generate basic insights based on health score
        let healthScore = healthData.overallHealthScore.overall
        
        let insights: [String]
        let recommendations: [AIRecommendation]
        let plan: String
        
        if language == "japanese" || language == "ja" {
            insights = generateJapaneseInsights(healthScore: healthScore, healthData: healthData)
            recommendations = generateJapaneseRecommendations(healthData: healthData)
            plan = generateJapanesePlan(healthData: healthData)
        } else {
            insights = generateEnglishInsights(healthScore: healthScore, healthData: healthData)
            recommendations = generateEnglishRecommendations(healthData: healthData)
            plan = generateEnglishPlan(healthData: healthData)
        }
        
        return AIHealthInsights(
            overallScore: healthScore,
            keyInsights: insights,
            improvementOpportunities: [],
            recommendations: recommendations,
            todaysOptimalPlan: plan,
            culturalNotes: language == "japanese" ? "日本の生活習慣に適したアドバイスです" : nil,
            confidenceScore: 75.0 // Lower confidence for fallback
        )
    }
    
    /// Create fallback quick insights
    private func createFallbackQuickInsights(
        from healthData: ComprehensiveHealthData,
        language: String
    ) -> QuickAIInsights {
        
        let score = Int(healthData.overallHealthScore.overall)
        let summary: String
        let quickTip: String
        
        if language == "japanese" || language == "ja" {
            summary = score >= 80 ? "健康状態は良好です" :
                      score >= 60 ? "バランスの取れた状態です" :
                      "改善の余地があります"
            quickTip = "今日も健康的な一日を過ごしましょう"
        } else {
            summary = score >= 80 ? "Your health status is excellent" :
                      score >= 60 ? "Your health is balanced" :
                      "There's room for improvement"
            quickTip = "Focus on small improvements today"
        }
        
        return QuickAIInsights(
            summary: summary,
            quickTip: quickTip,
            score: score,
            timestamp: Date()
        )
    }
    
    // MARK: - Fallback Content Generation
    
    private func generateJapaneseInsights(healthScore: Double, healthData: ComprehensiveHealthData) -> [String] {
        var insights: [String] = []
        
        if healthScore >= 80 {
            insights.append("健康状態は非常に良好です")
            insights.append("現在の健康習慣を継続することをおすすめします")
        } else if healthScore >= 60 {
            insights.append("バランスの取れた健康状態です")
            insights.append("さらなる改善で理想的な状態に近づけます")
        } else {
            insights.append("健康状態の改善に取り組む良い機会です")
            insights.append("小さな変化から始めることが大切です")
        }
        
        // Add specific insights based on data
        if healthData.sleep.sleepEfficiency >= 0.9 {
            insights.append("睡眠の質が優秀です")
        }
        if healthData.activity.steps >= 10000 {
            insights.append("活動量が十分で素晴らしいです")
        }
        
        return insights
    }
    
    private func generateEnglishInsights(healthScore: Double, healthData: ComprehensiveHealthData) -> [String] {
        var insights: [String] = []
        
        if healthScore >= 80 {
            insights.append("Your health status is excellent")
            insights.append("Continue your current healthy habits")
        } else if healthScore >= 60 {
            insights.append("Your health is well-balanced")
            insights.append("Small improvements can lead to optimal health")
        } else {
            insights.append("Great opportunity to improve your health")
            insights.append("Start with small, sustainable changes")
        }
        
        if healthData.sleep.sleepEfficiency >= 0.9 {
            insights.append("Your sleep quality is excellent")
        }
        if healthData.activity.steps >= 10000 {
            insights.append("You're achieving great activity levels")
        }
        
        return insights
    }
    
    private func generateJapaneseRecommendations(healthData: ComprehensiveHealthData) -> [AIRecommendation] {
        var recommendations: [AIRecommendation] = []
        
        // Sleep recommendation
        let sleepHours = healthData.sleep.totalDuration / 3600
        if sleepHours < 7 {
            recommendations.append(AIRecommendation(
                category: .sleep,
                title: "睡眠時間の改善",
                description: "7-8時間の睡眠を目指してみませんか？",
                priority: .high,
                actionableSteps: ["就寝時間を30分早める", "就寝前のスクリーン時間を減らす"],
                estimatedBenefit: "体の回復と集中力向上"
            ))
        }
        
        // Activity recommendation
        if healthData.activity.steps < 8000 {
            recommendations.append(AIRecommendation(
                category: .exercise,
                title: "歩数の増加",
                description: "日常的な歩行を増やしてみませんか？",
                priority: .medium,
                actionableSteps: ["階段を積極的に使う", "短時間の散歩を追加"],
                estimatedBenefit: "心血管健康の改善"
            ))
        }
        
        return recommendations
    }
    
    private func generateEnglishRecommendations(healthData: ComprehensiveHealthData) -> [AIRecommendation] {
        var recommendations: [AIRecommendation] = []
        
        let sleepHours = healthData.sleep.totalDuration / 3600
        if sleepHours < 7 {
            recommendations.append(AIRecommendation(
                category: .sleep,
                title: "Improve Sleep Duration",
                description: "Consider aiming for 7-8 hours of sleep",
                priority: .high,
                actionableSteps: ["Move bedtime 30 minutes earlier", "Reduce screen time before bed"],
                estimatedBenefit: "Better recovery and focus"
            ))
        }
        
        if healthData.activity.steps < 8000 {
            recommendations.append(AIRecommendation(
                category: .exercise,
                title: "Increase Daily Steps",
                description: "Try to add more walking to your routine",
                priority: .medium,
                actionableSteps: ["Take stairs when possible", "Add short walks throughout the day"],
                estimatedBenefit: "Improved cardiovascular health"
            ))
        }
        
        return recommendations
    }
    
    private func generateJapanesePlan(healthData: ComprehensiveHealthData) -> String {
        let score = healthData.overallHealthScore.overall
        
        if score >= 80 {
            return "現在の健康習慣を継続し、新しい健康目標の設定を検討しましょう。"
        } else if score >= 60 {
            return "睡眠と運動のバランスを少し調整することで、さらなる健康改善が期待できます。"
        } else {
            return "今日は基本的な健康習慣（適度な運動、十分な睡眠、バランスの良い食事）に焦点を当てましょう。"
        }
    }
    
    private func generateEnglishPlan(healthData: ComprehensiveHealthData) -> String {
        let score = healthData.overallHealthScore.overall
        
        if score >= 80 {
            return "Continue your excellent health habits and consider setting new wellness goals."
        } else if score >= 60 {
            return "Fine-tune your sleep and exercise routine for optimal health improvements."
        } else {
            return "Focus on fundamental health habits today: moderate exercise, adequate sleep, and balanced nutrition."
        }
    }
}

// MARK: - Supporting Types

/// Quick analysis request structure
struct QuickAnalysisRequest: Codable {
    let healthData: ComprehensiveHealthData
    let language: String
    let analysisType: AnalysisType
    let timestamp: Date
}

/// Quick AI insights response
struct QuickAIInsights: Codable {
    let summary: String
    let quickTip: String
    let score: Int
    let timestamp: Date
}

/// Enhanced API response wrapper
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let error: String?
    let timestamp: Date?
    let requestId: String?
}

/// Tempo AI specific errors
enum TempoAIAPIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case decodingError
    case networkError(String)
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case httpError(Int)
    case analysisError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .encodingError:
            return "リクエストのエンコードに失敗しました"
        case .decodingError:
            return "レスポンスのデコードに失敗しました"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .clientError(let code):
            return "クライアントエラー: \(code)"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .analysisError(let message):
            return "分析エラー: \(message)"
        }
    }
}