//
//  WeatherAPIClient.swift
//  TempoAI
//
//  Weather API Client using Open-Meteo API
//

import Foundation

// MARK: - WeatherAPIClientProtocol

/// Weather API通信プロトコル
protocol WeatherAPIClientProtocol: Sendable {

    /// 気象データを取得
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 経度
    /// - Returns: WeatherData
    /// - Throws: WeatherAPIError
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData
}

// MARK: - WeatherAPIClient

/// Open-Meteo APIクライアント
final class WeatherAPIClient: WeatherAPIClientProtocol, Sendable {

    // MARK: - Properties

    private let session: NetworkSession
    private let baseURL: String = "https://api.open-meteo.com/v1/forecast"

    // MARK: - Initialization

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    // MARK: - Public Methods

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let url: URL = try buildURL(latitude: latitude, longitude: longitude)
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        let (data, response): (Data, URLResponse) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.serverError(httpResponse.statusCode)
        }

        let decoder: JSONDecoder = JSONDecoder()

        do {
            let responseDTO: OpenMeteoResponseDTO = try decoder.decode(
                OpenMeteoResponseDTO.self,
                from: data
            )
            return try convertToWeatherData(from: responseDTO)
        } catch let decodingError as DecodingError {
            throw WeatherAPIError.decodingError(decodingError.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func buildURL(latitude: Double, longitude: Double) throws -> URL {
        var components: URLComponents? = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,surface_pressure"),
            URLQueryItem(name: "hourly", value: "surface_pressure,uv_index"),
            URLQueryItem(name: "timezone", value: "Asia/Tokyo"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]

        guard let url = components?.url else {
            throw WeatherAPIError.invalidURL
        }

        return url
    }

    private func convertToWeatherData(from response: OpenMeteoResponseDTO) throws -> WeatherData {
        guard let current = response.current else {
            throw WeatherAPIError.missingData("current")
        }

        let pressureTrend: PressureTrend = calculatePressureTrend(
            hourlyPressures: response.hourly?.surfacePressure ?? []
        )

        let uvIndex: Int = getCurrentUVIndex(
            hourlyUV: response.hourly?.uvIndex ?? [],
            hourlyTimes: response.hourly?.time ?? []
        )

        return WeatherData(
            temperature: current.temperature2m,
            pressure: current.surfacePressure,
            pressureTrend: pressureTrend,
            uvIndex: uvIndex,
            humidity: current.relativeHumidity2m,
            weatherCode: current.weatherCode,
            fetchedAt: Date()
        )
    }

    /// 気圧トレンドを計算（過去3時間の変化から）
    private func calculatePressureTrend(hourlyPressures: [Double]) -> PressureTrend {
        guard hourlyPressures.count >= 4 else {
            return .stable
        }

        let calendar: Calendar = Calendar.current
        let currentHour: Int = calendar.component(.hour, from: Date())

        // 現在時刻と3時間前のインデックスを取得
        let currentIndex: Int = min(currentHour, hourlyPressures.count - 1)
        let pastIndex: Int = max(0, currentIndex - 3)

        guard currentIndex < hourlyPressures.count, pastIndex < hourlyPressures.count else {
            return .stable
        }

        let currentPressure: Double = hourlyPressures[currentIndex]
        let pastPressure: Double = hourlyPressures[pastIndex]
        let difference: Double = currentPressure - pastPressure

        // 1hPa以上の変化でトレンド判定
        if difference > 1.0 {
            return .rising
        } else if difference < -1.0 {
            return .falling
        } else {
            return .stable
        }
    }

    /// 現在時刻のUV指数を取得
    private func getCurrentUVIndex(hourlyUV: [Double], hourlyTimes: [String]) -> Int {
        let calendar: Calendar = Calendar.current
        let currentHour: Int = calendar.component(.hour, from: Date())

        guard currentHour < hourlyUV.count else {
            return hourlyUV.last.map { Int($0) } ?? 0
        }

        return Int(hourlyUV[currentHour])
    }
}

// MARK: - WeatherAPIError

/// Weather APIエラー
enum WeatherAPIError: Error, LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(String)
    case missingData(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        case .decodingError(let message):
            return "データ解析エラー: \(message)"
        case .missingData(let field):
            return "必要なデータがありません: \(field)"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        }
    }
}

// MARK: - Open-Meteo Response DTOs

/// Open-Meteo APIレスポンス
struct OpenMeteoResponseDTO: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let current: CurrentDataDTO?
    let hourly: HourlyDataDTO?
}

/// 現在の気象データDTO
struct CurrentDataDTO: Codable, Sendable {
    let time: String
    let temperature2m: Double
    let relativeHumidity2m: Int
    let weatherCode: Int
    let surfacePressure: Double

    private enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case surfacePressure = "surface_pressure"
    }
}

/// 時間別気象データDTO
struct HourlyDataDTO: Codable, Sendable {
    let time: [String]
    let surfacePressure: [Double]?
    let uvIndex: [Double]?

    private enum CodingKeys: String, CodingKey {
        case time
        case surfacePressure = "surface_pressure"
        case uvIndex = "uv_index"
    }
}
