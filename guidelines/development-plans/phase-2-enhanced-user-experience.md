# 💫 Phase 2: ユーザー体験向上計画書

**実施期間**: 4-5週間（文化適応機能追加により+1週間）  
**対象読者**: 開発チーム  
**最終更新**: 2025年12月5日  
**前提条件**: Phase 1 完了（美麗オンボーディング + カラーコード化ステータス）

---

## ⚠️ 重要：実装開始前の必須手順

**実装を開始する前に、必ず以下の手順を実行してください：**

1. **📋 全体像の把握**: [`guidelines/tempo-ai-product-spec.md`](../tempo-ai-product-spec.md) を熟読し、プロダクト全体のビジョン・要件・アーキテクチャを理解する

2. **📝 開発ルールの確認**: [`CLAUDE.md`](../../CLAUDE.md) とその関連ドキュメント（[Swift Coding Standards](.claude/swift-coding-standards.md), [TypeScript Hono Standards](.claude/typescript-hono-standards.md)）を確認し、コーディング規約・品質基準・開発プロセスを把握する

3. **🧪 テスト駆動開発**: **テストカバレッジ80%以上を維持**しながら、TDD（Test-Driven Development）でコードを実装する
   - Red: テストを書く（失敗）
   - Green: テストを通すための最小限のコード実装
   - Refactor: コード品質向上
   - **カバレッジ確認**: 各実装後に必ずテストカバレッジが80%を下回らないことを確認

---

## 🎯 概要

Phase 2では、ユーザーの主観的体調を反映した高度なパーソナライゼーション機能を実装します。朝のクイックチェックイン、詳細な教育的アドバイス画面、拡張HealthKit連携、環境アラート統合により、データドリブンと主観的感覚の両方を活用した包括的なヘルスアドバイザーを構築します。

---

## 📊 現状と目標

### Phase 1 完了時の状態
- 美麗4ページオンボーディングフロー
- カラーコード化ヘルスステータス（4段階）
- 天気対応パーソナライズ挨拶
- 基本的な環境アラート表示

### Phase 2 終了時の目標
- 🌅 **朝のクイックチェックイン機能**（気分・疲労・睡眠質・飲酒追跡）
- 🍱 **基本文化適応システム**（日本食材DB・季節対応・文化的食事提案）
- 📚 **教育的アドバイス画面**（理由説明 + インタラクティブツールチップ）
- 🌡️ **拡張HealthKit連携**（SpO2・呼吸数・体温・HRV詳細）
- ⚠️ **高度環境アラート**（気圧病・花粉症・AQI統合）
- 📊 **詳細データ可視化**（個人基準値比較・トレンド表示）

---

## 📋 実装タスク

### 1. 朝のクイックチェックイン機能

#### 1.1 MorningCheckInView 実装
```swift
// ios/TempoAI/TempoAI/Views/CheckIn/MorningCheckInView.swift
struct MorningCheckInView: View {
    @StateObject private var viewModel: MorningCheckInViewModel
    @State private var currentStep: CheckInStep = .mood
    
    var body: some View {
        VStack {
            ProgressIndicatorView(currentStep: currentStep)
            CheckInStepView(step: currentStep)
            NavigationButtonsView()
        }
        .onAppear { analytics.trackCheckInStarted() }
    }
}

enum CheckInStep: CaseIterable {
    case mood        // 😊😐😔 3択
    case fatigue     // 1-5スライダー  
    case sleepQuality // ⭐️☁️💤 3択
    case alcohol     // 🍺量 + ❌なし
}
```

#### 1.2 CheckInData モデル
```swift
// ios/TempoAI/TempoAI/Models/CheckInData.swift
struct MorningCheckInData: Codable {
    let date: Date
    let mood: MoodLevel
    let fatigue: Int // 1-5
    let sleepQuality: SleepQuality
    let alcoholConsumption: AlcoholConsumption?
    let skipReasons: [SkipReason] // オプション
}

enum MoodLevel: String, CaseIterable {
    case good = "good"        // 😊 調子いい
    case normal = "normal"    // 😐 普通  
    case tired = "tired"      // 😔 疲れてる
}

enum SleepQuality: String, CaseIterable {
    case excellent = "excellent" // ⭐️ ぐっすり
    case average = "average"     // ☁️ 普通
    case poor = "poor"           // 💤 浅い
}

struct AlcoholConsumption: Codable {
    let glasses: Int // 1-4+
    let type: AlcoholType // ビール・ワイン・日本酒等
}
```

