import Foundation

// MARK: - Health Analysis Engine Types

// AnalysisRequestType is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AnalysisRoute is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// AIAnalysisDecision is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AIAnalysisReason is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// LocalAnalysisDecision is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// LocalAnalysisReason is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// HybridAnalysisDecision is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// HybridStrategy is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// RoutingDecision is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AIDecisionFactors is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// LocalAnalysisFallbackParams is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AnalysisComplexity is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// UserEngagement is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// TimeSensitivity is defined in HealthAnalysisEngine.swift with computed properties
// This avoids duplicate type definitions

// MARK: - Analysis Result Types

struct AnalysisResult {
    let id: String
    let route: AnalysisRoute
    let insights: AnalysisInsights
    let confidence: Double
    let processingTime: TimeInterval
    let cost: Double?
    let timestamp: Date
    let isPartial: Bool
    let metadata: [String: Any]
}

enum AnalysisInsights {
    case ai(AIHealthInsights)
    case local(LocalHealthInsights)
    case hybrid(HybridHealthInsights)
}

struct HybridHealthInsights {
    let localInsights: LocalHealthInsights
    let aiInsights: AIHealthInsights?
    let combinedScore: Double
    let confidence: Double
    let enhancedRecommendations: [ActionableRecommendation]
    let validationResults: ValidationResults
}

struct ValidationResults {
    let localAgreement: Double
    let confidenceAlignment: Double
    let recommendationConsistency: Double
    let overallValidation: Double
}

// AnalysisPerformanceMetrics is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AnalysisCapabilities is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// MARK: - Cache Related Types

struct CachedAnalysis {
    let id: String
    let requestHash: String
    let result: AnalysisResult
    let expirationDate: Date
    let hitCount: Int
    let lastAccessed: Date
    let size: Int
}

struct CacheConfiguration {
    let maxSize: Int
    let maxAge: TimeInterval
    let compressionEnabled: Bool
    let encryptionEnabled: Bool
    let evictionPolicy: CacheEvictionPolicy
    
    static let `default` = CacheConfiguration(
        maxSize: 50,
        maxAge: 3600, // 1 hour
        compressionEnabled: true,
        encryptionEnabled: false,
        evictionPolicy: .lru
    )
}

enum CacheEvictionPolicy: String, CaseIterable {
    case lru = "least_recently_used"
    case lfu = "least_frequently_used"
    case fifo = "first_in_first_out"
    case ttl = "time_to_live"
    case size = "size_based"
}

// MARK: - Decision Engine Types

struct DecisionCriteria {
    let priorityWeights: [String: Double]
    let thresholds: [String: Double]
    let constraints: [String: Any]
    let preferences: UserAnalysisPreferences?
}

struct UserAnalysisPreferences {
    let preferredRoute: AnalysisRoute?
    let maxWaitTime: TimeInterval?
    let budgetConstraints: Double?
    let privacyLevel: PrivacyLevel
    let qualityOverSpeed: Bool
}

// PrivacyLevel is defined in Models/AIAnalysisModels.swift with Codable support
// This avoids duplicate type definitions

// MARK: - Analysis Engine Status Types

struct EngineStatus {
    let aiServiceAvailable: Bool
    let localProcessingEnabled: Bool
    let hybridModeSupported: Bool
    let currentLoad: Double
    let averageResponseTime: TimeInterval
    let budgetUtilization: Double
    let healthStatus: EngineHealthStatus
}

enum EngineHealthStatus: String, CaseIterable {
    case optimal = "optimal"
    case degraded = "degraded"
    case limited = "limited"
    case unavailable = "unavailable"
}
