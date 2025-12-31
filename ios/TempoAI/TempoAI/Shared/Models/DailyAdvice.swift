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
}

// MARK: - Health Scores

/**
 * Health scores for HRV, sleep, rhythm, and activity
 * Each score is 0-100
 */
struct HealthScores: Codable, Hashable {
    let hrv: Int
    let sleep: Int
    let rhythm: Int
    let activity: Int

    /// Energy level based on HRV score (primary indicator)
    var energyLevel: EnergyLevel {
        EnergyLevel(hrvScore: hrv)
    }
}

// MARK: - Energy Level

enum EnergyLevel {
    case excellent    // 80-100
    case good         // 60-79
    case moderate     // 40-59
    case low          // 20-39
    case veryLow      // 0-19

    init(hrvScore: Int) {
        switch hrvScore {
        case 80...100: self = .excellent
        case 60..<80: self = .good
        case 40..<60: self = .moderate
        case 20..<40: self = .low
        default: self = .veryLow
        }
    }

    var color: String {
        switch self {
        case .excellent, .good: return "Primary"
        case .moderate: return "Yellow"
        case .low: return "Orange"
        case .veryLow: return "Red"
        }
    }

    var percentage: Double {
        switch self {
        case .excellent: return 0.9
        case .good: return 0.7
        case .moderate: return 0.5
        case .low: return 0.3
        case .veryLow: return 0.15
        }
    }
}

// MARK: - Daily Advice

/**
 * Core daily advice model containing all information for the home screen
 * and detail views (Phase 10 format)
 */
struct DailyAdvice: Codable, Identifiable, Hashable {
    /// Note: id is intentionally excluded from CodingKeys.
    /// A new UUID is generated on each decode to ensure unique identity for SwiftUI views.
    let id: UUID = UUID()
    let greeting: String
    let energyComment: String
    let condition: Condition
    let insight: String
    let dailyTry: TryContent
    let closingMessage: String
    let scores: HealthScores
    let generatedAt: Date
    let timeSlot: TimeSlot

    private enum CodingKeys: String, CodingKey {
        case greeting
        case energyComment
        case condition
        case insight
        case dailyTry
        case closingMessage
        case scores
        case generatedAt
        case timeSlot
    }

    static func == (lhs: DailyAdvice, rhs: DailyAdvice) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Condition

struct Condition: Codable, Hashable {
    let summary: String    // For home screen display
    let detail: String     // For detail view
}

// MARK: - Try Content

struct TryContent: Codable, Identifiable, Hashable {
    /// Note: id is intentionally excluded from CodingKeys.
    /// A new UUID is generated on each decode to ensure unique identity for SwiftUI views.
    /// This is by design as TryContent is embedded in DailyAdvice and doesn't need persistent identity.
    let id: UUID = UUID()
    let title: String      // For card title (15 chars max)
    let detail: String     // For detail view

    private enum CodingKeys: String, CodingKey {
        case title, detail
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

// MARK: - Mock Data Extensions

extension DailyAdvice {
    /**
     * Creates mock daily advice for testing and development
     * Phase 10: Updated format with energyComment, insight, and scores
     */
    static func createMock(timeSlot: TimeSlot = .morning, scores: HealthScores? = nil) -> DailyAdvice {
        let mockScores = scores ?? HealthScores(hrv: 85, sleep: 82, rhythm: 78, activity: 70)

        return DailyAdvice(
            greeting: "テストユーザーさん、\(timeSlot.greeting)",
            energyComment: "今日は絶好調ですね",
            condition: Condition(
                summary: "昨夜は7時間の良質な睡眠が取れましたね。今朝のHRVは72msと高く、体の回復が十分に進んでいます。",
                detail: "昨夜は7時間の良質な睡眠が取れましたね。深い睡眠が1時間45分と、筋肉の回復に理想的な状態です。\n\n今朝のHRVは72msと、過去7日平均の68msを上回っています。体の回復が十分に進んでいます。"
            ),
            insight: "昨夜は就寝が30分早かったため、HRVが+9%改善しました。3日連続でリズムが安定しているため、回復効率がアップしています。",
            dailyTry: TryContent(
                title: "ドロップセット法に挑戦",
                detail: "今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？通常の重量でできる限界まで行った後、重量を20-30%下げてさらに限界まで続けます。"
            ),
            closingMessage: "今日は心身ともに最高のコンディションです。ぜひ全力でチャレンジしてください。",
            scores: mockScores,
            generatedAt: Date(),
            timeSlot: timeSlot
        )
    }

    /**
     * Creates mock daily advice with specific HRV score for testing energy levels
     */
    static func createMock(withHrvScore hrvScore: Int) -> DailyAdvice {
        let scores = HealthScores(hrv: hrvScore, sleep: 70, rhythm: 70, activity: 70)
        return createMock(scores: scores)
    }
}
