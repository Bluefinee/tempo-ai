# 📊 Phase 3: マルチタブナビゲーション実装計画書

**実施期間**: 4-5週間  
**対象読者**: 開発チーム  
**最終更新**: 2025年12月5日  
**前提条件**: Phase 2 完了（チェックイン + 詳細教育 + 環境統合）

## 🔧 開発実施前の必須確認事項

**実装開始前に必ず以下のドキュメントを確認すること:**

1. **製品全体理解**: [`guidelines/tempo-ai-product-spec.md`](../tempo-ai-product-spec.md) - 製品ビジョン、要件、アーキテクチャ概要を把握
2. **開発ルール**: [`CLAUDE.md`](../../CLAUDE.md) - 開発フロー、品質基準、コミット戦略
3. **Swift開発基準**: [`.claude/swift-coding-standards.md`](../../.claude/swift-coding-standards.md) - iOS開発のベストプラクティス
4. **TypeScript開発基準**: [`.claude/typescript-hono-standards.md`](../../.claude/typescript-hono-standards.md) - API開発の規約

**必須開発手法:**
- **テスト駆動開発 (TDD)**: Red → Green → Blue → Integrate サイクルの徹底
- **カバレッジ目標**: バックエンド 80%以上、iOS 80%以上
- **コミット戦略**: 機能の細かい単位での頻繁なコミット（CI/CDパイプライン連携）

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

Phase 3では、現在プレースホルダー状態のHistory・Trendsタブを完全実装し、強化されたProfileタブと共に、包括的な健康データ管理プラットフォームを構築します。過去データ分析、長期トレンド可視化、編集可能なプロフィール機能により、ユーザーの健康ジャーニー全体をサポートします。

---

## 📊 現状と目標

### Phase 2 完了時の状態
- 高度な Today タブ（チェックイン + 詳細アドバイス）
- 拡張HealthKit連携（SpO2・呼吸数・体温）
- 環境データ統合とアラート
- 個人基準値比較機能

### Phase 3 終了時の目標
- 📅 **完全なHistoryタブ**（過去のアドバイス・体調変化・環境履歴）
- 📈 **高度なTrendsタブ**（30日トレンド・相関分析・パターン認識）
- 👤 **編集可能Profileタブ**（目標設定・アレルギー管理・通知設定）
- 💾 **堅牢なデータ永続化**（ローカル + クラウドバックアップ）
- 🔍 **詳細分析機能**（健康スコア推移・環境影響分析）

---

## 📋 実装タスク

### 1. データ永続化アーキテクチャ構築

#### 1.1 Core Data モデル設計
```swift
// ios/TempoAI/TempoAI/CoreData/TempoAI.xcdatamodeld

// エンティティ: DailyHealthRecord
class DailyHealthRecord: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var healthData: Data          // HealthData JSON
    @NSManaged var checkInData: Data?        // MorningCheckInData JSON
    @NSManaged var environmentData: Data     // EnvironmentData JSON
    @NSManaged var advice: Data              // DailyAdvice JSON
    @NSManaged var userRating: Int16         // アドバイス評価 1-5
    @NSManaged var notes: String?            // ユーザーメモ
}

// エンティティ: UserProfile  
class UserProfile: NSManagedObject {
    @NSManaged var userId: UUID
    @NSManaged var name: String?
    @NSManaged var age: Int16
    @NSManaged var gender: String
    @NSManaged var goals: Data               // [String] JSON
    @NSManaged var allergies: Data?          // [Allergy] JSON
    @NSManaged var medications: Data?        // [Medication] JSON
    @NSManaged var notificationSettings: Data // NotificationSettings JSON
    @NSManaged var barometricSensitivity: String
}

// エンティティ: HealthMetricBaseline
class HealthMetricBaseline: NSManagedObject {
    @NSManaged var metricType: String        // "hrv", "rhr", "sleep"
    @NSManaged var baseline: Double
    @NSManaged var standardDeviation: Double
    @NSManaged var calculatedDate: Date
    @NSManaged var sampleSize: Int16
}
```

