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

/// Health recommendation types for personalization
enum HealthRecommendationType: String, CaseIterable {
    case dietary
    case exercise
    case sleep
    case stress
    case medical
    case lifestyle
    case monitoring
    case immediate
    case shortTerm
    case longTerm
}

// MARK: - Additional LocalHealthAnalyzer Types

struct LocalHealthInsights {
    let overallScore: Double
    let keyInsights: [String]
    let categoryInsights: CategoryInsights
    let riskFactors: [HealthRiskFactor]
    let recommendations: PersonalizedRecommendations
    let trends: [HealthTrend]
    let dataQuality: DataQuality
    let confidenceScore: Double
    let analysisMethod: AnalysisMethod
    let generatedAt: Date
    let language: String
}

struct CategoryInsights {
    let cardiovascular: HealthCategoryInsight
    let sleep: HealthCategoryInsight
    let activity: HealthCategoryInsight
    let metabolic: HealthCategoryInsight
}

struct QuickHealthInsights {
    let score: Int
    let summary: String
    let topPriority: String
    let quickTip: String
    let dataQuality: String
    let timestamp: Date
}

// MARK: - User Profile Extension

extension UserProfile {
    var estimatedFitnessLevel: String {
        switch exerciseFrequency {
        case "daily":
            return "high"
        case "weekly":
            return "moderate"
        case "monthly":
            return "low"
        default:
            return "sedentary"
        }
    }
}

// MARK: - LocalHealthInsights Extensions for Notifications

extension LocalHealthInsights {

    /// Check if insights have significant findings that warrant notifications
    var hasSignificantFindings: Bool {
        return overallScore < 70  // Overall health score is concerning
            || riskFactors.contains { $0.severity >= 7 }  // High-severity risk factors
            || recommendations.immediate.contains { $0.priority == .high }  // High-priority recommendations
    }

    /// Convert LocalHealthInsights to AIHealthInsights for notification compatibility
    func toAIHealthInsights() -> AIHealthInsights {
        return AIHealthInsights(
            id: UUID().uuidString,
            summary: "健康分析が完了しました。全体スコア: \(Int(overallScore))点",
            analysisDate: Date(),
            overallScore: Int(overallScore),
            riskFactors: riskFactors.map { factor in
                RiskFactor(
                    category: factor.category,
                    severity: Int(factor.severity),
                    description: factor.factor,
                    recommendation: factor.recommendation ?? "定期的なモニタリングをお勧めします"
                )
            },
            recommendations: recommendations.immediate.map { rec in
                Recommendation(
                    title: rec.title,
                    description: rec.description,
                    priority: rec.priority.rawValue,
                    category: rec.category?.rawValue ?? "general",
                    estimatedImpact: rec.expectedBenefit
                )
            },
            language: language
        )
    }
}
