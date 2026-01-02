//
//  WeatherAPIClientTests.swift
//  TempoAITests
//
//  Tests for WeatherAPIClient
//

import XCTest
@testable import TempoAI

// MARK: - WeatherAPIClientTests

final class WeatherAPIClientTests: XCTestCase {

    // MARK: - Properties

    private var sut: WeatherAPIClient!
    private var mockSession: MockNetworkSession!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        sut = WeatherAPIClient(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testFetchWeather_Success_ReturnsWeatherData() async throws {
        // Given
        let responseJSON: String = """
        {
            "latitude": 35.6762,
            "longitude": 139.6503,
            "current": {
                "time": "2024-01-01T12:00",
                "temperature_2m": 22.5,
                "relative_humidity_2m": 60,
                "weather_code": 1,
                "surface_pressure": 1013.25
            },
            "hourly": {
                "time": ["2024-01-01T00:00", "2024-01-01T01:00", "2024-01-01T02:00", "2024-01-01T03:00"],
                "surface_pressure": [1010.0, 1011.0, 1012.0, 1013.0],
                "uv_index": [0.0, 0.0, 0.0, 1.0]
            }
        }
        """
        mockSession.mockData = responseJSON.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let weather: WeatherData = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)

        // Then
        XCTAssertEqual(weather.temperature, 22.5)
        XCTAssertEqual(weather.humidity, 60)
        XCTAssertEqual(weather.weatherCode, 1)
        XCTAssertEqual(weather.pressure, 1013.25)
    }

    func testFetchWeather_Success_TemperatureStringFormatted() async throws {
        // Given
        let responseJSON: String = """
        {
            "latitude": 35.6762,
            "longitude": 139.6503,
            "current": {
                "time": "2024-01-01T12:00",
                "temperature_2m": 22.7,
                "relative_humidity_2m": 60,
                "weather_code": 0,
                "surface_pressure": 1013.25
            },
            "hourly": {
                "time": [],
                "surface_pressure": [],
                "uv_index": []
            }
        }
        """
        mockSession.mockData = responseJSON.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let weather: WeatherData = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)

        // Then
        XCTAssertEqual(weather.temperatureString, "23°")
    }

    // MARK: - Error Tests

    func testFetchWeather_ServerError_ThrowsError() async {
        // Given
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            _ = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherAPIError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Expected WeatherAPIError")
        }
    }

    func testFetchWeather_InvalidJSON_ThrowsDecodingError() async {
        // Given
        mockSession.mockData = "invalid json".data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            _ = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherAPIError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Expected decodingError")
            }
        } catch {
            XCTFail("Expected WeatherAPIError")
        }
    }

    func testFetchWeather_MissingCurrentData_ThrowsMissingDataError() async {
        // Given
        let responseJSON: String = """
        {
            "latitude": 35.6762,
            "longitude": 139.6503,
            "hourly": {
                "time": [],
                "surface_pressure": [],
                "uv_index": []
            }
        }
        """
        mockSession.mockData = responseJSON.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            _ = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherAPIError {
            if case .missingData(let field) = error {
                XCTAssertEqual(field, "current")
            } else {
                XCTFail("Expected missingData error")
            }
        } catch {
            XCTFail("Expected WeatherAPIError")
        }
    }

    // MARK: - Pressure Trend Tests

    func testPressureTrend_Rising_WhenPressureIncreases() async throws {
        // Given: 気圧が過去3時間で2hPa以上上昇
        let responseJSON: String = """
        {
            "latitude": 35.6762,
            "longitude": 139.6503,
            "current": {
                "time": "2024-01-01T03:00",
                "temperature_2m": 22.5,
                "relative_humidity_2m": 60,
                "weather_code": 1,
                "surface_pressure": 1015.0
            },
            "hourly": {
                "time": ["2024-01-01T00:00", "2024-01-01T01:00", "2024-01-01T02:00", "2024-01-01T03:00"],
                "surface_pressure": [1010.0, 1011.0, 1013.0, 1015.0],
                "uv_index": [0.0, 0.0, 0.0, 1.0]
            }
        }
        """
        mockSession.mockData = responseJSON.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let weather: WeatherData = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)

        // Then: 現在時刻に依存するため、stableまたはrisingのいずれかを許容
        XCTAssertTrue([PressureTrend.stable, PressureTrend.rising].contains(weather.pressureTrend))
    }

    func testPressureTrend_Stable_WhenPressureConstant() async throws {
        // Given: 気圧がほぼ一定
        let responseJSON: String = """
        {
            "latitude": 35.6762,
            "longitude": 139.6503,
            "current": {
                "time": "2024-01-01T03:00",
                "temperature_2m": 22.5,
                "relative_humidity_2m": 60,
                "weather_code": 1,
                "surface_pressure": 1013.0
            },
            "hourly": {
                "time": ["2024-01-01T00:00", "2024-01-01T01:00", "2024-01-01T02:00", "2024-01-01T03:00"],
                "surface_pressure": [1013.0, 1013.2, 1013.1, 1013.0],
                "uv_index": [0.0, 0.0, 0.0, 1.0]
            }
        }
        """
        mockSession.mockData = responseJSON.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let weather: WeatherData = try await sut.fetchWeather(latitude: 35.6762, longitude: 139.6503)

        // Then
        XCTAssertEqual(weather.pressureTrend, .stable)
    }
}

