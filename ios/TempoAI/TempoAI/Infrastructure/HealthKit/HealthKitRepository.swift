import Foundation
import HealthKit
import os.log

// MARK: - HealthKitRepository

/// HealthKitからのデータ取得を担当するリポジトリ
/// @unchecked Sendable: HKHealthStore is documented as thread-safe per Apple documentation
final class HealthKitRepository: HealthKitRepositoryProtocol, @unchecked Sendable {

    // MARK: - Properties

    let healthStore: HKHealthStore
    static let logger: Logger = Logger(subsystem: "com.tempoai", category: "HealthKit")

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
}
