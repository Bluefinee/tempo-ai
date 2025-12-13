import SwiftUI

/// Card component displaying a single action suggestion
/// Used in AdviceDetailView for showing action recommendations
struct ActionSuggestionCard: View {
    let suggestion: ActionSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + Title row
            HStack(spacing: 12) {
                // SF Symbol icon with circle background
                Image(systemName: suggestion.icon.systemImageName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.tempoSoftCoral)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.tempoSoftCoral.opacity(0.15))
                    )

                Text(suggestion.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.tempoPrimaryText)
            }

            // Detail text
            Text(suggestion.detail)
                .font(.subheadline)
                .foregroundColor(.tempoSecondaryText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
    }
}

// MARK: - Preview

#Preview("Fitness") {
    ActionSuggestionCard(
        suggestion: ActionSuggestion(
            icon: .fitness,
            title: "午前中に高強度トレーニング",
            detail: "HRVが高く、睡眠の質も良いため、パフォーマンスを最大限発揮できる状態です。"
        )
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Nutrition") {
    ActionSuggestionCard(
        suggestion: ActionSuggestion(
            icon: .nutrition,
            title: "トレーニング後の栄養補給",
            detail: "30分以内にプロテインと炭水化物を一緒に摂ることで、筋グリコーゲンの回復が早まります。"
        )
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}

#Preview("Stretch") {
    ActionSuggestionCard(
        suggestion: ActionSuggestion(
            icon: .stretch,
            title: "トレーニング前に動的ストレッチ",
            detail: "月曜日は週末の休養明けで、関節が硬くなりやすいタイミングです。肩甲骨周りを入念に動かしてください。"
        )
    )
    .padding(.horizontal, 24)
    .background(Color.tempoLightCream)
}
