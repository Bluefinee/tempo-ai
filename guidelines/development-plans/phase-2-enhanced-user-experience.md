# 💫 Phase 2: ユーザー体験向上計画書

**実施期間**: 4-5 週間（文化適応機能追加により+1 週間）  
**対象読者**: 開発チーム  
**最終更新**: 2025 年 12 月 5 日  
**前提条件**: Phase 1 完了（美麗オンボーディング + カラーコード化ステータス）

---

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール

### 🧪 テスト駆動開発（TDD）必須要件

- **カバレッジ目標**: Backend ≥80%, iOS ≥80%
- **TDD サイクル**: Red → Green → Blue → Integrate
- **継続的品質**: 全実装でテストファースト
- **品質ゲート**: 実装完了前に必ずテスト実行・確認

### 📦 コミット戦略

- **細かい単位でコミット**: 機能単位、テスト単位での適切な粒度
- **明確なコミットメッセージ**: 変更内容と理由を簡潔に記載
- **継続的統合**: 各コミット後の CI/CD 確認

---

## 🎯 概要

Phase 2 では、ユーザーの主観的体調を反映した高度なパーソナライゼーション機能を実装します。朝のクイックチェックイン、詳細な教育的アドバイス画面、拡張 HealthKit 連携、環境アラート統合により、データドリブンと主観的感覚の両方を活用した包括的なヘルスアドバイザーを構築します。

---

## 📊 現状と目標

### Phase 1 完了時の状態

- 美麗 4 ページオンボーディングフロー
- カラーコード化ヘルスステータス（4 段階）
- 天気対応パーソナライズ挨拶
- 基本的な環境アラート表示

### Phase 2 終了時の目標

- 🌅 **朝のクイックチェックイン機能**（気分・疲労・睡眠質・飲酒追跡）
- 🍱 **基本文化適応システム**（日本食材 DB・季節対応・文化的食事提案）
- 📚 **教育的アドバイス画面**（理由説明 + インタラクティブツールチップ）
- 🌡️ **拡張 HealthKit 連携**（SpO2・呼吸数・体温・HRV 詳細）
- ⚠️ **高度環境アラート**（気圧病・花粉症・AQI 統合）
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
  userId: string;
  date: string;
  mood: "good" | "normal" | "tired";
  fatigue: number; // 1-5
  sleepQuality: "excellent" | "average" | "poor";
  alcoholConsumption?: {
    glasses: number;
    type: string;
  };
}

// backend/src/services/advice-personalization.ts
export const personalizeAdviceWithCheckIn = (
  baseAdvice: DailyAdvice,
  checkIn: MorningCheckIn,
  healthData: HealthData
): PersonalizedAdvice => {
  // 主観的データとHealthKitデータを統合してアドバイス再調整
};
```

### 2. 詳細アドバイス画面（教育的 UI）

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

### 3. 拡張 HealthKit 連携

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

#### 3.2 バックエンド Advanced Health 分析

```typescript
// backend/src/services/advanced-health-analysis.ts
export interface AdvancedHealthData {
  oxygenSaturation?: number;
  respiratoryRate?: number;
  bodyTemperature?: number;
  hrvTrends?: HRVDataPoint[];
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
    stressIndicators: identifyStressPatterns(
      basicData.hrv,
      advancedData.respiratoryRate
    ),
  };
};
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

### 5. 文化適応システム（基本版）

#### 5.1 Claude API 文化適応プロンプト強化

```typescript
// backend/src/services/cultural-adaptation.ts
export const generateCulturallyAdaptedAdvice = async (
  healthData: HealthData,
  environmentData: EnvironmentData,
  userLocation: UserLocation,
  userLanguage: string
): Promise<CulturallyAdaptedAdvice> => {

  const culturalPrompt = buildCulturalAdaptationPrompt(
    userLocation,
    userLanguage,
    getCurrentSeason(userLocation)
  )

  const prompt = `
${culturalPrompt}

今日の健康データ:
${JSON.stringify(healthData)}

環境データ:
${JSON.stringify(environmentData)}

文化的に適応されたアドバイスを生成してください。季節の食材と地域の食文化を自然に取り入れ、
実践しやすい具体的な食事・運動・過ごし方を提案してください。
`

  const response = await callClaudeAPI(prompt)
  return parseAdviceResponse(response)
}

const buildCulturalAdaptationPrompt = (
  location: UserLocation,
  language: string,
  season: Season
): string => {
  if (language === 'ja' && location.country === 'JP') {
    return `
