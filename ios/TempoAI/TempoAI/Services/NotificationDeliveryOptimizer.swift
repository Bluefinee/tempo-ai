import Foundation

// MARK: - Notification Delivery Optimizer

/// Optimizes notification delivery timing based on user behavior patterns and context
/// Uses machine learning-like algorithms to predict optimal delivery times
@MainActor
class NotificationDeliveryOptimizer: ObservableObject {

    // MARK: - Private Properties

    private var deliveryHistory: [DeliveryOutcome] = []
    private var userEngagementPatterns: [EngagementPattern] = []
    private let maxHistoryEntries = 500

    // MARK: - Initialization

    init() {
        loadDeliveryHistory()
        analyzeEngagementPatterns()
    }

    // MARK: - Public Interface

    /// Optimize notification delivery based on user context and preferences
    func optimize(
        notification: SmartNotification,
        userPreferences: NotificationPreferences,
        currentContext: NotificationContext
    ) async -> SmartNotification {

        // If notification is urgent, deliver immediately
        if notification.priority == .urgent {
            return notification
        }

        // Check if current time is within quiet hours
        if isInQuietHours(context: currentContext, preferences: userPreferences) {
            let optimizedNotification = await scheduleAfterQuietHours(
                notification: notification,
                preferences: userPreferences
            )
            return optimizedNotification
        }

        // Optimize based on engagement patterns
        let optimalDelivery = await calculateOptimalDeliveryTime(
            for: notification,
            userPreferences: userPreferences,
            context: currentContext
        )

        var optimizedNotification = notification
        optimizedNotification = SmartNotification(
            id: notification.id,
            type: notification.type,
            priority: notification.priority,
            title: notification.title,
            body: notification.body,
            categoryIdentifier: notification.categoryIdentifier,
            scheduledDelivery: .absolute(date: optimalDelivery),
            actionButtons: notification.actionButtons,
            userInfo: notification.userInfo,
            soundName: notification.soundName,
            badgeCount: notification.badgeCount,
            expirationDate: notification.expirationDate
        )

        return optimizedNotification
    }

    /// Calculate optimal delivery time based on historical patterns and current context
    func calculateOptimalDeliveryTime(
        for notification: SmartNotification,
        userPreferences: NotificationPreferences,
        context: NotificationContext? = nil
    ) async -> Date {

        let currentDate = Date()
        let calendar = Calendar.current

        // Get user's preferred delivery window
        let preferredWindow = userPreferences.preferredDeliveryWindow.timeRange

        // Find the next optimal time slot within the preferred window
        if let optimalTime = await findOptimalTimeSlot(
            for: notification.type,
            preferences: userPreferences,
            startingFrom: currentDate
        ) {
            return optimalTime
        }

        // Fallback to next available time in preferred window
        return findNextAvailableTimeInWindow(
            preferredWindow,
            startingFrom: currentDate,
            preferences: userPreferences
        )
    }

    /// Record delivery outcome for learning
    func recordDeliveryOutcome(_ params: DeliveryOutcomeParams) {
        let outcome = DeliveryOutcome(
            notificationId: params.notificationId,
            notificationType: params.notificationType,
            scheduledTime: params.scheduledTime,
            deliveredTime: params.deliveredTime,
            userResponse: params.userResponse,
            context: params.context,
            engagementScore: calculateEngagementScore(response: params.userResponse)
        )

        deliveryHistory.append(outcome)

        // Maintain history size
        if deliveryHistory.count > maxHistoryEntries {
            deliveryHistory.removeFirst()
        }

        saveDeliveryHistory()
        analyzeEngagementPatterns()

        print("📊 DeliveryOptimizer: Recorded outcome for \(notificationId) - Engagement: \(outcome.engagementScore)")
    }

    /// Get delivery insights for analytics
    func getDeliveryInsights() -> DeliveryInsights {
        let totalDeliveries = deliveryHistory.count

        guard totalDeliveries > 0 else {
            return DeliveryInsights.empty
        }

        let averageEngagement = deliveryHistory.map { $0.engagementScore }.reduce(0, +) / Double(totalDeliveries)

        let optimalTimeSlots = findOptimalTimeSlots()
        let typePerformance = analyzeTypePerformance()

        return DeliveryInsights(
            totalDeliveries: totalDeliveries,
            averageEngagementScore: averageEngagement,
            optimalTimeSlots: optimalTimeSlots,
            typePerformance: typePerformance,
            lastUpdated: Date()
        )
    }

    // MARK: - Private Implementation

    private func isInQuietHours(context: NotificationContext, preferences: NotificationPreferences) -> Bool {
        let currentTime = context.timeOfDay
        return currentTime.isWithinQuietHours(
            start: preferences.quietHoursStart,
            end: preferences.quietHoursEnd
        )
    }

