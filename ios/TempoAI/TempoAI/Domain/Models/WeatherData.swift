//
//  WeatherData.swift
//  TempoAI
//
//  Weather Data Model for Environment Card
//

import Foundation

// MARK: - WeatherData

/// 気象データモデル
struct WeatherData: Equatable, Codable, Sendable {

    // MARK: - Properties

    /// 気温（℃）
    let temperature: Double

    /// 気圧（hPa）
    let pressure: Double

    /// 気圧傾向
    let pressureTrend: PressureTrend

    /// UV指数（0-11+）
    let uvIndex: Int

    /// 湿度（%）
    let humidity: Int

    /// WMO天気コード
    let weatherCode: Int

    /// データ取得日時
    let fetchedAt: Date

    // MARK: - Computed Properties

    /// 気温の表示用文字列
    var temperatureString: String {
        String(format: "%.0f°", temperature)
    }

    /// 気圧の表示用文字列
    var pressureString: String {
        String(format: "%.0f hPa", pressure)
    }

    /// UV指数の表示用文字列
    var uvIndexString: String {
        "UV \(uvIndex)"
    }

    /// 湿度の表示用文字列
    var humidityString: String {
        "\(humidity)%"
    }

    /// UV指数のレベル
    var uvLevel: UVLevel {
        UVLevel(uvIndex: uvIndex)
    }

    /// 天気の説明
    var weatherDescription: String {
        WeatherCode(rawValue: weatherCode)?.description ?? "不明"
    }

    /// 天気アイコン（SF Symbols）
    var weatherIcon: String {
        WeatherCode(rawValue: weatherCode)?.icon ?? "questionmark"
    }
}

// MARK: - PressureTrend

/// 気圧傾向
enum PressureTrend: String, Codable, Sendable, CaseIterable {
    case rising = "rising"
    case stable = "stable"
    case falling = "falling"

    /// 表示用矢印
    var arrow: String {
        switch self {
        case .rising: return "↑"
        case .stable: return "→"
        case .falling: return "↓"
        }
    }

    /// アクセシビリティ用説明
    var accessibilityLabel: String {
        switch self {
        case .rising: return "上昇傾向"
        case .stable: return "安定"
        case .falling: return "下降傾向"
        }
    }

    /// SF Symbolsアイコン
    var icon: String {
        switch self {
        case .rising: return "arrow.up"
        case .stable: return "arrow.forward"
        case .falling: return "arrow.down"
        }
    }
}

// MARK: - UVLevel

/// UV指数レベル
enum UVLevel: String, Sendable {
    case low = "低い"
    case moderate = "中程度"
    case high = "高い"
    case veryHigh = "非常に高い"
    case extreme = "極端に高い"

    init(uvIndex: Int) {
        switch uvIndex {
        case ..<0:
            self = .low
        case 0...2:
            self = .low
        case 3...5:
            self = .moderate
        case 6...7:
            self = .high
        case 8...10:
            self = .veryHigh
        default:
            self = .extreme
        }
    }

    /// アクセシビリティ用説明
    var accessibilityLabel: String {
        rawValue
    }
}

// MARK: - WeatherCode

/// WMO天気コード
enum WeatherCode: Int, Sendable {
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case depositingRimeFog = 48
    case drizzleLight = 51
    case drizzleModerate = 53
    case drizzleDense = 55
    case freezingDrizzleLight = 56
    case freezingDrizzleDense = 57
    case rainSlight = 61
    case rainModerate = 63
    case rainHeavy = 65
    case freezingRainLight = 66
    case freezingRainHeavy = 67
    case snowFallSlight = 71
    case snowFallModerate = 73
    case snowFallHeavy = 75
    case snowGrains = 77
    case rainShowersSlight = 80
    case rainShowersModerate = 81
    case rainShowersViolent = 82
    case snowShowersSlight = 85
    case snowShowersHeavy = 86
    case thunderstorm = 95
    case thunderstormSlightHail = 96
    case thunderstormHeavyHail = 99

    /// 日本語説明
    var description: String {
        switch self {
        case .clearSky:
            return "快晴"
        case .mainlyClear:
            return "晴れ"
        case .partlyCloudy:
            return "晴れ時々曇り"
        case .overcast:
            return "曇り"
        case .fog, .depositingRimeFog:
            return "霧"
        case .drizzleLight, .drizzleModerate, .drizzleDense:
            return "霧雨"
        case .freezingDrizzleLight, .freezingDrizzleDense:
            return "着氷性霧雨"
        case .rainSlight:
            return "小雨"
        case .rainModerate:
            return "雨"
        case .rainHeavy:
            return "大雨"
        case .freezingRainLight, .freezingRainHeavy:
            return "着氷性雨"
        case .snowFallSlight:
            return "小雪"
        case .snowFallModerate:
            return "雪"
        case .snowFallHeavy:
            return "大雪"
        case .snowGrains:
            return "霰"
        case .rainShowersSlight, .rainShowersModerate:
            return "にわか雨"
        case .rainShowersViolent:
            return "激しいにわか雨"
        case .snowShowersSlight, .snowShowersHeavy:
            return "にわか雪"
        case .thunderstorm:
            return "雷雨"
        case .thunderstormSlightHail, .thunderstormHeavyHail:
            return "雷雨（雹を伴う）"
        }
    }

    /// SF Symbolsアイコン
    var icon: String {
        switch self {
        case .clearSky, .mainlyClear:
            return "sun.max"
        case .partlyCloudy:
            return "cloud.sun"
        case .overcast:
            return "cloud"
        case .fog, .depositingRimeFog:
            return "cloud.fog"
        case .drizzleLight, .drizzleModerate, .drizzleDense:
            return "cloud.drizzle"
        case .freezingDrizzleLight, .freezingDrizzleDense:
            return "cloud.sleet"
        case .rainSlight, .rainModerate:
            return "cloud.rain"
        case .rainHeavy:
            return "cloud.heavyrain"
        case .freezingRainLight, .freezingRainHeavy:
            return "cloud.sleet"
        case .snowFallSlight, .snowFallModerate, .snowFallHeavy, .snowGrains:
            return "cloud.snow"
        case .rainShowersSlight, .rainShowersModerate, .rainShowersViolent:
            return "cloud.rain"
        case .snowShowersSlight, .snowShowersHeavy:
            return "cloud.snow"
        case .thunderstorm, .thunderstormSlightHail, .thunderstormHeavyHail:
            return "cloud.bolt.rain"
        }
    }
}

// MARK: - WeatherData+Mock

extension WeatherData {

    /// プレビュー・テスト用のモックデータ
    static func mock(
        temperature: Double = 22.5,
        pressure: Double = 1013.25,
        pressureTrend: PressureTrend = .stable,
        uvIndex: Int = 5,
        humidity: Int = 60,
        weatherCode: Int = 1
    ) -> WeatherData {
        WeatherData(
            temperature: temperature,
            pressure: pressure,
            pressureTrend: pressureTrend,
            uvIndex: uvIndex,
            humidity: humidity,
            weatherCode: weatherCode,
            fetchedAt: Date()
        )
    }
}
