import XCTest
@testable import TempoAI

final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
        // Clean state before each test
        cacheManager.deleteUserProfile()
        cacheManager.resetOnboardingState()
    }
    
    override func tearDown() {
        // Clean up after each test
        cacheManager.deleteUserProfile()
        cacheManager.resetOnboardingState()
        super.tearDown()
    }
    
    // MARK: - UserProfile Tests
    
    func testUserProfileSaveAndLoad() throws {
        let testProfile = UserProfile(
            nickname: "テストユーザー",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: .itEngineer,
            lifestyleRhythm: .morning,
            exerciseFrequency: .threeToFour,
            alcoholFrequency: .never,
            interests: [.fitness, .nutrition]
        )
        
        // Test save
        XCTAssertNoThrow(try cacheManager.saveUserProfile(testProfile), "Should save profile without error")
        
        // Test load
        let loadedProfile = try cacheManager.loadUserProfile()
        XCTAssertNotNil(loadedProfile, "Should load saved profile")
        XCTAssertEqual(loadedProfile?.nickname, testProfile.nickname, "Nickname should match")
        XCTAssertEqual(loadedProfile?.age, testProfile.age, "Age should match")
        XCTAssertEqual(loadedProfile?.gender, testProfile.gender, "Gender should match")
    }
    
    func testUserProfileDelete() throws {
        let testProfile = UserProfile.sampleData
        
        // Save profile first
        try cacheManager.saveUserProfile(testProfile)
        XCTAssertNotNil(try cacheManager.loadUserProfile(), "Profile should exist before deletion")
        
        // Delete profile
        cacheManager.deleteUserProfile()
        
        // Verify deletion
        let loadedProfile = try? cacheManager.loadUserProfile()
        XCTAssertNil(loadedProfile, "Profile should be nil after deletion")
    }
    
    func testUserProfileCorruptedDataHandling() throws {
        // This test would need to simulate corrupted data
        // For now, we test that loading non-existent profile returns nil
        let loadedProfile = try? cacheManager.loadUserProfile()
        XCTAssertNil(loadedProfile, "Should return nil when no profile exists")
    }
    
    // MARK: - Onboarding State Tests
    
    func testOnboardingCompletion() {
        // Initially should not be completed
        XCTAssertFalse(cacheManager.isOnboardingCompleted(), "Onboarding should not be completed initially")
        
        // Mark as completed
        cacheManager.markOnboardingCompleted()
        
        // Should be completed now
        XCTAssertTrue(cacheManager.isOnboardingCompleted(), "Onboarding should be completed after marking")
    }
    
    func testOnboardingReset() {
        // Mark as completed first
        cacheManager.markOnboardingCompleted()
        XCTAssertTrue(cacheManager.isOnboardingCompleted(), "Should be completed")
        
        // Reset
        cacheManager.resetOnboardingState()
        
        // Should be reset
        XCTAssertFalse(cacheManager.isOnboardingCompleted(), "Should be reset after resetOnboardingState")
    }
    
    func testCompleteReset() throws {
        let testProfile = UserProfile.sampleData
        
        // Set up some data
        try cacheManager.saveUserProfile(testProfile)
        cacheManager.markOnboardingCompleted()
        
        XCTAssertTrue(cacheManager.isOnboardingCompleted(), "Should be completed")
        XCTAssertNotNil(try cacheManager.loadUserProfile(), "Profile should exist")
        
        // Perform complete reset
        cacheManager.performCompleteReset()
        
        // Verify everything is reset
        XCTAssertFalse(cacheManager.isOnboardingCompleted(), "Onboarding should be reset")
        XCTAssertNil(try? cacheManager.loadUserProfile(), "Profile should be deleted")
    }
    
    // MARK: - HealthKit Authorization Tests
    
    func testHealthKitAuthorizationStatusSaveAndLoad() {
        let testStatus: HealthKitAuthorizationStatus = .authorized
        
        // Save status
        cacheManager.saveHealthKitAuthorizationStatus(testStatus)
        
        // Load status
        let loadedStatus = cacheManager.loadHealthKitAuthorizationStatus()
        XCTAssertEqual(loadedStatus, testStatus, "HealthKit status should match")
    }
    
    func testHealthKitAuthorizationStatusDefaults() {
        // Default should be notDetermined
        let defaultStatus = cacheManager.loadHealthKitAuthorizationStatus()
        XCTAssertEqual(defaultStatus, .notDetermined, "Default HealthKit status should be notDetermined")
    }
    
    // MARK: - Location Authorization Tests
    
    func testLocationAuthorizationStatusSaveAndLoad() {
        let testStatus: LocationAuthorizationStatus = .authorizedWhenInUse
        
        // Save status
        cacheManager.saveLocationAuthorizationStatus(testStatus)
        
        // Load status
        let loadedStatus = cacheManager.loadLocationAuthorizationStatus()
        XCTAssertEqual(loadedStatus, testStatus, "Location status should match")
    }
    
    // MARK: - Health Data Tests
    
    func testHealthDataSaveAndLoad() throws {
        let testHealthData = HealthData(
            heartRate: HeartRateData(
                averageHeartRate: 72.0,
                restingHeartRate: 60.0,
                heartRateVariability: 45.0,
                recordedAt: Date()
            ),
            hrv: HRVData(
                rmssd: 42.0,
                recordedAt: Date()
            ),
            sleep: SleepData(
                totalSleepTime: 7.5,
                deepSleepTime: 1.5,
                remSleepTime: 1.8,
                sleepEfficiency: 0.85,
                bedTime: Date(),
                wakeTime: Date()
            ),
            steps: StepData(
                stepCount: 8500,
                distance: 6.2,
                recordedAt: Date()
            ),
            activeEnergy: ActiveEnergyData(
                totalEnergyBurned: 420.0,
                recordedAt: Date()
            ),
            recordedAt: Date()
        )
        
        // Test save
        XCTAssertNoThrow(try cacheManager.saveHealthData(testHealthData), "Should save health data without error")
        
        // Test load
        let loadedData = try cacheManager.loadLatestHealthData()
        XCTAssertNotNil(loadedData, "Should load saved health data")
        XCTAssertEqual(loadedData?.heartRate.averageHeartRate, testHealthData.heartRate.averageHeartRate, "Heart rate should match")
    }
    
    // MARK: - Location Data Tests
    
    func testLocationDataSaveAndLoad() throws {
        let testLocationData = LocationData(
            coordinates: LocationCoordinates(
                latitude: 35.6762,
                longitude: 139.6503
            ),
            city: "東京",
            country: "日本",
            timezone: "Asia/Tokyo",
            recordedAt: Date()
        )
        
        // Test save
        XCTAssertNoThrow(try cacheManager.saveLocationData(testLocationData), "Should save location data without error")
        
        // Test load
        let loadedData = try cacheManager.loadLatestLocationData()
        XCTAssertNotNil(loadedData, "Should load saved location data")
        XCTAssertEqual(loadedData?.city, testLocationData.city, "City should match")
        XCTAssertEqual(loadedData?.coordinates.latitude, testLocationData.coordinates.latitude, accuracy: 0.001, "Latitude should match")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidUserProfileHandling() {
        // Test with invalid profile (this would require creating an invalid profile)
        // For now, test that error handling doesn't crash
        let emptyNicknameProfile = UserProfile(
            nickname: "",
            age: 25,
            gender: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            occupation: nil,
            lifestyleRhythm: nil,
            exerciseFrequency: nil,
            alcoholFrequency: nil,
            interests: []
        )
        
        // This should not crash, even with empty interests array
        XCTAssertNoThrow(try cacheManager.saveUserProfile(emptyNicknameProfile), "Should handle invalid profile gracefully")
    }
    
    // MARK: - Memory Management Tests
    
    func testSingletonBehavior() {
        let manager1 = CacheManager.shared
        let manager2 = CacheManager.shared
        
        XCTAssert(manager1 === manager2, "CacheManager should be a singleton")
    }
}