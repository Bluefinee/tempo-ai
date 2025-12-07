import Foundation

// MARK: - Rate Limiting Configuration and Types

// RateLimitConfiguration is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// RateLimitResult is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// LimitType is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// AIRequestRecord is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// AIUsageStatus is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// RequestTypeUsage is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// BudgetStatus is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// RequestType is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// RateLimitInfo is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// AIAvailabilityStatus is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// PredictionResult is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// LimitingFactor is defined in AIRequestRateLimiter.swift
// This avoids duplicate type definitions

// MARK: - Usage Analytics Types

struct AIUsageStatistics {
    let totalRequests: Int
    let successfulRequests: Int
    let failedRequests: Int
    let averageResponseTime: TimeInterval
    let totalTokensUsed: Int
    let totalCostIncurred: Double
    let requestsByType: [AnalysisRequestType: Int]
    let peakUsageHours: [Int]
    let costByType: [AnalysisRequestType: Double]
    let period: StatisticsPeriod
}

enum StatisticsPeriod: String, CaseIterable {
    case hour
    case day
    case week
    case month
    case year
}

struct UsageAnalytics {
    let currentUsage: AIUsageStatistics
    let historicalTrends: [AIUsageStatistics]
    let predictions: UsagePredictions
    let recommendations: [UsageRecommendation]
    let anomalies: [UsageAnomaly]
}

struct UsagePredictions {
    let projectedDailyUsage: Int
    let projectedWeeklyCost: Double
    let projectedMonthlyBudgetUsage: Double
    let peakUsageTimes: [Date]
    let confidence: Double
}

struct UsageAnomaly {
    let timestamp: Date
    let pattern: UsageAnomalyPattern
    let severity: AnnomalySeverity
    let description: String
    let impact: String
}

enum UsageAnomalyPattern: String, CaseIterable {
    case unusualSpike
    case unusualDrop
    case offPeakUsage
    case rapidConsumption
    case errorSpike
}

enum AnnomalySeverity: String, CaseIterable {
    case low
    case medium
    case high
    case critical
}

struct UsageRecommendation {
    let type: AnalyticsRecommendationType
    let title: String
    let description: String
    let potentialSavings: Double?
    let implementationDifficulty: ImplementationDifficulty
    let priority: RecommendationPriority
}

// Using AnalyticsRecommendationType to avoid conflict with other RecommendationType enums
enum AnalyticsRecommendationType: String, CaseIterable {
    case budgetOptimization
    case usagePatternOptimization
    case requestTypeOptimization
    case timingOptimization
    case errorReduction
}

enum ImplementationDifficulty: String, CaseIterable {
    case easy
    case medium
    case hard
}

// RecommendationPriority is defined in Models/AIAnalysisModels.swift with Codable support
// This avoids duplicate type definitions

// MARK: - Cost Calculation Types

// CostBreakdown is defined in Services/AICostCalculator.swift
// This avoids duplicate type definitions

// CostEstimate is defined in Services/AICostCalculator.swift
// This avoids duplicate type definitions

// MARK: - Pattern Analysis Types

struct UsagePatternAnalysis {
    let peakHours: [Int]
    let averageRequestsPerHour: Double
    let mostUsedRequestType: AnalysisRequestType
    let costTrend: CostTrend
    let efficiency: UsageEfficiency
    let recommendations: [OptimizationRecommendation]
}

enum CostTrend: String, CaseIterable {
    case increasing
    case decreasing
    case stable
    case volatile
}

struct UsageEfficiency {
    let successRate: Double
    let averageResponseTime: TimeInterval
    let costPerSuccessfulRequest: Double
    let optimalUsageScore: Double
}

struct OptimizationRecommendation {
    let category: OptimizationCategory
    let suggestion: String
    let potentialImprovement: String
    let implementationEffort: ImplementationDifficulty
}

enum OptimizationCategory: String, CaseIterable {
    case timing
    case requestType
    case frequency
    case errorHandling
    case budgetManagement
}
