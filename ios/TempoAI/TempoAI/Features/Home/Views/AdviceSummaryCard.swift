import SwiftUI

struct AdviceSummaryCard: View {
  let advice: DailyAdvice

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

        Button("詳しく見る") {
          // Phase 4で実装予定
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.tempoSoftCoral)
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
  AdviceSummaryCard(advice: DailyAdvice.createMock())
    .padding()
    .background(Color.tempoLightCream)
}

