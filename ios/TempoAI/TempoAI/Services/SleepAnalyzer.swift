//
//  SleepAnalyzer.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//  
//  Sleep quality analysis and scoring algorithms.
//

import Foundation

// MARK: - Sleep Analyzer

/// Sleep quality analysis and scoring
enum SleepAnalyzer: HealthScorer {
    
    /// Calculate comprehensive sleep quality score
    /// - Parameter sleep: Enhanced sleep data
    /// - Returns: Sleep quality score from 0-100
    static func calculateQualityScore(from sleep: EnhancedSleepData) -> Double {
        let durationScore = calculateDurationScore(sleep.totalDuration)
        let efficiencyScore = calculateEfficiencyScore(sleep.sleepEfficiency)
        let stageScore = calculateStageScore(sleep)
        let timingScore = calculateTimingScore(bedtime: sleep.bedtime, wakeTime: sleep.wakeTime)
        
        // Weighted average
        return (durationScore * 0.3 + efficiencyScore * 0.25 + stageScore * 0.25 + timingScore * 0.2)
    }
    
    /// Calculate score based on sleep duration
    /// - Parameter duration: Total sleep duration in seconds
    /// - Returns: Score from 0-100
    private static func calculateDurationScore(_ duration: TimeInterval) -> Double {
        let hours = duration / 3600
        
        switch hours {
        case 7...9: return 100 // Optimal range
        case 6..<7: return 75 // Slightly short
        case 9..<10: return 85 // Slightly long
        case 5..<6: return 50 // Too short
        case 10..<11: return 70 // Too long
        case ..<5: return 20 // Severely insufficient
        default: return 40 // Excessively long
        }
    }
    
    /// Calculate score based on sleep efficiency
    /// - Parameter efficiency: Sleep efficiency ratio (0-1)
    /// - Returns: Score from 0-100
    private static func calculateEfficiencyScore(_ efficiency: Double) -> Double {
        let percentage = efficiency * 100
        
        switch percentage {
        case 90...: return 100
        case 85..<90: return 85
        case 80..<85: return 70
        case 75..<80: return 55
        case 70..<75: return 40
        default: return 20
        }
    }
    
    /// Calculate score based on sleep stage distribution
    /// - Parameter sleep: Enhanced sleep data with stage information
    /// - Returns: Score from 0-100
    private static func calculateStageScore(_ sleep: EnhancedSleepData) -> Double {
        guard let stages = sleep.stageBreakdown else { return 60.0 }
        
        // Ideal ranges for sleep stages
        let deepIdeal: ClosedRange<Double> = 15...25
        let remIdeal: ClosedRange<Double> = 20...30
        
        var score: Double = 60.0 // Base score
        
        // Deep sleep scoring
        if deepIdeal.contains(stages.deepPercentage) {
            score += 20
        } else {
            let deepDeviation = min(
                abs(stages.deepPercentage - 20),
                abs(stages.deepPercentage - 15)
            )
            score += max(0, 20 - deepDeviation)
        }
        
        // REM sleep scoring
        if remIdeal.contains(stages.remPercentage) {
            score += 20
        } else {
            let remDeviation = min(
                abs(stages.remPercentage - 25),
                abs(stages.remPercentage - 20)
            )
            score += max(0, 20 - remDeviation)
        }
        
        return min(score, 100)
    }
    
    /// Calculate score based on sleep timing consistency
    /// - Parameters:
    ///   - bedtime: Bedtime date (optional)
    ///   - wakeTime: Wake time date (optional)
    /// - Returns: Score from 0-100
    private static func calculateTimingScore(bedtime: Date?, wakeTime: Date?) -> Double {
        guard let bedtime = bedtime, let wakeTime = wakeTime else { return 50.0 }
        
        let calendar = Calendar.current
        let bedtimeHour = calendar.component(.hour, from: bedtime)
        let wakeHour = calendar.component(.hour, from: wakeTime)
        
        // Ideal bedtime range: 21:00 - 23:30
        let bedtimeScore: Double
        switch bedtimeHour {
        case 21...23: bedtimeScore = 50
        case 20, 0: bedtimeScore = 35
        case 19, 1: bedtimeScore = 20
        default: bedtimeScore = 10
        }
        
        // Ideal wake time range: 06:00 - 08:00
        let wakeScore: Double
        switch wakeHour {
        case 6...8: wakeScore = 50
        case 5, 9: wakeScore = 35
        case 4, 10: wakeScore = 20
        default: wakeScore = 10
        }
        
        return bedtimeScore + wakeScore
    }
}