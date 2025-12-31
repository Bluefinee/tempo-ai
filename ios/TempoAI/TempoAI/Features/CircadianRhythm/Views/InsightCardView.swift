import SwiftUI

/// Displays AI insight with causal relationships
struct InsightCardView: View {
  let insight: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header with icon
      HStack(spacing: 8) {
        Image(systemName: "brain.head.profile")
          .font(.system(size: 16))
          .foregroundColor(.tempoSageGreen)

        Text("今日の見立て")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.tempoPrimaryText)
      }

      // Insight text
      Text(insight)
        .font(.body)
        .foregroundColor(.tempoSecondaryText)
        .lineSpacing(4)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.tempoLightCream)
        .shadow(
          color: Color.black.opacity(0.04),
          radius: 4,
          x: 0,
          y: 2
        )
    )
  }
}

// MARK: - Preview

#if DEBUG
#Preview("Insight Card - Good") {
  InsightCardView(
    insight: "昨夜は就寝が30分早かったため、HRVが+9%改善しました。3日連続でリズムが安定しているため、回復効率がアップしています。"
  )
  .padding()
}

#Preview("Insight Card - Poor") {
  InsightCardView(
    insight: "睡眠リズムが不安定なため、HRVが低下しています。まずは就寝時刻を一定に保つことから始めてみましょう。"
  )
  .padding()
}

#Preview("Insight Card - Long") {
  InsightCardView(
    // swiftlint:disable:next line_length
    insight: "昨夜は普段より1時間遅い就寝でしたが、7時間の睡眠は確保できました。ただし、深い睡眠の割合が通常より少なめだったため、今朝のHRVは平均を少し下回っています。午後は軽めの活動にして、今夜は通常の時刻に就寝することをおすすめします。"
  )
  .padding()
}
#endif
