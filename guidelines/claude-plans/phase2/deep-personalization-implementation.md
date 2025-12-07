# Phase 2: ディープパーソナライゼーション実装計画

## 🎯 Goal: Focus Tags + AI-Enhanced Multi-Context Analysis

**Philosophy**: 心理学的ペルソナを持つFocus Tags + AI駆動の"Happy Insight"生成による革新的パーソナライゼーション実現

## 🧠 AI Integration Foundation

Phase 2 builds directly on **Phase 1.5's AI Analysis Architecture**, extending the empathetic AI partner with sophisticated multi-tag personalization and psychological insight generation.

## 📚 必読リファレンス

### 開発標準

- [CLAUDE.md](../../../CLAUDE.md) - 開発哲学、プロセス、品質基準
- [Swift Coding Standards](../../../.claude/swift-coding-standards.md) - Swift 実装ルール
- [UX Concepts](../../../.claude/ux_concepts.md) - **🔥 Progressive Disclosure, Mere Exposure Effect**
- [Messaging Guidelines](../../../.claude/messaging_guidelines.md) - パーソナライズドアドバイス表現

### 仕様書

- [Product Spec](../../tempo-ai-product-spec.md) - Focus Tags 仕様 + AI Partner Model
- [Technical Spec](../../tempo-ai-technical-spec.md) - マルチコンテキストロジック
- [Phase 1.5 Implementation](../phase1.5/ai-analysis-implementation.md) - **AI Analysis Foundation**
- [Phase 2 Dev Plan](../../development-plans/phase-2.md) - フェーズ 2 要件 + Enhanced AI Integration

## 🗂️ 実装ステージ

### Stage 2.1: Enhanced Focus Tags with Psychological Profiles (3 日)

#### 2.1.1 AI-Aware Tag 定義とデータモデル

**ファイル**: `Models/FocusTag.swift`

**AI Integration**: 各タグに心理学的ペルソナとAI分析レンズを統合

**UX コンセプト適用**:

- **Progressive Disclosure**: 段階的な設定開示で認知負荷軽減
- **Hick's Law**: 4 つのタグに制限して決断時間短縮
- **Peak-End Rule**: タグ選択完了時に達成感を演出

