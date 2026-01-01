import XCTest
@testable import TempoAI

// MARK: - AdviceRequestDTO Tests

final class AdviceRequestDTOTests: XCTestCase {

    func testProfileDTOFromDomain() {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = DateComponents()
        components.hour = 23
        components.minute = 0
        let targetBedtime: Date = calendar.date(from: components)!

        let profile: UserProfile = UserProfile(
            nickname: "テスト",
            age: 28,
            gender: .male,
            weight: 70.0,
            height: 175.0,
            occupation: .deskWork,
            chronotype: .morning,
            exerciseFrequency: .twiceWeek,
            alcoholFrequency: nil,
            targetBedtime: targetBedtime
        )

        let dto: ProfileDTO = ProfileDTO.from(profile)

        XCTAssertEqual(dto.nickname, "テスト")
        XCTAssertEqual(dto.age, 28)
        XCTAssertEqual(dto.gender, "male")
        XCTAssertEqual(dto.chronotype, "morning")
        XCTAssertEqual(dto.occupation, "deskWork")
        XCTAssertEqual(dto.exerciseFrequency, "twiceWeek")
        XCTAssertEqual(dto.targetBedtime, "23:00")
    }

    func testRhythmAnalysisDTOFromDomain() {
        let analysis: RhythmAnalysis = RhythmAnalysis(
            bedtimeStddevMinutes: 22.5,
            wakeTimeStddevMinutes: 18.3,
            consecutiveStableDays: 5,
            wristTemperature: nil
        )

        let dto: RhythmAnalysisDTO = RhythmAnalysisDTO.from(analysis)

        XCTAssertEqual(dto.bedtimeStddevMinutes, 22.5)
        XCTAssertEqual(dto.wakeTimeStddevMinutes, 18.3)
        XCTAssertEqual(dto.consecutiveStableDays, 5)
        XCTAssertEqual(dto.status, "stable")
    }

    func testSleepDTOFromDomain() {
        let bedtime: Date = Date(timeIntervalSince1970: 1704067200)  // 2024-01-01 00:00
        let wakeTime: Date = Date(timeIntervalSince1970: 1704092400)  // 2024-01-01 07:00

        let sleep: SleepMetrics = SleepMetrics(
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: 420,
            deepSleepMinutes: 90,
            remSleepMinutes: 100
        )

        let dto: SleepDTO = SleepDTO.from(sleep)

        XCTAssertEqual(dto.durationHours, 7.0)
        XCTAssertEqual(dto.deepSleepMinutes, 90)
        XCTAssertEqual(dto.remSleepMinutes, 100)
        XCTAssertEqual(dto.deepSleepRatio, 90.0 / 420.0, accuracy: 0.01)
    }

    func testHRVDTOFromDomain() {
        let hrv: HRVMetrics = HRVMetrics(
            value: 68.0,
            baseline30d: 62.0
        )

        let dto: HRVDTO = HRVDTO.from(hrv)

        XCTAssertEqual(dto.value, 68.0)
        XCTAssertEqual(dto.baseline30d, 62.0)
        XCTAssertEqual(dto.deviationPercent, ((68.0 - 62.0) / 62.0) * 100, accuracy: 0.1)
    }

    func testActivityDTOFromDomain() {
        let activity: ActivityMetrics = ActivityMetrics(
            stepsYesterday: 8500,
            activeMinutesYesterday: 45
        )

        let dto: ActivityDTO = ActivityDTO.from(activity)

        XCTAssertEqual(dto.stepsYesterday, 8500)
        XCTAssertEqual(dto.activeMinutesYesterday, 45)
    }
}
