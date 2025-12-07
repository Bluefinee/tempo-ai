import SwiftUI

// MARK: - Health Goal Types

enum HealthGoal: CaseIterable {
    case none, weightLoss, muscleGain, generalFitness, stressReduction, betterSleep, heartHealth

    var title: String {
        switch self {
        case .none: return ""
        case .weightLoss: return NSLocalizedString("goal_weight_loss", comment: "Weight Loss")
        case .muscleGain: return NSLocalizedString("goal_muscle_gain", comment: "Muscle Gain")
        case .generalFitness: return NSLocalizedString("goal_general_fitness", comment: "General Fitness")
        case .stressReduction: return NSLocalizedString("goal_stress_reduction", comment: "Stress Reduction")
        case .betterSleep: return NSLocalizedString("goal_better_sleep", comment: "Better Sleep")
        case .heartHealth: return NSLocalizedString("goal_heart_health", comment: "Heart Health")
        }
    }

    var icon: String {
        switch self {
        case .none: return ""
        case .weightLoss: return "scalemass"
        case .muscleGain: return "dumbbell"
        case .generalFitness: return "figure.run"
        case .stressReduction: return "leaf"
        case .betterSleep: return "bed.double"
        case .heartHealth: return "heart"
        }
    }

    var color: Color {
        switch self {
        case .none: return ColorPalette.gray300
        case .weightLoss: return ColorPalette.error
        case .muscleGain: return ColorPalette.success
        case .generalFitness: return ColorPalette.info
        case .stressReduction: return ColorPalette.warning
        case .betterSleep: return ColorPalette.gray700
        case .heartHealth: return Color.red
        }
    }
}

// MARK: - Activity Level Types

enum ActivityLevel: CaseIterable {
    case none, sedentary, lightlyActive, moderatelyActive, veryActive, extremelyActive

    var title: String {
        switch self {
        case .none: return ""
        case .sedentary: return NSLocalizedString("activity_sedentary", comment: "Sedentary")
        case .lightlyActive: return NSLocalizedString("activity_lightly_active", comment: "Lightly Active")
        case .moderatelyActive: return NSLocalizedString("activity_moderately_active", comment: "Moderately Active")
        case .veryActive: return NSLocalizedString("activity_very_active", comment: "Very Active")
        case .extremelyActive: return NSLocalizedString("activity_extremely_active", comment: "Extremely Active")
        }
    }

    var description: String {
        switch self {
        case .none: return ""
        case .sedentary: return NSLocalizedString("activity_sedentary_desc", comment: "Little to no exercise")
        case .lightlyActive:
            return NSLocalizedString("activity_lightly_active_desc", comment: "Light exercise 1-3 days/week")
        case .moderatelyActive:
            return NSLocalizedString("activity_moderately_active_desc", comment: "Moderate exercise 3-5 days/week")
        case .veryActive: return NSLocalizedString("activity_very_active_desc", comment: "Hard exercise 6-7 days/week")
        case .extremelyActive:
            return NSLocalizedString("activity_extremely_active_desc", comment: "Very hard exercise, physical job")
        }
    }

    var icon: String {
        switch self {
        case .none: return ""
        case .sedentary: return "figure.seated.side"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.run"
        case .veryActive: return "figure.strengthtraining.traditional"
        case .extremelyActive: return "bolt"
        }
    }

    var color: Color {
        switch self {
        case .none: return ColorPalette.gray300
        case .sedentary: return ColorPalette.gray500
        case .lightlyActive: return ColorPalette.warning.opacity(0.7)
        case .moderatelyActive: return ColorPalette.warning
        case .veryActive: return ColorPalette.success
        case .extremelyActive: return ColorPalette.error
        }
    }
}

// MARK: - Health Interest Types

enum HealthInterest: CaseIterable {
    case nutrition, exercise, sleep, mentalHealth, heartHealth, weightManagement

    var title: String {
        switch self {
        case .nutrition: return NSLocalizedString("interest_nutrition", comment: "Nutrition")
        case .exercise: return NSLocalizedString("interest_exercise", comment: "Exercise")
        case .sleep: return NSLocalizedString("interest_sleep", comment: "Sleep")
        case .mentalHealth: return NSLocalizedString("interest_mental_health", comment: "Mental Health")
        case .heartHealth: return NSLocalizedString("interest_heart_health", comment: "Heart Health")
        case .weightManagement: return NSLocalizedString("interest_weight_management", comment: "Weight Management")
        }
    }

    var icon: String {
        switch self {
        case .nutrition: return "fork.knife"
        case .exercise: return "figure.run"
        case .sleep: return "bed.double"
        case .mentalHealth: return "brain.head.profile"
        case .heartHealth: return "heart"
        case .weightManagement: return "scalemass"
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
