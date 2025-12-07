//
//  NutritionAnalyzer.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//
//  Nutrition analysis and scoring algorithms.
//

import Foundation

// MARK: - Nutrition Analyzer

/// Nutrition analysis and scoring
enum NutritionAnalyzer: HealthScorer {

    /// HealthScorer protocol conformance
    static func calculateScore<T>(from data: T) -> Double {
        // Since we don't have a standard nutrition data type in HealthKitData,
        // return a reasonable default for protocol conformance
        return 0.7  // Assume reasonable nutrition by default
    }

    /// Calculate macronutrient balance score
    /// - Parameters:
    ///   - protein: Protein intake in grams
    ///   - carbs: Carbohydrate intake in grams
    ///   - fat: Fat intake in grams
    /// - Returns: Balance score from 0-100
    static func calculateBalanceScore(protein: Double, carbs: Double, fat: Double) -> Double {
        let totalCals = (protein * 4) + (carbs * 4) + (fat * 9)
        guard totalCals > 0 else { return 0 }

        let proteinPercent = (protein * 4) / totalCals * 100
        let carbsPercent = (carbs * 4) / totalCals * 100
        let fatPercent = (fat * 9) / totalCals * 100

        // Ideal ranges (flexible)
        let proteinScore = calculateMacroScore(proteinPercent, ideal: 15 ... 25)
        let carbsScore = calculateMacroScore(carbsPercent, ideal: 45 ... 65)
        let fatScore = calculateMacroScore(fatPercent, ideal: 20 ... 35)

        return (proteinScore + carbsScore + fatScore) / 3.0
    }

    /// Calculate individual macro score
    /// - Parameters:
    ///   - percentage: Actual percentage
    ///   - ideal: Ideal range
    /// - Returns: Score from 0-100
    private static func calculateMacroScore(_ percentage: Double, ideal: ClosedRange<Double>) -> Double {
        if ideal.contains(percentage) {
            return 100
        } else {
            let deviation = min(
                abs(percentage - ideal.lowerBound),
                abs(percentage - ideal.upperBound)
            )
            return max(0, 100 - (deviation * 3))  // 3% deviation = -3 points
        }
    }
}
