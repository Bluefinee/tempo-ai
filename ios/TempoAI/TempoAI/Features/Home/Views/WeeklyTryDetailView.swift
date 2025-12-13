import SwiftUI

/// Weekly try detail screen showing the full description of this week's challenge
struct WeeklyTryDetailView: View {
    let tryContent: TryContent

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // MARK: - Icon

                Image(systemName: "calendar")
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
        .navigationTitle("今週のトライ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview("Week Challenge") {
    NavigationStack {
        WeeklyTryDetailView(
            tryContent: TryContent(
                title: "セサミオイルで足裏マッサージ",
                summary: "アーユルヴェーダの知恵で、深い眠りと自律神経の安定を",
                detail: """
                今週のチャレンジ:
                セサミオイルで寝る前の足裏マッサージ

                アーユルヴェーダでは、足裏のマッサージが深い眠りと自律神経の安定につながるとされています。

                【やり方】
                1. 少量のセサミオイルを手に取り、体温で温めます
                2. 足裏全体を優しくマッサージ
                3. 特に土踏まずと指の付け根を重点的に

                【期待できる効果】
                ・血行促進とリラックス
                ・睡眠の質の向上
                ・自律神経の調整

                今週、3回以上試してみてください。
                """
            )
        )
    }
}

#Preview("Long Content with Lists") {
    NavigationStack {
        WeeklyTryDetailView(
            tryContent: TryContent(
                title: "毎朝同じ時間に起きる習慣",
                summary: "サーカディアンリズムを安定させる最も効果的な方法",
                detail: """
                今週は、週末も含めて毎朝7時に起きることを目標にしてみませんか？

                サーカディアンリズムを安定させる最も効果的な方法の一つが、起床時間を固定することです。

                【実践のポイント】
                1. 目覚まし時計を毎日同じ時刻にセット
                2. 朝起きたら、カーテンを開けて光を浴びる
                3. 起床後30分以内に軽い運動や散歩
                4. 週末も同じリズムを維持

                【期待できる効果】
                ・睡眠の質の向上
                ・日中のパフォーマンス向上
                ・自律神経のバランス改善
                ・ストレス耐性の向上

                あなたの過去1ヶ月のデータを見ると、週末に起床時間が2-3時間遅れる傾向があります。まずは1週間、この習慣にチャレンジしてみてください。

                月曜日の朝が楽になり、週全体のコンディションが安定するはずです。
                """
            )
        )
    }
}
