# 🚀 Phase 2: 実データ統合とコア機能実装

**実施期間**: 4-5 週間  
**対象読者**: 開発チーム  
**最終更新**: 2025 年 12 月 7 日  
**前提条件**: Phase 1 完了（UI/UX 刷新、TDD 基盤、基本オンボーディング、シミュレーター動作確認）

---

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール
5. **UX 設計原則**: [.claude/ux_concepts.md](../../.claude/ux_concepts.md) - UX 心理学原則
6. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

### 🧪 テスト駆動開発（TDD）必須要件

- **カバレッジ目標**: Backend ≥85%, iOS ≥85%
- **TDD サイクル**: Red → Green → Refactor → Integrate
- **継続的品質**: 全実装でテストファースト
- **品質ゲート**: 実装完了前に必ずテスト実行・確認

---

## 🎯 Phase 2 で実現される機能とユーザー体験

### **Phase 2 完了時のユーザー体験**

**朝 7 時、田中さん（35 歳、会社員）の iPhone に通知が届きます...**

#### 📱 **パーソナライズされた朝のインサイト**

```
🌅 おはようございます！

昨夜の睡眠：7時間12分（深い睡眠85%）
心拍変動：今週平均より12%向上 ✨

今日の天気：23°C、晴れ（UV指数4）
💡 午前中の軽いジョギングがおすすめです
```

#### 🏠 **ホーム画面での詳細表示**

- **健康スコア**: 82/100（過去 30 日平均より+5 ポイント）
- **今日の重点アドバイス**: "水分補給を意識してみませんか？1.8L 目標です"
- **環境情報**: 花粉少なめ、外での運動に最適
- **バイタルトレンド**: 安静時心拍数が週平均より 3bpm 低く、良好

#### 📊 **詳細アドバイス画面**

**タップすると表示される包括的な分析:**

**栄養バランス**:

- "昨日のタンパク質摂取は推奨値の 85%でした。昼食に魚料理を追加してみませんか？"
- "ビタミン D 不足の傾向があります。今日は日光浴を 15 分程度いかがでしょうか？"

**運動・活動**:

- "歩数 8,200 歩（目標 10,000 歩の 82%）。あと 1,800 歩です！"
- "午後 3 時頃に 10 分の散歩を取り入れると、午後の集中力向上が期待できます"

**睡眠・回復**:

- "深い睡眠の割合が理想的です。この調子で 22:30 の就寝習慣を続けてみませんか？"
- "心拍変動が改善しているので、ストレス管理がうまくいっています"

### **Phase 2 核心実装項目**

1. **🏥 実 HealthKit データ統合**: 20+種類の健康データを実時間で取得・分析
2. **🌤️ 天候・環境データ統合**: UV 指数、大気質、花粉情報との健康相関分析
3. **🤖 多言語対応 AI 分析**: 日英対応の詳細健康インサイト生成
4. **✨ 心理学ベース UX**: Progressive Disclosure、Peak-End Rule 適用の完全オンボーディング
5. **🔔 インテリジェント通知**: 適切なタイミングでの健康アドバイス配信

### **技術的な進化**

#### **データの深度**

- Phase 1: モックデータによる表示のみ
- Phase 2: 実 HealthKit + 環境データによるリアル分析

#### **AI 分析の sophistication**

- Phase 1: 静的なアドバイステンプレート
- Phase 2: Claude AI による動的・コンテキスト考慮型パーソナライゼーション

#### **ユーザーとの関係性**

- Phase 1: 情報表示アプリ
- Phase 2: 信頼できるパーソナル健康パートナー

---

## 📊 現状と目標

### Phase 1 完了時の状態

- ✅ 包括的 UI/UX デザインシステム（WCAG 2.1 AAA 準拠）
- ✅ 7 ページオンボーディングフロー（言語選択対応）
- ✅ HealthKit 認証基盤（モックデータ使用）
- ✅ TDD 基盤（80%+テストカバレッジ）
- ✅ 国際化対応（ja/en）
- ❌ 実機動作（白画面問題）

### Phase 2 終了時の目標

- 🏥 **実 HealthKit データ統合**: 心拍数、HRV、睡眠、歩数、血圧、体重等の実データ取得
- 🌤️ **天候データ統合**: OpenWeatherMap API、UV Index、大気質、花粉情報
- 🤖 **AI 分析エンジン**: Claude API 統合による詳細健康分析
- ✨ **オンボーディング 2.0**: Progressive Disclosure、Peak-End Rule 活用
- 📱 **リアルタイム通知**: 健康異常、天候変化、日次アドバイス配信
- 📊 **高度データ可視化**: トレンド分析、個人基準値比較
- 🔧 **実機動作**: デバイス固有問題完全解決

