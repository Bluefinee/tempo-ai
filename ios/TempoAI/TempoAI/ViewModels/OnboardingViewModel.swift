import Foundation
import SwiftUI

/// ViewModel managing onboarding flow state and permission requests.
///
/// Handles navigation through the 4-page onboarding experience, manages permission
/// request state, and coordinates with the permission manager for HealthKit and
/// location access. Tracks completion status for app initialization.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current active page in onboarding flow (0-3)
    @Published var currentPage: Int = 0

    /// HealthKit permission status
    @Published var healthKitStatus: PermissionStatus = .notDetermined

    /// Location permission status
    @Published var locationStatus: PermissionStatus = .notDetermined

    /// Whether onboarding flow has been completed
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Private Properties

    private let permissionManager = PermissionManager.shared
    private let userDefaults = UserDefaults.standard

    // MARK: - Constants

    private enum UserDefaultsKeys {
        static let onboardingCompleted = "OnboardingCompleted"
        static let onboardingStartTime = "OnboardingStartTime"
    }

    // MARK: - Initialization

    init() {
        loadOnboardingState()
        observePermissionChanges()
    }

    // MARK: - Public Methods

    /// Track when user starts onboarding flow for analytics
    func trackOnboardingStart() {
        userDefaults.set(Date(), forKey: UserDefaultsKeys.onboardingStartTime)
        print("📊 Onboarding flow started")
    }

    /// Navigate to next page in onboarding flow
    func nextPage() {
        guard currentPage < 3 else { return }
        currentPage += 1
        print("📱 Onboarding: Advanced to page \(currentPage)")
    }

    /// Navigate to previous page in onboarding flow
    func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        print("📱 Onboarding: Returned to page \(currentPage)")
    }

    /// Jump directly to specific page
    func goToPage(_ page: Int) {
        guard page >= 0 && page <= 3 else { return }
        currentPage = page
        print("📱 Onboarding: Jumped to page \(currentPage)")
    }

    /// Request HealthKit permissions
    func requestHealthKitPermission() async {
        print("🏥 Requesting HealthKit permission...")
        let status = await permissionManager.requestHealthKitPermission()
        healthKitStatus = status
        print("🏥 HealthKit permission result: \(status)")
    }

    /// Request location permissions
    func requestLocationPermission() async {
        print("📍 Requesting location permission...")
        let status = await permissionManager.requestLocationPermission()
        locationStatus = status
        print("📍 Location permission result: \(status)")
    }

    /// Complete onboarding and mark as finished
    func completeOnboarding() {
        userDefaults.set(true, forKey: UserDefaultsKeys.onboardingCompleted)
        isOnboardingCompleted = true

        // Track completion analytics
        if let startTime = userDefaults.object(forKey: UserDefaultsKeys.onboardingStartTime) as? Date {
            let duration = Date().timeIntervalSince(startTime)
            print("📊 Onboarding completed in \(Int(duration)) seconds")
        }

        print("✅ Onboarding flow completed successfully")
        print("📊 Final permission status - HealthKit: \(healthKitStatus), Location: \(locationStatus)")
    }

    /// Reset onboarding state (for testing or re-onboarding)
    func resetOnboarding() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingCompleted)
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingStartTime)
        currentPage = 0
        isOnboardingCompleted = false
        healthKitStatus = permissionManager.healthKitPermissionStatus
        locationStatus = permissionManager.locationPermissionStatus
        print("🔄 Onboarding state reset")
    }

    // MARK: - Private Methods

    /// Load existing onboarding completion state
    private func loadOnboardingState() {
        isOnboardingCompleted = userDefaults.bool(forKey: UserDefaultsKeys.onboardingCompleted)
        healthKitStatus = permissionManager.healthKitPermissionStatus
        locationStatus = permissionManager.locationPermissionStatus

        print("📱 Loaded onboarding state - Completed: \(isOnboardingCompleted)")
        print("📊 Permission status - HealthKit: \(healthKitStatus), Location: \(locationStatus)")
    }

    /// Observe permission status changes from permission manager
    private func observePermissionChanges() {
        // Observe HealthKit permission changes
        NotificationCenter.default.addObserver(
            forName: .healthKitPermissionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.healthKitStatus = self?.permissionManager.healthKitPermissionStatus ?? .notDetermined
        }

        // Observe location permission changes
        NotificationCenter.default.addObserver(
            forName: .locationPermissionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.locationStatus = self?.permissionManager.locationPermissionStatus ?? .notDetermined
        }
    }
}

// MARK: - Computed Properties

extension OnboardingViewModel {

    /// Whether all critical permissions have been granted
    var allPermissionsGranted: Bool {
        healthKitStatus == .granted && locationStatus == .granted
    }

    /// Whether at least one permission has been granted
    var anyPermissionsGranted: Bool {
        healthKitStatus == .granted || locationStatus == .granted
    }

    /// Progress through onboarding flow (0.0 to 1.0)
    var onboardingProgress: Double {
        Double(currentPage) / 3.0
    }

    /// Whether user is on the final onboarding page
    var isOnFinalPage: Bool {
        currentPage == 3
    }

    /// Whether user can proceed to next page
    var canProceed: Bool {
        switch currentPage {
        case 0: return true  // Welcome page - always can proceed
        case 1: return true  // HealthKit page - can skip
        case 2: return true  // Location page - can skip
        case 3: return true  // Completion page - ready to finish
        default: return false
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let healthKitPermissionChanged = Notification.Name("HealthKitPermissionChanged")
    static let locationPermissionChanged = Notification.Name("LocationPermissionChanged")
}
