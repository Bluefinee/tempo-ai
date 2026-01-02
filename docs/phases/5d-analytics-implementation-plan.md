# Phase 5d: Analytics画面 実装計画書

## 概要
期間別スコアトレンド、リズム一貫性、インサイトを表示するAnalytics画面を実装する。

## 参照ドキュメント
- [PHASE_5D_SPEC.md](../../PHASE_5D_SPEC.md) - 機能仕様書
- [product-spec.md](../specs/product-spec.md) - プロダクト仕様
- [ui-spec.md](../specs/ui-spec.md) - UIデザイン仕様
- [swift-coding-standards.md](../../.claude/swift-coding-standards.md) - コーディング規約

---

## 作成ファイル一覧

```
ios/TempoAI/TempoAI/Features/Analytics/
├── AnalyticsView.swift
├── AnalyticsViewModel.swift
└── Components/
    ├── PeriodSelector.swift
    ├── ScoreTrendsChart.swift
    ├── RhythmConsistencyCard.swift
    └── InsightsCard.swift

ios/TempoAI/TempoAI/Domain/Models/
├── TimePeriod.swift          # 新規
├── DailyScoreSnapshot.swift  # 新規
└── AnalyticsError.swift      # 新規

ios/TempoAI/TempoAITests/Features/Analytics/
└── AnalyticsViewModelTests.swift
```

## 修正ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `Domain/Models/RhythmAnalysis.swift` | `ConsistencyStatus` enum追加、`bedtimeConsistencyStatus`/`wakeTimeConsistencyStatus` computed properties追加 |
| `Shared/Design/Colors.swift` | `good`/`fair`/`poor`色定数追加、`consistencyColor(for:)`関数追加 |
| `Infrastructure/HealthKit/HealthKitRepositoryProtocol.swift` | `fetchDailyMetrics(days:)`メソッド追加 |
| `Infrastructure/HealthKit/HealthKitRepository.swift` | `fetchDailyMetrics(days:)`実装追加 |
| `Infrastructure/HealthKit/HealthKitManager.swift` | `fetchDailyMetrics(days:)`メソッド追加 |

---

## 実装ステージ

### Stage 1: ドメインモデル（テスト先行）

**Status**: [x] Complete

#### 1.1 TimePeriod.swift
```swift
enum TimePeriod: String, CaseIterable, Codable, Sendable {
    case weekly = "週間"
    case monthly = "月間"
    var days: Int  // 7 or 30
    var displayName: String { rawValue }
}
```

#### 1.2 DailyScoreSnapshot.swift
```swift
struct DailyScoreSnapshot: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let autonomicScore: Int  // 0-100 clamped
    let sleepScore: Int
    let rhythmScore: Int
    let activityScore: Int
}
```

#### 1.3 AnalyticsError.swift
```swift
enum AnalyticsError: LocalizedError, Equatable, Sendable {
    case dataLoadFailed
    case insufficientData
    case calculationError
    var errorDescription: String?
}
```

#### 1.4 RhythmAnalysis拡張
```swift
// RhythmAnalysis.swift に追加
enum ConsistencyStatus: String, Codable, Sendable {
    case stable = "安定"        // ≤30分
    case recovering = "回復中"   // 30-45分
    case unstable = "乱れ気味"   // >45分
}

var bedtimeConsistencyStatus: ConsistencyStatus
var wakeTimeConsistencyStatus: ConsistencyStatus
```

#### 1.5 TempoColors拡張
```swift
// Colors.swift に追加
static let good: Color = primary      // 安定
static let fair: Color = warning      // 回復中
static let poor: Color = caution      // 乱れ気味
static func consistencyColor(for status: ConsistencyStatus) -> Color
```

**完了条件**:
- [x] 全モデルのテストがパス
- [x] SwiftLint警告なし

---

### Stage 2: HealthKit拡張

**Status**: [x] Complete

#### 2.1 HealthKitRepositoryProtocol追加
```swift
func fetchDailyMetrics(days: Int) async throws -> [HealthMetrics]
```

#### 2.2 HealthKitRepository実装
過去N日間の日別HealthMetricsを取得するロジック

#### 2.3 HealthKitManager追加
```swift
func fetchDailyMetrics(days: Int = 7) async -> [HealthMetrics]
```

**完了条件**:
- [x] プロトコルメソッド追加
- [x] 実装追加
- [x] Mockも更新

---

### Stage 3: AnalyticsViewModel（テスト先行）

**Status**: [x] Complete

