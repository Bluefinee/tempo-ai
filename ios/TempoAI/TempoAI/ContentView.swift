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
    @State private var showingProfileSettings = false
    @State private var showingAISettings = false
    @State private var showingDataPermissions = false
    @State private var showingPrivacySettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("設定")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)

                        Text("あなたの体験をカスタマイズ")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                    }
                    .padding(.top, Spacing.lg)

                    // Settings Cards
                    VStack(spacing: Spacing.md) {
                        // Profile Settings
                        SettingsCardRow(
                            icon: "person.circle.fill",
                            title: "あなたのプロフィール",
                            subtitle: "AIがあなたに合わせて最適化",
                            status: userProfileManager.currentMode.displayName,
                            color: Color(.systemBlue)
                        ) {
                            showingProfileSettings = true
                        }

                        // AI Analysis Settings
                        SettingsCardRow(
                            icon: "brain.head.profile",
                            title: "AI分析とカスタマイズ",
                            subtitle: aiSettingsSubtitle,
                            status: "\(focusTagManager.activeTags.count)つの関心領域",
                            color: Color(.systemPurple)
                        ) {
                            showingAISettings = true
                        }

                        // Data Permissions
                        SettingsCardRow(
                            icon: "heart.text.square.fill",
                            title: "データ連携",
                            subtitle: "さらに詳しい分析で精度向上",
                            status: "6項目許可済み",  // TODO: Make this dynamic
                            color: Color(.systemRed)
                        ) {
                            showingDataPermissions = true
                        }

                        // Privacy and Notifications
                        SettingsCardRow(
                            icon: "lock.shield.fill",
                            title: "プライバシーと通知",
                            subtitle: "あなたのデータはデバイス内で処理",
                            status: "安全に保護",
                            color: Color(.systemGreen)
                        ) {
                            showingPrivacySettings = true
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    #if DEBUG
                        // Developer Tools (Debug only)
                        VStack {
                            Button("オンボーディングリセット") {
                                resetOnboarding()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ColorPalette.error)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md)
                                    .fill(ColorPalette.error.opacity(0.1))
                            )
                        }
                        .padding(.top, Spacing.xl)
                    #endif

                    Spacer()
                }
            }
            .background(ColorPalette.gray50)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingProfileSettings) {
            ProfileSettingsView()
        }
        .sheet(isPresented: $showingAISettings) {
            AIAnalysisSettingsView()
        }
        .sheet(isPresented: $showingDataPermissions) {
            DataPermissionsView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
    }

    private var aiSettingsSubtitle: String {
        let tags = Array(focusTagManager.activeTags.prefix(3))
        if tags.isEmpty {
            return "タップして関心領域を設定"
        }
        return tags.map { $0.displayName }.joined(separator: "、")
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

#Preview {
    ContentView()
}
