import Foundation

/**
 * AI分析サービスのモック実装
 * 開発・テスト用の基本的な応答を提供
 */
class MockAIAnalysisService: AIAnalysisServiceProtocol {
    
    func generateAnalysis(from staticResult: AnalysisResult) async throws -> AIAnalysisResponse {
        // 静的分析結果に基づいてモック応答を生成
        guard let staticAnalysis = staticResult.staticAnalysis else {
            throw AIAnalysisServiceError.invalidStaticAnalysis
        }
        
        // エネルギーレベルに応じたメッセージ生成
        let (title, subtitle, impactLevel) = generateHeadline(energyLevel: staticAnalysis.energyLevel)
        let energyComment = generateEnergyComment(energyLevel: staticAnalysis.energyLevel)
        
        return AIAnalysisResponse(
            headline: HeadlineInsight(
                title: title,
                subtitle: subtitle,
                impactLevel: impactLevel,
                confidence: 85.0
            ),
            energyComment: energyComment,
            tagInsights: generateTagInsights(),
            aiActionSuggestions: generateSmartSuggestions(energyLevel: staticAnalysis.energyLevel),
            detailAnalysis: generateDetailAnalysis(staticAnalysis: staticAnalysis),
            dataQuality: DataQuality(
                healthDataCompleteness: 90.0,
                weatherDataAge: 15,
                analysisTimestamp: Date()
            ),
            generatedAt: Date()
        )
    }
    
    private func generateHeadline(energyLevel: Double) -> (String, String, ImpactLevel) {
        switch energyLevel {
        case 0..<30:
            return ("エネルギー不足", "今日は無理せず、回復に専念しましょう", .high)
        case 30..<50:
            return ("疲れ気味", "ペースを落として、自分を労ってください", .medium)
        case 50..<75:
            return ("安定したコンディション", "今日はバランス良く過ごせそうです", .low)
        default:
            return ("調子良好", "今日は積極的に活動できる日です", .low)
        }
    }
    
    private func generateEnergyComment(energyLevel: Double) -> String {
        switch energyLevel {
        case 0..<30:
            return "エネルギーが低下しています。十分な休息を取りましょう。"
        case 30..<50:
            return "少し疲れが見えます。無理をせず、ペースを調整してみませんか？"
        case 50..<75:
            return "バランスの取れた状態を保っています。"
        default:
            return "調子が良いですね！今日のエネルギーを有効活用しましょう。"
        }
    }
    
    private func generateTagInsights() -> [TagInsight] {
        return [
            TagInsight(
                tag: .sleep,
                icon: "bed.double.circle",
                message: "睡眠の質が良好です",
                urgency: .info
            )
        ]
    }
    
    private func generateSmartSuggestions(energyLevel: Double) -> [AIActionSuggestion] {
        if energyLevel < 50 {
            return [
                AIActionSuggestion(
                    title: "深呼吸をする",
                    description: "3回の深呼吸で気持ちをリセットしませんか？",
                    actionType: .rest,
                    estimatedTime: "1分",
                    difficulty: .easy
                )
            ]
        } else {
            return [
                AIActionSuggestion(
                    title: "軽い散歩",
                    description: "外の空気を吸いながら、5分間歩いてみましょう",
                    actionType: .exercise,
                    estimatedTime: "5分",
                    difficulty: .easy
                )
            ]
        }
    }
    
    private func generateDetailAnalysis(staticAnalysis: StaticAnalysis) -> String {
        return """
        今日の分析結果：
        
        エネルギーレベル: \(Int(staticAnalysis.energyLevel))%
        睡眠スコア: \(Int(staticAnalysis.basicMetrics.sleepScore))点
        活動スコア: \(Int(staticAnalysis.basicMetrics.activityScore))点
        ストレススコア: \(Int(staticAnalysis.basicMetrics.stressScore))点
        
        総合的に見て、\(staticAnalysis.generateBasicMessage())
        """
    }
}

enum AIAnalysisServiceError: Error, LocalizedError {
    case invalidStaticAnalysis
    
    var errorDescription: String? {
        switch self {
        case .invalidStaticAnalysis:
            return "静的分析データが無効です"
        }
    }
}