#### 1.2 データマネージャー実装
```swift
// ios/TempoAI/TempoAI/Services/DataPersistenceManager.swift
@MainActor
class DataPersistenceManager: ObservableObject {
    private let container: NSPersistentContainer
    private let cloudSync: CloudSyncManager
    
    func saveDailyRecord(
        date: Date,
        healthData: HealthData,
        checkIn: MorningCheckInData?,
        environment: EnvironmentData,
        advice: DailyAdvice
    ) async throws {
        // Core Data + CloudKit 同期保存
    }
    
    func fetchHistoricalData(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [DailyHealthRecord] {
        // 期間指定データ取得
    }
    
    func calculateTrends(
        for metric: HealthMetric,
        period: TrendPeriod
    ) async throws -> TrendData {
        // トレンド計算・統計分析
    }
}

enum HealthMetric {
    case heartRateVariability
    case restingHeartRate
    case sleepDuration
    case sleepEfficiency  
    case stepCount
    case checkInMood
}

enum TrendPeriod {
    case week, month, quarter, year
}
```

### 2. History タブ実装

#### 2.1 HistoryView メイン画面
```swift
// ios/TempoAI/TempoAI/Views/History/HistoryView.swift
struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel
    @State private var selectedDate: Date = Date()
    @State private var viewMode: HistoryViewMode = .timeline
    
    var body: some View {
        NavigationStack {
            VStack {
                // 期間選択 & 表示モード切替
                HistoryControlsView(
                    selectedDate: $selectedDate,
                    viewMode: $viewMode
                )
                
                // メイン表示エリア
                switch viewMode {
                case .timeline:
                    HistoryTimelineView(date: selectedDate)
                case .calendar:
                    HistoryCalendarView(selectedDate: $selectedDate)
                case .search:
                    HistorySearchView()
                }
            }
            .navigationTitle("History")
            .task { await viewModel.loadHistoryData() }
        }
    }
}

enum HistoryViewMode {
    case timeline   // タイムライン表示
    case calendar   // カレンダー表示  
    case search     // 検索・フィルター
}
```

#### 2.2 過去データ詳細表示
```swift
// ios/TempoAI/TempoAI/Views/History/HistoricalAdviceDetailView.swift
struct HistoricalAdviceDetailView: View {
    let record: DailyHealthRecord
    @State private var showingComparison: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // その日のアドバイス再表示
                HistoricalAdviceDisplayView(advice: record.advice)
                
                // その日の体調データ
                HealthDataSummaryView(data: record.healthData)
                
                // 環境データ
                EnvironmentalConditionsView(environment: record.environmentData)
                
                // チェックインデータ（あれば）
                if let checkIn = record.checkInData {
                    CheckInDataDisplayView(checkIn: checkIn)
                }
                
                // ユーザー評価・メモ
                UserFeedbackView(record: record)
                
                // 現在との比較
                if showingComparison {
                    ComparisonWithTodayView(historical: record)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Compare with Today") {
                    showingComparison.toggle()
                }
            }
        }
    }
}
```

### 3. Trends タブ実装

#### 3.1 TrendsView ダッシュボード
```swift
// ios/TempoAI/TempoAI/Views/Trends/TrendsView.swift
struct TrendsView: View {
    @StateObject private var viewModel: TrendsViewModel
    @State private var selectedPeriod: TrendPeriod = .month
    @State private var selectedMetrics: Set<HealthMetric> = [.heartRateVariability, .sleepDuration]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 期間・指標選択
                    TrendControlsView(
                        period: $selectedPeriod,
                        selectedMetrics: $selectedMetrics
                    )
                    
                    // 健康スコア推移
                    OverallHealthScoreTrendView(period: selectedPeriod)
                    
                    // 個別指標トレンド
                    ForEach(Array(selectedMetrics), id: \.self) { metric in
                        MetricTrendCardView(
                            metric: metric,
                            period: selectedPeriod,
                            data: viewModel.getTrendData(for: metric)
                        )
                    }
                    
                    // 相関分析
                    CorrelationAnalysisView(period: selectedPeriod)
                    
                    // 環境影響分析
                    EnvironmentalImpactAnalysisView(period: selectedPeriod)
                }
            }
            .navigationTitle("Trends")
        }
    }
}
```

