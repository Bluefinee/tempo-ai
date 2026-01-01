import Foundation

// MARK: - HealthMetrics Entity

/// HealthKitから取得した健康データを保持するエンティティ
struct HealthMetrics: Equatable, Codable, Sendable {
    let date: Date
    let sleep: SleepMetrics?
    let hrv: HRVMetrics?
    let activity: ActivityMetrics?
    let auxiliary: AuxiliaryMetrics?
}

// MARK: - SleepMetrics

/// 睡眠データ
struct SleepMetrics: Equatable, Codable, Sendable {
    let bedtime: Date
    let wakeTime: Date
    let durationMinutes: Int
    let deepSleepMinutes: Int
    let remSleepMinutes: Int

    // MARK: - Computed Properties

    /// 睡眠時間（時間単位）
    var durationHours: Double {
        Double(durationMinutes) / 60.0
    }

    /// 深い睡眠の割合
    var deepSleepRatio: Double {
        guard durationMinutes > 0 else { return 0 }
        return Double(deepSleepMinutes) / Double(durationMinutes)
    }

    /// レム睡眠の割合
    var remSleepRatio: Double {
        guard durationMinutes > 0 else { return 0 }
        return Double(remSleepMinutes) / Double(durationMinutes)
    }

    /// 浅い睡眠の分数
    var lightSleepMinutes: Int {
        max(0, durationMinutes - deepSleepMinutes - remSleepMinutes)
    }

    /// 浅い睡眠の割合
    var lightSleepRatio: Double {
        guard durationMinutes > 0 else { return 0 }
        return Double(lightSleepMinutes) / Double(durationMinutes)
    }
}

// MARK: - HRVMetrics

/// 心拍変動（HRV）データ
struct HRVMetrics: Equatable, Codable, Sendable {
    /// 今日のHRV値（ミリ秒）
    let value: Double
    /// 過去30日間のベースライン（ミリ秒）
    let baseline30d: Double

    // MARK: - Computed Properties

    /// ベースラインからの偏差（パーセント）
    var deviationPercent: Double {
        guard baseline30d > 0 else { return 0 }
        return ((value - baseline30d) / baseline30d) * 100
    }

    /// HRVの状態評価
    var status: HRVStatus {
        let deviation: Double = deviationPercent
        switch deviation {
        case 10...:
            return .elevated
        case -10..<10:
            return .normal
        case -20..<(-10):
            return .slightlyLow
        default:
            return .low
        }
    }
}

/// HRV状態
enum HRVStatus: String, Codable, Sendable {
    case elevated = "高め"
    case normal = "正常"
    case slightlyLow = "やや低め"
    case low = "低め"
}

// MARK: - ActivityMetrics

/// 活動量データ
struct ActivityMetrics: Equatable, Codable, Sendable {
    /// 昨日の歩数
    let stepsYesterday: Int
    /// 昨日のアクティブ時間（分）
    let activeMinutesYesterday: Int

    // MARK: - Computed Properties

    /// 目標歩数（デフォルト8000歩）に対する達成率
    func stepAchievementRate(target: Int = 8000) -> Double {
        guard target > 0 else { return 0 }
        return Double(stepsYesterday) / Double(target)
    }
}

// MARK: - AuxiliaryMetrics

/// 補助的なメトリクス（対応機種のみ）
struct AuxiliaryMetrics: Equatable, Codable, Sendable {
    let daylight: DaylightMetrics?
    let wristTemperature: WristTemperatureMetrics?
}

// MARK: - DaylightMetrics

/// 日光暴露データ（watchOS 10+, SE2, Series 6以降対応）
struct DaylightMetrics: Equatable, Codable, Sendable {
    /// 昨日の日光暴露時間（分）
    let minutesYesterday: Int

    // MARK: - Computed Properties

    var status: DaylightStatus {
        switch minutesYesterday {
        case 45...:
            return .sufficient
        case 30..<45:
            return .slightlyInsufficient
        default:
            return .insufficient
        }
    }
}

/// 日光暴露状態
enum DaylightStatus: String, Codable, Sendable {
    case sufficient = "十分"
    case slightlyInsufficient = "やや不足"
    case insufficient = "不足"
}

// MARK: - WristTemperatureMetrics

/// 手首体温データ（Series 8+, Ultra対応）
struct WristTemperatureMetrics: Equatable, Codable, Sendable {
    /// ベースラインからの偏差（℃）
    let deviation: Double

    // MARK: - Computed Properties

    var status: TemperatureStatus {
        switch abs(deviation) {
        case 0..<0.2:
            return .stable
        case 0.2..<0.5:
            return .slightlyVariable
        default:
            return .variable
        }
    }
}

/// 体温変動状態
enum TemperatureStatus: String, Codable, Sendable {
    case stable = "安定"
    case slightlyVariable = "やや変動"
    case variable = "変動大"
}
