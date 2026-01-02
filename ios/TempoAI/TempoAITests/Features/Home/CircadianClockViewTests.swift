//
//  CircadianClockViewTests.swift
//  TempoAITests
//
//  Tests for CircadianClockView calculations
//

import XCTest
@testable import TempoAI

// MARK: - CircadianClockViewTests

final class CircadianClockViewTests: XCTestCase {

    // MARK: - Activity Zone Tests

    func testActivityZone_MorningType_StartsAt6() {
        let zoneStart: Int = CircadianClockCalculations.activityZoneStart(for: .morning)
        XCTAssertEqual(zoneStart, 6)
    }

    func testActivityZone_MorningType_EndsAt18() {
        let zoneEnd: Int = CircadianClockCalculations.activityZoneEnd(for: .morning)
        XCTAssertEqual(zoneEnd, 18)
    }

    func testActivityZone_IntermediateType_StartsAt8() {
        let zoneStart: Int = CircadianClockCalculations.activityZoneStart(for: .intermediate)
        XCTAssertEqual(zoneStart, 8)
    }

    func testActivityZone_IntermediateType_EndsAt20() {
        let zoneEnd: Int = CircadianClockCalculations.activityZoneEnd(for: .intermediate)
        XCTAssertEqual(zoneEnd, 20)
    }

    func testActivityZone_EveningType_StartsAt10() {
        let zoneStart: Int = CircadianClockCalculations.activityZoneStart(for: .evening)
        XCTAssertEqual(zoneStart, 10)
    }

    func testActivityZone_EveningType_EndsAt22() {
        let zoneEnd: Int = CircadianClockCalculations.activityZoneEnd(for: .evening)
        XCTAssertEqual(zoneEnd, 22)
    }

    // MARK: - Angle Calculation Tests

    func testAngle_Midnight_IsMinusPi() {
        // 0時 = 上（-π/2 in standard, 0° in our system starting from top）
        let angle: Double = CircadianClockCalculations.angleForHour(0)
        XCTAssertEqual(angle, -.pi / 2, accuracy: 0.001)
    }

    func testAngle_6AM_IsZero() {
        // 6時 = 右（0° from top clockwise = π/2 - π/2 = 0）
        // Actually 6/24 * 2π = π/2, but from top: π/2 - π/2 = 0
        let angle: Double = CircadianClockCalculations.angleForHour(6)
        let expected: Double = (6.0 / 24.0) * 2 * .pi - .pi / 2
        XCTAssertEqual(angle, expected, accuracy: 0.001)
    }

    func testAngle_12Noon_IsPiHalf() {
        // 12時 = 下（12/24 * 2π - π/2 = π - π/2 = π/2）
        let angle: Double = CircadianClockCalculations.angleForHour(12)
        let expected: Double = (12.0 / 24.0) * 2 * .pi - .pi / 2
        XCTAssertEqual(angle, expected, accuracy: 0.001)
    }

    func testAngle_18PM_IsPi() {
        // 18時 = 左（18/24 * 2π - π/2 = 3π/2 - π/2 = π）
        let angle: Double = CircadianClockCalculations.angleForHour(18)
        let expected: Double = (18.0 / 24.0) * 2 * .pi - .pi / 2
        XCTAssertEqual(angle, expected, accuracy: 0.001)
    }

    // MARK: - Current Hour Angle Tests

    func testCurrentAngle_CalculatesCorrectly() {
        // Create a date for 12:00 noon with fixed date to avoid timezone issues
        var components: DateComponents = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        components.hour = 12
        components.minute = 0
        components.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let calendar: Calendar = Calendar.current
        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let angle: Double = CircadianClockCalculations.angleForDate(date)
        let expected: Double = (12.0 / 24.0) * 2 * .pi - .pi / 2
        XCTAssertEqual(angle, expected, accuracy: 0.01)
    }

    func testCurrentAngle_IncludesMinutes() {
        // 12:30 should be slightly past 12:00 with fixed date
        var components: DateComponents = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        components.hour = 12
        components.minute = 30
        components.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let calendar: Calendar = Calendar.current
        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let angle: Double = CircadianClockCalculations.angleForDate(date)
        let expected: Double = (12.5 / 24.0) * 2 * .pi - .pi / 2
        XCTAssertEqual(angle, expected, accuracy: 0.01)
    }

    // MARK: - Accessibility Label Tests

    func testAccessibilityLabel_MorningType_DescribesZones() {
        let label: String = CircadianClockCalculations.accessibilityLabel(
            for: .morning,
            currentHour: 10
        )
        XCTAssertTrue(label.contains("6時"))
        XCTAssertTrue(label.contains("18時"))
        XCTAssertTrue(label.contains("活動"))
    }

    func testAccessibilityLabel_IncludesCurrentTime() {
        let label: String = CircadianClockCalculations.accessibilityLabel(
            for: .intermediate,
            currentHour: 14
        )
        XCTAssertTrue(label.contains("14時"))
    }

    func testAccessibilityLabel_InActivityZone_SaysActive() {
        // 10時 is in activity zone for all chronotypes
        let label: String = CircadianClockCalculations.accessibilityLabel(
            for: .morning,
            currentHour: 10
        )
        XCTAssertTrue(label.contains("活動"))
    }

    func testAccessibilityLabel_InRestZone_SaysRest() {
        // 23時 is in rest zone for all chronotypes
        let label: String = CircadianClockCalculations.accessibilityLabel(
            for: .morning,
            currentHour: 23
        )
        XCTAssertTrue(label.contains("休息"))
    }

    // MARK: - Zone Check Tests

    func testIsInActivityZone_Morning_10AM_ReturnsTrue() {
        let result: Bool = CircadianClockCalculations.isInActivityZone(
            hour: 10,
            chronotype: .morning
        )
        XCTAssertTrue(result)
    }

    func testIsInActivityZone_Morning_22PM_ReturnsFalse() {
        let result: Bool = CircadianClockCalculations.isInActivityZone(
            hour: 22,
            chronotype: .morning
        )
        XCTAssertFalse(result)
    }

    func testIsInActivityZone_Evening_21PM_ReturnsTrue() {
        // Evening type: 10-22, but the range is hour >= start && hour < end
        // So 21 is the last hour that returns true
        let result: Bool = CircadianClockCalculations.isInActivityZone(
            hour: 21,
            chronotype: .evening
        )
        XCTAssertTrue(result)
    }

    func testIsInActivityZone_Evening_5AM_ReturnsFalse() {
        let result: Bool = CircadianClockCalculations.isInActivityZone(
            hour: 5,
            chronotype: .evening
        )
        XCTAssertFalse(result)
    }
}
