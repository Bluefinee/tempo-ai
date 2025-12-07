//
//  HealthDataStore.swift
//  TempoAI
//
//  Created by Claude on 2025-12-07.
//
//  Core Data integration for health data caching and persistence.
//  Provides offline support and performance optimization.
//

import CoreData
import Foundation

// MARK: - Health Data Store

/// Core Data store for health data persistence and caching
/// Provides offline support and improves app performance through data caching
@MainActor
final class HealthDataStore: ObservableObject {

    // MARK: - Properties

    static let shared: HealthDataStore = HealthDataStore()

    /// Core Data persistent container for health data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealthDataModel")

        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                print("❌ Core Data error: \(error.localizedDescription)")
                self?.handleCoreDataError(error)
            } else {
                print("✅ Core Data health store loaded successfully")
            }
        }

        // Configure for background processing
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        return container
    }()

    /// Background context for data operations
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()

    // MARK: - Initialization

    private init() {
        // Private init for singleton pattern
    }

    // MARK: - Health Data Persistence

    /// Save comprehensive health data to Core Data
    /// - Parameter data: Comprehensive health data to persist
    /// - Throws: Core Data or encoding errors
    func saveHealthData(_ data: ComprehensiveHealthData) async throws {
        try await backgroundContext.perform {
            // Check if entry for this timestamp already exists
            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: data.timestamp)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? Date()

            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp < %@",
                dayStart as NSDate,
                dayEnd as NSDate
            )

            let existingEntries = try self.backgroundContext.fetch(request)

            // Update existing or create new
            let entity = existingEntries.first ?? HealthDataEntity(context: self.backgroundContext)

            entity.timestamp = data.timestamp
            entity.overallScore = data.overallHealthScore.overall

            // Encode comprehensive data as JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            entity.dataJSON = try encoder.encode(data)

            // Save vital signs
            entity.heartRate = data.vitalSigns.heartRate?.average ?? 0
            entity.restingHeartRate = data.vitalSigns.heartRate?.resting ?? 0
            entity.hrvAverage = data.vitalSigns.heartRateVariability?.average ?? 0
            entity.oxygenSaturation = data.vitalSigns.oxygenSaturation ?? 0
            entity.systolicBP = data.vitalSigns.bloodPressure?.systolic ?? 0
            entity.diastolicBP = data.vitalSigns.bloodPressure?.diastolic ?? 0

            // Save activity data
            entity.steps = Int32(data.activity.steps)
            entity.distance = data.activity.distance
            entity.activeCalories = data.activity.activeEnergyBurned
            entity.exerciseMinutes = Int32(data.activity.exerciseTime)

            // Save sleep data
            entity.sleepDuration = data.sleep.totalDuration
            entity.sleepEfficiency = data.sleep.sleepEfficiency
            entity.deepSleep = data.sleep.deepSleep ?? 0
            entity.remSleep = data.sleep.remSleep ?? 0

            // Save body measurements
            entity.weight = data.bodyMeasurements.weight ?? 0
            entity.bodyMassIndex = data.bodyMeasurements.bodyMassIndex ?? 0

            try self.backgroundContext.save()
            print("✅ Health data saved successfully for \(data.timestamp)")
        }
    }

    /// Fetch cached health data for a specific date
    /// - Parameter date: Date to fetch data for
    /// - Returns: Cached comprehensive health data, if available
    func fetchCachedData(for date: Date) async throws -> ComprehensiveHealthData? {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? Date()

            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp < %@",
                dayStart as NSDate,
                dayEnd as NSDate
            )
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first,
                let dataJSON = entity.dataJSON
            else {
                return nil
            }

            // Decode comprehensive data from JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ComprehensiveHealthData.self, from: dataJSON)
        }
    }

    /// Fetch health data for a date range
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    /// - Returns: Array of health data entries in date range
    func fetchHealthDataRange(from startDate: Date, to endDate: Date) async throws -> [ComprehensiveHealthData] {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                startDate as NSDate,
                endDate as NSDate
            )
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

            let entities = try self.backgroundContext.fetch(request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            return entities.compactMap { entity in
                guard let dataJSON = entity.dataJSON else { return nil }
                return try? decoder.decode(ComprehensiveHealthData.self, from: dataJSON)
            }
        }
    }

    /// Get health trends for the past N days
    /// - Parameter days: Number of days to analyze (default: 30)
    /// - Returns: Health trend analysis
    func getHealthTrends(for days: Int = 30) async throws -> HealthTrendAnalysis {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate

        let healthDataEntries = try await fetchHealthDataRange(from: startDate, to: endDate)

        return HealthTrendAnalysis(
            period: days,
            entries: healthDataEntries,
            averageScore: calculateAverageScore(healthDataEntries),
            trends: calculateTrends(healthDataEntries)
        )
    }

    // MARK: - Cache Management

    /// Check if fresh cached data exists for today
    /// - Returns: True if fresh data (< 1 hour old) exists
    func hasFreshCachedDataForToday() async -> Bool {
        do {
            let today = Date()
            guard let cachedData = try await fetchCachedData(for: today) else { return false }

            let hourAgo = Date().addingTimeInterval(-3600)  // 1 hour ago
            return cachedData.timestamp > hourAgo
        } catch {
            print("⚠️ Error checking cached data: \(error)")
            return false
        }
    }

    /// Clear old cached data to manage storage
    /// - Parameter daysToKeep: Number of days of data to retain (default: 90)
    func clearOldCachedData(keepingLast daysToKeep: Int = 90) async throws {
        try await backgroundContext.perform {
            let cutoffDate =
                Calendar.current.date(
                    byAdding: .day,
                    value: -daysToKeep,
                    to: Date()
                ) ?? Date()

            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)

            let oldEntries = try self.backgroundContext.fetch(request)
            for entry in oldEntries {
                self.backgroundContext.delete(entry)
            }

            try self.backgroundContext.save()
            print("🧹 Cleared \(oldEntries.count) old health data entries")
        }
    }

    // MARK: - Helper Methods

    /// Handle Core Data errors gracefully
    /// - Parameter error: Core Data error
    private func handleCoreDataError(_ error: Error) {
        // Log error and potentially attempt recovery
        print("❌ Core Data Error: \(error)")

        // For now, just log. In production, could attempt container recreation
        // or fallback to in-memory storage
    }

    /// Calculate average health score from entries
    /// - Parameter entries: Health data entries
    /// - Returns: Average overall health score
    private func calculateAverageScore(_ entries: [ComprehensiveHealthData]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let totalScore = entries.map { $0.overallHealthScore.overall }.reduce(0, +)
        return totalScore / Double(entries.count)
    }

    /// Calculate health trends from historical data
    /// - Parameter entries: Health data entries
    /// - Returns: Trend analysis
    private func calculateTrends(_ entries: [ComprehensiveHealthData]) -> HealthTrends {
        guard entries.count >= 2 else {
            return HealthTrends(overall: .stable, activity: .stable, sleep: .stable)
        }

        let recent = Array(entries.suffix(7))  // Last 7 days
        let previous = Array(entries.dropLast(7).suffix(7))  // Previous 7 days

        return HealthTrends(
            overall: calculateTrend(
                recent: recent.map { $0.overallHealthScore.overall },
                previous: previous.map { $0.overallHealthScore.overall }
            ),
            activity: calculateTrend(
                recent: recent.map { $0.overallHealthScore.activity },
                previous: previous.map { $0.overallHealthScore.activity }
            ),
            sleep: calculateTrend(
                recent: recent.map { $0.overallHealthScore.sleep },
                previous: previous.map { $0.overallHealthScore.sleep }
            )
        )
    }

    /// Calculate trend direction for a metric
    /// - Parameters:
    ///   - recent: Recent values
    ///   - previous: Previous values
    /// - Returns: Trend direction
    private func calculateTrend(recent: [Double], previous: [Double]) -> TrendDirection {
        guard !recent.isEmpty && !previous.isEmpty else { return .stable }

        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let previousAvg = previous.reduce(0, +) / Double(previous.count)

        let changePercent = ((recentAvg - previousAvg) / previousAvg) * 100

        if changePercent > 5 {
            return .improving
        } else if changePercent < -5 {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - Supporting Types

/// Health trend analysis container
struct HealthTrendAnalysis {
    let period: Int
    let entries: [ComprehensiveHealthData]
    let averageScore: Double
    let trends: HealthTrends
}

/// Health trends for different categories
struct HealthTrends {
    let overall: TrendDirection
    let activity: TrendDirection
    let sleep: TrendDirection
}

/// Trend direction indicators
enum TrendDirection: String, CaseIterable {
    case improving
    case declining
    case stable
}

/// Core Data entity extension for proper initialization
extension HealthDataEntity {
    /// Convenience initializer
    convenience init(context: NSManagedObjectContext) {
        self.init(entity: HealthDataEntity.entity(), insertInto: context)
    }
}
