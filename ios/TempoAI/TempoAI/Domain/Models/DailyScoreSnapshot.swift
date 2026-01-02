//
//  DailyScoreSnapshot.swift
//  TempoAI
//
//  日別スコアスナップショット（グラフ表示用）
//

import Foundation

// MARK: - DailyScoreSnapshot

/// 日別のスコアデータを保持するスナップショット
/// - Note: Analytics画面のスコアトレンドグラフで使用
struct DailyScoreSnapshot: Identifiable, Codable, Equatable, Sendable {

    // MARK: - Properties

    let id: UUID
    let date: Date
    let autonomicScore: Int
    let sleepScore: Int
    let rhythmScore: Int
    let activityScore: Int

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date,
        autonomicScore: Int,
        sleepScore: Int,
        rhythmScore: Int,
        activityScore: Int
    ) {
        self.id = id
        self.date = date
        self.autonomicScore = Self.clamp(autonomicScore)
        self.sleepScore = Self.clamp(sleepScore)
        self.rhythmScore = Self.clamp(rhythmScore)
        self.activityScore = Self.clamp(activityScore)
    }

    // MARK: - Private Helpers

    /// 値を0-100の範囲にクランプ
    private static func clamp(_ value: Int) -> Int {
        max(0, min(100, value))
    }
}