#### 1.3 バックエンドチェックイン統合
```typescript
// backend/src/types/checkin.ts
export interface MorningCheckIn {
  userId: string
  date: string
  mood: 'good' | 'normal' | 'tired'
  fatigue: number // 1-5
  sleepQuality: 'excellent' | 'average' | 'poor'  
  alcoholConsumption?: {
    glasses: number
    type: string
  }
}

// backend/src/services/advice-personalization.ts
export const personalizeAdviceWithCheckIn = (
  baseAdvice: DailyAdvice,
  checkIn: MorningCheckIn,
  healthData: HealthData
): PersonalizedAdvice => {
  // 主観的データとHealthKitデータを統合してアドバイス再調整
}
```

### 2. 詳細アドバイス画面（教育的UI）

#### 2.1 DetailedAdviceView の高度化
```swift
// ios/TempoAI/TempoAI/Views/Advice/DetailedAdviceView.swift
struct DetailedAdviceView: View {
    let advice: DailyAdvice
    let healthData: HealthData
    let checkInData: MorningCheckInData?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AdviceHeaderView(advice: advice)
                
                // 各アドバイスセクション
                MealAdviceDetailView(meal: advice.breakfast)
                ExerciseAdviceDetailView(exercise: advice.exercise)  
                WellnessAdviceDetailView(wellness: advice.breathing)
                
                // なぜこのアドバイス？セクション
                ReasoningExplanationView(advice: advice, data: healthData)
                
                // あなたのデータから見える傾向
                PersonalInsightsView(healthData: healthData)
            }
        }
    }
}
```

#### 2.2 インタラクティブ教育ツールチップ
```swift
// ios/TempoAI/TempoAI/Views/Components/EducationalTooltipView.swift  
struct EducationalTooltipView: View {
    let title: String
    let explanation: String
    let personalValue: String
    let normalRange: String
    let improvementTips: [String]
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            // コンパクト表示：指標値 + ⓘ アイコン
            if !isExpanded { CompactIndicatorView() }
            
            // 展開表示：詳細説明 + 改善ヒント
            if isExpanded { ExpandedEducationView() }
        }
        .onTapGesture { withAnimation(.spring()) { isExpanded.toggle() } }
    }
}
```

### 3. 拡張HealthKit連携

#### 3.1 HealthKitManager 機能拡張
```swift
// ios/TempoAI/TempoAI/Managers/HealthKitManager.swift - 拡張
extension HealthKitManager {
    
    // 新規データタイプ
    func requestAdvancedPermissions() async -> Bool {
        let advancedTypes: Set<HKSampleType> = [
            HKQuantityType(.oxygenSaturation),        // SpO2
            HKQuantityType(.respiratoryRate),         // 呼吸数  
            HKQuantityType(.bodyTemperature),         // 体温
            HKQuantityType(.heartRateRecoveryOneMinute), // 心拍回復
            HKCategoryType(.sleepAnalysis)            // 睡眠ステージ詳細
        ]
    }
    
    // 詳細データ取得
    func fetchAdvancedHealthData() async -> AdvancedHealthData? {
        async let spo2 = fetchOxygenSaturation()
        async let respRate = fetchRespiratoryRate()  
        async let bodyTemp = fetchBodyTemperature()
        async let hrvDetails = fetchHRVTrends()
        
        return await AdvancedHealthData(
            oxygenSaturation: spo2,
            respiratoryRate: respRate,
            bodyTemperature: bodyTemp,
            hrvTrends: hrvDetails
        )
    }
}

struct AdvancedHealthData: Codable {
    let oxygenSaturation: Double?      // SpO2 %
    let respiratoryRate: Double?       // breaths/min
    let bodyTemperature: Double?       // °C
    let hrvTrends: [HRVDataPoint]      // 過去7日間
}
```

