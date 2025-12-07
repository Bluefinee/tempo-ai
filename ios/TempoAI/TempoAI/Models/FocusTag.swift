import Combine
import Foundation

enum FocusTag: String, Codable, CaseIterable {
    case work
    case beauty
    case diet
    case chill

    var emoji: String {
        switch self {
        case .work: return "🧠"
        case .beauty: return "✨"
        case .diet: return "🥗"
        case .chill: return "🍃"
        }
    }

    var displayName: String {
        switch self {
        case .work: return "深い集中（仕事）"
        case .beauty: return "美容・肌"
        case .diet: return "食事・代謝"
        case .chill: return "リラックス"
        }
    }

    var description: String {
        switch self {
        case .work: return "脳のパフォーマンスと集中力ウィンドウを最適化"
        case .beauty: return "水分補給、睡眠ホルモン、肌の健康に焦点"
        case .diet: return "食事タイミング、代謝、カロリー収支を管理"
        case .chill: return "自律神経バランス、入浴、サウナ、リセット"
        }
    }

    var analysisLens: AnalysisLens {
        switch self {
        case .work:
            return AnalysisLens(
                focusAreas: ["脳のパフォーマンス", "集中力ウィンドウ", "認知負荷"],
                keyMetrics: ["HRV", "睡眠効率", "ストレスレベル"],
                environmentFactors: ["気圧", "騒音レベル"]
            )
        case .beauty:
            return AnalysisLens(
                focusAreas: ["肌の水分量", "成長ホルモン分泌", "UV暴露"],
                keyMetrics: ["深い睡眠", "水分摂取", "日光暴露"],
                environmentFactors: ["湿度", "UV指数", "気温"]
            )
        case .diet:
            return AnalysisLens(
                focusAreas: ["代謝タイミング", "消化効率", "血糖値安定"],
                keyMetrics: ["活動カロリー", "食事タイミング", "心拍数変動"],
                environmentFactors: ["気温", "湿度"]
            )
        case .chill:
            return AnalysisLens(
                focusAreas: ["自律神経バランス", "回復促進", "メンタルリセット"],
                keyMetrics: ["HRV", "深い睡眠", "ストレス回復"],
                environmentFactors: ["気圧", "湿度", "気温"]
            )
        }
    }
}

struct AnalysisLens {
    let focusAreas: [String]
    let keyMetrics: [String]
    let environmentFactors: [String]
}

@MainActor
class FocusTagManager: ObservableObject {
    static let shared: FocusTagManager = FocusTagManager()

    @Published var activeTags: Set<FocusTag> = []
    @Published var hasCompletedOnboarding: Bool = false

    private let userDefaults: UserDefaults = UserDefaults.standard
    private let tagsKey: String = "active_focus_tags"
    private let onboardingKey: String = "focus_tags_onboarding_completed"

    private init() {
        loadActiveTags()
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
    }

    func toggleTag(_ tag: FocusTag) {
        if activeTags.remove(tag) == nil {
            activeTags.insert(tag)
        }
        saveActiveTags()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
        saveActiveTags()
    }

    private func saveActiveTags() {
        let tagStrings = activeTags.map { $0.rawValue }
        userDefaults.set(tagStrings, forKey: tagsKey)
    }

    private func loadActiveTags() {
        if let tagStrings = userDefaults.array(forKey: tagsKey) as? [String] {
            activeTags = Set(tagStrings.compactMap { FocusTag(rawValue: $0) })
        }
    }
}
