import Foundation
import HealthKit

// MARK: - HealthKitRepository

/// HealthKitからのデータ取得を担当するリポジトリ
final class HealthKitRepository: HealthKitRepositoryProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let healthStore: HKHealthStore

    /// 必須のHealthKitデータタイプ
    private let requiredReadTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis)
    ]

    /// オプションのHealthKitデータタイプ
    private let optionalReadTypes: Set<HKObjectType> = [
        HKQuantityType(.timeInDaylight),
        HKQuantityType(.appleSleepingWristTemperature)
    ]

    /// すべての読み取りタイプ
    private var allReadTypes: Set<HKObjectType> {
        requiredReadTypes.union(optionalReadTypes)
    }

    // MARK: - Initialization

    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }

    // MARK: - Public Methods

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: [], read: allReadTypes)
    }

    func fetchTodayMetrics() async throws -> HealthMetrics {
        let today: Date = Date()

        async let sleepData = fetchLatestSleep()
        async let hrvData = fetchLatestHRV()
        async let activityData = fetchYesterdayActivity()
        async let auxiliaryData = fetchAuxiliaryMetrics()

        return HealthMetrics(
            date: today,
            sleep: try? await sleepData,
            hrv: try? await hrvData,
            activity: try? await activityData,
            auxiliary: try? await auxiliaryData
        )
    }

    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics] {
        let calendar: Calendar = Calendar.current
        let endDate: Date = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthKitError.dataUnavailable
        }

        let sleepType: HKCategoryType = HKCategoryType(.sleepAnalysis)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query: HKSampleQuery = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        return groupSamplesIntoSleepMetrics(samples)
    }

    func fetchHRVBaseline(days: Int) async throws -> Double {
        let calendar: Calendar = Calendar.current
        let endDate: Date = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthKitError.dataUnavailable
        }

        let hrvType: HKQuantityType = HKQuantityType(.heartRateVariabilitySDNN)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { continuation in
            let query: HKSampleQuery = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }

        guard !samples.isEmpty else {
            throw HealthKitError.insufficientData
        }

        let total: Double = samples.reduce(0) { sum, sample in
            sum + sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
        }

        return total / Double(samples.count)
    }

    // MARK: - Private Methods

    private func fetchLatestSleep() async throws -> SleepMetrics {
        let calendar: Calendar = Calendar.current
        let endDate: Date = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw HealthKitError.dataUnavailable
        }

        let sleepType: HKCategoryType = HKCategoryType(.sleepAnalysis)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query: HKSampleQuery = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        let sleepMetricsList: [SleepMetrics] = groupSamplesIntoSleepMetrics(samples)
        guard let latestSleep = sleepMetricsList.first else {
            throw HealthKitError.dataUnavailable
        }

        return latestSleep
    }

    private func fetchLatestHRV() async throws -> HRVMetrics {
        let calendar: Calendar = Calendar.current
        let endDate: Date = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw HealthKitError.dataUnavailable
        }

        let hrvType: HKQuantityType = HKQuantityType(.heartRateVariabilitySDNN)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { continuation in
            let query: HKSampleQuery = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }

        guard let latestSample = samples.first else {
            throw HealthKitError.dataUnavailable
        }

        let currentHRV: Double = latestSample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
        let baseline: Double = (try? await fetchHRVBaseline(days: 30)) ?? 50.0

        return HRVMetrics(value: currentHRV, baseline30d: baseline)
    }

    private func fetchYesterdayActivity() async throws -> ActivityMetrics {
        let calendar: Calendar = Calendar.current
        let now: Date = Date()
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)),
              let yesterdayEnd = calendar.date(byAdding: .day, value: 1, to: yesterdayStart) else {
            throw HealthKitError.dataUnavailable
        }

        let stepType: HKQuantityType = HKQuantityType(.stepCount)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: yesterdayStart,
            end: yesterdayEnd,
            options: .strictStartDate
        )

        let steps: Double = try await withCheckedThrowingContinuation { continuation in
            let query: HKStatisticsQuery = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                let sum: Double = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }

        return ActivityMetrics(stepsYesterday: Int(steps), activeMinutesYesterday: 0)
    }

    private func fetchAuxiliaryMetrics() async throws -> AuxiliaryMetrics {
        let daylight: DaylightMetrics? = try? await fetchDaylightMetrics()
        let temperature: WristTemperatureMetrics? = try? await fetchWristTemperature()

        return AuxiliaryMetrics(daylight: daylight, wristTemperature: temperature)
    }

    private func fetchDaylightMetrics() async throws -> DaylightMetrics {
        let calendar: Calendar = Calendar.current
        let now: Date = Date()
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)),
              let yesterdayEnd = calendar.date(byAdding: .day, value: 1, to: yesterdayStart) else {
            throw HealthKitError.dataUnavailable
        }

        let daylightType: HKQuantityType = HKQuantityType(.timeInDaylight)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: yesterdayStart,
            end: yesterdayEnd,
            options: .strictStartDate
        )

        let minutes: Double = try await withCheckedThrowingContinuation { continuation in
            let query: HKStatisticsQuery = HKStatisticsQuery(
                quantityType: daylightType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                let sum: Double = statistics?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }

        return DaylightMetrics(minutesYesterday: Int(minutes))
    }

    private func fetchWristTemperature() async throws -> WristTemperatureMetrics {
        let calendar: Calendar = Calendar.current
        let endDate: Date = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw HealthKitError.dataUnavailable
        }

        let tempType: HKQuantityType = HKQuantityType(.appleSleepingWristTemperature)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { continuation in
            let query: HKSampleQuery = HKSampleQuery(
                sampleType: tempType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }

        guard let latestSample = samples.first else {
            throw HealthKitError.dataUnavailable
        }

        let deviation: Double = latestSample.quantity.doubleValue(for: HKUnit.degreeCelsius())
        return WristTemperatureMetrics(deviation: deviation)
    }

    private func groupSamplesIntoSleepMetrics(_ samples: [HKCategorySample]) -> [SleepMetrics] {
        guard !samples.isEmpty else { return [] }

        var deepSleepMinutes: Int = 0
        var remSleepMinutes: Int = 0
        var totalMinutes: Int = 0
        var bedtime: Date = samples.first?.startDate ?? Date()
        var wakeTime: Date = samples.last?.endDate ?? Date()

        for sample in samples {
            let duration: Int = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)

            if sample.startDate < bedtime {
                bedtime = sample.startDate
            }
            if sample.endDate > wakeTime {
                wakeTime = sample.endDate
            }

            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleepMinutes += duration
                totalMinutes += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleepMinutes += duration
                totalMinutes += duration
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                totalMinutes += duration
            case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                totalMinutes += duration
            default:
                break
            }
        }

        guard totalMinutes > 0 else { return [] }

        let sleepMetrics: SleepMetrics = SleepMetrics(
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: totalMinutes,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes
        )

        return [sleepMetrics]
    }
}