#### 3.2 バックエンドAdvanced Health分析
```typescript
// backend/src/services/advanced-health-analysis.ts
export interface AdvancedHealthData {
  oxygenSaturation?: number
  respiratoryRate?: number  
  bodyTemperature?: number
  hrvTrends?: HRVDataPoint[]
}

export const analyzeAdvancedHealth = (
  basicData: HealthData,
  advancedData: AdvancedHealthData,
  checkIn?: MorningCheckIn
): AdvancedHealthInsights => {
  return {
    respiratoryHealth: analyzeRespiratoryMetrics(advancedData),
    recoveryStatus: assessRecoveryState(basicData, advancedData),
    sleepQuality: correlateSleepMetrics(basicData.sleep, checkIn?.sleepQuality),
    stressIndicators: identifyStressPatterns(basicData.hrv, advancedData.respiratoryRate)
  }
}
```

### 4. 高度環境アラートシステム

#### 4.1 気圧病対応アラート
```swift
// ios/TempoAI/TempoAI/Services/BarometricPressureService.swift
class BarometricPressureService {
    static func analyzeBarometricChanges(
        current: Double,      // 現在気圧 hPa
        trend: [Double],      // 過去24時間の気圧変化
        userSensitivity: BarometricSensitivity
    ) -> BarometricAlert? {
        
        let pressureDropRate = calculatePressureDropRate(trend)
        let severity = assessPressureImpact(pressureDropRate, userSensitivity)
        
        guard severity > .none else { return nil }
        
        return BarometricAlert(
            severity: severity,
            currentPressure: current,
            dropRate: pressureDropRate,
            symptoms: predictedSymptoms(severity),
            recommendations: mitigationStrategies(severity)
        )
    }
}

struct BarometricAlert {
    let severity: AlertSeverity      // .mild, .moderate, .severe
    let currentPressure: Double      // hPa
    let dropRate: Double             // hPa/hour
    let symptoms: [String]           // 予想症状
    let recommendations: [String]    // 対策提案
}

enum BarometricSensitivity: CaseIterable {
    case low, medium, high, veryHigh
}
```

#### 4.2 統合環境ダッシュボード
```swift
// ios/TempoAI/TempoAI/Views/Environment/EnvironmentDashboardView.swift
struct EnvironmentDashboardView: View {
    let environmentData: EnvironmentData
    let userProfile: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // 気圧チャート（過去24時間）
            BarometricPressureChartView(data: environmentData.pressureHistory)
            
            // アレルギー情報（花粉・大気質）
            AllergyInformationView(
                pollenLevel: environmentData.pollenLevel,
                aqi: environmentData.airQuality,
                userAllergies: userProfile.allergies
            )
            
            // UV・熱中症リスク  
            HealthRiskAssessmentView(
                uvIndex: environmentData.uvIndex,
                temperature: environmentData.temperature,
                humidity: environmentData.humidity
            )
        }
    }
}
```

### 5. 文化適応システム（基本版）- Phase 5から前倒し

