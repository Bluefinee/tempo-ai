import SwiftUI

struct HomeView: View {
  let userProfile: UserProfile
  @State private var mockAdvice: DailyAdvice = DailyAdvice.createMock()

  var body: some View {
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

            // Area for Phase 3 additions
            VStack(spacing: 16) {
              Text("Phase 3で追加予定")
                .font(.subheadline)
                .foregroundColor(.tempoSecondaryText)

              Text("• メトリクスカード\n• トライカード")
                .font(.caption)
                .foregroundColor(.tempoSecondaryText.opacity(0.7))
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)

            // Space for tab bar
            Spacer()
              .frame(height: 100)
          }
        }
      }
    }
    .navigationBarHidden(true)
  }
}

#Preview {
  HomeView(userProfile: UserProfile.sampleData)
}