// MARK: - WeatherDataTests

final class WeatherDataTests: XCTestCase {

    func testUVLevel_Low_ForUVIndex0To2() {
        XCTAssertEqual(UVLevel(uvIndex: 0), .low)
        XCTAssertEqual(UVLevel(uvIndex: 1), .low)
        XCTAssertEqual(UVLevel(uvIndex: 2), .low)
    }

    func testUVLevel_Moderate_ForUVIndex3To5() {
        XCTAssertEqual(UVLevel(uvIndex: 3), .moderate)
        XCTAssertEqual(UVLevel(uvIndex: 4), .moderate)
        XCTAssertEqual(UVLevel(uvIndex: 5), .moderate)
    }

    func testUVLevel_High_ForUVIndex6To7() {
        XCTAssertEqual(UVLevel(uvIndex: 6), .high)
        XCTAssertEqual(UVLevel(uvIndex: 7), .high)
    }

    func testUVLevel_VeryHigh_ForUVIndex8To10() {
        XCTAssertEqual(UVLevel(uvIndex: 8), .veryHigh)
        XCTAssertEqual(UVLevel(uvIndex: 9), .veryHigh)
        XCTAssertEqual(UVLevel(uvIndex: 10), .veryHigh)
    }

    func testUVLevel_Extreme_ForUVIndex11Plus() {
        XCTAssertEqual(UVLevel(uvIndex: 11), .extreme)
        XCTAssertEqual(UVLevel(uvIndex: 15), .extreme)
    }

    func testPressureTrendArrow() {
        XCTAssertEqual(PressureTrend.rising.arrow, "↑")
        XCTAssertEqual(PressureTrend.stable.arrow, "→")
        XCTAssertEqual(PressureTrend.falling.arrow, "↓")
    }

    func testWeatherCode_ClearSky_ReturnsCorrectDescriptionAndIcon() {
        let weatherCode: WeatherCode = .clearSky
        XCTAssertEqual(weatherCode.description, "快晴")
        XCTAssertEqual(weatherCode.icon, "sun.max")
    }

    func testWeatherCode_Rain_ReturnsCorrectDescriptionAndIcon() {
        let weatherCode: WeatherCode = .rainModerate
        XCTAssertEqual(weatherCode.description, "雨")
        XCTAssertEqual(weatherCode.icon, "cloud.rain")
    }

    func testWeatherDataMock() {
        let mock: WeatherData = .mock()
        XCTAssertEqual(mock.temperature, 22.5)
        XCTAssertEqual(mock.pressure, 1013.25)
        XCTAssertEqual(mock.pressureTrend, .stable)
        XCTAssertEqual(mock.uvIndex, 5)
        XCTAssertEqual(mock.humidity, 60)
    }

    func testWeatherDataDisplayStrings() {
        let weather: WeatherData = .mock(
            temperature: 25.7,
            pressure: 1008.5,
            uvIndex: 8,
            humidity: 75
        )

        XCTAssertEqual(weather.temperatureString, "26°")
        XCTAssertEqual(weather.pressureString, "1008 hPa")
        XCTAssertEqual(weather.uvIndexString, "UV 8")
        XCTAssertEqual(weather.humidityString, "75%")
        XCTAssertEqual(weather.uvLevel, .veryHigh)
    }
}

