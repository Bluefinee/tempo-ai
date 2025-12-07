import Foundation
import HealthKit
import XCTest

@testable import TempoAI

class MockHealthKitStore: HealthKitStoreProtocol {
    static var staticIsHealthDataAvailableResult: Bool = true

    var isHealthDataAvailableResult: Bool = true
    var authorizationStatusResult: HKAuthorizationStatus = .notDetermined
    var requestAuthorizationCalled: Bool = false
    var requestAuthorizationError: Error?
    var executedQueries: [HKQuery] = []
    var mockQueryResults: [String: Any] = [:]

    static func isHealthDataAvailable() -> Bool {
        return staticIsHealthDataAvailableResult
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return authorizationStatusResult
    }

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?) async throws {
        requestAuthorizationCalled = true

        if let error = requestAuthorizationError {
            throw error
        }

        // Keep the pre-configured authorizationStatusResult
        // Tests should set this value before calling requestAuthorization
        // Only set to granted if no specific status was configured
        if authorizationStatusResult == .notDetermined {
            authorizationStatusResult = .sharingAuthorized
        }
    }

    func execute(_ query: HKQuery) {
        executedQueries.append(query)

        // Simulate query execution with mock results
        DispatchQueue.main.async {
            if let sampleQuery = query as? HKSampleQuery {
                self.handleSampleQuery(sampleQuery)
            } else if let statisticsQuery = query as? HKStatisticsQuery {
                self.handleStatisticsQuery(statisticsQuery)
            }
        }
    }

    private func handleSampleQuery(_ query: HKSampleQuery) {
        var samples: [HKSample] = []

        // Create mock samples based on query type
        if query.sampleType.identifier == HKCategoryTypeIdentifier.sleepAnalysis.rawValue {
            samples = createMockSleepSamples()
        } else if query.sampleType.identifier == HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue {
            samples = createMockHRVSamples()
        } else if query.sampleType.identifier == HKQuantityTypeIdentifier.heartRate.rawValue {
            samples = createMockHeartRateSamples()
        }

        // Use MockQueryFactory to handle results instead of direct resultsHandler access
    }

    private func handleStatisticsQuery(_ query: HKStatisticsQuery) {
        let mockValue: Double

        switch query.quantityType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            mockValue = 8234
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            mockValue = 6200 // meters
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            mockValue = 420
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            mockValue = 35
        default:
            mockValue = 0
        }

        // Create quantity with appropriate unit for the quantity type
        let unit: HKUnit
        switch query.quantityType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            unit = .count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            unit = .meter()
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            unit = .kilocalorie()
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            unit = .minute()
        default:
            unit = .count()
        }
        let quantity = HKQuantity(unit: unit, doubleValue: mockValue)
        let statistics = MockStatistics(sumQuantity: quantity)

        // Note: Cannot directly access resultsHandler as it's private in HKStatisticsQuery
        // The mock relies on the query execution pattern in the actual HealthKitManager
    }

    private func createMockSleepSamples() -> [HKCategorySample] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date()
        let endDate = Date()

        let sample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleep.rawValue,
            start: startDate,
            end: endDate
        )

        return [sample]
    }

    private func createMockHRVSamples() -> [HKQuantitySample] {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let unit = HKUnit.secondUnit(with: .milli)
        let quantity = HKQuantity(unit: unit, doubleValue: 45.2)
        let startDate = Date()

        let sample = HKQuantitySample(
            type: hrvType,
            quantity: quantity,
            start: startDate,
            end: startDate
        )

        return [sample]
    }

    private func createMockHeartRateSamples() -> [HKQuantitySample] {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let unit = HKUnit.count().unitDivided(by: .minute())
        let quantity = HKQuantity(unit: unit, doubleValue: 75)
        let startDate = Date()

        let sample = HKQuantitySample(
            type: heartRateType,
            quantity: quantity,
            start: startDate,
            end: startDate
        )

        return [sample]
    }
}