#### 3.2 高度な分析機能
```swift
// ios/TempoAI/TempoAI/Services/TrendAnalysisService.swift
class TrendAnalysisService {
    
    static func calculateHealthScore(
        healthData: HealthData,
        personalBaselines: PersonalBaselines
    ) -> HealthScore {
        // 複数指標を統合した総合健康スコア算出
        let hrvScore = normalizeToScore(healthData.hrv.average, baseline: personalBaselines.hrv)
        let sleepScore = normalizeToScore(healthData.sleep.efficiency, baseline: personalBaselines.sleep)
        let activityScore = normalizeToScore(healthData.activity.steps, baseline: personalBaselines.activity)
        
        return HealthScore(
            overall: (hrvScore + sleepScore + activityScore) / 3,
            components: HealthScoreComponents(
                recovery: hrvScore,
                sleep: sleepScore,
                activity: activityScore
            )
        )
    }
    
    static func findCorrelations(
        records: [DailyHealthRecord]
    ) -> [HealthCorrelation] {
        // 指標間の相関関係分析
        return [
            analyzeHRVSleepCorrelation(records),
            analyzeWeatherMoodCorrelation(records),
            analyzeExerciseRecoveryCorrelation(records)
        ].compactMap { $0 }
    }
    
    static func identifyPatterns(
        records: [DailyHealthRecord]
    ) -> [HealthPattern] {
        // パターン認識（週末効果、季節変動など）
    }
}

struct HealthCorrelation {
    let metric1: HealthMetric
    let metric2: HealthMetric  
    let correlation: Double           // -1.0 to 1.0
    let significance: Significance    // .weak, .moderate, .strong
    let description: String
}
```

#### 3.3 インタラクティブチャート
```swift
// ios/TempoAI/TempoAI/Views/Trends/Charts/InteractiveHealthChart.swift
import Charts

struct InteractiveHealthChart: View {
    let data: [HealthDataPoint]
    let metric: HealthMetric
    @State private var selectedDataPoint: HealthDataPoint?
    
    var body: some View {
        VStack {
            Chart(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value(metric.displayName, point.value)
                )
                .foregroundStyle(colorForMetric(metric))
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                // 個人基準値ライン
                RuleMark(y: .value("Baseline", personalBaseline))
                    .foregroundStyle(.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                
                // 選択ポイント
                if let selected = selectedDataPoint, selected.id == point.id {
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value(metric.displayName, point.value)
                    )
                    .foregroundStyle(.red)
                    .symbol(.circle)
                    .symbolSize(50)
                }
            }
            .onTapGesture(coordinateSpace: .plotArea) { location in
                // タップ位置からデータポイント選択
                selectedDataPoint = findNearestDataPoint(at: location)
            }
            
            // 選択データ詳細表示
            if let selected = selectedDataPoint {
                DataPointDetailView(point: selected)
            }
        }
    }
}
```

### 4. Profile タブ強化

#### 4.1 編集可能ProfileView
```swift
// ios/TempoAI/TempoAI/Views/Profile/EditableProfileView.swift
struct EditableProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var isEditing: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Basic Information") {
                    EditableProfileRow(
                        title: "Name",
                        value: $viewModel.profile.name,
                        isEditing: isEditing
                    )
                    AgePickerRow(age: $viewModel.profile.age, isEditing: isEditing)
                    GenderPickerRow(gender: $viewModel.profile.gender, isEditing: isEditing)
                }
                
                Section("Health Goals") {
                    HealthGoalsEditorView(
                        goals: $viewModel.profile.goals,
                        isEditing: isEditing
                    )
                }
                
                Section("Medical Information") {
                    AllergiesEditorView(
                        allergies: $viewModel.profile.allergies,
                        isEditing: isEditing
                    )
                    MedicationsEditorView(
                        medications: $viewModel.profile.medications,
                        isEditing: isEditing
                    )
                }
                
                Section("Sensitivity Settings") {
                    BarometricSensitivityPickerView(
                        sensitivity: $viewModel.profile.barometricSensitivity,
                        isEditing: isEditing
                    )
                }
                
                Section("Notifications") {
                    NotificationSettingsView(
                        settings: $viewModel.profile.notificationSettings,
                        isEditing: isEditing
                    )
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            Task { await viewModel.saveProfile() }
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}
```