    private func scheduleAfterQuietHours(
        notification: SmartNotification,
        preferences: NotificationPreferences
    ) async -> SmartNotification {
        let calendar = Calendar.current
        let now = Date()

        // Find next time after quiet hours end
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = preferences.quietHoursEnd.hour
        components.minute = preferences.quietHoursEnd.minute

        var targetDate = calendar.date(from: components) ?? now

        // If quiet hours end time is earlier in the day, schedule for tomorrow
        if targetDate <= now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? now
        }

        // Add a small buffer to ensure we're definitely out of quiet hours
        targetDate = targetDate.addingTimeInterval(300)  // 5 minutes

        var optimizedNotification = notification
        optimizedNotification = SmartNotification(
            id: notification.id,
            type: notification.type,
            priority: notification.priority,
            title: notification.title,
            body: notification.body,
            categoryIdentifier: notification.categoryIdentifier,
            scheduledDelivery: .absolute(date: targetDate),
            actionButtons: notification.actionButtons,
            userInfo: notification.userInfo,
            soundName: notification.soundName,
            badgeCount: notification.badgeCount,
            expirationDate: notification.expirationDate
        )

        return optimizedNotification
    }

    private func findOptimalTimeSlot(
        for type: NotificationType,
        preferences: NotificationPreferences,
        startingFrom startDate: Date
    ) async -> Date? {

        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: startDate)
        let currentMinute = calendar.component(.minute, from: startDate)

        // Find engagement patterns for this notification type
        let typePatterns = userEngagementPatterns.filter { $0.notificationType == type }

        // If we have enough historical data, use it
        if typePatterns.count >= 3 {
            let sortedPatterns = typePatterns.sorted { $0.averageEngagement > $1.averageEngagement }

            // Find the best time slot that's in the future and within preferred window
            for pattern in sortedPatterns {
                let patternTime = TimeOfDay(hour: pattern.hour, minute: 0)

                // Check if this time is within preferred delivery window
                if isTimeWithinWindow(patternTime, window: preferences.preferredDeliveryWindow) {
                    // Create target date for today or tomorrow
                    var components = calendar.dateComponents([.year, .month, .day], from: startDate)
                    components.hour = pattern.hour
                    components.minute = max(currentMinute + 5, 0)  // At least 5 minutes from now

                    if let targetDate = calendar.date(from: components) {
                        // If time has passed today, schedule for tomorrow
                        if targetDate <= startDate {
                            if let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: targetDate) {
                                return tomorrowDate
                            }
                        } else {
                            return targetDate
                        }
                    }
                }
            }
        }

        return nil
    }

    private func findNextAvailableTimeInWindow(
        _ window: (start: TimeOfDay, end: TimeOfDay),
        startingFrom startDate: Date,
        preferences: NotificationPreferences
    ) -> Date {

        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: startDate)

        // If we're currently in the window, schedule for a bit later
        if currentHour >= window.start.hour && currentHour <= window.end.hour {
            return startDate.addingTimeInterval(preferences.minTimeBetweenNotifications)
        }

        // Schedule for the start of the next window
        var components = calendar.dateComponents([.year, .month, .day], from: startDate)
        components.hour = window.start.hour
        components.minute = window.start.minute

        var targetDate = calendar.date(from: components) ?? startDate

        // If window start time has passed today, schedule for tomorrow
        if targetDate <= startDate {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? startDate
        }

        return targetDate
    }

    private func isTimeWithinWindow(_ time: TimeOfDay, window: DeliveryWindow) -> Bool {
        let windowRange = window.timeRange

        let timeMinutes = time.hour * 60 + time.minute
        let startMinutes = windowRange.start.hour * 60 + windowRange.start.minute
        let endMinutes = windowRange.end.hour * 60 + windowRange.end.minute

        return timeMinutes >= startMinutes && timeMinutes <= endMinutes
    }

    private func calculateEngagementScore(response: DeliveryResponse) -> Double {
        switch response {
        case .opened:
            return 1.0
        case .dismissed:
            return 0.2
        case .actionTaken:
            return 1.2
        case .ignored:
            return 0.0
        case .snoozed:
            return 0.6
        }
    }

    private func analyzeEngagementPatterns() {
        let groupedByTypeAndHour = Dictionary(grouping: deliveryHistory) { outcome in
            EngagementPatternKey(
                type: outcome.notificationType,
                hour: Calendar.current.component(.hour, from: outcome.deliveredTime)
            )
        }

        userEngagementPatterns = groupedByTypeAndHour.compactMap { key, outcomes in
            guard outcomes.count >= 2 else { return nil }  // Need at least 2 data points

            let averageEngagement = outcomes.map { $0.engagementScore }.reduce(0, +) / Double(outcomes.count)
            let totalDeliveries = outcomes.count

            return EngagementPattern(
                notificationType: key.type,
                hour: key.hour,
                averageEngagement: averageEngagement,
                deliveryCount: totalDeliveries
            )
        }

        print("📊 DeliveryOptimizer: Analyzed \(userEngagementPatterns.count) engagement patterns")
    }

    private func findOptimalTimeSlots() -> [OptimalTimeSlot] {
        let hourlyEngagement = Dictionary(grouping: deliveryHistory) { outcome in
            Calendar.current.component(.hour, from: outcome.deliveredTime)
        }.mapValues { outcomes in
            outcomes.map { $0.engagementScore }.reduce(0, +) / Double(outcomes.count)
        }

        return
            hourlyEngagement
            .filter { $0.value > 0.5 }  // Only include hours with decent engagement
            .sorted { $0.value > $1.value }
            .prefix(5)  // Top 5 hours
            .map { hour, engagement in
                OptimalTimeSlot(hour: hour, engagementScore: engagement)
            }
    }

    private func analyzeTypePerformance() -> [TypePerformance] {
        let typeGroups = Dictionary(grouping: deliveryHistory) { $0.notificationType }

        return typeGroups.map { type, outcomes in
            let averageEngagement = outcomes.map { $0.engagementScore }.reduce(0, +) / Double(outcomes.count)
            let deliveryCount = outcomes.count

            return TypePerformance(
                type: type,
                averageEngagement: averageEngagement,
                deliveryCount: deliveryCount
            )
        }.sorted { $0.averageEngagement > $1.averageEngagement }
    }

    private func loadDeliveryHistory() {
        if let data = UserDefaults.standard.data(forKey: "NotificationDeliveryHistory"),
            let history = try? JSONDecoder().decode([DeliveryOutcome].self, from: data)
        {
            deliveryHistory = history
            print("📊 DeliveryOptimizer: Loaded \(deliveryHistory.count) historical delivery outcomes")
        }
    }

    private func saveDeliveryHistory() {
        if let data = try? JSONEncoder().encode(deliveryHistory) {
            UserDefaults.standard.set(data, forKey: "NotificationDeliveryHistory")
        }
    }
}

