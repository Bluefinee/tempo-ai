import Foundation

// MARK: - Smart Notification Types

/// Type of smart notification
enum NotificationType: String, CaseIterable, Codable {
    case healthInsights = "healthInsights"
    case dataReminder = "dataReminder"
    case wellnessTip = "wellnessTip"
    case goalAchievement = "goalAchievement"
    case systemAlert = "systemAlert"

    var displayName: String {
        switch self {
        case .healthInsights:
            return "健康分析"
        case .dataReminder:
            return "データ更新"
        case .wellnessTip:
            return "ウェルネスのヒント"
        case .goalAchievement:
            return "目標達成"
        case .systemAlert:
            return "システム通知"
        }
    }

    var iconName: String {
        switch self {
        case .healthInsights:
            return "chart.line.uptrend.xyaxis"
        case .dataReminder:
            return "arrow.clockwise"
        case .wellnessTip:
            return "lightbulb"
        case .goalAchievement:
            return "trophy"
        case .systemAlert:
            return "exclamationmark.triangle"
        }
    }
}

/// Priority level for notifications
enum NotificationPriority: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"

    var interruptionLevel: String {
        switch self {
        case .low:
            return "passive"
        case .normal:
            return "active"
        case .high:
            return "timeSensitive"
        case .urgent:
            return "critical"
        }
    }
}

/// Smart notification delivery scheduling
enum NotificationDelivery: Codable, Equatable {
    case immediate
    case relative(timeInterval: TimeInterval)
    case absolute(date: Date)
    case optimal  // Let the system determine optimal time

    var targetDate: Date? {
        switch self {
        case .immediate:
            return Date()
        case .relative(let timeInterval):
            return Date().addingTimeInterval(timeInterval)
        case .absolute(let date):
            return date
        case .optimal:
            return nil  // Determined by delivery optimizer
        }
    }
}

/// Notification action button
struct NotificationAction: Codable {
    let id: String
    let title: String
    let isDestructive: Bool

    enum ActionType: String, Codable {
        case sent = "sent"
        case delivered = "delivered"
        case opened = "opened"
        case dismissed = "dismissed"
        case actionTaken = "actionTaken"
    }
}

/// Smart notification structure
struct SmartNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType
    let priority: NotificationPriority
    let title: String
    let body: String
    let categoryIdentifier: String
    let scheduledDelivery: NotificationDelivery
    let actionButtons: [NotificationAction]
    let userInfo: [String: Any]
    let soundName: String?
    let badgeCount: Int?
    let expirationDate: Date?

    init(
        id: String,
        type: NotificationType,
        priority: NotificationPriority = .normal,
        title: String,
        body: String,
        categoryIdentifier: String,
        scheduledDelivery: NotificationDelivery = .immediate,
        actionButtons: [NotificationAction] = [],
        userInfo: [String: Any] = [:],
        soundName: String? = nil,
        badgeCount: Int? = nil,
        expirationDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.priority = priority
        self.title = title
        self.body = body
        self.categoryIdentifier = categoryIdentifier
        self.scheduledDelivery = scheduledDelivery
        self.actionButtons = actionButtons
        self.userInfo = userInfo
        self.soundName = soundName
        self.badgeCount = badgeCount
        self.expirationDate = expirationDate
    }

    // Custom Codable implementation to handle userInfo
    enum CodingKeys: String, CodingKey {
        case id, type, priority, title, body, categoryIdentifier
        case scheduledDelivery, actionButtons, soundName, badgeCount, expirationDate
        case userInfoData = "userInfo"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(NotificationType.self, forKey: .type)
        priority = try container.decode(NotificationPriority.self, forKey: .priority)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        categoryIdentifier = try container.decode(String.self, forKey: .categoryIdentifier)
        scheduledDelivery = try container.decode(NotificationDelivery.self, forKey: .scheduledDelivery)
        actionButtons = try container.decode([NotificationAction].self, forKey: .actionButtons)
        soundName = try container.decodeIfPresent(String.self, forKey: .soundName)
        badgeCount = try container.decodeIfPresent(Int.self, forKey: .badgeCount)
        expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)

        if let data = try container.decodeIfPresent(Data.self, forKey: .userInfoData),
            let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        {
            userInfo = decoded
        } else {
            userInfo = [:]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(priority, forKey: .priority)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(categoryIdentifier, forKey: .categoryIdentifier)
        try container.encode(scheduledDelivery, forKey: .scheduledDelivery)
        try container.encode(actionButtons, forKey: .actionButtons)
        try container.encodeIfPresent(soundName, forKey: .soundName)
        try container.encodeIfPresent(badgeCount, forKey: .badgeCount)
        try container.encodeIfPresent(expirationDate, forKey: .expirationDate)

        if let data = try? JSONSerialization.data(withJSONObject: userInfo) {
            try container.encode(data, forKey: .userInfoData)
        }
    }
}

