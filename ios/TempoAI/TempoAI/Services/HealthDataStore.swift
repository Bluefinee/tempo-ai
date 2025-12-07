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
import Combine

// MARK: - Temporary Mock Implementation
// TODO: Implement proper Core Data entity when schema is available

class HealthDataStore: ObservableObject {
    static let shared = HealthDataStore()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    // Mock implementations to allow compilation
    func saveHealthData(_ data: ComprehensiveHealthData) async throws {
        // Mock save - implement later with proper Core Data schema
        print("📝 Mock: Saving health data for \(data.timestamp)")
    }
    
    func getHealthData(for date: Date) async throws -> ComprehensiveHealthData? {
        // Mock retrieval - implement later with proper Core Data schema
        print("📖 Mock: Getting health data for \(date)")
        return nil
    }
    
    func getHealthDataRange(from startDate: Date, to endDate: Date) async throws -> [ComprehensiveHealthData] {
        // Mock range query - implement later with proper Core Data schema
        print("📊 Mock: Getting health data range from \(startDate) to \(endDate)")
        return []
    }
    
    func deleteHealthData(olderThan date: Date) async throws {
        // Mock deletion - implement later with proper Core Data schema
        print("🗑️ Mock: Deleting health data older than \(date)")
    }
}

/*
// ORIGINAL IMPLEMENTATION - Requires HealthDataEntity Core Data schema
// Uncomment when Core Data entity is properly configured

import CoreData
import Foundation

/// Core Data service for health data persistence
/// Provides local caching for offline support and performance optimization
class HealthDataStore: ObservableObject {
    static let shared = HealthDataStore()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "HealthDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Saves health data with deduplication by timestamp
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
            
            // Update entity properties
            entity.timestamp = data.timestamp
            entity.jsonData = try JSONEncoder().encode(data)
            
            try self.backgroundContext.save()
            print("✅ Health data saved for \(data.timestamp)")
        }
    }
    
    /// Retrieves health data for specific date
    /// - Parameter date: Target date
    /// - Returns: Health data if found
    /// - Throws: Core Data or decoding errors
    func getHealthData(for date: Date) async throws -> ComprehensiveHealthData? {
        try await backgroundContext.perform {
            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? Date()

            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp < %@",
                dayStart as NSDate,
                dayEnd as NSDate
            )
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first,
                  let jsonData = entity.jsonData else {
                return nil
            }

            return try JSONDecoder().decode(ComprehensiveHealthData.self, from: jsonData)
        }
    }
    
    /// Retrieves health data within date range
    /// - Parameters:
    ///   - startDate: Range start
    ///   - endDate: Range end
    /// - Returns: Array of health data
    /// - Throws: Core Data or decoding errors
    func getHealthDataRange(from startDate: Date, to endDate: Date) async throws -> [ComprehensiveHealthData] {
        try await backgroundContext.perform {
            let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                startDate as NSDate,
                endDate as NSDate
            )
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \HealthDataEntity.timestamp, ascending: true)
            ]

            let entities = try self.backgroundContext.fetch(request)
            
            return try entities.compactMap { entity in
                guard let jsonData = entity.jsonData else { return nil }
                return try JSONDecoder().decode(ComprehensiveHealthData.self, from: jsonData)
            }
        }
    }
    
    /// Cleans up old health data entries
    /// - Parameter date: Delete entries older than this date
    /// - Throws: Core Data errors
    func deleteHealthData(olderThan date: Date) async throws {
        try await backgroundContext.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = HealthDataEntity.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp < %@", date as NSDate)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try self.backgroundContext.execute(deleteRequest)
            try self.backgroundContext.save()
            
            print("🗑️ Cleaned up health data older than \(date)")
        }
    }
}

// MARK: - Core Data Entity Extensions

extension HealthDataEntity {
    convenience init(from healthData: ComprehensiveHealthData, context: NSManagedObjectContext) throws {
        self.init(entity: HealthDataEntity.entity(), insertInto: context)
        
        self.timestamp = healthData.timestamp
        self.jsonData = try JSONEncoder().encode(healthData)
    }
}

*/