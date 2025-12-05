import Foundation
import HealthKit
import XCTest

@testable import TempoAI

// MARK: - Statistics Protocol for Testing

protocol StatisticsProtocol {
    func sumQuantity() -> HKQuantity?
}

extension HKStatistics: StatisticsProtocol {}

class MockStatistics: StatisticsProtocol {
    private let _sumQuantity: HKQuantity?
    
    init(sumQuantity: HKQuantity?) {
        self._sumQuantity = sumQuantity
    }
    
    func sumQuantity() -> HKQuantity? {
        return _sumQuantity
    }
}

// MARK: - Test Helpers

extension HealthKitManagerTests {
    func setupAuthorizedManager() async {
        mockHealthStore.isHealthDataAvailableResult = true
        mockHealthStore.authorizationStatusResult = .sharingAuthorized
        try? await healthKitManager.requestAuthorization()
    }

    func setupMockQueryResponses() {
        // Reset previous queries
        mockHealthStore.executedQueries.removeAll()
    }

    func withMockData<T>(_ block: () throws -> T) rethrows -> T {
        return try block()
    }
}