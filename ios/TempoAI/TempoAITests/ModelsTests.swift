import XCTest
@testable import TempoAI

final class ModelsTests: XCTestCase {
    
    // MARK: - Health Data Model Tests
    
    func testHealthDataModelCreation() {
        // Given: Valid health data components
        let sleepData = SleepData(duration: 7.5, deep: 1.2, rem: 1.8, light: 4.5, awake: 0.0, efficiency: 88)
        let hrvData = HRVData(average: 45.2, min: 38.1, max: 52.7)
        let heartRateData = HeartRateData(resting: 58, average: 72, min: 55, max: 85)
        let activityData = ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
        
        // When: Creating health data model
        let healthData = HealthData(
            sleep: sleepData,
            hrv: hrvData,
            heartRate: heartRateData,
            activity: activityData
        )
        
        // Then: Should create valid health data
        XCTAssertEqual(healthData.sleep.duration, 7.5)
        XCTAssertEqual(healthData.hrv.average, 45.2)
        XCTAssertEqual(healthData.heartRate.resting, 58)
        XCTAssertEqual(healthData.activity.steps, 8234)
    }
    
    func testSleepDataValidation() {
        // Given: Sleep data with various values
        let sleepData = SleepData(duration: 8.0, deep: 1.5, rem: 2.0, light: 4.0, awake: 0.5, efficiency: 94)
        
        // Then: Should maintain all sleep components
        XCTAssertEqual(sleepData.duration, 8.0)
        XCTAssertEqual(sleepData.deep, 1.5)
        XCTAssertEqual(sleepData.rem, 2.0)
        XCTAssertEqual(sleepData.light, 4.0)
        XCTAssertEqual(sleepData.awake, 0.5)
        XCTAssertEqual(sleepData.efficiency, 94)
        
        // Validate reasonable ranges
        XCTAssertGreaterThanOrEqual(sleepData.duration, 0)
        XCTAssertGreaterThanOrEqual(sleepData.efficiency, 0)
        XCTAssertLessThanOrEqual(sleepData.efficiency, 100)
    }
    
    func testHRVDataValidation() {
        // Given: HRV data
        let hrvData = HRVData(average: 42.5, min: 35.0, max: 55.0)
        
        // Then: Should maintain HRV values
        XCTAssertEqual(hrvData.average, 42.5)
        XCTAssertEqual(hrvData.min, 35.0)
        XCTAssertEqual(hrvData.max, 55.0)
        
        // Validate relationships
        XCTAssertLessThanOrEqual(hrvData.min, hrvData.average)
        XCTAssertGreaterThanOrEqual(hrvData.max, hrvData.average)
    }
    
    func testHeartRateDataValidation() {
        // Given: Heart rate data
        let heartRateData = HeartRateData(resting: 60, average: 75, min: 58, max: 145)
        
        // Then: Should maintain heart rate values
        XCTAssertEqual(heartRateData.resting, 60)
        XCTAssertEqual(heartRateData.average, 75)
        XCTAssertEqual(heartRateData.min, 58)
        XCTAssertEqual(heartRateData.max, 145)
        
        // Validate reasonable ranges
        XCTAssertGreaterThan(heartRateData.resting, 0)
        XCTAssertGreaterThan(heartRateData.average, 0)
        XCTAssertLessThanOrEqual(heartRateData.min, heartRateData.average)
        XCTAssertGreaterThanOrEqual(heartRateData.max, heartRateData.average)
    }
    
    func testActivityDataValidation() {
        // Given: Activity data
        let activityData = ActivityData(steps: 10000, distance: 8.5, calories: 500, activeMinutes: 45)
        
        // Then: Should maintain activity values
        XCTAssertEqual(activityData.steps, 10000)
        XCTAssertEqual(activityData.distance, 8.5)
        XCTAssertEqual(activityData.calories, 500)
        XCTAssertEqual(activityData.activeMinutes, 45)
        
        // Validate reasonable ranges
        XCTAssertGreaterThanOrEqual(activityData.steps, 0)
        XCTAssertGreaterThanOrEqual(activityData.distance, 0)
        XCTAssertGreaterThanOrEqual(activityData.calories, 0)
        XCTAssertGreaterThanOrEqual(activityData.activeMinutes, 0)
    }
    
