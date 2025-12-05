import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .accessibilityIdentifier(UIIdentifiers.ContentView.todayTab)

            PlaceholderView(title: "History", icon: "clock.fill", message: "過去のアドバイス履歴\n(Phase 3で実装予定)")
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .accessibilityIdentifier(UIIdentifiers.ContentView.historyTab)

            PlaceholderView(title: "Trends", icon: "chart.line.uptrend.xyaxis", message: "健康データトレンド\n(Phase 4で実装予定)")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Trends")
                }
                .accessibilityIdentifier(UIIdentifiers.ContentView.trendsTab)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .accessibilityIdentifier(UIIdentifiers.ContentView.profileTab)
        }
        .accessibilityIdentifier(UIIdentifiers.ContentView.tabView)
        .tint(.primary)
    }
}

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

                Spacer()
            }
            .accessibilityIdentifier(UIIdentifiers.ProfileView.mainView)
            .padding()
            .navigationTitle("Profile")
        }
    }
}

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
