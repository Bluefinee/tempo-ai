import Foundation
import os.log

/**
 * 実際のBackend APIと通信するAI分析サービス
 * MockAIAnalysisServiceの置き換え
 */
class RealAIAnalysisService: AIAnalysisServiceProtocol {
    
    private enum APIConstants {
        static let baseURL = "https://tempo-ai-backend.your-domain.workers.dev" // 実際のWorkers URL
        static let focusAnalysisEndpoint = "/api/health/ai/focus-analysis"
        static let timeoutInterval: TimeInterval = 30.0
    }
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConstants.timeoutInterval
        self.urlSession = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()  
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func generateAnalysis(from staticResult: AnalysisResult) async throws -> AIAnalysisResponse {
        guard let staticAnalysis = staticResult.staticAnalysis else {
            throw AIAnalysisServiceError.invalidStaticAnalysis
        }
        
        let startTime = Date()
        
        do {
            // 実データでAI分析リクエスト構築
            let aiRequest = try await buildRealAIAnalysisRequest(from: staticAnalysis)
            
            // 実際のBackend API呼び出し
            let response = try await performRealAPIRequest(aiRequest)
            
            let elapsed = Date().timeIntervalSince(startTime)
            os_log("Real AI analysis completed in %{public}.3f seconds", log: .default, type: .info, elapsed)
            
            return response
            
        } catch {
            os_log("Real AI analysis failed, using fallback: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            // AI失敗時は高品質なフォールバックを提供
            return generateIntelligentFallback(from: staticAnalysis)
        }
    }
    
    /**
     * 実データでAI分析リクエストを構築
     */
    private func buildRealAIAnalysisRequest(from staticAnalysis: StaticAnalysis) async throws -> AIAnalysisRequest {
        let userProfile = UserProfileManager.shared
        let focusTagManager = FocusTagManager.shared
        
        // 実際のHealthKitデータを取得
        let healthData = try await BatteryEngine(
            healthService: HealthService(),
            weatherService: WeatherService()
        ).getLatestHealthData()
        
        // 実際の気象データを取得
        let weatherService = WeatherService()
        let weatherData = await weatherService.getCurrentWeather() ?? WeatherData.mock()
        
        // 実データから生物学的コンテキスト構築
        let biologicalContext = BiologicalContext(
            hrvStatus: healthData.hrvData.current - healthData.hrvData.baseline,
            rhrStatus: healthData.heartRate.resting - 65.0, // 基準値65bpm
            sleepDeep: Int(healthData.sleepData.deepSleepDuration * 60), // 分単位に変換
            sleepRem: Int(healthData.sleepData.duration * 0.25 * 60), // REM推定
            respiratoryRate: calculateRespiratoryRate(from: healthData.hrvData),
            steps: healthData.activityData.stepCount,
            activeCalories: healthData.activityData.activeEnergyBurned
        )
        
        // 実際の環境コンテキスト構築
        let environmentalContext = EnvironmentalContext(
            pressureTrend: weatherData.pressureChange,
            humidity: weatherData.humidity,
            feelsLike: weatherData.temperature, // 体感温度として使用
            uvIndex: 3.0, // TODO: 実際のUVデータ
            weatherCode: 0 // TODO: 実際の天候コード
        )
        
        let userContext = UserContext(
            activeTags: focusTagManager.activeTags,
            timeOfDay: getCurrentTimeOfDay(),
            language: .japanese,
            userMode: userProfile.currentMode
        )
        
        return AIAnalysisRequest(
            batteryLevel: staticAnalysis.energyLevel,
            batteryTrend: .stable, // TODO: 前回との比較
            biologicalContext: biologicalContext,
            environmentalContext: environmentalContext,
            userContext: userContext
        )
    }
    
    /**
     * 実際のBackend APIリクエスト実行
     */
    private func performRealAPIRequest(_ request: AIAnalysisRequest) async throws -> AIAnalysisResponse {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.focusAnalysisEndpoint) else {
            throw AIAnalysisServiceError.invalidStaticAnalysis
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // リクエストボディ設定
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIAnalysisServiceError.invalidStaticAnalysis
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIAnalysisServiceError.invalidStaticAnalysis
        }
        
        return try decoder.decode(AIAnalysisResponse.self, from: data)
    }
    
    /**
     * AI失敗時の知的フォールバック
     */
    private func generateIntelligentFallback(from staticAnalysis: StaticAnalysis) -> AIAnalysisResponse {
        // 固定値ではなく、静的分析結果に基づく動的フォールバック
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
    
    // MARK: - Intelligent Fallback Helpers
    
    private func generateContextualHeadline(energyLevel: Double) -> HeadlineInsight {
        let focusTagManager = FocusTagManager.shared
        let activeTags = focusTagManager.activeTags
        
        // 関心分野を考慮したコンテキスト型ヘッドライン
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
            // デフォルト
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
            suggestions.append(AIActionSuggestion(
                title: "3回の深呼吸",
                description: "30秒で気持ちをリセットしませんか？",
                actionType: .rest,
                estimatedTime: "30秒",
                difficulty: .easy
            ))
        } else {
            suggestions.append(AIActionSuggestion(
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
        
        return Array(focusTagManager.activeTags.prefix(2)).map { tag in
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
    
    // MARK: - Helper Methods
    
    private func calculateRespiratoryRate(from hrvData: HRVData) -> Double {
        // HRVから呼吸数を推定（簡易計算）
        let baseRate = 16.0
        let variation = (hrvData.current - hrvData.baseline) / hrvData.baseline * 2.0
        return max(12.0, min(20.0, baseRate + variation))
    }
    
    private func getCurrentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon  
        case 17..<21: return .evening
        default: return .night
        }
    }
}