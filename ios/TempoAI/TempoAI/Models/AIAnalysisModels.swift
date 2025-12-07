import Foundation

// MARK: - AI Health Insights

/// AI-generated health insights from Claude analysis
struct AIHealthInsights: Codable {
    let overallScore: Double
    let keyInsights: [String]
    let improvementOpportunities: [String]
    let recommendations: [AIRecommendation]
    let todaysOptimalPlan: String
    let culturalNotes: String?
    let confidenceScore: Double
    let analysisTimestamp: Date

    init(
        overallScore: Double,
        keyInsights: [String],
        improvementOpportunities: [String],
        recommendations: [AIRecommendation],
        todaysOptimalPlan: String,
        culturalNotes: String? = nil,
        confidenceScore: Double = 85.0
    ) {
        self.overallScore = overallScore
        self.keyInsights = keyInsights
        self.improvementOpportunities = improvementOpportunities
        self.recommendations = recommendations
        self.todaysOptimalPlan = todaysOptimalPlan
        self.culturalNotes = culturalNotes
        self.confidenceScore = confidenceScore
        self.analysisTimestamp = Date()
    }
}

/// AI-generated recommendation
struct AIRecommendation: Codable {
    let category: RecommendationCategory
    let title: String
    let description: String
    let priority: RecommendationPriority
    let actionableSteps: [String]
    let estimatedBenefit: String
}

/// Actionable recommendation combining AI and local insights
struct ActionableRecommendation: Codable {
    let category: RecommendationCategory
    let title: String
    let description: String
    let priority: RecommendationPriority
    let actionableSteps: [String]
    let estimatedBenefit: String
    let source: RecommendationSource
    let timestamp: Date

    init(
        category: RecommendationCategory,
        title: String,
        description: String,
        priority: RecommendationPriority,
        actionableSteps: [String],
        estimatedBenefit: String,
        source: RecommendationSource
    ) {
        self.category = category
        self.title = title
        self.description = description
        self.priority = priority
        self.actionableSteps = actionableSteps
        self.estimatedBenefit = estimatedBenefit
        self.source = source
        self.timestamp = Date()
    }
}

/// Recommendation categories
enum RecommendationCategory: String, CaseIterable, Codable {
    case nutrition = "nutrition"
    case exercise = "exercise"
    case lifestyle = "lifestyle"
    case mindfulness = "mindfulness"
    case sleep = "sleep"
    case recovery = "recovery"
    case stress = "stress"
}

/// Recommendation priority levels
enum RecommendationPriority: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"

    var numericValue: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

/// Source of recommendation
enum RecommendationSource: String, Codable {
    case aiGenerated = "ai_generated"
    case localAnalysis = "local_analysis"
    case environmental = "environmental"
    case userPreference = "user_preference"
}

// MARK: - Health Risk Assessment

/// Health risk factor identification
struct HealthRiskFactor: Codable {
    let category: RiskCategory
    let description: String
    let severity: RiskSeverity
    let recommendations: [String]
    let dataPoints: [String]
}

/// Risk categories
enum RiskCategory: String, CaseIterable, Codable {
    case cardiovascular = "cardiovascular"
    case metabolic = "metabolic"
    case sleep = "sleep"
    case activity = "activity"
    case stress = "stress"
    case nutrition = "nutrition"
}

/// Risk severity levels
enum RiskSeverity: String, CaseIterable, Codable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"

    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Health Trends

/// Health trend analysis
struct HealthTrend: Codable {
    let metric: String
    let direction: TrendDirection
    let magnitude: Double
    let timeframe: TrendTimeframe
    let significance: Double
    let description: String
}

// TrendDirection is defined in LocalHealthAnalyzerTypes.swift
// This avoids duplicate type definitions

/// Trend analysis timeframe
enum TrendTimeframe: String, CaseIterable, Codable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"

    var displayName: String {
        switch self {
        case .week: return "過去1週間"
        case .month: return "過去1ヶ月"
        case .quarter: return "過去3ヶ月"
        case .year: return "過去1年"
        }
    }
}

// MARK: - Health Alerts

/// Health alert for immediate attention
struct HealthAlert: Codable {
    let id: String
    let type: AlertType
    let title: String
    let description: String
    let severity: AlertSeverity
    let actionRequired: Bool
    let recommendations: [String]
    let timestamp: Date

    init(
        type: AlertType,
        title: String,
        description: String,
        severity: AlertSeverity,
        actionRequired: Bool = false,
        recommendations: [String] = []
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.title = title
        self.description = description
        self.severity = severity
        self.actionRequired = actionRequired
        self.recommendations = recommendations
        self.timestamp = Date()
    }
}

