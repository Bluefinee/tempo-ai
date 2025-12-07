//
//  HealthScoring.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//  
//  Health scoring protocol and shared utilities.
//  Individual analyzers moved to separate files for maintainability.
//

import Foundation

// MARK: - Health Scoring Protocol

/// Protocol for health scoring components
protocol HealthScorer {
    static func calculateScore<T>(from data: T) -> Double
}

// MARK: - Activity Scorer

/// Activity scoring algorithms
enum ActivityScorer: HealthScorer {
    
    /// Calculate comprehensive activity score
    /// - Parameter activity: Enhanced activity data
    /// - Returns: Activity score from 0-100
    static func calculateScore(from activity: EnhancedActivityData) -> Double {
        let stepsScore = calculateStepsScore(activity.steps)
        let exerciseScore = calculateExerciseScore(activity.exerciseTime)
        let caloriesScore = calculateCaloriesScore(
            active: activity.activeEnergyBurned,
            basal: activity.basalEnergyBurned
        )
        let standScore = calculateStandScore(activity.standHours)
        
        // Weighted average
        return (stepsScore * 0.3 + exerciseScore * 0.3 + caloriesScore * 0.25 + standScore * 0.15)
    }
    
    /// Calculate steps score with graduated targets
    /// - Parameter steps: Daily step count
    /// - Returns: Score from 0-100
    private static func calculateStepsScore(_ steps: Int) -> Double {
        switch steps {
        case 0..<2000: return Double(steps) / 2000.0 * 20
        case 2000..<5000: return 20 + (Double(steps - 2000) / 3000.0 * 30)
        case 5000..<8000: return 50 + (Double(steps - 5000) / 3000.0 * 25)
        case 8000..<10000: return 75 + (Double(steps - 8000) / 2000.0 * 15)
        case 10000...: return min(90 + (Double(steps - 10000) / 5000.0 * 10), 100)
        default: return 0
        }
    }
    
    /// Calculate exercise score based on active minutes
    /// - Parameter exerciseMinutes: Active exercise time in minutes
    /// - Returns: Score from 0-100
    private static func calculateExerciseScore(_ exerciseMinutes: Int) -> Double {
        switch exerciseMinutes {
        case 0..<15: return Double(exerciseMinutes) / 15.0 * 30
        case 15..<30: return 30 + (Double(exerciseMinutes - 15) / 15.0 * 30)
        case 30..<60: return 60 + (Double(exerciseMinutes - 30) / 30.0 * 25)
        case 60...: return min(85 + (Double(exerciseMinutes - 60) / 60.0 * 15), 100)
        default: return 0
        }
    }
    
    /// Calculate calories score based on active vs total energy expenditure
    /// - Parameters:
    ///   - active: Active energy burned
    ///   - basal: Basal metabolic rate
    /// - Returns: Score from 0-100
    private static func calculateCaloriesScore(active: Double, basal: Double) -> Double {
        guard basal > 0 else { return 50.0 }
        
        let ratio = active / basal
        switch ratio {
        case 0..<0.1: return 20
        case 0.1..<0.2: return 40
        case 0.2..<0.3: return 70
        case 0.3..<0.5: return 90
        case 0.5...: return 100
        default: return 50
        }
    }
    
    /// Calculate stand score based on hourly stand goals
    /// - Parameter standHours: Hours with at least 1 minute of standing
    /// - Returns: Score from 0-100
    private static func calculateStandScore(_ standHours: Int) -> Double {
        return min(Double(standHours) / 12.0 * 100, 100)
    }
}