//
//  TimePeriod.swift
//  TempoAI
//
//  Analytics画面の期間選択用Value Object
//

import Foundation

// MARK: - TimePeriod

/// Analytics画面で使用する期間選択
enum TimePeriod: String, CaseIterable, Codable, Sendable {
    case weekly = "週間"
    case monthly = "月間"

    // MARK: - Computed Properties

    /// 期間の日数
    var days: Int {
        switch self {
        case .weekly:
            return 7
        case .monthly:
            return 30
        }
    }

    /// 表示用の名前
    var displayName: String {
        rawValue
    }
}
