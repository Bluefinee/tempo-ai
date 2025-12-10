import Foundation

/**
 * Service for creating mock data for testing and development
 * Phase 7: Used to test API client integration with realistic data
 */
@MainActor
final class MockDataService: ObservableObject {
    
    static let shared = MockDataService()
    
    private init() {}
    
    // MARK: - Mock Advice Request Creation
    
    /**
     * Creates a complete mock advice request for testing API integration
     * This generates realistic data that matches the expected backend schema
     */
    func createMockAdviceRequest() -> AdviceRequest {
        return AdviceRequest(
            userProfile: createMockUserProfile(),
            healthData: createMockHealthData(),
            location: createMockLocationData(),
            context: createMockRequestContext()
        )
    }
    
    // MARK: - Mock User Profile
    
    private func createMockUserProfile() -> UserProfile {
        return UserProfile(
            nickname: "テストユーザー",
            age: 28,
            gender: .female,
            weightKg: 55.0,
            heightCm: 165.0,
            occupation: .itEngineer,
            lifestyleRhythm: .morning,
            exerciseFrequency: .threeToFour,
            alcoholFrequency: .oneToTwo,
            interests: [.fitness, .beauty, .sleep]
        )
    }
    
    // MARK: - Mock Health Data
    
    private func createMockHealthData() -> HealthData {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        return HealthData(
            date: ISO8601DateFormatter().string(from: today),
            sleep: createMockSleepData(),
            morningVitals: createMockMorningVitals(),
            yesterdayActivity: createMockActivityData(),
            weekTrends: createMockWeekTrends()
        )
    }
    
    private func createMockSleepData() -> SleepData {
        let bedtime = Calendar.current.date(byAdding: .hour, value: -9, to: Date())!
        let wakeTime = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
        
        return SleepData(
            bedtime: ISO8601DateFormatter().string(from: bedtime),
            wakeTime: ISO8601DateFormatter().string(from: wakeTime),
            durationHours: 7.5,
            deepSleepHours: 1.8,
            remSleepHours: 1.2,
            awakenings: 2,
            avgHeartRate: 58
        )
    }
    
    private func createMockMorningVitals() -> MorningVitals {
        return MorningVitals(
            restingHeartRate: 62,
            hrvMs: 72.0,
            bloodOxygen: 98
        )
    }
    
    private func createMockActivityData() -> ActivityData {
        return ActivityData(
            steps: 8520,
            workoutMinutes: 45,
            workoutType: "Strength Training",
            caloriesBurned: 320
        )
    }
    
    private func createMockWeekTrends() -> WeekTrends {
        return WeekTrends(
            avgSleepHours: 7.2,
            avgHrv: 68.0,
            avgRestingHeartRate: 64,
            avgSteps: 7800,
            totalWorkoutHours: 4.5
        )
    }
    
    // MARK: - Mock Location Data
    
    private func createMockLocationData() -> LocationData {
        // Tokyo coordinates
        return LocationData(
            latitude: 35.6762,
            longitude: 139.6503,
            city: "東京"
        )
    }
    
    // MARK: - Mock Request Context
    
    private func createMockRequestContext() -> RequestContext {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        
        // Convert weekday (1=Sunday, 2=Monday...) to DayOfWeek enum
        let dayOfWeek: RequestContext.DayOfWeek = {
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: return .monday
            }
        }()
        
        return RequestContext(
            currentTime: ISO8601DateFormatter().string(from: now),
            dayOfWeek: dayOfWeek,
            isMonday: dayOfWeek == .monday,
            recentDailyTries: [
                "朝のストレッチルーティン",
                "プロテインスムージー",
                "昼休み散歩",
                "睡眠前のヨガ"
            ],
            lastWeeklyTry: dayOfWeek == .monday ? "週間瞑想チャレンジ" : nil
        )
    }
    
    // MARK: - API Test Helper
    
    /**
     * Tests the API client with mock data
     * Useful for verifying end-to-end communication
     */
    func testAPIConnection() async -> (success: Bool, advice: DailyAdvice?, error: String?) {
        do {
            let mockRequest = createMockAdviceRequest()
            let advice = try await APIClient.shared.generateAdvice(request: mockRequest)
            return (true, advice, nil)
        } catch {
            return (false, nil, error.localizedDescription)
        }
    }
}