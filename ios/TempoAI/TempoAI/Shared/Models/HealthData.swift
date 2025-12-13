import Foundation

// MARK: - Health Data Models

/// HealthKitデータ
struct HealthData: Codable {
    let heartRateData: [HeartRateData]
    let hrvData: [HRVData]
    let sleepData: [SleepData]
    let stepData: [StepData]
    let activeEnergyData: [ActiveEnergyData]
    let fetchedAt: Date
}

/// 心拍数データ
struct HeartRateData: Codable {
    let date: Date
    let value: Double  // bpm
}

/// 心拍変動データ
struct HRVData: Codable {
    let date: Date
    let value: Double  // milliseconds
}

/// 睡眠データ
struct SleepData: Codable {
    let date: Date
    let duration: Double  // hours
    let bedTime: Date
    let wakeTime: Date
}

/// 歩数データ
struct StepData: Codable {
    let date: Date
    let count: Int
}

/// 消費エネルギーデータ
struct ActiveEnergyData: Codable {
    let date: Date
    let value: Double  // kcal
}

// MARK: - Location Data Models

/// 位置データ
struct LocationData: Codable {
    let coordinates: LocationCoordinates
    let cityName: String
    let fetchedAt: Date
}

/// 位置座標
struct LocationCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}
