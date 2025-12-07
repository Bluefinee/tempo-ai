//
//  UIIdentifiers.swift
//  TempoAI
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Accessibility identifiers for UI automation testing
//

import Foundation

/// Centralized accessibility identifiers for UI testing
/// This enum provides a structured approach to accessibility identifiers
/// that can be shared between the main app and UI test targets
enum UIIdentifiers {

    // MARK: - ContentView (Main Tab Navigation)
    enum ContentView {
        static let todayTab: String = "Today"
        static let historyTab: String = "History"
        static let trendsTab: String = "Trends"
        static let profileTab: String = "Profile"
        static let tabView: String = "contentView.tabView"

    }

    // MARK: - HomeView (Today Tab)
    enum HomeView {
        static let navigationTitle: String = "homeView.navigation.title"
        static let greetingText: String = "homeView.greeting.text"
        static let settingsButton: String = "homeView.settings.button"
        static let subtitleText: String = "homeView.subtitle.text"
        static let scrollView: String = "homeView.scrollView"
        static let headerSection: String = "homeView.header.section"
        static let refreshControl: String = "homeView.refresh.control"
        static let mockDataBanner: String = "homeView.mockData.banner"
        static let mockDataIcon: String = "homeView.mockData.icon"
        static let mockDataText: String = "homeView.mockData.text"

