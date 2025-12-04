import SwiftUI

struct HomeView: View {
    @StateObject private var healthKitManager: HealthKitManager = HealthKitManager()
    @StateObject private var locationManager: LocationManager = LocationManager()
    @StateObject private var apiClient: APIClient = APIClient.shared

    @State private var todayAdvice: DailyAdvice?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingPermissions: Bool = false

    private let userProfile: UserProfile = UserProfile(
        age: 28,
        gender: "male",
        goals: ["fatigue_recovery", "focus"],
        dietaryPreferences: "No restrictions",
        exerciseHabits: "Regular weight training",
        exerciseFrequency: "active"
    )

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
                        AdviceView(advice: advice)
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
                Text("Good morning!")
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
        } catch {
            errorMessage = "HealthKit setup failed: \(error.localizedDescription)"
        }

        locationManager.requestLocation()
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

            // Try real API first, fallback to mock
            do {
                let advice = try await apiClient.analyzeHealth(
                    healthData: healthData,
                    location: locationData,
                    userProfile: userProfile
                )
                todayAdvice = advice
            } catch {
                // Fallback to mock API
                let advice = try await apiClient.analyzeHealthMock(
                    healthData: healthData,
                    location: locationData,
                    userProfile: userProfile
                )
                todayAdvice = advice
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    HomeView()
}
