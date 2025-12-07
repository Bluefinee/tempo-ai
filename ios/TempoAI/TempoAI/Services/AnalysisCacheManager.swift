import Foundation

// MARK: - Analysis Cache Manager

actor AnalysisCacheManager {

    private var cache: [String: CachedAnalysis] = [:]
    private let configuration: CacheConfiguration

    init(configuration: CacheConfiguration = .default) {
        self.configuration = configuration
    }

    func getCachedAnalysis(
        for key: String
    ) -> CachedAnalysis? {
        guard let cached = cache[key] else { return nil }

        // Check if cache is still valid
        if cached.expirationDate < Date() {
            cache.removeValue(forKey: key)
            return nil
        }

        // Update access tracking
        var updatedCache = cached
        updatedCache = CachedAnalysis(
            id: cached.id,
            requestHash: cached.requestHash,
            result: cached.result,
            expirationDate: cached.expirationDate,
            hitCount: cached.hitCount + 1,
            lastAccessed: Date(),
            size: cached.size
        )
        cache[key] = updatedCache

        return updatedCache
    }

    func cacheAnalysis(
        _ result: AnalysisResult,
        key: String,
        size: Int = 1024
    ) {
        let expirationDate = Date().addingTimeInterval(configuration.maxAge)

        let cached = CachedAnalysis(
            id: result.id,
            requestHash: key,
            result: result,
            expirationDate: expirationDate,
            hitCount: 0,
            lastAccessed: Date(),
            size: size
        )

        cache[key] = cached

        // Clean up if necessary
        if cache.count > configuration.maxSize {
            performCacheEviction()
        }
    }

    func getCacheStatistics() -> CacheStatistics {
        let totalSize = cache.values.reduce(0) { $0 + $1.size }
        let totalHits = cache.values.reduce(0) { $0 + $1.hitCount }
        let averageHitCount = cache.isEmpty ? 0.0 : Double(totalHits) / Double(cache.count)

        return CacheStatistics(
            totalEntries: cache.count,
            totalSize: totalSize,
            averageHitCount: averageHitCount,
            hitRate: calculateHitRate(),
            oldestEntry: cache.values.min { $0.lastAccessed < $1.lastAccessed }?.lastAccessed,
            newestEntry: cache.values.max { $0.lastAccessed < $1.lastAccessed }?.lastAccessed
        )
    }

    func clearCache() {
        cache.removeAll()
    }

    func clearExpiredEntries() {
        let now = Date()
        cache = cache.filter { _, cached in
            cached.expirationDate > now
        }
    }

    // MARK: - Cache Key Generation

    static func generateCacheKey(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) -> String {
        // Create a deterministic hash of the input parameters
        let dataComponents = [
            "\(healthData.vitalSigns.heartRate?.resting ?? 0)",
            "\(healthData.activity.steps)",
            "\(healthData.sleep.totalDuration)",
            "\(userProfile.age ?? 0)",
            userProfile.gender ?? "unknown",
            requestType.rawValue,
        ]

        let combined = dataComponents.joined(separator: "|")
        return combined.sha256Hash
    }

    // MARK: - Private Methods

    private func calculateDataSimilarity(
        _ current: ComprehensiveHealthData,
        _ cached: ComprehensiveHealthData
    ) -> Double {
        var similarity = 0.0
        var factors = 0

        // Compare heart rate
        if let currentHR = current.vitalSigns.heartRate?.resting,
            let cachedHR = cached.vitalSigns.heartRate?.resting
        {
            let hrSimilarity = 1.0 - min(1.0, abs(currentHR - cachedHR) / 50.0)
            similarity += hrSimilarity
            factors += 1
        }

        // Compare steps
        let stepDiff = abs(current.activity.steps - cached.activity.steps)
        let stepSimilarity = 1.0 - min(1.0, Double(stepDiff) / 5000.0)
        similarity += stepSimilarity
        factors += 1

        // Compare sleep
        let sleepDiff = abs(current.sleep.totalDuration - cached.sleep.totalDuration)
        let sleepSimilarity = 1.0 - min(1.0, sleepDiff / 7200.0)  // 2 hours
        similarity += sleepSimilarity
        factors += 1

        return factors > 0 ? similarity / Double(factors) : 0.0
    }

    private func performCacheEviction() {
        let entriesToRemove = cache.count - configuration.maxSize + 1

        switch configuration.evictionPolicy {
        case .lru:
            evictLRU(count: entriesToRemove)
        case .lfu:
            evictLFU(count: entriesToRemove)
        case .fifo:
            evictFIFO(count: entriesToRemove)
        case .ttl:
            clearExpiredEntries()
        case .size:
            evictLargest(count: entriesToRemove)
        }
    }

    private func evictLRU(count: Int) {
        let sortedByAccess = cache.sorted { $0.value.lastAccessed < $1.value.lastAccessed }
        for (key, _) in sortedByAccess.prefix(count) {
            cache.removeValue(forKey: key)
        }
    }

    private func evictLFU(count: Int) {
        let sortedByHitCount = cache.sorted { $0.value.hitCount < $1.value.hitCount }
        for (key, _) in sortedByHitCount.prefix(count) {
            cache.removeValue(forKey: key)
        }
    }

    private func evictFIFO(count: Int) {
        let sortedByCreation = cache.sorted { $0.value.id < $1.value.id }
        for (key, _) in sortedByCreation.prefix(count) {
            cache.removeValue(forKey: key)
        }
    }

    private func evictLargest(count: Int) {
        let sortedBySize = cache.sorted { $0.value.size > $1.value.size }
        for (key, _) in sortedBySize.prefix(count) {
            cache.removeValue(forKey: key)
        }
    }

    private func calculateHitRate() -> Double {
        // This would need to track cache misses to calculate properly
        // For now, return a placeholder
        return 0.0
    }
}

// MARK: - Cache Configuration

extension CacheConfiguration {
    static let `default` = CacheConfiguration(
        maxSize: 50,
        maxAge: 3600,  // 1 hour
        compressionEnabled: false,
        encryptionEnabled: false,
        evictionPolicy: .lru
    )

    static let performance = CacheConfiguration(
        maxSize: 100,
        maxAge: 1800,  // 30 minutes
        compressionEnabled: true,
        encryptionEnabled: false,
        evictionPolicy: .lfu
    )

    static let privacy = CacheConfiguration(
        maxSize: 25,
        maxAge: 900,  // 15 minutes
        compressionEnabled: true,
        encryptionEnabled: true,
        evictionPolicy: .ttl
    )
}

// MARK: - Cache Statistics

struct CacheStatistics {
    let totalEntries: Int
    let totalSize: Int
    let averageHitCount: Double
    let hitRate: Double
    let oldestEntry: Date?
    let newestEntry: Date?
}

// MARK: - String Hashing Extension

extension String {
    var sha256Hash: String {
        // Simplified hash - in production, use proper cryptographic hashing
        return "\(self.hashValue)"
    }
}
