import XCTest
@testable import TempoAI

final class DailyAdviceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testDailyAdviceInitialization() {
        let action: RecommendedAction = RecommendedAction(
            type: .breathing,
            message: "深呼吸をしましょう"
        )
        let date: Date = Date()
        let advice: DailyAdvice = DailyAdvice(
            summary: "今日のコンディションは良好です。",
            fullInsight: "詳細なインサイト...",
            recommendedAction: action,
            generatedAt: date,
            isOfflineFallback: false
        )

        XCTAssertEqual(advice.summary, "今日のコンディションは良好です。")
        XCTAssertEqual(advice.fullInsight, "詳細なインサイト...")
        XCTAssertEqual(advice.recommendedAction.type, .breathing)
        XCTAssertEqual(advice.recommendedAction.message, "深呼吸をしましょう")
        XCTAssertEqual(advice.generatedAt, date)
        XCTAssertFalse(advice.isOfflineFallback)
    }

    func testDailyAdviceDefaultValues() {
        let action: RecommendedAction = RecommendedAction(
            type: .rest,
            message: "休憩しましょう"
        )
        let advice: DailyAdvice = DailyAdvice(
            summary: "サマリー",
            fullInsight: "フルインサイト",
            recommendedAction: action
        )

        XCTAssertFalse(advice.isOfflineFallback)
        XCTAssertNotNil(advice.generatedAt)
    }

    // MARK: - RecommendedAction Tests

    func testActionTypeBreathing() {
        let actionType: RecommendedAction.ActionType = .breathing
        XCTAssertEqual(actionType.rawValue, "breathing")
        XCTAssertEqual(actionType.icon, "wind")
        XCTAssertEqual(actionType.displayName, "深呼吸")
    }

    func testActionTypeMorningLight() {
        let actionType: RecommendedAction.ActionType = .morningLight
        XCTAssertEqual(actionType.rawValue, "morning_light")
        XCTAssertEqual(actionType.icon, "sun.max")
        XCTAssertEqual(actionType.displayName, "朝の光")
    }

    func testActionTypeRest() {
        let actionType: RecommendedAction.ActionType = .rest
        XCTAssertEqual(actionType.rawValue, "rest")
        XCTAssertEqual(actionType.icon, "moon.zzz")
        XCTAssertEqual(actionType.displayName, "休息")
    }

    func testActionTypeActivity() {
        let actionType: RecommendedAction.ActionType = .activity
        XCTAssertEqual(actionType.rawValue, "activity")
        XCTAssertEqual(actionType.icon, "figure.walk")
        XCTAssertEqual(actionType.displayName, "活動")
    }

    // MARK: - Codable Tests

    func testDailyAdviceEncodeDecode() throws {
        let action: RecommendedAction = RecommendedAction(
            type: .morningLight,
            message: "朝の光を浴びましょう"
        )
        let original: DailyAdvice = DailyAdvice(
            summary: "エンコードテスト",
            fullInsight: "デコードテスト",
            recommendedAction: action,
            generatedAt: Date(timeIntervalSince1970: 1704067200),
            isOfflineFallback: false
        )

        let encoder: JSONEncoder = JSONEncoder()
        let data: Data = try encoder.encode(original)

        let decoder: JSONDecoder = JSONDecoder()
        let decoded: DailyAdvice = try decoder.decode(DailyAdvice.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testRecommendedActionEncodeDecode() throws {
        let original: RecommendedAction = RecommendedAction(
            type: .activity,
            message: "散歩しましょう"
        )

        let encoder: JSONEncoder = JSONEncoder()
        let data: Data = try encoder.encode(original)

        let decoder: JSONDecoder = JSONDecoder()
        let decoded: RecommendedAction = try decoder.decode(RecommendedAction.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testActionTypeDecodeFromRawValue() throws {
        let json: String = """
        "morning_light"
        """
        let data: Data = json.data(using: .utf8)!
        let decoder: JSONDecoder = JSONDecoder()
        let actionType: RecommendedAction.ActionType = try decoder.decode(
            RecommendedAction.ActionType.self,
            from: data
        )
        XCTAssertEqual(actionType, .morningLight)
    }

    // MARK: - Fallback Tests

    func testFallbackAdvice() {
        let fallback: DailyAdvice = DailyAdvice.fallback()

        XCTAssertTrue(fallback.isOfflineFallback)
        XCTAssertFalse(fallback.summary.isEmpty)
        XCTAssertFalse(fallback.fullInsight.isEmpty)
        XCTAssertEqual(fallback.recommendedAction.type, .breathing)
        XCTAssertNotNil(fallback.generatedAt)
    }

    // MARK: - Equatable Tests

    func testDailyAdviceEquality() {
        let date: Date = Date(timeIntervalSince1970: 1704067200)
        let action: RecommendedAction = RecommendedAction(
            type: .rest,
            message: "休憩"
        )

        let advice1: DailyAdvice = DailyAdvice(
            summary: "サマリー",
            fullInsight: "インサイト",
            recommendedAction: action,
            generatedAt: date,
            isOfflineFallback: false
        )

        let advice2: DailyAdvice = DailyAdvice(
            summary: "サマリー",
            fullInsight: "インサイト",
            recommendedAction: action,
            generatedAt: date,
            isOfflineFallback: false
        )

        XCTAssertEqual(advice1, advice2)
    }

    func testDailyAdviceInequality() {
        let date: Date = Date(timeIntervalSince1970: 1704067200)
        let action: RecommendedAction = RecommendedAction(
            type: .rest,
            message: "休憩"
        )

        let advice1: DailyAdvice = DailyAdvice(
            summary: "サマリー1",
            fullInsight: "インサイト",
            recommendedAction: action,
            generatedAt: date,
            isOfflineFallback: false
        )

        let advice2: DailyAdvice = DailyAdvice(
            summary: "サマリー2",
            fullInsight: "インサイト",
            recommendedAction: action,
            generatedAt: date,
            isOfflineFallback: false
        )

        XCTAssertNotEqual(advice1, advice2)
    }

    // MARK: - Description Tests

    func testDailyAdviceDescription() {
        let action: RecommendedAction = RecommendedAction(
            type: .breathing,
            message: "深呼吸"
        )
        let advice: DailyAdvice = DailyAdvice(
            summary: "今日のコンディションは良好です。",
            fullInsight: "インサイト",
            recommendedAction: action,
            isOfflineFallback: false
        )

        let description: String = advice.description

        XCTAssertTrue(description.contains("今日のコンディションは良好です。"))
        XCTAssertTrue(description.contains("深呼吸"))
        XCTAssertFalse(description.contains("offline fallback"))
    }

    func testFallbackAdviceDescription() {
        let fallback: DailyAdvice = DailyAdvice.fallback()
        let description: String = fallback.description

        XCTAssertTrue(description.contains("offline fallback"))
    }
}
