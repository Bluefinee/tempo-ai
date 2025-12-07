import Foundation

// MARK: - Metric Value Constants

/// Constants for approximate metric value calculations
///
/// ⚠️ These are estimated values for backward compatibility only.
/// In production, prefer using actual HealthKit data when available.
enum MetricValueConstants {
    /// Approximate HRV range for display (ms)
    /// Note: Typical HRV ranges from 20-200ms, using 50 as multiplier for 0-50ms range
    static let hrvMultiplier: Double = 50.0
    static let hrvDisplayNote = "~"  // Prefix to indicate approximation

    /// Approximate sleep duration range for display (hours)
    /// Note: Using 10 hour maximum for 0-1 normalized score
    static let sleepMultiplier: Double = 10.0
    static let sleepDisplayNote = "~"

    /// Approximate daily step count for display
    /// Note: Using 10,000 steps as maximum for normalized score
    static let activityMultiplier: Double = 10000.0
    static let activityDisplayNote = "~"

    /// Heart rate range constants (bpm)
    /// Note: 60-100 bpm is typical resting heart rate range
    static let heartRateBase: Double = 60.0
    static let heartRateRange: Double = 40.0
    static let heartRateDisplayNote = "~"
}
