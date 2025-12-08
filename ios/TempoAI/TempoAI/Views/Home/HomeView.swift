import SwiftUI

struct HomeView: View {
    @StateObject private var batteryEngine: BatteryEngine
    @StateObject private var hybridAnalysisEngine: HybridAnalysisEngine
    @ObservedObject private var userProfileManager = UserProfileManager.shared
    @ObservedObject private var focusTagManager = FocusTagManager.shared

    @State private var currentAdvice: AdviceHeadline = AdviceHeadline.mock()
    @State private var healthData: HealthData = HealthData.mock()
    @State private var isRefreshing: Bool = false

    init() {
        let healthService = HealthService()
        let weatherService = WeatherService()
        let batteryEngine = BatteryEngine(
            healthService: healthService,
            weatherService: weatherService
        )

        _batteryEngine = StateObject(wrappedValue: batteryEngine)

        // HybridAnalysisEngine初期化 - 標準的なNetworkManagerを使用
        let aiService = StandardAIAnalysisService()
        let cacheManager = AnalysisCacheManager()

        _hybridAnalysisEngine = StateObject(
            wrappedValue: HybridAnalysisEngine(
                batteryEngine: batteryEngine,
                weatherService: weatherService,
                aiAnalysisService: aiService,
                cacheManager: cacheManager
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.xl) {
                    VStack(spacing: Spacing.lg) {
                        // AI分析結果の状態に応じた表示
                        if let analysisResult = hybridAnalysisEngine.currentAnalysis {
                            switch analysisResult.source {
                            case .hybrid, .cached:
                                // 真のAI分析結果
                                if let aiAnalysis = analysisResult.aiAnalysis {
                                    VStack(spacing: Spacing.sm) {
                                        AIHeadlineCard(headline: aiAnalysis.headline)
                                        DataSourceBadge(source: analysisResult.source)
                                        AnalysisValidityIndicator(
                                            generatedAt: aiAnalysis.generatedAt,
                                            validUntil: Calendar.current.date(
                                                byAdding: .hour, value: 8, to: aiAnalysis.generatedAt)
                                        )
                                    }
                                } else {
                                    AdviceHeaderView(headline: currentAdvice) {
                                        showAdviceDetail()
                                    }
                                }
                            case .aiError:
                                // AI接続エラー表示
                                AIErrorView(
                                    error: hybridAnalysisEngine.analysisError,
                                    fallbackAvailable: true
                                ) {
                                    Task {
                                        await hybridAnalysisEngine.generateAnalysis()
                                    }
                                }
                            case .fallback, .staticOnly:
                                // 基本分析のみ表示
                                VStack(spacing: Spacing.sm) {
                                    AdviceHeaderView(headline: currentAdvice) {
                                        showAdviceDetail()
                                    }
                                    DataSourceBadge(source: analysisResult.source)
                                }
                            }
                        } else {
                            AdviceHeaderView(headline: currentAdvice) {
                                showAdviceDetail()
                            }
                        }

                        LiquidBatteryView(battery: batteryEngine.currentBattery)
                            .padding(.horizontal, Spacing.lg)

                        IntuitiveCardsView(
                            healthData: healthData,
                            userMode: userProfileManager.currentMode
                        )
                        .padding(.horizontal, Spacing.lg)

                        // AI提案がある場合はAI提案を表示、なければ従来の提案
                        if let aiAnalysis = hybridAnalysisEngine.currentAnalysis?.aiAnalysis,
                            !aiAnalysis.aiActionSuggestions.isEmpty
                        {
                            AITodaysTriesView(suggestions: aiAnalysis.aiActionSuggestions)
                                .padding(.horizontal, Spacing.lg)
                        } else if !focusTagManager.activeTags.isEmpty {
                            SmartSuggestionsView(
                                activeTags: focusTagManager.activeTags,
                                healthData: healthData,
                                batteryLevel: batteryEngine.currentBattery.currentLevel
                            )
                        }

                        // AI詳細分析とタグインサイト表示
                        if let aiAnalysis = hybridAnalysisEngine.currentAnalysis?.aiAnalysis,
                            !aiAnalysis.tagInsights.isEmpty
                        {
                            AITagInsightsView(insights: aiAnalysis.tagInsights)
                                .padding(.horizontal, Spacing.lg)
                        }

                        // AI分析ローディング状態
                        if hybridAnalysisEngine.isEnhancingWithAI {
                            AILoadingView()
                                .padding(.horizontal, Spacing.lg)
                        }
                    }
                    .padding(.vertical, Spacing.lg)
                }
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await refreshData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRefreshing)
                    }
                }
            }
        }
        .background(ColorPalette.pureWhite)
        .preferredColorScheme(.light)
        .task {
            await refreshData()
        }
    }

    private func refreshData() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            healthData = try await batteryEngine.getLatestHealthData()

            // 従来のアドバイス生成
            await generateAdvice()

            // 新しいハイブリッド分析実行
            await hybridAnalysisEngine.generateAnalysis()
        } catch {
            print("Failed to refresh data: \(error)")
        }
    }

    private func generateAdvice() async {
        let batteryLevel = batteryEngine.currentBattery.currentLevel

        switch batteryLevel {
        case 70 ... 100:
            currentAdvice = AdviceHeadline(
                title: "エネルギー充分",
                subtitle: "今日は積極的に活動できそうです",
                impactLevel: .low
            )
        case 40 ..< 70:
            currentAdvice = AdviceHeadline(
                title: "バランス良好",
                subtitle: "適度なペースで進めましょう",
                impactLevel: .medium
            )
        case 20 ..< 40:
            currentAdvice = AdviceHeadline(
                title: "エネルギー低下",
                subtitle: "休息を取ることをお勧めします",
                impactLevel: .medium
            )
        default:
            currentAdvice = AdviceHeadline(
                title: "要注意レベル",
                subtitle: "今日は無理をせず回復に専念してください",
                impactLevel: .high
            )
        }
    }

    private func showAdviceDetail() {
        print("Show advice detail")
    }
}