```swift
@MainActor
final class AnalyticsViewModel: ObservableObject {
    // Published
    @Published var selectedPeriod: TimePeriod = .weekly
    @Published var scoreSnapshots: [DailyScoreSnapshot] = []
    @Published var rhythmAnalysis: RhythmAnalysis?
    @Published var insights: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: AnalyticsError?
    @Published var isCalibrating: Bool = false

    // Dependencies (DI)
    private let healthKitManager: HealthKitManager
    private let scoreCalculator: ScoreCalculator
    private let localStorage: LocalStorage

    // Methods
    func loadAnalyticsData() async
    func changePeriod(_ period: TimePeriod) async
    private func generateInsights()
}
```

**テストケース**:
- [x] 初期状態: selectedPeriodはweekly
- [x] 初期状態: isLoadingはfalse
- [x] 初期状態: errorはnil
- [x] loadAnalyticsData: isLoadingが正しく切り替わる
- [x] loadAnalyticsData: キャリブレーション未完了時はisCalibratingがtrue
- [x] loadAnalyticsData: キャリブレーション完了時はisCalibratingがfalse
- [x] loadAnalyticsData: データ取得成功時にscoreSnapshotsが設定される
- [x] loadAnalyticsData: データ取得失敗時にerrorが設定される
- [x] changePeriod: 期間変更後にloadAnalyticsDataが呼ばれる
- [x] generateInsights: スコアパターンからインサイトを生成

**完了条件**:
- [x] 全テストがパス
- [x] SwiftLint警告なし

---

### Stage 4: UIコンポーネント

**Status**: [x] Complete

#### 4.1 PeriodSelector.swift
- Picker (segmented style)
- TimePeriod Binding
- accessibilityLabel

