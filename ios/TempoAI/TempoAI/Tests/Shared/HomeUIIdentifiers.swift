//
//  HomeUIIdentifiers.swift
//  TempoAI
//
//  Created by Claude for UI Testing on 2024-12-05.
//  Accessibility identifiers for home and advice views UI automation testing
//

import Foundation

extension UIIdentifiers {
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
            let sanitizedTimeOfDay = UIIdentifiers.sanitizeInput(timeOfDay)
            return "homeView.greeting.\(sanitizedTimeOfDay)"
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
            let sanitizedErrorType = UIIdentifiers.sanitizeInput(errorType)
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
            let sanitizedMealType = UIIdentifiers.sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).card"
        }

        /// Generates meal title identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal title identifier string
        static func mealTitle(for mealType: String) -> String {
            let sanitizedMealType = UIIdentifiers.sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).title"
        }

        /// Generates meal advice identifier
        /// - Parameter mealType: The type of meal
        /// - Returns: A unique meal advice identifier string
        static func mealAdvice(for mealType: String) -> String {
            let sanitizedMealType = UIIdentifiers.sanitizeInput(mealType)
            return "adviceView.meal.\(sanitizedMealType).advice"
        }
    }
}
