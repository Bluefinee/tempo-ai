import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()

    var body: some View {
        Group {
            if onboardingCoordinator.isCompleted {
                MainAppView()
            } else {
                OnboardingFlowView()
                    .environmentObject(onboardingCoordinator)
            }
        }
    }
}

struct MainAppView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }

            PlaceholderView(
                title: "History",
                icon: "clock.fill",
                message: "過去のアドバイス履歴\nPhase 2で実装予定"
            )
            .tabItem {
                Image(systemName: "clock.fill")
                Text("History")
            }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

struct PlaceholderView: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(ColorPalette.gray400)

                Text(message)
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle(title)
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var userProfileManager = UserProfileManager.shared
    @ObservedObject private var focusTagManager = FocusTagManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section("ユーザー設定") {
                    UserModeRow(userMode: userProfileManager.currentMode) {
                        // TODO: Present mode selection sheet/view
                        // For now, just update to next mode for testing
                        let nextMode: UserMode = userProfileManager.currentMode == .standard ? .athlete : .standard
                        userProfileManager.updateMode(nextMode)
                    }
                }

                Section("関心タグ") {
                    ForEach(FocusTag.allCases, id: \.self) { tag in
                        FocusTagRow(
                            tag: tag,
                            isSelected: focusTagManager.activeTags.contains(tag)
                        ) {
                            focusTagManager.toggleTag(tag)
                        }
                    }
                }

                #if DEBUG
                    Section("開発者ツール") {
                        Button("オンボーディングリセット") {
                            resetOnboarding()
                        }
                        .foregroundColor(ColorPalette.error)
                    }
                #endif
            }
            .navigationTitle("Settings")
        }
    }

    #if DEBUG
        private func resetOnboarding() {
            UserDefaults.standard.removeObject(forKey: "onboarding_completed")
            UserDefaults.standard.removeObject(forKey: "focus_tags_onboarding_completed")
            UserDefaults.standard.removeObject(forKey: "active_focus_tags")
            exit(0)
        }
    #endif
}

struct UserModeRow: View {
    let userMode: UserMode
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text("バッテリーモード")
                .typography(.body)

            Spacer()

            Text(userMode.displayName)
                .typography(.body)
                .foregroundColor(ColorPalette.gray600)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(ColorPalette.gray400)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct FocusTagRow: View {
    let tag: FocusTag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Text(tag.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(tag.displayName)
                    .typography(.body)

                Text(tag.description)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }

            Spacer()

            Toggle(
                "",
                isOn: .init(
                    get: { isSelected },
                    set: { _ in onToggle() }
                ))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    ContentView()
}
