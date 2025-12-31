import SwiftUI

// MARK: - Navigation Destination

enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
}

// MARK: - HomeView

/**
 * Main home screen displaying daily health advice
 * Phase 10: Added EnergyBatteryView at the top of scrollable content
 *
 * Layout (from ui-spec.md):
 * - Header → Energy Battery (16pt)
 * - Energy Battery → Advice Summary (20pt)
 * - Advice Summary → Daily Try (24pt)
 */
struct HomeView: View {
    let userProfile: UserProfile
    @State private var mockAdvice: DailyAdvice = DailyAdvice.createMock()
    @State private var navigationPath: NavigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                // Background
                Color.tempoLightCream
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header (fixed)
                    HomeHeaderView(userProfile: userProfile)

                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Energy Battery View (Phase 10)
                            EnergyBatteryView(
                                scores: mockAdvice.scores,
                                energyComment: mockAdvice.energyComment
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 16)  // 16pt from header

                            // Advice summary card
                            AdviceSummaryCard(advice: mockAdvice) {
                                navigationPath.append(HomeNavigationDestination.adviceDetail(mockAdvice))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)  // 20pt from energy battery

                            // Daily try card
                            DailyTryCard(tryContent: mockAdvice.dailyTry) {
                                navigationPath.append(
                                    HomeNavigationDestination.dailyTryDetail(mockAdvice.dailyTry)
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)  // 24pt from advice card

                            // Space for tab bar
                            Spacer()
                                .frame(height: 120)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeNavigationDestination.self) { destination in
                switch destination {
                case .adviceDetail(let advice):
                    AdviceDetailView(advice: advice)
                case .dailyTryDetail(let tryContent):
                    DailyTryDetailView(tryContent: tryContent)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    HomeView(userProfile: UserProfile.sampleData)
}

#Preview("Low Energy") {
    let lowEnergyAdvice = DailyAdvice.createMock(
        withHrvScore: 35
    )
    return HomeView(userProfile: UserProfile.sampleData)
}
#endif
