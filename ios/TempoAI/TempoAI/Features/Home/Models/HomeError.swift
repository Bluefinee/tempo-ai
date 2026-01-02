//
//  HomeError.swift
//  TempoAI
//
//  Home画面のエラー定義
//

import Foundation

/// Home画面のエラー
enum HomeError: Error, LocalizedError, Sendable {
    case dataLoadFailed
    case apiError(String)
    case healthKitError(String)
    case offlineMode

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "データの読み込みに失敗しました"
        case .apiError(let message):
            return "API エラー: \(message)"
        case .healthKitError(let message):
            return "HealthKit エラー: \(message)"
        case .offlineMode:
            return "オフラインモードです"
        }
    }
}
