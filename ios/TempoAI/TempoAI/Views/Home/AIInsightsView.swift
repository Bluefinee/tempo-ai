/**
 * @fileoverview AI Insights Display Components
 *
 * AI分析結果を表示するUIコンポーネント群。
 * プログレッシブエンハンスメントとローディング状態を含む。
 */

import SwiftUI

/**
 * AI分析結果表示ビュー
 * ヘッドライン、タグインサイト、今日のトライを統合表示
 */
struct AIInsightsView: View {
    let analysis: AIAnalysisResponse
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // ヘッドライン表示
            AIHeadlineCard(headline: analysis.headline)
            
            // タグ別インサイト
            if !analysis.tagInsights.isEmpty {
                AITagInsightsView(insights: analysis.tagInsights)
            }
            
            // 今日のトライ提案
            if !analysis.aiActionSuggestions.isEmpty {
                AITodaysTriesView(suggestions: analysis.aiActionSuggestions)
            }
            
            // 詳細分析（折りたたみ）
            AIDetailAnalysisView(detailText: analysis.detailAnalysis)
        }
    }
}

/**
 * AIヘッドライン表示カード
 * UXの「Answer First」原則を体現
 */
struct AIHeadlineCard: View {
    let headline: HeadlineInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                // 影響レベルインジケーター
                Circle()
                    .fill(impactLevelColor)
                    .frame(width: 12, height: 12)
                
                Text(headline.title)
                    .typography(.headline)
                    .foregroundColor(ColorPalette.richBlack)
                
                Spacer()
                
                // AI信頼度表示
                Text("\(Int(headline.confidence))%")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }
            
            Text(headline.subtitle)
                .typography(.body)
                .foregroundColor(ColorPalette.gray600)
                .multilineTextAlignment(.leading)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(ColorPalette.pureWhite)
                .shadow(color: ColorPalette.richBlack.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(impactLevelColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var impactLevelColor: Color {
        switch headline.impactLevel {
        case .low: return ColorPalette.success
        case .medium: return ColorPalette.warning
        case .high: return ColorPalette.error
        case .critical: return ColorPalette.error
        }
    }
}

/**
 * タグ別インサイト表示
 */
struct AITagInsightsView: View {
    let insights: [TagInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("関心分野からの分析")
                .typography(.subhead)
                .foregroundColor(ColorPalette.richBlack)
            
            LazyVStack(spacing: Spacing.sm) {
                ForEach(insights, id: \.tag) { insight in
                    AITagInsightCard(insight: insight)
                }
            }
        }
    }
}

/**
 * 個別タグインサイトカード
 */
struct AITagInsightCard: View {
    let insight: TagInsight
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // タグアイコン
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.tag.themeColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(insight.tag.displayName)
                        .typography(.subhead)
                        .foregroundColor(ColorPalette.richBlack)
                    
                    Spacer()
                    
                    // 緊急度バッジ
                    if insight.urgency != .info {
                        Text(urgencyText)
                            .typography(.caption)
                            .foregroundColor(urgencyColor)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(urgencyColor.opacity(0.1))
                            )
                    }
                }
                
                Text(insight.message)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(insight.tag.themeColor.opacity(0.05))
        )
    }
    
    private var urgencyText: String {
        switch insight.urgency {
        case .info: return ""
        case .warning: return "注意"
        case .critical: return "重要"
        }
    }
    
    private var urgencyColor: Color {
        switch insight.urgency {
        case .info: return ColorPalette.info
        case .warning: return ColorPalette.warning
        case .critical: return ColorPalette.error
        }
    }
}

/**
 * 今日のトライ提案表示
 */
struct AITodaysTriesView: View {
    let suggestions: [AIActionSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("今日のトライ")
                .typography(.subhead)
                .foregroundColor(ColorPalette.richBlack)
            
            LazyVStack(spacing: Spacing.sm) {
                ForEach(suggestions.prefix(3), id: \.title) { suggestion in
                    AITryCard(suggestion: suggestion)
                }
            }
        }
    }
}

/**
 * 今日のトライカード
 */
struct AITryCard: View {
    let suggestion: AIActionSuggestion
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // アクションタイプアイコン
            Image(systemName: actionTypeIcon)
                .font(.title3)
                .foregroundColor(difficultyColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(suggestion.title)
                        .typography(.subhead)
                        .foregroundColor(ColorPalette.richBlack)
                    
                    Spacer()
                    
                    // 所要時間バッジ
                    Text(suggestion.estimatedTime)
                        .typography(.caption)
                        .foregroundColor(ColorPalette.gray500)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(ColorPalette.gray100)
                        )
                }
                
                Text(suggestion.description)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.leading)
            }
            
            // 実行ボタン
            Button("試す") {
                // TODO: アクション実行ロジック
                print("Try action: \(suggestion.title)")
            }
            .typography(.caption)
            .foregroundColor(ColorPalette.pureWhite)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(difficultyColor)
            .cornerRadius(CornerRadius.sm)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pureWhite)
                .shadow(color: ColorPalette.richBlack.opacity(0.08), radius: 2, x: 0, y: 1)
        )
    }
    
    private var actionTypeIcon: String {
        switch suggestion.actionType {
        case .rest: return "bed.double"
        case .hydrate: return "drop"
        case .exercise: return "figure.walk"
        case .focus: return "brain.head.profile"
        case .social: return "person.2"
        case .beauty: return "sparkles"
        }
    }
    
    private var difficultyColor: Color {
        switch suggestion.difficulty {
        case .easy: return ColorPalette.success
        case .medium: return ColorPalette.warning
        case .hard: return ColorPalette.error
        }
    }
}

/**
 * 詳細分析表示（折りたたみ可能）
 */
struct AIDetailAnalysisView: View {
    let detailText: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text("詳細分析")
                        .typography(.subhead)
                        .foregroundColor(ColorPalette.richBlack)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(ColorPalette.gray500)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(detailText)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.gray50)
        )
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

/**
 * AI分析ローディング表示
 * UXの「Labor Illusion」原則を実装
 */
struct AILoadingView: View {
    @State private var animationPhase: Int = 0
    
    private let loadingMessages = [
        "ヘルスケアデータを分析中...",
        "環境要因を考慮中...",
        "パーソナライズ提案を生成中...",
        "最適なアドバイスを準備中..."
    ]
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.primaryAccent))
                    .scaleEffect(0.8)
                
                Text(loadingMessages[animationPhase])
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray600)
                
                Spacer()
            }
            
            // プログレスバー
            ProgressView(value: Double(animationPhase + 1), total: Double(loadingMessages.count))
                .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.primaryAccent))
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pureWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(ColorPalette.primaryAccent.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                animationPhase = (animationPhase + 1) % loadingMessages.count
            }
            
            // 10秒後にタイマー停止（タイムアウト対策）
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                timer.invalidate()
            }
        }
    }
}