---

## 🏗️ 段階的実装計画（5 Stages）

## Stage 1: Real HealthKit Data Integration (Week 1)

**Goal**: モックデータから実 HealthKit データへの完全移行

### Success Criteria

- ✅ 全指定データ型の実データ取得（90%+ success rate）
- ✅ バックグラウンド更新対応（HKObserverQuery 実装）
- ✅ データキャッシュ機能（Core Data 統合）
- ✅ 包括的エラーハンドリング

### 実装タスク

#### 1.1 HealthKitManager Complete Rewrite

```swift
// ios/TempoAI/TempoAI/Managers/HealthKitManager.swift - 完全書き換え
class HealthKitManager: ObservableObject {

    // 対応データ型拡張
    static let comprehensiveHealthTypes: Set<HKSampleType> = [
        // Vital Signs
        HKQuantityType(.heartRate),                    // 心拍数
        HKQuantityType(.restingHeartRate),             // 安静時心拍数
        HKQuantityType(.heartRateVariabilitySDNN),     // HRV
        HKQuantityType(.oxygenSaturation),             // SpO2
        HKQuantityType(.respiratoryRate),              // 呼吸数
        HKQuantityType(.bodyTemperature),              // 体温

        // Physical Activity
        HKQuantityType(.stepCount),                    // 歩数
        HKQuantityType(.distanceWalkingRunning),       // 歩行・ランニング距離
        HKQuantityType(.activeEnergyBurned),           // 消費カロリー
        HKQuantityType(.basalEnergyBurned),            // 基礎代謝
        HKQuantityType(.appleExerciseTime),            // 運動時間

        // Body Measurements
        HKQuantityType(.bodyMass),                     // 体重
        HKQuantityType(.bodyMassIndex),                // BMI
        HKQuantityType(.bodyFatPercentage),            // 体脂肪率
        HKQuantityType(.leanBodyMass),                 // 除脂肪体重

        // Blood Pressure
        HKQuantityType(.bloodPressureSystolic),        // 収縮期血圧
        HKQuantityType(.bloodPressureDiastolic),       // 拡張期血圧

        // Sleep & Recovery
        HKCategoryType(.sleepAnalysis),                // 睡眠分析
        HKQuantityType(.heartRateRecoveryOneMinute),   // 心拍回復

        // Nutrition (if available)
        HKQuantityType(.dietaryWater),                 // 水分摂取
        HKQuantityType(.dietaryFiber),                 // 食物繊維
    ]

    // 実データ取得メソッド
    func fetchComprehensiveHealthData() async throws -> ComprehensiveHealthData {
        // 並行処理で効率的にデータ取得
        async let vitalSigns = fetchVitalSigns()
        async let activity = fetchActivityData()
        async let bodyMeasurements = fetchBodyMeasurements()
        async let sleep = fetchSleepData()

        return try await ComprehensiveHealthData(
            vitalSigns: vitalSigns,
            activity: activity,
            bodyMeasurements: bodyMeasurements,
            sleep: sleep,
            timestamp: Date()
        )
    }

    // バックグラウンド観察機能
    func startRealTimeObservation() {
        for dataType in Self.comprehensiveHealthTypes {
            let query = HKObserverQuery(sampleType: dataType, predicate: nil) { [weak self] _, _, error in
                if let error = error {
                    print("❌ Observer error for \(dataType): \(error)")
                    return
                }

                Task { @MainActor in
                    await self?.handleDataUpdate(for: dataType)
                }
            }

            healthStore.execute(query)
        }
    }
}
```

#### 1.2 Enhanced Data Models

```swift
// ios/TempoAI/TempoAI/Models/ComprehensiveHealthData.swift
struct ComprehensiveHealthData: Codable {
    let vitalSigns: VitalSignsData
    let activity: ActivityData
    let bodyMeasurements: BodyMeasurementsData
    let sleep: SleepData
    let timestamp: Date

    // 健康スコア算出
    var overallHealthScore: HealthScore {
        return HealthScoreCalculator.calculate(from: self)
    }
}

struct VitalSignsData: Codable {
    let heartRate: HeartRateMetrics?
    let heartRateVariability: HRVMetrics?
    let oxygenSaturation: Double?
    let respiratoryRate: Double?
    let bodyTemperature: Double?
}

struct BodyMeasurementsData: Codable {
    let weight: Double?
    let bmi: Double?
    let bodyFatPercentage: Double?
    let bloodPressure: BloodPressureReading?
}

struct BloodPressureReading: Codable {
    let systolic: Double
    let diastolic: Double
    let timestamp: Date

    var category: BPCategory {
        switch (systolic, diastolic) {
        case (..<120, ..<80): return .normal
        case (120..<130, ..<80): return .elevated
        case (130..<140, 80..<90): return .stage1Hypertension
        default: return .stage2Hypertension
        }
    }
}
```