/// Notification event for analytics
struct NotificationEvent: Codable {
    let id: String
    let type: NotificationType
    let sentDate: Date
    let scheduledDate: Date
    var deliveredDate: Date?
    var respondedDate: Date?
    var action: NotificationAction.ActionType

    var deliveryDelay: TimeInterval? {
        guard let deliveredDate = deliveredDate else { return nil }
        return deliveredDate.timeIntervalSince(sentDate)
    }

    var responseTime: TimeInterval? {
        guard let respondedDate = respondedDate,
            let deliveredDate = deliveredDate
        else { return nil }
        return respondedDate.timeIntervalSince(deliveredDate)
    }
}

/// User notification preferences
struct NotificationPreferences: Codable {
    let language: AppLanguage
    let healthInsightsEnabled: Bool
    let dataRemindersEnabled: Bool
    let wellnessTipsEnabled: Bool
    let achievementsEnabled: Bool

    // Timing preferences
    let quietHoursStart: TimeOfDay
    let quietHoursEnd: TimeOfDay
    let preferredDeliveryWindow: DeliveryWindow

    // Frequency controls
    let maxDailyNotifications: Int
    let minTimeBetweenNotifications: TimeInterval  // In seconds

    static let `default` = NotificationPreferences(
        language: .japanese,
        healthInsightsEnabled: true,
        dataRemindersEnabled: true,
        wellnessTipsEnabled: true,
        achievementsEnabled: true,
        quietHoursStart: TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 8, minute: 0),
        preferredDeliveryWindow: .flexible,
        maxDailyNotifications: 5,
        minTimeBetweenNotifications: 1800  // 30 minutes
    )
}

/// Time of day representation
struct TimeOfDay: Codable, Equatable {
    let hour: Int  // 0-23
    let minute: Int  // 0-59

    var date: Date {
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date()
    }

    func isWithinQuietHours(start: TimeOfDay, end: TimeOfDay) -> Bool {
        let currentMinutes = hour * 60 + minute
        let startMinutes = start.hour * 60 + start.minute
        let endMinutes = end.hour * 60 + end.minute

        if startMinutes <= endMinutes {
            // Same day range
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            // Overnight range
            return currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
    }
}

/// Delivery time window preferences
enum DeliveryWindow: String, CaseIterable, Codable {
    case morning = "morning"  // 6-11 AM
    case afternoon = "afternoon"  // 12-17 PM
    case evening = "evening"  // 18-21 PM
    case flexible = "flexible"  // Any time outside quiet hours

    var timeRange: (start: TimeOfDay, end: TimeOfDay) {
        switch self {
        case .morning:
            return (TimeOfDay(hour: 6, minute: 0), TimeOfDay(hour: 11, minute: 59))
        case .afternoon:
            return (TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 17, minute: 59))
        case .evening:
            return (TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 21, minute: 59))
        case .flexible:
            return (TimeOfDay(hour: 0, minute: 0), TimeOfDay(hour: 23, minute: 59))
        }
    }

    var displayName: String {
        switch self {
        case .morning:
            return "朝 (6:00-12:00)"
        case .afternoon:
            return "午後 (12:00-18:00)"
        case .evening:
            return "夜 (18:00-22:00)"
        case .flexible:
            return "いつでも"
        }
    }
}

