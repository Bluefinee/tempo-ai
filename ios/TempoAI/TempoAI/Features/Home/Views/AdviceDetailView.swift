import SwiftUI

/// Advice detail screen showing full condition details, action suggestions, and closing message
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

                // MARK: - Today's Actions Section

                VStack(alignment: .leading, spacing: 16) {
                    Text("今日のアクション")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.tempoPrimaryText)

                    VStack(spacing: 12) {
                        ForEach(advice.actionSuggestions) { suggestion in
                            ActionSuggestionCard(suggestion: suggestion)
                        }
                    }
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
