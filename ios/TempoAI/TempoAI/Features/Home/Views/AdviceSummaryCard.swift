import SwiftUI

struct AdviceSummaryCard: View {
    let advice: DailyAdvice
    let onTapAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Advice content
            Text(advice.condition.summary)
                .font(.body)
                .foregroundColor(.tempoPrimaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            // "See details" link
            HStack {
                Spacer()

                Button {
                    onTapAction()
                } label: {
                    HStack(spacing: 4) {
                        Text("詳しく見る")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.tempoSoftCoral)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    AdviceSummaryCard(advice: DailyAdvice.createMock()) {
        // Navigation handled in production
    }
    .padding()
    .background(Color.tempoLightCream)
}

