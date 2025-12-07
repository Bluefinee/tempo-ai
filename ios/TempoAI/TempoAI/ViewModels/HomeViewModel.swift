import Combine
import Foundation
import SwiftUI

#if os(iOS)
    import UIKit
#endif

/// ViewModel managing home screen state and health analysis integration.
///
/// Coordinates between HealthKit data collection, health status analysis,
/// and API-based advice generation. Provides reactive state management
/// for the home screen with real-time updates and error handling.
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var healthAnalysis: HealthAnalysis?
    @Published var todayAdvice: DailyAdvice?
    @Published var isLoadingHealth: Bool = false
    @Published var isLoadingAdvice: Bool = false
    @Published var errorMessage: String?
    @Published var showingPermissions: Bool = false
    @Published var isMockData: Bool = false
    @Published var healthKitPermissionStatus: PermissionStatus = .notDetermined
    @Published var locationPermissionStatus: PermissionStatus = .notDetermined

    // MARK: - Private Properties

    private let healthKitManager = HealthKitManager.shared
    private lazy var locationManager = LocationManager()
    private lazy var healthStatusAnalyzer = HealthStatusAnalyzer()
    private lazy var apiClient = APIClient.shared
    private lazy var permissionManager = PermissionManager.shared
    private var cancellables = Set<AnyCancellable>()

    // User profile for API requests
    private let userProfile = UserProfile(
        age: 28,
        gender: "male",
        goals: ["fatigue_recovery", "focus"],
        dietaryPreferences: "No restrictions",
        exerciseHabits: "Regular weight training",
        exerciseFrequency: "weekly"
    )

    // MARK: - Initialization

    init() {
        setupDataRefreshObservers()
        setupPermissionObservers()
        updatePermissionStatus()
    }

    deinit {
        // Note: Cleanup handled by deallocation
        // Background observation will stop when HealthKitManager is deallocated
    }

    // MARK: - Public Methods

    /// Initialize permissions and load initial data
    func initialize() async {
        await setupPermissions()
        await refreshHealthData()
        await refreshAdvice()

        // Start background data monitoring
        healthKitManager.startBackgroundDataObservation()
    }

    /// Refresh health status analysis
    func refreshHealthData() async {
        guard !isLoadingHealth else { return }

        isLoadingHealth = true
        errorMessage = nil

        defer { isLoadingHealth = false }

        do {
            let healthData = try await healthKitManager.fetchTodayHealthData()
            let analysis = await healthStatusAnalyzer.analyzeHealthStatus(from: healthData)

            healthAnalysis = analysis

        } catch {
            errorMessage = "Failed to analyze health data: \(error.localizedDescription)"
            print("Health analysis error: \(error)")
        }
    }

    /// Refresh AI advice based on current health data
    /// Uses date-based caching to prevent duplicate generation for the same day
    func refreshAdvice() async {
        guard !isLoadingAdvice else { return }

        // Check if we already have today's advice
        if let currentAdvice = todayAdvice, currentAdvice.isFromToday {
            print("📋 Using cached advice from today (created \(Int(currentAdvice.ageInHours)) hours ago)")
            return
        }

        isLoadingAdvice = true
        defer { isLoadingAdvice = false }

        print("📋 Generating new advice for today...")

        do {
            let healthData = try await healthKitManager.fetchTodayHealthData()

            // Use available location data or provide default location for Tokyo
            let locationData =
                locationManager.locationData
                ?? LocationData(
                    latitude: 35.6762,
                    longitude: 139.6503
                )

            // Use enhanced API with health analysis context
            do {
                let advice: DailyAdvice

                // Use standard API - simplified approach
                advice = try await apiClient.analyzeHealth(
                    healthData: healthData,
                    location: locationData,
                    userProfile: userProfile,
                    healthAnalysis: healthAnalysis
                )

                todayAdvice = advice
                isMockData = false

                // Note: Advice tracking simplified for now
                print("✅ AI advice generated successfully")

            } catch {
                #if DEBUG
                    print("🚨 API call failed in DEBUG mode, using mock data: \(error.localizedDescription)")

                    // In DEBUG, use local mock data instead of calling backend mock endpoint
                    let mockAdvice = createLocalMockAdvice()
                    todayAdvice = mockAdvice
                    isMockData = true
                #else
                    // In production, show the actual error
                    throw error
                #endif
            }

        } catch {
            errorMessage = error.localizedDescription
            print("Advice generation error: \(error)")
        }
    }

    /// Force refresh advice generation regardless of cache
    func forceRefreshAdvice() async {
        print("📋 Force generating new advice (bypassing cache)...")
        todayAdvice = nil  // Clear cache
        await refreshAdvice()
    }

    /// Refresh both health analysis and advice
    func refreshAll() async {
        await refreshHealthData()
        await refreshAdvice()
    }

    /// Show permissions screen
    func showPermissions() {
        showingPermissions = true
    }

    /// Dismiss permissions screen and refresh data
    func dismissPermissions() {
        showingPermissions = false
        Task {
            await refreshAll()
        }
    }

    // Note: Advice tracking features simplified for now

    // MARK: - Computed Properties

    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12:
            return NSLocalizedString("home_greeting_morning", comment: "Good Morning")
        case 12 ..< 17:
            return NSLocalizedString("home_greeting_afternoon", comment: "Good Afternoon")
        case 17 ..< 22:
            return NSLocalizedString("home_greeting_evening", comment: "Good Evening")
        default:
            return NSLocalizedString("home_greeting_night", comment: "Good Night")
        }
    }

    var isAnyLoading: Bool {
        isLoadingHealth || isLoadingAdvice
    }

    var hasData: Bool {
        healthAnalysis != nil || todayAdvice != nil
    }

    var shouldShowMockBanner: Bool {
        isMockData && todayAdvice != nil
    }

    /// Whether to show permission banner and which type
    var permissionBannerType: PermissionBannerType? {
        let healthKitNeeded = healthKitPermissionStatus != .granted
        let locationNeeded = locationPermissionStatus != .granted

        if healthKitNeeded && locationNeeded {
            return .both
        } else if healthKitNeeded {
            return .healthKit
        } else if locationNeeded {
            return .location
        } else {
            return nil
        }
    }

    // MARK: - Private Methods

    /// Update permission status from PermissionManager
    private func updatePermissionStatus() {
        healthKitPermissionStatus = permissionManager.healthKitPermissionStatus
        locationPermissionStatus = permissionManager.locationPermissionStatus
    }

    /// Setup observers for permission status changes
    private func setupPermissionObservers() {
        // Observe HealthKit permission changes
        NotificationCenter.default.publisher(for: .healthKitPermissionChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePermissionStatus()
            }
            .store(in: &cancellables)

        // Observe location permission changes
        NotificationCenter.default.publisher(for: .locationPermissionChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePermissionStatus()
            }
            .store(in: &cancellables)
    }

    /// Open iOS Settings app to permission section
    func openPermissionSettings() {
        #if os(iOS)
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        #endif
    }

    private func setupPermissions() async {
        let success = await healthKitManager.requestAuthorization()
        if !success {
            errorMessage = "HealthKit authorization failed. Please check your permissions in Settings."
            print("HealthKit permission setup error")
        }
        locationManager.requestLocation()
    }

    private func setupDataRefreshObservers() {
        // Automatically refresh health data when HealthKit data changes
        NotificationCenter.default.publisher(for: .healthKitDataUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshHealthData()
                }
            }
            .store(in: &cancellables)

        // Automatically refresh advice when health analysis changes
        // Note: refreshAdvice() will check date cache to prevent duplicate generation
        $healthAnalysis
            .dropFirst()  // Skip initial nil value
            .compactMap { $0 }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)  // Avoid rapid updates
            .sink { [weak self] _ in
                Task {
                    await self?.refreshAdvice()
                }
            }
            .store(in: &cancellables)
    }

    // Feedback functionality simplified for now

    /// Create local mock advice for DEBUG mode
    private func createLocalMockAdvice() -> DailyAdvice {
        return DailyAdvice(
            theme: "開発モード",
            summary: "これは開発用のサンプルデータです。実際のAI分析ではありません。",
            breakfast: MealAdvice(
                recommendation: "バランスの良い朝食",
                reason: "開発用サンプル",
                examples: ["トースト", "卵", "野菜サラダ"],
                timing: "7:00-9:00",
                avoid: ["甘いもの", "重いもの"]
            ),
            lunch: MealAdvice(
                recommendation: "軽めの昼食",
                reason: "開発用サンプル",
                examples: ["おにぎり", "味噌汁"],
                timing: "12:00-13:00",
                avoid: ["揚げ物"]
            ),
            dinner: MealAdvice(
                recommendation: "栄養価の高い夕食",
                reason: "開発用サンプル",
                examples: ["焼き魚", "野菜炒め", "ご飯"],
                timing: "18:00-20:00",
                avoid: ["カフェイン", "アルコール"]
            ),
            exercise: ExerciseAdvice(
                recommendation: "軽い散歩",
                intensity: .low,
                reason: "開発用サンプル",
                timing: "夕方",
                avoid: []
            ),
            hydration: HydrationAdvice(
                target: "2リットル",
                schedule: HydrationSchedule(
                    morning: "500ml",
                    afternoon: "750ml",
                    evening: "750ml"
                ),
                reason: "開発用サンプル"
            ),
            breathing: BreathingAdvice(
                technique: "深呼吸",
                duration: "5分",
                frequency: "1日3回",
                instructions: ["鼻から吸って", "口から吐く"]
            ),
            sleepPreparation: SleepPreparationAdvice(
                bedtime: "22:00",
                routine: ["入浴", "読書"],
                avoid: ["カフェイン摂取", "画面を見る"]
            ),
            weatherConsiderations: WeatherConsiderations(
                warnings: ["気圧変化に注意"],
                opportunities: ["適切な服装を選択", "散歩に良い天気"]
            ),
            priorityActions: ["開発用データです", "実際のアドバイスではありません"]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let healthKitDataUpdated = Notification.Name("healthKitDataUpdated")
}

// MARK: - Preview Support

extension HomeViewModel {
    static var preview: HomeViewModel {
        let viewModel = HomeViewModel()

        // Set up preview data
        viewModel.healthAnalysis = HealthAnalysis(
            status: .good,
            overallScore: 0.75,
            confidence: 0.85,
            hrvScore: 0.7,
            sleepScore: 0.8,
            activityScore: 0.7,
            heartRateScore: 0.75
        )

        return viewModel
    }
}
