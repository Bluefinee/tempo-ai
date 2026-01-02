# Phase 5c: Home画面 + AI Insight詳細 実装計画

## 概要
6セクション構成のHome画面とAI Insight詳細画面をTDDで実装します。

## ファイル構成
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

---

## 実装ステージ

### Stage 0: WeatherData モデル + WeatherAPIClient
**Goal**: 気象データ取得機能の実装
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Domain/Models/WeatherData.swift`
- [ ] `ios/TempoAI/TempoAI/Infrastructure/API/WeatherAPIClient.swift`
- [ ] `ios/TempoAI/TempoAITests/Infrastructure/WeatherAPIClientTests.swift`

**WeatherData モデル仕様**:
```swift
struct WeatherData: Equatable, Codable, Sendable {
    let temperature: Double        // 気温(℃)
    let pressure: Double           // 気圧(hPa)
    let pressureTrend: PressureTrend // 気圧傾向
    let uvIndex: Int               // UV指数(0-11+)
    let humidity: Int              // 湿度(%)
    let weatherCode: Int           // WMO天気コード
    let fetchedAt: Date
}

enum PressureTrend: String, Codable, Sendable {
    case rising = "rising"      // ↑ 上昇
    case stable = "stable"      // → 安定
    case falling = "falling"    // ↓ 下降
}
```

**WeatherAPIClient仕様**:
- Open-Meteo API使用（無料・認証不要）
- 緯度・経度から現在の気象データを取得
- プロトコル: `WeatherAPIClientProtocol`

**テストケース**:
- [ ] 正常取得テスト（モックレスポンス）
- [ ] エラーハンドリングテスト
- [ ] 気圧トレンド計算テスト

---

### Stage 1: HomeViewModel + エラーハンドリング
**Goal**: Home画面の状態管理とビジネスロジック
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Features/Home/HomeViewModel.swift`
- [ ] `ios/TempoAI/TempoAITests/Features/Home/HomeViewModelTests.swift`

**実装内容**:
1. HomeViewModelの基本プロパティ（@Published）
   - dailyAdvice, conditionAssessment, calibrationState
   - userProfile, mood, todayMode, weather
   - isLoading, loadingStep, error
2. HomeError enum定義
3. loadDashboardData() - Labor Illusion対応（4ステップ）
4. submitMorningCheckIn()
5. submitFeedback(_ isHelpful:)
6. refreshData()

**テストケース**:
- [ ] 初期状態テスト
- [ ] データ読み込み成功テスト
- [ ] ローディングステップ遷移テスト
- [ ] エラーハンドリングテスト
- [ ] キャリブレーション状態テスト

---

### Stage 2: CircadianClockView（Canvas描画）
**Goal**: 24時間サークルのCanvas描画実装
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/CircadianClockView.swift`
- [ ] `ios/TempoAI/TempoAITests/Features/Home/CircadianClockViewTests.swift`

**実装内容**:
1. Canvas APIで24時間サークル描画
2. 活動ゾーン（🔥）/ 休息ゾーン（☽）の色分け
3. 現在時刻マーカー（アニメーション）
4. クロノタイプ別パーソナライズ
   - 朝型: 6:00-18:00
   - 中間型: 8:00-20:00
   - 夜型: 10:00-22:00
5. アクセシビリティラベル

**テストケース**:
- [ ] クロノタイプ別ゾーン時間計算テスト
- [ ] 現在時刻の角度計算テスト
- [ ] アクセシビリティラベル生成テスト

---

### Stage 3: Home画面コンポーネント群
**Goal**: 6セクションの各コンポーネント実装
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/AIDailyInsightCard.swift`
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/MorningCheckInSection.swift`
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/ScoresSection.swift`
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/EnvironmentCard.swift`
- [ ] `ios/TempoAI/TempoAI/Features/Home/Components/QuickActionCard.swift`

**各コンポーネント仕様**:

#### [A] AIDailyInsightCard
- ニックネーム + 挨拶 + 要約（100-150文字）
- 「続きを読む」ボタン
- ローディング状態対応（4ステップメッセージ）
- アクセシビリティ対応

#### [B] MorningCheckInSection
- 既存MorningCheckInCardをラップ
- セクションヘッダー付き
- 完了状態の表示

#### [C] ScoresSection
- 既存ScoreCardを使用
- キャリブレーション期間: 「---」表示 + CalibrationProgressView
- 3スコア横並び（自律神経/睡眠/リズム）

#### [E] EnvironmentCard
- 気温、気圧（傾向）、UV指数表示
- WeatherDataモデル使用

#### [F] QuickActionCard
- recommendedAction表示
- タップでアクション実行

---

### Stage 4: HomeView統合
**Goal**: 全コンポーネントを統合したメイン画面
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Features/Home/HomeView.swift`

**実装内容**:
1. ScrollView + VStack構成
2. 6セクション配置
3. Pull-to-refresh対応
4. ナビゲーション（InsightDetailViewへの遷移）
5. Labor Illusionローディング表示
6. エラー表示
7. アクセシビリティ対応

---

### Stage 5: AI Insight詳細画面
**Goal**: 詳細画面とフィードバックUI
**Status**: [ ] Not Started

**作成ファイル**:
- [ ] `ios/TempoAI/TempoAI/Features/Insight/InsightDetailView.swift`
- [ ] `ios/TempoAI/TempoAI/Features/Insight/InsightFeedbackView.swift`

**InsightDetailView構成**:
1. ナビゲーションバー（戻るボタン）
2. フルInsight表示（fullInsight: 400-600文字）
3. フィードバックセクション
4. アクセシビリティ対応

**InsightFeedbackView**:
- 「このアドバイスは役立ちましたか？」
- 👍 はい / 👎 いいえ ボタン
- フィードバック送信後の確認表示

