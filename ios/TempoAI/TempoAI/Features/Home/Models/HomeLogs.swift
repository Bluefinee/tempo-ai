//
//  HomeLogs.swift
//  TempoAI
//
//  Home画面で使用するログモデル
//

import Foundation

/// 気分ログ
struct MoodLog: Codable, Sendable {
    let date: Date
    let mood: Mood
}

/// 今日のモードログ
struct TodayModeLog: Codable, Sendable {
    let date: Date
    let mode: TodayMode
}

/// フィードバックログ
struct FeedbackLog: Codable, Sendable {
    let date: Date
    let isHelpful: Bool
    let adviceSummary: String?
}
