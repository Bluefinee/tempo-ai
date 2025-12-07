//
//  TempoAIApp.swift
//  TempoAI
//
//  Created by 岩原正和 on 2025/12/04.
//

import SwiftUI

@main
struct TempoAIApp: App {
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingViewModel.isOnboardingCompleted {
                    ContentView()
                } else {
                    OnboardingFlowView()
                        .environmentObject(onboardingViewModel)
                }
            }
            .onAppear {
                // Ensure consistent state on app launch
                if ProcessInfo.processInfo.environment["RESET_ONBOARDING"] == "1" {
                    onboardingViewModel.resetOnboarding()
                }
            }
        }
    }
}