---

## 使用する既存コンポーネント
- `CardView` - カード背景
- `ScoreCard` / `ScoreGauge` - スコア表示
- `MoodSelector` / `TodayModeSelector` / `MorningCheckInCard`
- `LoadingView` / `AIAnalysisLoadingView` - Labor Illusionローディング
- `CalibrationProgressView` - キャリブレーション進捗
- `SectionHeader` - セクション見出し
- `PrimaryButton` / `SecondaryButton` / `TextButton`
- `TempoColors`, `TempoTypography`, `TempoSpacing`

## 使用する既存サービス
- `AdviceAPIClient` (APIClientProtocol)
- `ScoreCalculator`
- `LocalStorage` (LocalStorageProtocol)
- `HealthKitManager` (HealthKitRepositoryProtocol)
- `LocationManager`

## 新規作成が必要なモデル・サービス

### WeatherData モデル
- `ios/TempoAI/TempoAI/Domain/Models/WeatherData.swift`
- プロパティ: temperature, pressure, pressureTrend, uvIndex, humidity, weatherCode

### Weather API クライアント
- `ios/TempoAI/TempoAI/Infrastructure/API/WeatherAPIClient.swift`
- Open-Meteo API使用（無料・APIキー不要）
- エンドポイント: `https://api.open-meteo.com/v1/forecast`

## 使用する既存モデル
- `DailyAdvice`, `ConditionAssessment`, `CalibrationState`
- `UserProfile`, `Mood`, `TodayMode`
- `HealthMetrics`, `Score`, `RhythmAnalysis`

---

## 重要な実装ポイント

### Labor Illusion
```swift
static let loadingSteps: [String] = [
    "睡眠データを解析中...",
    "自律神経バランスを計算中...",
    "今日の環境を確認中...",
    "あなたへのアドバイスを作成中..."
]
```

### キャリブレーション期間対応
- `calibrationState.isComplete == false` の場合
- スコア: 「---」表示
- CalibrationProgressView表示

### アクセシビリティ
- 全コンポーネントに`.accessibilityLabel`
- スコア: 「自律神経スコア、85点、良好」
- Dynamic Type対応

### デザインシステム厳守
```swift
.foregroundStyle(TempoColors.primary)
.padding(TempoSpacing.screenPadding)
.font(TempoTypography.body)
```

---

## 最終セルフレビューチェックリスト

実装完了後、以下を必ず確認すること。

### 1. ビルド・テスト
- [ ] `swift build` が成功する
- [ ] 全テストがパス（`swift test`）
- [ ] SwiftLint警告なし

### 2. UI/レイアウト確認
- [ ] 全6セクションが正しい順序で表示される
- [ ] セクション間のスペーシングが統一されている（TempoSpacing.lg = 20pt）
- [ ] カードの角丸が統一されている（TempoSpacing.cardCornerRadius = 16pt）
- [ ] 画面端の余白が統一されている（TempoSpacing.screenPadding = 16pt）
- [ ] スクロール時に要素が重ならない
- [ ] Safe Area対応が正しい

### 3. 文言・テキスト確認
- [ ] 挨拶文が時間帯に応じて正しい（おはよう/こんにちは/こんばんは）
- [ ] ニックネームが正しく表示される（「〇〇さん」形式）
- [ ] ボタンラベルが仕様通り（「続きを読む」「記録する」等）
- [ ] エラーメッセージが日本語で適切
- [ ] 「学習中」「---」表示がキャリブレーション期間中のみ

### 4. 色・タイポグラフィ確認
- [ ] Primary色（Soft Sage Green #7CB342）が正しく使用されている
- [ ] スコアの色がステータスに応じて変化する
- [ ] テキストカラーが適切（primary/secondary/tertiary）
- [ ] フォントサイズがTempoTypographyに準拠

### 5. インタラクション確認
- [ ] ボタンタップ時のフィードバックがある
- [ ] ローディング時にLabor Illusion（4ステップ）が表示される
- [ ] Pull-to-refreshが動作する
- [ ] 「続きを読む」タップでInsightDetailViewに遷移する
- [ ] フィードバックボタン（👍👎）が動作する

### 6. 状態別表示確認
- [ ] ローディング中: AIAnalysisLoadingView表示
- [ ] キャリブレーション中: CalibrationProgressView + 「---」スコア
- [ ] キャリブレーション完了後: 実際のスコア表示
- [ ] エラー時: エラーメッセージ + リトライボタン
- [ ] オフライン時: フォールバックアドバイス表示

### 7. CircadianClock確認
- [ ] 24時間サークルが正しく描画される
- [ ] 現在時刻マーカーが正しい位置にある
- [ ] 活動ゾーン（🔥）と休息ゾーン（☽）が色分けされている
- [ ] クロノタイプに応じてゾーンが調整される

### 8. アクセシビリティ確認
- [ ] VoiceOverで全要素がナビゲート可能
- [ ] スコアが「自律神経スコア、85点、良好」と読み上げられる
- [ ] ボタンに適切なaccessibilityLabel/Hintがある
- [ ] Dynamic Type有効時にテキストが拡大される
- [ ] 装飾的要素が`.hideFromAccessibility()`されている

### 9. コード品質確認
- [ ] 全プロパティに明示的な型宣言がある
- [ ] `any`型を使用していない
- [ ] MARK: コメントでセクション分けされている
- [ ] 1ファイル400行以下
- [ ] 不要なコメント・コードがない

### 10. 仕様との整合性確認
- [ ] PHASE_5C_SPEC.mdの成功基準を全て満たしている
- [ ] docs/specs/ui-spec.mdのデザイン仕様に準拠
- [ ] docs/specs/product-spec.mdの機能仕様に準拠

---

## 成功基準（PHASE_5C_SPEC.mdより）

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
