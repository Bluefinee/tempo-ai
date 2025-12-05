import Combine
import Foundation
import SwiftUI

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

    // MARK: - Private Properties

    private lazy var healthKitManager = HealthKitManager()
    private lazy var locationManager = LocationManager()
    private lazy var healthStatusAnalyzer = HealthStatusAnalyzer()
    private lazy var apiClient = APIClient.shared
    private lazy var adviceTrackingService = AdviceTrackingService()
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
    }

    deinit {
        Task { @MainActor in
            healthKitManager.stopBackgroundDataObservation()
        }
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
    func refreshAdvice() async {
        guard !isLoadingAdvice else { return }

        isLoadingAdvice = true
        defer { isLoadingAdvice = false }

        do {
            let healthData = try await healthKitManager.fetchTodayHealthData()

            guard let locationData = locationManager.locationData else {
                throw APIError.serverError("Location data not available")
            }

            // Use enhanced API with health analysis context
            do {
                let advice: DailyAdvice

                // Try enhanced API with health analysis if available
                if let currentAnalysis = healthAnalysis {
                    // Get user feedback insights for personalization
                    let feedbackInsights = adviceTrackingService.getFeedbackInsights()
                    let userPreferences = adviceTrackingService.getUserPreferences()

                    advice = try await apiClient.analyzeHealthEnhanced(
                        healthData: healthData,
                        location: locationData,
                        userProfile: userProfile,
                        healthAnalysis: currentAnalysis,
                        previousAdviceFollowed: feedbackInsights != nil
                            ? adviceTrackingService.hasConsistentFollowThrough() : nil,
                        userFeedback: generateUserFeedbackSummary(from: feedbackInsights, preferences: userPreferences)
                    )
                } else {
                    // Fallback to standard API
                    advice = try await apiClient.analyzeHealth(
                        healthData: healthData,
                        location: locationData,
                        userProfile: userProfile,
                        healthAnalysis: healthAnalysis
                    )
                }

                todayAdvice = advice
                isMockData = false

                // Start tracking the new advice session
                adviceTrackingService.startAdviceSession(advice: advice, healthAnalysis: healthAnalysis)

            } catch {
                #if DEBUG
                    print("Real API failed, using mock data: \(error.localizedDescription)")

                    // Fallback to mock API in DEBUG builds only
                    let advice = try await apiClient.analyzeHealthMock(
                        healthData: healthData,
                        location: locationData,
                        userProfile: userProfile,
                        healthAnalysis: healthAnalysis
                    )
                    todayAdvice = advice
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

    /// Record that user followed specific advice
    func recordAdviceFollowed(_ adviceType: AdviceType, quality: AdviceQuality? = nil) {
        adviceTrackingService.recordAdviceFollowed(adviceType, quality: quality)
    }

    /// Submit feedback for current advice
    func submitAdviceFeedback(
        overallRating: Int,
        mostHelpful: [AdviceType],
        leastHelpful: [AdviceType],
        comments: String? = nil
    ) {
        adviceTrackingService.submitFeedback(
            overallRating: overallRating,
            mostHelpful: mostHelpful,
            leastHelpful: leastHelpful,
            comments: comments
        )
    }

    /// Get advice tracking service for UI binding
    var adviceTracker: AdviceTrackingService {
        adviceTrackingService
    }

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

    // MARK: - Private Methods

    private func setupPermissions() async {
        do {
            try await healthKitManager.requestAuthorization()
            locationManager.requestLocation()
        } catch {
            errorMessage = "HealthKit setup failed: \(error.localizedDescription)"
            print("Permission setup error: \(error)")
        }
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

    private func generateUserFeedbackSummary(
        from insights: FeedbackInsights?, preferences: UserAdvicePreferences
    ) -> String? {
        guard let insights = insights else { return nil }

        var summary: [String] = []

        if insights.averageRating >= 4.0 {
            summary.append("User generally satisfied with advice quality")
        } else if insights.averageRating < 3.0 {
            summary.append("User requests more personalized recommendations")
        }

        if !preferences.preferredAdviceTypes.isEmpty {
            let preferred = preferences.preferredAdviceTypes.prefix(3).map { $0.rawValue }.joined(separator: ", ")
            summary.append("Prefers \(preferred) advice")
        }

        if !preferences.avoidAdviceTypes.isEmpty {
            let avoided = preferences.avoidAdviceTypes.prefix(2).map { $0.rawValue }.joined(separator: ", ")
            summary.append("Less interested in \(avoided) recommendations")
        }

        switch preferences.communicationStyle {
        case .concise:
            summary.append("Prefers brief, actionable advice")
        case .detailed:
            summary.append("Values detailed explanations and rationale")
        case .balanced:
            break
        }

        if insights.followThroughRate > 0.8 {
            summary.append("High compliance with previous recommendations")
        } else if insights.followThroughRate < 0.5 {
            summary.append("May need simpler, more achievable recommendations")
        }

        return summary.isEmpty ? nil : summary.joined(separator: "; ")
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
