# Phase 5c: Home画面 + AI Insight詳細 実装仕様書

## 概要
6セクション構成のHome画面とAI Insight詳細画面を実装します。

## 必読ドキュメント
実装前に必ず以下を確認してください：
- CLAUDE.md - 開発規約・原則
- .claude/swift-coding-standards.md - Swiftコーディング規約
- .claude/ux_concepts.md - UXデザイン原則（Labor Illusion, Progressive Disclosure等）
- docs/specs/product-spec.md - プロダクト仕様（Section 2.4 Home画面）
- docs/specs/ui-spec.md - UIデザイン仕様
- docs/specs/ai-prompt-spec.md - AI Insight仕様

## ブランチ
`feature/phase-5c-home`

## 作成ファイル構成
```
ios/TempoAI/TempoAI/Features/
├── Home/
│   ├── HomeView.swift                 # メイン画面
│   ├── HomeViewModel.swift            # 状態管理
│   └── Components/
│       ├── AIDailyInsightCard.swift   # [A] AI Insight要約
│       ├── MorningCheckInSection.swift # [B] 気分 + 今日のモード
│       ├── ScoresSection.swift        # [C] 3スコア表示
│       ├── CircadianClockView.swift   # [D] 24時間サークル
│       ├── EnvironmentCard.swift      # [E] 気象情報
│       └── QuickActionCard.swift      # [F] 即時アクション
├── Insight/
│   ├── InsightDetailView.swift        # AI Insight詳細画面
│   └── InsightFeedbackView.swift      # フィードバックUI

ios/TempoAI/TempoAITests/Features/Home/
├── HomeViewModelTests.swift
└── CircadianClockViewTests.swift
```

## Home画面の6セクション構成

```
┌─────────────────────────────────────────┐
│ [A] AI Daily Insight                    │ ← 要約（100-150文字）+ 「続きを読む」
├─────────────────────────────────────────┤
│ [B] Morning Check-in                    │ ← 気分(5段階) + 今日のモード(3択)
├─────────────────────────────────────────┤
│ [C] Scores（3スコア横並び）               │ ← ♡自律神経 / ☽睡眠 / ◎リズム
├─────────────────────────────────────────┤
│ [D] Circadian Clock                     │ ← 24時間サークル（🔥活動/☽休息）
├─────────────────────────────────────────┤
│ [E] Environment  │ [F] Quick Action     │ ← 気象 / 即時アクション
└─────────────────────────────────────────┘
```

## 各セクションの詳細仕様

### [A] AI Daily Insight
- **表示**: ニックネーム + 挨拶 + 要約（100-150文字）
- **CTA**: 「続きを読む」ボタン → InsightDetailViewへ遷移
- **ローディング**: Labor Illusion対応（4ステップ）
  1. 「睡眠データを解析中...」
  2. 「自律神経バランスを計算中...」
  3. 「今日の環境を確認中...」
  4. 「あなたへのアドバイスを作成中...」