```swift
enum FocusTag: String, Codable, CaseIterable {
    case work = "work"        // 🧠 Deep Focus (Work)
    case beauty = "beauty"    // ✨ Beauty & Skin
    case diet = "diet"        // 🥗 Diet & Metabolism
    case chill = "chill"      // 🍃 Chill / Relax

    var emoji: String {
        switch self {
        case .work: return "🧠"
        case .beauty: return "✨"
        case .diet: return "🥗"
        case .chill: return "🍃"
        }
    }

    var displayName: String {
        switch self {
        case .work: return NSLocalizedString("focusTag.work", comment: "")
        case .beauty: return NSLocalizedString("focusTag.beauty", comment: "")
        case .diet: return NSLocalizedString("focusTag.diet", comment: "")
        case .chill: return NSLocalizedString("focusTag.chill", comment: "")
        }
    }

    var description: String {
        switch self {
        case .work: return NSLocalizedString("focusTag.work.description", comment: "")
        case .beauty: return NSLocalizedString("focusTag.beauty.description", comment: "")
        case .diet: return NSLocalizedString("focusTag.diet.description", comment: "")
        case .chill: return NSLocalizedString("focusTag.chill.description", comment: "")
        }
    }

    // AI分析用のペルソナ定義 (Phase 1.5統合)
    var aiPersona: AIPersonaProfile {
        switch self {
        case .work:
            return AIPersonaProfile(
                persona: "Elite Executive Assistant",
                batteryInterpretation: "Remaining focus hours before cognitive decline",
                primaryWarnings: ["Brain fog risk", "Attention fragmentation", "Decision fatigue"],
                successMetrics: ["Sustained attention", "Mental clarity", "Cognitive reserves"],
                messagingTone: "Professional, predictive, strategic",
                analysisLogic: "Analyze `sleepRem` and `pressureTrend`. If REM < 60min OR pressure drops > 5hPa: warn about brain fog risk."
            )
        case .beauty:
            return AIPersonaProfile(
                persona: "Expert Aesthetician & Wellness Coach",
                batteryInterpretation: "Skin vitality and cellular repair capacity", 
                primaryWarnings: ["Skin barrier compromise", "Hydration deficit", "Stress aging"],
                successMetrics: ["Glowing skin", "Cellular renewal", "Stress-free radiance"],
                messagingTone: "Nurturing, sophisticated, science-backed",
                analysisLogic: "Analyze `sleepDeep` and `humidity`. If deep sleep < 40min OR humidity < 40%: warn about skin barrier disruption."
            )
        case .diet:
            return AIPersonaProfile(
                persona: "Metabolic Health Strategist",
                batteryInterpretation: "Nutritional energy efficiency and metabolic state",
                primaryWarnings: ["Blood sugar instability", "Metabolic slowdown", "Energy crash risk"],
                successMetrics: ["Stable energy", "Optimal timing", "Metabolic flexibility"],
                messagingTone: "Scientific, practical, empowering",
                analysisLogic: "Focus on energy expenditure vs intake balance. Suggest meal timing based on activity patterns and circadian rhythms."
            )
        case .chill:
            return AIPersonaProfile(
                persona: "Mindfulness & Nervous System Expert",
                batteryInterpretation: "Autonomic balance and stress resilience",
                primaryWarnings: ["Sympathetic overdrive", "Burnout trajectory", "Nervous system fatigue"],
                successMetrics: ["Calm alertness", "Stress resilience", "Inner peace"],
                messagingTone: "Gentle, wise, deeply understanding",
                analysisLogic: "Monitor sympathetic nervous system activation. Suggest specific relaxation techniques based on stress patterns."
            )
        }
    }
    
    var analysisLens: AnalysisLens {
        switch self {
        case .work:
            return AnalysisLens(
                dataPriority: ["sleepRem", "pressureTrend", "hrvStatus"],
                focusAreas: ["脳のパフォーマンス", "集中力ウィンドウ", "認知負荷"],
                keyMetrics: ["REM睡眠", "気圧変動", "HRV", "ストレスレベル"],
                environmentFactors: ["気圧", "騒音レベル"]
            )
        case .beauty:
            return AnalysisLens(
                dataPriority: ["sleepDeep", "humidity", "uvIndex"],
                focusAreas: ["肌の水分量", "成長ホルモン分泌", "UV暴露"],
                keyMetrics: ["深い睡眠", "湿度レベル", "水分摂取", "UV指数"],
                environmentFactors: ["湿度", "UV指数", "気温"]
            )
        case .diet:
            return AnalysisLens(
                dataPriority: ["activeCalories", "mealTiming", "hrvStatus"],
                focusAreas: ["代謝タイミング", "消化効率", "血糖値安定"],
                keyMetrics: ["活動カロリー", "食事タイミング", "心拍数変動"],
                environmentFactors: ["気温", "湿度"]
            )
        case .chill:
            return AnalysisLens(
                dataPriority: ["hrvStatus", "stressSpikes", "recoveryMetrics"],
                focusAreas: ["自律神経バランス", "回復促進", "メンタルリセット"],
                keyMetrics: ["HRV", "ストレス回復", "深い睡眠"],
                environmentFactors: ["気圧", "湿度", "気温"]
            )
        }
    }
}

// AI Persona Profile (Phase 1.5統合)
struct AIPersonaProfile: Codable {
    let persona: String                    // AI personality role
    let batteryInterpretation: String      // How to interpret battery in this context
    let primaryWarnings: [String]          // Key risk factors to monitor
    let successMetrics: [String]           // What "winning" looks like for this tag
    let messagingTone: String              // Communication style
    let analysisLogic: String              // Specific analysis instructions for AI
}

struct AnalysisLens {
    let dataPriority: [String]             // Which data points to prioritize
    let focusAreas: [String]
    let keyMetrics: [String]
    let environmentFactors: [String]
}

// Focus Tags管理
@MainActor
class FocusTagManager: ObservableObject {
    @Published var activeTags: Set<FocusTag> = []
    @Published var hasCompletedOnboarding = false

    private let userDefaults = UserDefaults.standard
    private let tagsKey = "active_focus_tags"
    private let onboardingKey = "focus_tags_onboarding_completed"

    init() {
        loadActiveTags()
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
    }

    func toggleTag(_ tag: FocusTag) {
        if activeTags.contains(tag) {
            activeTags.remove(tag)
        } else {
            activeTags.insert(tag)
        }
        saveActiveTags()

        // UX: Mere Exposure Effect - 露出機会を増やす
        logTagInteraction(tag)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
        saveActiveTags()
    }

    private func saveActiveTags() {
        let tagStrings = activeTags.map { $0.rawValue }
        userDefaults.set(tagStrings, forKey: tagsKey)
    }

    private func loadActiveTags() {
        if let tagStrings = userDefaults.array(forKey: tagsKey) as? [String] {
            activeTags = Set(tagStrings.compactMap { FocusTag(rawValue: $0) })
        }
    }

    private func logTagInteraction(_ tag: FocusTag) {
        // アナリティクス: タグ使用パターンの追跡
    }
}
```

