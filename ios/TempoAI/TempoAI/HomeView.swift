import SwiftUI

struct HomeView: View {
    @StateObject private var healthKitManager: HealthKitManager = HealthKitManager()
    @StateObject private var locationManager: LocationManager = LocationManager()
    @ObservedObject private var apiClient: APIClient = APIClient.shared

    @State private var todayAdvice: DailyAdvice?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingPermissions: Bool = false
    @State private var isMockData: Bool = false

    private let userProfile: UserProfile = UserProfile(
        age: 28,
        gender: "male",
        goals: ["fatigue_recovery", "focus"],
        dietaryPreferences: "No restrictions",
        exerciseHabits: "Regular weight training",
        exerciseFrequency: "active"
    )

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12:
            return "Good morning!"
        case 12 ..< 17:
            return "Good afternoon!"
        case 17 ..< 22:
            return "Good evening!"
        default:
            return "Good night!"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if isLoading {
                        LoadingView()
                    } else if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage) {
                            await refreshAdvice()
                        }
                    } else if let advice = todayAdvice {
                        VStack(spacing: 12) {
                            if isMockData {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Using simulated data (API unavailable)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.orange.opacity(0.1))
                                .cornerRadius(8)
                            }

                            AdviceView(advice: advice)
                        }
                    } else {
                        EmptyStateView {
                            await refreshAdvice()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshAdvice()
            }
            .task {
                await setupPermissions()
            }
            .sheet(isPresented: $showingPermissions) {
                PermissionsView(
                    healthKitManager: healthKitManager,
                    locationManager: locationManager,
                    onDismiss: {
                        showingPermissions = false
                        Task {
                            await refreshAdvice()
                        }
                    }
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(timeBasedGreeting)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showingPermissions = true
                } label: {
                    Image(systemName: "gear")
                        .font(.title3)
                }
            }

            Text("Here's your personalized health advice for today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func setupPermissions() async {
        do {
            try await healthKitManager.requestAuthorization()
            locationManager.requestLocation()
        } catch {
            errorMessage = "HealthKit setup failed: \(error.localizedDescription)"
            return
        }
    }

    private func refreshAdvice() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let healthData = try await healthKitManager.fetchTodayHealthData()

            guard let locationData = locationManager.locationData else {
                throw APIError.serverError("Location data not available")
            }

            // Try real API first, fallback to mock in DEBUG builds
            do {
                let advice = try await apiClient.analyzeHealth(
                    healthData: healthData,
                    location: locationData,
                    userProfile: userProfile
                )
                todayAdvice = advice
                isMockData = false
            } catch {
                #if DEBUG
                    print("Real API failed, using mock data: \(error.localizedDescription)")
                #endif

                #if DEBUG
                    // Fallback to mock API in DEBUG builds only
                    let advice = try await apiClient.analyzeHealthMock(
                        healthData: healthData,
                        location: locationData,
                        userProfile: userProfile
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
        }
    }
}

#Preview {
    HomeView()
}