// MARK: - Supporting Types

/// Parameters for recording delivery outcome
struct DeliveryOutcomeParams {
    let notificationId: String
    let notificationType: NotificationType
    let scheduledTime: Date
    let deliveredTime: Date
    let userResponse: DeliveryResponse
    let context: NotificationContext
}

/// Delivery outcome for machine learning
struct DeliveryOutcome: Codable {
    let notificationId: String
    let notificationType: NotificationType
    let scheduledTime: Date
    let deliveredTime: Date
    let userResponse: DeliveryResponse
    let context: NotificationContext
    let engagementScore: Double
}

/// User response to notification delivery
enum DeliveryResponse: String, CaseIterable, Codable {
    case opened
    case dismissed
    case actionTaken
    case ignored
    case snoozed
}

/// Engagement pattern for specific notification type and time
struct EngagementPattern: Codable {
    let notificationType: NotificationType
    let hour: Int
    let averageEngagement: Double
    let deliveryCount: Int
}

/// Key for grouping engagement patterns
private struct EngagementPatternKey: Hashable {
    let type: NotificationType
    let hour: Int
}

/// Optimal time slot for notifications
struct OptimalTimeSlot: Codable {
    let hour: Int
    let engagementScore: Double

    var timeRange: String {
        let startTime = String(format: "%02d:00", hour)
        let endTime = String(format: "%02d:59", hour)
        return "\(startTime) - \(endTime)"
    }
}

/// Performance metrics for notification types
struct TypePerformance: Codable {
    let type: NotificationType
    let averageEngagement: Double
    let deliveryCount: Int

    var engagementPercentage: String {
        String(format: "%.1f%%", averageEngagement * 100)
    }
}

/// Comprehensive delivery insights
struct DeliveryInsights: Codable {
    let totalDeliveries: Int
    let averageEngagementScore: Double
    let optimalTimeSlots: [OptimalTimeSlot]
    let typePerformance: [TypePerformance]
    let lastUpdated: Date

    static let empty = DeliveryInsights(
        totalDeliveries: 0,
        averageEngagementScore: 0.0,
        optimalTimeSlots: [],
        typePerformance: [],
        lastUpdated: Date()
    )

    var averageEngagementPercentage: String {
        String(format: "%.1f%%", averageEngagementScore * 100)
    }

    var topOptimalHour: String? {
        optimalTimeSlots.first?.timeRange
    }

    var bestPerformingType: NotificationType? {
        typePerformance.first?.type
    }
}