#### 2.1.2 AI-Enhanced Multi-Select Logic - "Synthesis" Engine

**ファイル**: `Services/TagSynthesisEngine.swift`

**AI Integration**: Phase 1.5のHybridAnalysisEngineと統合し、AI駆動の多重コンテキスト分析を実現

**UX コンセプト適用**:

- **Tesler's Law**: 複雑性をシステム側で処理し、ユーザー体験をシンプルに
- **Peak-End Rule**: 競合解決時もポジティブな体験に
- **Self-Determination Theory**: ユーザーの自律性を尊重した統合的アドバイス

```swift
// AI統合型コンテキスト合成 (Phase 1.5拡張)
struct TagSynthesis {
    let primaryPersona: AIPersonaProfile  // 主導的AIペルソナ
    let secondaryPersonas: [AIPersonaProfile] // 補助的AIペルソナ
    let unifiedPersona: UnifiedPersona?   // 多重タグ時の統合ペルソナ
    let conflictResolution: ConflictResolution?
    let safetyOverride: Bool             // 生物学的安全性による上書き
    let synthesisPriority: SynthesisPriority
}

// 統合ペルソナ（複数タグ選択時）
struct UnifiedPersona: Codable {
    let unifiedIdentity: String          // "High-Performance Wellness Expert"等
    let synthesisMessage: String         // タグ間の相乗効果説明
    let conflictResolutionStrategy: String // 競合時の解決方針
}

enum SynthesisPriority {
    case biologicalSafety               // バッテリー残量 < 20%
    case balancedSynthesis             // バランス重視
    case userGoalOptimization          // ユーザー目標優先
}

enum ConflictResolution {
    case workVsChill(priority: ConflictPriority)
    case beautyVsDiet(priority: ConflictPriority)
    case workVsDiet(priority: ConflictPriority)

    enum ConflictPriority {
        case biological   // バッテリー残量が低い時は生物学的安全性優先
        case balanced     // バランス取る
        case userGoal     // ユーザーの目標優先
    }
}

@MainActor 
class TagSynthesisEngine: ObservableObject {
    @Published var currentSynthesis: TagSynthesis?

    private let tagManager: FocusTagManager
    private let hybridAnalysisEngine: HybridAnalysisEngine // Phase 1.5統合
    private let batteryEngine: BatteryEngine

    init(tagManager: FocusTagManager, hybridAnalysisEngine: HybridAnalysisEngine, batteryEngine: BatteryEngine) {
        self.tagManager = tagManager
        self.hybridAnalysisEngine = hybridAnalysisEngine
        self.batteryEngine = batteryEngine
    }

    func createTagSynthesis(
        activeTags: Set<FocusTag>,
        batteryState: BatteryState,
        userMode: UserMode
    ) async -> TagSynthesis {

        // 生物学的安全性チェック
        let safetyOverride = batteryState == .critical || batteryState == .low

        if safetyOverride {
            return createSafetyPrioritySynthesis(activeTags: activeTags)
        }

        // AI駆動の統合的コンテキスト合成
        return await createAIEnhancedSynthesis(activeTags: activeTags, userMode: userMode)
    }

    private func createSafetyPriorityMix(activeTags: Set<FocusTag>) -> ContextMix {
        // 低バッテリー時は回復優先
        let safetyLens = AnalysisLens(
            focusAreas: ["回復促進", "エネルギー温存", "ストレス軽減"],
            keyMetrics: ["HRV", "睡眠質", "活動強度"],
            environmentFactors: ["気温", "気圧"]
        )

        return ContextMix(
            primaryLens: safetyLens,
            secondaryLenses: activeTags.map { $0.analysisLens },
            conflictResolution: nil,
            safetyOverride: true
        )
    }

    private func createBalancedMix(activeTags: Set<FocusTag>, userMode: UserMode) -> ContextMix {
        guard !activeTags.isEmpty else {
            return createDefaultMix(for: userMode)
        }

        // 競合パターン検出
        let conflictResolution = detectConflicts(in: activeTags)

        // 主レンズ決定（ユーザーモードと組み合わせ）
        let primaryTag = determinePrimaryTag(from: activeTags, userMode: userMode)
        let secondaryTags = activeTags.subtracting([primaryTag])

        return ContextMix(
            primaryLens: primaryTag.analysisLens,
            secondaryLenses: secondaryTags.map { $0.analysisLens },
            conflictResolution: conflictResolution,
            safetyOverride: false
        )
    }

    private func detectConflicts(in tags: Set<FocusTag>) -> ConflictResolution? {
        if tags.contains(.work) && tags.contains(.chill) {
            return .workVsChill(priority: .balanced)
        }

        if tags.contains(.beauty) && tags.contains(.diet) {
            return .beautyVsDiet(priority: .balanced)
        }

        if tags.contains(.work) && tags.contains(.diet) {
            return .workVsDiet(priority: .balanced)
        }

        return nil
    }

    private func determinePrimaryTag(from tags: Set<FocusTag>, userMode: UserMode) -> FocusTag {
        // Athleteモードの場合は特定の優先順位
        if userMode == .athlete {
            if tags.contains(.diet) { return .diet }
            if tags.contains(.chill) { return .chill }
        }

        // 一般的な優先順位: Work > Beauty > Diet > Chill
        let priorityOrder: [FocusTag] = [.work, .beauty, .diet, .chill]

        for tag in priorityOrder {
            if tags.contains(tag) {
                return tag
            }
        }

        return tags.first! // フォールバック
    }

    private func createDefaultMix(for userMode: UserMode) -> ContextMix {
        let defaultLens = AnalysisLens(
            focusAreas: ["全般的な健康", "エネルギー管理"],
            keyMetrics: ["バッテリーレベル", "総合的な活動"],
            environmentFactors: ["気象条件"]
        )

        return ContextMix(
            primaryLens: defaultLens,
            secondaryLenses: [],
            conflictResolution: nil,
            safetyOverride: false
        )
    }
}
```

