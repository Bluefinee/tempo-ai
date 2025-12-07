import CoreLocation
import Foundation
import UIKit

// MARK: - Notification Context Manager

/// Manages contextual information for intelligent notification delivery
/// Tracks user activity patterns, app usage, and environmental factors
@MainActor
class NotificationContextManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var currentContext: NotificationContext = NotificationContext()
    @Published var isMonitoring: Bool = false

    // MARK: - Private Properties

    private var appUsageTracker: AppUsageTracker
    private var userActivityDetector: UserActivityDetector
    private let locationManager = CLLocationManager()

    // Context history for pattern learning
    private var contextHistory: [NotificationContext] = []
    private let maxHistoryEntries = 100

    // MARK: - Initialization

    override init() {
        self.appUsageTracker = AppUsageTracker()
        self.userActivityDetector = UserActivityDetector()
        super.init()

        setupLocationManager()
        observeApplicationState()
        loadContextHistory()
    }

    // MARK: - Public Interface

    /// Start monitoring user context for notification optimization
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true

        // Start tracking components
        appUsageTracker.startTracking()
        userActivityDetector.startDetection()

        // Begin periodic context updates
        startPeriodicContextUpdates()

        print("📊 NotificationContextManager: Started monitoring user context")
    }

    /// Stop context monitoring
    func stopMonitoring() {
        isMonitoring = false

        appUsageTracker.stopTracking()
        userActivityDetector.stopDetection()

        print("📊 NotificationContextManager: Stopped monitoring")
    }

    /// Get current notification context
    func getCurrentContext() -> NotificationContext {
        updateCurrentContext()
        return currentContext
    }

    /// Check if current time is optimal for notifications based on historical data
    func isOptimalNotificationTime() -> Bool {
        let context = getCurrentContext()

        // Check quiet hours
        if context.isInQuietHours {
            return false
        }

        // Check if user is actively using the app
        if context.appUsageState == .activelyUsing {
            return false  // Don't interrupt active usage
        }

        // Check if user is likely to be receptive based on historical patterns
        return isHistoricallyReceptiveTime() && context.phoneState == .unlocked
    }

    /// Get optimal notification delivery delay based on current context
    func getOptimalDeliveryDelay() -> TimeInterval {
        let context = getCurrentContext()

        switch context.appUsageState {
        case .notUsed:
            return 0  // Deliver immediately

        case .backgroundActive:
            return 300  // 5 minutes delay to avoid interrupting background tasks

        case .activelyUsing:
            return 1800  // 30 minutes delay to avoid interrupting active usage

        case .recentlyUsed:
            return 600  // 10 minutes delay to let user finish current task
        }
    }

    /// Predict user engagement likelihood for a notification at the current time
    func predictEngagementLikelihood() -> Double {
        let context = getCurrentContext()
        var likelihood: Double = 0.5  // Base probability

        // Adjust based on app usage state
        switch context.appUsageState {
        case .notUsed:
            likelihood += 0.3
        case .recentlyUsed:
            likelihood += 0.1
        case .backgroundActive:
            likelihood -= 0.1
        case .activelyUsing:
            likelihood -= 0.3
        }

        // Adjust based on historical patterns
        if isHistoricallyReceptiveTime() {
            likelihood += 0.2
        }

        // Adjust based on phone state
        if context.phoneState == .locked {
            likelihood -= 0.2
        }

        // Adjust based on time of day patterns
        likelihood += getTimeOfDayEngagementBoost()

        return max(0.0, min(1.0, likelihood))
    }

    // MARK: - Private Implementation

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    private func observeApplicationState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func startPeriodicContextUpdates() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCurrentContext()
            }
        }
    }

    private func updateCurrentContext() {
        let newContext = NotificationContext(
            timestamp: Date(),
            timeOfDay: getCurrentTimeOfDay(),
            dayOfWeek: Calendar.current.component(.weekday, from: Date()),
            appUsageState: appUsageTracker.getCurrentUsageState(),
            phoneState: getPhoneState(),
            locationContext: getCurrentLocationContext(),
            isInQuietHours: isCurrentTimeInQuietHours(),
            batteryLevel: UIDevice.current.batteryLevel,
            isCharging: UIDevice.current.batteryState == .charging,
            networkAvailable: isNetworkAvailable()
        )

        // Update current context
        currentContext = newContext

        // Add to history for pattern learning
        addToContextHistory(newContext)
    }

    private func getCurrentTimeOfDay() -> TimeOfDay {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        return TimeOfDay(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }

    private func getPhoneState() -> PhoneState {
        // This is a simplified implementation
        // In a real app, you might use more sophisticated detection
        let application = UIApplication.shared

        switch application.applicationState {
        case .active:
            return .unlocked
        case .background, .inactive:
            return .locked
        @unknown default:
            return .locked
        }
    }

    private func getCurrentLocationContext() -> LocationContext {
        // Simplified location context
        // In a real implementation, you might categorize locations as home, work, etc.
        return LocationContext(
            type: .unknown,
            confidence: 0.5
        )
    }

    private func isCurrentTimeInQuietHours() -> Bool {
        // This would check against user preferences
        // For now, assume quiet hours are 22:00 - 08:00
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 22 || hour < 8
    }

    private func isNetworkAvailable() -> Bool {
        // Simplified network check
        // In a real implementation, you'd use proper reachability checking
        return true
    }

    private func addToContextHistory(_ context: NotificationContext) {
        contextHistory.append(context)

        // Maintain history size limit
        if contextHistory.count > maxHistoryEntries {
            contextHistory.removeFirst()
        }

        // Periodically save context history
        saveContextHistory()
    }

    private func isHistoricallyReceptiveTime() -> Bool {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentDayOfWeek = Calendar.current.component(.weekday, from: Date())

        // Find historical contexts for similar times
        let similarContexts = contextHistory.filter { context in
            let contextHour = Calendar.current.component(.hour, from: context.timestamp)
            let contextDayOfWeek = Calendar.current.component(.weekday, from: context.timestamp)

            return abs(contextHour - currentHour) <= 1 && contextDayOfWeek == currentDayOfWeek
        }

        // If we have enough historical data, use it to predict receptivity
        if similarContexts.count >= 5 {
            let receptiveContexts = similarContexts.filter { $0.wasReceptiveToNotifications }
            return Double(receptiveContexts.count) / Double(similarContexts.count) > 0.6
        }

        // Default assumption based on typical patterns
        return currentHour >= 9 && currentHour <= 21  // 9 AM to 9 PM
    }

    private func getTimeOfDayEngagementBoost() -> Double {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 8 ... 10:  // Morning peak
            return 0.2
        case 12 ... 14:  // Lunch peak
            return 0.15
        case 18 ... 20:  // Evening peak
            return 0.2
        case 22 ... 23, 0 ... 6:  // Night/early morning
            return -0.3
        default:
            return 0.0
        }
    }

    private func loadContextHistory() {
        if let data = UserDefaults.standard.data(forKey: "NotificationContextHistory"),
            let history = try? JSONDecoder().decode([NotificationContext].self, from: data)
        {
            contextHistory = history
        }
    }

    private func saveContextHistory() {
        if let data = try? JSONEncoder().encode(contextHistory) {
            UserDefaults.standard.set(data, forKey: "NotificationContextHistory")
        }
    }

    @objc private func applicationDidEnterBackground() {
        updateCurrentContext()
    }

    @objc private func applicationWillEnterForeground() {
        updateCurrentContext()
    }

    @objc private func applicationDidBecomeActive() {
        updateCurrentContext()
    }
}

