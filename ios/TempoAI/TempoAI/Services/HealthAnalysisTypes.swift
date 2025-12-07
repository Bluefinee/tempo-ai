import Foundation

// MARK: - Health Analysis Engine Types

// AnalysisRequestType is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

enum AnalysisRoute: String, CaseIterable {
    case ai = "ai"
    case local = "local"
    case hybrid = "hybrid"
    case fallback = "fallback"
}

struct AIAnalysisDecision {
    let shouldUseAI: Bool
    let reason: AIAnalysisReason
    let confidence: Double
    let estimatedCost: Double?
    let estimatedResponseTime: TimeInterval
    let fallbackToLocal: Bool
}

enum AIAnalysisReason: String, CaseIterable {
    case highComplexity = "high_complexity"
    case patternRecognition = "pattern_recognition"
    case trendsAnalysis = "trends_analysis"
    case userPreference = "user_preference"
    case comprehensiveAnalysis = "comprehensive_analysis"
    case criticalHealth = "critical_health"
    case dataRichness = "data_richness"
    case timePermitting = "time_permitting"
    case budgetAvailable = "budget_available"
}

struct LocalAnalysisDecision {
    let canProcessLocally: Bool
    let reason: LocalAnalysisReason
    let confidence: Double
    let estimatedAccuracy: Double
    let processingTime: TimeInterval
    let limitations: [String]
}

enum LocalAnalysisReason: String, CaseIterable {
    case simpleMetrics = "simple_metrics"
    case standardGuidelines = "standard_guidelines"
    case quickAssessment = "quick_assessment"
    case offlineMode = "offline_mode"
    case privacyPreferred = "privacy_preferred"
    case budgetConstraints = "budget_constraints"
    case fastResponseNeeded = "fast_response_needed"
    case basicAnalysisOnly = "basic_analysis_only"
}

struct HybridAnalysisDecision {
    let strategy: HybridStrategy
    let localComponents: [String]
    let aiComponents: [String]
    let estimatedCombinedAccuracy: Double
    let costBenefit: Double
}

enum HybridStrategy: String, CaseIterable {
    case localFirst = "local_first"
    case aiEnhanced = "ai_enhanced"
    case parallel = "parallel"
    case sequential = "sequential"
    case validationBased = "validation_based"
}

// RoutingDecision is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

// AIDecisionFactors is defined in HealthAnalysisEngine.swift
// This avoids duplicate type definitions

struct LocalAnalysisFallbackParams {
    let maxWaitTime: TimeInterval
    let minimumAccuracyThreshold: Double
    let enabledComponents: [String]
    let degradedModeSettings: [String: Any]
}

enum AnalysisComplexity: String, CaseIterable {
    case simple = "simple"
    case moderate = "moderate"
    case complex = "complex"
    case veryComplex = "very_complex"
}

enum UserEngagement: String, CaseIterable {
    case passive = "passive"
    case active = "active"
    case interactive = "interactive"
    case critical = "critical"
}

enum TimeSensitivity: String, CaseIterable {
    case realTime = "real_time"
    case immediate = "immediate"
    case standard = "standard"
    case deferred = "deferred"
}

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

struct AnalysisPerformanceMetrics {
    let routingDecisionTime: TimeInterval
    let analysisExecutionTime: TimeInterval
    let totalProcessingTime: TimeInterval
    let accuracy: Double?
    let costEfficiency: Double?
    let userSatisfaction: Double?
    let route: AnalysisRoute
}

struct AnalysisCapabilities {
    let aiAvailable: Bool
    let localCapabilities: [String]
    let hybridStrategies: [HybridStrategy]
    let estimatedAIResponseTime: TimeInterval?
    let localProcessingSpeed: Double
    let budgetRemaining: Double?
}

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
