import Foundation

// MARK: - Daily Advice Response Models

/**
 * Main response wrapper for advice API
 * Matches the backend AdviceResponse interface
 */
struct AdviceResponse: Codable {
    let success: Bool
    let data: AdviceResponseData?
    let error: String?
    let code: String?
}

struct AdviceResponseData: Codable {
    let mainAdvice: DailyAdvice
    let additionalAdvice: AdditionalAdvice?
}

// MARK: - Daily Advice

/**
 * Core daily advice model containing all information for the home screen
 * and detail views
 */
struct DailyAdvice: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let greeting: String
    let condition: Condition
    let actionSuggestions: [ActionSuggestion]
    let closingMessage: String
    let dailyTry: TryContent
    let weeklyTry: TryContent?
    let generatedAt: Date
    let timeSlot: TimeSlot

    private enum CodingKeys: String, CodingKey {
        case greeting, condition, actionSuggestions
        case closingMessage, dailyTry, weeklyTry
        case generatedAt, timeSlot
    }

    static func == (lhs: DailyAdvice, rhs: DailyAdvice) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Condition

struct Condition: Codable {
    let summary: String    // For home screen display
    let detail: String     // For detail view
}

// MARK: - Action Suggestion

struct ActionSuggestion: Codable, Identifiable {
    let id = UUID()
    let icon: IconType
    let title: String
    let detail: String
    
    private enum CodingKeys: String, CodingKey {
        case icon, title, detail
    }
}

enum IconType: String, Codable {
    case fitness = "fitness"
    case stretch = "stretch"
    case nutrition = "nutrition"
    case hydration = "hydration"
    case rest = "rest"
    case work = "work"
    case sleep = "sleep"
    case mental = "mental"
    case beauty = "beauty"
    case outdoor = "outdoor"
    
    var systemImageName: String {
        switch self {
        case .fitness: return "figure.strengthtraining.functional"
        case .stretch: return "figure.yoga"
        case .nutrition: return "fork.knife"
        case .hydration: return "drop.fill"
        case .rest: return "bed.double.fill"
        case .work: return "laptopcomputer"
        case .sleep: return "moon.stars.fill"
        case .mental: return "brain.head.profile"
        case .beauty: return "sparkles"
        case .outdoor: return "tree.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .fitness: return "フィットネス"
        case .stretch: return "ストレッチ"
        case .nutrition: return "栄養"
        case .hydration: return "水分補給"
        case .rest: return "休息"
        case .work: return "仕事"
        case .sleep: return "睡眠"
        case .mental: return "メンタル"
        case .beauty: return "美容"
        case .outdoor: return "アウトドア"
        }
    }
}

// MARK: - Try Content

struct TryContent: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String      // For card title
    let summary: String    // For card subtitle
    let detail: String     // For detail view

    private enum CodingKeys: String, CodingKey {
        case title, summary, detail
    }

    static func == (lhs: TryContent, rhs: TryContent) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Time Slot

enum TimeSlot: String, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    
    var displayName: String {
        switch self {
        case .morning: return "朝"
        case .afternoon: return "昼"
        case .evening: return "夜"
        }
    }
    
    var greeting: String {
        switch self {
        case .morning: return "おはようございます"
        case .afternoon: return "お疲れさまです"
        case .evening: return "お疲れさまでした"
        }
    }
}

// MARK: - Additional Advice

/**
 * Additional advice for afternoon/evening notifications
 */
struct AdditionalAdvice: Codable, Identifiable {
    let id = UUID()
    let timeSlot: TimeSlot
    let greeting: String
    let message: String
    let generatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case timeSlot, greeting, message, generatedAt
    }
}

// MARK: - Mock Data Extensions

extension DailyAdvice {
    /**
     * Creates mock daily advice for testing and development
     * Phase 7: Used for UI development before backend integration
     */
    static func createMock(timeSlot: TimeSlot = .morning) -> DailyAdvice {
        return DailyAdvice(
            greeting: "テストユーザーさん、\(timeSlot.greeting)",
            condition: Condition(
                summary: "昨夜は7時間の良質な睡眠が取れましたね。今朝のHRVは72msと高く、体の回復が十分に進んでいます。",
                detail: "昨夜は7時間の良質な睡眠が取れましたね。深い睡眠が1時間45分と、筋肉の回復に理想的な状態です。\n\n今朝のHRVは72msと、過去7日平均の68msを上回っています。体の回復が十分に進んでいます。"
            ),
            actionSuggestions: [
                ActionSuggestion(
                    icon: .fitness,
                    title: "午前中に高強度トレーニング",
                    detail: "HRVが高く、睡眠の質も良いため、パフォーマンスを最大限発揮できる状態です。"
                ),
                ActionSuggestion(
                    icon: .nutrition,
                    title: "トレーニング後の栄養補給",
                    detail: "30分以内にプロテインと炭水化物を一緒に摂ることで、筋グリコーゲンの回復が早まります。"
                )
            ],
            closingMessage: "今日は心身ともに最高のコンディションです。ぜひ全力でチャレンジしてください。",
            dailyTry: TryContent(
                title: "ドロップセット法に挑戦",
                summary: "トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？",
                detail: "今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？通常の重量でできる限界まで行った後、重量を20-30%下げてさらに限界まで続けます。"
            ),
            weeklyTry: timeSlot == .morning ? TryContent(
                title: "今週の瞑想チャレンジ",
                summary: "毎日5分の瞑想でストレス軽減",
                detail: "今週は毎日5分間の瞑想にチャレンジしてみましょう。朝起きた時や寝る前など、決まった時間に行うのがコツです。"
            ) : nil,
            generatedAt: Date(),
            timeSlot: timeSlot
        )
    }
}