#### 2.1.3 Focus Tags 設定 UI

**ファイル**: `Views/Settings/FocusTagsSettingsView.swift`

**UX コンセプト適用**:

- **Progressive Disclosure**: 詳細説明は要求時のみ表示
- **Familiarity Bias**: 一般的なトグルスイッチパターン採用

```swift
struct FocusTagsSettingsView: View {
    @ObservedObject var tagManager: FocusTagManager
    @State private var showingTagDetail: FocusTag?

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("settings.focusTags.description")
                        .bodyStyle()
                        .foregroundColor(ColorPalette.gray700)
                } header: {
                    Text("settings.focusTags.title")
                }

                Section {
                    ForEach(FocusTag.allCases, id: \.self) { tag in
                        FocusTagRow(
                            tag: tag,
                            isSelected: tagManager.activeTags.contains(tag),
                            onToggle: { tagManager.toggleTag(tag) },
                            onShowDetail: { showingTagDetail = tag }
                        )
                    }
                } header: {
                    Text("設定中のタグ")
                } footer: {
                    if !tagManager.activeTags.isEmpty {
                        Text("選択されたタグ: \(tagManager.activeTags.count)/4")
                            .captionStyle()
                    }
                }
            }
            .navigationTitle("Focus Tags")
            .sheet(item: $showingTagDetail) { tag in
                FocusTagDetailView(tag: tag)
            }
        }
    }
}

struct FocusTagRow: View {
    let tag: FocusTag
    let isSelected: Bool
    let onToggle: () -> Void
    let onShowDetail: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(tag.emoji)
                        .font(.title2)

                    Text(tag.displayName)
                        .headlineStyle()

                    Spacer()
                }

                Text(tag.description)
                    .captionStyle()
                    .foregroundColor(ColorPalette.gray500)
            }

            Spacer()

            Button(action: onShowDetail) {
                Image(systemName: "info.circle")
                    .foregroundColor(ColorPalette.gray400)
            }

            Toggle("", isOn: .init(
                get: { isSelected },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}
```

### Stage 2.2: AI Persona Synthesis Integration (3 日)

#### 2.2.1 Enhanced Prompt Builder with Multi-Persona Support

**ファイル**: `Services/EnhancedPromptBuilder.swift`