#### 1.3 Core Data Integration for Caching

```swift
// ios/TempoAI/TempoAI/Data/HealthDataStore.swift
class HealthDataStore: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealthDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()

    func saveHealthData(_ data: ComprehensiveHealthData) async throws {
        let context = persistentContainer.newBackgroundContext()

        try await context.perform {
            let entity = HealthDataEntity(context: context)
            entity.timestamp = data.timestamp
            entity.dataJSON = try JSONEncoder().encode(data)

            try context.save()
        }
    }

    func fetchCachedData(for date: Date) async -> ComprehensiveHealthData? {
        // 指定日のキャッシュデータ取得
    }
}
```

---

## Stage 2: Weather & Environmental Data (Week 1-2)

**Goal**: リアルタイム環境データ統合

### Success Criteria

- ✅ OpenWeatherMap API 統合（99% uptime）
- ✅ UV Index, 大気質, 花粉情報取得
- ✅ 位置情報プライバシー保護
- ✅ 環境データキャッシュ

### 実装タスク

#### 2.1 Weather Service Implementation

```swift
// ios/TempoAI/TempoAI/Services/WeatherService.swift
class WeatherService: ObservableObject {
    private let apiKey = "YOUR_OPENWEATHER_API_KEY"
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    func fetchCurrentWeather(for location: CLLocation) async throws -> WeatherData {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // 現在の天候
        let currentURL = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

        // UV Index
        let uvURL = "\(baseURL)/uvi?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"

        // 大気質
        let airURL = "\(baseURL)/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"

        async let current = fetchWeatherJSON(from: currentURL)
        async let uv = fetchUVIndex(from: uvURL)
        async let air = fetchAirQuality(from: airURL)

        let (weather, uvIndex, airQuality) = try await (current, uv, air)

        return WeatherData(
            temperature: weather.main.temp,
            humidity: weather.main.humidity,
            pressure: weather.main.pressure,
            condition: weather.weather.first?.main ?? "",
            uvIndex: uvIndex,
            airQuality: airQuality,
            timestamp: Date()
        )
    }

    func fetchWeatherForecast(for location: CLLocation) async throws -> [WeatherForecast] {
        // 5日間予報取得
    }
}

struct WeatherData: Codable {
    let temperature: Double
    let humidity: Double
    let pressure: Double
    let condition: String
    let uvIndex: Double
    let airQuality: AirQualityData
    let timestamp: Date

    // 健康への影響スコア
    var healthImpactScore: EnvironmentalHealthScore {
        return EnvironmentalHealthCalculator.calculate(from: self)
    }
}
```

#### 2.2 Location Management Enhancement

```swift
// ios/TempoAI/TempoAI/Services/LocationManager.swift - 拡張
extension LocationManager {

    // プライバシー保護位置情報取得
    func getPrivacyProtectedLocation() async throws -> CLLocation {
        guard let location = currentLocation else {
            throw LocationError.unavailable
        }

        // 精度を適度に下げてプライバシー保護
        let reducedAccuracy = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: round(location.coordinate.latitude * 100) / 100,
                longitude: round(location.coordinate.longitude * 100) / 100
            ),
            altitude: location.altitude,
            horizontalAccuracy: 1000,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )

        return reducedAccuracy
    }
}
```

---

## Stage 3: Claude AI Analysis Integration (Week 2-3)

**Goal**: 高度な AI 健康分析の実装

### Success Criteria

- ✅ Claude API 統合完了
- ✅ パーソナライズド分析アルゴリズム
- ✅ コンテキスト分析精度 85%+
- ✅ 実用的推奨事項生成

### 実装タスク

#### 3.1 AI Analysis Service