#### 4.2 ヘルスデータ権限管理
```swift
// ios/TempoAI/TempoAI/Views/Profile/HealthPermissionsView.swift
struct HealthPermissionsView: View {
    @StateObject private var healthKitManager: HealthKitManager
    @State private var permissionStatus: [HKQuantityTypeIdentifier: HKAuthorizationStatus] = [:]
    
    var body: some View {
        List {
            Section("Required Permissions") {
                ForEach(HealthKitPermission.required, id: \.self) { permission in
                    PermissionStatusRow(
                        permission: permission,
                        status: permissionStatus[permission.identifier] ?? .notDetermined
                    )
                }
            }
            
            Section("Optional Permissions") {
                ForEach(HealthKitPermission.optional, id: \.self) { permission in
                    PermissionStatusRow(
                        permission: permission,
                        status: permissionStatus[permission.identifier] ?? .notDetermined
                    )
                }
            }
        }
        .navigationTitle("Health Permissions")
        .task { await refreshPermissionStatus() }
    }
}

enum HealthKitPermission: CaseIterable {
    static let required: [HealthKitPermission] = [.heartRate, .steps, .sleepAnalysis]
    static let optional: [HealthKitPermission] = [.oxygenSaturation, .bodyTemperature, .respiratoryRate]
    
    case heartRate, heartRateVariability, steps, sleepAnalysis
    case oxygenSaturation, bodyTemperature, respiratoryRate
    
    var identifier: HKQuantityTypeIdentifier {
        // HKQuantityTypeIdentifier マッピング
    }
}
```

### 5. バックエンドデータ分析API

#### 5.1 履歴データ分析エンドポイント
```typescript
// backend/src/routes/analysis.ts
export const analysisRoutes = new Hono<{ Bindings: Bindings }>()

// POST /api/analysis/trends
analysisRoutes.post('/trends', async (c) => {
  const request = await c.req.json()
  const { userId, period, metrics } = analysisSchema.parse(request)
  
  const historicalData = await getHistoricalHealthData(userId, period)
  const trends = await calculateTrends(historicalData, metrics)
  const correlations = await findCorrelations(historicalData)
  const patterns = await identifyPatterns(historicalData)
  
  return c.json({
    success: true,
    data: {
      trends,
      correlations,
      patterns,
      insights: generateTrendInsights(trends, correlations)
    }
  })
})

// POST /api/analysis/health-score-history
analysisRoutes.post('/health-score-history', async (c) => {
  const request = await c.req.json()
  const { userId, period } = healthScoreSchema.parse(request)
  
  const records = await getHistoricalRecords(userId, period)
  const scoreHistory = records.map(record => 
    calculateHealthScore(record.healthData, record.personalBaselines)
  )
  
  return c.json({
    success: true,
    data: {
      scoreHistory,
      average: calculateAverage(scoreHistory),
      trend: calculateTrend(scoreHistory),
      insights: generateScoreInsights(scoreHistory)
    }
  })
})
```

#### 5.2 高度分析サービス
```typescript
// backend/src/services/advanced-analytics.ts
export const calculateTrends = async (
  data: HistoricalHealthData[],
  metrics: HealthMetric[]
): Promise<TrendAnalysis[]> => {
  return metrics.map(metric => {
    const values = data.map(d => extractMetricValue(d, metric))
    const trend = calculateLinearTrend(values)
    const seasonality = detectSeasonality(values, data.map(d => d.date))
    const volatility = calculateVolatility(values)
    
    return {
      metric,
      trend: {
        slope: trend.slope,
        direction: trend.slope > 0 ? 'improving' : 'declining',
        confidence: trend.rSquared
      },
      seasonality,
      volatility,
      insights: generateTrendInsights(metric, trend, seasonality)
    }
  })
}

export const findCorrelations = async (
  data: HistoricalHealthData[]
): Promise<CorrelationAnalysis[]> => {
  const metricPairs = generateMetricPairs()
  
  return metricPairs.map(pair => {
    const values1 = data.map(d => extractMetricValue(d, pair.metric1))
    const values2 = data.map(d => extractMetricValue(d, pair.metric2))
    
    const correlation = calculatePearsonCorrelation(values1, values2)
    const significance = assessCorrelationSignificance(correlation, values1.length)
    
    return {
      metric1: pair.metric1,
      metric2: pair.metric2,
      correlation,
      significance,
      insights: generateCorrelationInsights(pair, correlation, significance)
    }
  })
}
```

