//
//  OnboardingUIIdentifiers.swift
//  TempoAI
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Accessibility identifiers for onboarding flow UI automation testing
//

import Foundation

extension UIIdentifiers {
    // MARK: - OnboardingFlow
    enum OnboardingFlow {
        static let mainContainer = "onboarding.main.container"
        static let tabView = "onboarding.tabView"
        static let pageIndicator = "onboarding.pageIndicator"

        // Page 0: Language Selection
        static let languageSelectionPage = "onboarding.languageSelection.page"
        static let languageSelectionTitle = "onboarding.languageSelection.title"
        static let languageSelectionIcon = "onboarding.languageSelection.icon"
        static let japaneseButton = "onboarding.languageSelection.japaneseButton"
        static let englishButton = "onboarding.languageSelection.englishButton"

        // Page 1: Welcome Page
        static let welcomePage = "onboarding.welcome.page"
        static let welcomeIcon = "onboarding.welcome.icon"
        static let welcomeTitle = "onboarding.welcome.title"
        static let welcomeDescription = "onboarding.welcome.description"
        static let welcomeNextButton = "onboarding.welcome.nextButton"

        // Page 2: Data Sources
        static let dataSourcesPage = "onboarding.dataSources.page"
        static let dataSourcesIcon = "onboarding.dataSources.icon"
        static let dataSourcesTitle = "onboarding.dataSources.title"
        static let dataSourcesDescription = "onboarding.dataSources.description"
        static let dataSourcesNextButton = "onboarding.dataSources.nextButton"

        // Page 3: AI Analysis
        static let aiAnalysisPage = "onboarding.aiAnalysis.page"
        static let aiAnalysisIcon = "onboarding.aiAnalysis.icon"
        static let aiAnalysisTitle = "onboarding.aiAnalysis.title"
        static let aiAnalysisDescription = "onboarding.aiAnalysis.description"
        static let aiAnalysisNextButton = "onboarding.aiAnalysis.nextButton"

        // Page 4: Daily Plans
        static let dailyPlansPage = "onboarding.dailyPlans.page"
        static let dailyPlansIcon = "onboarding.dailyPlans.icon"
        static let dailyPlansTitle = "onboarding.dailyPlans.title"
        static let dailyPlansDescription = "onboarding.dailyPlans.description"
        static let dailyPlansNextButton = "onboarding.dailyPlans.nextButton"

        // Page 5: HealthKit Permission
        static let healthKitPage = "onboarding.healthKit.page"
        static let healthKitIcon = "onboarding.healthKit.icon"
        static let healthKitTitle = "onboarding.healthKit.title"
        static let healthKitDescription = "onboarding.healthKit.description"
        static let healthKitAllowButton = "onboarding.healthKit.allowButton"
        static let healthKitSkipButton = "onboarding.healthKit.skipButton"
        static let healthKitNextButton = "onboarding.healthKit.nextButton"
        static let healthKitGrantedStatus = "onboarding.healthKit.grantedStatus"

        // Page 6: Location Permission & Completion
        static let locationPage = "onboarding.location.page"
        static let locationIcon = "onboarding.location.icon"
        static let locationTitle = "onboarding.location.title"
        static let locationDescription = "onboarding.location.description"
        static let locationAllowButton = "onboarding.location.allowButton"
        static let locationSkipButton = "onboarding.location.skipButton"
        static let locationCompleteButton = "onboarding.location.completeButton"
        static let locationGrantedStatus = "onboarding.location.grantedStatus"

        // Navigation Controls
        static let backButton = "onboarding.navigation.backButton"
        static let nextButton = "onboarding.navigation.nextButton"
        static let skipButton = "onboarding.navigation.skipButton"

        // Permission Status
        static func permissionStatusRow(for permission: String) -> String {
            return "onboarding.permissionStatus.\(UIIdentifiers.sanitizeInput(permission))"
        }
    }
}