#### 5.1 基本日本食材データベース構築
```swift
// ios/TempoAI/TempoAI/Services/JapaneseFoodDatabase.swift
struct JapaneseFoodDatabase {
    static let seasonalIngredients: [Season: [FoodIngredient]] = [
        .spring: [
            FoodIngredient(name: "筍", englishName: "Bamboo Shoots", nutritionalProfile: .highFiber),
            FoodIngredient(name: "菜の花", englishName: "Rapeseed Blossoms", nutritionalProfile: .antioxidant),
            FoodIngredient(name: "新玉ねぎ", englishName: "New Onions", nutritionalProfile: .antiInflammatory),
            FoodIngredient(name: "春キャベツ", englishName: "Spring Cabbage", nutritionalProfile: .vitaminC),
            FoodIngredient(name: "アスパラガス", englishName: "Asparagus", nutritionalProfile: .folate)
        ],
        .summer: [
            FoodIngredient(name: "茄子", englishName: "Eggplant", nutritionalProfile: .lowCalorie),
            FoodIngredient(name: "胡瓜", englishName: "Cucumber", nutritionalProfile: .hydrating),
            FoodIngredient(name: "トマト", englishName: "Tomato", nutritionalProfile: .lycopene),
            FoodIngredient(name: "枝豆", englishName: "Edamame", nutritionalProfile: .protein),
            FoodIngredient(name: "とうもろこし", englishName: "Corn", nutritionalProfile: .complexCarbs)
        ],
        .autumn: [
            FoodIngredient(name: "柿", englishName: "Persimmon", nutritionalProfile: .vitaminC),
            FoodIngredient(name: "さつまいも", englishName: "Sweet Potato", nutritionalProfile: .complexCarbs),
            FoodIngredient(name: "椎茸", englishName: "Shiitake Mushroom", nutritionalProfile: .immuneSupport),
            FoodIngredient(name: "栗", englishName: "Chestnut", nutritionalProfile: .complexCarbs),
            FoodIngredient(name: "銀杏", englishName: "Ginkgo Nut", nutritionalProfile: .antioxidant)
        ],
        .winter: [
            FoodIngredient(name: "大根", englishName: "Daikon Radish", nutritionalProfile: .digestiveSupport),
            FoodIngredient(name: "白菜", englishName: "Chinese Cabbage", nutritionalProfile: .vitaminK),
            FoodIngredient(name: "長ネギ", englishName: "Long Onion", nutritionalProfile: .antiViral),
            FoodIngredient(name: "ほうれん草", englishName: "Spinach", nutritionalProfile: .iron),
            FoodIngredient(name: "かぼちゃ", englishName: "Kabocha Squash", nutritionalProfile: .betaCarotene)
        ]
    ]
    
    static let culturalMeals: [MealType: [JapaneseMeal]] = [
        .breakfast: [
            JapaneseMeal(name: "和定食", ingredients: ["米", "味噌汁", "焼き魚", "納豆", "海苔"]),
            JapaneseMeal(name: "おにぎりセット", ingredients: ["おにぎり", "味噌汁", "漬物"]),
            JapaneseMeal(name: "卵かけご飯", ingredients: ["米", "卵", "醤油", "海苔"]),
            JapaneseMeal(name: "お粥セット", ingredients: ["お粥", "梅干し", "昆布"]),
            JapaneseMeal(name: "パンケーキ", ingredients: ["小麦粉", "卵", "牛乳", "蜂蜜"])
        ],
        .lunch: [
            JapaneseMeal(name: "親子丼", ingredients: ["鶏肉", "卵", "玉ねぎ", "米"]),
            JapaneseMeal(name: "天ぷらそば", ingredients: ["そば", "天ぷら", "つゆ"]),
            JapaneseMeal(name: "カレーライス", ingredients: ["カレールー", "米", "玉ねぎ", "人参"]),
            JapaneseMeal(name: "弁当", ingredients: ["米", "焼き魚", "卵焼き", "野菜"]),
            JapaneseMeal(name: "うどん", ingredients: ["うどん", "つゆ", "ネギ", "かまぼこ"])
        ],
        .dinner: [
            JapaneseMeal(name: "鍋料理", ingredients: ["白菜", "豚肉", "豆腐", "きのこ"]),
            JapaneseMeal(name: "刺身定食", ingredients: ["刺身", "米", "味噌汁", "小鉢"]),
            JapaneseMeal(name: "焼き魚定食", ingredients: ["焼き魚", "米", "味噌汁", "煮物"]),
            JapaneseMeal(name: "すき焼き", ingredients: ["牛肉", "豆腐", "白菜", "しらたき"]),
            JapaneseMeal(name: "天ぷら定食", ingredients: ["天ぷら", "米", "味噌汁", "漬物"])
        ]
    ]
}
```

