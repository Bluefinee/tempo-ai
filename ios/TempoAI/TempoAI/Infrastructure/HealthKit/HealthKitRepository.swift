import Foundation
import HealthKit
import os.log

// MARK: - HealthKitRepository

/// HealthKitからのデータ取得を担当するリポジトリ
/// @unchecked Sendable: HKHealthStore is documented as thread-safe per Apple documentation
final class HealthKitRepository: HealthKitRepositoryProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let healthStore: HKHealthStore
    private static let logger: Logger = Logger(subsystem: "com.tempoai", category: "HealthKit")

    /// 必須のHealthKitデータタイプ
    private let requiredReadTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.stepCount),
        HKQuantityType(.appleExerciseTime),
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

        async let sleepTask = fetchLatestSleepSafe()
        async let hrvTask = fetchLatestHRVSafe()
        async let activityTask = fetchYesterdayActivitySafe()
        async let auxiliaryTask = fetchAuxiliaryMetricsSafe()

        let (sleep, sleepError) = await sleepTask
        let (hrv, hrvError) = await hrvTask
        let (activity, activityError) = await activityTask
        let (auxiliary, auxiliaryError) = await auxiliaryTask

        #if DEBUG
        if let error = sleepError {
            Self.logger.debug("Sleep fetch failed: \(error.localizedDescription)")
        }
        if let error = hrvError {
            Self.logger.debug("HRV fetch failed: \(error.localizedDescription)")
        }
        if let error = activityError {
            Self.logger.debug("Activity fetch failed: \(error.localizedDescription)")
        }
        if let error = auxiliaryError {
            Self.logger.debug("Auxiliary fetch failed: \(error.localizedDescription)")
        }
        #endif

        return HealthMetrics(
            date: today,
            sleep: sleep,
            hrv: hrv,
            activity: activity,
            auxiliary: auxiliary
        )
    }

    // MARK: - Safe Fetch Methods (for parallel execution with error logging)

    private func fetchLatestSleepSafe() async -> (SleepMetrics?, Error?) {
        do {
            return (try await fetchLatestSleep(), nil)
        } catch {
            return (nil, error)
        }
    }

    private func fetchLatestHRVSafe() async -> (HRVMetrics?, Error?) {
        do {
            return (try await fetchLatestHRV(), nil)
        } catch {
            return (nil, error)
        }
    }

    private func fetchYesterdayActivitySafe() async -> (ActivityMetrics?, Error?) {
        do {
            return (try await fetchYesterdayActivity(), nil)
        } catch {
            return (nil, error)
        }
    }

    private func fetchAuxiliaryMetricsSafe() async -> (AuxiliaryMetrics?, Error?) {
        do {
            return (try await fetchAuxiliaryMetrics(), nil)
        } catch {
            return (nil, error)
        }
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

        if let metrics = aggregateSleepSamples(samples) {
            return [metrics]
        }
        return []
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

        guard let latestSleep = aggregateSleepSamples(samples) else {
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

        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: yesterdayStart,
            end: yesterdayEnd,
            options: .strictStartDate
        )

        // Fetch steps
        let stepType: HKQuantityType = HKQuantityType(.stepCount)
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

        // Fetch active minutes (exercise time)
        let exerciseType: HKQuantityType = HKQuantityType(.appleExerciseTime)
        let activeMinutes: Double = try await withCheckedThrowingContinuation { continuation in
            let query: HKStatisticsQuery = HKStatisticsQuery(
                quantityType: exerciseType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    // Exercise time may not be available, return 0 instead of failing
                    #if DEBUG
                    Self.logger.debug("Exercise time query failed: \(error.localizedDescription)")
                    #endif
                    continuation.resume(returning: 0)
                    return
                }
                let sum: Double = statistics?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }

        return ActivityMetrics(stepsYesterday: Int(steps), activeMinutesYesterday: Int(activeMinutes))
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

    /// Aggregates sleep samples into a single SleepMetrics
    private func aggregateSleepSamples(_ samples: [HKCategorySample]) -> SleepMetrics? {
        guard !samples.isEmpty else { return nil }

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

        guard totalMinutes > 0 else { return nil }

        return SleepMetrics(
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: totalMinutes,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes
        )
    }
}
