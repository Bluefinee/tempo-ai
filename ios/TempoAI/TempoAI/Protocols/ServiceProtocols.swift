import Foundation

// MARK: - Service Protocols

/// Protocol defining the interface for health data services
protocol HealthServiceProtocol {
    func getLatestHealthData() async throws -> HealthData
    func requestPermissions() async -> Bool
}

/// Protocol defining the interface for weather data services
protocol WeatherServiceProtocol {
    func getCurrentWeather() async -> WeatherData?
}