        /// Helper function for dynamic greeting identifiers
        /// - Parameter timeOfDay: The time of day (e.g., "morning", "afternoon")
        /// - Returns: A unique greeting identifier string
        static func greetingText(for timeOfDay: String) -> String {
            let sanitizedTimeOfDay = sanitizeInput(timeOfDay)
            return "homeView.greeting.\(sanitizedTimeOfDay)"
        }
    }

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
            return "onboarding.permissionStatus.\(sanitizeInput(permission))"
        }
    }

    // MARK: - HomeViewComponents (Loading, Error, Empty States)
    enum HomeViewComponents {
        // Loading View
        static let loadingView: String = "homeViewComponents.loading.view"
        static let loadingText: String = "homeViewComponents.loading.text"
        static let loadingSpinner: String = "homeViewComponents.loading.spinner"

        // Error View
        static let errorView: String = "homeViewComponents.error.view"
        static let errorIcon: String = "homeViewComponents.error.icon"
        static let errorTitle: String = "homeViewComponents.error.title"
        static let errorMessage: String = "homeViewComponents.error.message"
        static let errorRetryButton: String = "homeViewComponents.error.retry.button"

        // Empty State View
        static let emptyStateView: String = "homeViewComponents.emptyState.view"
        static let emptyStateIcon: String = "homeViewComponents.emptyState.icon"
        static let emptyStateTitle: String = "homeViewComponents.emptyState.title"
        static let emptyStateMessage: String = "homeViewComponents.emptyState.message"
        static let emptyStateActionButton: String = "homeViewComponents.emptyState.action.button"

        // Advice Card Component
        static let adviceCard: String = "homeViewComponents.advice.card"
        static let adviceCardContent: String = "homeViewComponents.advice.card.content"

        /// Helper function for dynamic error messages
        /// - Parameter errorType: The type of error (e.g., "network", "server")
        /// - Returns: A unique error message identifier string
        static func errorMessage(for errorType: String) -> String {
            let sanitizedErrorType = sanitizeInput(errorType)
            return "homeViewComponents.error.message.\(sanitizedErrorType)"
        }
    }

    // MARK: - AdviceView (Health Advice Display)
    enum AdviceView {
        static let mainView: String = "adviceView.main.view"
        static let scrollView: String = "adviceView.scrollView"

        // Theme Summary Card
        static let themeSummaryCard: String = "adviceView.themeSummary.card"
        static let themeSummaryIcon: String = "adviceView.themeSummary.icon"
        static let themeSummaryTitle: String = "adviceView.themeSummary.title"
        static let themeSummaryContent: String = "adviceView.themeSummary.content"

        // Weather Card
        static let weatherCard: String = "adviceView.weather.card"
        static let weatherIcon: String = "adviceView.weather.icon"
        static let weatherTitle: String = "adviceView.weather.title"
        static let weatherTemperature: String = "adviceView.weather.temperature"
        static let weatherCondition: String = "adviceView.weather.condition"
        static let weatherAdvice: String = "adviceView.weather.advice"

        // Meals Section
        static let mealCardsSection: String = "adviceView.meals.section"
        static let mealsTitle: String = "adviceView.meals.title"

        // Individual Meal Cards
        static let breakfastCard: String = "adviceView.meal.breakfast.card"
        static let lunchCard: String = "adviceView.meal.lunch.card"
        static let dinnerCard: String = "adviceView.meal.dinner.card"
        static let snackCard: String = "adviceView.meal.snack.card"

        // Exercise Card
        static let exerciseCard: String = "adviceView.exercise.card"
        static let exerciseIcon: String = "adviceView.exercise.icon"
        static let exerciseTitle: String = "adviceView.exercise.title"
        static let exerciseType: String = "adviceView.exercise.type"
        static let exerciseDuration: String = "adviceView.exercise.duration"
        static let exerciseAdvice: String = "adviceView.exercise.advice"

        // Sleep Card
        static let sleepCard: String = "adviceView.sleep.card"
        static let sleepIcon: String = "adviceView.sleep.icon"
        static let sleepTitle: String = "adviceView.sleep.title"
        static let sleepBedtime: String = "adviceView.sleep.bedtime"
        static let sleepWakeTime: String = "adviceView.sleep.wakeTime"
        static let sleepAdvice: String = "adviceView.sleep.advice"

        // Breathing Card
        static let breathingCard: String = "adviceView.breathing.card"
        static let breathingIcon: String = "adviceView.breathing.icon"
        static let breathingTitle: String = "adviceView.breathing.title"
        static let breathingDuration: String = "adviceView.breathing.duration"
        static let breathingAdvice: String = "adviceView.breathing.advice"
        static let breathingStartButton: String = "adviceView.breathing.start.button"

        /// Helper functions for dynamic meal card identifiers

        /// Generates meal card identifier
        /// - Parameter mealType: The type of meal (e.g., "breakfast", "lunch")
        /// - Returns: A unique meal card identifier string
        static func mealCard(for mealType: String) -> String {
            let sanitizedMealType = sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).card"
        }

        /// Generates meal title identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal title identifier string
        static func mealTitle(for mealType: String) -> String {
            let sanitizedMealType = sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).title"
        }

        /// Generates meal advice identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal advice identifier string
        static func mealAdvice(for mealType: String) -> String {
            let sanitizedMealType = sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).advice"
        }
    }

    // MARK: - PermissionsView (Authorization Management)
    enum PermissionsView {
        static let mainView: String = "permissionsView.main.view"
        static let navigationTitle: String = "permissionsView.navigation.title"
        static let scrollView: String = "permissionsView.scrollView"
        static let headerTitle: String = "permissionsView.header.title"
        static let headerSubtitle: String = "permissionsView.header.subtitle"
        static let permissionsList: String = "permissionsView.permissions.list"
        static let dismissButton: String = "permissionsView.dismiss.button"
        static let continueButton: String = "permissionsView.continue.button"

        // Permission Rows
        static let healthKitRow: String = "permissionsView.healthKit.row"
        static let healthKitIcon: String = "permissionsView.healthKit.icon"
        static let healthKitTitle: String = "permissionsView.healthKit.title"
        static let healthKitDescription: String = "permissionsView.healthKit.description"
        static let healthKitStatus: String = "permissionsView.healthKit.status"
        static let healthKitButton: String = "permissionsView.healthKit.button"

        static let locationRow: String = "permissionsView.location.row"
        static let locationIcon: String = "permissionsView.location.icon"
        static let locationTitle: String = "permissionsView.location.title"
        static let locationDescription: String = "permissionsView.location.description"
        static let locationStatus: String = "permissionsView.location.status"
        static let locationButton: String = "permissionsView.location.button"

        /// Helper functions for permission-related identifiers

        /// Generates permission status identifier
        /// - Parameter permissionType: The type of permission (e.g., "HealthKit", "Location")
        /// - Returns: A unique permission status identifier string
        static func permissionStatus(for permissionType: String) -> String {
            let sanitizedType = sanitizeInput(permissionType)
            return "permissionsView.\(sanitizedType).status"
        }

        /// Generates permission button identifier
        /// - Parameter permissionType: The type of permission
        /// - Returns: A unique permission button identifier string
        static func permissionButton(for permissionType: String) -> String {
            let sanitizedType = sanitizeInput(permissionType)
            return "permissionsView.\(sanitizedType).button"
        }
    }

    // MARK: - PlaceholderView (Future Features)
    enum PlaceholderView {
        static let mainView: String = "placeholderView.main.view"
        static let icon: String = "placeholderView.icon"
        static let title: String = "placeholderView.title"
        static let message: String = "placeholderView.message"

        /// Helper function for different placeholder types
        /// - Parameter feature: The feature name (e.g., "history", "trends")
        /// - Returns: A unique placeholder identifier string
        static func placeholder(for feature: String) -> String {
            let sanitizedFeature = sanitizeInput(feature)
            return "placeholderView.\(sanitizedFeature)"
        }
    }

    // MARK: - ProfileView (Profile Tab)
    enum ProfileView {
        static let mainView: String = "profileView.main.view"
        static let navigationTitle: String = "profileView.navigation.title"

        /// Helper function for profile rows
        /// - Parameter rowType: The type of profile row (e.g., "age", "gender")
        /// - Returns: A unique profile row identifier string
        static func profileRow(for rowType: String) -> String {
            let sanitizedRowType = sanitizeInput(rowType)
            return "profileView.row.\(sanitizedRowType)"
        }
    }

    // MARK: - Common Elements
    enum Common {
        static let navigationBackButton: String = "common.navigation.back.button"
        static let closeButton: String = "common.close.button"
        static let doneButton: String = "common.done.button"
        static let cancelButton: String = "common.cancel.button"
        static let saveButton: String = "common.save.button"
        static let editButton: String = "common.edit.button"
        static let deleteButton: String = "common.delete.button"

        // Loading states
        static let loadingIndicator: String = "common.loading.indicator"
        static let refreshButton: String = "common.refresh.button"

        // Alert elements
        static let alertView: String = "common.alert.view"
        static let alertTitle: String = "common.alert.title"
        static let alertMessage: String = "common.alert.message"
        static let alertOKButton: String = "common.alert.ok.button"
        static let alertCancelButton: String = "common.alert.cancel.button"
    }

    // MARK: - Test Environment Identifiers
    enum TestEnvironment {
        static let mockDataEnabled: String = "testEnvironment.mockData.enabled"
        static let testModeIndicator: String = "testEnvironment.testMode.indicator"

        /// Helper function for test state indicators
        /// - Parameter state: The test state (e.g., "loading", "error")
        /// - Returns: A unique test state identifier string
        static func testState(for state: String) -> String {
            let sanitizedState = sanitizeInput(state)
            return "testEnvironment.state.\(sanitizedState)"
        }
    }
}