```swift
// ios/TempoAI/TempoAI/Services/AIAnalysisService.swift
class AIAnalysisService: ObservableObject {
    private let apiClient: TempoAIAPIClient

    func generatePersonalizedInsights(
        healthData: ComprehensiveHealthData,
        weatherData: WeatherData,
        userProfile: UserProfile
    ) async throws -> PersonalizedInsights {

        let analysisRequest = AnalysisRequest(
            healthData: healthData,
            environmentalData: weatherData,
            userProfile: userProfile,
            analysisType: .comprehensive
        )

        let insights = try await apiClient.analyzeHealth(request: analysisRequest)

        // ローカル処理でさらに詳細化
        return PersonalizedInsights(
            aiInsights: insights,
            localAnalysis: performLocalAnalysis(healthData),
            recommendations: generateActionableRecommendations(insights, userProfile)
        )
    }

    private func performLocalAnalysis(_ data: ComprehensiveHealthData) -> LocalHealthAnalysis {
        return LocalHealthAnalysis(
            riskFactors: HealthRiskAssessor.assess(data),
            trends: TrendAnalyzer.analyzeTrends(data),
            alerts: AlertManager.generateAlerts(data)
        )
    }
}

struct PersonalizedInsights {
    let aiInsights: AIHealthInsights
    let localAnalysis: LocalHealthAnalysis
    let recommendations: [ActionableRecommendation]
    let confidenceScore: Double
}
```

#### 3.2 Backend AI Integration

```typescript
// backend/src/services/claude-analysis.ts
export interface ComprehensiveAnalysisRequest {
  healthData: ComprehensiveHealthData;
  environmentalData: WeatherData;
  userProfile: UserProfile;
  historicalData?: HealthDataHistory;
}

export const performComprehensiveHealthAnalysis = async (
  request: ComprehensiveAnalysisRequest
): Promise<AIHealthInsights> => {

  const analysisPrompt = buildComprehensivePrompt(request);

  const claudeResponse = await callClaudeAPI({
    prompt: analysisPrompt,
    model: "claude-3-sonnet-20240229",
    maxTokens: 2000,
    temperature: 0.3
  });

  return parseAndValidateInsights(claudeResponse);
};

// 言語サポートインターフェース
interface LanguageConfig {
  code: 'ja' | 'en';
  outputLanguage: string;
  tone: string;
  messagingGuidelines: string;
}

// LocalizationManagerと連携した言語設定
const getLanguageConfig = (userLanguagePreference: string): LanguageConfig => {
  // LocalizationManager.SupportedLanguageに対応
  const effectiveLanguage = (() => {
    switch (userLanguagePreference) {
      case 'ja':
      case 'japanese':
        return 'ja';
      case 'en':
      case 'english':
        return 'en';
      case 'system':
      default:
        // システム言語またはデフォルト（日本語）
        return 'ja';
    }
  })();

  return effectiveLanguage === 'ja' ? {
    code: 'ja',
    outputLanguage: 'Japanese',
    tone: 'Polite, supportive, use suggestion forms like "〜してみませんか" and "〜がおすすめです"',
    messagingGuidelines: `
- 提案型表現を使用（「〜してみませんか？」「〜がおすすめです」）
- ポジティブフレーミング（欠点指摘ではなく改善提案）
- 具体的で実行可能なアドバイス
- 「〜かもしれません」「〜と良いでしょう」などの柔らかい表現
- 医療的助言ではないことを適切に示唆
- 文化的配慮：和食、季節感、日本の生活習慣を考慮`
  } : {
    code: 'en',
    outputLanguage: 'English',
    tone: 'Friendly, supportive, use phrases like "you might want to try" and "consider"',
    messagingGuidelines: `
- Use suggestion language ("Would you like to try...", "You might consider...")
- Focus on progress and opportunities (not deficiencies)
- Provide specific, actionable advice
- Maintain encouraging and supportive tone
- Make clear this is general wellness guidance, not medical advice
- Cultural sensitivity: Consider local food culture and lifestyle patterns`
  };
};

const buildComprehensivePrompt = (
  request: ComprehensiveAnalysisRequest,
  userProfile: UserProfile
): string => {
  const languageConfig = getLanguageConfig(userProfile.languagePreference);

  return `
You are an advanced AI health analysis system. Analyze the comprehensive health data below and provide personalized health insights and actionable recommendations.

Follow these important guidelines:
- Be supportive and encouraging (never critical or fear-inducing)
- Use suggestion language ("you might want to try..." not "you must...")
- Focus on progress and improvement opportunities
- Provide specific, actionable advice
- Consider cultural context and food preferences
- Note that this is NOT medical advice

HEALTH DATA:
${JSON.stringify(request.healthData, null, 2)}

ENVIRONMENTAL DATA:
${JSON.stringify(request.environmentalData, null, 2)}

USER PROFILE:
${JSON.stringify(request.userProfile, null, 2)}

ANALYSIS REQUIREMENTS:
1. Overall health status assessment (score 1-100)
2. Detected health patterns and trends
3. Improvement opportunities (not "risk factors")
4. Specific actionable recommendations (3-5 items)
5. Today's optimal plan considering environmental factors

OUTPUT LANGUAGE: ${languageConfig.outputLanguage}
TONE: ${languageConfig.tone}

