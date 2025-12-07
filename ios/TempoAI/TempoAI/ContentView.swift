import SwiftUI

/// Main content view providing tabbed navigation for the TempoAI application.
///
/// This view serves as the root navigation container, organizing the app's primary
/// features into four distinct tabs: Today (Home), History, Trends, and Profile.
/// Each tab provides access to different aspects of the health and wellness experience.
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }

            PlaceholderView(title: "History", icon: "clock.fill", message: "過去のアドバイス履歴\n(Phase 3で実装予定)")
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }

            PlaceholderView(title: "Trends", icon: "chart.line.uptrend.xyaxis", message: "健康データトレンド\n(Phase 4で実装予定)")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Trends")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
        }
        .accessibilityIdentifier(UIIdentifiers.ContentView.tabView)
        .tint(.primary)
    }
}

/// Placeholder view for unimplemented features in future development phases.
///
/// This view provides a consistent interface for features that are planned
/// but not yet implemented, displaying relevant information about the feature
/// and its expected implementation timeline.
///
/// - Parameters:
///   - title: The feature title displayed in navigation
///   - icon: SF Symbol name for the feature icon
///   - message: Descriptive message about the feature and implementation status
struct PlaceholderView: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier(UIIdentifiers.PlaceholderView.icon)

                Text(message)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(UIIdentifiers.PlaceholderView.message)
            }
            .accessibilityIdentifier(UIIdentifiers.PlaceholderView.mainView)
            .padding()
            .navigationTitle(title)
        }
    }
}

/// User profile view displaying personal settings and health preferences.
///
/// This view presents the user's profile information including demographics,
/// health goals, exercise habits, and dietary preferences. Currently serves
/// as a read-only display with editing functionality planned for Phase 2.
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("Profile Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 16) {
                    ProfileRow(title: "Age", value: "28")
                        .accessibilityIdentifier(UIIdentifiers.ProfileView.profileRow(for: "age"))
                    ProfileRow(title: "Gender", value: "Male")
                        .accessibilityIdentifier(UIIdentifiers.ProfileView.profileRow(for: "gender"))
                    ProfileRow(title: "Goals", value: "Fatigue Recovery, Focus")
                        .accessibilityIdentifier(UIIdentifiers.ProfileView.profileRow(for: "goals"))
                    ProfileRow(title: "Exercise Frequency", value: "Active")
                        .accessibilityIdentifier(UIIdentifiers.ProfileView.profileRow(for: "exercise"))
                    ProfileRow(title: "Dietary Preferences", value: "No restrictions")
                        .accessibilityIdentifier(UIIdentifiers.ProfileView.profileRow(for: "dietary"))
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)

                Text("プロフィール編集機能は\nPhase 2で実装予定です")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                #if DEBUG
                    VStack(spacing: 16) {
                        Divider()

                        Text("開発用ツール")
                            .font(.headline)
                            .foregroundColor(.orange)

                        Button("オンボーディングをリセット") {
                            resetOnboarding()

                            // Force app to restart by exiting
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                exit(0)
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)

                        Text("このボタンはデバッグビルドでのみ表示されます")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                #endif

                Spacer()
            }
            .accessibilityIdentifier(UIIdentifiers.ProfileView.mainView)
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#if DEBUG
    /// Resets onboarding state for development purposes
    private func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
        UserDefaults.standard.removeObject(forKey: "onboardingStartTime")
    }
#endif

/// Individual row component for displaying profile information.
///
/// Creates a consistent horizontal layout for profile data with title and value pairs.
/// Used within ProfileView to display various user attributes and preferences.
///
/// - Parameters:
///   - title: The label for the profile attribute
///   - value: The current value for the attribute
struct ProfileRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
}
