import Foundation

// MARK: - Rate Limiting Configuration and Types

struct RateLimitConfiguration {
    // Hourly limits by request type
    let hourlyLimits: [AnalysisRequestType: Int] = [
        .quick: 20,
        .daily: 5,
        .comprehensive: 2,
        .weekly: 1,
        .critical: 3,
        .userRequested: 3,
    ]

    // Daily limits by request type
    let dailyLimits: [AnalysisRequestType: Int] = [
        .quick: 50,
        .daily: 10,
        .comprehensive: 5,
        .weekly: 3,
        .critical: 10,
        .userRequested: 8,
    ]

    // Weekly limits by request type
    let weeklyLimits: [AnalysisRequestType: Int] = [
        .quick: 200,
        .daily: 50,
        .comprehensive: 20,
        .weekly: 10,
        .critical: 30,
        .userRequested: 25,
    ]

    // Monthly limits by request type
    let monthlyLimits: [AnalysisRequestType: Int] = [
        .quick: 500,
        .daily: 150,
        .comprehensive: 50,
        .weekly: 30,
        .critical: 100,
        .userRequested: 80,
    ]

    // Default limits for unknown types
    let defaultHourlyLimit = 5
    let defaultDailyLimit = 15
    let defaultWeeklyLimit = 50
    let defaultMonthlyLimit = 100
}

enum RateLimitResult {
    case allowed
    case rateLimited(resetTime: Date, limitType: LimitType)
    case budgetExceeded(resetTime: Date)
    case dailyQuotaReached(resetTime: Date)
    case criticalOnly
}

enum LimitType: String, CaseIterable {
    case hourly
    case daily
    case weekly
    case monthly
    case budget
}

struct AIRequestRecord {
    let id: UUID
    let requestType: AnalysisRequestType
    let timestamp: Date
    let success: Bool
    let responseTime: TimeInterval
    let tokensUsed: Int
    let estimatedCost: Double
    let errorMessage: String?
}

struct AIUsageStatus {
    let currentHourUsage: [AnalysisRequestType: Int]
    let currentDayUsage: [AnalysisRequestType: Int]
    let currentWeekUsage: [AnalysisRequestType: Int]
    let currentMonthUsage: [AnalysisRequestType: Int]
    let totalCostThisMonth: Double
    let remainingBudget: Double
    let nextResetTime: Date
    let availability: AIAvailabilityStatus
}

struct RequestTypeUsage {
    let requestType: AnalysisRequestType
    let hourlyUsed: Int
    let hourlyLimit: Int
    let dailyUsed: Int
    let dailyLimit: Int
    let weeklyUsed: Int
    let weeklyLimit: Int
    let monthlyUsed: Int
    let monthlyLimit: Int
    let isAvailable: Bool
}

struct BudgetStatus {
    let totalBudget: Double
    let usedAmount: Double
    let remainingAmount: Double
    let percentageUsed: Double
    let estimatedDaysRemaining: Int
    let onTrackForMonth: Bool
}

struct RequestType {
    let type: AnalysisRequestType
    let priority: Int
    let estimatedCost: Double
    let averageTokens: Int
    let description: String
}

struct RateLimitInfo {
    let isLimited: Bool
    let limitType: LimitType?
    let resetTime: Date?
    let remainingRequests: Int
    let totalLimit: Int
    let timeUntilReset: TimeInterval?
}

struct AIAvailabilityStatus {
    let isAvailable: Bool
    let reason: String?
    let limitingFactor: LimitingFactor?
    let nextAvailableTime: Date?
    let allowedTypes: [AnalysisRequestType]
}

struct PredictionResult {
    let canMakeRequest: Bool
    let estimatedWaitTime: TimeInterval?
    let alternativeTypes: [AnalysisRequestType]
    let recommendation: String
}

enum LimitingFactor: String, CaseIterable {
    case hourlyLimit = "hourly_limit"
    case dailyLimit = "daily_limit"
    case weeklyLimit = "weekly_limit"
    case monthlyLimit = "monthly_limit"
    case budgetLimit = "budget_limit"
    case systemMaintenance = "system_maintenance"
    case none = "none"
}

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
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
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
    case unusualSpike = "unusual_spike"
    case unusualDrop = "unusual_drop"
    case offPeakUsage = "off_peak_usage"
    case rapidConsumption = "rapid_consumption"
    case errorSpike = "error_spike"
}

enum AnnomalySeverity: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

struct UsageRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let potentialSavings: Double?
    let implementationDifficulty: ImplementationDifficulty
    let priority: RecommendationPriority
}

enum RecommendationType: String, CaseIterable {
    case budgetOptimization = "budget_optimization"
    case usagePatternOptimization = "usage_pattern_optimization"
    case requestTypeOptimization = "request_type_optimization"
    case timingOptimization = "timing_optimization"
    case errorReduction = "error_reduction"
}

enum ImplementationDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
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
    case increasing = "increasing"
    case decreasing = "decreasing"
    case stable = "stable"
    case volatile = "volatile"
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
    case timing = "timing"
    case requestType = "request_type"
    case frequency = "frequency"
    case errorHandling = "error_handling"
    case budgetManagement = "budget_management"
}
