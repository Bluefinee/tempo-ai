import Combine
import Foundation

// MARK: - Onboarding Progressive Disclosure Helper

class OnboardingProgressiveDisclosure: ObservableObject {

    // MARK: - Published Properties
    @Published var disclosureLevel: ProgressiveDisclosureLevel = .basic
    @Published var explainedDataCategories: Set<String> = []
    @Published var privacyConcerns: [String] = []
    @Published var prefersDetailedExplanations: Bool = false
    @Published var currentDisclosureStage: DisclosureStage = .introduction

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard

    // MARK: - Constants
    private struct UserDefaultsKeys {
        static let disclosureLevel = "onboarding_disclosure_level"
        static let explainedCategories = "onboarding_explained_categories"
        static let privacyConcerns = "onboarding_privacy_concerns"
        static let prefersDetailedExplanations = "onboarding_detailed_explanations"
        static let currentDisclosureStage = "onboarding_disclosure_stage"
    }

    // MARK: - Initialization
    init() {
        loadProgressiveDisclosureState()
    }

    // MARK: - Public Methods

    func updateDisclosureLevel(_ level: ProgressiveDisclosureLevel) {
        disclosureLevel = level
        userDefaults.set(level.rawValue, forKey: UserDefaultsKeys.disclosureLevel)
        adjustDataCollectionStrategy(for: level)
    }

    func markDataCategoryExplained(_ category: String) {
        explainedDataCategories.insert(category)
        let categoriesArray = Array(explainedDataCategories)
        userDefaults.set(categoriesArray, forKey: UserDefaultsKeys.explainedCategories)
    }

    func recordPrivacyConcern(_ concern: String) {
        if !privacyConcerns.contains(concern) {
            privacyConcerns.append(concern)
            userDefaults.set(privacyConcerns, forKey: UserDefaultsKeys.privacyConcerns)
        }
        adaptFlowForPrivacyConcerns()
    }

    func setDetailedExplanationPreference(_ prefers: Bool) {
        prefersDetailedExplanations = prefers
        userDefaults.set(prefers, forKey: UserDefaultsKeys.prefersDetailedExplanations)
    }

    func advanceDisclosureStage() {
        switch currentDisclosureStage {
        case .introduction:
            currentDisclosureStage = .dataCategories
        case .dataCategories:
            currentDisclosureStage = .permissions
        case .permissions:
            currentDisclosureStage = .dataUsage
        case .dataUsage:
            currentDisclosureStage = .completion
        case .completion:
            break  // Stay at completion
        }
        userDefaults.set(currentDisclosureStage.rawValue, forKey: UserDefaultsKeys.currentDisclosureStage)
    }

    func getPersonalizedExplanation(for category: String) -> String {
        switch disclosureLevel {
        case .minimal:
            return "Basic health data for general wellness insights."
        case .basic:
            return "This data helps us provide personalized health recommendations."
        case .detailed:
            return "We analyze this data using medical guidelines to " +
                "provide evidence-based health insights and recommendations."
        }
    }

    func shouldShowDetailedPermissionExplanation(for permission: String) -> Bool {
        return prefersDetailedExplanations || privacyConcerns.contains("data_sharing") || disclosureLevel == .detailed
    }

    func getRecommendedSharingLevel() -> ProgressiveDisclosureLevel {
        if privacyConcerns.contains("data_privacy") || privacyConcerns.contains("third_party_sharing") {
            return .minimal
        } else if prefersDetailedExplanations {
            return .detailed
        } else {
            return .basic
        }
    }

    // MARK: - Computed Properties

    var shouldShowProgressiveDisclosure: Bool {
        return disclosureLevel == .detailed || !privacyConcerns.isEmpty
    }

    var disclosureProgress: Double {
        let totalStages = DisclosureStage.allCases.count
        let currentIndex = DisclosureStage.allCases.firstIndex(of: currentDisclosureStage) ?? 0
        return Double(currentIndex + 1) / Double(totalStages)
    }