MESSAGING GUIDELINES:
${languageConfig.messagingGuidelines}

OUTPUT FORMAT (JSON):
{
  "overallScore": number,
  "keyInsights": string[],
  "improvementOpportunities": string[],
  "recommendations": {
    "nutrition": string,
    "exercise": string,
    "lifestyle": string,
    "mindfulness": string
  },
  "todaysOptimalPlan": string,
  "culturalNotes": string
}
`;
```

---

## 📱 UI/UX 設計詳細 (メッセージングガイドライン準拠)

### ホーム画面のアドバイス表示

#### **健康スコア表示**

```swift
// Progressive Disclosure適用
struct HealthScoreView: View {
    let score: Int
    let trend: String
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Level 1: Basic Score (Hick's Law: シンプルな情報)
            HStack {
                Text("健康スコア")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("詳細") { showDetails.toggle() }
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Text("\(score)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(score >= 80 ? .green : score >= 60 ? .orange : .red)

            // Level 2: Progress-focused messaging (if expanded)
            if showDetails {
                Text("先週より+5ポイント改善しています ✨")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(Spacing.md)
        .background(ColorPalette.secondaryBackground)
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.3), value: showDetails)
    }
}
```

#### **今日の重点アドバイス**（メッセージングガイドライン準拠）

```swift
struct TodaysFocusAdviceView: View {
    let advice: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.orange)
                Text("今日の重点アドバイス")
                    .font(.headline)
                    .fontWeight(.medium)
            }

            // 提案型表現使用（「〜してみませんか？」）
            Text("水分補給を意識してみませんか？1.8L目標です")
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Fitts's Law: 44px以上のタップ領域
            Button(action: {}) {
                HStack {
                    Text("詳しく見る")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right.circle")
                }
                .foregroundColor(.blue)
            }
            .frame(minHeight: 44)
        }
        .padding(Spacing.md)
        .background(ColorPalette.primaryBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
```

### 詳細アドバイス画面

#### **カテゴリ別アドバイス**（Miller's Law: 7±2 制限）

```swift
struct DetailedAdviceView: View {
    let insights: PersonalizedInsights
    @Environment(\.localizationManager) var localization

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg, pinnedViews: [.sectionHeaders]) {

                // Peak-End Rule: 印象的な開始
                MotivationalHeaderView(score: insights.overallScore)

                // Miller's Law適用: 最大5つのセクション
                AdviceSectionView(
                    title: "nutrition_title".localized,
                    advice: insights.recommendations.nutrition,
                    icon: "fork.knife",
                    color: .green
                )

                AdviceSectionView(
                    title: "exercise_title".localized,
                    advice: insights.recommendations.exercise,
                    icon: "figure.run",
                    color: .blue
                )

                AdviceSectionView(
                    title: "lifestyle_title".localized,
                    advice: insights.recommendations.lifestyle,
                    icon: "house",
                    color: .purple
                )

                AdviceSectionView(
                    title: "mindfulness_title".localized,
                    advice: insights.recommendations.mindfulness,
                    icon: "brain",
                    color: .orange
                )

                // Peak-End Rule: ポジティブな終了体験
                EncouragementFooterView()
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}
```

#### **個別アドバイスセクション**（提案型メッセージング）

```swift
struct AdviceSectionView: View {
    let title: String
    let advice: String
    let icon: String
    let color: Color
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Von Restorff Effect: 視覚的差別化
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 44, height: 44) // Fitts's Law
            }

            // 基本アドバイス（常時表示）
            Text(extractMainAdvice(from: advice))
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Progressive Disclosure: 詳細情報
            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("詳しいアドバイス")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text(advice)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Evidence-backed messaging
                    if let evidence = extractEvidence(from: advice) {
                        Text("💡 \(evidence)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, Spacing.xs)
                    }
                }
                .padding(.top, Spacing.sm)
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding(Spacing.md)
        .background(ColorPalette.secondaryBackground)
        .cornerRadius(16)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }

    // メッセージング処理ヘルパー
    private func extractMainAdvice(from fullAdvice: String) -> String {
        // 提案型表現を抽出
        return fullAdvice.components(separatedBy: ".").first ?? fullAdvice
    }

    private func extractEvidence(from fullAdvice: String) -> String? {
        // 根拠情報の抽出
        return fullAdvice.contains("研究によると") ? "研究によると効果が確認されています" : nil
    }
}
```

### メッセージング具体例

#### **日本語メッセージング**（ガイドライン準拠）

