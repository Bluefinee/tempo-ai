import Foundation
import HealthKit

// MARK: - Local Health Analyzer Supporting Types

/// Health analysis categories
enum HealthCategory: String, CaseIterable {
    case cardiovascular
    case metabolic
    case respiratory
    case sleep
    case activity
    case nutrition
    case mental
    case recovery
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
    case normal
    case caution
    case concern
    case critical
    case positive
}

/// Finding severity levels
enum Severity: String, CaseIterable {
    case low
    case moderate
    case high
    case severe
}

/// Risk assessment levels
enum RiskLevel: String, CaseIterable {
    case low
    case moderate
    case high
    case severe
}

/// Analysis methodology information
enum AnalysisMethod: String, CaseIterable {
    case evidenceBased = "evidence_based"
    case comparative
    case longitudinal
    case riskAdjusted = "risk_adjusted"
    case local = "local"
    case ai = "ai"
    case hybrid = "hybrid"
    case localFallback = "local_fallback"
}

/// Personalized recommendations structure
struct PersonalizedRecommendations {
    let immediate: [ActionableRecommendation]
    let shortTerm: [ActionableRecommendation]  // 1-4 weeks
    let longTerm: [ActionableRecommendation]  // 1+ months
    let lifestyle: [ActionableRecommendation]
    let medical: [ActionableRecommendation]
}


/// Recommendation priorities
enum Priority: String, CaseIterable {
    case low
    case medium
    case high
    case urgent
}

/// Data quality assessment
struct DataQuality: Codable {
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
    case dietary
    case exercise
    case sleep
    case stress
    case medical
    case lifestyle
    case monitoring
}
