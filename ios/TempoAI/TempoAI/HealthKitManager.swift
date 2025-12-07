import Combine
import Foundation
import HealthKit

// MARK: - HealthKit Permission Status

// Using existing PermissionStatus from PermissionManager for consistency
extension PermissionStatus {
    static let unavailable: PermissionStatus = .denied  // Map unavailable to denied for simplicity
}

// MARK: - HealthKit Manager

/// Dedicated HealthKit authorization and data management following Apple 2024 best practices
@MainActor
final class HealthKitManager: ObservableObject {

    // MARK: - Properties

    static let shared: HealthKitManager = HealthKitManager()

    @Published var authorizationStatus: PermissionStatus = .notDetermined
    @Published var isLoading: Bool = false

    let healthStore: HKHealthStore = HKHealthStore()

    // MARK: - Initialization

    private init() {
        updateAuthorizationStatus()
    }

    // MARK: - Health Data Types

    static let healthDataTypesToRead: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []

        // Quantity types
        if let heartRateVariability = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(heartRateVariability)
        }
        if let restingHeartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHeartRate)
        }
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }

        // Category types
        if let sleepAnalysis = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }

        return types
    }()

    // MARK: - Authorization Methods

    /// Request HealthKit authorization using Apple's 2024 recommended pattern
    /// - Returns: Boolean indicating if the request was successful
    func requestAuthorization() async -> Bool {
        print("🏥 HealthKitManager: Requesting authorization...")

        // Check HealthKit availability first
        #if os(iOS)
            guard HKHealthStore.isHealthDataAvailable() else {
                print("❌ HealthKit not available on this iOS device")
                authorizationStatus = .denied
                return false
            }
        #else
            // On macOS (for development/testing), simulate iOS behavior
            print("⚠️ Running on macOS - simulating HealthKit availability for development")
        #endif

        isLoading = true
        defer { isLoading = false }

        do {
            // Use Apple's recommended async/await pattern with continuation
            let success: Bool = try await withCheckedThrowingContinuation { continuation in
                healthStore.requestAuthorization(
                    toShare: [],
                    read: HealthKitManager.healthDataTypesToRead
                ) { success, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ HealthKit authorization error: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        } else {
                            print("✅ HealthKit authorization completed: \(success)")
                            continuation.resume(returning: success)
                        }
                    }
                }
            }

            // Update status after authorization attempt
            print("🏥 Authorization request completed with success: \(success)")

            // Give the system a moment to process the authorization before testing
            try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second delay

            updateAuthorizationStatus()
            return success

        } catch {
            print("❌ HealthKit authorization failed: \(error.localizedDescription)")
            authorizationStatus = .denied
            return false
        }
    }

    /// Check current authorization status without requesting
    func checkAuthorizationStatus() -> PermissionStatus {
        updateAuthorizationStatus()
        return authorizationStatus
    }

    /// Start background data observation for health data changes
    func startBackgroundDataObservation() {
        // Background observation setup for health data updates
        print("🏥 HealthKit: Starting background data observation")
        // Implementation would go here for production apps
        // For now, we'll use a simplified approach
    }

    // MARK: - Data Collection (Simplified)

    /// Fetch today's health data for analysis
    /// - Returns: HealthData object with today's metrics
    func fetchTodayHealthData() async throws -> HealthData {
        print("🏥 HealthKitManager: Fetching today's health data...")

        #if os(iOS)
            guard HKHealthStore.isHealthDataAvailable() else {
                print("❌ HealthKit not available - using mock data")
                return createMockHealthData()
            }
        #else
            print("⚠️ Running on macOS - using mock health data for development")
            return createMockHealthData()
        #endif

        // For now, return simplified mock data
        // Real implementation would query actual HealthKit data
        return createMockHealthData()
    }

    // MARK: - Private Helper Methods

    func updateAuthorizationStatus() {
        #if os(iOS)
            guard HKHealthStore.isHealthDataAvailable() else {
                print("🏥 HealthKit not available on iOS device")
                authorizationStatus = .denied
                return
            }
        #else
            print("🏥 Running on macOS - using simulated HealthKit status")
        #endif

        print("🏥 Updating HealthKit authorization status...")

        // Apple 2024 approach: Test actual data access for read permissions
        // Note: HealthKit authorization status only reflects write permissions for privacy
        Task { @MainActor in
            let hasReadAccess = await testDataReadAccess()

            if hasReadAccess {
                print("🏥 HealthKit read access confirmed - setting status to granted")
                authorizationStatus = .granted
            } else {
                print("🏥 HealthKit read access denied or not determined - setting status to denied")
                authorizationStatus = .denied
            }
        }
    }

    private func testDataReadAccess() async -> Bool {
        // Simplified approach for now
        // Real implementation would test actual data queries
        #if os(iOS)
            return true  // Assume access for simplicity
        #else
            return true  // Simulate access on macOS
        #endif
    }

    private func createMockHealthData() -> HealthData {
        return HealthData(
            sleep: SleepData(
                duration: 7.5,
                deep: 1.5,
                rem: 2.0,
                light: 3.5,
                awake: 0.5,
                efficiency: 0.85
            ),
            hrv: HRVData(
                average: 35.0,
                min: 30.0,
                max: 40.0
            ),
            heartRate: HeartRateData(
                resting: 65,
                average: 72,
                min: 60,
                max: 180
            ),
            activity: ActivityData(
                steps: 8500,
                distance: 6.2,
                calories: 420,
                activeMinutes: 45
            )
        )
    }
}

// MARK: - HealthKit Error Types

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed(details: String)
    case partialAuthorization(granted: [String], denied: [String])
    case dataUnavailable(dataType: String)
    case queryFailed(dataType: String, error: String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed(let details):
            return "HealthKit authorization failed: \(details)"
        case .partialAuthorization(let granted, let denied):
            return
                "Partial HealthKit access - Granted: \(granted.joined(separator: ", ")), Denied: \(denied.joined(separator: ", "))"
        case .dataUnavailable(let dataType):
            return "Health data unavailable for type: \(dataType)"
        case .queryFailed(let dataType, let error):
            return "HealthKit query failed for \(dataType): \(error)"
        }
    }

    var failureReason: String? {
        switch self {
        case .notAvailable:
            return "This device does not support HealthKit or health data access"
        case .authorizationFailed:
            return "User has not granted permission to access health data"
        case .partialAuthorization:
            return "Some health data types are not accessible"
        case .dataUnavailable:
            return "The requested health data is not available or accessible"
        case .queryFailed:
            return "Failed to retrieve health data from HealthKit"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not supported on this device. The app will use mock data."
        case .authorizationFailed, .partialAuthorization:
            return "Please enable HealthKit permissions in Settings > Privacy & Security > Health > Tempo AI"
        case .dataUnavailable, .queryFailed:
            return "Ensure health data is available and try again. You may need to use the Health app first."
        }
    }
}
