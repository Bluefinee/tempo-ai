# Phase 5: UI実装 計画書

**作成日**: 2026-01-02
**ステータス**: Phase 5a完了 → Phase 5b待ち

---

## 全体進捗チェックリスト

### サブフェーズ完了状況

- [x] **Phase 5a**: Design System + 共通コンポーネント ✅ (PR #49)
- [ ] **Phase 5b**: Onboarding（9ステップ）
- [ ] **Phase 5c**: Home画面 + AI Insight詳細
- [ ] **Phase 5d**: Analytics画面
- [ ] **Phase 5e**: Settings画面 + TabView統合

---

## 概要

Phase 4（AI連携）完了後のUI実装フェーズ。Onboarding、Home、Analytics、Settings画面を実装する。

## 現在の状態

- **Features/ディレクトリ**: 存在しない（新規作成）
- **OnboardingView/HomeView**: ContentView.swift内にプレースホルダーのみ
- **Design System**: 未実装
- **Domain層**: 完全実装済み（Score, DailyAdvice, HealthMetrics等）
- **Infrastructure層**: 完全実装済み（API, HealthKit, Storage）

## サブフェーズ分割

作業量が多いため、以下の5つのサブフェーズに分割。**各サブフェーズごとにPRを作成**：

| サブフェーズ | ブランチ名 | 内容 | 推定ファイル数 |
|-------------|-----------|------|---------------|
| 5a | feature/phase-5a-design-system | Design System + 共通コンポーネント | 10-15 |
| 5b | feature/phase-5b-onboarding | Onboarding（9ステップ） | 12-15 |
| 5c | feature/phase-5c-home | Home画面 + AI Insight詳細 | 12-15 |
| 5d | feature/phase-5d-analytics | Analytics画面 | 5-8 |
| 5e | feature/phase-5e-settings | Settings画面 + 統合 | 5-8 |

**ワークフロー**: 各サブフェーズ完了時にPR作成 → レビュー → mainにマージ → 次のサブフェーズへ

---

## Phase 5a: Design System + 共通コンポーネント ✅

### チェックリスト

- [x] ブランチ作成: `feature/phase-5a-design-system`
- [x] Shared/Design/ディレクトリ作成
- [x] Colors.swift実装
- [x] Typography.swift実装
- [x] Spacing.swift実装
- [x] Shared/Components/ディレクトリ作成
- [x] PrimaryButton.swift実装
- [x] SecondaryButton.swift実装
- [x] CardView.swift実装
- [x] ScoreGauge.swift実装
- [x] LoadingView.swift実装
- [x] MoodSelector.swift実装
- [x] View+Accessibility.swift実装
- [x] View+Style.swift実装
- [x] テスト作成（DesignSystemTests.swift）
- [x] PR作成: https://github.com/Bluefinee/tempo-ai/pull/49
- [ ] PRマージ

### ゴール
1. カラー・フォント・スペーシング定数を定義
2. 再利用可能なボタン・カードコンポーネントを実装
3. VoiceOver/Dynamic Type対応の基盤を整備

### 作成ファイル

```
ios/TempoAI/TempoAI/
├── Shared/
│   ├── Design/
│   │   ├── Colors.swift              # ui-spec.md カラーパレット
│   │   ├── Typography.swift          # フォントスケール
│   │   └── Spacing.swift             # スペーシング定数
│   ├── Components/
│   │   ├── PrimaryButton.swift       # プライマリボタン
│   │   ├── SecondaryButton.swift     # セカンダリボタン
│   │   ├── CardView.swift            # 汎用カード
│   │   ├── ScoreGauge.swift          # スコア表示ゲージ
│   │   ├── LoadingView.swift         # ローディング表示（Labor Illusion）
│   │   └── MoodSelector.swift        # 気分選択UI
│   └── Extensions/
│       ├── View+Accessibility.swift  # VoiceOver拡張
│       └── View+Style.swift          # スタイル拡張
```

### 実装詳細

#### Colors.swift
```swift
// ui-spec.md Section 2 に基づく
enum TempoColors {
    static let primary = Color(hex: "#7CB342")      // Soft Sage Green
    static let secondary = Color(hex: "#F5F0E8")    // Warm Beige
    static let accent = Color(hex: "#E8A598")       // Soft Coral
    static let background = Color(hex: "#FAF8F5")   // Light Cream
    static let cardBackground = Color(hex: "#F5F0E8")

    // スコア状態カラー
    static func scoreColor(for value: Int) -> Color
}
```

#### Typography.swift
```swift
// ui-spec.md Section 3 に基づく
enum TempoTypography {
    static let largeTitle: Font = .system(size: 34, weight: .bold)
    static let title: Font = .system(size: 28, weight: .bold)
    static let body: Font = .system(size: 17, weight: .regular)
    // ... Dynamic Type対応
}
```

### 成功基準
- [x] 全カラーがui-spec.md通り
- [x] Dynamic Type対応（最小0.7倍）
- [x] VoiceOverラベル設定済み

---

## Phase 5b: Onboarding（9ステップ）

### チェックリスト

- [ ] ブランチ作成: `feature/phase-5b-onboarding`
- [ ] Features/Onboarding/ディレクトリ作成
- [ ] OnboardingContainerView.swift実装
- [ ] OnboardingViewModel.swift実装
- [ ] OnboardingState.swift実装
- [ ] WelcomeStepView.swift実装
- [ ] HealthKitStepView.swift実装
- [ ] NicknameStepView.swift実装
- [ ] BasicInfoStepView.swift実装
- [ ] ChronotypeStepView.swift実装（自動推定+手動フォールバック）
- [ ] BedtimeGoalStepView.swift実装（自動提案+手動フォールバック）
- [ ] LifestyleStepView.swift実装
- [ ] LocationStepView.swift実装
- [ ] CompleteStepView.swift実装
- [ ] テスト作成
- [ ] PR作成・マージ

### ゴール
1. 9ステップのオンボーディングフローを実装
2. HealthKitからの自動推定（クロノタイプ、就寝時刻）
3. プログレスインジケーター

### 作成ファイル

```
ios/TempoAI/TempoAI/Features/
├── Onboarding/
│   ├── OnboardingContainerView.swift  # フロー管理
│   ├── OnboardingViewModel.swift      # 状態管理
│   ├── OnboardingState.swift          # 状態モデル
│   └── Steps/
│       ├── WelcomeStepView.swift      # Step 1
│       ├── HealthKitStepView.swift    # Step 2（認証）
│       ├── NicknameStepView.swift     # Step 3
│       ├── BasicInfoStepView.swift    # Step 4（年齢・性別・体重・身長）
│       ├── ChronotypeStepView.swift   # Step 5（自動推定）
│       ├── BedtimeGoalStepView.swift  # Step 6（自動提案）
│       ├── LifestyleStepView.swift    # Step 7（任意項目）
│       ├── LocationStepView.swift     # Step 8
│       └── CompleteStepView.swift     # Step 9
```

### 実装詳細

#### OnboardingViewModel
```swift
@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var state: OnboardingState = .init()

    // HealthKitからの自動推定
    func estimateChronotype() async -> Chronotype
    func estimateBedtimeGoal() async -> Date

    // 保存
    func completeOnboarding() async
}
```

#### ChronotypeStepView（自動推定 + 手動フォールバック）
```swift
// product-spec.md Section 2.2 の仕様
// MSFsc = (平均就寝時刻 + 平均睡眠時間/2)
// MSFsc < 3:00 → 朝型, 3:00-5:00 → 中間型, > 5:00 → 夜型

// 自動推定成功時:
// UI: 「あなたは○○型のようです。合っていますか？」+ 確認ボタン

// HealthKitデータ不足時（フォールバック）:
// UI: 通常の3択選択UI（朝型/中間型/夜型）を表示
```

#### BedtimeGoalStepView（自動提案 + 手動フォールバック）
```swift
// 自動提案成功時:
// UI: 「あなたの平均就寝時刻は23:30です。これを目標にしますか？」

// HealthKitデータ不足時（フォールバック）:
// UI: 時刻ピッカーで手動入力
```

### 成功基準
- [ ] 9ステップが正常に遷移
- [ ] HealthKit認証が動作
- [ ] 自動推定が正しく計算される（データ十分時）
- [ ] データ不足時に手動入力UIにフォールバック
- [ ] UserProfileがLocalStorageに保存される

---

## Phase 5c: Home画面 + AI Insight詳細

### チェックリスト

- [ ] ブランチ作成: `feature/phase-5c-home`
- [ ] Features/Home/ディレクトリ作成
- [ ] HomeView.swift実装
- [ ] HomeViewModel.swift実装
- [ ] AIDailyInsightCard.swift実装
- [ ] MorningCheckInSection.swift実装
- [ ] ScoresSection.swift実装
- [ ] CircadianClockView.swift実装（リッチ実装）
- [ ] EnvironmentCard.swift実装
- [ ] QuickActionCard.swift実装
- [ ] Features/Insight/ディレクトリ作成
- [ ] InsightDetailView.swift実装
- [ ] InsightFeedbackView.swift実装
- [ ] キャリブレーション期間対応
- [ ] テスト作成
- [ ] PR作成・マージ

### ゴール
1. 6セクション構成のHome画面
2. AI Daily Insight詳細画面
3. キャリブレーション期間対応

### 作成ファイル

```
ios/TempoAI/TempoAI/Features/
├── Home/
│   ├── HomeView.swift                 # メイン画面
│   ├── HomeViewModel.swift            # 状態管理
│   └── Components/
│       ├── AIDailyInsightCard.swift   # [A] AI Insight要約
│       ├── MorningCheckInSection.swift # [B] 気分 + 今日のモード
│       ├── ScoresSection.swift        # [C] 3スコア表示
│       ├── CircadianClockView.swift   # [D] 24時間サークル（リッチ実装）
│       ├── EnvironmentCard.swift      # [E] 気象情報
│       └── QuickActionCard.swift      # [F] 即時アクション
├── Insight/
│   ├── InsightDetailView.swift        # AI Insight詳細画面
│   └── InsightFeedbackView.swift      # フィードバックUI
```

### 実装詳細

#### HomeViewModel
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var conditionAssessment: ConditionAssessment?
    @Published var dailyAdvice: DailyAdvice?
    @Published var calibrationState: CalibrationState?
    @Published var isLoading: Bool = false

    // データ取得
    func loadDashboardData() async
    func submitMood(_ mood: Mood) async
    func submitTodayMode(_ mode: TodayMode) async
}
```

#### キャリブレーション期間対応
```swift
// product-spec.md Section 2.3
// スコアは「---」と表示
// プログレスバー: 「あなたのリズムを学習中... あと○日」
```

#### CircadianClockView（リッチ実装）
```swift
// 24時間サークルのリッチ実装
// - グラデーション背景（時間帯に応じた色変化）
// - 活動ゾーン🔥と休息ゾーン☽の視覚的区分
// - 現在時刻のアニメーション表示（針または光るドット）
// - ユーザーのクロノタイプに応じたゾーン調整
// - 日の出・日の入り時刻の表示
// - スムーズなトランジションアニメーション
```

### 成功基準
- [ ] 全6セクションが表示される
- [ ] AI Insight要約→詳細遷移が動作
- [ ] キャリブレーション期間中は「---」表示
- [ ] フィードバックUIが動作
- [ ] CircadianClockがアニメーション付きで描画される

---

## Phase 5d: Analytics画面

### チェックリスト

- [ ] ブランチ作成: `feature/phase-5d-analytics`
- [ ] Features/Analytics/ディレクトリ作成
- [ ] AnalyticsView.swift実装
- [ ] AnalyticsViewModel.swift実装
- [ ] PeriodSelector.swift実装
- [ ] ScoreTrendsChart.swift実装
- [ ] RhythmConsistencyCard.swift実装
- [ ] InsightsCard.swift実装
- [ ] テスト作成
- [ ] PR作成・マージ

### ゴール
1. 期間セレクター（週間/月間）
2. スコアトレンドグラフ
3. リズム一貫性表示
4. インサイトカード

### 作成ファイル

```
ios/TempoAI/TempoAI/Features/
├── Analytics/
│   ├── AnalyticsView.swift            # メイン画面
│   ├── AnalyticsViewModel.swift       # 状態管理
│   └── Components/
│       ├── PeriodSelector.swift       # 期間セレクター
│       ├── ScoreTrendsChart.swift     # スコアトレンドグラフ
│       ├── RhythmConsistencyCard.swift # リズム一貫性
│       └── InsightsCard.swift         # AIインサイト
```

### 成功基準
- [ ] 週間/月間の切り替えが動作
- [ ] グラフが正しく描画される
- [ ] リズム一貫性データが表示される

---

## Phase 5e: Settings画面 + 統合

### チェックリスト

- [ ] ブランチ作成: `feature/phase-5e-settings`
- [ ] Features/Settings/ディレクトリ作成
- [ ] SettingsView.swift実装
- [ ] SettingsViewModel.swift実装
- [ ] ProfileSection.swift実装
- [ ] DataSection.swift実装
- [ ] AboutSection.swift実装
- [ ] Features/Main/ディレクトリ作成
- [ ] MainTabView.swift実装
- [ ] ContentView.swift更新（プレースホルダー削除）
- [ ] テスト作成
- [ ] PR作成・マージ

### ゴール
1. プロフィール編集
2. HealthKit/位置情報連携状態表示
3. アプリ情報
4. TabView統合

### 作成ファイル

```
ios/TempoAI/TempoAI/Features/
├── Settings/
│   ├── SettingsView.swift             # メイン画面
│   ├── SettingsViewModel.swift        # 状態管理
│   └── Components/
│       ├── ProfileSection.swift       # プロフィール編集
│       ├── DataSection.swift          # データ連携状態
│       └── AboutSection.swift         # アプリ情報
├── Main/
│   └── MainTabView.swift              # TabView（Home/Analytics/Settings）
```

### ContentView.swift更新
```swift
// プレースホルダーを削除し、MainTabViewを使用
if hasCompletedOnboarding {
    MainTabView()
} else {
    OnboardingContainerView()
}
```

### 成功基準
- [ ] 3タブが正常に動作
- [ ] プロフィール編集が保存される
- [ ] 連携状態が正しく表示される

---

## テスト戦略

### ユニットテスト
- OnboardingViewModel: 状態遷移、自動推定ロジック
- HomeViewModel: データ取得、エラーハンドリング
- ScoreGauge: スコア表示ロジック

### UIテスト（将来）
- オンボーディングフロー完走
- Home画面の各セクション表示確認
- タブ間遷移

---

## 技術的考慮事項

### VoiceOver対応
- 全インタラクティブ要素にaccessibilityLabelを設定
- スコアは「自律神経スコア 85点」のように読み上げ
- カードは「続きを読むボタン」のように明示

### Dynamic Type対応
- システムフォント（.title, .body等）を使用
- 固定サイズ指定を避ける
- レイアウトが崩れないようpadding調整

### パフォーマンス
- HomeViewModelでの非同期データ取得
- ローディング状態の適切な表示
- キャッシュからの即時表示

---

## 参照ドキュメント

| ドキュメント | パス |
|-------------|------|
| Product Spec | docs/specs/tempoai_product_spec.md |
| UI Spec | docs/specs/ui-spec.md |
| Swift Standards | .claude/swift-coding-standards.md |
| UX Concepts | .claude/ux_concepts.md |

---

## 実装順序とブランチ戦略

### 順序

1. **Phase 5a**: Design System（他の全画面で使用） → PR → mainへマージ
2. **Phase 5b**: Onboarding（初回起動時必須） → PR → mainへマージ
3. **Phase 5c**: Home（メイン機能） → PR → mainへマージ
4. **Phase 5d**: Analytics → PR → mainへマージ
5. **Phase 5e**: Settings + TabView統合 → PR → mainへマージ

### ブランチ作成手順（各サブフェーズ開始時）

```bash
git checkout main
git pull origin main
git checkout -b feature/phase-5X-[name]
```

### PR作成時のチェックリスト（各サブフェーズ）

- [ ] 全テストがパス（Xcode ⌘+U）
- [ ] SwiftLint警告なし
- [ ] VoiceOver対応確認
- [ ] Dynamic Type対応確認
- [ ] 実機での動作確認

---

## 決定事項メモ

- **PR戦略**: 各サブフェーズごとにPR作成 → mainへマージ
- **自動推定フォールバック**: HealthKitデータ不足時は手動入力UIを表示
- **CircadianClock**: リッチ実装（アニメーション・グラデーション付き）

---

## 改訂履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-01-02 | 初版作成 |
| 2026-01-02 | Phase 5a完了（PR #49） |
