import Combine
import Foundation
import SwiftUI
import os.log

@MainActor
class BatteryEngine: ObservableObject {
    @Published var currentBattery: HumanBattery

    let healthService: HealthServiceProtocol
    let weatherService: WeatherServiceProtocol
    private var updateTimer: Timer?

    init(healthService: HealthServiceProtocol, weatherService: WeatherServiceProtocol) {
        self.healthService = healthService
        self.weatherService = weatherService
        self.currentBattery = HumanBattery(
            currentLevel: 75.0,
            morningCharge: 0.0,
            drainRate: -5.0,
            state: .high,
            lastUpdated: Date()
        )

        startRealTimeUpdates()
    }

    deinit {
        updateTimer?.invalidate()
    }

    // MARK: - Battery Calculation Logic

    func calculateMorningCharge(
        sleepData: SleepData,
        hrvData: HRVData,
        userMode: UserMode
    ) -> Double {
        let sleepScore = calculateSleepScore(sleepData, for: userMode)
        let hrvScore = calculateHRVScore(hrvData)

        let baseCharge = (sleepScore * 0.6) + (hrvScore * 0.4)

        let previousDayPenalty = currentBattery.currentLevel < 20 ? 0.9 : 1.0

        return min(100.0, baseCharge * previousDayPenalty)
    }

    func calculateRealTimeDrain(
        activeEnergy: Double,
        stressLevel: Double,
        environmentFactor: Double,
        userMode: UserMode
    ) -> Double {
        let baseDrain = -2.5

        let activityDrain = activeEnergy * (userMode == .athlete ? 0.8 : 1.0) * 0.01
        let stressDrain = stressLevel * 0.5
        let environmentDrain = environmentFactor

        return baseDrain - activityDrain - stressDrain - environmentDrain
    }

    func calculateEnvironmentFactor(_ weather: WeatherData) -> Double {
        var factor = 0.0

        if weather.temperature > 30 && weather.humidity > 70 {
            factor += 2.0
        }

        if weather.pressureChange < -3.0 {
            factor += 1.5
        }

        return factor
    }

    // MARK: - Public Methods

    /// Fetches the latest health data through the health service
    func getLatestHealthData() async throws -> HealthData {
        return try await healthService.getLatestHealthData()
    }

    // MARK: - Private Methods

    private func calculateSleepScore(_ sleepData: SleepData, for userMode: UserMode) -> Double {
        let durationScore = min(100, (sleepData.duration / 8.0) * 100)
        let qualityScore = sleepData.quality * 100

        let weightedScore = (durationScore * 0.7) + (qualityScore * 0.3)

        return userMode == .athlete ? weightedScore * 1.1 : weightedScore
    }

    private func calculateHRVScore(_ hrvData: HRVData) -> Double {
        guard hrvData.baseline > 0 else { return 50.0 }
        let baselineRatio = hrvData.current / hrvData.baseline
        let score = min(100, baselineRatio * 100)

        switch hrvData.trend {
        case .improving: return score * 1.1
        case .stable: return score
        case .declining: return score * 0.9
        }
    }

    private func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.updateBattery()
            }
        }
    }

    private func updateBattery() async {
        do {
            let healthData = try await healthService.getLatestHealthData()
            let weatherData = await weatherService.getCurrentWeather()

            let environmentFactor = calculateEnvironmentFactor(weatherData ?? WeatherData.mock())

            let newDrainRate = calculateRealTimeDrain(
                activeEnergy: healthData.activeEnergy,
                stressLevel: healthData.stressLevel,
                environmentFactor: environmentFactor,
                userMode: UserProfileManager.shared.currentMode
            )

            let timeDelta = Date().timeIntervalSince(currentBattery.lastUpdated) / 3600.0
            let newLevel = max(0.0, currentBattery.currentLevel + (newDrainRate * timeDelta))

            let newState = BatteryState.fromLevel(newLevel)

            currentBattery = HumanBattery(
                currentLevel: newLevel,
                morningCharge: currentBattery.morningCharge,
                drainRate: newDrainRate,
                state: newState,
                lastUpdated: Date()
            )
        } catch {
            os_log("Failed to update battery: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
        }
    }
}
