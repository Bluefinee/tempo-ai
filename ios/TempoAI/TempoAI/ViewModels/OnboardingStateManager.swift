import Combine
import Foundation

// MARK: - Onboarding State Manager

class OnboardingStateManager: ObservableObject {

    // MARK: - Published Properties
    @Published var currentPage: Int = 0
    @Published var selectedLanguage: AppLanguage = .english
    @Published var healthKitStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private struct UserDefaultsKeys {
        static let currentPage = "onboarding_current_page"
        static let selectedLanguage = "onboarding_selected_language"
        static let healthKitStatus = "onboarding_healthkit_status"
        static let locationStatus = "onboarding_location_status"
        static let isOnboardingCompleted = "onboarding_completed"
        static let lastCompletedVersion = "onboarding_last_completed_version"
    }

    // MARK: - Initialization
    init() {
        loadOnboardingState()
        observePermissionChanges()
    }

    // MARK: - Public Methods

    func trackOnboardingStart() {
        let event = AnalyticsEvent(name: "onboarding_started", parameters: [:])
        AnalyticsManager.shared.track(event)
    }

    func nextPage() {
        if currentPage < OnboardingPage.allCases.count - 1 {
            currentPage += 1
            saveCurrentPage()
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            saveCurrentPage()
        }
    }

    func goToPage(_ page: Int) {
        if page >= 0 && page < OnboardingPage.allCases.count {
            currentPage = page
            saveCurrentPage()
        }
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: UserDefaultsKeys.selectedLanguage)

        // Update app language
        LocalizationManager.shared.setLanguage(language)

