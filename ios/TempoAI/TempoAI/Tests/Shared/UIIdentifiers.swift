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
        static let todayTab = "contentView.tab.today"
        static let historyTab = "contentView.tab.history"
        static let trendsTab = "contentView.tab.trends"
        static let profileTab = "contentView.tab.profile"
        static let tabView = "contentView.tabView"
    }
    
    // MARK: - HomeView (Today Tab)
    enum HomeView {
        static let navigationTitle = "homeView.navigation.title"
        static let greetingText = "homeView.greeting.text"
        static let settingsButton = "homeView.settings.button"
        static let subtitleText = "homeView.subtitle.text"
        static let scrollView = "homeView.scrollView"
        static let headerSection = "homeView.header.section"
        static let refreshControl = "homeView.refresh.control"
        static let mockDataBanner = "homeView.mockData.banner"
        static let mockDataIcon = "homeView.mockData.icon"
        static let mockDataText = "homeView.mockData.text"
        
        /// Helper function for dynamic greeting identifiers
        /// - Parameter timeOfDay: The time of day (e.g., "morning", "afternoon")
        /// - Returns: A unique greeting identifier string
        static func greetingText(for timeOfDay: String) -> String {
            let sanitizedTimeOfDay = timeOfDay.lowercased().replacingOccurrences(of: " ", with: "")
            return "homeView.greeting.\(sanitizedTimeOfDay)"
        }
    }
    
    // MARK: - HomeViewComponents (Loading, Error, Empty States)
    enum HomeViewComponents {
        // Loading View
        static let loadingView = "homeViewComponents.loading.view"
        static let loadingText = "homeViewComponents.loading.text"
        static let loadingSpinner = "homeViewComponents.loading.spinner"
        
        // Error View
        static let errorView = "homeViewComponents.error.view"
        static let errorIcon = "homeViewComponents.error.icon"
        static let errorTitle = "homeViewComponents.error.title"
        static let errorMessage = "homeViewComponents.error.message"
        static let errorRetryButton = "homeViewComponents.error.retry.button"
        
        // Empty State View
        static let emptyStateView = "homeViewComponents.emptyState.view"
        static let emptyStateIcon = "homeViewComponents.emptyState.icon"
        static let emptyStateTitle = "homeViewComponents.emptyState.title"
        static let emptyStateMessage = "homeViewComponents.emptyState.message"
        static let emptyStateActionButton = "homeViewComponents.emptyState.action.button"
        
        // Advice Card Component
        static let adviceCard = "homeViewComponents.advice.card"
        static let adviceCardContent = "homeViewComponents.advice.card.content"
        
        /// Helper function for dynamic error messages
        /// - Parameter errorType: The type of error (e.g., "network", "server")
        /// - Returns: A unique error message identifier string
        static func errorMessage(for errorType: String) -> String {
            let sanitizedErrorType = errorType.lowercased().replacingOccurrences(of: " ", with: "")
            return "homeViewComponents.error.message.\(sanitizedErrorType)"
        }
    }
    
    // MARK: - AdviceView (Health Advice Display)
    enum AdviceView {
        static let mainView = "adviceView.main.view"
        static let scrollView = "adviceView.scrollView"
        
        // Theme Summary Card
        static let themeSummaryCard = "adviceView.themeSummary.card"
        static let themeSummaryIcon = "adviceView.themeSummary.icon"
        static let themeSummaryTitle = "adviceView.themeSummary.title"
        static let themeSummaryContent = "adviceView.themeSummary.content"
        
        // Weather Card
        static let weatherCard = "adviceView.weather.card"
        static let weatherIcon = "adviceView.weather.icon"
        static let weatherTitle = "adviceView.weather.title"
        static let weatherTemperature = "adviceView.weather.temperature"
        static let weatherCondition = "adviceView.weather.condition"
        static let weatherAdvice = "adviceView.weather.advice"
        
        // Meals Section
        static let mealCardsSection = "adviceView.meals.section"
        static let mealsTitle = "adviceView.meals.title"
        
        // Individual Meal Cards
        static let breakfastCard = "adviceView.meal.breakfast.card"
        static let lunchCard = "adviceView.meal.lunch.card"
        static let dinnerCard = "adviceView.meal.dinner.card"
        static let snackCard = "adviceView.meal.snack.card"
        
        // Exercise Card
        static let exerciseCard = "adviceView.exercise.card"
        static let exerciseIcon = "adviceView.exercise.icon"
        static let exerciseTitle = "adviceView.exercise.title"
        static let exerciseType = "adviceView.exercise.type"
        static let exerciseDuration = "adviceView.exercise.duration"
        static let exerciseAdvice = "adviceView.exercise.advice"
        
        // Sleep Card
        static let sleepCard = "adviceView.sleep.card"
        static let sleepIcon = "adviceView.sleep.icon"
        static let sleepTitle = "adviceView.sleep.title"
        static let sleepBedtime = "adviceView.sleep.bedtime"
        static let sleepWakeTime = "adviceView.sleep.wakeTime"
        static let sleepAdvice = "adviceView.sleep.advice"
        
        // Breathing Card
        static let breathingCard = "adviceView.breathing.card"
        static let breathingIcon = "adviceView.breathing.icon"
        static let breathingTitle = "adviceView.breathing.title"
        static let breathingDuration = "adviceView.breathing.duration"
        static let breathingAdvice = "adviceView.breathing.advice"
        static let breathingStartButton = "adviceView.breathing.start.button"
        
        /// Helper functions for dynamic meal card identifiers
        
        /// Generates meal card identifier
        /// - Parameter mealType: The type of meal (e.g., "breakfast", "lunch")
        /// - Returns: A unique meal card identifier string
        static func mealCard(for mealType: String) -> String {
            let sanitizedMealType = mealType.lowercased().replacingOccurrences(of: " ", with: "")
            return "adviceView.meal.\(sanitizedMealType).card"
        }
        
        /// Generates meal title identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal title identifier string
        static func mealTitle(for mealType: String) -> String {
            let sanitizedMealType = mealType.lowercased().replacingOccurrences(of: " ", with: "")
            return "adviceView.meal.\(sanitizedMealType).title"
        }
        
        /// Generates meal advice identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal advice identifier string
        static func mealAdvice(for mealType: String) -> String {
            let sanitizedMealType = mealType.lowercased().replacingOccurrences(of: " ", with: "")
            return "adviceView.meal.\(sanitizedMealType).advice"
        }
    }
    
    // MARK: - PermissionsView (Authorization Management)
    enum PermissionsView {
        static let mainView = "permissionsView.main.view"
        static let navigationTitle = "permissionsView.navigation.title"
        static let scrollView = "permissionsView.scrollView"
        static let headerTitle = "permissionsView.header.title"
        static let headerSubtitle = "permissionsView.header.subtitle"
        static let permissionsList = "permissionsView.permissions.list"
        static let dismissButton = "permissionsView.dismiss.button"
        static let continueButton = "permissionsView.continue.button"
        
        // Permission Rows
        static let healthKitRow = "permissionsView.healthKit.row"
        static let healthKitIcon = "permissionsView.healthKit.icon"
        static let healthKitTitle = "permissionsView.healthKit.title"
        static let healthKitDescription = "permissionsView.healthKit.description"
        static let healthKitStatus = "permissionsView.healthKit.status"
        static let healthKitButton = "permissionsView.healthKit.button"
        
        static let locationRow = "permissionsView.location.row"
        static let locationIcon = "permissionsView.location.icon"
        static let locationTitle = "permissionsView.location.title"
        static let locationDescription = "permissionsView.location.description"
        static let locationStatus = "permissionsView.location.status"
        static let locationButton = "permissionsView.location.button"
        
        /// Helper functions for permission-related identifiers
        
        /// Generates permission status identifier
        /// - Parameter permissionType: The type of permission (e.g., "HealthKit", "Location")
        /// - Returns: A unique permission status identifier string
        static func permissionStatus(for permissionType: String) -> String {
            let sanitizedType = permissionType.lowercased().replacingOccurrences(of: " ", with: "")
            return "permissionsView.\(sanitizedType).status"
        }
        
        /// Generates permission button identifier
        /// - Parameter permissionType: The type of permission
        /// - Returns: A unique permission button identifier string
        static func permissionButton(for permissionType: String) -> String {
            let sanitizedType = permissionType.lowercased().replacingOccurrences(of: " ", with: "")
            return "permissionsView.\(sanitizedType).button"
        }
    }
    
    // MARK: - PlaceholderView (Future Features)
    enum PlaceholderView {
        static let mainView = "placeholderView.main.view"
        static let icon = "placeholderView.icon"
        static let title = "placeholderView.title"
        static let message = "placeholderView.message"
        
        /// Helper function for different placeholder types
        /// - Parameter feature: The feature name (e.g., "history", "trends")
        /// - Returns: A unique placeholder identifier string
        static func placeholder(for feature: String) -> String {
            let sanitizedFeature = feature.lowercased().replacingOccurrences(of: " ", with: "")
            return "placeholderView.\(sanitizedFeature)"
        }
    }
    
    // MARK: - ProfileView (Profile Tab)
    enum ProfileView {
        static let mainView = "profileView.main.view"
        static let navigationTitle = "profileView.navigation.title"
        
        /// Helper function for profile rows
        /// - Parameter rowType: The type of profile row (e.g., "age", "gender")
        /// - Returns: A unique profile row identifier string
        static func profileRow(for rowType: String) -> String {
            let sanitizedRowType = rowType.lowercased().replacingOccurrences(of: " ", with: "")
            return "profileView.row.\(sanitizedRowType)"
        }
    }
    
    // MARK: - Common Elements
    enum Common {
        static let navigationBackButton = "common.navigation.back.button"
        static let closeButton = "common.close.button"
        static let doneButton = "common.done.button"
        static let cancelButton = "common.cancel.button"
        static let saveButton = "common.save.button"
        static let editButton = "common.edit.button"
        static let deleteButton = "common.delete.button"
        
        // Loading states
        static let loadingIndicator = "common.loading.indicator"
        static let refreshButton = "common.refresh.button"
        
        // Alert elements
        static let alertView = "common.alert.view"
        static let alertTitle = "common.alert.title"
        static let alertMessage = "common.alert.message"
        static let alertOKButton = "common.alert.ok.button"
        static let alertCancelButton = "common.alert.cancel.button"
    }
    
    // MARK: - Test Environment Identifiers
    enum TestEnvironment {
        static let mockDataEnabled = "testEnvironment.mockData.enabled"
        static let testModeIndicator = "testEnvironment.testMode.indicator"
        
        /// Helper function for test state indicators
        /// - Parameter state: The test state (e.g., "loading", "error")
        /// - Returns: A unique test state identifier string
        static func testState(for state: String) -> String {
            let sanitizedState = state.lowercased().replacingOccurrences(of: " ", with: "")
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
        let sanitizedPrefix = prefix.lowercased().replacingOccurrences(of: " ", with: "")
        return "\(sanitizedPrefix).item.\(index)"
    }
    
    /// Generates a unique identifier for cards with dynamic content
    /// - Parameters:
    ///   - cardType: The type of card
    ///   - identifier: A unique identifier for the content
    /// - Returns: A unique identifier string
    static func dynamicCard(cardType: String, identifier: String) -> String {
        let sanitizedCardType = cardType.lowercased().replacingOccurrences(of: " ", with: "")
        let sanitizedIdentifier = identifier.lowercased().replacingOccurrences(of: " ", with: "")
        return "\(sanitizedCardType).card.\(sanitizedIdentifier)"
    }
    
    /// Generates a state-dependent identifier
    /// - Parameters:
    ///   - baseIdentifier: The base identifier
    ///   - state: The current state
    /// - Returns: A state-specific identifier
    static func stateDependentIdentifier(_ baseIdentifier: String, state: String) -> String {
        let sanitizedState = state.lowercased().replacingOccurrences(of: " ", with: "")
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