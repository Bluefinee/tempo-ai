import Foundation
import SwiftUI

/// Four-tier health status classification based on comprehensive health metrics analysis.
///
/// This enum represents the user's current health condition derived from HealthKit data
/// including HRV, sleep quality, activity levels, and heart rate patterns. Each status
/// provides specific color coding and localized messaging for the user interface.
enum HealthStatus: String, CaseIterable, Codable {
    // swiftlint:disable redundant_string_enum_value
    case optimal = "optimal"  // 🟢 絶好調
    case good = "good"  // 🟡 良好
    case care = "care"  // 🟠 ケアモード
    case rest = "rest"  // 🔴 休息モード
    case unknown = "unknown"  // ⚪ 分析中
    // swiftlint:enable redundant_string_enum_value

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

// MARK: - Health Metrics

/// Individual health metric with score and category
struct HealthMetric: Codable, Identifiable {
    let id: UUID
    let category: MetricCategory
    let score: Double
    let value: String
    let trend: MetricTrend

    /// Normalized score value (0.0 to 1.0) for UI display
    var normalizedValue: Double {
        max(0.0, min(1.0, score))
    }

    init(category: MetricCategory, score: Double, value: String, trend: MetricTrend = .stable, id: UUID = UUID()) {
        self.id = id
        self.category = category
        self.score = score
        self.value = value
        self.trend = trend
    }
}

/// Categories of health metrics
enum MetricCategory: String, CaseIterable, Codable {
    case hrv = "hrv"
    case sleep = "sleep"
    case activity = "activity"
    case heartRate = "heartRate"

    var displayName: String {
        switch self {
        case .hrv: return NSLocalizedString("metric_hrv", comment: "HRV")
        case .sleep: return NSLocalizedString("metric_sleep", comment: "Sleep")
        case .activity: return NSLocalizedString("metric_activity", comment: "Activity")
        case .heartRate: return NSLocalizedString("metric_heart_rate", comment: "Heart Rate")
        }
    }

    var icon: String {
        switch self {
        case .hrv: return "heart.fill"
        case .sleep: return "moon.stars.fill"
        case .activity: return "figure.walk"
        case .heartRate: return "waveform.path.ecg"
        }
    }

    var color: Color {
        switch self {
        case .hrv: return .pink  // Heart rate variability - heart health indicator
        case .sleep: return .blue
        case .activity: return .green
        case .heartRate: return .orange
        }
    }
}

/// Trend direction for metrics
enum MetricTrend: String, CaseIterable, Codable {
    case improving
    case stable
    case declining

    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .gray
        case .declining: return .red
        }
    }
}

// MARK: - Health Analysis Result

/// Comprehensive health analysis result containing status and supporting metrics
struct HealthAnalysis: Codable {
    let status: HealthStatus
    let overallScore: Double
    let confidence: Double

    // Health metrics array
    let metrics: [HealthMetric]

    // Individual metric scores (for backward compatibility)
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
        metrics: [HealthMetric] = [],
        hrvScore: Double? = nil,
        sleepScore: Double? = nil,
        activityScore: Double? = nil,
        heartRateScore: Double? = nil,
        analysisDate: Date = Date(),
        dataQuality: DataQuality = DataQuality(completeness: 0.8, recency: 0.9, accuracy: 0.85, consistency: 0.8, overallScore: 0.84, recommendations: [])
    ) {
        self.status = status
        self.overallScore = overallScore
        self.confidence = confidence

        // If metrics array is empty, create from individual scores
        if metrics.isEmpty {
            var derivedMetrics: [HealthMetric] = []

            if let hrvScore = hrvScore {
                derivedMetrics.append(
                    HealthMetric(
                        category: .hrv,
                        score: hrvScore,
                        value:
                            "\(MetricValueConstants.hrvDisplayNote)\(String(format: "%.1f ms", hrvScore * MetricValueConstants.hrvMultiplier))"
                    ))
            }

            if let sleepScore = sleepScore {
                derivedMetrics.append(
                    HealthMetric(
                        category: .sleep,
                        score: sleepScore,
                        value:
                            "\(MetricValueConstants.sleepDisplayNote)\(String(format: "%.1f hrs", sleepScore * MetricValueConstants.sleepMultiplier))"
                    ))
            }

            if let activityScore = activityScore {
                derivedMetrics.append(
                    HealthMetric(
                        category: .activity,
                        score: activityScore,
                        value:
                            "\(MetricValueConstants.activityDisplayNote)\(String(format: "%.0f steps", activityScore * MetricValueConstants.activityMultiplier))"
                    ))
            }

            if let heartRateScore = heartRateScore {
                derivedMetrics.append(
                    HealthMetric(
                        category: .heartRate,
                        score: heartRateScore,
                        value:
                            "\(MetricValueConstants.heartRateDisplayNote)\(String(format: "%.0f bpm", MetricValueConstants.heartRateBase + heartRateScore * MetricValueConstants.heartRateRange))"
                    ))
            }

            self.metrics = derivedMetrics
        } else {
            self.metrics = metrics
        }

        self.hrvScore = hrvScore
        self.sleepScore = sleepScore
        self.activityScore = activityScore
        self.heartRateScore = heartRateScore
        self.analysisDate = analysisDate
        self.dataQuality = dataQuality
        self.recommendedActions = status.recommendedActions
    }
}

