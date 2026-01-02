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

#Preview {
    ContentView()
}
