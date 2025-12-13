import SwiftUI

/**
 * Card displaying this week's try (weekly challenge)
 * Shows full card on Monday with NEW badge, compact version on other days
 */
struct WeeklyTryCard: View {
    let tryContent: TryContent?
    let isMonday: Bool
    let onTapAction: () -> Void

    var body: some View {
        if let tryContent = tryContent {
            if isMonday {
                // Full card for Monday
                VStack(alignment: .leading, spacing: 16) {
                    // Section title with icon and NEW badge
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tempoSoftCoral)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color.tempoSoftCoral.opacity(0.15))
                            )

                        Text("今週のトライ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.tempoPrimaryText)

                        Spacer()

                        // NEW badge
                        Text("NEW!")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.tempoSoftCoral)
                            )
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
            } else {
                // Compact card for Tuesday-Sunday
                Button {
                    onTapAction()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.tempoSoftCoral)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(Color.tempoSoftCoral.opacity(0.15))
                            )

                        Text("今週のトライ: \(tryContent.title)")
                            .font(.subheadline)
                            .foregroundColor(.tempoPrimaryText)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.tempoSecondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tempoLightCream)
                            .shadow(
                                color: Color.black.opacity(0.06),
                                radius: 4,
                                x: 0,
                                y: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview("Monday - Full Card") {
    WeeklyTryCard(
        tryContent: TryContent(
            title: "セサミオイルで足裏マッサージ",
            summary: "アーユルヴェーダの知恵で、深い眠りと自律神経の安定を目指しましょう。",
            detail: "詳細はタップで表示"
        ),
        isMonday: true
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Tuesday-Sunday - Compact") {
    WeeklyTryCard(
        tryContent: TryContent(
            title: "セサミオイルで足裏マッサージ",
            summary: "アーユルヴェーダの知恵で、深い眠りと自律神経の安定を目指しましょう。",
            detail: "詳細はタップで表示"
        ),
        isMonday: false
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("No Weekly Try") {
    WeeklyTryCard(
        tryContent: nil,
        isMonday: true
    ) {
        // Navigation handled in production
    }
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}
