import SwiftUI

/// Daily try detail screen showing the full description of today's challenge
struct DailyTryDetailView: View {
    let tryContent: TryContent

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // MARK: - Icon

                Image(systemName: "scope")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.tempoSoftCoral)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.tempoSoftCoral.opacity(0.15))
                    )
                    .padding(.top, 32)

                // MARK: - Title

                Text(tryContent.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.tempoPrimaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // MARK: - Divider

                Rectangle()
                    .fill(Color.tempoLightGray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 24)

                // MARK: - Detail Content

                Text(tryContent.detail)
                    .font(.body)
                    .foregroundColor(.tempoPrimaryText)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Bottom padding for comfortable scrolling
                Spacer()
                    .frame(height: 40)
            }
        }
        .background(Color.tempoLightCream.ignoresSafeArea())
        .navigationTitle("今日のトライ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview("Short Content") {
    NavigationStack {
        DailyTryDetailView(
            tryContent: TryContent(
                title: "ドロップセット法に挑戦",
                summary: "トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？",
                detail: """
                今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？

                限界重量でセットを終えたら、すぐに重量を30%落として限界まで追い込む方法です。

                あなたの今日のHRVと回復状態を見ると、この高強度テクニックに耐えられる体の準備ができています。

                筋肥大に非常に効果的で、普段と違った刺激を筋肉に与えられますよ。ただし週に1-2種目に留めて、オーバートレーニングには注意してくださいね。

                ぜひ今日、試してみてください。
                """
            )
        )
    }
}

#Preview("Long Content") {
    NavigationStack {
        DailyTryDetailView(
            tryContent: TryContent(
                title: "4-7-8呼吸法で眠りを整える",
                summary: "今夜、就寝前に5分だけ試してみませんか？",
                detail: """
                今夜、就寝前に5分だけ「4-7-8呼吸法」を試してみてください。

                4秒かけて鼻から息を吸い、7秒息を止め、8秒かけて口から吐きます。これを4-8回繰り返します。

                この呼吸法は副交感神経を活性化し、移動で高ぶった交感神経を鎮める効果があります。

                あなたの過去1週間のデータを見ると、夜の心拍数がやや高めで推移しています。この呼吸法を習慣にすることで、より深い睡眠につながる可能性があります。

                寝る前の5分間、スマホを置いて、自分の呼吸に集中してみてください。

                継続することで、睡眠の質が向上し、朝の目覚めもよくなるはずです。
                """
            )
        )
    }
}
