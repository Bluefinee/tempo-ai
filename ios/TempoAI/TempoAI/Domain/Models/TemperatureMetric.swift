import Foundation

/// 体温位相ステータス
enum PhaseStatus {
    case collecting
    case synced
    case slightlyLate
    case late
    case slightlyEarly
    case early
}

/// 体温位相指標モデル
/// スコアなし、ステータスのみ
struct TemperatureMetric {
    let phaseShiftHours: Double
    let isAvailable: Bool
    let nightsOfData: Int

    static let requiredNights: Int = 5

    /// データが十分か
    var hasEnoughData: Bool {
        nightsOfData >= Self.requiredNights
    }

    /// 位相ステータス
    var status: PhaseStatus {
        guard hasEnoughData else { return .collecting }

        switch phaseShiftHours {
        case -0.5...0.5: return .synced
        case 0.5..<1.5: return .slightlyLate
        case 1.5...: return .late
        case -1.5..<(-0.5): return .slightlyEarly
        default: return .early
        }
    }

    /// ステータスに基づくコメント
    var comment: String {
        switch status {
        case .collecting:
            let remaining = Self.requiredNights - nightsOfData
            return "データ収集中（あと\(remaining)晩）"
        case .synced:
            return "体内時計は整っています"
        case .slightlyLate:
            return "少し遅れ気味です"
        case .late:
            return "朝の光浴を増やしましょう"
        case .slightlyEarly:
            return "少し進み気味です"
        case .early:
            return "夕方の光を控えましょう"
        }
    }

    /// 5段階ゲージレベル（0 = 非表示）
    var gaugeLevel: Int {
        switch status {
        case .synced: return 5
        case .slightlyLate, .slightlyEarly: return 3
        case .late, .early: return 2
        case .collecting: return 0
        }
    }

    /// 警告アイコンを表示するか
    var showWarningIcon: Bool {
        status == .late || status == .early
    }

    /// 表示用ステータステキスト
    var displayValue: String {
        switch status {
        case .synced: return "正常"
        case .slightlyLate: return "やや遅れ"
        case .late: return "遅れ気味"
        case .slightlyEarly: return "やや進み"
        case .early: return "進み気味"
        case .collecting: return "収集中"
        }
    }
}

// MARK: - Mock Data

extension TemperatureMetric {
    static var mock: TemperatureMetric {
        TemperatureMetric(
            phaseShiftHours: 0.3,
            isAvailable: true,
            nightsOfData: 7
        )
    }

    static var mockCollecting: TemperatureMetric {
        TemperatureMetric(
            phaseShiftHours: 0,
            isAvailable: true,
            nightsOfData: 3
        )
    }

    static var mockLate: TemperatureMetric {
        TemperatureMetric(
            phaseShiftHours: 2.0,
            isAvailable: true,
            nightsOfData: 10
        )
    }

    static var mockUnavailable: TemperatureMetric {
        TemperatureMetric(
            phaseShiftHours: 0,
            isAvailable: false,
            nightsOfData: 0
        )
    }
}
