//
//  MainTabView.swift
//  TempoAI
//
//  Main tab navigation with Home, Analytics, and Settings
//

import SwiftUI

// MARK: - MainTabView

/// メインタブナビゲーション
struct MainTabView: View {

    // MARK: - Properties

    @State private var selectedTab: Tab = .home

    /// AnalyticsViewに渡すHealthKitManager
    @StateObject private var healthKitManager: HealthKitManager = HealthKitManager()

    // MARK: - Tab Enum

    enum Tab: String, CaseIterable {
        case home = "ホーム"
        case analytics = "分析"
        case settings = "設定"

        var icon: String {
            switch self {
            case .home:
                return "house"
            case .analytics:
                return "chart.bar"
            case .settings:
                return "gearshape"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home:
                return "house.fill"
            case .analytics:
                return "chart.bar.fill"
            case .settings:
                return "gearshape.fill"
            }
        }
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        Tab.home.rawValue,
                        systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon
                    )
                }
                .tag(Tab.home)

            AnalyticsView(healthKitManager: healthKitManager)
                .tabItem {
                    Label(
                        Tab.analytics.rawValue,
                        systemImage: selectedTab == .analytics ? Tab.analytics.selectedIcon : Tab.analytics.icon
                    )
                }
                .tag(Tab.analytics)

            SettingsView()
                .tabItem {
                    Label(
                        Tab.settings.rawValue,
                        systemImage: selectedTab == .settings ? Tab.settings.selectedIcon : Tab.settings.icon
                    )
                }
                .tag(Tab.settings)
        }
        .tint(TempoColors.primary)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MainTabView") {
    MainTabView()
}
#endif
