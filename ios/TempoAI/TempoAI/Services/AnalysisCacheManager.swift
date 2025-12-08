import Foundation

/**
 * 分析結果のキャッシュ管理
 * 基本的なメモリキャッシュを提供
 */
class AnalysisCacheManager: AnalysisCacheManagerProtocol {
    
    private var cache: [String: AIAnalysisResponse] = [:]
    private let cacheQueue = DispatchQueue(label: "cache.queue", attributes: .concurrent)
    
    func getCachedAIAnalysis(for staticResult: AnalysisResult) async -> AIAnalysisResponse? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async {
                let key = self.generateCacheKey(for: staticResult)
                continuation.resume(returning: self.cache[key])
            }
        }
    }
    
    func cacheAIAnalysis(_ analysis: AIAnalysisResponse, for staticResult: AnalysisResult) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                let key = self.generateCacheKey(for: staticResult)
                self.cache[key] = analysis
                continuation.resume()
            }
        }
    }
    
    func clearCache() async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                self.cache.removeAll()
                continuation.resume()
            }
        }
    }
    
    private func generateCacheKey(for staticResult: AnalysisResult) -> String {
        guard let analysis = staticResult.staticAnalysis else {
            return "fallback"
        }
        return "\(Int(analysis.energyLevel))_\(analysis.batteryState.rawValue)"
    }
}