---

## 🎨 UI/UX 設計詳細

### History タブ ナビゲーション
```swift
// 直感的な期間選択UI
struct HistoryPeriodSelector: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            // 日付ピッカー（カレンダー）
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
            
            Spacer()
            
            // クイック選択ボタン
            QuickDateButtons(selectedDate: $selectedDate)
        }
    }
}

// クイック選択: 今日、昨日、1週間前、1ヶ月前
```

### Trends タブ チャート設計
```swift
// 複数指標同時表示
struct MultiMetricChartView: View {
    let metrics: [HealthMetric]
    let period: TrendPeriod
    
    var body: some View {
        Chart {
            ForEach(metrics, id: \.self) { metric in
                ForEach(dataFor(metric)) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.normalizedValue)
                    )
                    .foregroundStyle(colorFor(metric))
                    .symbol(symbolFor(metric))
                }
            }
        }
        .chartYAxis {
            AxisMarks(preset: .extended, position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: periodStride))
        }
        .chartLegend(position: .bottom)
    }
}
```

### Profile タブ 編集体験
```swift
// インライン編集 vs 専用編集画面の使い分け
enum EditingStyle {
    case inline    // 簡単な値（名前、年齢）
    case modal     // 複雑な値（目標、アレルギー）
    case navigation // リスト形式（薬剤、通知設定）
}

// スムースな保存体験
struct AutoSaveEditingView: View {
    @State private var saveStatus: SaveStatus = .saved
    
    enum SaveStatus {
        case saved, saving, error
    }
}
```

---

## 🧪 テスト戦略

### Core Data テスト
```swift
// ios/TempoAI/TempoAITests/CoreData/DataPersistenceTests.swift
class DataPersistenceTests: XCTestCase {
    func testDailyRecordSaveAndFetch()
    func testLargeDatasetPerformance()           // 1年分データでのパフォーマンス
    func testDataMigration()                     // スキーマ変更時の移行
    func testConcurrentAccess()                  // 同時読み書き
    func testCloudSyncConflictResolution()       // CloudKit競合解決
}
```

### トレンド分析テスト
```swift
// ios/TempoAI/TempoAITests/Analytics/TrendAnalysisTests.swift
class TrendAnalysisTests: XCTestCase {
    func testLinearTrendCalculation()
    func testSeasonalityDetection()
    func testCorrelationAccuracy()
    func testAnomalyDetection()                  // 異常値検出
    func testInsightGeneration()                 // 洞察文生成
}
```

### UIテスト（複雑な相互作用）
```swift
// ios/TempoAI/TempoAIUITests/NavigationUITests.swift
class NavigationUITests: XCTestCase {
    func testHistoryCalendarNavigation()        // カレンダー→詳細画面
    func testTrendsChartInteraction()           // チャートタップ→データ詳細
    func testProfileEditingSaveFlow()           // 編集→保存→確認
    func testTabSwitchingDataPersistence()      // タブ切替時のデータ保持
}
```

### パフォーマンステスト
```swift
// 重要なパフォーマンス目標
class PerformanceTests: XCTestCase {
    func testHistoryLoadingWith1000Records()    // 1000件履歴: 2秒以内
    func testTrendCalculationFor30Days()        // 30日トレンド: 1秒以内
    func testChartRenderingWith100Points()      // 100ポイントチャート: 0.5秒以内
    func testProfileSaveWithLargeData()         // プロフィール保存: 0.5秒以内
}
```

---

## 📦 成果物

### Core Data スキーマ
```
TempoAI.xcdatamodeld
├── DailyHealthRecord.swift        // 日次健康記録
├── UserProfile.swift              // ユーザープロフィール
├── HealthMetricBaseline.swift     // 個人基準値
└── EnvironmentalRecord.swift      // 環境データ記録
```

