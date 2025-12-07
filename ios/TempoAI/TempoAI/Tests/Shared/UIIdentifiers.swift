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
///
/// Note: OnboardingFlow identifiers moved to OnboardingUIIdentifiers.swift
/// Note: HomeView/AdviceView identifiers moved to HomeUIIdentifiers.swift
enum UIIdentifiers {

    // MARK: - ContentView (Main Tab Navigation)
    enum ContentView {
        static let todayTab: String = "Today"
        static let historyTab: String = "History"
        static let trendsTab: String = "Trends"
        static let profileTab: String = "Profile"
        static let tabView: String = "contentView.tabView"

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