/// Notification analytics data
struct NotificationAnalytics: Codable {
    let totalSent: Int
    let totalOpened: Int
    let totalDismissed: Int
    let engagementRate: Double
    let averageDeliveryTime: TimeInterval
    let mostEngagingTypes: [NotificationType]

    var engagementRatePercentage: String {
        String(format: "%.1f%%", engagementRate * 100)
    }

    var averageDeliveryTimeFormatted: String {
        let minutes = Int(averageDeliveryTime / 60)
        return "\(minutes)分"
    }
}

/// Wellness tip structure
struct WellnessTip: Codable, Identifiable {
    let id: String
    let category: WellnessTipCategory
    let title: String
    let shortDescription: String
    let detailedContent: String
    let actionItems: [String]
    let relevanceScore: Double
    let language: AppLanguage

    static func welcomeTip(for language: AppLanguage) -> WellnessTip {
        let isJapanese = language == .japanese

        return WellnessTip(
            id: "welcome_tip",
            category: .general,
            title: isJapanese ? "TempoAIへようこそ" : "Welcome to TempoAI",
            shortDescription: isJapanese
                ? "あなたの健康的な生活をサポートする準備ができました。" : "We're ready to support your healthy lifestyle.",
            detailedContent: isJapanese
                ? "TempoAIは、あなたの健康データを分析し、パーソナライズされたアドバイスを提供します。定期的なデータ更新により、より正確な分析が可能になります。"
                : "TempoAI analyzes your health data and provides personalized advice. Regular data updates enable more accurate analysis.",
            actionItems: isJapanese
                ? ["健康データを同期する", "初回分析を実行する", "通知設定を確認する"]
                : ["Sync your health data", "Run initial analysis", "Check notification settings"],
            relevanceScore: 1.0,
            language: language
        )
    }
}

/// Wellness tip categories
enum WellnessTipCategory: String, CaseIterable, Codable {
    case general = "general"
    case exercise = "exercise"
    case nutrition = "nutrition"
    case sleep = "sleep"
    case stress = "stress"
    case prevention = "prevention"

    var displayName: String {
        switch self {
        case .general:
            return "一般"
        case .exercise:
            return "運動"
        case .nutrition:
            return "栄養"
        case .sleep:
            return "睡眠"
        case .stress:
            return "ストレス"
        case .prevention:
            return "予防"
        }
    }
}

/// Detailed health goal with progress tracking
struct DetailedHealthGoal: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let targetValue: Double
    let currentValue: Double
    let unit: String
    let deadline: Date?
    let category: HealthGoalCategory

    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    var isCompleted: Bool {
        return currentValue >= targetValue
    }
}

/// Health goal categories
enum HealthGoalCategory: String, CaseIterable, Codable {
    case steps = "steps"
    case weight = "weight"
    case exercise = "exercise"
    case sleep = "sleep"
    case heartRate = "heartRate"
    case nutrition = "nutrition"

    var displayName: String {
        switch self {
        case .steps:
            return "歩数"
        case .weight:
            return "体重"
        case .exercise:
            return "運動"
        case .sleep:
            return "睡眠"
        case .heartRate:
            return "心拍数"
        case .nutrition:
            return "栄養"
        }
    }
}

/// Goal achievement structure
struct GoalAchievement: Codable, Identifiable {
    let id: String
    let goalId: String
    let type: AchievementType
    let achievedDate: Date
    let celebrationMessage: String
    let badgeImageName: String?

    enum AchievementType: String, CaseIterable, Codable {
        case goalCompleted = "goalCompleted"
        case milestone = "milestone"
        case streak = "streak"
        case personalBest = "personalBest"

        var displayName: String {
            switch self {
            case .goalCompleted:
                return "目標達成"
            case .milestone:
                return "マイルストーン"
            case .streak:
                return "継続記録"
            case .personalBest:
                return "自己ベスト"
            }
        }
    }
}
