//
//  ContentView.swift
//  TempoAI
//
//  Created by 岩原正和 on 2026/01/01.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Properties

    @State private var hasCompletedOnboarding: Bool = false
    private let localStorage: LocalStorageProtocol

    // MARK: - Initialization

    init(localStorage: LocalStorageProtocol = LocalStorage()) {
        self.localStorage = localStorage
    }

    // MARK: - Body

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }

    // MARK: - Private Methods

    private func checkOnboardingStatus() {
        hasCompletedOnboarding = localStorage.exists(forKey: StorageKeys.onboardingCompleted)
    }
}

// MARK: - Placeholder Views

/// ホーム画面のプレースホルダー（Phase 5cで実装予定）
struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(TempoColors.primary)

                Text("TempoAI")
                    .font(TempoTypography.largeTitle)
                    .foregroundStyle(TempoColors.textPrimary)

                Text("ホーム画面（Phase 5cで実装予定）")
                    .font(TempoTypography.subheadline)
                    .foregroundStyle(TempoColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tempoBackground()
        }
    }
}

#Preview {
    ContentView()
}
