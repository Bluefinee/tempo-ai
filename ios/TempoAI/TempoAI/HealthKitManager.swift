import Combine
import Foundation
import HealthKit

extension Notification.Name {
    static let healthKitDataUpdated = Notification.Name("healthKitDataUpdated")
}

protocol HealthKitQueryFactory {
    func createSampleQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) -> HKSampleQuery
}

class DefaultHealthKitQueryFactory: HealthKitQueryFactory {
    func createSampleQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) -> HKSampleQuery {
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors,
            resultsHandler: resultsHandler
        )
    }
}

@MainActor
class HealthKitManager: ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: String = "Not Determined"

    private let healthStore: HKHealthStore
    private let queryFactory: HealthKitQueryFactory

    init(
        healthStore: HKHealthStore = HKHealthStore(),
        queryFactory: HealthKitQueryFactory = DefaultHealthKitQueryFactory()
    ) {
        self.healthStore = healthStore
        self.queryFactory = queryFactory
    }

    private var typesToRead: Set<HKObjectType> {
        let quantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .heartRateVariabilitySDNN, .restingHeartRate, .heartRate,
            .stepCount, .distanceWalkingRunning, .activeEnergyBurned, .appleExerciseTime,
        ]
        var types: Set<HKObjectType> = Set()
        for identifier in quantityIdentifiers {
            if let type = HKObjectType.quantityType(forIdentifier: identifier) {
                types.insert(type)
            }
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        return types
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit: Health data not available on this device")
            throw HealthKitError.notAvailable
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            print("✅ HealthKit: Successfully requested authorization for \(typesToRead.count) data types")
            
            isAuthorized = true
            authorizationStatus = "Authorized"
        } catch {
            print("❌ HealthKit: Authorization request failed - \(error.localizedDescription)")
            isAuthorized = false
            authorizationStatus = "Denied"
            throw error
        }
    }

    func fetchTodayHealthData() async throws -> HealthData {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit: Health data not available, returning mock data")
            throw HealthKitError.notAvailable
        }
        guard isAuthorized else { 
            print("❌ HealthKit: Not authorized, cannot fetch data")
            throw HealthKitError.notAuthorized 
        }
        print("📱 HealthKit: Fetching today's health data...")
        do {
            async let sleep = fetchSleepData()
            async let hrv = fetchHRVData()
            async let heartRate = fetchHeartRateData()
            async let activity = fetchActivityData()
            let healthData = try await HealthData(sleep: sleep, hrv: hrv, heartRate: heartRate, activity: activity)
            print("✅ HealthKit: Successfully fetched health data")
            return healthData
        } catch {
            print("❌ HealthKit: Failed to fetch health data - \(error.localizedDescription)")
            throw error
        }
    }

    private func fetchSleepData() async throws -> SleepData {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit: Sleep data unavailable, using mock data")
            return mockSleepData()
        }
        guard isAuthorized else {
            print("⚠️ HealthKit: Not authorized for sleep data, using mock data")
            return mockSleepData()
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)

        return await withCheckedContinuation { continuation in
            let query = queryFactory.createSampleQuery(
                sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil
            ) { [weak self] _, samples, _ in
                guard let self = self else {
                    let emptySleepData = SleepData(duration: 0, deep: 0, rem: 0, light: 0, awake: 0, efficiency: 0)
                    continuation.resume(returning: emptySleepData)
                    return
                }
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: self.mockSleepData())
                    return
                }
                let sleepData = self.processSleepSamples(sleepSamples)
                continuation.resume(returning: sleepData)
            }
            healthStore.execute(query)
        }
    }

    private func mockSleepData() -> SleepData {
        SleepData(duration: 6.5, deep: 1.2, rem: 1.8, light: 3.0, awake: 0.5, efficiency: 92.0)
    }

    private func processSleepSamples(_ sleepSamples: [HKCategorySample]) -> SleepData {
        var totals = (total: 0.0, deep: 0.0, rem: 0.0, light: 0.0, awake: 0.0)

        for sample in sleepSamples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                totals.deep += duration
                totals.total += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                totals.rem += duration
                totals.total += duration
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue, HKCategoryValueSleepAnalysis.asleep.rawValue:
                totals.light += duration
                totals.total += duration
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                totals.awake += duration
            default:
                totals.light += duration
                totals.total += duration
            }
        }

        let efficiency = totals.total > 0 ? (totals.total / (totals.total + totals.awake)) * 100 : 92.0
        return SleepData(duration: totals.total / 3600, deep: totals.deep / 3600, rem: totals.rem / 3600,
                         light: totals.light / 3600, awake: totals.awake / 3600, efficiency: efficiency)
    }

    private func fetchHRVData() async throws -> HRVData {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit: HRV data unavailable, using mock data")
            return HRVData(average: 45, min: 25, max: 68)
        }
        guard isAuthorized else {
            print("⚠️ HealthKit: Not authorized for HRV data, using mock data")
            return HRVData(average: 45, min: 25, max: 68)
        }

        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)

        return await withCheckedContinuation { continuation in
            let query = queryFactory.createSampleQuery(
                sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil
            ) { [weak self] _, samples, _ in
                guard let self = self else {
                    continuation.resume(returning: HRVData(average: 45, min: 25, max: 68))
                    return
                }
                guard let hrvSamples = samples as? [HKQuantitySample], !hrvSamples.isEmpty else {
                    continuation.resume(returning: HRVData(average: 45, min: 25, max: 68))
                    return
                }
                let hrvValues = hrvSamples.map { $0.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) }
                let average = hrvValues.reduce(0, +) / Double(hrvValues.count)
                let min = hrvValues.min() ?? 25
                let max = hrvValues.max() ?? 68
                continuation.resume(returning: HRVData(average: average, min: min, max: max))
            }
            healthStore.execute(query)
        }
    }

    private func fetchHeartRateData() async throws -> HeartRateData {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit: Heart rate data unavailable, using mock data")
            return HeartRateData(resting: 62, average: 75, min: 58, max: 145)
        }
        guard isAuthorized else {
            print("⚠️ HealthKit: Not authorized for heart rate data, using mock data")
            return HeartRateData(resting: 62, average: 75, min: 58, max: 145)
        }

        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)

        let heartRateValues = await fetchHeartRateValues(predicate: predicate)
        guard !heartRateValues.isEmpty else {
            return HeartRateData(resting: 62, average: 75, min: 58, max: 145)
        }

        let average = Double(heartRateValues.reduce(0, +)) / Double(heartRateValues.count)
        let min = heartRateValues.min() ?? 58
        let max = heartRateValues.max() ?? 145
        let resting = await fetchRestingHeartRate(predicate: predicate) ?? 62

        return HeartRateData(resting: Double(resting), average: average, min: Double(min), max: Double(max))
    }

    private func fetchActivityData() async throws -> ActivityData {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit: Activity data unavailable, using mock data")
            return ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
        }
        guard isAuthorized else {
            print("⚠️ HealthKit: Not authorized for activity data, using mock data")
            return ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
        }

        async let steps = fetchSteps()
        async let distance = fetchDistance()
        async let calories = fetchCalories()
        async let activeMinutes = fetchActiveMinutes()

        return try await ActivityData(
            steps: Double(steps), distance: distance, calories: Double(calories), activeMinutes: Double(activeMinutes)
        )
    }

    private func fetchSteps() async throws -> Double {
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        return await fetchQuantitySum(for: stepsType, unit: .count())
    }

    private func fetchDistance() async throws -> Double {
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        return await fetchQuantitySum(for: distanceType, unit: .meter()) / 1000  // Convert to kilometers
    }

    private func fetchCalories() async throws -> Double {
        let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        return await fetchQuantitySum(for: caloriesType, unit: .kilocalorie())
    }

    private func fetchActiveMinutes() async throws -> Double {
        let activeMinutesType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        return await fetchQuantitySum(for: activeMinutesType, unit: .minute())
    }

    private func fetchQuantitySum(for quantityType: HKQuantityType, unit: HKUnit) async -> Double {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum
            ) { _, result, _ in
                let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }
    }

    private func fetchHeartRateValues(predicate: NSPredicate) async -> [Int] {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        return await withCheckedContinuation { continuation in
            let query = queryFactory.createSampleQuery(
                sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil
            ) { [weak self] _, samples, _ in
                guard self != nil else {
                    continuation.resume(returning: [])
                    return
                }
                guard let heartRateSamples = samples as? [HKQuantitySample], !heartRateSamples.isEmpty else {
                    continuation.resume(returning: [])
                    return
                }
                let heartRateValues = heartRateSamples.map {
                    Int($0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                }
                continuation.resume(returning: heartRateValues)
            }
            healthStore.execute(query)
        }
    }

    private func fetchRestingHeartRate(predicate: NSPredicate) async -> Int? {
        guard let restingType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = queryFactory.createSampleQuery(
                sampleType: restingType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]
            ) { [weak self] _, samples, _ in
                guard self != nil else {
                    continuation.resume(returning: nil)
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let restingValue = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                continuation.resume(returning: restingValue)
            }
            healthStore.execute(query)
        }
    }

    private var backgroundObserverQueries: [HKObserverQuery] = []

    func startBackgroundDataObservation() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit: Cannot start background observation - health data unavailable")
            return
        }
        guard isAuthorized else { 
            print("⚠️ HealthKit: Cannot start background observation - not authorized")
            return 
        }
        print("🔄 HealthKit: Starting background data observation...")
        let types: [HKSampleType] = [
            .quantityType(forIdentifier: .heartRateVariabilitySDNN),
            .quantityType(forIdentifier: .stepCount),
            .categoryType(forIdentifier: .sleepAnalysis),
        ].compactMap { $0 }
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { _, _, error in
                if let error = error {
                    print("❌ HealthKit: Background observation error for \(type.identifier)")
                    print("❌ Error: \(error.localizedDescription)")
                } else {
                    print("📊 HealthKit: Data updated for \(type.identifier)")
                    Task { @MainActor in
                        NotificationCenter.default.post(name: .healthKitDataUpdated, object: nil)
                    }
                }
            }
            backgroundObserverQueries.append(query)
            healthStore.execute(query)
        }
        print("✅ HealthKit: Background observation started for \(types.count) data types")
    }

    func stopBackgroundDataObservation() {
        for query in backgroundObserverQueries {
            healthStore.stop(query)
        }
        backgroundObserverQueries.removeAll()
    }
}

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case dataUnavailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .dataUnavailable:
            return "Health data is not available"
        }
    }
}