**AI Integration**: Phase 1.5のPromptBuilderを拡張し、複数タグペルソナの統合とコンテキスト合成を実現

```swift
// Enhanced Contextual Prompt (Phase 1.5拡張)
struct EnhancedContextualPrompt {
    let systemPersona: String               // Base AI personality from Phase 1.5  
    let primaryTagPersona: String          // Primary tag persona instructions
    let secondaryTagPersonas: [String]     // Secondary tag persona instructions
    let unifiedPersonaInstructions: String? // Multi-tag synthesis instructions
    let conflictResolutionStrategy: String?
    let environmentContext: String
    let safetyConstraints: String?
    let happyInsightFramework: String      // Phase 1.5 "Happy Advice" integration
}

@MainActor
class EnhancedPromptBuilder: ObservableObject {

    func buildEnhancedPrompt(
        userMode: UserMode,
        tagSynthesis: TagSynthesis,
        healthData: HealthData,
        weatherData: WeatherData?,
        batteryLevel: Double
    ) -> EnhancedContextualPrompt {

        let systemPersona = buildSystemPersona(for: userMode) // Phase 1.5統合
        let primaryTagPersona = buildPrimaryTagPersona(tagSynthesis.primaryPersona)
        let secondaryTagPersonas = tagSynthesis.secondaryPersonas.map { buildSecondaryTagPersona($0) }
        let unifiedPersonaInstructions = buildUnifiedPersonaInstructions(tagSynthesis.unifiedPersona)
        let conflictResolutionStrategy = buildConflictResolutionStrategy(tagSynthesis.conflictResolution)
        let environmentContext = buildEnvironmentContext(from: weatherData)
        let safetyConstraints = buildSafetyConstraints(
            batteryLevel: batteryLevel,
            overrideActive: tagSynthesis.safetyOverride
        )
        let happyInsightFramework = buildHappyInsightFramework() // Phase 1.5統合

        return EnhancedContextualPrompt(
            systemPersona: systemPersona,
            primaryTagPersona: primaryTagPersona,
            secondaryTagPersonas: secondaryTagPersonas,
            unifiedPersonaInstructions: unifiedPersonaInstructions,
            conflictResolutionStrategy: conflictResolutionStrategy,
            environmentContext: environmentContext,
            safetyConstraints: safetyConstraints,
            happyInsightFramework: happyInsightFramework
        )
    }

    // Phase 1.5統合: システムペルソナ
    private func buildSystemPersona(for mode: UserMode) -> String {
        let basePersona = """
        You are Tempo, a sophisticated health partner with deep empathy and scientific knowledge.
        Your primary goal is to make the user feel **understood**, **validated**, and **empowered**.

        Core Principles:
        1. NEVER scold or criticize the user for "bad" data
        2. Always offer a "recovery strategy" instead of dwelling on problems  
        3. Start responses with THE CONCLUSION first (The Headline)
        4. Connect invisible environmental forces to how the user feels
        5. Provide permission to rest OR encouragement to push - never guilt

        You are not a doctor. You are a wise friend who sees patterns the user cannot see.
        """
        
        let modeSpecificPersona: String
        switch mode {
        case .standard:
            modeSpecificPersona = """
            Mode: Gentle Life Optimizer
            Focus on sustainable daily improvements and stress reduction.
            Prioritize mental wellness and energy conservation.
            """
        case .athlete:
            modeSpecificPersona = """
            Mode: Elite Performance Partner  
            Focus on training optimization and strategic recovery.
            Balance peak performance ambition with injury prevention.
            """
        }
        
        return basePersona + "\n\n" + modeSpecificPersona
    }
    
    // 主要タグペルソナ構築
    private func buildPrimaryTagPersona(_ persona: AIPersonaProfile) -> String {
        return """
        PRIMARY LENS: \(persona.persona)
        Battery Interpretation: \(persona.batteryInterpretation)
        Key Warnings: \(persona.primaryWarnings.joined(separator: ", "))
        Success Definition: \(persona.successMetrics.joined(separator: ", "))
        Messaging Tone: \(persona.messagingTone)
        Analysis Priority: \(persona.analysisLogic)
        """
    }
    
    // Phase 1.5統合: Happy Insight Framework
    private func buildHappyInsightFramework() -> String {
        return """
        HAPPY INSIGHT FRAMEWORK:
        
        1. Permission-Granting Approach:
           - High Battery: "Permission granted to pursue ambitious goals"
           - Low Battery: "Permission granted to prioritize rest without guilt"
           
        2. Contextual Connections:
           - Link environmental factors to user feelings
           - Example: "That headache isn't your fault - pressure dropped 6hPa"
           
        3. Micro-Actions Only:
           - Suggest actions completable in <5 minutes
           - Examples: "3 deep breaths", "one glass of water", "2-minute walk"
        """
    }

    private func buildTagLenses(from contextMix: ContextMix) -> [String] {
        var lenses: [String] = []

        // 主レンズ
        lenses.append(formatLens(contextMix.primaryLens, isPrimary: true))

        // 副レンズ
        for secondaryLens in contextMix.secondaryLenses {
            lenses.append(formatLens(secondaryLens, isPrimary: false))
        }

        return lenses
    }

    private func formatLens(_ lens: AnalysisLens, isPrimary: Bool) -> String {
        let priority = isPrimary ? "【最重要】" : "【補助的観点】"

        return """
        \(priority)
        分析重点: \(lens.focusAreas.joined(separator: "、"))
        注目指標: \(lens.keyMetrics.joined(separator: "、"))
        環境要因: \(lens.environmentFactors.joined(separator: "、"))
        """
    }

    private func buildConflictResolution(from contextMix: ContextMix) -> String? {
        guard let conflict = contextMix.conflictResolution else { return nil }

        switch conflict {
        case .workVsChill(let priority):
            switch priority {
            case .biological:
                return "仕事効率と休息が競合する場合、現在のバッテリー残量を考慮し、回復を優先してください。"
            case .balanced:
                return "仕事効率と休息のバランスを取り、短期的なパフォーマンスと長期的な持続可能性を両立してください。"
            case .userGoal:
                return "ユーザーの主要目標を尊重しつつ、適度な回復時間も確保するよう助言してください。"
            }
        case .beautyVsDiet(let priority):
            return "美容と代謝の観点から総合的にアドバイスし、相乗効果を狙ってください。"
        case .workVsDiet(let priority):
            return "集中力維持に必要な栄養タイミングと代謝最適化を両立してください。"
        }
    }

    private func buildEnvironmentContext(from weather: WeatherData?) -> String {
        guard let weather = weather else {
            return "気象データが利用できません。一般的な屋内環境を想定してください。"
        }

        var context = "【環境コンテキスト】\n"
        context += "気温: \(Int(weather.temperature))℃\n"
        context += "湿度: \(Int(weather.humidity))%\n"
        context += "気圧: \(weather.surfacePressure) hPa"

        if weather.pressureChange < -3.0 {
            context += "\n⚠️ 気圧が急低下中（頭痛リスク増加）"
        }

        if weather.temperature > 30 && weather.humidity > 70 {
            context += "\n⚠️ 高温多湿状態（熱中症リスク増加）"
        }

        return context
    }

    private func buildSafetyConstraints(batteryLevel: Double, overrideActive: Bool) -> String? {
        if overrideActive {
            return """
            【生物学的安全性最優先】
            現在のバッテリーレベルが低いため（\(Int(batteryLevel))%）、
            いかなる目標よりも回復と休息を最優先してください。
            積極的な活動や努力は明日以降に先延ばしし、
            今日は最低限の活動に留めることを強く推奨してください。
            """
        }

        if batteryLevel < 30 {
            return """
            【注意喚起】
            バッテリーレベルが低下中（\(Int(batteryLevel))%）。
            アドバイスの際は適度な休息時間の確保も併せて提案してください。
            """
        }

        return nil
    }
}
```

