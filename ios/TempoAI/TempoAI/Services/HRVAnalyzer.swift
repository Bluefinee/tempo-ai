//
//  HRVAnalyzer.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//
//  Heart Rate Variability analysis for recovery and stress assessment.
//

import Foundation

// MARK: - HRV Analyzer

/// Heart Rate Variability analysis for recovery and stress
enum HRVAnalyzer: HealthScorer {

    /// Calculate recovery score from HRV metrics
    /// - Parameter hrv: HRV metrics data
    /// - Returns: Recovery score from 0-100
    static func calculateRecoveryScore(from hrv: HRVMetrics) -> Double {
        // RMSSD is the primary metric for recovery analysis
        if let rmssd = hrv.rmssd {
            return calculateRMSSDScore(rmssd)
        } else if let sdnn = hrv.sdnn {
            return calculateSDNNScore(sdnn)
        } else {
            // Fallback to average with trend analysis
            return calculateAverageHRVScore(hrv.average, trend: hrv.trend)
        }
    }

    /// Calculate score from RMSSD (preferred metric)
    /// - Parameter rmssd: RMSSD value in milliseconds
    /// - Returns: Score from 0-100
    private static func calculateRMSSDScore(_ rmssd: Double) -> Double {
        // Age and fitness adjusted ranges
        switch rmssd {
        case 50...: return 95
        case 40 ..< 50: return 85
        case 30 ..< 40: return 75
        case 25 ..< 30: return 60
        case 20 ..< 25: return 45
        case 15 ..< 20: return 30
        default: return 20
        }
    }

    /// Calculate score from SDNN
    /// - Parameter sdnn: SDNN value in milliseconds
    /// - Returns: Score from 0-100
    private static func calculateSDNNScore(_ sdnn: Double) -> Double {
        switch sdnn {
        case 50...: return 90
        case 40 ..< 50: return 80
        case 30 ..< 40: return 70
        case 25 ..< 30: return 55
        case 20 ..< 25: return 40
        case 15 ..< 20: return 25
        default: return 15
        }
    }

    /// Calculate score from average HRV with trend consideration
    /// - Parameters:
    ///   - average: Average HRV value
    ///   - trend: HRV trend indicator
    /// - Returns: Score from 0-100
    private static func calculateAverageHRVScore(_ average: Double, trend: HRVTrend) -> Double {
        var baseScore = calculateRMSSDScore(average)  // Use RMSSD scoring as baseline

        // Adjust based on trend
        switch trend {
        case .improving: baseScore = min(baseScore + 10, 100)
        case .declining: baseScore = max(baseScore - 10, 0)
        case .stable, .unknown: break
        }

        return baseScore
    }
}