    // MARK: - Location & User Profile Tests
    
    func testLocationDataCreation() {
        // Given: Valid coordinates
        let latitude = 35.6895
        let longitude = 139.6917
        
        // When: Creating location data
        let locationData = LocationData(latitude: latitude, longitude: longitude)
        
        // Then: Should create valid location
        XCTAssertEqual(locationData.latitude, latitude)
        XCTAssertEqual(locationData.longitude, longitude)
        
        // Validate coordinate ranges
        XCTAssertGreaterThanOrEqual(locationData.latitude, -90.0)
        XCTAssertLessThanOrEqual(locationData.latitude, 90.0)
        XCTAssertGreaterThanOrEqual(locationData.longitude, -180.0)
        XCTAssertLessThanOrEqual(locationData.longitude, 180.0)
    }
    
    func testUserProfileCreation() {
        // Given: Valid user profile data
        let userProfile = UserProfile(
            age: 30,
            gender: "male",
            goals: ["疲労回復", "集中力向上"],
            dietaryPreferences: "バランス重視",
            exerciseHabits: "週3回ジム",
            exerciseFrequency: "3回/週"
        )
        
        // Then: Should create valid user profile
        XCTAssertEqual(userProfile.age, 30)
        XCTAssertEqual(userProfile.gender, "male")
        XCTAssertEqual(userProfile.goals.count, 2)
        XCTAssertEqual(userProfile.goals[0], "疲労回復")
        XCTAssertEqual(userProfile.dietaryPreferences, "バランス重視")
        XCTAssertEqual(userProfile.exerciseHabits, "週3回ジム")
        XCTAssertEqual(userProfile.exerciseFrequency, "3回/週")
        
        // Validate reasonable ranges
        XCTAssertGreaterThan(userProfile.age, 0)
        XCTAssertLessThan(userProfile.age, 150) // Reasonable age limit
    }
    
    // MARK: - API Request Model Tests
    
    func testAnalysisRequestCreation() {
        // Given: Valid components
        let healthData = createMockHealthData()
        let location = LocationData(latitude: 35.6895, longitude: 139.6917)
        let userProfile = createMockUserProfile()
        
        // When: Creating analysis request
        let request = AnalysisRequest(
            healthData: healthData,
            location: location,
            userProfile: userProfile
        )
        
        // Then: Should create valid request
        XCTAssertEqual(request.healthData.sleep.duration, healthData.sleep.duration)
        XCTAssertEqual(request.location.latitude, location.latitude)
        XCTAssertEqual(request.userProfile.age, userProfile.age)
    }
    
    // MARK: - Daily Advice Model Tests
    
    func testDailyAdviceCreation() {
        // Given: Valid advice components
        let dailyAdvice = createMockDailyAdvice()
        
        // Then: Should create valid advice with unique ID
        XCTAssertNotNil(dailyAdvice.id)
        XCTAssertEqual(dailyAdvice.theme, "バランス調整の日")
        XCTAssertEqual(dailyAdvice.summary, "今日は適度な運動を。")
        XCTAssertNotNil(dailyAdvice.breakfast)
        XCTAssertNotNil(dailyAdvice.lunch)
        XCTAssertNotNil(dailyAdvice.dinner)
        XCTAssertNotNil(dailyAdvice.exercise)
        XCTAssertNotNil(dailyAdvice.hydration)
        XCTAssertNotNil(dailyAdvice.breathing)
        XCTAssertNotNil(dailyAdvice.sleepPreparation)
        XCTAssertNotNil(dailyAdvice.weatherConsiderations)
        XCTAssertGreaterThan(dailyAdvice.priorityActions.count, 0)
    }
    
    func testDailyAdviceUniqueIDs() {
        // Given: Multiple daily advice instances
        let advice1 = createMockDailyAdvice()
        let advice2 = createMockDailyAdvice()
        
        // Then: Should have unique IDs
        XCTAssertNotEqual(advice1.id, advice2.id)
    }
    