```swift
struct JapaneseMessagingExamples {
    // ✅ 推奨表現
    static let goodExamples = [
        "水分補給を意識してみませんか？", // 提案型
        "今週は平均7時間睡眠でした。8時間を目指してみませんか？", // Progress-focused
        "歩数が先週より15%増加しています。素晴らしい改善です！", // ポジティブフレーミング
        "昼食にタンパク質を追加すると、午後の集中力向上が期待できます", // Evidence-backed
        "無理のない範囲で続けてみてください", // User empowerment
    ]

    // ❌ 避けるべき表現
    static let badExamples = [
        "水分摂取量が不足しています", // 否定的
        "睡眠時間が短すぎます", // 批判的
        "運動してください", // 命令的
        "このままでは健康を損ないます", // 恐怖訴求
    ]
}
```

#### **英語メッセージング**

```swift
struct EnglishMessagingExamples {
    // ✅ 推奨表現
    static let goodExamples = [
        "You might want to try increasing your water intake",
        "Your sleep averaged 7 hours this week. Consider aiming for 8 hours?",
        "Great improvement! Your steps increased by 15% from last week",
        "Adding protein to lunch could help improve afternoon focus",
        "Take it at your own pace - you're doing great!",
    ]

    // ❌ 避けるべき表現
    static let badExamples = [
        "Your water intake is insufficient",
        "Your sleep is too short",
        "You must exercise",
        "This will damage your health",
    ]
}
```

---

## Stage 4: Onboarding 2.0 Refactoring (Week 3-4)

**Goal**: UX 原則に基づく完全オンボーディング刷新

### Success Criteria

- ✅ Progressive Disclosure 実装
- ✅ Peak-End Rule 活用
- ✅ 完了率 80%+ 達成
- ✅ WCAG 2.1 AAA 準拠維持

### UX Principles Implementation

#### 4.1 Psychology-Based Onboarding Flow

```swift
// ios/TempoAI/TempoAI/Views/Onboarding/OnboardingFlow2.swift
struct OnboardingFlow2: View {
    @StateObject private var viewModel = OnboardingViewModel2()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            WelcomePageView()
                .navigationDestination(for: OnboardingStep.self) { step in
                    stepView(for: step)
                }
        }
        .onAppear {
            viewModel.trackOnboardingStart()
        }
    }

    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomePageView()
        case .valueProposition:
            ValuePropositionView() // Hick's Law: 3つの主要価値提示
        case .dataPrivacy:
            DataPrivacyView()      // Progressive Disclosure: 段階的説明
        case .healthGoals:
            HealthGoalsView()      // Miller's Law: 7±2の目標選択
        case .basicPermissions:
            BasicPermissionsView() // Fitts's Law: 大きなタップ領域
        case .advancedSetup:
            AdvancedSetupView()    // Von Restorff Effect: 重要設定強調
        case .aiIntroduction:
            AIIntroductionView()   // Labor Illusion: AI処理過程表示
        case .firstInsight:
            FirstInsightView()     // Peak-End Rule: 印象的な終了体験
        }
    }
}

enum OnboardingStep: CaseIterable, Hashable {
    case welcome, valueProposition, dataPrivacy, healthGoals,
         basicPermissions, advancedSetup, aiIntroduction, firstInsight
}
```

#### 4.2 Progressive Disclosure Implementation

```swift
// ios/TempoAI/TempoAI/Views/Onboarding/Components/ProgressiveDisclosureView.swift
struct ProgressiveDisclosureView: View {
    let title: String
    let basicInfo: String
    let detailedInfo: String
    let actionItems: [String]

    @State private var currentLevel: DisclosureLevel = .basic

    var body: some View {
        VStack(spacing: 16) {
            // Level 1: Basic Information
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(basicInfo)
                .font(.body)
                .multilineTextAlignment(.center)

            // Level 2: Detailed Explanation (if expanded)
            if currentLevel >= .detailed {
                DetailedExplanationView(detailedInfo)
                    .transition(.opacity.combined(with: .slide))
            }

            // Level 3: Action Items (if fully expanded)
            if currentLevel == .actionable {
                ActionItemsView(actionItems)
                    .transition(.opacity.combined(with: .slide))
            }

            // Progressive disclosure controls
            DisclosureControlsView(currentLevel: $currentLevel)
        }
        .animation(.easeInOut(duration: 0.4), value: currentLevel)
    }
}

enum DisclosureLevel: Int, CaseIterable {
    case basic = 0
    case detailed = 1
    case actionable = 2

    static func < (lhs: DisclosureLevel, rhs: DisclosureLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
```

#### 4.3 Peak-End Rule Implementation

