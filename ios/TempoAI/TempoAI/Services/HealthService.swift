import Combine
import Foundation
import HealthKit

@MainActor
class HealthService: HealthServiceProtocol, ObservableObject {
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var latestData: HealthData?

    private let healthStore = HKHealthStore()
    private lazy var requiredTypes: Set<HKSampleType> = {
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        return [
            HKSampleType.quantityType(forIdentifier: .heartRate),
            HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
            HKSampleType.quantityType(forIdentifier: .stepCount),
            HKSampleType.categoryType(forIdentifier: .sleepAnalysis),
        ].compactMap { $0 }
    }()

    func requestPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: requiredTypes) { success, _ in
                DispatchQueue.main.async {
                    self.authorizationStatus = success ? .sharingAuthorized : .sharingDenied
                    continuation.resume(returning: success)
                }
            }
        }
    }

    func getLatestHealthData() async throws -> HealthData {
        async let heartRate = getLatestHeartRate()
        async let sleepData = getLatestSleepData()
        async let activityData = getLatestActivityData()
        async let hrvData = getLatestHRVData()

        return HealthData(
            heartRate: await heartRate,
            sleepData: await sleepData,
            activityData: await activityData,
            hrvData: await hrvData,
            timestamp: Date()
        )
    }

    private func getLatestHeartRate() async -> HeartRateData {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return HeartRateData(current: 70, resting: 65, max: 180)
        }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: HeartRateData(current: 70, resting: 65, max: 180))
                    return
                }
                let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: HeartRateData(current: value, resting: 65, max: 180))
            }
            healthStore.execute(query)
        }
    }

    private func getLatestSleepData() async -> SleepData {
        // TODO: Implement actual HealthKit sleep data query
        return SleepData(duration: 7.5, quality: 0.8, deepSleepRatio: 0.25)
    }

    private func getLatestActivityData() async -> ActivityData {
        // TODO: Implement actual HealthKit activity data query
        return ActivityData(activeEnergyBurned: 350, stepCount: 8500)
    }

    private func getLatestHRVData() async -> HRVData {
        // TODO: Implement actual HealthKit HRV data query
        return HRVData(current: 45, baseline: 45, trend: .stable)
    }
}