        let event = AnalyticsEvent(
            name: "onboarding_language_selected",
            parameters: ["language": language.rawValue]
        )
        AnalyticsManager.shared.track(event)
    }

    func completeOnboarding() {
        isOnboardingCompleted = true
        userDefaults.set(true, forKey: UserDefaultsKeys.isOnboardingCompleted)

        // Save the app version when onboarding was completed
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        userDefaults.set(currentVersion, forKey: UserDefaultsKeys.lastCompletedVersion)

        // Track completion
        trackOnboardingCompletion()

        // Post notification
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    func resetOnboarding() {
        // Reset state
        currentPage = 0
        selectedLanguage = .english
        healthKitStatus = .notRequested
        locationStatus = .notRequested
        isOnboardingCompleted = false

        // Clear UserDefaults
        let keysToRemove = [
            UserDefaultsKeys.currentPage,
            UserDefaultsKeys.selectedLanguage,
            UserDefaultsKeys.healthKitStatus,
            UserDefaultsKeys.locationStatus,
            UserDefaultsKeys.isOnboardingCompleted,
            UserDefaultsKeys.lastCompletedVersion,
        ]

        for key in keysToRemove {
            userDefaults.removeObject(forKey: key)
        }

        // Reset progressive disclosure
        let progressiveDisclosureKeys = [
            "onboarding_disclosure_level",
            "onboarding_explained_categories",
            "onboarding_privacy_concerns",
            "onboarding_detailed_explanations",
            "onboarding_disclosure_stage",
        ]

        for key in progressiveDisclosureKeys {
            userDefaults.removeObject(forKey: key)
        }

        let event = AnalyticsEvent(name: "onboarding_reset", parameters: [:])
        AnalyticsManager.shared.track(event)
    }

    func shouldShowOnboarding() -> Bool {
        // Check if onboarding was completed for the current app version
        guard isOnboardingCompleted else { return true }

        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let lastCompletedVersion = userDefaults.string(forKey: UserDefaultsKeys.lastCompletedVersion) ?? "0.0"

        // Show onboarding if app version has changed significantly
        return shouldShowOnboardingForVersion(current: currentVersion, lastCompleted: lastCompletedVersion)
    }

    // MARK: - Computed Properties

    var allPermissionsGranted: Bool {
        return healthKitStatus == .authorized && locationStatus == .authorized
    }

    var anyPermissionsGranted: Bool {
        return healthKitStatus == .authorized || locationStatus == .authorized
    }

    var onboardingProgress: Double {
        return Double(currentPage + 1) / Double(OnboardingPage.allCases.count)
    }

    var isOnFinalPage: Bool {
        return currentPage == OnboardingPage.allCases.count - 1
    }

    var canProceed: Bool {
        let currentOnboardingPage = OnboardingPage.allCases[safe: currentPage]

        switch currentOnboardingPage {
        case .welcome, .language:
            return true
        case .healthKitPermission:
            return healthKitStatus != .notRequested
        case .locationPermission:
            return locationStatus != .notRequested
        case .completion:
            return anyPermissionsGranted
        case .none:
            return false
        }
    }

    // MARK: - Permission Updates

    func updateHealthKitStatus(_ status: PermissionStatus) {
        healthKitStatus = status
        userDefaults.set(status.rawValue, forKey: UserDefaultsKeys.healthKitStatus)

        let event = AnalyticsEvent(
            name: "onboarding_healthkit_permission",
            parameters: ["status": status.rawValue]
        )
        AnalyticsManager.shared.track(event)
    }

    func updateLocationStatus(_ status: PermissionStatus) {
        locationStatus = status
        userDefaults.set(status.rawValue, forKey: UserDefaultsKeys.locationStatus)

        let event = AnalyticsEvent(
            name: "onboarding_location_permission",
            parameters: ["status": status.rawValue]
        )
        AnalyticsManager.shared.track(event)
    }

    // MARK: - Private Methods

    private func loadOnboardingState() {
        // Load current page
        currentPage = userDefaults.integer(forKey: UserDefaultsKeys.currentPage)

        // Load selected language
        if let languageRaw = userDefaults.string(forKey: UserDefaultsKeys.selectedLanguage),
            let language = AppLanguage(rawValue: languageRaw)
        {
            selectedLanguage = language
        }

        // Load permission statuses
        if let healthStatusRaw = userDefaults.string(forKey: UserDefaultsKeys.healthKitStatus),
            let healthStatus = PermissionStatus(rawValue: healthStatusRaw)
        {
            healthKitStatus = healthStatus
        }

        if let locationStatusRaw = userDefaults.string(forKey: UserDefaultsKeys.locationStatus),
            let locStatus = PermissionStatus(rawValue: locationStatusRaw)
        {
            locationStatus = locStatus
        }

        // Load completion status
        isOnboardingCompleted = userDefaults.bool(forKey: UserDefaultsKeys.isOnboardingCompleted)
    }

    private func saveCurrentPage() {
        userDefaults.set(currentPage, forKey: UserDefaultsKeys.currentPage)
    }

    private func observePermissionChanges() {
        // Observe permission status changes from PermissionManager
        NotificationCenter.default.publisher(for: .permissionStatusChanged)
            .sink { [weak self] notification in
                guard let self = self,
                    let userInfo = notification.userInfo,
                    let permissionType = userInfo["type"] as? String,
                    let statusRaw = userInfo["status"] as? String,
                    let status = PermissionStatus(rawValue: statusRaw)
                else { return }

                switch permissionType {
                case "healthKit":
                    self.updateHealthKitStatus(status)
                case "location":
                    self.updateLocationStatus(status)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func trackOnboardingCompletion() {
        let event = AnalyticsEvent(
            name: "onboarding_completed",
            parameters: [
                "total_pages": OnboardingPage.allCases.count,
                "permissions_granted": [
                    "healthKit": healthKitStatus.rawValue,
                    "location": locationStatus.rawValue,
                ],
                "language": selectedLanguage.rawValue,
                "completion_time": Date().timeIntervalSince1970,
            ]
        )
        AnalyticsManager.shared.track(event)
    }

    private func shouldShowOnboardingForVersion(current: String, lastCompleted: String) -> Bool {
        let currentComponents = current.components(separatedBy: ".").compactMap { Int($0) }
        let lastComponents = lastCompleted.components(separatedBy: ".").compactMap { Int($0) }

        guard currentComponents.count >= 2 && lastComponents.count >= 2 else { return true }

        // Major version change
        if currentComponents[0] > lastComponents[0] {
            return true
        }

        // Minor version change
        if currentComponents[0] == lastComponents[0] && currentComponents[1] > lastComponents[1] {
            return true
        }

        return false
    }
}

// MARK: - Onboarding Page Enum

enum OnboardingPage: CaseIterable {
    case welcome
    case language
    case healthKitPermission
    case locationPermission
    case completion
}

// MARK: - Array Extension for Safe Access

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
    static let permissionStatusChanged = Notification.Name("permissionStatusChanged")
}
