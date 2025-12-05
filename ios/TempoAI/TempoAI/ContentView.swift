import SwiftUI

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

                Text(message)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
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
                    ProfileRow(title: "Gender", value: "Male")
                    ProfileRow(title: "Goals", value: "Fatigue Recovery, Focus")
                    ProfileRow(title: "Exercise Frequency", value: "Active")
                    ProfileRow(title: "Dietary Preferences", value: "No restrictions")
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
