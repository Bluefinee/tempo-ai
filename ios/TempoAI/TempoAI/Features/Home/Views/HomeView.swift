import SwiftUI

struct HomeView: View {
  let userProfile: UserProfile
  @State private var mockAdvice: DailyAdvice = DailyAdvice.createMock()
  @State private var showAdditionalAdvice: Bool = false

  private var isMonday: Bool {
    Calendar.current.component(.weekday, from: Date()) == 2
  }

  var body: some View {
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
              AdviceSummaryCard(advice: mockAdvice)
                .padding(.horizontal, 24)
                .padding(.top, 8)

              #if DEBUG
                // Metrics grid (2x2)
                MetricsGridView(metrics: MockData.mockMetrics)
                  .padding(.horizontal, 24)

                // Daily try card
                DailyTryCard(tryContent: mockAdvice.dailyTry)
                  .padding(.horizontal, 24)

                // Weekly try card
                WeeklyTryCard(
                  tryContent: mockAdvice.weeklyTry,
                  isMonday: isMonday
                )
                .padding(.horizontal, 24)
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

#Preview {
  HomeView(userProfile: UserProfile.sampleData)
}
