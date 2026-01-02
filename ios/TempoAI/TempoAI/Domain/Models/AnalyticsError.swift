//
//  AnalyticsError.swift
//  TempoAI
//
//  Analytics画面固有のエラー定義
//

import Foundation

// MARK: - AnalyticsError

/// Analytics画面で発生するエラー
enum AnalyticsError: LocalizedError, Equatable, Sendable, Identifiable {
    case dataLoadFailed
    case insufficientData
    case calculationError

    // MARK: - Identifiable

    var id: String {
        switch self {
        case .dataLoadFailed:
            return "dataLoadFailed"
        case .insufficientData:
            return "insufficientData"
        case .calculationError:
            return "calculationError"
        }
    }

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "データの読み込みに失敗しました"
        case .insufficientData:
            return "十分なデータがありません"
        case .calculationError:
            return "計算中にエラーが発生しました"
        }
    }
}
