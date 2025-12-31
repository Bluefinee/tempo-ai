import SwiftUI

/**
 * Card displaying today's try (daily challenge)
 * Prominently displayed on the home screen
 * Phase 10: Updated to show detail preview instead of summary
 */
struct DailyTryCard: View {
    let tryContent: TryContent
    let onTapAction: () -> Void

    /// Preview of detail text (first 60 characters)
    private var detailPreview: String {
        if tryContent.detail.count <= 60 {
            return tryContent.detail
        }
        let index = tryContent.detail.index(
            tryContent.detail.startIndex,
            offsetBy: 60
        )
        return String(tryContent.detail[..<index]) + "..."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title with icon
            HStack(spacing: 8) {
                Image(systemName: "scope")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.tempoSoftCoral)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.tempoSoftCoral.opacity(0.15))
                    )

                Text("今日のトライ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.tempoPrimaryText)
            }

            // Try title
            Text(tryContent.title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.tempoPrimaryText)

            // Try detail preview (Phase 10: replaced summary with detail preview)
            Text(detailPreview)
                .font(.subheadline)
                .foregroundColor(.tempoSecondaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            // CTA button
            HStack {
                Spacer()
                Button {
                    onTapAction()
                } label: {
                    HStack(spacing: 4) {
                        Text("詳しく見る")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.tempoSoftCoral)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tempoLightCream)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

// MARK: - Preview

#Preview("Daily Try") {
    DailyTryCard(
        tryContent: TryContent(
            title: "ドロップセット法に挑戦",
            detail: "トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？通常の重量でできる限界まで行った後、重量を20-30%下げてさらに限界まで続けます。"
        )
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Long Text") {
    DailyTryCard(
        tryContent: TryContent(
            title: "4-7-8呼吸法で眠りを整える",
            detail: "今夜、就寝前に5分だけ「4-7-8呼吸法」を試してみてください。この呼吸法は副交感神経を活性化し、移動で高ぶった交感神経を鎮める効果があります。鼻から4秒かけて吸い、7秒間息を止め、8秒かけてゆっくり吐き出します。"
        )
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}