// MARK: - Helper Extensions for UI Testing

extension UIIdentifiers {

    /// Generates a unique identifier for list items
    /// - Parameters:
    ///   - prefix: The base identifier prefix
    ///   - index: The index of the item in the list
    /// - Returns: A unique identifier string
    static func listItem(prefix: String, index: Int) -> String {
        let sanitizedPrefix = sanitizeInput(prefix)
        return "\(sanitizedPrefix).item.\(index)"
    }

    /// Generates a unique identifier for cards with dynamic content
    /// - Parameters:
    ///   - cardType: The type of card
    ///   - identifier: A unique identifier for the content
    /// - Returns: A unique identifier string
    static func dynamicCard(cardType: String, identifier: String) -> String {
        let sanitizedCardType = sanitizeInput(cardType)
        let sanitizedIdentifier = sanitizeInput(identifier)
        return "\(sanitizedCardType).card.\(sanitizedIdentifier)"
    }

    /// Generates a state-dependent identifier
    /// - Parameters:
    ///   - baseIdentifier: The base identifier
    ///   - state: The current state
    /// - Returns: A state-specific identifier
    static func stateDependentIdentifier(_ baseIdentifier: String, state: String) -> String {
        let sanitizedState = sanitizeInput(state)
        return "\(baseIdentifier).\(sanitizedState)"
    }

    /// Sanitizes input strings for consistent identifier generation
    /// - Parameter input: The input string to sanitize
    /// - Returns: A sanitized string suitable for use in identifiers
    private static func sanitizeInput(_ input: String) -> String {
        return input.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }
}
