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
    private let localStorage: LocalStorageProtocol = LocalStorage()

    // MARK: - Body

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
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

/// ホーム画面のプレースホルダー（Phase 5で実装）
struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink)

                Text("TempoAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("ホーム画面（Phase 5で実装予定）")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Home")
        }
    }
}

/// オンボーディング画面のプレースホルダー（Phase 5で実装）
struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("TempoAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Tune Your Rhythm")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("オンボーディング画面（Phase 5で実装予定）")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 40)
            }
        }
    }
}

#Preview {
    ContentView()
}
