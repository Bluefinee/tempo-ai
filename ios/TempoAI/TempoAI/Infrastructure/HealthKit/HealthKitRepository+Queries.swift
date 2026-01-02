import Foundation
import HealthKit
import os.log

// MARK: - HealthKitRepository + Private Query Implementations

extension HealthKitRepository {

    // MARK: - Sleep Queries

    func fetchLatestSleep() async throws -> SleepMetrics {
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

    /// Aggregates sleep samples into a single SleepMetrics
    func aggregateSleepSamples(_ samples: [HKCategorySample]) -> SleepMetrics? {
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

    // MARK: - HRV Queries

    func fetchLatestHRV() async throws -> HRVMetrics {
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

    // MARK: - Activity Queries

    func fetchYesterdayActivity() async throws -> ActivityMetrics {
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

    // MARK: - Auxiliary Metrics Queries

    func fetchAuxiliaryMetrics() async throws -> AuxiliaryMetrics {
        let daylight: DaylightMetrics? = try? await fetchDaylightMetrics()
        let temperature: WristTemperatureMetrics? = try? await fetchWristTemperature()

        return AuxiliaryMetrics(daylight: daylight, wristTemperature: temperature)
    }

    func fetchDaylightMetrics() async throws -> DaylightMetrics {
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

    func fetchWristTemperature() async throws -> WristTemperatureMetrics {
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

    // MARK: - Daily Metrics for Analytics

    /// 過去N日間の日別HealthMetricsを取得
    func fetchDailyMetrics(days: Int) async throws -> [HealthMetrics] {
        let calendar: Calendar = Calendar.current
        let today: Date = calendar.startOfDay(for: Date())

        var dailyMetrics: [HealthMetrics] = []

        for dayOffset in (0..<days).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            let metrics: HealthMetrics = await fetchMetricsForDate(targetDate)
            dailyMetrics.append(metrics)
        }

        return dailyMetrics
    }

    /// 特定日のHealthMetricsを取得
    private func fetchMetricsForDate(_ date: Date) async -> HealthMetrics {
        let calendar: Calendar = Calendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else {
            return HealthMetrics(date: date, sleep: nil, hrv: nil, activity: nil, auxiliary: nil)
        }

        async let sleepTask = fetchSleepForDateRangeSafe(start: date, end: nextDay)
        async let hrvTask = fetchHRVForDateRangeSafe(start: date, end: nextDay)
        async let activityTask = fetchActivityForDateRangeSafe(start: date, end: nextDay)

        let sleep: SleepMetrics? = await sleepTask
        let hrv: HRVMetrics? = await hrvTask
        let activity: ActivityMetrics? = await activityTask

        return HealthMetrics(
            date: date,
            sleep: sleep,
            hrv: hrv,
            activity: activity,
            auxiliary: nil
        )
    }

    private func fetchSleepForDateRangeSafe(start: Date, end: Date) async -> SleepMetrics? {
        let sleepType: HKCategoryType = HKCategoryType(.sleepAnalysis)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        do {
            let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
                let query: HKSampleQuery = HKSampleQuery(
                    sampleType: sleepType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
                }
                healthStore.execute(query)
            }
            return aggregateSleepSamples(samples)
        } catch {
            return nil
        }
    }

    private func fetchHRVForDateRangeSafe(start: Date, end: Date) async -> HRVMetrics? {
        let hrvType: HKQuantityType = HKQuantityType(.heartRateVariabilitySDNN)
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        do {
            let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { continuation in
                let query: HKSampleQuery = HKSampleQuery(
                    sampleType: hrvType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
                }
                healthStore.execute(query)
            }

            guard !samples.isEmpty else { return nil }

            // 日のHRV平均値を計算
            let total: Double = samples.reduce(0) { sum, sample in
                sum + sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            }
            let average: Double = total / Double(samples.count)
            let baseline: Double = (try? await fetchHRVBaseline(days: 30)) ?? 50.0

            return HRVMetrics(value: average, baseline30d: baseline)
        } catch {
            return nil
        }
    }

    private func fetchActivityForDateRangeSafe(start: Date, end: Date) async -> ActivityMetrics? {
        let predicate: NSPredicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        // Fetch steps
        let stepType: HKQuantityType = HKQuantityType(.stepCount)
        let steps: Int = await withCheckedContinuation { continuation in
            let query: HKStatisticsQuery = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                let sum: Double = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(sum))
            }
            healthStore.execute(query)
        }

        // Fetch active minutes
        let exerciseType: HKQuantityType = HKQuantityType(.appleExerciseTime)
        let activeMinutes: Int = await withCheckedContinuation { continuation in
            let query: HKStatisticsQuery = HKStatisticsQuery(
                quantityType: exerciseType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                let sum: Double = statistics?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0
                continuation.resume(returning: Int(sum))
            }
            healthStore.execute(query)
        }

        return ActivityMetrics(stepsYesterday: steps, activeMinutesYesterday: activeMinutes)
    }
}