struct SmartSuggestionsView: View {
    let activeTags: Set<FocusTag>
    let healthData: HealthData
    let batteryLevel: Double

    private var suggestions: [SmartSuggestion] {
        generateSuggestions()
    }

    var body: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(suggestions, id: \.id) { suggestion in
                SmartSuggestionCard(suggestion: suggestion)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private func generateSuggestions() -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []

        if activeTags.contains(.work) && healthData.stressLevel > 70 {
            suggestions.append(
                SmartSuggestion(
                    tag: .work,
                    title: "集中力リセット",
                    message: "ストレスが高めです。5分間の深呼吸がお勧め。",
                    priority: .medium
                ))
        }

        if activeTags.contains(.chill) && healthData.stressLevel > 75 {
            suggestions.append(
                SmartSuggestion(
                    tag: .chill,
                    title: "サウナチャンス",
                    message: "交感神経が高ぶっています。温浴でリセット。",
                    priority: .high
                ))
        }

        return Array(suggestions.prefix(3))
    }
}

struct SmartSuggestion: Identifiable {
    let id: UUID = UUID()
    let tag: FocusTag
    let title: String
    let message: String
    let priority: Priority

    enum Priority {
        case high, medium, low

        var color: Color {
            switch self {
            case .high: return ColorPalette.error
            case .medium: return ColorPalette.warning
            case .low: return ColorPalette.info
            }
        }
    }
}

struct SmartSuggestionCard: View {
    let suggestion: SmartSuggestion

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(suggestion.tag.emoji)
                        .font(.title3)

                    Text(suggestion.title)
                        .typography(.subhead)
                        .foregroundColor(suggestion.priority.color)

                    Spacer()
                }

                Text(suggestion.message)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(suggestion.priority.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(suggestion.priority.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
}
