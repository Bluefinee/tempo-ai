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
    @ObservedObject private var focusTagManager = FocusTagManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Coming Soon Message
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(ColorPalette.primaryAccent)
                    
                    VStack(spacing: Spacing.md) {
                        Text("設定機能準備中")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)
                        
                        Text("Phase 1.5以降で実装予定\n\n現在は6つの関心分野選択で\nパーソナライズをお楽しみください")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    
                    // Show current focus areas
                    if !focusTagManager.activeTags.isEmpty {
                        VStack(spacing: Spacing.sm) {
                            Text("選択済み関心分野")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ColorPalette.gray500)
                            
                            HStack(spacing: Spacing.sm) {
                                ForEach(Array(focusTagManager.activeTags), id: \.self) { tag in
                                    Text(tag.displayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(tag.themeColor)
                                        .padding(.horizontal, Spacing.sm)
                                        .padding(.vertical, Spacing.xs)
                                        .background(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .fill(tag.themeColor.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(.top, Spacing.lg)
                    }
                }
                
                Spacer()
                
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
                #endif
            }
            .padding(Spacing.lg)
            .background(ColorPalette.pureWhite)
            .navigationBarHidden(true)
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

#Preview {
    ContentView()
}