### Stage 2.3: UI 個別化 (3 日)

#### 2.3.1 Smart Suggestions 実装

**ファイル**: `Views/Home/SmartSuggestionsView.swift`

**UX コンセプト適用**:

- **Von Restorff Effect**: 重要な提案を視覚的に際立たせる
- **Contextual Recommendations**: 状況に応じた適切な提案

```swift
struct SmartSuggestion {
    let id = UUID()
    let tag: FocusTag
    let title: String
    let message: String
    let actionTitle: String?
    let priority: Priority
    let triggerCondition: String

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

struct SmartSuggestionsView: View {
    let suggestions: [SmartSuggestion]
    let onSuggestionTap: (SmartSuggestion) -> Void

    var body: some View {
        if !suggestions.isEmpty {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(suggestions, id: \.id) { suggestion in
                    SmartSuggestionCard(
                        suggestion: suggestion,
                        onTap: { onSuggestionTap(suggestion) }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

struct SmartSuggestionCard: View {
    let suggestion: SmartSuggestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(suggestion.tag.emoji)
                            .font(.title3)

                        Text(suggestion.title)
                            .subheadStyle()
                            .foregroundColor(suggestion.priority.color)

                        Spacer()

                        if suggestion.actionTitle != nil {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(ColorPalette.gray400)
                        }
                    }

                    Text(suggestion.message)
                        .captionStyle()
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
        .buttonStyle(ScaleButtonStyle())
    }
}

// Smart Suggestions生成ロジック
@MainActor
class SmartSuggestionsEngine: ObservableObject {
    @Published var currentSuggestions: [SmartSuggestion] = []

    func generateSuggestions(
        activeTags: Set<FocusTag>,
        healthData: HealthData,
        weatherData: WeatherData?,
        batteryLevel: Double
    ) -> [SmartSuggestion] {

        var suggestions: [SmartSuggestion] = []

        // Tag別の条件チェック
        for tag in activeTags {
            suggestions.append(contentsOf: checkTagConditions(
                tag: tag,
                healthData: healthData,
                weatherData: weatherData,
                batteryLevel: batteryLevel
            ))
        }

        // 優先度順にソート
        suggestions.sort { $0.priority.sortOrder < $1.priority.sortOrder }

        // 最大3つまで
        return Array(suggestions.prefix(3))
    }

    private func checkTagConditions(
        tag: FocusTag,
        healthData: HealthData,
        weatherData: WeatherData?,
        batteryLevel: Double
    ) -> [SmartSuggestion] {

        switch tag {
        case .work:
            return checkWorkConditions(healthData: healthData, weatherData: weatherData)
        case .beauty:
            return checkBeautyConditions(healthData: healthData, weatherData: weatherData)
        case .diet:
            return checkDietConditions(healthData: healthData, batteryLevel: batteryLevel)
        case .chill:
            return checkChillConditions(healthData: healthData, batteryLevel: batteryLevel)
        }
    }

    private func checkWorkConditions(
        healthData: HealthData,
        weatherData: WeatherData?
    ) -> [SmartSuggestion] {

        var suggestions: [SmartSuggestion] = []

        // 低気圧 × 集中作業
        if let weather = weatherData,
           weather.pressureChange < -3.0 {
            suggestions.append(SmartSuggestion(
                tag: .work,
                title: "低気圧注意報",
                message: "気圧低下で頭痛リスク増加。重要なタスクは今のうちに。",
                actionTitle: "詳細を見る",
                priority: .high,
                triggerCondition: "pressure_drop"
            ))
        }

        // 高ストレス × 集中必要
        if healthData.stressLevel > 70 {
            suggestions.append(SmartSuggestion(
                tag: .work,
                title: "集中力ブースト",
                message: "ストレスが高めです。5分間の深呼吸で集中力リセット。",
                actionTitle: "呼吸法ガイド",
                priority: .medium,
                triggerCondition: "high_stress"
            ))
        }

        return suggestions
    }

    private func checkBeautyConditions(
        healthData: HealthData,
        weatherData: WeatherData?
    ) -> [SmartSuggestion] {

        var suggestions: [SmartSuggestion] = []

        // 低湿度 × 美容
        if let weather = weatherData,
           weather.humidity < 40 {
            suggestions.append(SmartSuggestion(
                tag: .beauty,
                title: "乾燥警報",
                message: "湿度\(Int(weather.humidity))%。保湿ケアを強化してください。",
                actionTitle: nil,
                priority: .medium,
                triggerCondition: "low_humidity"
            ))
        }

        return suggestions
    }

    private func checkChillConditions(
        healthData: HealthData,
        batteryLevel: Double
    ) -> [SmartSuggestion] {

        var suggestions: [SmartSuggestion] = []

        // 高ストレス × リラックス
        if healthData.stressLevel > 75 {
            suggestions.append(SmartSuggestion(
                tag: .chill,
                title: "サウナ・チャンス",
                message: "交感神経が高ぶっています。温浴で自律神経をリセット。",
                actionTitle: "入浴法を見る",
                priority: .high,
                triggerCondition: "high_stress_chill"
            ))
        }

        return suggestions
    }
}
```

