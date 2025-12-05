import Combine
import Foundation

/// Service for tracking user interactions with health advice and collecting feedback
/// to improve AI recommendation quality over time
@MainActor
class AdviceTrackingService: ObservableObject {

    // MARK: - Published Properties

    @Published var currentAdviceSession: AdviceSession?
    @Published var feedbackHistory: [AdviceFeedback] = []

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard
    private let feedbackStorageKey = "advice_feedback_history"
    private let maxFeedbackHistory = 100

    // MARK: - Initialization

    init() {
        loadFeedbackHistory()
    }

    // MARK: - Advice Session Management

    /// Start tracking a new advice session
    func startAdviceSession(advice: DailyAdvice, healthAnalysis: HealthAnalysis?) {
        currentAdviceSession = AdviceSession(
            advice: advice,
            healthAnalysis: healthAnalysis,
            startTime: Date()
        )
    }

    /// Record that user followed specific advice
    func recordAdviceFollowed(_ adviceType: AdviceType, quality: AdviceQuality? = nil) {
        guard let session = currentAdviceSession else { return }

        var updatedSession = session
        updatedSession.followedAdvice.append(
            FollowedAdvice(
                type: adviceType,
                followedAt: Date(),
                quality: quality
            ))

        currentAdviceSession = updatedSession
    }

    /// Submit feedback for current advice session
    func submitFeedback(
        overallRating: Int,
        mostHelpful: [AdviceType],
        leastHelpful: [AdviceType],
        comments: String? = nil
    ) {
        guard let session = currentAdviceSession else { return }

        let feedback = AdviceFeedback(
            adviceId: session.advice.id,
            sessionId: session.id,
            overallRating: overallRating,
            mostHelpful: mostHelpful,
            leastHelpful: leastHelpful,
            comments: comments,
            healthStatus: session.healthAnalysis?.status,
            followedAdvice: session.followedAdvice,
            submittedAt: Date()
        )

        addFeedback(feedback)
        currentAdviceSession = nil
    }

    // MARK: - Feedback Analytics

    /// Get user feedback analytics for API context
    func getFeedbackInsights() -> FeedbackInsights? {
        guard !feedbackHistory.isEmpty else { return nil }

        let recentFeedback = getRecentFeedback(days: 30)

        // Calculate average rating
        let averageRating = recentFeedback.map { Double($0.overallRating) }.reduce(0, +) / Double(recentFeedback.count)

        // Find most helpful advice types
        let helpfulAdvice = Dictionary(grouping: recentFeedback.flatMap { $0.mostHelpful }) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        // Find least helpful advice types
        let unhelpfulAdvice = Dictionary(grouping: recentFeedback.flatMap { $0.leastHelpful }) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        // Calculate follow-through rate
        let totalAdvice = recentFeedback.flatMap { $0.followedAdvice }
        let followThroughRate =
            totalAdvice.isEmpty
            ? 0.0 : Double(totalAdvice.filter { $0.quality != .poor }.count) / Double(totalAdvice.count)

        return FeedbackInsights(
            averageRating: averageRating,
            mostHelpfulAdvice: Array(helpfulAdvice),
            leastHelpfulAdvice: Array(unhelpfulAdvice),
            followThroughRate: followThroughRate,
            totalFeedbackCount: recentFeedback.count
        )
    }

    /// Check if user has been following advice consistently
    func hasConsistentFollowThrough() -> Bool {
        let insights = getFeedbackInsights()
        return (insights?.followThroughRate ?? 0.0) > 0.7
    }

    /// Get personalized preferences based on feedback history
    func getUserPreferences() -> UserAdvicePreferences {
        let insights = getFeedbackInsights()

        return UserAdvicePreferences(
            preferredAdviceTypes: insights?.mostHelpfulAdvice ?? [],
            avoidAdviceTypes: insights?.leastHelpfulAdvice ?? [],
            communicationStyle: derivePreferredCommunicationStyle(),
            detailLevel: derivePreferredDetailLevel()
        )
    }

    // MARK: - Private Methods

    private func addFeedback(_ feedback: AdviceFeedback) {
        feedbackHistory.append(feedback)

        // Limit history size
        if feedbackHistory.count > maxFeedbackHistory {
            feedbackHistory.removeFirst(feedbackHistory.count - maxFeedbackHistory)
        }

        saveFeedbackHistory()
    }

    private func getRecentFeedback(days: Int) -> [AdviceFeedback] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return feedbackHistory.filter { $0.submittedAt >= cutoffDate }
    }

    private func derivePreferredCommunicationStyle() -> CommunicationStyle {
        let recentComments = getRecentFeedback(days: 30)
            .compactMap { $0.comments }
            .joined(separator: " ")
            .lowercased()

        if recentComments.contains("simple") || recentComments.contains("brief") {
            return .concise
        } else if recentComments.contains("detailed") || recentComments.contains("explain") {
            return .detailed
        } else {
            return .balanced
        }
    }

    private func derivePreferredDetailLevel() -> DetailLevel {
        let insights = getFeedbackInsights()
        let averageRating = insights?.averageRating ?? 3.0

        if averageRating >= 4.0 {
            return .standard
        } else {
            return .detailed
        }
    }

    private func saveFeedbackHistory() {
        if let data = try? JSONEncoder().encode(feedbackHistory) {
            userDefaults.set(data, forKey: feedbackStorageKey)
        }
    }

    private func loadFeedbackHistory() {
        guard let data = userDefaults.data(forKey: feedbackStorageKey),
            let history = try? JSONDecoder().decode([AdviceFeedback].self, from: data)
        else {
            return
        }
        feedbackHistory = history
    }
}

// MARK: - Supporting Models

struct AdviceSession: Identifiable {
    let id = UUID()
    let advice: DailyAdvice
    let healthAnalysis: HealthAnalysis?
    let startTime: Date
    var followedAdvice: [FollowedAdvice] = []
}

struct FollowedAdvice: Codable {
    let type: AdviceType
    let followedAt: Date
    let quality: AdviceQuality?
}

struct AdviceFeedback: Codable, Identifiable {
    let id = UUID()
    let adviceId: UUID
    let sessionId: UUID
    let overallRating: Int  // 1-5 scale
    let mostHelpful: [AdviceType]
    let leastHelpful: [AdviceType]
    let comments: String?
    let healthStatus: HealthStatus?
    let followedAdvice: [FollowedAdvice]
    let submittedAt: Date
}

struct FeedbackInsights: Codable {
    let averageRating: Double
    let mostHelpfulAdvice: [AdviceType]
    let leastHelpfulAdvice: [AdviceType]
    let followThroughRate: Double
    let totalFeedbackCount: Int
}

struct UserAdvicePreferences: Codable {
    let preferredAdviceTypes: [AdviceType]
    let avoidAdviceTypes: [AdviceType]
    let communicationStyle: CommunicationStyle
    let detailLevel: DetailLevel
}

enum AdviceType: String, CaseIterable, Codable {
    case breakfast
    case lunch
    case dinner
    case exercise
    case hydration
    case breathing
    case sleepPreparation = "sleep_preparation"
    case weather
    case priorityActions = "priority_actions"
}

enum AdviceQuality: String, CaseIterable, Codable {
    case excellent
    case good
    case fair
    case poor
}

enum CommunicationStyle: String, CaseIterable, Codable {
    case concise
    case balanced
    case detailed
}

enum DetailLevel: String, CaseIterable, Codable {
    case minimal
    case standard
    case detailed
}
