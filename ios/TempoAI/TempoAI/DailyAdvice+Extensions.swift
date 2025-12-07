//
//  DailyAdvice+Extensions.swift
//  TempoAI
//
//  Extensions for DailyAdvice model to support EnhancedAdviceCard compatibility
//

import Foundation
import SwiftUI

// MARK: - DailyAdvice Extensions

extension DailyAdvice {
    /// Check if this advice was created today (same calendar day)
    var isFromToday: Bool {
        Calendar.current.isDateInToday(createdAt)
    }

    /// Check if this advice was created on the specified date
    func isFrom(date: Date) -> Bool {
        Calendar.current.isDate(createdAt, inSameDayAs: date)
    }

    /// Get age of this advice in hours
    var ageInHours: Double {
        Date().timeIntervalSince(createdAt) / 3600
    }

    // MARK: - EnhancedAdviceCard Compatibility

    /// Category for advice card display
    var category: Category {
        .general  // Default category, can be made more sophisticated later
    }

    /// Title for display in advice card
    var title: String {
        theme
    }

    /// Detailed information for expanded view
    var details: [String] {
        // Convert summary to an array, split by sentences
        let sentences = summary.components(separatedBy: ". ").filter { !$0.isEmpty }
        return sentences.map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Tips array for display
    var tips: [String] {
        priorityActions
    }

    /// Weather impact information
    var weatherImpact: String? {
        // Extract weather information from weather considerations
        if !weatherConsiderations.opportunities.isEmpty {
            return weatherConsiderations.opportunities.first
        } else if !weatherConsiderations.warnings.isEmpty {
            return weatherConsiderations.warnings.first
        }
        return nil
    }
}

// MARK: - DailyAdvice Category

extension DailyAdvice {
    enum Category {
        case general
        case exercise
        case nutrition
        case sleep
        case mindfulness

        var icon: String {
            switch self {
            case .general: return "sparkles"
            case .exercise: return "figure.run"
            case .nutrition: return "leaf.fill"
            case .sleep: return "moon.stars.fill"
            case .mindfulness: return "brain.head.profile"
            }
        }

        var color: Color {
            switch self {
            case .general: return ColorPalette.info
            case .exercise: return ColorPalette.success
            case .nutrition: return ColorPalette.warning
            case .sleep: return ColorPalette.info
            case .mindfulness: return ColorPalette.info
            }
        }

        var rawValue: String {
            switch self {
            case .general: return "general"
            case .exercise: return "exercise"
            case .nutrition: return "nutrition"
            case .sleep: return "sleep"
            case .mindfulness: return "mindfulness"
            }
        }
    }
}
