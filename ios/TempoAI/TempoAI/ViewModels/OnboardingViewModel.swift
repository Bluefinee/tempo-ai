import Combine
import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Codable {
    case japanese = "ja"
    case english = "en"

    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        }
    }

    /// Convert to LocalizationManager.SupportedLanguage
    var localizationLanguage: LocalizationManager.SupportedLanguage {
        switch self {
        case .japanese: return .japanese
        case .english: return .english
        }
    }
}

/// ViewModel managing onboarding flow state, language selection, and permission requests.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current active page in onboarding flow (0-6)
    @Published var currentPage: Int = 0

    /// Selected language for the app
    @Published var selectedLanguage: AppLanguage = .japanese

    /// HealthKit permission status
    @Published var healthKitStatus: PermissionStatus = .notDetermined

    /// Location permission status
    @Published var locationStatus: PermissionStatus = .notDetermined

    /// Whether onboarding flow has been completed
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Dependencies

    private let permissionManager = PermissionManager.shared
    private let userDefaults = UserDefaults.standard
    private let progressiveDisclosure = OnboardingProgressiveDisclosure()

    // MARK: - Constants

    private enum UserDefaultsKeys {
        static let onboardingCompleted = "OnboardingCompleted"
        static let onboardingStartTime = "OnboardingStartTime"
        static let selectedLanguage = "SelectedLanguage"
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
        guard currentPage < 7 else { return }
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
        guard page >= 0 && page <= 7 else { return }
        currentPage = page
        print("📱 Onboarding: Jumped to page \(currentPage)")
    }

    /// Set the selected language for the app
    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: UserDefaultsKeys.selectedLanguage)
        print("🌍 Language set to: \(language.displayName)")

        // Apply language change immediately
        Task { @MainActor in
            LocalizationManager.shared.setLanguage(language.localizationLanguage)
        }
    }

    /// Request HealthKit permissions using dedicated HealthKitManager
    func requestHealthKitPermission() async {
        print("🏥 Requesting HealthKit permission...")
        let success: Bool = await HealthKitManager.shared.requestAuthorization()
        healthKitStatus = HealthKitManager.shared.authorizationStatus
        print("🏥 HealthKit permission result: \(success) - Status: \(healthKitStatus)")
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
    /// Completely resets all onboarding-related data including language preferences
    func resetOnboarding() {
        print("🔄 Starting complete onboarding reset...")

        // Clear ALL UserDefaults keys related to onboarding and language
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingCompleted)
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingStartTime)
        userDefaults.removeObject(forKey: UserDefaultsKeys.selectedLanguage)

        // Clear progressive disclosure state
        userDefaults.removeObject(forKey: UserDefaultsKeys.disclosureLevel)
        userDefaults.removeObject(forKey: UserDefaultsKeys.explainedDataCategories)
        userDefaults.removeObject(forKey: UserDefaultsKeys.privacyConcerns)
        userDefaults.removeObject(forKey: UserDefaultsKeys.prefersDetailedExplanations)
        userDefaults.removeObject(forKey: UserDefaultsKeys.currentDisclosureStage)

        // Clear localization manager's language preference
        userDefaults.removeObject(forKey: "user_language_preference")

        // Use proper state update order to prevent race conditions
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Reset completion state first to prevent automatic navigation
            self.isOnboardingCompleted = false
            print("🔄 Reset completion status: false")

            // Reset page to start
            self.currentPage = 0
            print("🔄 Reset page to: 0")

            // Reset language to default (Japanese)
            self.selectedLanguage = .japanese
            LocalizationManager.shared.setLanguage(.japanese)
            print("🔄 Reset language to: Japanese")

            // Reset permission statuses to initial state
            self.healthKitStatus = .notDetermined
            self.locationStatus = .notDetermined
            print("🔄 Reset permission statuses to: notDetermined")

            // Reset progressive disclosure state
            self.disclosureLevel = .minimal
            self.explainedDataCategories = []
            self.privacyConcerns = []
            self.prefersDetailedExplanations = false
            self.currentDisclosureStage = .introduction
            print("🔄 Reset progressive disclosure state to defaults")

            // Post notification for other app components that onboarding was reset
            NotificationCenter.default.post(
                name: .onboardingDidReset,
                object: nil,
                userInfo: ["timestamp": Date()]
            )

            print("✅ Complete onboarding reset finished successfully")
            print("📊 Final state - Page: \(self.currentPage), Completed: \(self.isOnboardingCompleted)")
            print("🌍 Language: \(self.selectedLanguage.displayName)")
            print("📱 Permissions - HealthKit: \(self.healthKitStatus), Location: \(self.locationStatus)")
        }
    }

    // MARK: - Progressive Disclosure Delegate Methods

    /// Progressive disclosure support
    var progressiveDisclosureLevel: ProgressiveDisclosureLevel {
        progressiveDisclosure.disclosureLevel
    }

    func updateDisclosureLevel(_ level: ProgressiveDisclosureLevel) {
        progressiveDisclosure.updateDisclosureLevel(level)
    }

    func markDataCategoryExplained(_ category: HealthDataCategory) {
        progressiveDisclosure.markDataCategoryExplained(category)
    }

    func recordPrivacyConcern(_ concern: PrivacyConcern) {
        progressiveDisclosure.recordPrivacyConcern(concern)
    }

    func setDetailedExplanationPreference(_ prefers: Bool) {
        progressiveDisclosure.setDetailedExplanationPreference(prefers)
    }

    func advanceDisclosureStage() {
        progressiveDisclosure.advanceDisclosureStage()
    }

    func getPersonalizedExplanation(for category: HealthDataCategory) -> DataExplanation {
        return progressiveDisclosure.getPersonalizedExplanation(for: category)
    }

    func shouldShowDetailedPermissionExplanation(for permission: PermissionType) -> Bool {
        return progressiveDisclosure.shouldShowDetailedPermissionExplanation(for: permission)
    }

    func getRecommendedSharingLevel() -> DataSharingLevel {
        return progressiveDisclosure.getRecommendedSharingLevel()
    }
    // MARK: - Private Methods

    /// Load existing onboarding completion state
    private func loadOnboardingState() {
        // Ensure we're loading state on the main thread to avoid race conditions
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Load completion state
            self.isOnboardingCompleted = self.userDefaults.bool(forKey: UserDefaultsKeys.onboardingCompleted)

            // Initialize page to 0 when onboarding is not completed
            if !self.isOnboardingCompleted {
                self.currentPage = 0
            }

            // Load permission statuses
            self.healthKitStatus = self.permissionManager.healthKitPermissionStatus
            self.locationStatus = self.permissionManager.locationPermissionStatus

            // Load selected language
            if let savedLanguage = self.userDefaults.string(forKey: UserDefaultsKeys.selectedLanguage),
                let language = AppLanguage(rawValue: savedLanguage)
            {
                self.selectedLanguage = language
                Task { @MainActor in
                    LocalizationManager.shared.setLanguage(language.localizationLanguage)
                }
            }

            print("📱 Loaded onboarding state - Completed: \(self.isOnboardingCompleted), Page: \(self.currentPage)")
            print("🌍 Language: \(self.selectedLanguage.displayName)")
            print("📊 Permission status - HealthKit: \(self.healthKitStatus), Location: \(self.locationStatus)")
        }
    }

    /// Observe permission status changes from permission manager
    private func observePermissionChanges() {
        // Observe HealthKit permission changes
        NotificationCenter.default.addObserver(
            forName: .healthKitPermissionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.healthKitStatus = self?.permissionManager.healthKitPermissionStatus ?? .notDetermined
            }
        }

        // Observe location permission changes
        NotificationCenter.default.addObserver(
            forName: .locationPermissionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.locationStatus = self?.permissionManager.locationPermissionStatus ?? .notDetermined
            }
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
        Double(currentPage) / 7.0
    }

    /// Whether user is on the final onboarding page
    var isOnFinalPage: Bool {
        currentPage == 7
    }

    /// Whether user can proceed to next page
    var canProceed: Bool {
        switch currentPage {
        case 0: return true  // Language selection page - always can proceed
        case 1: return true  // Welcome page - always can proceed
        case 2: return true  // Data sources page - always can proceed
        case 3: return true  // AI analysis page - always can proceed
        case 4: return true  // Daily plans page - always can proceed
        case 5: return true  // Progressive disclosure page - always can proceed
        case 6: return true  // HealthKit page - can skip
        case 7: return true  // Location page - final page
        default: return false
        }
    }

    /// Whether user should see progressive disclosure flow
    var shouldShowProgressiveDisclosure: Bool {
        currentDisclosureStage != .completion && !isOnboardingCompleted
    }

    /// Current disclosure progress as percentage
    var disclosureProgress: Double {
        let totalStages = DisclosureStage.allCases.count
        let currentIndex = DisclosureStage.allCases.firstIndex(of: currentDisclosureStage) ?? 0
        return Double(currentIndex) / Double(totalStages)
    }

    /// Personalized onboarding message based on disclosure level
    var personalizedOnboardingMessage: String {
        switch disclosureLevel {
        case .minimal:
            return "プライバシーを重視したシンプルな設定を行います"
        case .selective:
            return "お好みに合わせてカスタマイズできます"
        case .comprehensive:
            return "詳細な分析で最適な健康サポートを提供します"
        }
    }

    /// Whether to show detailed explanations for current user
    var shouldShowDetailedExplanations: Bool {
        return prefersDetailedExplanations || disclosureLevel == .comprehensive || !privacyConcerns.isEmpty
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let healthKitPermissionChanged = Notification.Name("HealthKitPermissionChanged")
    static let locationPermissionChanged = Notification.Name("LocationPermissionChanged")
    static let onboardingDidReset = Notification.Name("OnboardingDidResetNotification")
}