### [B] Morning Check-in
- **気分（Mood）**: 5段階モノクロ顔文字
  - 1: (´･_･`) とても悪い
  - 2: (._.) 悪い
  - 3: (-_-) 普通
  - 4: (･ω･) 良い
  - 5: (^_^) とても良い
- **今日のモード（TodayMode）**: 3択カプセルボタン
  - 通常: 普通の1日
  - 頑張る日: 重要な予定あり
  - 休日: リラックス優先
- 既存の`MorningCheckInCard`コンポーネントを活用

### [C] Scores（3スコア横並び）
- 自律神経スコア: ♡ アイコン（heart SF Symbol）
- 睡眠スコア: ☽ アイコン（moon SF Symbol）
- リズムスコア: ◎ アイコン（circle.circle SF Symbol）
- **キャリブレーション期間中**: 数値の代わりに「---」表示
- 既存の`ScoreCard`コンポーネントを活用

### [D] Circadian Clock（リッチ実装）
```
24時間サークル表示:
        ┌─────────────────┐
       / 22    24    2   \
      │  🔥活動  ●   ☽休息 │
       \ 18          6  /
        └─────────────────┘
```
- **構成要素**:
  - 24時間サークル（Canvas描画）
  - 🔥 活動ゾーン（交感神経優位時間帯）
  - ☽ 休息ゾーン（副交感神経優位時間帯）
  - ● 現在時刻マーク（アニメーション）
- **パーソナライズ**: ユーザーのクロノタイプに応じてゾーン調整
  - 朝型: 活動ゾーン 6:00-18:00
  - 中間型: 活動ゾーン 8:00-20:00
  - 夜型: 活動ゾーン 10:00-22:00

### [E] Environment
- 気温、気圧（傾向: ↑↓→）、UV指数
- データソース: WeatherAPIClient

### [F] Quick Action
- スコア・AI提案に基づく即時アクション
- 例: 「1分間の深呼吸」「朝の光リマインダー」

## キャリブレーション期間対応

**初期7日間の表示:**
```
┌─────────────────────────────────────────┐
│ 🔄 あなたのリズムを学習中...            │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 5/7日   │
│ あと2日でパーソナライズされた            │
│ スコアをお届けできます                   │
└─────────────────────────────────────────┘
```
- スコア: 「---」表示（数値なし）
- AIコメント: スコア言及なし、コメント主体

## AI Insight詳細画面（InsightDetailView）

```
┌─────────────────────────────────────────┐
│ ← [Back]               Today's Insight  │
├─────────────────────────────────────────┤
│ マサさん、おはようございます。          │
│                                         │
│ 📊 今日のコンディション (2-3文)         │
│ ☽ 睡眠分析 (3-4文)                      │
│ ◎ リズム分析 (2-3文)                    │
│ ☁ 環境影響 (2-3文)                      │
│ 💡 今日の過ごし方 (3-4文)               │
│                                         │
│ 今日も良い1日になりますように。         │
├─────────────────────────────────────────┤
│ このアドバイスは役立ちましたか？         │
│        👍 はい    👎 いいえ             │
└─────────────────────────────────────────┘
```

## HomeViewModel実装
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var dailyAdvice: DailyAdvice?
    @Published var conditionAssessment: ConditionAssessment?
    @Published var calibrationState: CalibrationState?
    @Published var userProfile: UserProfile?
    @Published var mood: Mood?
    @Published var todayMode: TodayMode?
    @Published var weather: WeatherData?
    @Published var isLoading: Bool = false
    @Published var loadingStep: Int = 0  // Labor Illusion用（0-4）
    @Published var error: HomeError? = nil

    private let adviceAPIClient: AdviceAPIClientProtocol
    private let scoreCalculator: ScoreCalculatorProtocol
    private let weatherAPIClient: WeatherAPIClientProtocol
    private let localStorage: LocalStorageProtocol
    private let healthKitManager: HealthKitManagerProtocol

    // Labor Illusion用のステップメッセージ
    static let loadingSteps: [String] = [
        "睡眠データを解析中...",
        "自律神経バランスを計算中...",
        "今日の環境を確認中...",
        "あなたへのアドバイスを作成中..."
    ]

    func loadDashboardData() async
    func submitMorningCheckIn() async
    func submitFeedback(_ isHelpful: Bool) async
    func refreshData() async
}
```

## 使用する既存コンポーネント
- `CardView` - カード表示（Shared/Components/）
- `ScoreCard` / `ScoreGauge` - スコア表示（Shared/Components/）
- `MoodSelector` / `TodayModeSelector` / `MorningCheckInCard` - チェックイン（Shared/Components/）
- `LoadingView` - ローディング（Labor Illusion）（Shared/Components/）
- `PrimaryButton` / `SecondaryButton` - ボタン（Shared/Components/）
- `TempoColors`, `TempoTypography`, `TempoSpacing` - デザイン定数（Shared/Design/）

## 使用する既存サービス・モデル
- `AdviceAPIClient` - AI Insight取得（Infrastructure/API/）
- `ScoreCalculator` - スコア計算（Domain/Services/）
- `WeatherAPIClient` - 気象データ取得（Infrastructure/API/）
- `LocalStorage` - CalibrationState, UserProfile読み込み（Infrastructure/Storage/）
- `HealthKitManager` - HealthKitデータ取得（Infrastructure/HealthKit/）
- `DailyAdvice` - AIアドバイスモデル（Domain/Models/）
- `ConditionAssessment` - 状態評価モデル（Domain/Models/）
- `CalibrationState` - キャリブレーション状態（Domain/Models/）
- `Mood`, `TodayMode` - 気分・モードEnum（Domain/Models/）

## デザインシステム使用例

### カラー
```swift
.foregroundStyle(TempoColors.primary)        // Soft Sage Green
.background(TempoColors.cardBackground)      // Warm Beige
TempoColors.scoreColor(for: score)           // スコアに応じた色
```

### スペーシング
```swift
.padding(TempoSpacing.screenPadding)         // 16pt screen padding
VStack(spacing: TempoSpacing.lg)             // 20pt spacing
.clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
```

### タイポグラフィ
```swift
.font(TempoTypography.title2)                // 22pt Bold
.font(TempoTypography.body)                  // 17pt Regular
.font(TempoTypography.caption)               // 12pt Regular
```

## CircadianClockView実装詳細

```swift
struct CircadianClockView: View {
    let chronotype: Chronotype
    let currentTime: Date

    // 活動ゾーンの時間帯（クロノタイプ別）
    private var activityZoneStart: Int {
        switch chronotype {
        case .morning: return 6
        case .intermediate: return 8
        case .evening: return 10
        }
    }

    private var activityZoneEnd: Int {
        switch chronotype {
        case .morning: return 18
        case .intermediate: return 20
        case .evening: return 22
        }
    }

    var body: some View {
        Canvas { context, size in
            // 24時間サークルを描画
            // 活動ゾーン（🔥）と休息ゾーン（☽）を色分け
            // 現在時刻の位置にマーカーを配置
        }
        .frame(width: 200, height: 200)
        .accessibilityLabel("24時間サークル。現在の時刻は\(currentTimeString)です。")
    }
}
```

## アクセシビリティ対応
- 全てのインタラクティブ要素に `accessibilityLabel` を設定
- スコアは「自律神経スコア 85点」のように読み上げ
- AI Insightカードは要約内容を読み上げ
- CircadianClockは時刻と状態を読み上げ
- Dynamic Type対応（システムフォントを使用）

## エラーハンドリング
```swift
enum HomeError: LocalizedError {
    case dataLoadFailed
    case apiError(String)
    case offlineMode

    var errorDescription: String? { ... }
}
```

## 成功基準
- [ ] 全6セクションが表示される
- [ ] AI Insight要約→詳細遷移が動作
- [ ] キャリブレーション期間中は「---」表示 + プログレスバー
- [ ] MorningCheckInが正しく動作
- [ ] CircadianClockがアニメーション付きで描画される
- [ ] Labor Illusionローディングが4ステップで表示される
- [ ] フィードバックUIが動作
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
PHASE_5C_SPEC.mdを読みました。この仕様に従って、Phase 5cのHome画面 + AI Insight詳細の実装を開始してください。
まずCLAUDE.mdと必読ドキュメントを確認し、既存のコンポーネント・サービスの構造を理解した上で、
TDD（テスト駆動開発）で実装を進めてください。
```