#### 5.2 文化適応サービス（基本版）
```swift
// ios/TempoAI/TempoAI/Services/CulturalAdaptationService.swift
struct CulturalAdaptationService {
    
    static func adaptMealRecommendations(
        _ recommendations: [MealRecommendation],
        for language: SupportedLanguage,
        season: Season
    ) -> [CulturallyAdaptedMeal] {
        
        guard language == .japanese else {
            return recommendations.map { CulturallyAdaptedMeal(original: $0) }
        }
        
        return recommendations.map { recommendation in
            adaptToJapaneseCulture(recommendation, season: season)
        }
    }
    
    private static func adaptToJapaneseCulture(
        _ recommendation: MealRecommendation,
        season: Season
    ) -> CulturallyAdaptedMeal {
        
        let seasonalIngredients = JapaneseFoodDatabase.seasonalIngredients[season] ?? []
        let culturalMeals = JapaneseFoodDatabase.culturalMeals[recommendation.mealType] ?? []
        
        return CulturallyAdaptedMeal(
            original: recommendation,
            adaptedIngredients: adaptIngredients(recommendation.ingredients, seasonal: seasonalIngredients),
            culturalMealOptions: culturalMeals,
            seasonalContext: generateSeasonalContext(for: season),
            preparationTips: generateJapanesePreparationTips(for: recommendation.mealType)
        )
    }
    
    private static func adaptIngredients(
        _ ingredients: [Ingredient],
        seasonal: [FoodIngredient]
    ) -> [AdaptedIngredient] {
        
        return ingredients.compactMap { ingredient in
            // 栄養プロファイルに基づく日本食材への置き換え
            let japaneseSubs = seasonal.filter { $0.nutritionalProfile == ingredient.nutritionalProfile }
            let substitution = japaneseSubs.randomElement()
            
            return AdaptedIngredient(
                original: ingredient,
                japaneseName: substitution?.name,
                englishName: substitution?.englishName,
                culturalRelevance: substitution != nil ? .high : .low
            )
        }
    }
}
```

#### 5.3 バックエンド文化適応統合
```typescript
// backend/src/utils/cultural-adaptation.ts
export interface CulturalContext {
  language: 'ja' | 'en'
  region: 'JP' | 'US' | 'other'
  season: 'spring' | 'summer' | 'autumn' | 'winter'
  localTime: string
}

export const generateCulturallyAdaptedAdvice = async (
  healthData: HealthData,
  environmentData: EnvironmentData,
  culturalContext: CulturalContext
): Promise<LocalizedAdvice> => {
  
  const culturalPrompt = buildCulturalPrompt(culturalContext)
  const seasonalFoodContext = getSeasonalFoodContext(culturalContext.season, culturalContext.region)
  
  const prompt = `
${culturalPrompt}

今日の健康データ:
${JSON.stringify(healthData)}

環境データ:
${JSON.stringify(environmentData)}

季節の食材情報:
${seasonalFoodContext}

文化的に適応されたアドバイスを以下の形式で生成してください:
- 食事: 季節の食材と文化的な調理法を活用
- 運動: 地域の気候と文化的習慣を考慮
- 過ごし方: 文化的なウェルネス習慣を取り入れ
`

  const response = await callClaudeAPI(prompt)
  return parseAdviceResponse(response, culturalContext)
}

const buildCulturalPrompt = (context: CulturalContext): string => {
  if (context.language === 'ja' && context.region === 'JP') {
    return `
あなたは日本の文化と食習慣に精通したヘルスアドバイザーです。
- 季節感を大切にした食材選択
- 和食を中心とした栄養バランス
- 日本の気候と生活リズムに適応したアドバイス
- 親しみやすく実践しやすい提案
`
  }
  
  return `
You are a culturally-aware health advisor providing personalized recommendations.
Focus on locally available ingredients and culturally appropriate meal suggestions.
`
}

const getSeasonalFoodContext = (season: string, region: string): string => {
  if (region !== 'JP') return ''
  
  const seasonalMaps = {
    spring: '春の食材: 筍、菜の花、新玉ねぎ、春キャベツ、アスパラガス',
    summer: '夏の食材: 茄子、胡瓜、トマト、枝豆、とうもろこし',
    autumn: '秋の食材: 柿、さつまいも、椎茸、栗、銀杏',
    winter: '冬の食材: 大根、白菜、長ネギ、ほうれん草、かぼちゃ'
  }
  
  return seasonalMaps[season] || ''
}
```

### 6. データ可視化と個人基準値比較

