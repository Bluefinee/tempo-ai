import XCTest
@testable import TempoAI

// MARK: - AdviceResponseDTO Tests

final class AdviceResponseDTOTests: XCTestCase {

    func testToDomainSuccess() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: true,
            data: AdviceDataDTO(
                summary: "サマリー",
                fullInsight: "インサイト",
                recommendedAction: RecommendedActionDTO(
                    type: "breathing",
                    message: "深呼吸"
                )
            ),
            error: nil
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNotNil(advice)
        XCTAssertEqual(advice?.summary, "サマリー")
        XCTAssertEqual(advice?.fullInsight, "インサイト")
        XCTAssertEqual(advice?.recommendedAction.type, .breathing)
        XCTAssertEqual(advice?.recommendedAction.message, "深呼吸")
        XCTAssertFalse(advice?.isOfflineFallback ?? true)
    }

    func testToDomainFailureNotSuccess() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: false,
            data: nil,
            error: "エラー"
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNil(advice)
    }

    func testToDomainFailureInvalidActionType() {
        let dto: AdviceResponseDTO = AdviceResponseDTO(
            success: true,
            data: AdviceDataDTO(
                summary: "サマリー",
                fullInsight: "インサイト",
                recommendedAction: RecommendedActionDTO(
                    type: "invalid",
                    message: "メッセージ"
                )
            ),
            error: nil
        )

        let advice: DailyAdvice? = dto.toDomain()

        XCTAssertNil(advice)
    }

    func testAdviceDataDTOToDomain() {
        let dataDTO: AdviceDataDTO = AdviceDataDTO(
            summary: "サマリー",
            fullInsight: "インサイト",
            recommendedAction: RecommendedActionDTO(
                type: "morning_light",
                message: "朝の光"
            )
        )

        let advice: DailyAdvice? = dataDTO.toDomain()

        XCTAssertNotNil(advice)
        XCTAssertEqual(advice?.recommendedAction.type, .morningLight)
    }
}
