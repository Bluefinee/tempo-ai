import XCTest
@testable import TempoAI

class HumanBatteryTests: XCTestCase {
    
    func testBatteryStateColors() {
        XCTAssertNotNil(BatteryState.high.color)
        XCTAssertNotNil(BatteryState.medium.color)
        XCTAssertNotNil(BatteryState.low.color)
        XCTAssertNotNil(BatteryState.critical.color)
    }
    
    func testBatteryProjectedEndTime() {
        let battery = HumanBattery(
            currentLevel: 50.0,
            morningCharge: 80.0,
            drainRate: -10.0,
            state: .medium,
            lastUpdated: Date()
        )
        
        let projectedEnd = battery.projectedEndTime
        let expectedHours = 50.0 / 10.0
        let expectedEnd = Date().addingTimeInterval(expectedHours * 3600)
        
        XCTAssertEqual(projectedEnd.timeIntervalSince1970, expectedEnd.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testBatteryStateFromLevel() {
        XCTAssertEqual(BatteryState.fromLevel(85), .high)
        XCTAssertEqual(BatteryState.fromLevel(55), .medium)
        XCTAssertEqual(BatteryState.fromLevel(25), .low)
        XCTAssertEqual(BatteryState.fromLevel(10), .critical)
    }
}

class BatteryEngineTests: XCTestCase {
    var batteryEngine: BatteryEngine!
    var mockHealthService: MockHealthService!
    var mockWeatherService: MockWeatherService!
    
    override func setUp() {
        super.setUp()
        mockHealthService = MockHealthService()
        mockWeatherService = MockWeatherService()
        batteryEngine = BatteryEngine(
            healthService: mockHealthService,
            weatherService: mockWeatherService
        )
    }
    
    func testMorningChargeCalculation() {
        let sleepData = SleepData(duration: 8.0, quality: 0.85, deepSleepRatio: 0.2)
        let hrvData = HRVData(current: 48, baseline: 45, trend: .stable)
        
        let charge = batteryEngine.calculateMorningCharge(
            sleepData: sleepData,
            hrvData: hrvData,
            userMode: .standard
        )
        
        XCTAssertGreaterThan(charge, 70.0)
        XCTAssertLessThanOrEqual(charge, 100.0)
    }
    
    func testEnvironmentFactorCalculation() {
        let hotHumidWeather = WeatherData(
            temperature: 35.0,
            humidity: 80.0,
            surfacePressure: 1013.0,
            pressureChange: 0.0,
            timestamp: Date()
        )
        
        let factor = batteryEngine.calculateEnvironmentFactor(hotHumidWeather)
        XCTAssertGreaterThan(factor, 0.0)
    }
    
    func testLowPressureFactor() {
        let lowPressureWeather = WeatherData(
            temperature: 25.0,
            humidity: 60.0,
            surfacePressure: 1013.0,
            pressureChange: -5.0,
            timestamp: Date()
        )
        
        let factor = batteryEngine.calculateEnvironmentFactor(lowPressureWeather)
        XCTAssertGreaterThan(factor, 1.0)
    }
}

// Mock classes for testing
class MockHealthService: HealthServiceProtocol {
    var mockHealthData: HealthData?
    
    func getLatestHealthData() async throws -> HealthData {
        return mockHealthData ?? HealthData.mock()
    }
    
    func requestPermissions() async -> Bool {
        return true
    }
}

class MockWeatherService: WeatherServiceProtocol {
    var mockWeatherData: WeatherData?
    
    func getCurrentWeather() async -> WeatherData? {
        return mockWeatherData ?? WeatherData.mock()
    }
}