#### 2.3.2 Detail View 分岐

**ファイル**: `Views/Detail/TagAwareDetailView.swift`

```swift
struct TagAwareDetailView: View {
    let healthData: HealthData
    let activeTags: Set<FocusTag>

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                // 基本情報は常に表示
                BasicMetricsSection(healthData: healthData)

                // Tag別セクション
                TagSpecificSections(
                    healthData: healthData,
                    activeTags: activeTags
                )
            }
            .padding(Spacing.md)
        }
        .navigationTitle("詳細分析")
    }
}

struct TagSpecificSections: View {
    let healthData: HealthData
    let activeTags: Set<FocusTag>

    var body: some View {
        ForEach(Array(activeTags), id: \.self) { tag in
            Group {
                switch tag {
                case .work:
                    WorkDetailSection(healthData: healthData)
                case .beauty:
                    BeautyDetailSection(healthData: healthData)
                case .diet:
                    DietDetailSection(healthData: healthData)
                case .chill:
                    ChillDetailSection(healthData: healthData)
                }
            }
        }
    }
}

struct BeautyDetailSection: View {
    let healthData: HealthData

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("✨")
                    .font(.title2)
                Text("美容・肌コンディション")
                    .headlineStyle()
                Spacer()
            }

            // 肌のゴールデンタイム（深い睡眠）
            SkinRepairTimeCard(
                deepSleepDuration: healthData.sleepData.deepSleepDuration,
                skinRepairEfficiency: calculateSkinRepairEfficiency(healthData)
            )

            // 水分バランス
            HydrationStatusCard(
                currentHydration: healthData.hydrationLevel,
                environmentalLoss: calculateEnvironmentalLoss(healthData)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(ColorPalette.pearl)
        )
    }

    private func calculateSkinRepairEfficiency(_ data: HealthData) -> Double {
        // 深い睡眠時間と成長ホルモン分泌効率から算出
        let deepSleepRatio = data.sleepData.deepSleepDuration / data.sleepData.totalDuration
        return min(100, deepSleepRatio * 120) // 最大100%
    }
}
```