#### 4.2 ScoreTrendsChart.swift
- iOS 16+ Charts使用
- 4本のLineMark:
  - 自律神経: TempoColors.primary (#7CB342)
  - 睡眠: Color.blue
  - リズム: Color.orange
  - 活動量: Color.purple
- chartYScale(domain: 0...100)
- @State selectedSnapshot（タップ選択）
- accessibilityLabel("過去X日間のスコア推移グラフ")

#### 4.3 RhythmConsistencyCard.swift
- CardView使用
- 3行: 就寝ばらつき / 起床ばらつき / 連続安定日数
- ConsistencyStatusバッジ（色付き）
- アクセシビリティ対応

#### 4.4 InsightsCard.swift
- CardView使用
- ForEach(insights) { 💡 + テキスト }
- アクセシビリティ対応

**完了条件**:
- [x] Previewで各コンポーネント表示確認
- [x] アクセシビリティラベル設定済み

---

### Stage 5: AnalyticsView

**Status**: [x] Complete

```swift
struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel

    var body: some View {
        ScrollView {
            if viewModel.isCalibrating {
                CalibrationProgressView(...)
            } else {
                VStack(spacing: TempoSpacing.lg) {
                    PeriodSelector(...)
                    ScoreTrendsChart(...)
                    RhythmConsistencyCard(...)
                    InsightsCard(...)
                }
            }
        }
        .overlay { if viewModel.isLoading { LoadingView() } }
        .alert(item: $viewModel.error) { ... }
        .task { await viewModel.loadAnalyticsData() }
    }
}
```

**完了条件**:
- [x] 全コンポーネント統合
- [x] キャリブレーション表示動作
- [x] エラー表示動作
- [x] ローディング表示動作

---

## 最終UIレビューチェックリスト

**レビュー実施日**: 2026-01-02

実装完了後、以下の項目を確認する:

### レイアウト確認
- [x] 画面全体のスペーシングがTempoSpacingに準拠している
- [x] カード間の余白が統一されている（TempoSpacing.lg = 20pt）
- [x] 画面端のパディングがscreenPadding（16pt）になっている
- [x] スクロール時に要素が重ならない
- [x] グラフの高さが適切（200pt）

### 文言確認
- [x] 期間セレクター: 「週間」「月間」
- [x] リズム一貫性カード見出し: 「リズムの一貫性」
- [x] ばらつき表示: 「就寝時刻のばらつき」「起床時刻のばらつき」
- [x] 連続安定日数: 「連続安定日数」
- [x] ステータスバッジ: 「安定」「回復中」「乱れ気味」
- [x] インサイトカード見出し: 「インサイト」
- [x] キャリブレーション中メッセージ: 仕様書と一致

### デザイン確認
- [x] カラー: TempoColors準拠
  - Primary Green (#7CB342) がメインカラー
  - ステータス色が正しく適用（good/fair/poor）
- [x] タイポグラフィ: TempoTypography準拠
  - 見出し: headline
  - 本文: body
  - キャプション: caption
- [x] グラフの4色が区別しやすい（primary/blue/orange/purple）
- [x] カードの角丸が統一（16pt）
- [x] 背景色がTempoColors.background

### アクセシビリティ確認
- [x] VoiceOverで全要素にアクセス可能
- [x] グラフに説明ラベルあり（"過去X日間のスコア推移グラフ"）
- [x] ステータスバッジが読み上げられる
- [x] Dynamic Type対応（フォントサイズ変更時）
- [x] 最小タップエリア44x44px確保

### インタラクション確認
- [x] 期間切り替えがスムーズ
- [x] グラフタップで詳細表示
- [x] ローディング表示が適切（SimpleLoadingView使用）
- [x] エラー表示が適切（Alert使用）

### 境界ケース確認
- [x] データなし時の表示（insufficientDataエラー）
- [x] キャリブレーション期間中の表示（AnalyticsCalibrationView）
- [x] 1日分のデータしかない場合のグラフ（LineMark対応済み）
- [x] インサイトが0件の場合（EmptyInsightsView表示）

---

## 重要な既存ファイルパス

| 用途 | パス |
|------|------|
| RhythmAnalysis | `ios/TempoAI/TempoAI/Domain/Models/RhythmAnalysis.swift` |
| TempoColors | `ios/TempoAI/TempoAI/Shared/Design/Colors.swift` |
| CardView | `ios/TempoAI/TempoAI/Shared/Components/CardView.swift` |
| HealthKitManager | `ios/TempoAI/TempoAI/Infrastructure/HealthKit/HealthKitManager.swift` |
| HealthKitRepository | `ios/TempoAI/TempoAI/Infrastructure/HealthKit/HealthKitRepository.swift` |
| HealthKitRepositoryProtocol | `ios/TempoAI/TempoAI/Infrastructure/HealthKit/HealthKitRepositoryProtocol.swift` |
| ScoreCalculator | `ios/TempoAI/TempoAI/Domain/Services/ScoreCalculator.swift` |
| LocalStorage | `ios/TempoAI/TempoAI/Infrastructure/Storage/LocalStorage.swift` |
| CalibrationState | `ios/TempoAI/TempoAI/Domain/Models/UserProfile.swift` |

---

## 成功基準（PHASE_5D_SPEC.mdより）

- [x] 週間/月間の切り替えが動作
- [x] グラフが正しく描画される（4ライン）
- [x] リズム一貫性データが表示される
- [x] インサイトが表示される
- [x] キャリブレーション期間中は適切なメッセージ表示
- [x] 全テストがパスする
- [x] VoiceOver対応完了
- [x] Dynamic Type対応完了

---

## 実装完了サマリー

**実装完了日**: 2026-01-02

### 作成されたファイル

| ファイル | 行数 | 説明 |
|---------|------|------|
| `TimePeriod.swift` | ~25 | 期間選択用enum |
| `DailyScoreSnapshot.swift` | ~35 | 日別スコアデータモデル |
| `AnalyticsError.swift` | ~30 | エラー型定義 |
| `AnalyticsViewModel.swift` | ~285 | 状態管理ViewModel |
| `PeriodSelector.swift` | ~45 | 期間セレクター |
| `ScoreTrendsChart.swift` | ~260 | スコア推移グラフ |
| `RhythmConsistencyCard.swift` | ~160 | リズム一貫性カード |
| `InsightsCard.swift` | ~105 | インサイトカード |
| `AnalyticsView.swift` | ~185 | メインView |

### 修正されたファイル

| ファイル | 変更内容 |
|---------|---------|
| `RhythmAnalysis.swift` | ConsistencyStatus enum、computed properties追加 |
| `Colors.swift` | good/fair/poor色、consistencyColor関数追加 |
| `HealthKitRepositoryProtocol.swift` | fetchDailyMetricsメソッド追加 |
| `HealthKitRepository+Queries.swift` | fetchDailyMetrics実装 |
| `HealthKitManager.swift` | fetchDailyMetricsラッパー、Mock更新 |

### 特記事項

- 既存の `CalibrationProgressView` との名前衝突を回避するため、`AnalyticsCalibrationView` として実装
- 既存の `SimpleLoadingView` を再利用（Labor Illusion対応版）
- iOS 16+ Charts フレームワーク使用
