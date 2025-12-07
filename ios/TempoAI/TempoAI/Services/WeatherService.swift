import Combine
import Foundation
import SwiftUI

@MainActor
class WeatherService: WeatherServiceProtocol, ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading: Bool = false

    private let cache: NSCache<NSString, CacheItem> = NSCache()
    private let cacheExpiry: TimeInterval = 1800

    init() {
        cache.countLimit = 10
    }

    func getCurrentWeather() async -> WeatherData? {
        if let cachedWeather = getCachedWeather() {
            return cachedWeather
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let weather = try await fetchWeatherFromAPI()
            cacheWeather(weather)
            currentWeather = weather
            return weather
        } catch {
            return handleOfflineWeather()
        }
    }

    private func fetchWeatherFromAPI() async throws -> WeatherData {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let mockWeather = WeatherData(
            temperature: Double.random(in: 15 ... 30),
            humidity: Double.random(in: 40 ... 80),
            surfacePressure: Double.random(in: 1000 ... 1020),
            pressureChange: Double.random(in: -5 ... 2),
            timestamp: Date()
        )

        return mockWeather
    }

    private func getCachedWeather() -> WeatherData? {
        if let cachedItem = cache.object(forKey: "current_weather" as NSString),
            Date().timeIntervalSince(cachedItem.timestamp) < cacheExpiry
        {
            return cachedItem.weather
        }
        return nil
    }

    private func cacheWeather(_ weather: WeatherData) {
        let item = CacheItem(weather: weather, timestamp: Date())
        cache.setObject(item, forKey: "current_weather" as NSString)
    }

    private func handleOfflineWeather() -> WeatherData? {
        return getCachedWeather()
            ?? WeatherData(
                temperature: 22.0,
                humidity: 60.0,
                surfacePressure: 1013.25,
                pressureChange: 0.0,
                timestamp: Date()
            )
    }
}

private class CacheItem: NSObject {
    let weather: WeatherData
    let timestamp: Date

    init(weather: WeatherData, timestamp: Date) {
        self.weather = weather
        self.timestamp = timestamp
    }
}
