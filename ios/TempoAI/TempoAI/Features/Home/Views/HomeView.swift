import SwiftUI

// MARK: - Navigation Destination

enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
    case weeklyTryDetail(TryContent)
}

// MARK: - Hashable Conformance for Navigation

extension DailyAdvice: Hashable {
    static func == (lhs: DailyAdvice, rhs: DailyAdvice) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TryContent: Hashable {
    static func == (lhs: TryContent, rhs: TryContent) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - HomeView

struct HomeView: View {
    let userProfile: UserProfile
    @State private var mockAdvice = DailyAdvice.createMock()
    @State private var showAdditionalAdvice: Bool = false
    @State private var navigationPath = NavigationPath()

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
                                    if let weeklyTry: TryContent = mockAdvice.weeklyTry {
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
            .navigationBarHidden(true)
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
        .onAppear {
            // Demo: Show additional advice after 2 seconds
            #if DEBUG
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showAdditionalAdvice = true
                    }
                }
            #endif
        }
    }
}

#if DEBUG
#Preview {
  HomeView(userProfile: UserProfile.sampleData)
}
#endif