あなたは日本の文化と食習慣に精通したヘルスアドバイザーです。

文化的配慮事項:
- 現在の季節（${season}）の旬の食材を活用
- 和食を中心とした栄養バランス
- 日本の生活リズム（朝食・昼食・夕食の時間帯）に適応
- 地域の気候と季節変化を考慮
- 親しみやすく実践しやすい提案
- だし・発酵食品など日本の伝統的健康食材の活用
`
  }

  return `
You are a culturally-aware health advisor providing personalized recommendations.
Consider local food culture, seasonal availability, and cultural meal patterns.
`
```

#### 5.2 文化適応機能（AI 統合版）

```swift
// ios/TempoAI/TempoAI/Services/CulturalAdaptationService.swift
struct CulturalAdaptationService {

    static func getCurrentCulturalContext(
        userLocation: CLLocation,
        userLanguage: String
    ) -> CulturalContext {

        return CulturalContext(
            language: userLanguage,
            region: determineRegion(from: userLocation),
            season: getCurrentSeason(for: userLocation),
            timeZone: TimeZone.current
        )
    }

    private static func determineRegion(from location: CLLocation) -> String {
        // CoreLocationを使用して地域判定
        let geocoder = CLGeocoder()
        // 簡単な地域判定ロジック
        return "JP" // 実際の実装では地理的座標から判定
    }

    private static func getCurrentSeason(for location: CLLocation) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())

        // 北半球での季節判定（南半球の場合は逆転）
        switch month {
        case 3...5: return "spring"
        case 6...8: return "summer"
        case 9...11: return "autumn"
        default: return "winter"
        }
    }
}

struct CulturalContext {
    let language: String
    let region: String
    let season: String
    let timeZone: TimeZone

    var culturalPromptContext: String {
        switch (language, region) {
        case ("ja", "JP"):
            return "日本在住、\(season)の季節、和食文化重視"
        case ("en", "US"):
            return "US resident, \(season) season, Western food culture"
        default:
            return "General cultural context, \(season) season"
        }
    }
}
```

#### 5.3 バックエンド文化適応統合（AI 最適化版）

```typescript
// backend/src/utils/cultural-adaptation.ts
export interface CulturalContext {
  language: "ja" | "en";
  region: "JP" | "US" | "other";
  season: "spring" | "summer" | "autumn" | "winter";
  localTime: string;
  userLocation?: {
    latitude: number;
    longitude: number;
  };
}

export const generateCulturallyAdaptedAdvice = async (
  healthData: HealthData,
  environmentData: EnvironmentData,
  culturalContext: CulturalContext
): Promise<LocalizedAdvice> => {
  const culturalPrompt = buildAdvancedCulturalPrompt(culturalContext);

  const prompt = `
${culturalPrompt}

今日の健康データ:
${JSON.stringify(healthData)}

環境データ:
${JSON.stringify(environmentData)}

上記のデータを元に、文化的背景を考慮した個人向けアドバイスを生成してください。
季節の食材、地域の食文化、生活習慣を自然に織り込んだ実践的な提案をお願いします。
`;

  const response = await callClaudeAPI(prompt);
  return parseAdviceResponse(response, culturalContext);
};

const buildAdvancedCulturalPrompt = (context: CulturalContext): string => {
  const basePrompt = `あなたは文化に精通したパーソナルヘルスアドバイザーです。`;

  if (context.language === "ja" && context.region === "JP") {
    return `
${basePrompt}

日本の文化的特徴を考慮:
- 現在は${context.season}で、この季節の旬の食材を自然に提案
- 和食文化（だし、発酵食品、季節感）を活用  
- 日本の生活リズム（朝食・昼食・夕食の時間帯、働き方）に適応
- 地域の気候変化と体調管理の関連性を考慮
- 実践しやすく、親しみやすい表現で提案

食材や調理法は固定せず、健康データと季節に応じて柔軟に選択してください。
`;
  }

  return `
${basePrompt}

Cultural considerations for ${context.region}:
- Current season: ${context.season}
- Local food availability and cultural meal patterns
- Regional climate and lifestyle adaptation
- Practical and culturally appropriate suggestions
`;
};
```

### 6. データ可視化と個人基準値比較 + アドバイス履歴活用

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

#### 6.2 AdviceHistoryManager（アドバイス履歴活用）

**Phase 1で準備したAIプロンプト履歴セクションに実際のデータを提供する機能を実装**

