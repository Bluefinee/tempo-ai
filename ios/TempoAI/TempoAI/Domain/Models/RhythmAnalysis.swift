import Foundation

// MARK: - RhythmAnalysis Aggregate

/// リズムの安定性を分析・評価する集約ルート
struct RhythmAnalysis: Equatable, Codable, Sendable {

    // MARK: - Properties

    /// 就寝時刻の標準偏差（分）
    let bedtimeStddevMinutes: Double
    /// 起床時刻の標準偏差（分）
    let wakeTimeStddevMinutes: Double
    /// 連続で安定したリズムを維持した日数
    let consecutiveStableDays: Int
    /// 手首体温データ（対応機種のみ）
    let wristTemperature: WristTemperatureMetrics?

    // MARK: - Computed Properties

    /// リズムの安定度ステータス
    var status: RhythmStatus {
        if consecutiveStableDays >= 5 {
            return .stable
        }
        if consecutiveStableDays >= 3 {
            return .recovering
        }
        return .unstable
    }

    /// リズムが安定しているかどうか
    /// 就寝・起床時刻の両方が30分以内の標準偏差であれば安定とみなす
    var isStable: Bool {
        bedtimeStddevMinutes <= 30 && wakeTimeStddevMinutes <= 30
    }

    /// 就寝時刻の一貫性スコア（0-100）
    var bedtimeConsistencyScore: Double {
        Self.consistencyScore(from: bedtimeStddevMinutes)
    }

    /// 起床時刻の一貫性スコア（0-100）
    var wakeTimeConsistencyScore: Double {
        Self.consistencyScore(from: wakeTimeStddevMinutes)
    }

    /// 就寝時刻の一貫性ステータス
    var bedtimeConsistencyStatus: ConsistencyStatus {
        Self.consistencyStatus(from: bedtimeStddevMinutes)
    }

    /// 起床時刻の一貫性ステータス
    var wakeTimeConsistencyStatus: ConsistencyStatus {
        Self.consistencyStatus(from: wakeTimeStddevMinutes)
    }

    // MARK: - Private Helpers

    /// 標準偏差からConsistencyStatusを算出
    private static func consistencyStatus(from stddev: Double) -> ConsistencyStatus {
        switch stddev {
        case ...30:
            return .stable
        case 30..<45:
            return .recovering
        default:
            return .unstable
        }
    }

    /// 標準偏差からスコアを算出
    private static func consistencyScore(from stddev: Double) -> Double {
        switch stddev {
        case ...15:
            return 100
        case 15..<30:
            return 85
        case 30..<45:
            return 70
        case 45..<60:
            return 55
        case 60..<90:
            return 40
        default:
            return 25
        }
    }
}

// MARK: - RhythmStatus

/// リズム安定度ステータス（連続安定日数ベース）
enum RhythmStatus: String, Codable, Sendable {
    case stable = "安定"
    case recovering = "回復中"
    case unstable = "乱れ気味"
}

// MARK: - ConsistencyStatus

/// 時刻一貫性ステータス（標準偏差ベース）
/// - Note: RhythmStatusとは異なり、時刻のばらつきを評価
enum ConsistencyStatus: String, Codable, Sendable {
    /// 安定（標準偏差 ≤ 30分）
    case stable = "安定"
    /// 回復中（標準偏差 30-45分）
    case recovering = "回復中"
    /// 乱れ気味（標準偏差 > 45分）
    case unstable = "乱れ気味"
}