    func testMealAdviceValidation() {
        // Given: Meal advice with all optional fields
        let mealAdvice = MealAdvice(
            recommendation: "バランスの良い食事",
            reason: "エネルギー維持のため",
            examples: ["サラダ", "スープ", "玄米"],
            timing: "12:30 PM",
            avoid: ["揚げ物", "高糖質食品"]
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(mealAdvice.recommendation, "バランスの良い食事")
        XCTAssertEqual(mealAdvice.reason, "エネルギー維持のため")
        XCTAssertEqual(mealAdvice.examples?.count, 3)
        XCTAssertEqual(mealAdvice.timing, "12:30 PM")
        XCTAssertEqual(mealAdvice.avoid?.count, 2)
    }
    
    func testMealAdviceWithNilOptionalFields() {
        // Given: Meal advice with nil optional fields
        let mealAdvice = MealAdvice(
            recommendation: "簡単な食事",
            reason: "時間節約",
            examples: nil,
            timing: nil,
            avoid: nil
        )
        
        // Then: Should handle nil fields properly
        XCTAssertEqual(mealAdvice.recommendation, "簡単な食事")
        XCTAssertEqual(mealAdvice.reason, "時間節約")
        XCTAssertNil(mealAdvice.examples)
        XCTAssertNil(mealAdvice.timing)
        XCTAssertNil(mealAdvice.avoid)
    }
    
    func testExerciseAdviceValidation() {
        // Given: Exercise advice
        let exerciseAdvice = ExerciseAdvice(
            recommendation: "軽いジョギング",
            intensity: "Moderate",
            reason: "心肺機能向上",
            timing: "午前中",
            avoid: ["高強度トレーニング", "長時間運動"]
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(exerciseAdvice.recommendation, "軽いジョギング")
        XCTAssertEqual(exerciseAdvice.intensity, "Moderate")
        XCTAssertEqual(exerciseAdvice.reason, "心肺機能向上")
        XCTAssertEqual(exerciseAdvice.timing, "午前中")
        XCTAssertEqual(exerciseAdvice.avoid.count, 2)
    }
    
    func testHydrationAdviceValidation() {
        // Given: Hydration advice
        let schedule = HydrationSchedule(morning: "500ml", afternoon: "800ml", evening: "700ml")
        let hydrationAdvice = HydrationAdvice(
            target: "2L",
            schedule: schedule,
            reason: "代謝促進"
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(hydrationAdvice.target, "2L")
        XCTAssertEqual(hydrationAdvice.schedule.morning, "500ml")
        XCTAssertEqual(hydrationAdvice.schedule.afternoon, "800ml")
        XCTAssertEqual(hydrationAdvice.schedule.evening, "700ml")
        XCTAssertEqual(hydrationAdvice.reason, "代謝促進")
    }
    
    func testBreathingAdviceValidation() {
        // Given: Breathing advice
        let breathingAdvice = BreathingAdvice(
            technique: "4-7-8呼吸法",
            duration: "5分",
            frequency: "朝晩2回",
            instructions: ["4秒で吸う", "7秒止める", "8秒で吐く", "繰り返す"]
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(breathingAdvice.technique, "4-7-8呼吸法")
        XCTAssertEqual(breathingAdvice.duration, "5分")
        XCTAssertEqual(breathingAdvice.frequency, "朝晩2回")
        XCTAssertEqual(breathingAdvice.instructions.count, 4)
        XCTAssertEqual(breathingAdvice.instructions[0], "4秒で吸う")
    }
    
    func testSleepPreparationAdviceValidation() {
        // Given: Sleep preparation advice
        let sleepAdvice = SleepPreparationAdvice(
            bedtime: "22:30",
            routine: ["入浴", "読書", "瞑想"],
            avoid: ["スマホ", "カフェイン", "激しい運動"]
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(sleepAdvice.bedtime, "22:30")
        XCTAssertEqual(sleepAdvice.routine.count, 3)
        XCTAssertEqual(sleepAdvice.avoid.count, 3)
        XCTAssertEqual(sleepAdvice.routine[1], "読書")
        XCTAssertEqual(sleepAdvice.avoid[0], "スマホ")
    }
    
    func testWeatherConsiderationsValidation() {
        // Given: Weather considerations
        let weatherConsiderations = WeatherConsiderations(
            warnings: ["強風注意", "UV指数高"],
            opportunities: ["散歩に適した気温", "屋外運動可能"]
        )
        
        // Then: Should maintain all fields
        XCTAssertEqual(weatherConsiderations.warnings.count, 2)
        XCTAssertEqual(weatherConsiderations.opportunities.count, 2)
        XCTAssertEqual(weatherConsiderations.warnings[0], "強風注意")
        XCTAssertEqual(weatherConsiderations.opportunities[0], "散歩に適した気温")
    }
    
    // MARK: - API Response Model Tests
    
    func testAPIResponseSuccessCreation() {
        // Given: Successful API response
        let mockAdvice = createMockDailyAdvice()
        let apiResponse = APIResponse(success: true, data: mockAdvice, error: nil)
        
        // Then: Should create valid response
        XCTAssertTrue(apiResponse.success)
        XCTAssertNotNil(apiResponse.data)
        XCTAssertNil(apiResponse.error)
        XCTAssertEqual(apiResponse.data?.theme, "バランス調整の日")
    }
    
    func testAPIResponseErrorCreation() {
        // Given: Error API response
        let apiResponse = APIResponse<DailyAdvice>(success: false, data: nil, error: "Server error")
        
        // Then: Should create valid error response
        XCTAssertFalse(apiResponse.success)
        XCTAssertNil(apiResponse.data)
        XCTAssertEqual(apiResponse.error, "Server error")
    }
    
    func testMockAdviceResponseCreation() {
        // Given: Mock advice response
        let mockAdvice = createMockDailyAdvice()
        let mockResponse = MockAdviceResponse(advice: mockAdvice)
        
        // Then: Should create valid mock response
        XCTAssertEqual(mockResponse.advice.theme, "バランス調整の日")
        XCTAssertNotNil(mockResponse.advice.breakfast)
    }
    
    // MARK: - JSON Serialization Tests
    
    func testHealthDataJSONSerialization() throws {
        // Given: Health data model
        let healthData = createMockHealthData()
        
        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(healthData)
        
        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // And: Should decode back to the same data
        let decodedHealthData = try JSONDecoder().decode(HealthData.self, from: jsonData)
        XCTAssertEqual(decodedHealthData.sleep.duration, healthData.sleep.duration)
        XCTAssertEqual(decodedHealthData.hrv.average, healthData.hrv.average)
    }
    
    func testLocationDataJSONSerialization() throws {
        // Given: Location data
        let locationData = LocationData(latitude: 35.6895, longitude: 139.6917)
        
        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(locationData)
        
        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // And: Should decode back correctly
        let decodedLocation = try JSONDecoder().decode(LocationData.self, from: jsonData)
        XCTAssertEqual(decodedLocation.latitude, locationData.latitude)
        XCTAssertEqual(decodedLocation.longitude, locationData.longitude)
    }
    
    func testDailyAdviceJSONSerialization() throws {
        // Given: Daily advice model
        let dailyAdvice = createMockDailyAdvice()
        
        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(dailyAdvice)
        
        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // And: Should decode back correctly (but with new UUID)
        let decodedAdvice = try JSONDecoder().decode(DailyAdvice.self, from: jsonData)
        XCTAssertEqual(decodedAdvice.theme, dailyAdvice.theme)
        XCTAssertEqual(decodedAdvice.summary, dailyAdvice.summary)
        // Note: UUID will be different after decoding since it's generated
    }
    
    func testAnalysisRequestJSONSerialization() throws {
        // Given: Analysis request
        let request = AnalysisRequest(
            healthData: createMockHealthData(),
            location: LocationData(latitude: 35.6895, longitude: 139.6917),
            userProfile: createMockUserProfile()
        )
        
        // When: Encoding to JSON
        let jsonData = try JSONEncoder().encode(request)
        
        // Then: Should encode successfully
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // And: Should decode back correctly
        let decodedRequest = try JSONDecoder().decode(AnalysisRequest.self, from: jsonData)
        XCTAssertEqual(decodedRequest.healthData.sleep.duration, request.healthData.sleep.duration)
        XCTAssertEqual(decodedRequest.location.latitude, request.location.latitude)
        XCTAssertEqual(decodedRequest.userProfile.age, request.userProfile.age)
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testEmptyUserGoals() {
        // Given: User profile with empty goals
        let userProfile = UserProfile(
            age: 25,
            gender: "female",
            goals: [],
            dietaryPreferences: "ベジタリアン",
            exerciseHabits: "ヨガ",
            exerciseFrequency: "毎日"
        )
        
        // Then: Should handle empty goals
        XCTAssertEqual(userProfile.goals.count, 0)
        XCTAssertEqual(userProfile.age, 25)
    }
    
    func testExtremeCoordinates() {
        // Given: Extreme but valid coordinates
        let extremeLocations = [
            LocationData(latitude: 90.0, longitude: 180.0),    // North Pole, Date Line
            LocationData(latitude: -90.0, longitude: -180.0),  // South Pole, Date Line
            LocationData(latitude: 0.0, longitude: 0.0)        // Null Island
        ]
        
        // Then: Should handle extreme coordinates
        for location in extremeLocations {
            XCTAssertGreaterThanOrEqual(location.latitude, -90.0)
            XCTAssertLessThanOrEqual(location.latitude, 90.0)
            XCTAssertGreaterThanOrEqual(location.longitude, -180.0)
            XCTAssertLessThanOrEqual(location.longitude, 180.0)
        }
    }
    
    func testZeroActivityData() {
        // Given: Activity data with zero values
        let activityData = ActivityData(steps: 0, distance: 0.0, calories: 0, activeMinutes: 0)
        
        // Then: Should handle zero values
        XCTAssertEqual(activityData.steps, 0)
        XCTAssertEqual(activityData.distance, 0.0)
        XCTAssertEqual(activityData.calories, 0)
        XCTAssertEqual(activityData.activeMinutes, 0)
    }
}

// MARK: - Test Data Helpers

extension ModelsTests {
    func createMockHealthData() -> HealthData {
        return HealthData(
            sleep: SleepData(duration: 7.5, deep: 1.2, rem: 1.8, light: 4.5, awake: 0.0, efficiency: 88),
            hrv: HRVData(average: 45.2, min: 38.1, max: 52.7),
            heartRate: HeartRateData(resting: 58, average: 72, min: 55, max: 85),
            activity: ActivityData(steps: 8234, distance: 6.2, calories: 420, activeMinutes: 35)
        )
    }
    
    func createMockUserProfile() -> UserProfile {
        return UserProfile(
            age: 30,
            gender: "male",
            goals: ["疲労回復", "集中力向上"],
            dietaryPreferences: "バランス重視",
            exerciseHabits: "週3回ジム",
            exerciseFrequency: "3回/週"
        )
    }
    
    func createMockDailyAdvice() -> DailyAdvice {
        return DailyAdvice(
            theme: "バランス調整の日",
            summary: "今日は適度な運動を。",
            breakfast: MealAdvice(
                recommendation: "タンパク質豊富な朝食を",
                reason: "筋肉合成を促進",
                examples: ["ゆで卵", "ヨーグルト"],
                timing: nil,
                avoid: nil
            ),
            lunch: MealAdvice(
                recommendation: "バランス食",
                reason: "エネルギー維持",
                examples: ["サラダ"],
                timing: "12:30 PM",
                avoid: ["揚げ物"]
            ),
            dinner: MealAdvice(
                recommendation: "軽い食事",
                reason: "睡眠の質保持",
                examples: ["魚料理"],
                timing: "6:30 PM",
                avoid: ["遅い食事"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "有酸素運動30分",
                intensity: "Moderate",
                reason: "回復状態が良好",
                timing: "午前10時頃",
                avoid: ["高強度運動"]
            ),
            hydration: HydrationAdvice(
                target: "2.5L",
                schedule: HydrationSchedule(morning: "500ml", afternoon: "1000ml", evening: "1000ml"),
                reason: "活動量に対応"
            ),
            breathing: BreathingAdvice(
                technique: "4-7-8 breathing",
                duration: "5分",
                frequency: "2回",
                instructions: ["吸う", "止める", "吐く"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "22:30",
                routine: ["お風呂", "読書"],
                avoid: ["スマホ"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: ["日焼け止めを"],
                opportunities: ["散歩に最適"]
            ),
            priorityActions: ["朝食を摂る", "運動する", "水分摂取"]
        )
    }
}