// MARK: - CLLocationManagerDelegate

extension NotificationContextManager: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            updateCurrentContext()
        }
    }
}

// MARK: - Supporting Types

/// Current notification delivery context
struct NotificationContext: Codable {
    let timestamp: Date
    let timeOfDay: TimeOfDay
    let dayOfWeek: Int
    let appUsageState: AppUsageState
    let phoneState: PhoneState
    let locationContext: LocationContext
    let isInQuietHours: Bool
    let batteryLevel: Float
    let isCharging: Bool
    let networkAvailable: Bool

    // Derived properties
    var wasReceptiveToNotifications: Bool {
        // This would be updated based on actual user interaction with notifications
        // For now, we'll estimate based on context
        return !isInQuietHours && appUsageState != .activelyUsing && phoneState == .unlocked && batteryLevel > 0.2
    }

    init() {
        self.timestamp = Date()
        self.timeOfDay = TimeOfDay(hour: 12, minute: 0)
        self.dayOfWeek = 1
        self.appUsageState = .notUsed
        self.phoneState = .unlocked
        self.locationContext = LocationContext(type: .unknown, confidence: 0.0)
        self.isInQuietHours = false
        self.batteryLevel = 1.0
        self.isCharging = false
        self.networkAvailable = true
    }

    init(
        timestamp: Date, timeOfDay: TimeOfDay, dayOfWeek: Int, appUsageState: AppUsageState, phoneState: PhoneState,
        locationContext: LocationContext, isInQuietHours: Bool, batteryLevel: Float, isCharging: Bool,
        networkAvailable: Bool
    ) {
        self.timestamp = timestamp
        self.timeOfDay = timeOfDay
        self.dayOfWeek = dayOfWeek
        self.appUsageState = appUsageState
        self.phoneState = phoneState
        self.locationContext = locationContext
        self.isInQuietHours = isInQuietHours
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
        self.networkAvailable = networkAvailable
    }
}