    var personalizedOnboardingMessage: String {
        switch disclosureLevel {
        case .minimal:
            return "Quick setup with essential permissions only."
        case .basic:
            return "Let's set up your health companion."
        case .detailed:
            return "Complete health analysis setup with full transparency."
        }
    }

    var shouldShowDetailedExplanations: Bool {
        return prefersDetailedExplanations || disclosureLevel == .detailed
    }

    // MARK: - Private Methods

    private func adjustDataCollectionStrategy(for level: ProgressiveDisclosureLevel) {
        switch level {
        case .minimal:
            // Limit data collection to essentials
            NotificationCenter.default.post(
                name: .onboardingDataCollectionStrategy,
                object: ["strategy": "minimal"]
            )
        case .basic:
            // Standard data collection
            NotificationCenter.default.post(
                name: .onboardingDataCollectionStrategy,
                object: ["strategy": "standard"]
            )
        case .detailed:
            // Full data collection with transparency
            NotificationCenter.default.post(
                name: .onboardingDataCollectionStrategy,
                object: ["strategy": "comprehensive"]
            )
        }
    }

    private func adaptFlowForPrivacyConcerns() {
        if privacyConcerns.contains("data_sharing") {
            updateDisclosureLevel(.detailed)
        }

        if privacyConcerns.contains("third_party_access") {
            setDetailedExplanationPreference(true)
        }

        NotificationCenter.default.post(
            name: .onboardingFlowAdaptation,
            object: ["concerns": privacyConcerns]
        )
    }

    private func loadProgressiveDisclosureState() {
        // Load disclosure level
        if let levelRaw = userDefaults.object(forKey: UserDefaultsKeys.disclosureLevel) as? String,
            let level = ProgressiveDisclosureLevel(rawValue: levelRaw)
        {
            self.disclosureLevel = level
        }

        // Load explained categories
        if let categories = userDefaults.array(forKey: UserDefaultsKeys.explainedCategories) as? [String] {
            self.explainedDataCategories = Set(categories)
        }

        // Load privacy concerns
        if let concerns = userDefaults.array(forKey: UserDefaultsKeys.privacyConcerns) as? [String] {
            self.privacyConcerns = concerns
        }

        // Load detailed explanation preference
        if userDefaults.object(forKey: UserDefaultsKeys.prefersDetailedExplanations) != nil {
            self.prefersDetailedExplanations = userDefaults.bool(forKey: UserDefaultsKeys.prefersDetailedExplanations)
        }

        // Load current disclosure stage
        if let stageRaw = userDefaults.object(forKey: UserDefaultsKeys.currentDisclosureStage) as? String,
            let stage = DisclosureStage(rawValue: stageRaw)
        {
            self.currentDisclosureStage = stage
        }
    }

    // MARK: - Analytics Support

    func trackDisclosurePreference(_ preference: String, value: Any) {
        let event = AnalyticsEvent(
            name: "onboarding_disclosure_preference",
            parameters: [
                "preference": preference,
                "value": String(describing: value),
                "disclosure_level": disclosureLevel.rawValue,
                "stage": currentDisclosureStage.rawValue,
            ]
        )
        AnalyticsManager.shared.track(event)
    }

    func trackPrivacyConcernRaised(_ concern: String) {
        let event = AnalyticsEvent(
            name: "onboarding_privacy_concern",
            parameters: [
                "concern": concern,
                "total_concerns": privacyConcerns.count,
                "disclosure_level": disclosureLevel.rawValue,
            ]
        )
        AnalyticsManager.shared.track(event)
    }
}

// MARK: - Disclosure Stage Enum

enum DisclosureStage: String, CaseIterable {
    case introduction = "introduction"
    case dataCategories = "data_categories"
    case permissions = "permissions"
    case dataUsage = "data_usage"
    case completion = "completion"
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let onboardingDataCollectionStrategy = Notification.Name("onboardingDataCollectionStrategy")
    static let onboardingFlowAdaptation = Notification.Name("onboardingFlowAdaptation")
}