#### 6.1 PersonalBaselineCalculator
```swift
// ios/TempoAI/TempoAI/Services/PersonalBaselineCalculator.swift
class PersonalBaselineCalculator {
    
    static func calculatePersonalBaselines(
        healthHistory: [HealthData]
    ) -> PersonalBaselines {
        
        let last30Days = healthHistory.suffix(30)
        
        return PersonalBaselines(
            restingHeartRate: calculateBaseline(last30Days.map(\.heartRate.resting)),
            hrv: calculateBaseline(last30Days.map(\.hrv.average)),
            sleepDuration: calculateBaseline(last30Days.map(\.sleep.duration)),
            sleepEfficiency: calculateBaseline(last30Days.map(\.sleep.efficiency))
        )
    }
    
    static func compareToBaseline(
        current: Double,
        baseline: Baseline
    ) -> BaselineComparison {
        let percentDifference = ((current - baseline.average) / baseline.average) * 100
        
        return BaselineComparison(
            current: current,
            baseline: baseline.average,
            percentDifference: percentDifference,
            significance: assessSignificance(percentDifference, baseline.standardDeviation)
        )
    }
}

struct PersonalBaselines {
    let restingHeartRate: Baseline
    let hrv: Baseline
    let sleepDuration: Baseline
    let sleepEfficiency: Baseline
}

struct BaselineComparison {
    let current: Double
    let baseline: Double
    let percentDifference: Double        // -15% to +20% etc
    let significance: Significance       // .normal, .noteworthy, .significant
}
```

---

## 🎨 UI/UX 設計詳細

### チェックインフロー設計
```swift
// 30秒以内完了を目指すUX
struct CheckInStepView: View {
    let step: CheckInStep
    
    var body: some View {
        switch step {
        case .mood:
            // 大きな絵文字 3択（タップ1回）
            MoodSelectionView()
        case .fatigue:
            // 直感的スライダー（ドラッグ1回）
            FatigueSliderView()
        case .sleepQuality:  
            // 視覚的アイコン 3択（タップ1回）
            SleepQualityView()
        case .alcohol:
            // 「なし」は大きなボタン、「あり」は数量選択
            AlcoholInputView()
        }
    }
}
```

### 教育ツールチップ階層設計
```
レベル1: 🔵 基本指標表示（HRV: 58ms ⓘ）
レベル2: 📊 あなたとの比較（平均より8%低め）
レベル3: 📚 医学的説明（心拍と心拍の間隔のばらつき）
レベル4: 💡 改善アクション（7-8時間睡眠、ストレス管理）
```

### 環境アラート重要度視覚化
```swift
extension AlertSeverity {
    var displayStyle: AlertDisplayStyle {
        switch self {
        case .mild:     return .info(color: .blue, icon: "info.circle")
        case .moderate: return .warning(color: .orange, icon: "exclamationmark.triangle")  
        case .severe:   return .critical(color: .red, icon: "exclamationmark.octagon")
        }
    }
}
```

---

## 🧪 テスト戦略

### UIテスト重点項目
```swift
// ios/TempoAI/TempoAIUITests/MorningCheckInUITests.swift
class MorningCheckInUITests: XCTestCase {
    func testCheckInFlowCompletion30Seconds()    // 30秒以内完了
    func testCheckInSkipFunctionality()           // スキップ機能
    func testMoodSelectionAccessibility()         // アクセシビリティ
    func testFatigueSliderPrecision()            // スライダー精度
    func testAlcoholInputValidation()            // 入力検証
}

// ios/TempoAI/TempoAIUITests/EducationalUITests.swift
class EducationalUITests: XCTestCase {
    func testTooltipExpansionAnimation()         // ツールチップ展開
    func testPersonalDataComparisonAccuracy()   // 個人比較精度
    func testBaselineCalculationDisplay()       // 基準値表示
}
```

### バックエンド統合テスト
```typescript
// backend/tests/integration/advanced-health.test.ts
describe('Advanced Health Integration', () => {
  it('should integrate check-in data with health analysis')
  it('should calculate personal baselines accurately')  
  it('should generate educational explanations')
  it('should correlate environmental and health data')
})
```

### パフォーマンステスト
```swift
// 重要な性能目標
- チェックイン表示: 0.5秒以内
- 詳細アドバイス読み込み: 1秒以内  
- 環境データ更新: 2秒以内
- ツールチップ展開アニメーション: 60fps維持
```

