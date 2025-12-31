import SwiftUI

/// Advice detail screen showing full condition details, insight, and closing message
/// Phase 10: Replaced action suggestions with insight section
struct AdviceDetailView: View {
    let advice: DailyAdvice

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // MARK: - Today's Condition Section

                VStack(alignment: .leading, spacing: 16) {
                    Text("今日のコンディション")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.tempoPrimaryText)

                    Text(advice.condition.detail)
                        .font(.body)
                        .foregroundColor(.tempoPrimaryText)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Insight Section (Phase 10: replaces action suggestions)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tempoSoftCoral)

                        Text("AIの見立て")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.tempoPrimaryText)
                    }

                    Text(advice.insight)
                        .font(.body)
                        .foregroundColor(.tempoPrimaryText)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.tempoSoftCoral.opacity(0.08))
                        )
                }

                // MARK: - Closing Message

                Text(advice.closingMessage)
                    .font(.body)
                    .foregroundColor(.tempoSecondaryText)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)

                // Bottom padding for comfortable scrolling
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .background(Color.tempoLightCream.ignoresSafeArea())
        .navigationTitle("今日のアドバイス")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AdviceDetailView(advice: DailyAdvice.createMock())
    }
}
