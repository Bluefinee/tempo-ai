import Foundation
import SwiftUI

/// Four-tier health status classification based on comprehensive health metrics analysis.
///
/// This enum represents the user's current health condition derived from HealthKit data
/// including HRV, sleep quality, activity levels, and heart rate patterns. Each status
/// provides specific color coding and localized messaging for the user interface.
enum HealthStatus: String, CaseIterable, Codable {
    case optimal = "optimal"  // 🟢 絶好調
    case good = "good"  // 🟡 良好
    case care = "care"  // 🟠 ケアモード
    case rest = "rest"  // 🔴 休息モード
    case unknown = "unknown"  // ⚪ 分析中

    /// Primary color associated with this health status
    var color: Color {
        switch self {
        case .optimal:
            return .green
        case .good:
            return .yellow
        case .care:
            return .orange
        case .rest:
            return .red
        case .unknown:
            return .gray
        }
    }

    /// Secondary color for subtle UI elements
    var secondaryColor: Color {
        color.opacity(0.3)
    }

    /// Background color for cards and containers
    var backgroundColor: Color {
        color.opacity(0.1)
    }

    /// Emoji representation for quick visual identification
    var emoji: String {
        switch self {
        case .optimal:
            return "🟢"
        case .good:
            return "🟡"
        case .care:
            return "🟠"
        case .rest:
            return "🔴"
        case .unknown:
            return "⚪"
        }
    }

    /// SF Symbol icon for UI elements
    var icon: String {
        switch self {
        case .optimal:
            return "checkmark.circle.fill"
        case .good:
            return "checkmark.circle"
        case .care:
            return "exclamationmark.circle.fill"
        case .rest:
            return "pause.circle.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }

    /// Localized title for display in UI
    var localizedTitle: String {
        NSLocalizedString("health_status_\(rawValue)_title", comment: "Health status title")
    }

    /// Localized description explaining the health status
    var localizedDescription: String {
        NSLocalizedString("health_status_\(rawValue)_description", comment: "Health status description")
    }

    /// Detailed explanation of what this status means
    var localizedExplanation: String {
        NSLocalizedString("health_status_\(rawValue)_explanation", comment: "Health status explanation")
    }

    /// Recommended actions for this health status
    var recommendedActions: [String] {
        let key = "health_status_\(rawValue)_actions"
        let actionsString = NSLocalizedString(key, comment: "Recommended actions")
        return actionsString.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Numeric score representation (0.0 to 1.0)
    var score: Double {
        switch self {
        case .optimal:
            return 1.0
        case .good:
            return 0.75
        case .care:
            return 0.5
        case .rest:
            return 0.25
        case .unknown:
            return 0.0
        }
    }

    /// Priority level for notifications and alerts
    var priority: AlertPriority {
        switch self {
        case .optimal:
            return .low
        case .good:
            return .low
        case .care:
            return .medium
        case .rest:
            return .high
        case .unknown:
            return .none
        }
    }
}

// MARK: - HealthStatus Creation

extension HealthStatus {

    /// Create health status from overall health score (0.0 to 1.0)
    static func from(overallScore: Double) -> HealthStatus {
        switch overallScore {
        case 0.8 ... 1.0:
            return .optimal
        case 0.6 ..< 0.8:
            return .good
        case 0.4 ..< 0.6:
            return .care
        case 0.1 ..< 0.4:
            return .rest
        default:
            return .unknown
        }
    }

    /// Create health status from individual metric scores
    static func from(
        hrvScore: Double,
        sleepScore: Double,
        activityScore: Double,
        heartRateScore: Double
    ) -> HealthStatus {
        let weights: [Double] = [0.3, 0.4, 0.2, 0.1]  // HRV, Sleep, Activity, HR weights
        let scores = [hrvScore, sleepScore, activityScore, heartRateScore]

        let weightedSum = zip(scores, weights).map { $0 * $1 }.reduce(0, +)
        let weightSum = weights.reduce(0, +)
        let averageScore = weightedSum / weightSum

        return from(overallScore: averageScore)
    }
}

// MARK: - Supporting Types

/// Priority level for health status alerts and notifications
enum AlertPriority: Int, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var localizedTitle: String {
        NSLocalizedString("alert_priority_\(self)", comment: "Alert priority level")
    }
}

// MARK: - Health Analysis Result

/// Comprehensive health analysis result containing status and supporting metrics
struct HealthAnalysis: Codable {
    let status: HealthStatus
    let overallScore: Double
    let confidence: Double

    // Individual metric scores
    let hrvScore: Double?
    let sleepScore: Double?
    let activityScore: Double?
    let heartRateScore: Double?

    // Timestamp and metadata
    let analysisDate: Date
    let dataQuality: DataQuality
    let recommendedActions: [String]

    init(
        status: HealthStatus,
        overallScore: Double,
        confidence: Double = 1.0,
        hrvScore: Double? = nil,
        sleepScore: Double? = nil,
        activityScore: Double? = nil,
        heartRateScore: Double? = nil,
        analysisDate: Date = Date(),
        dataQuality: DataQuality = .good
    ) {
        self.status = status
        self.overallScore = overallScore
        self.confidence = confidence
        self.hrvScore = hrvScore
        self.sleepScore = sleepScore
        self.activityScore = activityScore
        self.heartRateScore = heartRateScore
        self.analysisDate = analysisDate
        self.dataQuality = dataQuality
        self.recommendedActions = status.recommendedActions
    }
}

/// Data quality indicator for health analysis
enum DataQuality: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"

    var score: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.8
        case .fair: return 0.6
        case .poor: return 0.4
        }
    }

    var localizedTitle: String {
        NSLocalizedString("data_quality_\(rawValue)", comment: "Data quality level")
    }
}