### 新規iOS実装
```
ios/TempoAI/TempoAI/
├── Views/
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── HistoryTimelineView.swift
│   │   ├── HistoryCalendarView.swift
│   │   ├── HistoricalAdviceDetailView.swift
│   │   └── HistorySearchView.swift
│   ├── Trends/
│   │   ├── TrendsView.swift
│   │   ├── MetricTrendCardView.swift
│   │   ├── OverallHealthScoreTrendView.swift
│   │   ├── CorrelationAnalysisView.swift
│   │   └── Charts/
│   │       ├── InteractiveHealthChart.swift
│   │       ├── MultiMetricChartView.swift
│   │       └── CorrelationHeatmapView.swift
│   └── Profile/
│       ├── EditableProfileView.swift
│       ├── HealthPermissionsView.swift
│       ├── GoalsEditorView.swift
│       └── NotificationSettingsView.swift
├── ViewModels/
│   ├── HistoryViewModel.swift
│   ├── TrendsViewModel.swift
│   └── ProfileViewModel.swift
├── Services/
│   ├── DataPersistenceManager.swift
│   ├── TrendAnalysisService.swift
│   ├── CloudSyncManager.swift
│   └── HealthScoreCalculator.swift
└── CoreData/
    ├── TempoAI.xcdatamodeld
    ├── CoreDataStack.swift
    └── ManagedObjectExtensions.swift
```

### バックエンド分析API
```
backend/src/
├── routes/
│   └── analysis.ts                   // 分析API endpoints
├── services/
│   ├── advanced-analytics.ts         // 高度分析
│   ├── trend-calculation.ts          // トレンド計算
│   ├── correlation-analysis.ts       // 相関分析
│   └── pattern-recognition.ts        // パターン認識
└── types/
    ├── analytics.ts
    ├── trends.ts
    └── patterns.ts
```

---

## ⏱️ スケジュール

| Week | 主要タスク | マイルストーン |
|------|------------|----------------|
| **Week 1** | Core Data設計 + DataPersistenceManager | データ永続化基盤完成 |
| **Week 2** | History タブ完全実装 + 履歴表示 | 過去データ閲覧可能 |
| **Week 3** | Trends タブ + チャート実装 + 分析機能 | トレンド可視化完成 |
| **Week 4** | Profile タブ編集機能 + バックエンド分析API | 包括的プロフィール管理 |
| **Week 5** | 統合テスト + パフォーマンス最適化 + Phase 4準備 | Phase 3完成 |

---

## 🎯 成功基準

### 機能完了基準
- [ ] 過去30日間の履歴データが詳細に閲覧可能
- [ ] 5つ以上のヘルス指標でトレンド分析が動作
- [ ] プロフィール情報が完全に編集可能（目標・アレルギー・通知設定）
- [ ] 健康スコアの30日推移が視覚化
- [ ] 指標間の相関関係が統計的に分析・表示

### データ・分析品質基準
- [ ] 1000件履歴データの読み込み: 2秒以内
- [ ] トレンド計算精度: 統計的有意性確保
- [ ] Core Data + CloudKit同期: 99%信頼性
- [ ] 相関分析: ピアソン相関係数正確計算

### ユーザビリティ基準
- [ ] History検索機能: 目的データに30秒以内到達
- [ ] Trendsチャート操作: 直感的なタップ・ズーム操作
- [ ] Profile編集: 全項目編集に3分以内
- [ ] タブ間ナビゲーション: 即座の切り替え（200ms以内）

---

## 🔄 Next Phase

Phase 3 完了により、包括的なヘルスデータ管理プラットフォームが完成します。

### Phase 4への引き継ぎ
- **完成インフラ**: 堅牢なデータ永続化 + 高度分析 + 完全ナビゲーション
- **蓄積データ**: 豊富な履歴・トレンド・相関データ
- **準備事項**: 教育システム実装の基盤（Learn タブ）、個人インサイト深化

---

**📈 Phase 3により、Tempo AIは単発のアドバイスアプリから、長期的な健康ジャーニーをサポートする包括的プラットフォームへと進化します**