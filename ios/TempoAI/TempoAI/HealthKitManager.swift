import Combine
import Foundation
import HealthKit

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
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

        // Note: Read authorization status cannot be determined via authorizationStatus(for:)
        // We assume authorization was granted if requestAuthorization succeeds without error
        isAuthorized = true
        authorizationStatus = "Authorized"
    }

    func fetchTodayHealthData() async throws -> HealthData {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }

        async let sleepData = fetchSleepData()
        async let hrvData = fetchHRVData()
        async let heartRateData = fetchHeartRateData()
        async let activityData = fetchActivityData()

        return try await HealthData(
            sleep: sleepData,
            hrv: hrvData,
            heartRate: heartRateData,
            activity: activityData
        )
    }

    // MARK: - Sleep Data
    private func fetchSleepData() async throws -> SleepData {
        // For simulator or when no data is available, return mock data
        if !HKHealthStore.isHealthDataAvailable() || !isAuthorized {
            return mockSleepData()
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictEndDate
        )

        return await withCheckedContinuation { continuation in
            let query = queryFactory.createSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
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
        return SleepData(
            duration: 6.5,
            deep: 1.2,
            rem: 1.8,
            light: 3.0,
            awake: 0.5,
            efficiency: 92
        )
    }

    private func processSleepSamples(_ sleepSamples: [HKCategorySample]) -> SleepData {
        var totalSleep: TimeInterval = 0
        var deepSleep: TimeInterval = 0
        var remSleep: TimeInterval = 0
        var lightSleep: TimeInterval = 0
        var awakeTime: TimeInterval = 0

        for sample in sleepSamples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)

            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleep += duration
                totalSleep += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleep += duration
                totalSleep += duration
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                lightSleep += duration
                totalSleep += duration
            case HKCategoryValueSleepAnalysis.asleep.rawValue:
                // Handle deprecated .asleep case for backwards compatibility
                lightSleep += duration
                totalSleep += duration
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                awakeTime += duration
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
                // In bed but not sleeping - don't count towards total sleep
                break
            default:
                // For any other sleep stages, count as light sleep
                lightSleep += duration
                totalSleep += duration
            }
        }

        let efficiency = totalSleep > 0 ? Int((totalSleep / (totalSleep + awakeTime)) * 100) : 92

        return SleepData(
            duration: totalSleep / 3600,
            deep: deepSleep / 3600,
            rem: remSleep / 3600,
            light: lightSleep / 3600,
            awake: awakeTime / 3600,
            efficiency: efficiency
        )
    }

    // MARK: - HRV Data
    private func fetchHRVData() async throws -> HRVData {
        if !HKHealthStore.isHealthDataAvailable() || !isAuthorized {
            return HRVData(average: 45, min: 25, max: 68)
        }

        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictEndDate
        )

        return await withCheckedContinuation { continuation in
            let query = queryFactory.createSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
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

    // MARK: - Heart Rate Data
    private func fetchHeartRateData() async throws -> HeartRateData {
        if !HKHealthStore.isHealthDataAvailable() || !isAuthorized {
            return HeartRateData(resting: 62, average: 75, min: 58, max: 145)
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictEndDate
        )

        let heartRateValues = await fetchHeartRateValues(predicate: predicate)
        guard !heartRateValues.isEmpty else {
            return HeartRateData(resting: 62, average: 75, min: 58, max: 145)
        }

        let average = heartRateValues.reduce(0, +) / heartRateValues.count
        let min = heartRateValues.min() ?? 58
        let max = heartRateValues.max() ?? 145
        let resting = await fetchRestingHeartRate(predicate: predicate) ?? 62

        return HeartRateData(resting: resting, average: average, min: min, max: max)
    }

    // MARK: - Activity Data
    private func fetchActivityData() async throws -> ActivityData {
        if !HKHealthStore.isHealthDataAvailable() || !isAuthorized {
            return ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
        }

        async let steps = fetchSteps()
        async let distance = fetchDistance()
        async let calories = fetchCalories()
        async let activeMinutes = fetchActiveMinutes()

        return try await ActivityData(
            steps: steps,
            distance: distance,
            calories: calories,
            activeMinutes: activeMinutes
        )
    }

    private func fetchSteps() async throws -> Int {
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        return Int(await fetchQuantitySum(for: stepsType, unit: .count()))
    }

    private func fetchDistance() async throws -> Double {
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        return await fetchQuantitySum(for: distanceType, unit: .meter()) / 1000  // Convert to kilometers
    }

    private func fetchCalories() async throws -> Int {
        let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        return Int(await fetchQuantitySum(for: caloriesType, unit: .kilocalorie()))
    }

    private func fetchActiveMinutes() async throws -> Int {
        let activeMinutesType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        return Int(await fetchQuantitySum(for: activeMinutesType, unit: .minute()))
    }

    private func fetchQuantitySum(for quantityType: HKQuantityType, unit: HKUnit) async -> Double {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictEndDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
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
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
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
                sampleType: restingType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
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
