import Foundation
import os.log

/// 高度な分析結果キャッシュ管理
/// 多層キャッシュとコスト最適化を実現
class AnalysisCacheManager: AnalysisCacheManagerProtocol {
    // MARK: - Cache Layers

    /// Layer 1: メモリキャッシュ（1時間）
    private let layer1Cache = NSCache<NSString, CachedAnalysisEntry>()
    /// Layer 2: UserDefaults永続キャッシュ（4時間）
    private let layer2Cache = UserDefaults.standard

    private let cacheQueue = DispatchQueue(label: "cache.queue", attributes: .concurrent)

    // MARK: - Cache Configuration

    private enum CacheConstants {
        static let layer1TTL: TimeInterval = 3600  // 1時間
        static let layer2TTL: TimeInterval = 14400  // 4時間
        static let maxCacheSize: Int = 100  // 最大キャッシュエントリ数
    }

    // MARK: - Initialization

    init() {
        setupCacheConfiguration()
    }

    // MARK: - AnalysisCacheManagerProtocol Implementation

    func getCachedAIAnalysis(for staticResult: AnalysisResult) async -> AIAnalysisResponse? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async {
                let result = self.performCacheLookup(for: staticResult)
                continuation.resume(returning: result)
            }
        }
    }

    func cacheAIAnalysis(_ analysis: AIAnalysisResponse, for staticResult: AnalysisResult) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                self.performCacheStorage(analysis, for: staticResult)
                continuation.resume()
            }
        }
    }

    func clearCache() async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                self.performCacheClear()
                continuation.resume()
            }
        }
    }

    // MARK: - Private Methods - Cache Operations

    /**
     * キャッシュ設定の初期化
     */
    private func setupCacheConfiguration() {
        layer1Cache.countLimit = CacheConstants.maxCacheSize
        layer1Cache.totalCostLimit = 50 * 1024 * 1024  // 50MB
    }

    /**
     * 多層キャッシュ検索
     */
    private func performCacheLookup(for staticResult: AnalysisResult) -> AIAnalysisResponse? {
        let cacheKey = generateCacheKey(for: staticResult)

        // Layer 1: メモリキャッシュ（最新・最速）
        if let layer1Entry = layer1Cache.object(forKey: cacheKey as NSString),
            layer1Entry.isValid()
        {
            os_log("Cache hit: Layer 1 (memory)", log: .default, type: .info)
            return layer1Entry.analysis
        }

        // Layer 2: 永続キャッシュ（類似コンテキスト）
        if let layer2Analysis = checkLayer2Cache(cacheKey: cacheKey) {
            os_log("Cache hit: Layer 2 (persistent)", log: .default, type: .info)
            // Layer 1にプロモート
            promoteToLayer1(analysis: layer2Analysis, cacheKey: cacheKey)
            return layer2Analysis
        }

        os_log("Cache miss: Fresh analysis required", log: .default, type: .info)
        return nil
    }

    /**
     * キャッシュストレージ
     */
    private func performCacheStorage(_ analysis: AIAnalysisResponse, for staticResult: AnalysisResult) {
        let cacheKey = generateCacheKey(for: staticResult)

        // Layer 1: メモリキャッシュ
        let entry = CachedAnalysisEntry(
            analysis: analysis,
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(CacheConstants.layer1TTL)
        )
        layer1Cache.setObject(entry, forKey: cacheKey as NSString)

        // Layer 2: 永続キャッシュ
        storeInLayer2Cache(analysis: analysis, cacheKey: cacheKey)

        os_log("Analysis cached: %{public}@", log: .default, type: .info, cacheKey)
    }

    /**
     * キャッシュクリア
     */
    private func performCacheClear() {
        layer1Cache.removeAllObjects()
        clearLayer2Cache()
        os_log("All caches cleared", log: .default, type: .info)
    }

    // MARK: - Layer 2 Cache Management

    /**
     * Layer 2キャッシュ確認
     */
    private func checkLayer2Cache(cacheKey: String) -> AIAnalysisResponse? {
        let storageKey = "cache_\(cacheKey)"

        guard let data = layer2Cache.data(forKey: storageKey),
            let entry = try? JSONDecoder().decode(PersistentCacheEntry.self, from: data)
        else {
            return nil
        }

        // 有効期限チェック
        if entry.expiresAt < Date() {
            layer2Cache.removeObject(forKey: storageKey)
            return nil
        }

        return entry.analysis
    }

    /**
     * Layer 2キャッシュ保存
     */
    private func storeInLayer2Cache(analysis: AIAnalysisResponse, cacheKey: String) {
        let entry = PersistentCacheEntry(
            analysis: analysis,
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(CacheConstants.layer2TTL)
        )

        do {
            let data = try JSONEncoder().encode(entry)
            layer2Cache.set(data, forKey: "cache_\(cacheKey)")
        } catch {
            os_log(
                "Failed to store in Layer 2 cache: %{public}@", log: .default, type: .error, error.localizedDescription)
        }
    }

    /**
     * Layer 2キャッシュクリア
     */
    private func clearLayer2Cache() {
        let keys = layer2Cache.dictionaryRepresentation().keys.filter { $0.hasPrefix("cache_") }
        for key in keys {
            layer2Cache.removeObject(forKey: key)
        }
    }

    /**
     * Layer 1にプロモート
     */
    private func promoteToLayer1(analysis: AIAnalysisResponse, cacheKey: String) {
        let entry = CachedAnalysisEntry(
            analysis: analysis,
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(CacheConstants.layer1TTL)
        )
        layer1Cache.setObject(entry, forKey: cacheKey as NSString)
    }

    // MARK: - Utility Methods

    /**
     * キャッシュキー生成
     */
    private func generateCacheKey(for staticResult: AnalysisResult) -> String {
        guard let analysis = staticResult.staticAnalysis else {
            return "fallback_\(Date().timeIntervalSince1970)"
        }

        let energyBucket = Int(analysis.energyLevel / 10) * 10  // 10%バケット
        let timestamp = Date().timeIntervalSince1970
        let hourBucket = Int(timestamp / 3600)  // 1時間バケット

        return "analysis_\(energyBucket)_\(analysis.batteryState.rawValue)_\(hourBucket)"
    }
}

// MARK: - Supporting Types

/// メモリキャッシュエントリ
class CachedAnalysisEntry: NSObject {
    let analysis: AIAnalysisResponse
    let timestamp: Date
    let expiresAt: Date

    init(analysis: AIAnalysisResponse, timestamp: Date, expiresAt: Date) {
        self.analysis = analysis
        self.timestamp = timestamp
        self.expiresAt = expiresAt
        super.init()
    }

    func isValid() -> Bool {
        return Date() < expiresAt
    }
}

/// 永続キャッシュエントリ
struct PersistentCacheEntry: Codable {
    let analysis: AIAnalysisResponse
    let timestamp: Date
    let expiresAt: Date
}
