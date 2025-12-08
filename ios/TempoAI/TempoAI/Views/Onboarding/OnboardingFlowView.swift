import SwiftUI
import HealthKit
import CoreLocation

struct PermissionItem: Identifiable {
    let id: UUID = UUID()
    let icon: String
    let title: String
    let description: String
}

struct OnboardingFlowView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.pureWhite
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Simple progress indicator
                    if coordinator.currentPage != .welcome && coordinator.currentPage != .completion {
                        HStack {
                            ForEach(0..<OnboardingPage.allCases.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= coordinator.currentPage.rawValue ? 
                                          ColorPalette.richBlack : ColorPalette.gray300)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, Spacing.lg)
                    }

                    // Direct page rendering
                    Group {
                        switch coordinator.currentPage {
                        case .welcome:
                            WelcomePage(onNext: coordinator.nextPage)
                        case .userMode:
                            UserModePage(
                                selectedMode: $coordinator.selectedUserMode,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .focusTags:
                            FocusTagsPage(
                                selectedTags: $coordinator.selectedTags,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .healthPermission:
                            HealthPermissionPage(
                                isGranted: $coordinator.healthPermissionGranted,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .locationPermission:
                            LocationPermissionPage(
                                isGranted: $coordinator.locationPermissionGranted,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .completion:
                            CompletionPage {
                                coordinator.completeOnboarding()
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(OnboardingCoordinator())
}