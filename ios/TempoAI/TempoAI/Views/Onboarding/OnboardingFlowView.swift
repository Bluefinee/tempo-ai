import SwiftUI

/// Main onboarding flow providing a beautiful 4-page introduction experience.
///
/// This view guides users through the essential setup process including app introduction,
/// HealthKit permissions, location permissions, and completion confirmation.
/// Uses a TabView with page-style presentation for smooth transitions.
struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            WelcomePageView(viewModel: viewModel)
                .tag(0)

            HealthKitPermissionPageView(viewModel: viewModel)
                .tag(1)

            LocationPermissionPageView(viewModel: viewModel)
                .tag(2)

            CompletionPageView(viewModel: viewModel) {
                viewModel.completeOnboarding()
                dismiss()
            }
            .tag(3)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
        .onAppear {
            viewModel.trackOnboardingStart()
        }
    }
}

// MARK: - Welcome Page
struct WelcomePageView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.pink, .white)

                Text("Welcome to Tempo AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your personalized health advisor that learns from your data to provide daily wellness guidance.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button("Get Started") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.nextPage()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - HealthKit Permission Page
struct HealthKitPermissionPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)

                Text("Health Data Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("We analyze your sleep, heart rate, and activity data to provide personalized wellness advice.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                PermissionFeatureRow(
                    icon: "bed.double.fill",
                    title: "Sleep Analysis",
                    description: "Track sleep quality and duration"
                )

                PermissionFeatureRow(
                    icon: "heart.fill",
                    title: "Heart Rate Variability",
                    description: "Monitor stress and recovery levels"
                )

                PermissionFeatureRow(
                    icon: "figure.walk",
                    title: "Activity Data",
                    description: "Understand your daily movement patterns"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    isRequesting = true
                    Task {
                        await viewModel.requestHealthKitPermission()
                        isRequesting = false
                    }
                } label: {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text("Allow Health Access")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRequesting)

                if viewModel.healthKitStatus == .granted {
                    Button("Continue") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            viewModel.nextPage()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button("Skip for Now") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.nextPage()
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Location Permission Page
struct LocationPermissionPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Location for Weather")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("We use your location to provide weather-based health recommendations and environmental alerts.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                PermissionFeatureRow(
                    icon: "cloud.sun.fill",
                    title: "Weather-Based Advice",
                    description: "Adapt recommendations to weather conditions"
                )

                PermissionFeatureRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Environmental Alerts",
                    description: "Alerts for extreme weather or air quality"
                )

                PermissionFeatureRow(
                    icon: "thermometer.sun.fill",
                    title: "Temperature Awareness",
                    description: "Adjust activity suggestions for temperature"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    isRequesting = true
                    Task {
                        await viewModel.requestLocationPermission()
                        isRequesting = false
                    }
                } label: {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text("Allow Location Access")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRequesting)

                if viewModel.locationStatus == .granted {
                    Button("Continue") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            viewModel.nextPage()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button("Skip for Now") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.nextPage()
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Completion Page
struct CompletionPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)

                Text("All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("You're ready to receive personalized health advice. Let's start your wellness journey!")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                PermissionStatusRow(
                    title: "Health Data",
                    status: viewModel.healthKitStatus
                )

                PermissionStatusRow(
                    title: "Location",
                    status: viewModel.locationStatus
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            Button("Start Using Tempo AI") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Supporting Views
struct PermissionFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct PermissionStatusRow: View {
    let title: String
    let status: PermissionStatus

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)

                Text(status.displayText)
                    .font(.caption)
                    .foregroundColor(status.color)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OnboardingFlowView()
}
