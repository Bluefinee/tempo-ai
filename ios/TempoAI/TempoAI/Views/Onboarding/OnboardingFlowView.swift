import SwiftUI

/// Main onboarding flow providing a comprehensive 7-page introduction experience.
///
/// This view starts with language selection (page 0), then guides users through understanding
/// Tempo AI's value proposition (pages 1-4) followed by essential permissions setup (pages 5-6).
/// Based on the product specification, users first choose their language, then learn about
/// the app's capabilities before being asked for permissions.
/// Uses a TabView with page-style presentation for smooth transitions.
struct OnboardingFlowView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            // Page 0: Language Selection
            LanguageSelectionPageView()
                .environmentObject(viewModel)
                .tag(0)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.languageSelectionPage)

            // Page 1: Welcome - App Introduction
            WelcomePageView()
                .environmentObject(viewModel)
                .tag(1)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomePage)

            // Page 2: What We Analyze - Data Sources
            DataSourcesPageView()
                .environmentObject(viewModel)
                .tag(2)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesPage)

            // Page 3: AI Analysis - What We Learn
            AIAnalysisPageView()
                .environmentObject(viewModel)
                .tag(3)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisPage)

            // Page 4: What You Get - Daily Plans
            DailyPlansPageView()
                .environmentObject(viewModel)
                .tag(4)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansPage)

            // Page 5: Progressive Disclosure - Privacy & Data Sharing
            ProgressiveDisclosureView()
                .environmentObject(viewModel)
                .tag(5)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.progressiveDisclosurePage)

            // Page 6: HealthKit Permission
            HealthKitPermissionPageView()
                .environmentObject(viewModel)
                .tag(6)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitPage)

            // Page 7: Location Permission & Completion
            LocationPermissionPageView()
                .environmentObject(viewModel)
                .tag(7)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationPage)
        }
        #if os(iOS)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        #endif
        .ignoresSafeArea()
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.tabView)
        .onAppear {
            viewModel.trackOnboardingStart()
        }
    }
}

// MARK: - Preview
struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView()
            .environmentObject(OnboardingViewModel())
    }
}