```swift
// ios/TempoAI/TempoAI/Views/Onboarding/FirstInsightView.swift
struct FirstInsightView: View {
    @State private var showCelebration = false
    @State private var showPersonalizedInsight = false

    var body: some View {
        VStack(spacing: 24) {
            if showCelebration {
                CelebrationAnimationView()
                    .transition(.scale.combined(with: .opacity))
            }

            Text("🎉 ようこそ、Tempo AI へ！")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if showPersonalizedInsight {
                PersonalizedWelcomeInsightView()
                    .transition(.slide.combined(with: .opacity))
            }

            // Peak moment: First personalized insight
            Button("あなた専用の健康分析を見る") {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showPersonalizedInsight = true
                }

                // Haptic feedback for positive reinforcement
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(showPersonalizedInsight)

            Spacer()

            // Positive end experience
            Text("健康な毎日の始まりです ✨")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            // Delayed celebration for dramatic effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    showCelebration = true
                }
            }
        }
    }
}
```

---

## Stage 5: Real-time Notifications & Final Integration (Week 4-5)

**Goal**: 通知システムとシステム統合完成

### Success Criteria

- ✅ リアルタイム通知システム
- ✅ iOS Widget 実装
- ✅ 全機能統合テスト
- ✅ 実機動作完全対応

### 実装タスク

#### 5.1 Notification System

```swift
// ios/TempoAI/TempoAI/Services/NotificationService.swift
class NotificationService: ObservableObject {
    private let center = UNUserNotificationCenter.current()

    func scheduleHealthInsightNotification(insight: HealthInsight) async throws {
        let content = UNMutableNotificationContent()
        content.title = "今日の健康インサイト"
        content.body = insight.summary
        content.sound = .default
        content.badge = 1

        // Rich notification with action buttons
        content.categoryIdentifier = "HEALTH_INSIGHT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        try await center.add(request)
    }

    func scheduleEnvironmentalAlert(alert: EnvironmentalAlert) async throws {
        // 気象・環境変化の通知
    }
}
```

#### 5.2 iOS Widget Implementation

```swift
// ios/TempoAIWidget/TempoAIWidget.swift
struct TempoAIWidget: Widget {
    let kind: String = "TempoAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HealthProvider()) { entry in
            HealthWidgetView(entry: entry)
        }
        .configurationDisplayName("Tempo AI")
        .description("今日の健康状態と推奨事項")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct HealthWidgetView: View {
    let entry: HealthEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("健康スコア")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(entry.healthScore)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(entry.scoreColor)

            Text(entry.recommendation)
                .font(.caption)
                .lineLimit(2)
        }
        .padding()
    }
}
```

---

## 🧪 品質保証・テスト戦略

### TDD Implementation Strategy

#### Unit Tests

```swift
// ios/TempoAI/TempoAITests/Services/HealthKitManagerTests.swift
class HealthKitManagerTests: XCTestCase {
    func testRealHealthKitDataFetching() {
        // 実HealthKitデータ取得テスト
    }

    func testDataCaching() {
        // データキャッシュ機能テスト
    }

    func testBackgroundObservation() {
        // バックグラウンド観察機能テスト
    }
}

// ios/TempoAI/TempoAITests/Services/AIAnalysisServiceTests.swift
class AIAnalysisServiceTests: XCTestCase {
    func testPersonalizedInsightGeneration() {
        // AI分析機能テスト
    }

    func testAnalysisAccuracy() {
        // 分析精度テスト
    }
}
```

#### Integration Tests

```swift
// ios/TempoAI/TempoAITests/Integration/DataFlowTests.swift
class DataFlowTests: XCTestCase {
    func testCompleteHealthDataPipeline() {
        // HealthKit → AI分析 → UI表示の完全フロー
    }

    func testWeatherHealthCorrelation() {
        // 気象データと健康データの相関分析
    }
}
```

#### UI Tests

```swift
// ios/TempoAI/TempoAIUITests/OnboardingFlow2UITests.swift
class OnboardingFlow2UITests: XCTestCase {
    func testProgressiveDisclosureFlow() {
        // 段階的情報開示のUXテスト
    }

    func testOnboardingCompletionRate() {
        // オンボーディング完了率テスト
    }

    func testAccessibilityCompliance() {
        // アクセシビリティ準拠テスト
    }
}
```

### Performance Tests

```swift
// ios/TempoAI/TempoAITests/Performance/PerformanceTests.swift
class PerformanceTests: XCTestCase {
    func testHealthDataFetchPerformance() {
        measure {
            // HealthKitデータ取得性能測定
        }
    }

    func testAIAnalysisResponseTime() {
        measure {
            // AI分析応答時間測定
        }
    }
}
```

---

## 📊 Success Metrics & KPIs

### Technical Metrics

