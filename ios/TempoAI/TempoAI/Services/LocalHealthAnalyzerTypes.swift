import Foundation
import HealthKit

// MARK: - Local Health Analyzer Supporting Types

/// Health analysis categories
enum HealthCategory: String, CaseIterable {
    case cardiovascular = "cardiovascular"
    case metabolic = "metabolic"
    case respiratory = "respiratory"
    case sleep = "sleep"
    case activity = "activity"
    case nutrition = "nutrition"
    case mental = "mental"
    case recovery = "recovery"
}

/// Health category insights
struct HealthCategoryInsight {
    let category: HealthCategory
    let score: Double  // 0-100
    let findings: [HealthFinding]
    let recommendations: [String]
    let riskFactors: [HealthRiskFactor]
    let trend: HealthTrend
    let confidence: Double
}

/// Individual health finding
struct HealthFinding {
    let type: FindingType
    let severity: Severity
    let description: String
    let value: String
    let normalRange: String?
    let explanation: String
    let actionRequired: Bool
}

/// Finding classification
enum FindingType: String, CaseIterable {
    case normal = "normal"
    case caution = "caution"
    case concern = "concern"
    case critical = "critical"
    case positive = "positive"
}

/// Finding severity levels
enum Severity: String, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}

/// Health risk factors
struct HealthRiskFactor {
    let name: String
    let level: RiskLevel
    let description: String
    let modifiable: Bool
    let recommendations: [String]
}

/// Risk assessment levels
enum RiskLevel: String, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}

/// Main local health insights structure
struct LocalHealthInsights {
    let timestamp: Date
    let overallScore: Double
    let categoryInsights: [HealthCategoryInsight]
    let quickInsights: QuickHealthInsights
    let personalizedRecommendations: PersonalizedRecommendations
    let analysisMethod: AnalysisMethod
    let dataQuality: DataQuality
    let language: String
}

/// Quick insights for immediate display
struct QuickHealthInsights {
    let topFindings: [HealthFinding]
    let keyRecommendations: [String]
    let priorityActions: [ActionableRecommendation]
    let healthHighlights: [String]
    let concernAreas: [String]
}

/// Analysis methodology information
enum AnalysisMethod: String, CaseIterable {
    case evidenceBased = "evidence_based"
    case comparative = "comparative"
    case longitudinal = "longitudinal"
    case riskAdjusted = "risk_adjusted"
}

/// Personalized recommendations structure
struct PersonalizedRecommendations {
    let immediate: [ActionableRecommendation]
    let shortTerm: [ActionableRecommendation]  // 1-4 weeks
    let longTerm: [ActionableRecommendation]  // 1+ months
    let lifestyle: [ActionableRecommendation]
    let medical: [ActionableRecommendation]
}

/// Actionable recommendation
struct ActionableRecommendation {
    let title: String
    let description: String
    let priority: Priority
    let category: HealthCategory
    let timeframe: String
    let difficulty: String
    let expectedBenefit: String
    let trackable: Bool
}

/// Recommendation priorities
enum Priority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}

/// Health trend analysis
struct HealthTrend {
    let direction: TrendDirection
    let magnitude: Double
    let confidence: Double
    let timeframe: String
    let description: String
}

/// Trend direction indicators
enum TrendDirection: String, CaseIterable {
    case improving = "improving"
    case stable = "stable"
    case declining = "declining"
    case fluctuating = "fluctuating"
}

/// Data quality assessment
struct DataQuality {
    let completeness: Double  // 0-1
    let recency: Double  // 0-1
    let accuracy: Double  // 0-1
    let consistency: Double  // 0-1
    let overallScore: Double
    let recommendations: [String]
}

/// Medical analysis structure
struct MedicalAnalysis {
    let findings: [HealthFinding]
    let riskFactors: [HealthRiskFactor]
    let recommendations: [String]
    let referrals: [String]
    let followUpNeeded: Bool
    let urgencyLevel: Severity
}

/// Recommendation types for personalization
enum RecommendationType: String, CaseIterable {
    case dietary = "dietary"
    case exercise = "exercise"
    case sleep = "sleep"
    case stress = "stress"
    case medical = "medical"
    case lifestyle = "lifestyle"
    case monitoring = "monitoring"
}
