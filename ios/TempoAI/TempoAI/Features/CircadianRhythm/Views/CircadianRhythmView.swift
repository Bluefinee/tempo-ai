import SwiftUI

/// Main view for the Circadian Rhythm tab
/// Displays 24-hour circle, rhythm stability, metrics triangle, and AI insight
struct CircadianRhythmView: View {
  let data: CircadianData

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // 24-hour circle with HRV
          CircadianCircleView(data: data)
            .frame(height: 280)
            .padding(.horizontal, 16)

          // Rhythm stability
          RhythmStabilityView(data: data)
            .padding(.horizontal, 16)

          // 3 metrics triangle
          MetricsTriangleView(scores: data.scores)
            .padding(.horizontal, 16)

          // AI insight
          InsightCardView(insight: data.insight)
            .padding(.horizontal, 16)

          // Bottom padding for tab bar
          Spacer()
            .frame(height: 20)
        }
        .padding(.top, 16)
      }
      .background(Color.tempoBackground)
      .navigationTitle("リズム")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

// MARK: - Preview

#if DEBUG
#Preview("Circadian Rhythm - Good") {
  CircadianRhythmView(data: .mock)
}

#Preview("Circadian Rhythm - Poor") {
  CircadianRhythmView(data: .mockPoorRhythm)
}
#endif