---

## 📦 成果物

### 新規iOS実装
```
ios/TempoAI/TempoAI/
├── Views/
│   ├── CheckIn/
│   │   ├── MorningCheckInView.swift
│   │   ├── MoodSelectionView.swift  
│   │   ├── FatigueSliderView.swift
│   │   └── AlcoholInputView.swift
│   ├── Advice/
│   │   ├── DetailedAdviceView.swift
│   │   ├── ReasoningExplanationView.swift
│   │   └── PersonalInsightsView.swift
│   ├── Environment/
│   │   ├── EnvironmentDashboardView.swift
│   │   ├── BarometricPressureChartView.swift
│   │   └── AllergyInformationView.swift
│   └── Components/
│       ├── EducationalTooltipView.swift
│       ├── BaselineComparisonView.swift
│       └── AdvancedDataVisualizationView.swift
├── Services/
│   ├── BarometricPressureService.swift
│   ├── PersonalBaselineCalculator.swift
│   └── AdvancedHealthAnalyzer.swift
└── Models/
    ├── CheckInData.swift
    ├── AdvancedHealthData.swift
    └── PersonalBaselines.swift
```

### バックエンド拡張
```
backend/src/
├── routes/
│   └── checkin.ts                    // POST /checkin
├── services/
│   ├── advice-personalization.ts    // チェックイン統合
│   ├── advanced-health-analysis.ts  // 高度分析
│   ├── personal-baseline.ts         // 個人基準値
│   └── environmental-alerts.ts      // 環境アラート
└── types/
    ├── checkin.ts
    ├── advanced-health.ts
    └── environmental-alerts.ts
```

---

## ⏱️ スケジュール

| Week | 主要タスク | マイルストーン |
|------|------------|----------------|
| **Week 1** | 朝のチェックイン機能 + バックエンド統合 | チェックイン完成 |
| **Week 2** | 拡張HealthKit連携 + 高度データ分析 | 詳細ヘルスデータ取得 |
| **Week 3** | 基本文化適応システム（日本食材DB + 文化適応サービス） | 文化適応機能完成 |
| **Week 4** | 詳細アドバイス画面 + 教育ツールチップ | インタラクティブ説明完成 |
| **Week 5** | 環境アラート統合 + 個人基準値比較 + 最終統合テスト | Phase 2完成 |

---

## 🎯 成功基準

### 機能完了基準
- [ ] 朝のチェックインが30秒以内で完了可能
- [ ] 基本文化適応機能（日本食材50種・和食メニュー15種・季節対応）実装完了
- [ ] 拡張HealthKitデータ（SpO2・呼吸数・体温）取得・表示
- [ ] 教育ツールチップで全指標の意味と改善方法を説明
- [ ] 環境アラート（気圧・花粉・AQI）が実際の気象と連動
- [ ] 個人基準値との比較が視覚的に理解可能

### 体験品質基準
- [ ] チェックイン完了率: 90%以上（スキップ含む）
- [ ] ツールチップ利用率: 30%以上（初回利用者）
- [ ] アドバイス理解度: 教育的説明により大幅向上
- [ ] 環境アラート有用性: 実際の体調変化との相関確認

### 技術品質基準
- [ ] 新機能UIテスト網羅率: 90%以上
- [ ] バックエンドテストカバレッジ: 95%以上維持
- [ ] チェックインデータ永続化: 100%信頼性
- [ ] パフォーマンス: 全画面1秒以内読み込み

---

## 🔄 Next Phase

Phase 2 完了により、個人の主観とデータを統合した高度なヘルスアドバイザーが完成します。

### Phase 3への引き継ぎ
- **完成機能**: チェックイン + 文化適応（基本版） + 詳細教育 + 環境統合 + 個人基準値
- **拡張準備**: Historyタブでの過去データ活用、Trendsタブでの長期分析
- **データ蓄積**: 個人のチェックインパターン・健康トレンド・環境反応データ・文化的嗜好データ

---

**🎯 Phase 2により、Tempo AIは単なるデータ表示から、パーソナライズされた健康教育プラットフォームへと進化します**