import SwiftUI

// MARK: - Navigation Destination

enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
}

// MARK: - HomeView

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
                        VStack(spacing: 20) {
                            // Advice summary card
                            AdviceSummaryCard(advice: mockAdvice) {
                                navigationPath.append(HomeNavigationDestination.adviceDetail(mockAdvice))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                            // Daily try card
                            DailyTryCard(tryContent: mockAdvice.dailyTry) {
                                navigationPath.append(
                                    HomeNavigationDestination.dailyTryDetail(mockAdvice.dailyTry)
                                )
                            }
                            .padding(.horizontal, 24)

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
#endif