## 📊 テスト戦略

### 単体テスト - コンテキストミキサー

```swift
@testable import TempoAI
import XCTest

class ContextMixerEngineTests: XCTestCase {
    var mixerEngine: ContextMixerEngine!

    func testWorkChillConflictResolution() {
        // Given
        let tags: Set<FocusTag> = [.work, .chill]
        let batteryState: BatteryState = .medium

        // When
        let mix = mixerEngine.createContextMix(
            activeTags: tags,
            batteryState: batteryState,
            userMode: .standard
        )

        // Then
        XCTAssertNotNil(mix.conflictResolution)
        XCTAssertEqual(mix.primaryLens.focusAreas.count, 3)
        XCTAssertFalse(mix.safetyOverride)
    }

    func testSafetyOverrideOnLowBattery() {
        // Given
        let tags: Set<FocusTag> = [.work]
        let batteryState: BatteryState = .critical

        // When
        let mix = mixerEngine.createContextMix(
            activeTags: tags,
            batteryState: batteryState,
            userMode: .standard
        )

        // Then
        XCTAssertTrue(mix.safetyOverride)
        XCTAssertTrue(mix.primaryLens.focusAreas.contains("回復促進"))
    }
}
```

## 📊 成功基準

### 機能完成度

- [ ] 4 つの Focus Tags 設定・切り替えが正常動作
- [ ] 複数タグ選択時の適切な競合解決
- [ ] Tag 別の Smart Suggestions 生成
- [ ] Detail View 分岐表示

### UX 品質基準

- [ ] Progressive Disclosure 実装（詳細は要求時のみ）
- [ ] Tag 切り替え時の即座フィードバック
- [ ] 最大 3 つの Smart Suggestions で認知負荷軽減
- [ ] 競合解決時のポジティブメッセージング

### パフォーマンス

- [ ] Tag 切り替え応答 200ms 以内
- [ ] Suggestions 生成 500ms 以内
- [ ] Detail View 表示遅延最小化

### 品質保証

- [ ] 全 Tag 組み合わせでのテストカバレッジ
- [ ] エッジケース（タグなし、全タグ選択）対応
- [ ] ./scripts/quality-check.sh 通過

---

**完了条件**: 全ステージ完成 + マルチコンテキスト分析動作  
**Next Phase**: Phase 3 最適化・クリーンアップ
