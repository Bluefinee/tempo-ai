import SwiftUI

// MARK: - Navigation Destination

enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
    case weeklyTryDetail(TryContent)
}

// MARK: - HomeView

struct HomeView: View {
    let userProfile: UserProfile
    @State private var mockAdvice: DailyAdvice = DailyAdvice.createMock()
    @State private var showAdditionalAdvice: Bool = false
    @State private var navigationPath: NavigationPath = NavigationPath()

    private var isMonday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 2
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                // Main content
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

                                #if DEBUG
                                    // Note: Mock data for development. Real data integration in future phases.
                                    // Metrics grid (2x2)
                                    MetricsGridView(metrics: MockData.mockMetrics)
                                        .padding(.horizontal, 24)

                                    // Daily try card
                                    DailyTryCard(tryContent: mockAdvice.dailyTry) {
                                        navigationPath.append(
                                            HomeNavigationDestination.dailyTryDetail(mockAdvice.dailyTry)
                                        )
                                    }
                                    .padding(.horizontal, 24)

                                    // Weekly try card
                                    if let weeklyTry = mockAdvice.weeklyTry {
                                        WeeklyTryCard(
                                            tryContent: weeklyTry,
                                            isMonday: isMonday
                                        ) {
                                            navigationPath.append(
                                                HomeNavigationDestination.weeklyTryDetail(weeklyTry)
                                            )
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                #endif

                                // Space for tab bar and potential popup
                                Spacer()
                                    .frame(height: 120)
                            }
                        }
                    }
                }

                // Additional advice popup (floating at bottom)
                #if DEBUG
                    if showAdditionalAdvice {
                        AdditionalAdvicePopup(
                            advice: MockData.mockAdditionalAdvice,
                            isVisible: $showAdditionalAdvice
                        )
                    }
                #endif
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeNavigationDestination.self) { destination in
                switch destination {
                case .adviceDetail(let advice):
                    AdviceDetailView(advice: advice)
                case .dailyTryDetail(let tryContent):
                    DailyTryDetailView(tryContent: tryContent)
                case .weeklyTryDetail(let tryContent):
                    WeeklyTryDetailView(tryContent: tryContent)
                }
            }
        }
        #if DEBUG
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation { showAdditionalAdvice = true }
            }
        }
        #endif
    }
}

#if DEBUG
#Preview {
  HomeView(userProfile: UserProfile.sampleData)
}
#endif
