# Phase 5d: Analytics画面 実装仕様書

## 概要
期間別スコアトレンド、リズム一貫性、インサイトを表示するAnalytics画面を実装します。

## 必読ドキュメント
実装前に必ず以下を確認してください：
- CLAUDE.md - 開発規約・原則
- .claude/swift-coding-standards.md - Swiftコーディング規約
- .claude/ux_concepts.md - UXデザイン原則
- docs/specs/product-spec.md - プロダクト仕様（Section 2.5 Analytics画面）
- docs/specs/ui-spec.md - UIデザイン仕様
- docs/specs/metrics-spec.md - スコア算出アルゴリズム

## ブランチ
`feature/phase-5d-analytics`

## 作成ファイル構成
```
ios/TempoAI/TempoAI/Features/Analytics/
├── AnalyticsView.swift            # メイン画面
├── AnalyticsViewModel.swift       # 状態管理
└── Components/
    ├── PeriodSelector.swift       # 期間セレクター
    ├── ScoreTrendsChart.swift     # スコアトレンドグラフ
    ├── RhythmConsistencyCard.swift # リズム一貫性
    └── InsightsCard.swift         # AIインサイト

ios/TempoAI/TempoAITests/Features/Analytics/
└── AnalyticsViewModelTests.swift
```

## Analytics画面の構成

```
┌─────────────────────────────────────────┐
│ 期間: [週間 ▼] [月間]                    │ ← PeriodSelector
├─────────────────────────────────────────┤
│ [A] Score Trends                        │
│ ┌─────────────────────────────────────┐ │
│ │ 📈 4スコアの折れ線グラフ            │ │
│ │    ♡自律神経 / ☽睡眠 / ◎リズム / 🏃活動 │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ [B] Rhythm Consistency                  │
│ ┌─────────────────────────────────────┐ │
│ │ 就寝時刻のばらつき: 25分（安定）    │ │
│ │ 起床時刻のばらつき: 20分（安定）    │ │
│ │ 連続安定日数: 5日                   │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ [C] Insights                            │
│ ┌─────────────────────────────────────┐ │
│ │ 💡 睡眠7時間以上の日はスコア+10pt   │ │
│ │ 💡 23時前就寝で深い睡眠+20%         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 各コンポーネントの詳細仕様

### PeriodSelector
- **タイプ**: セグメントコントロール
- **選択肢**:
  - 週間 (.weekly): 過去7日
  - 月間 (.monthly): 過去30日
- **デフォルト**: 週間

```swift
enum TimePeriod: String, CaseIterable, Codable {
    case weekly = "週間"
    case monthly = "月間"

    var days: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30
        }
    }

    var displayName: String { rawValue }
}
```

### ScoreTrendsChart（SwiftUI Charts使用）
- **横軸**: 日付
- **縦軸**: スコア値（0-100）
- **4本のライン**:
  - 自律神経スコア: Primary Color (#7CB342) - TempoColors.primary
  - 睡眠スコア: Blue系 - Color.blue
  - リズムスコア: Orange系 - Color.orange
  - 活動量スコア: Purple系 - Color.purple
- **インタラクション**: タップで詳細値表示
- **iOS 16+ Charts フレームワーク使用**

```swift
import Charts

struct DailyScoreSnapshot: Identifiable, Codable {
    let id: UUID
    let date: Date
    let autonomicScore: Int
    let sleepScore: Int
    let rhythmScore: Int
    let activityScore: Int

    init(date: Date, autonomicScore: Int, sleepScore: Int, rhythmScore: Int, activityScore: Int) {
        self.id = UUID()
        self.date = date
        self.autonomicScore = autonomicScore
        self.sleepScore = sleepScore
        self.rhythmScore = rhythmScore
        self.activityScore = activityScore
    }
}

struct ScoreTrendsChart: View {
    let snapshots: [DailyScoreSnapshot]
    @State private var selectedSnapshot: DailyScoreSnapshot?

    var body: some View {
        Chart {
            ForEach(snapshots) { snapshot in
                // 4本のラインを描画
                LineMark(x: .value("日付", snapshot.date),
                         y: .value("スコア", snapshot.autonomicScore))
                    .foregroundStyle(TempoColors.primary)
                    .symbol(.circle)
                // ... 他の3本のライン
            }
        }
        .chartYScale(domain: 0...100)
        .frame(height: 200)
    }
}
```

### RhythmConsistencyCard
- **表示内容**:
  - 就寝時刻の標準偏差（分）+ ステータスバッジ
  - 起床時刻の標準偏差（分）+ ステータスバッジ
  - 連続安定日数
- **ステータスバッジ色**:
  - 安定（≤30分）: Green - TempoColors.good
  - 回復中（30-45分）: Yellow - TempoColors.fair
  - 乱れ気味（>45分）: Orange - TempoColors.poor

```swift
struct RhythmConsistencyCard: View {
    let rhythmAnalysis: RhythmAnalysis

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                Text("リズムの一貫性")
                    .font(TempoTypography.headline)

                // 就寝時刻のばらつき
                ConsistencyRow(
                    label: "就寝時刻のばらつき",
                    value: "\(Int(rhythmAnalysis.bedtimeStddevMinutes))分",
                    status: rhythmAnalysis.bedtimeConsistencyStatus
                )

                // 起床時刻のばらつき
                ConsistencyRow(
                    label: "起床時刻のばらつき",
                    value: "\(Int(rhythmAnalysis.wakeTimeStddevMinutes))分",
                    status: rhythmAnalysis.wakeTimeConsistencyStatus
                )