```swift
// ios/TempoAI/TempoAI/Services/AdviceHistoryManager.swift
import Foundation

class AdviceHistoryManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let historyKey = "tempoai_advice_history"
    private let maxHistoryDays = 7
    
    struct AdviceHistoryEntry: Codable {
        let date: Date
        let theme: String
        let summary: String
        let healthStatus: String
        let exerciseIntensity: String?
    }
    
    /// 新しいアドバイスを履歴に保存
    func saveAdvice(_ advice: DailyAdvice, healthStatus: String) {
        var history = getRecentHistory()
        
        let entry = AdviceHistoryEntry(
            date: Date(),
            theme: advice.theme,
            summary: advice.summary,
            healthStatus: healthStatus,
            exerciseIntensity: advice.exercise.intensity
        )
        
        history.append(entry)
        
        // 7日以前のデータを削除
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxHistoryDays, to: Date()) ?? Date()
        history = history.filter { $0.date >= cutoffDate }
        
        saveHistory(history)
    }
    
    /// AIプロンプト用の履歴文字列生成（Phase 1で準備したセクションに送信）
    func generateHistoryContextForAI() -> String {
        let history = getRecentHistory()
        
        guard !history.isEmpty else {
            return "No previous advice history available - this appears to be an early interaction."
        }
        
        let sortedHistory = history.sorted { $0.date > $1.date }
        var contextLines: [String] = []
        
        for (index, entry) in sortedHistory.enumerated() {
            let dayName = index == 0 ? "Yesterday" : "\(index + 1) days ago"
            let line = "- \(dayName): \(entry.theme) - \(entry.summary) (Health: \(entry.healthStatus))"
            contextLines.append(line)
        }
        
        return contextLines.joined(separator: "\n")
    }
    
    /// 週次パターン分析（Phase 1で準備したセクションに送信）
    func generateWeeklyPatternsForAI() -> String {
        let history = getRecentHistory()
        
        guard history.count >= 3 else {
            return "Insufficient data for pattern analysis - building baseline over time."
        }
        
        let exerciseDays = history.compactMap { $0.exerciseIntensity }.count
        let restDays = history.filter { $0.healthStatus.contains("rest") || $0.healthStatus.contains("care") }.count
        
        var patterns: [String] = []
        patterns.append("Exercise frequency: \(exerciseDays)/\(history.count) days")
        
        if restDays > 0 {
            patterns.append("Recovery days: \(restDays)/\(history.count) days")
        }
        
        return patterns.joined(separator: ", ")
    }
    
    private func getRecentHistory() -> [AdviceHistoryEntry] {
        guard let data = userDefaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([AdviceHistoryEntry].self, from: data) else {
            return []
        }
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxHistoryDays, to: Date()) ?? Date()
        return history.filter { $0.date >= cutoffDate }
    }
    
    private func saveHistory(_ history: [AdviceHistoryEntry]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
}
```

#### 6.3 Backend: 履歴データをAIプロンプトに統合

```typescript
// backend/src/services/health-advice.ts への拡張
import type { AdviceHistoryData } from '../types/history'

export interface HealthAdviceParams {
  // 既存のパラメータ...
  healthData: HealthData
  weather: WeatherData
  userProfile: UserProfile
  apiKey: string
  customFetch?: typeof fetch
  /** アドバイス履歴データ（Phase 2で追加） */
  adviceHistory?: AdviceHistoryData
}

// health-advice.ts での統合
export const generateHealthAdvice = async (
  params: HealthAdviceParams,
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  validateHealthAdviceInputs(params)

  try {
    // Phase 1で準備した履歴セクションに実際のデータを提供
    const prompt = buildPrompt({
      healthData: params.healthData,
      weather: params.weather,
      userProfile: params.userProfile,
      // Phase 1で準備したオプショナルフィールドに実データを渡す
      recentAdviceHistory: params.adviceHistory?.recentAdvice 
        ? formatAdviceHistory(params.adviceHistory.recentAdvice)
        : undefined,
      weeklyHealthPatterns: params.adviceHistory?.weeklyPatterns
        ? formatWeeklyPatterns(params.adviceHistory.weeklyPatterns)
        : undefined,
    })

    const claudeParams = { prompt, apiKey: params.apiKey, customFetch: params.customFetch }
    return await callClaude(claudeParams)
  } catch (error) {
    if (error instanceof APIError) throw error
    throw new APIError(`Health advice generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`, 500, 'HEALTH_ADVICE_GENERATION_ERROR')
  }
}
```

#### 6.4 HomeViewModel統合