/// Alert types
enum AlertType: String, CaseIterable, Codable {
    case dataAnomaly = "data_anomaly"
    case trendAlert = "trend_alert"
    case goalMilestone = "goal_milestone"
    case healthTip = "health_tip"
    case environmental = "environmental"
    case motivational = "motivational"
}

/// Alert severity levels
enum AlertSeverity: String, CaseIterable, Codable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"

    var color: String {
        switch self {
        case .info: return "blue"
        case .warning: return "orange"
        case .critical: return "red"
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - User Profile

/// User profile for personalized analysis
struct UserProfile: Codable {
    let userId: String
    let age: Int?
    let gender: Gender?
    let healthGoals: [HealthGoal]
    let goals: [String]
    let activityLevel: ActivityLevel
    let healthInterests: [HealthInterest]
    let languagePreference: String
    let culturalContext: CulturalContext?
    let medicalConditions: [String]
    let preferences: UserPreferences
    let exerciseFrequency: String?
    let dietaryPreferences: [String]
    let exerciseHabits: [String]

    init(
        userId: String = UUID().uuidString,
        age: Int? = nil,
        gender: Gender? = nil,
        healthGoals: [HealthGoal] = [],
        goals: [String] = [],
        activityLevel: ActivityLevel = .none,
        healthInterests: [HealthInterest] = [],
        languagePreference: String = "japanese",
        culturalContext: CulturalContext? = nil,
        medicalConditions: [String] = [],
        preferences: UserPreferences = UserPreferences(),
        exerciseFrequency: String? = nil,
        dietaryPreferences: [String] = [],
        exerciseHabits: [String] = []
    ) {
        self.userId = userId
        self.age = age
        self.gender = gender
        self.healthGoals = healthGoals
        self.goals = goals
        self.activityLevel = activityLevel
        self.healthInterests = healthInterests
        self.languagePreference = languagePreference
        self.culturalContext = culturalContext
        self.medicalConditions = medicalConditions
        self.preferences = preferences
        self.exerciseFrequency = exerciseFrequency
        self.dietaryPreferences = dietaryPreferences
        self.exerciseHabits = exerciseHabits
    }
}

/// Gender options
enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
}

/// Cultural context for localized recommendations
struct CulturalContext: Codable {
    let country: String
    let region: String?
    let foodPreferences: [String]
    let activityPreferences: [String]
    let languageNuances: [String: String]
}

/// User preferences
struct UserPreferences: Codable {
    let notificationFrequency: NotificationFrequency
    let analysisDetailLevel: AnalysisDetailLevel
    let recommendationStyle: RecommendationStyle
    let privacyLevel: PrivacyLevel

    init(
        notificationFrequency: NotificationFrequency = .daily,
        analysisDetailLevel: AnalysisDetailLevel = .balanced,
        recommendationStyle: RecommendationStyle = .encouraging,
        privacyLevel: PrivacyLevel = .standard
    ) {
        self.notificationFrequency = notificationFrequency
        self.analysisDetailLevel = analysisDetailLevel
        self.recommendationStyle = recommendationStyle
        self.privacyLevel = privacyLevel
    }
}

/// Notification frequency preferences
enum NotificationFrequency: String, CaseIterable, Codable {
    case never = "never"
    case weekly = "weekly"
    case daily = "daily"
    case realtime = "realtime"
}

/// Analysis detail level preferences
enum AnalysisDetailLevel: String, CaseIterable, Codable {
    case minimal = "minimal"
    case balanced = "balanced"
    case detailed = "detailed"
    case comprehensive = "comprehensive"
}

/// Recommendation style preferences
enum RecommendationStyle: String, CaseIterable, Codable {
    case direct = "direct"
    case encouraging = "encouraging"
    case scientific = "scientific"
    case casual = "casual"
}

/// Privacy level preferences
enum PrivacyLevel: String, CaseIterable, Codable {
    case minimal = "minimal"
    case standard = "standard"
    case strict = "strict"
}

// MARK: - Extensions

extension RecommendationCategory {
    var icon: String {
        switch self {
        case .nutrition: return "fork.knife"
        case .exercise: return "figure.run"
        case .lifestyle: return "house"
        case .mindfulness: return "brain.head.profile"
        case .sleep: return "bed.double"
        case .recovery: return "heart.fill"
        case .stress: return "leaf"
        }
    }

    var displayName: String {
        switch self {
        case .nutrition: return "栄養"
        case .exercise: return "運動"
        case .lifestyle: return "ライフスタイル"
        case .mindfulness: return "メンタルケア"
        case .sleep: return "睡眠"
        case .recovery: return "回復"
        case .stress: return "ストレス"
        }
    }
}

extension RecommendationPriority {
    static func > (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        return lhs.numericValue > rhs.numericValue
    }
}
