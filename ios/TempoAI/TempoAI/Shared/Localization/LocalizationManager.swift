//
//  LocalizationManager.swift
//  TempoAI
//
//  Created by Claude for Phase 0 on 2025-12-05.
//  Centralized localization management with SwiftUI integration
//

import Foundation
import SwiftUI
import Combine

/// Centralized localization manager for the TempoAI application
/// Manages language preferences and provides localized string access
/// Supports Japanese (default) and English languages
@MainActor
class LocalizationManager: ObservableObject {

    /// Shared singleton instance
    static let shared: LocalizationManager = LocalizationManager()

    /// Published property for reactive UI updates
    @Published var currentLanguage: SupportedLanguage

    /// Supported languages enumeration
    enum SupportedLanguage: String, CaseIterable, Identifiable {
        case japanese = "ja"
        case english = "en"
        case systemDefault = "system"

        var id: String { rawValue }

        /// Human-readable display name for UI
        var displayName: String {
            switch self {
            case .japanese:
                return "日本語"
            case .english:
                return "English"
            case .systemDefault:
                return NSLocalizedString("system_language", comment: "System Language")
            }
        }

        /// Native display name (in the language itself)
        var nativeDisplayName: String {
            switch self {
            case .japanese:
                return "日本語"
            case .english:
                return "English"
            case .systemDefault:
                return "System"
            }
        }
    }

    /// UserDefaults key for persisting language preference
    private static let userLanguageKey: String = "user_language_preference"

    /// Initialize with saved preference or system default
    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: Self.userLanguageKey),
            let language = SupportedLanguage(rawValue: savedLanguage)
        {
            self.currentLanguage = language
        } else {
            // Default to Japanese as specified in requirements
            self.currentLanguage = .japanese
        }
    }

    /// Set the current language and persist the preference
    /// - Parameter language: The language to set as current
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language

        // Persist the preference
        UserDefaults.standard.set(language.rawValue, forKey: Self.userLanguageKey)

        // Post notification for non-SwiftUI components if needed
        NotificationCenter.default.post(
            name: .languageDidChange,
            object: nil,
            userInfo: ["language": language]
        )
    }

    /// Get the effective language code (resolving system default)
    var effectiveLanguageCode: String {
        switch currentLanguage {
        case .systemDefault:
            // Use system locale, fallback to Japanese
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "ja"
            return ["ja", "en"].contains(systemLanguage) ? systemLanguage : "ja"
        case .japanese:
            return "ja"
        case .english:
            return "en"
        }
    }

    /// Check if current language is Japanese
    var isJapanese: Bool {
        effectiveLanguageCode == "ja"
    }

    /// Check if current language is English
    var isEnglish: Bool {
        effectiveLanguageCode == "en"
    }

    /// Get localized string for the given key
    /// - Parameter key: The localization key
    /// - Returns: Localized string for the current language
    func localizedString(for key: String) -> String {
        let languageCode = effectiveLanguageCode

        // Attempt to load from language-specific bundle
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

            // If localization is found (not equal to key), return it
            if localizedString != key {
                return localizedString
            }
        }

        // Fallback to main bundle
        return NSLocalizedString(key, comment: "")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when language preference changes
    static let languageDidChange = Notification.Name("LanguageDidChangeNotification")
}

// MARK: - String Extension

extension String {
    /// Convenience property for localized strings
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }

    /// Get localized string with specific language override
    /// - Parameter language: The language to use for localization
    /// - Returns: Localized string in the specified language
    func localized(in language: LocalizationManager.SupportedLanguage) -> String {
        let languageCode: String

        switch language {
        case .systemDefault:
            languageCode = Locale.current.language.languageCode?.identifier ?? "ja"
        case .japanese:
            languageCode = "ja"
        case .english:
            languageCode = "en"
        }

        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
            if localizedString != self {
                return localizedString
            }
        }

        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - SwiftUI Environment Integration

/// Environment key for LocalizationManager
struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue: LocalizationManager = LocalizationManager.shared
}

extension EnvironmentValues {
    /// Environment value for accessing LocalizationManager
    var localizationManager: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}