| 指標                   | Phase 1   | Phase 2 目標 | 測定方法                |
| ---------------------- | --------- | ------------ | ----------------------- |
| Real Data Success Rate | 0% (Mock) | 90%+         | HealthKit query success |
| App Launch Time        | -         | <2.0s        | XCTest Performance      |
| AI Analysis Response   | -         | <3.0s        | Network monitoring      |
| Crash Rate             | -         | <0.1%        | Crashlytics             |
| Test Coverage          | 80%+      | 85%+         | Xcode Coverage Report   |

### User Experience Metrics

| 指標                     | Phase 1 | Phase 2 目標 | 測定方法           |
| ------------------------ | ------- | ------------ | ------------------ |
| Onboarding Completion    | -       | 80%+         | Analytics tracking |
| Feature Discovery        | -       | 70%+         | Event tracking     |
| Data Accuracy Perception | -       | 4.5/5.0      | User survey        |
| App Session Time         | -       | +25%         | Usage analytics    |

### Health Data Quality

| 指標                    | Phase 1   | Phase 2 目標 | 測定方法         |
| ----------------------- | --------- | ------------ | ---------------- |
| Data Completeness       | Mock 100% | Real 85%+    | Data audit       |
| Insight Relevance       | -         | 4.0/5.0      | User rating      |
| Recommendation Accuracy | -         | 80%+         | Follow-up survey |

---

## 🔄 Risk Management

### Technical Risks & Mitigation

#### HealthKit Data Access Limitations

**Risk**: iOS 版本・デバイス制限によるデータアクセス失敗
**Mitigation**:

- Graceful degradation strategy
- 明確なエラーメッセージ
- 代替データソース準備

#### AI API Rate Limiting

**Risk**: Claude API 制限による分析機能停止
**Mitigation**:

- Request rate limiting
- キャッシュ戦略強化
- ローカル分析 fallback

#### Real Device Compatibility

**Risk**: 実機環境での予期しない動作
**Mitigation**:

- 段階的実機テスト
- デバイス固有問題の事前調査
- ログ・クラッシュ監視強化

---

## 📅 Implementation Timeline

### Week 1: Foundation (Stage 1-2)

- **Day 1-3**: HealthKit 実データ統合実装
- **Day 4-5**: 天候データ API 統合
- **Day 6-7**: 基本データフロー確立・テスト

### Week 2: Intelligence (Stage 3)

- **Day 8-10**: Claude AI 統合・分析機能実装
- **Day 11-12**: パーソナライズド分析アルゴリズム
- **Day 13-14**: AI 分析品質テスト・調整

### Week 3: Experience (Stage 4)

- **Day 15-17**: オンボーディング 2.0 実装
- **Day 18-19**: UX 原則適用・Progressive Disclosure
- **Day 20-21**: オンボーディング UX テスト・最適化

### Week 4: Integration (Stage 5)

- **Day 22-24**: 通知システム・Widget 実装
- **Day 25-26**: 全機能統合テスト
- **Day 27-28**: 実機動作最終調整・パフォーマンス最適化

### Week 5: Polish & Validation

- **Day 29-31**: 最終品質保証
- **Day 32-35**: ユーザテスト・フィードバック反映

---

## 🎯 Phase 2 完了判定基準

### Must Have (絶対必要)

- ✅ Real HealthKit data integration (90%+ success rate)
- ✅ Weather API integration with 99% uptime
- ✅ Claude AI analysis with meaningful insights (80%+ relevance)
- ✅ Refactored onboarding 2.0 (80%+ completion rate)
- ✅ All tests passing (85%+ coverage maintained)
- ✅ Real device functionality (white screen issue resolved)

### Should Have (推奨)

- ✅ Advanced health analytics dashboard
- ✅ Real-time notifications system
- ✅ Performance optimization (all screens <2s load)
- ✅ Full accessibility compliance verification

### Could Have (可能であれば)

- ✅ iOS Widget implementation
- ✅ Advanced caching system
- ✅ Multi-device sync foundation
- ✅ Enhanced error recovery

---

## 🚀 Phase 3 Preparation

### Next Phase Preview

- **Machine Learning**: オンデバイス予測モデル
- **Social Features**: 共有・コミュニティ機能
- **watchOS Full App**: 完全独立 Watch 体験
- **Advanced Analytics**: 長期健康トレンド分析
- **Healthcare Integration**: 医療機関連携

---

**🎯 Phase 2 完了により、Tempo AI は真の AI-powered パーソナル健康コーチとして機能し、ユーザーの健康改善に実質的な価値を提供するアプリケーションへと進化します。**

_Updated on 2025-12-07 by Claude Code Development Team_