                // 連続安定日数
                HStack {
                    Text("連続安定日数")
                    Spacer()
                    Text("\(rhythmAnalysis.consecutiveStableDays)日")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
```

### InsightsCard
- **表示**: 3-5個のインサイト
- **フォーマット**: 💡 + テキスト
- **例**:
  - 「睡眠7時間以上の日はスコア+10pt」
  - 「23時前就寝で深い睡眠+20%」
  - 「水曜日は自律神経スコアが低下傾向」

```swift
struct InsightsCard: View {
    let insights: [String]

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                Text("インサイト")
                    .font(TempoTypography.headline)

                ForEach(insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: TempoSpacing.sm) {
                        Text("💡")
                        Text(insight)
                            .font(TempoTypography.body)
                    }
                }
            }
        }
    }
}
```

## AnalyticsViewModel実装
```swift
@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .weekly
    @Published var scoreSnapshots: [DailyScoreSnapshot] = []
    @Published var rhythmAnalysis: RhythmAnalysis?
    @Published var insights: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: AnalyticsError? = nil
    @Published var isCalibrating: Bool = false

    private let scoreCalculator: ScoreCalculatorProtocol
    private let healthKitManager: HealthKitManagerProtocol
    private let localStorage: LocalStorageProtocol

    func loadAnalyticsData() async {
        isLoading = true
        defer { isLoading = false }

        // 1. キャリブレーション状態を確認
        if let calibrationState: CalibrationState = localStorage.load(forKey: StorageKeys.calibrationState) {
            isCalibrating = !calibrationState.isComplete
        }

        // 2. 期間に応じたデータを取得
        let days = selectedPeriod.days
        // HealthKitからデータ取得 → スコア計算 → スナップショット作成

        // 3. リズム分析データを取得
        // RhythmScoreCalculatorからデータ取得

        // 4. インサイトを生成
        generateInsights()
    }

    func changePeriod(_ period: TimePeriod) async {
        selectedPeriod = period
        await loadAnalyticsData()
    }

    private func generateInsights() {
        // スコアデータからパターンを分析してインサイトを生成
        insights = []

        // 例: 睡眠時間とスコアの相関
        // 例: 就寝時刻とスコアの相関
        // 例: 曜日別のパターン
    }
}
```

## 使用する既存コンポーネント
- `CardView` - カード表示（Shared/Components/）
- `TempoColors`, `TempoTypography`, `TempoSpacing` - デザイン定数（Shared/Design/）

## 使用する既存モデル・サービス
- `Score` - スコア値オブジェクト（Domain/Models/）
- `RhythmAnalysis` - リズム分析（Domain/Models/）
- `ConditionAssessment` - 状態評価（Domain/Models/）
- `CalibrationState` - キャリブレーション状態（Domain/Models/）
- `ScoreCalculator` - スコア計算（Domain/Services/）
- `RhythmScoreCalculator` - リズムスコア計算（Domain/Services/）
- `HealthKitManager` - HealthKitデータ取得（Infrastructure/HealthKit/）
- `LocalStorage` - データ取得（Infrastructure/Storage/）

## デザインシステム使用例

### カラー
```swift
.foregroundStyle(TempoColors.primary)        // Soft Sage Green
.background(TempoColors.cardBackground)      // Warm Beige

// ステータス色
TempoColors.good    // 安定
TempoColors.fair    // 回復中
TempoColors.poor    // 乱れ気味
```

### スペーシング
```swift
.padding(TempoSpacing.screenPadding)         // 16pt screen padding
VStack(spacing: TempoSpacing.lg)             // 20pt spacing
```

### タイポグラフィ
```swift
.font(TempoTypography.title2)                // 22pt Bold
.font(TempoTypography.headline)              // 17pt Semibold
.font(TempoTypography.body)                  // 17pt Regular
```

## キャリブレーション期間対応

**キャリブレーション期間中の表示:**
```
┌─────────────────────────────────────────┐
│ 🔄 データを収集中...                     │
│                                         │
│ まだ十分なデータがありません。           │
│ 7日間のデータが蓄積されると、            │
│ 詳細な分析をご覧いただけます。           │
│                                         │
│ 現在: X/7日 完了                        │
└─────────────────────────────────────────┘
```

## アクセシビリティ対応
- グラフにaccessibilityLabelを設定（「過去7日間のスコア推移グラフ」等）
- ステータスバッジを読み上げ（「安定」「回復中」「乱れ気味」）
- 数値は単位付きで読み上げ（「25分」「5日」）
- Dynamic Type対応（システムフォントを使用）

## エラーハンドリング
```swift
enum AnalyticsError: LocalizedError {
    case dataLoadFailed
    case insufficientData
    case calculationError

    var errorDescription: String? { ... }
}
```

## 成功基準
- [ ] 週間/月間の切り替えが動作
- [ ] グラフが正しく描画される（4ライン）
- [ ] リズム一貫性データが表示される
- [ ] インサイトが表示される
- [ ] キャリブレーション期間中は適切なメッセージ表示
- [ ] 全テストがパスする
- [ ] VoiceOver対応完了
- [ ] Dynamic Type対応完了

## PR作成時のチェックリスト
- [ ] 全テストがパス（Xcode ⌘+U）
- [ ] SwiftLint警告なし
- [ ] VoiceOver確認
- [ ] Dynamic Type確認
- [ ] 実機での動作確認

## 実装開始の指示
このファイルを読んだ後、以下のコマンドでClaude Codeに実装を開始させてください：

```
PHASE_5D_SPEC.mdを読みました。この仕様に従って、Phase 5dのAnalytics画面の実装を開始してください。
まずCLAUDE.mdと必読ドキュメントを確認し、既存のコンポーネント・サービスの構造を理解した上で、
TDD（テスト駆動開発）で実装を進めてください。
```
