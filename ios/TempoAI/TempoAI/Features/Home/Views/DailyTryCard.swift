import SwiftUI

/**
 * Card displaying today's try (daily challenge)
 * Prominently displayed on the home screen
 */
struct DailyTryCard: View {
    let tryContent: TryContent
    let onTapAction: () -> Void

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

            // Try summary
            Text(tryContent.summary)
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
            summary: "トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？",
            detail: "詳細はタップで表示"
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
            summary: "今夜、就寝前に5分だけ「4-7-8呼吸法」を試してみてください。この呼吸法は副交感神経を活性化し、移動で高ぶった交感神経を鎮める効果があります。",
            detail: "詳細はタップで表示"
        )
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}
