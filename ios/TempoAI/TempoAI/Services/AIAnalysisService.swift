import Combine
import Foundation

struct AnalysisRequest: Codable {
    let userMode: UserMode
    let batteryData: HumanBattery
    let healthData: HealthData
    let weatherData: WeatherData?
    let activeTags: [String]
    let timestamp: Date
}

struct AnalysisResponse: Codable {
    let headline: AdviceHeadlineResponse
    let batteryComment: String
    let detailedAnalysis: String
    let recommendations: [Recommendation]
}

struct AdviceHeadlineResponse: Codable {
    let title: String
    let subtitle: String
    let impactLevel: String
}

struct Recommendation: Codable {
    let id: String
    let tag: String?
    let title: String
    let description: String
    let priority: String
}

@MainActor
class AIAnalysisService: ObservableObject {
    @Published var currentAdvice: AnalysisResponse?
    @Published var isAnalyzing = false

    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func requestAnalysis(
        userMode: UserMode,
        battery: HumanBattery,
        health: HealthData,
        weather: WeatherData?,
        activeTags: Set<FocusTag>
    ) async -> AnalysisResponse? {
        isAnalyzing = true
        defer { isAnalyzing = false }

        let request = AnalysisRequest(
            userMode: userMode,
            batteryData: battery,
            healthData: health,
            weatherData: weather,
            activeTags: activeTags.map { $0.rawValue },
            timestamp: Date()
        )

        do {
            let response = try await apiClient.requestAnalysis(request)
            currentAdvice = response
            return response
        } catch {
            return createFallbackAdvice(for: battery)
        }
    }

    private func createFallbackAdvice(for battery: HumanBattery) -> AnalysisResponse {
        let headline = AdviceHeadlineResponse(
            title: battery.state == .high ? "エネルギー充分" : "バッテリー低下",
            subtitle: battery.state == .high ? "今日は積極的に活動できます" : "休息を取ることをお勧めします",
            impactLevel: battery.state == .critical ? "high" : "medium"
        )

        return AnalysisResponse(
            headline: headline,
            batteryComment: battery.batteryComment,
            detailedAnalysis: "詳細な分析はオンライン時に利用可能です。",
            recommendations: []
        )
    }
}

@MainActor
class APIClient {
    private let baseURL = URL(string: "https://your-backend-url.com")!

    func requestAnalysis(_ request: AnalysisRequest) async throws -> AnalysisResponse {
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let mockResponse = AnalysisResponse(
            headline: AdviceHeadlineResponse(
                title: "気圧低下注意",
                subtitle: "頭痛が起きやすい状態です。重要なタスクは早めに。",
                impactLevel: "medium"
            ),
            batteryComment: "午後にかけて急速に減る予測です",
            detailedAnalysis: "現在の気圧低下により、エネルギー消費が通常より15%高くなっています。",
            recommendations: [
                Recommendation(
                    id: UUID().uuidString,
                    tag: "work",
                    title: "集中作業の前倒し",
                    description: "気圧低下による頭痛前に重要タスクを完了させることをお勧めします。",
                    priority: "medium"
                )
            ]
        )

        return mockResponse
    }
}
