/**
 * @fileoverview AI Analysis Protocols
 *
 * AI分析関連のプロトコル定義。
 * 依存性注入と抽象化により、テストと疎結合を実現します。
 */

import Foundation

/// AI分析サービスのプロトコル
protocol AIAnalysisServiceProtocol {
    func generateAnalysis(from staticResult: AnalysisResult) async throws -> AIAnalysisResponse
}

/// 分析キャッシュマネージャーのプロトコル
protocol AnalysisCacheManagerProtocol {
    func getCachedAIAnalysis(for staticResult: AnalysisResult) async -> AIAnalysisResponse?
    func cacheAIAnalysis(_ analysis: AIAnalysisResponse, for staticResult: AnalysisResult) async
    func clearCache() async
}