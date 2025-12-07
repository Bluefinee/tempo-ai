import Combine
import CoreLocation
import Foundation
import UserNotifications

// MARK: - Smart Notification Engine

/// Intelligent notification system that delivers personalized, context-aware health notifications
/// Integrates with HealthAnalysisEngine and user preferences for optimal timing and relevance
@MainActor
class SmartNotificationEngine: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = SmartNotificationEngine()

    // MARK: - Published Properties

    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var isNotificationEngineActive: Bool = false
    @Published var pendingNotifications: [SmartNotification] = []
    @Published var notificationHistory: [NotificationEvent] = []

    // MARK: - Private Properties

    private let notificationCenter = UNUserNotificationCenter.current()
    private let healthAnalysisEngine = HealthAnalysisEngine.shared
    private let rateLimiter = AIRequestRateLimiter.shared
    private var cancellables = Set<AnyCancellable>()

    // Notification scheduling and intelligence
    private var userPreferences: NotificationPreferences = .default
    private var contextManager: NotificationContextManager
    private var deliveryOptimizer: NotificationDeliveryOptimizer

    // MARK: - Initialization

    private override init() {
        self.contextManager = NotificationContextManager()
        self.deliveryOptimizer = NotificationDeliveryOptimizer()
        super.init()

        setupNotificationCenter()
        loadUserPreferences()
        observeHealthAnalysisResults()
    }

    // MARK: - Public Interface

    /// Request notification permissions and activate the smart notification engine
    func requestPermissionsAndActivate() async {
        print("📱 SmartNotificationEngine: Requesting notification permissions...")

        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )

            await MainActor.run {
                notificationPermissionStatus = granted ? .authorized : .denied
                print("📱 Notification permissions: \(granted ? "granted" : "denied")")

                if granted {
                    activateNotificationEngine()
                }
            }
        } catch {
            print("❌ Error requesting notification permissions: \(error)")
            notificationPermissionStatus = .denied
        }
    }

    /// Update user notification preferences
    func updateNotificationPreferences(_ preferences: NotificationPreferences) {
        userPreferences = preferences
        saveUserPreferences()

        // Reschedule notifications based on new preferences
        Task {
            await rescheduleActiveNotifications()
        }

        print("📱 Updated notification preferences: \(preferences)")
    }

    /// Schedule a smart notification with context-aware delivery
    func scheduleSmartNotification(_ notification: SmartNotification) async {
        guard notificationPermissionStatus == .authorized else {
            print("❌ Cannot schedule notification: Permission not granted")
            return
        }

        // Optimize delivery time based on user context
        let optimizedNotification = await deliveryOptimizer.optimize(
            notification: notification,
            userPreferences: userPreferences,
            currentContext: contextManager.getCurrentContext()
        )

        // Check rate limits
        if shouldRateLimitNotification(optimizedNotification) {
            print("⏱️ Rate limiting notification: \(optimizedNotification.title)")
            return
        }

        // Schedule the notification
        do {
            try await scheduleNotification(optimizedNotification)
            await MainActor.run {
                pendingNotifications.append(optimizedNotification)
            }
            print("📅 Scheduled smart notification: \(optimizedNotification.title)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }

    /// Cancel a specific notification
    func cancelNotification(with id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        pendingNotifications.removeAll { $0.id == id }
        print("🚫 Cancelled notification: \(id)")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingNotifications.removeAll()
        print("🚫 Cancelled all pending notifications")
    }

    /// Get notification engagement analytics
    func getNotificationAnalytics() -> NotificationAnalytics {
        let totalSent = notificationHistory.count
        let totalOpened = notificationHistory.filter { $0.action == .opened }.count
        let totalDismissed = notificationHistory.filter { $0.action == .dismissed }.count

        let engagementRate = totalSent > 0 ? Double(totalOpened) / Double(totalSent) : 0.0

        return NotificationAnalytics(
            totalSent: totalSent,
            totalOpened: totalOpened,
            totalDismissed: totalDismissed,
            engagementRate: engagementRate,
            averageDeliveryTime: calculateAverageDeliveryTime(),
            mostEngagingTypes: getMostEngagingNotificationTypes()
        )
    }

    // MARK: - Smart Notification Triggers

    /// Trigger health insights notification based on analysis results
    func triggerHealthInsightsNotification(insights: AIHealthInsights) async {
        guard userPreferences.healthInsightsEnabled else { return }

        let notification = SmartNotification(
            id: UUID().uuidString,
            type: .healthInsights,
            priority: .normal,
            title: "新しい健康分析結果",
            body: insights.summary.prefix(120) + "...",
            categoryIdentifier: "HEALTH_INSIGHTS",
            actionButtons: [
                NotificationAction(id: "view", title: "詳細を見る", isDestructive: false),
                NotificationAction(id: "dismiss", title: "後で", isDestructive: false),
            ],
            userInfo: [
                "insightsId": insights.id,
                "analysisDate": insights.analysisDate.timeIntervalSince1970,
                "hasHighPriorityFindings": insights.riskFactors.contains { $0.severity > 7 },
            ]
        )

        await scheduleSmartNotification(notification)
    }

    /// Trigger reminder notification for health data collection
    func triggerHealthDataReminderNotification() async {
        guard userPreferences.dataRemindersEnabled else { return }

        let notification = SmartNotification(
            id: "health_data_reminder_\(Date().timeIntervalSince1970)",
            type: .dataReminder,
            priority: .low,
            title: "健康データの更新",
            body: "より正確な分析のため、最新の健康データを同期しませんか？",
            categoryIdentifier: "DATA_REMINDER",
            scheduledDelivery: .relative(timeInterval: 3600),  // 1 hour from now
            actionButtons: [
                NotificationAction(id: "sync", title: "同期する", isDestructive: false),
                NotificationAction(id: "later", title: "後で", isDestructive: false),
            ]
        )

        await scheduleSmartNotification(notification)
    }

    /// Trigger wellness tip notification
    func triggerWellnessTipNotification(tip: WellnessTip) async {
        guard userPreferences.wellnessTipsEnabled else { return }

        let notification = SmartNotification(
            id: "wellness_tip_\(tip.id)",
            type: .wellnessTip,
            priority: .low,
            title: "健康のヒント",
            body: tip.shortDescription,
            categoryIdentifier: "WELLNESS_TIP",
            scheduledDelivery: .optimal,  // Let delivery optimizer decide
            actionButtons: [
                NotificationAction(id: "learn_more", title: "詳しく見る", isDestructive: false)
            ],
            userInfo: [
                "tipId": tip.id,
                "category": tip.category.rawValue,
            ]
        )

        await scheduleSmartNotification(notification)
    }

    /// Trigger goal achievement notification
    func triggerGoalAchievementNotification(goal: DetailedHealthGoal, achievement: GoalAchievement) async {
        guard userPreferences.achievementsEnabled else { return }

        let notification = SmartNotification(
            id: "goal_achievement_\(goal.id)_\(achievement.id)",
            type: .goalAchievement,
            priority: .high,
            title: "目標達成おめでとうございます！",
            body: achievement.celebrationMessage,
            categoryIdentifier: "GOAL_ACHIEVEMENT",
            scheduledDelivery: .immediate,
            actionButtons: [
                NotificationAction(id: "celebrate", title: "詳細を見る", isDestructive: false),
                NotificationAction(id: "share", title: "シェア", isDestructive: false),
            ],
            userInfo: [
                "goalId": goal.id,
                "achievementId": achievement.id,
                "achievementType": achievement.type.rawValue,
            ]
        )

        await scheduleSmartNotification(notification)
    }

    // MARK: - Private Implementation

    private func setupNotificationCenter() {
        notificationCenter.delegate = self

        // Register notification categories
        registerNotificationCategories()

        // Check current permission status
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                notificationPermissionStatus = settings.authorizationStatus
                print("📱 Current notification permission: \(settings.authorizationStatus)")
            }
        }
    }

    private func registerNotificationCategories() {
        let categories: [UNNotificationCategory] = [
            // Health Insights
            UNNotificationCategory(
                identifier: "HEALTH_INSIGHTS",
                actions: [
                    UNNotificationAction(identifier: "view", title: "詳細を見る", options: .foreground),
                    UNNotificationAction(identifier: "dismiss", title: "後で", options: []),
                ],
                intentIdentifiers: []
            ),

            // Data Reminder
            UNNotificationCategory(
                identifier: "DATA_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "sync", title: "同期する", options: .foreground),
                    UNNotificationAction(identifier: "later", title: "後で", options: []),
                ],
                intentIdentifiers: []
            ),

            // Wellness Tip
            UNNotificationCategory(
                identifier: "WELLNESS_TIP",
                actions: [
                    UNNotificationAction(identifier: "learn_more", title: "詳しく見る", options: .foreground)
                ],
                intentIdentifiers: []
            ),

            // Goal Achievement
            UNNotificationCategory(
                identifier: "GOAL_ACHIEVEMENT",
                actions: [
                    UNNotificationAction(identifier: "celebrate", title: "詳細を見る", options: .foreground),
                    UNNotificationAction(identifier: "share", title: "シェア", options: .foreground),
                ],
                intentIdentifiers: []
            ),
        ]

        notificationCenter.setNotificationCategories(Set(categories))
        print("📱 Registered \(categories.count) notification categories")
    }

    private func activateNotificationEngine() {
        isNotificationEngineActive = true

        // Start context monitoring
        contextManager.startMonitoring()

        // Schedule initial wellness notifications
        Task {
            await scheduleInitialWellnessNotifications()
        }

        print("✅ SmartNotificationEngine activated")
    }

    private func observeHealthAnalysisResults() {
        healthAnalysisEngine.$lastAnalysisResult
            .compactMap { $0 }
            .sink { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .ai(let insights):
                        await self?.triggerHealthInsightsNotification(insights: insights)
                    case .local(let insights):
                        // Create notification for local insights if significant
                        if insights.hasSignificantFindings {
                            let aiInsights = insights.toAIHealthInsights()
                            await self?.triggerHealthInsightsNotification(insights: aiInsights)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func scheduleInitialWellnessNotifications() async {
        // Schedule a welcome tip for new users
        let welcomeTip = WellnessTip.welcomeTip(for: userPreferences.language)
        await triggerWellnessTipNotification(tip: welcomeTip)
    }

    private func shouldRateLimitNotification(_ notification: SmartNotification) -> Bool {
        let recentNotifications = notificationHistory.filter {
            $0.sentDate > Date().addingTimeInterval(-3600)  // Last hour
        }

        // Apply different rate limits based on notification type and priority
        switch notification.type {
        case .healthInsights:
            return recentNotifications.filter { $0.type == .healthInsights }.count >= 3
        case .dataReminder:
            return recentNotifications.filter { $0.type == .dataReminder }.count >= 1
        case .wellnessTip:
            return recentNotifications.filter { $0.type == .wellnessTip }.count >= 2
        case .goalAchievement:
            return false  // Never rate limit achievements
        case .systemAlert:
            return false  // Never rate limit system alerts
        }
    }

    private func scheduleNotification(_ notification: SmartNotification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.categoryIdentifier = notification.categoryIdentifier
        content.userInfo = notification.userInfo
        content.sound = notification.soundName.flatMap(UNNotificationSound.init) ?? .default

        if let badge = notification.badgeCount {
            content.badge = NSNumber(value: badge)
        }

        // Determine trigger based on scheduled delivery
        let trigger: UNNotificationTrigger? = {
            switch notification.scheduledDelivery {
            case .immediate:
                return nil
            case .relative(let timeInterval):
                return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            case .absolute(let date):
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            case .optimal:
                // Delivery optimizer will determine the best time
                let optimalDate = await deliveryOptimizer.calculateOptimalDeliveryTime(
                    for: notification,
                    userPreferences: userPreferences
                )
                let dateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: optimalDate)
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            }
        }()

        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)

        // Record the notification event
        let event = NotificationEvent(
            id: notification.id,
            type: notification.type,
            sentDate: Date(),
            scheduledDate: notification.scheduledDelivery.targetDate ?? Date(),
            action: .sent
        )

        await MainActor.run {
            notificationHistory.append(event)
        }
    }

    private func rescheduleActiveNotifications() async {
        // Cancel existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        // Reschedule based on new preferences
        let notificationsToReschedule = pendingNotifications
        pendingNotifications.removeAll()

        for notification in notificationsToReschedule {
            await scheduleSmartNotification(notification)
        }

        print("🔄 Rescheduled \(notificationsToReschedule.count) notifications")
    }

    private func loadUserPreferences() {
        // Load from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: "NotificationPreferences"),
            let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data)
        {
            userPreferences = preferences
        } else {
            userPreferences = .default
        }

        print("📱 Loaded notification preferences: \(userPreferences)")
    }

    private func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "NotificationPreferences")
        }
    }

    private func calculateAverageDeliveryTime() -> TimeInterval {
        let deliveryTimes = notificationHistory.compactMap { event in
            event.deliveredDate?.timeIntervalSince(event.sentDate)
        }

        return deliveryTimes.isEmpty ? 0 : deliveryTimes.reduce(0, +) / Double(deliveryTimes.count)
    }

    private func getMostEngagingNotificationTypes() -> [NotificationType] {
        let typeEngagement = Dictionary(grouping: notificationHistory) { $0.type }
            .mapValues { events in
                let opened = events.filter { $0.action == .opened }.count
                let total = events.count
                return total > 0 ? Double(opened) / Double(total) : 0.0
            }

        return
            typeEngagement
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension SmartNotificationEngine: UNUserNotificationCenterDelegate {

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])

        Task { @MainActor in
            recordNotificationEvent(
                id: notification.request.identifier,
                action: .delivered
            )
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        Task { @MainActor in
            let actionIdentifier = response.actionIdentifier
            let notificationId = response.notification.request.identifier

            // Record the user action
            recordNotificationEvent(
                id: notificationId,
                action: actionIdentifier == UNNotificationDismissActionIdentifier ? .dismissed : .opened
            )

            // Handle specific actions
            await handleNotificationAction(
                actionIdentifier: actionIdentifier,
                notification: response.notification
            )

            completionHandler()
        }
    }

    private func recordNotificationEvent(id: String, action: NotificationAction.ActionType) {
        if let index = notificationHistory.firstIndex(where: { $0.id == id }) {
            notificationHistory[index].action = action

            if action == .delivered {
                notificationHistory[index].deliveredDate = Date()
            } else if action == .opened || action == .dismissed {
                notificationHistory[index].respondedDate = Date()
            }
        }

        print("📱 Recorded notification action: \(action) for \(id)")
    }

    private func handleNotificationAction(actionIdentifier: String, notification: UNNotification) async {
        switch actionIdentifier {
        case "view", "celebrate", "learn_more":
            // Navigate to appropriate view in the app
            await navigateToNotificationContent(notification: notification)

        case "sync":
            // Trigger data synchronization
            await triggerDataSync()

        case "share":
            // Handle sharing achievement
            await handleAchievementShare(notification: notification)

        default:
            print("📱 Unhandled notification action: \(actionIdentifier)")
        }
    }

    private func navigateToNotificationContent(notification: UNNotification) async {
        // This would typically post a notification that the app's main coordinator listens to
        NotificationCenter.default.post(
            name: .navigateToNotificationContent,
            object: notification.request.content.userInfo
        )
    }

    private func triggerDataSync() async {
        // Trigger health data synchronization
        NotificationCenter.default.post(
            name: .triggerHealthDataSync,
            object: nil
        )
    }

    private func handleAchievementShare(notification: UNNotification) async {
        // Handle achievement sharing
        NotificationCenter.default.post(
            name: .shareAchievement,
            object: notification.request.content.userInfo
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToNotificationContent = Notification.Name("NavigateToNotificationContent")
    static let triggerHealthDataSync = Notification.Name("TriggerHealthDataSync")
    static let shareAchievement = Notification.Name("ShareAchievement")
}