/// App usage state
enum AppUsageState: String, CaseIterable, Codable {
    case notUsed
    case recentlyUsed
    case backgroundActive
    case activelyUsing
}

/// Phone state
enum PhoneState: String, CaseIterable, Codable {
    case locked
    case unlocked
}

/// Location context
struct LocationContext: Codable {
    let type: LocationType
    let confidence: Double

    enum LocationType: String, CaseIterable, Codable {
        case home
        case work
        case gym
        case unknown
    }
}

// MARK: - App Usage Tracker

class AppUsageTracker: ObservableObject {

    private var lastActiveTime: Date?
    private var isTracking: Bool = false

    func startTracking() {
        isTracking = true
        lastActiveTime = Date()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func stopTracking() {
        isTracking = false
    }

    func getCurrentUsageState() -> AppUsageState {
        guard let lastActive = lastActiveTime else {
            return .notUsed
        }

        let timeSinceLastActive = Date().timeIntervalSince(lastActive)
        let appState = UIApplication.shared.applicationState

        switch appState {
        case .active:
            return .activelyUsing
        case .background:
            if timeSinceLastActive < 300 {  // 5 minutes
                return .backgroundActive
            } else if timeSinceLastActive < 1800 {  // 30 minutes
                return .recentlyUsed
            } else {
                return .notUsed
            }
        case .inactive:
            return .recentlyUsed
        @unknown default:
            return .notUsed
        }
    }

    @objc private func appDidBecomeActive() {
        lastActiveTime = Date()
    }

    @objc private func appDidEnterBackground() {
        // Keep last active time as is
    }
}

// MARK: - User Activity Detector

class UserActivityDetector: ObservableObject {

    private var isDetecting: Bool = false

    func startDetection() {
        isDetecting = true
        // In a real implementation, you might use Core Motion to detect user activity
        print("🏃‍♀️ UserActivityDetector: Started activity detection")
    }

    func stopDetection() {
        isDetecting = false
        print("🏃‍♀️ UserActivityDetector: Stopped activity detection")
    }

    func getCurrentActivity() -> UserActivity {
        // Simplified activity detection
        // In a real implementation, you'd use CMMotionManager and other sensors
        return .stationary
    }
}

/// User activity types
enum UserActivity: String, CaseIterable, Codable {
    case stationary
    case walking
    case running
    case driving
    case unknown
}