```swift
// ios/TempoAI/TempoAI/ViewModels/HomeViewModel.swift への追加

@StateObject private var adviceHistoryManager = AdviceHistoryManager()

private func generateDailyAdvice() async {
    // 既存のヘルスデータ取得ロジック...
    
    do {
        // Phase 1で準備した構造を使って履歴データを送信
        let historyContext = adviceHistoryManager.generateHistoryContextForAI()
        let weeklyPatterns = adviceHistoryManager.generateWeeklyPatternsForAI()
        
        let advice = await apiClient.analyzeHealth(
            healthData: healthData,
            location: locationData,
            userProfile: userProfile
            // Backend API側でhistoryContextとweeklyPatternsを受け取って
            // Phase 1で準備したプロンプト構造に挿入
        )
        
        // アドバイス受信後、次回のために履歴に保存
        adviceHistoryManager.saveAdvice(advice, healthStatus: currentHealthStatus)
        
        await MainActor.run {
            self.dailyAdvice = advice
            self.loadingState = .loaded
        }
    } catch {
        await MainActor.run {
            self.loadingState = .error(error.localizedDescription)
        }
    }
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

### UI テスト重点項目

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

// ios/TempoAI/TempoAITests/Services/AdviceHistoryManagerTests.swift
class AdviceHistoryManagerTests: XCTestCase {
    func testAdviceHistorySaving()              // アドバイス保存機能
    func testSevenDayHistoryLimit()             // 7日制限機能
    func testHistoryContextGeneration()         // AIコンテキスト生成
    func testWeeklyPatternAnalysis()            // 週次パターン分析
    func testHistoryDataMigration()             // データ移行（Phase 3準備）
}
```

### バックエンド統合テスト

```typescript
// backend/tests/integration/advanced-health.test.ts
describe("Advanced Health Integration", () => {
  it("should integrate check-in data with health analysis");
  it("should calculate personal baselines accurately");
  it("should generate educational explanations");
  it("should correlate environmental and health data");
});
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

### 新規 iOS 実装

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

| Week       | 主要タスク                                             | マイルストーン           |
| ---------- | ------------------------------------------------------ | ------------------------ |
| **Week 1** | 朝のチェックイン機能 + バックエンド統合                | チェックイン完成         |
| **Week 2** | 拡張 HealthKit 連携 + 高度データ分析                   | 詳細ヘルスデータ取得     |
| **Week 3** | 基本文化適応システム（日本食材 DB + 文化適応サービス） | 文化適応機能完成         |
| **Week 4** | 詳細アドバイス画面 + 教育ツールチップ                  | インタラクティブ説明完成 |
| **Week 5** | 環境アラート統合 + 個人基準値比較 + 最終統合テスト     | Phase 2 完成             |

---

## 🎯 成功基準

### 機能完了基準

- [ ] 朝のチェックインが 30 秒以内で完了可能
- [ ] 基本文化適応機能（日本食材 50 種・和食メニュー 15 種・季節対応）実装完了
- [ ] 拡張 HealthKit データ（SpO2・呼吸数・体温）取得・表示
- [ ] 教育ツールチップで全指標の意味と改善方法を説明
- [ ] 環境アラート（気圧・花粉・AQI）が実際の気象と連動
- [ ] 個人基準値との比較が視覚的に理解可能

### 体験品質基準

- [ ] チェックイン完了率: 90%以上（スキップ含む）
- [ ] ツールチップ利用率: 30%以上（初回利用者）
- [ ] アドバイス理解度: 教育的説明により大幅向上
- [ ] 環境アラート有用性: 実際の体調変化との相関確認

### 技術品質基準

- [ ] 新機能 UI テスト網羅率: 90%以上
- [ ] バックエンドテストカバレッジ: 95%以上維持
- [ ] チェックインデータ永続化: 100%信頼性
- [ ] パフォーマンス: 全画面 1 秒以内読み込み

---

## 🔄 Next Phase

Phase 2 完了により、個人の主観とデータを統合した高度なヘルスアドバイザーが完成します。

### Phase 3 への引き継ぎ

- **完成機能**: チェックイン + 文化適応（基本版） + 詳細教育 + 環境統合 + 個人基準値
- **拡張準備**: History タブでの過去データ活用、Trends タブでの長期分析
- **データ蓄積**: 個人のチェックインパターン・健康トレンド・環境反応データ・文化的嗜好データ

---

**🎯 Phase 2 により、Tempo AI は単なるデータ表示から、パーソナライズされた健康教育プラットフォームへと進化します**
