import Foundation

// MARK: - AdviceResponseDTO

/// アドバイスレスポンスDTO（API用）
struct AdviceResponseDTO: Codable, Equatable, Sendable {
    let success: Bool
    let data: AdviceDataDTO?
    let error: String?
}

// MARK: - AdviceDataDTO

/// アドバイスデータDTO
struct AdviceDataDTO: Codable, Equatable, Sendable {
    let summary: String
    let fullInsight: String
    let recommendedAction: RecommendedActionDTO

    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case summary
        case fullInsight
        case recommendedAction
    }
}

// MARK: - RecommendedActionDTO

/// 推奨アクションDTO
struct RecommendedActionDTO: Codable, Equatable, Sendable {
    let type: String
    let message: String
}

// MARK: - AdviceResponseDTO+Domain

extension AdviceResponseDTO {

    /// DTOからドメインモデルに変換
    /// - Returns: DailyAdvice（変換できない場合はnil）
    func toDomain() -> DailyAdvice? {
        guard success, let data = data else {
            return nil
        }

        guard let actionType = RecommendedAction.ActionType(rawValue: data.recommendedAction.type) else {
            return nil
        }

        let action: RecommendedAction = RecommendedAction(
            type: actionType,
            message: data.recommendedAction.message
        )

        return DailyAdvice(
            summary: data.summary,
            fullInsight: data.fullInsight,
            recommendedAction: action,
            generatedAt: Date(),
            isOfflineFallback: false
        )
    }
}

// MARK: - AdviceDataDTO+Domain

extension AdviceDataDTO {

    /// DTOからドメインモデルに変換
    /// - Returns: DailyAdvice（変換できない場合はnil）
    func toDomain() -> DailyAdvice? {
        guard let actionType = RecommendedAction.ActionType(rawValue: recommendedAction.type) else {
            return nil
        }

        let action: RecommendedAction = RecommendedAction(
            type: actionType,
            message: recommendedAction.message
        )

        return DailyAdvice(
            summary: summary,
            fullInsight: fullInsight,
            recommendedAction: action,
            generatedAt: Date(),
            isOfflineFallback: false
        )
    }
}
