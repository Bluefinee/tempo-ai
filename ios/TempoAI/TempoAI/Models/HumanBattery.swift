import Foundation
import SwiftUI

enum BatteryState: String, Codable {
    case high, medium, low, critical

    var color: Color {
        switch self {
        case .high: return ColorPalette.success
        case .medium: return ColorPalette.warning
        case .low, .critical: return ColorPalette.error
        }
    }

    static func fromLevel(_ level: Double) -> BatteryState {
        switch level {
        case 70 ... 100: return .high
        case 40 ..< 70: return .medium
        case 15 ..< 40: return .low
        default: return .critical
        }
    }
}

struct HumanBattery: Codable {
    let currentLevel: Double
    let morningCharge: Double
    let drainRate: Double
    let state: BatteryState
    let lastUpdated: Date

    var projectedEndTime: Date {
        guard abs(drainRate) > 0 else {
            return Date().addingTimeInterval(24 * 3600)  // デフォルト: 24時間後
        }
        let hoursRemaining = currentLevel / abs(drainRate)
        return Date().addingTimeInterval(hoursRemaining * 3600)
    }

    var batteryComment: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        switch state {
        case .high:
            return "エネルギー充分。夕方まで持続予定"
        case .medium:
            return "良好なレベル。\(formatter.string(from: projectedEndTime))頃まで"
        case .low:
            return "エネルギー低下中。休息を検討してください"
        case .critical:
            return "要注意レベル。即座に回復が必要"
        }
    }
}

// ヘルスデータ関連モデル
struct HealthData: Codable {
    let heartRate: HeartRateData
    let sleepData: SleepData
    let activityData: ActivityData
    let hrvData: HRVData
    let timestamp: Date

    var stressLevel: Double {
        return hrvData.calculateStressLevel(heartRate.current)
    }

    var activeEnergy: Double {
        return activityData.activeEnergyBurned
    }

    static func mock() -> HealthData {
        return HealthData(
            heartRate: HeartRateData(current: 70, resting: 65, max: 180),
            sleepData: SleepData(duration: 7.5, quality: 0.8, deepSleepRatio: 0.25),
            activityData: ActivityData(activeEnergyBurned: 350, stepCount: 8500),
            hrvData: HRVData(current: 45, baseline: 45, trend: .stable),
            timestamp: Date()
        )
    }
}

struct HeartRateData: Codable {
    let current: Double
    let resting: Double
    let max: Double
}

struct SleepData: Codable {
    let duration: Double
    let quality: Double
    let deepSleepRatio: Double

    var deepSleepDuration: Double {
        return duration * deepSleepRatio
    }
}

struct ActivityData: Codable {
    let activeEnergyBurned: Double
    let stepCount: Int
}

struct HRVData: Codable {
    let current: Double
    let baseline: Double
    let trend: HRVTrend

    enum HRVTrend: String, Codable {
        case improving, stable, declining
    }

    func calculateStressLevel(_ heartRate: Double) -> Double {
        guard baseline > 0 else { return 50.0 }
        let hrvStress = max(0, (baseline - current) / baseline * 100)
        let hrStress = max(0, (heartRate - 60) / 60 * 100)
        return min(100, (hrvStress + hrStress) / 2)
    }
}

struct WeatherData: Codable {
    let temperature: Double
    let humidity: Double
    let surfacePressure: Double
    let pressureChange: Double
    let timestamp: Date

    static func mock() -> WeatherData {
        return WeatherData(
            temperature: 22.0,
            humidity: 65.0,
            surfacePressure: 1013.25,
            pressureChange: -1.0,
            timestamp: Date()
        )
    }
}
