# TempoAI 開発マスタープロンプト

このドキュメントは、Claude CodeがTempoAIアプリを自律的に開発するための包括的な指示書です。

---

## 🎯 プロジェクト概要

**TempoAI** - "Tune Your Rhythm"

サーカディアンリズム（体内時計）と自律神経を整え、日々のパフォーマンスを最適化するAIパートナーアプリ。

### 技術スタック

| レイヤー | 技術 |
|---------|------|
| iOS | SwiftUI (iOS 17+), HealthKit, CoreLocation |
| Backend | Cloudflare Workers, Hono, TypeScript |
| AI | Claude Sonnet 4 (claude-sonnet-4-20250514) |
| Weather | Open-Meteo API (Weather / Air Quality) |

### 設計思想

- **データベースレス**: ヘルスケアデータは端末内完結
- **軽量設計**: サーバーはAI連携のプロキシのみ
- **ドメイン駆動**: スコアリング等のビジネスロジックはドメインモデルに凝集

---

## 📚 必読ドキュメント

**重要**: 各フェーズの実装前に、必ず以下の仕様書を参照してください。

| ドキュメント | パス | 内容 |
|-------------|------|------|
| **Product Spec** | `docs/specs/product-spec.md` | 画面構成・ユーザーフロー（必読） |
| **Technical Spec** | `docs/specs/technical-spec.md` | ドメインモデル・API設計 |
| **Metrics Spec** | `docs/specs/metrics-spec.md` | スコア算出アルゴリズム |
| **AI Prompt Spec** | `docs/specs/ai-prompt-spec.md` | Claudeプロンプト設計 |
| **UI Spec** | `docs/specs/ui-spec.md` | カラー・タイポグラフィ・インタラクション |
| **Knowledge Base** | `docs/specs/knowledge-base.md` | サーカディアンリズムの科学的根拠 |
| **Swift Standards** | `.claude/swift-coding-standards.md` | Swift開発規約 |
| **TypeScript Standards** | `.claude/typescript-hono-standards.md` | バックエンド開発規約 |
| **UX Concepts** | `.claude/ux_concepts.md` | UXデザイン原則 |

---

## 🔄 開発ワークフロー

各フェーズで以下のワークフローを厳守してください。

### 1. フェーズ開始

```bash
# 1. mainブランチから新しいフィーチャーブランチを作成
git checkout main
git pull origin main
git checkout -b feature/phase-N-[name]

# 2. IMPLEMENTATION_PLAN.md を作成
# （詳細は後述）
```

### 2. 実装サイクル（TDD）

```
1. 仕様書を読む → 理解
2. テストを書く → RED
3. 最小限の実装 → GREEN
4. リファクタ → REFACTOR
5. コミット → 小さな単位で
```

### 3. フェーズ完了・PR作成

```bash
# 1. 全テスト通過を確認
pnpm test        # Backend
# Xcode: ⌘+U     # iOS

# 2. Lint/Format通過を確認
pnpm check       # Backend

# 3. プッシュ
git push origin feature/phase-N-[name]

# 4. GitHub PRを作成
# タイトル: "Phase N: [Name]"
# ベース: main
# 本文: IMPLEMENTATION_PLAN.mdの内容をコピー
```

### 4. マージ後

```bash
git checkout main
git pull origin main
# 次のフェーズへ
```

---

## 📋 IMPLEMENTATION_PLAN.md テンプレート

各フェーズ開始時に、プロジェクトルートに以下のファイルを作成してください。

```markdown
# Phase N: [フェーズ名]

## 概要
[このフェーズで達成すること1-2文]

## 参照ドキュメント
- [x] docs/specs/xxx.md の Section Y
- [x] .claude/yyy.md

## ゴール
- [ ] ゴール1
- [ ] ゴール2
- [ ] ゴール3

## 成功基準
- [ ] 全テストがパス
- [ ] Lint/Formatエラーなし
- [ ] 具体的な動作確認項目

## 実装ステップ

### Step 1: [名前]
**目的**: [何をするか]
**ファイル**: `path/to/file.ts`
**テスト**: `path/to/file.test.ts`

### Step 2: [名前]
...

## テストケース

### ユニットテスト
- [ ] テストケース1
- [ ] テストケース2

### 統合テスト（該当する場合）
- [ ] テストケース1

## 完了チェックリスト
- [ ] 全ステップ完了
- [ ] 全テストパス
- [ ] Lint/Formatパス
- [ ] PRレビュー対応可能
```

---

## 🚀 フェーズ一覧と詳細

---

## Phase 1: Backend基盤

**ブランチ名**: `feature/phase-1-backend-foundation`

### ゴール
1. Honoアプリケーションの基本構造を構築
2. Open-Meteo API連携（Weather + Air Quality）を実装
3. ヘルスチェック・エラーハンドリングを実装

### 参照ドキュメント
- `docs/specs/technical-spec.md` Section 4（API設計）
- `.claude/typescript-hono-standards.md`

### ディレクトリ構造

```
backend/src/
├── index.ts                 # エントリーポイント
├── routes/
│   ├── health.ts           # GET /health
│   └── weather.ts          # GET /api/weather
├── services/
│   └── weather/
│       ├── OpenMeteoClient.ts
│       ├── WeatherService.ts
│       └── types.ts
├── middleware/
│   ├── errorHandler.ts
│   └── logger.ts
└── utils/
    └── result.ts           # Result型
```

### 実装ステップ

#### Step 1: プロジェクト構造と型定義
1. ディレクトリ構造を作成
2. `services/weather/types.ts` に型定義
3. `utils/result.ts` にResult型パターン実装

#### Step 2: Open-Meteo Client
1. `OpenMeteoClient.ts` を実装
2. Weather API呼び出し
3. Air Quality API呼び出し
4. テスト: モック使用

#### Step 3: Weather Service
1. `WeatherService.ts` を実装
2. クライアントを注入（DI）
3. データ変換ロジック
4. テスト: サービス層

#### Step 4: Routes
1. `routes/health.ts`: ヘルスチェック
2. `routes/weather.ts`: 天気情報取得
3. テスト: Hono testClient使用

#### Step 5: Middleware
1. エラーハンドリングミドルウェア
2. ロギングミドルウェア
3. index.tsで統合

### テストケース

```typescript
// Weather Service Tests
describe('WeatherService', () => {
  it('should fetch current weather data')
  it('should fetch air quality data')
  it('should handle API errors gracefully')
  it('should transform API response to domain model')
})

// Weather Route Tests
describe('GET /api/weather', () => {
  it('should return 200 with weather data')
  it('should return 400 for invalid coordinates')
  it('should return 500 when API fails')
})
```

### 成功基準
- [ ] `pnpm test` 全パス
- [ ] `pnpm check` エラーなし
- [ ] `curl localhost:8787/health` → `{"status":"ok"}`
- [ ] `curl localhost:8787/api/weather?lat=35.68&lon=139.76` → 天気データ

---

## Phase 2: iOS基盤 + HealthKit

**ブランチ名**: `feature/phase-2-ios-foundation`

### ゴール
1. Xcodeプロジェクト構造を整備
2. ドメインモデルを実装（Score, HealthMetrics等）
3. HealthKitリポジトリを実装
4. ローカルストレージを実装

### 参照ドキュメント
- `docs/specs/technical-spec.md` Section 3（iOS設計）
- `docs/specs/metrics-spec.md`（スコア定義）
- `.claude/swift-coding-standards.md`

### ディレクトリ構造

```
ios/TempoAI/
├── App/
│   └── TempoAIApp.swift
├── Domain/
│   ├── Models/
│   │   ├── Score.swift
│   │   ├── HealthMetrics.swift
│   │   ├── RhythmAnalysis.swift
│   │   ├── ConditionAssessment.swift
│   │   └── UserProfile.swift
│   └── Services/
│       └── (Phase 3で実装)
├── Infrastructure/
│   ├── HealthKit/
│   │   ├── HealthKitRepository.swift
│   │   └── HealthKitRepositoryProtocol.swift
│   └── Storage/
│       ├── LocalStorage.swift
│       └── LocalStorageProtocol.swift
└── Shared/
    └── Extensions/
        └── Date+Extensions.swift
```

### 実装ステップ

#### Step 1: ドメインモデル
1. `Score.swift` - 値オブジェクト（ロジック内包）
2. `HealthMetrics.swift` - 生データ保持
3. `RhythmAnalysis.swift` - リズム分析集約
4. `ConditionAssessment.swift` - 全スコア統合
5. `UserProfile.swift` - ユーザー設定

#### Step 2: HealthKitリポジトリ
1. `HealthKitRepositoryProtocol.swift` - プロトコル定義
2. `HealthKitRepository.swift` - 実装
3. 取得データ: HRV, 睡眠, 歩数, 安静時心拍
4. async/await使用

#### Step 3: ローカルストレージ
1. `LocalStorageProtocol.swift`
2. `LocalStorage.swift` - UserDefaults + Codable
3. 保存対象: UserProfile, CalibrationState, キャッシュ

#### Step 4: テスト
1. Score値オブジェクトのテスト
2. HealthMetricsのテスト
3. モックを使ったリポジトリテスト

### テストケース

```swift
// Score Tests
func testScoreClampsBetween0And100()
func testScoreStatusReturnsCorrectValue()
func testScoreIconReturnsCorrectEmoji()

// HealthMetrics Tests
func testSleepMetricsDurationHoursCalculation()
func testHRVMetricsDeviationPercentCalculation()

// HealthKitRepository Tests (with mock)
func testFetchSleepDataReturnsMetrics()
func testFetchHRVReturnsBaseline()
```

### 成功基準
- [ ] Xcode ⌘+U 全テストパス
- [ ] SwiftLint警告なし
- [ ] HealthKit Entitlement設定済み

---

## Phase 3: スコア計算エンジン

**ブランチ名**: `feature/phase-3-score-engine`

### ゴール
1. Autonomic Score（自律神経スコア）計算
2. Sleep Score（睡眠スコア）計算
3. Rhythm Score（リズムスコア）計算
4. Activity Score（活動量スコア）計算

### 参照ドキュメント
- `docs/specs/metrics-spec.md`（**必読・アルゴリズム詳細**）
- `docs/specs/knowledge-base.md`（科学的根拠）

### ディレクトリ構造

```
ios/TempoAI/Domain/Services/
├── ScoreCalculator.swift
├── AutonomicScoreCalculator.swift
├── SleepScoreCalculator.swift
├── RhythmScoreCalculator.swift
├── ActivityScoreCalculator.swift
└── RhythmAnalyzer.swift
```

### 実装ステップ

#### Step 1: Autonomic Score Calculator
`docs/specs/metrics-spec.md` Section 2参照

```swift
// ベースライン比較 → 正規化 → 補正
func calculate(hrv: HRVMetrics, sleep: SleepMetrics?) -> Score
```

#### Step 2: Sleep Score Calculator
`docs/specs/metrics-spec.md` Section 3参照

```swift
// 睡眠時間40% + 深い睡眠30% + レム20% + 入眠効率10%
func calculate(sleep: SleepMetrics) -> Score
```

#### Step 3: Rhythm Score Calculator
`docs/specs/metrics-spec.md` Section 4参照

```swift
// 就寝一貫性35% + 起床一貫性35% + 体温20% + ステージ移行10%
func calculate(analysis: RhythmAnalysis) -> Score
```

#### Step 4: Activity Score Calculator
`docs/specs/metrics-spec.md` Section 5参照

```swift
// 歩数60% + 運動時間40%
func calculate(activity: ActivityMetrics) -> Score
```

#### Step 5: ScoreCalculator（ファサード）
全スコアを統合してConditionAssessmentを生成

### テストケース

```swift
// 各スコアのエッジケーステスト
func testAutonomicScoreWithHighHRV()
func testAutonomicScoreWithLowHRV()
func testAutonomicScoreWithMissingBaseline()

func testSleepScoreOptimalDuration()
func testSleepScoreShortSleep()
func testSleepScoreLongSleep()

func testRhythmScoreStablePattern()
func testRhythmScoreUnstablePattern()
func testRhythmScoreWithoutTemperatureData()

func testActivityScoreTargetMet()
func testActivityScoreBelowTarget()
```

### 成功基準
- [ ] 全スコア計算テストパス
- [ ] metrics-spec.mdのアルゴリズムと完全一致
- [ ] エッジケース（データ不足等）を適切にハンドリング

---

## Phase 4: AI連携

**ブランチ名**: `feature/phase-4-ai-integration`

### ゴール
1. Backend: Claude API連携エンドポイント
2. Backend: プロンプト構築ロジック
3. iOS: AdviceAPIClient実装
4. iOS: DailyAdviceモデル実装

### 参照ドキュメント
- `docs/specs/ai-prompt-spec.md`（**必読**）
- `docs/specs/technical-spec.md` Section 4.2

### Backend実装

#### ディレクトリ追加

```
backend/src/
├── routes/
│   └── advice.ts           # POST /api/advice
├── services/
│   └── ai/
│       ├── ClaudeClient.ts
│       ├── PromptBuilder.ts
│       ├── AdviceService.ts
│       └── types.ts
```

#### Step 1: 型定義
`AdviceRequest`, `AdviceResponse` を `ai-prompt-spec.md` に基づき定義

#### Step 2: PromptBuilder
- System Promptの構築（キャッシュ対象）
- User Data XMLの構築

#### Step 3: ClaudeClient
- Anthropic API呼び出し
- Prompt Caching設定
- エラーハンドリング

#### Step 4: AdviceService
- WeatherService + Claude呼び出しの統合
- レスポンス検証・変換

#### Step 5: Route
- `POST /api/advice`
- リクエストバリデーション（Zod）

### iOS実装

#### ディレクトリ追加

```
ios/TempoAI/
├── Domain/Models/
│   └── DailyAdvice.swift
└── Infrastructure/API/
    ├── AdviceAPIClient.swift
    └── AdviceAPIClientProtocol.swift
```

#### Step 1: DailyAdviceモデル
```swift
struct DailyAdvice: Codable {
    let summary: String
    let fullInsight: String
    let recommendedAction: RecommendedAction
    let isOfflineFallback: Bool
}
```

#### Step 2: AdviceAPIClient
- URLSession + async/await
- JSONエンコード/デコード
- エラーハンドリング

### テストケース

```typescript
// Backend Tests
describe('POST /api/advice', () => {
  it('should return advice for valid request')
  it('should return 400 for invalid request')
  it('should handle Claude API errors')
})

describe('PromptBuilder', () => {
  it('should build system prompt correctly')
  it('should build user data XML correctly')
})
```

```swift
// iOS Tests
func testAdviceAPIClientSuccess()
func testAdviceAPIClientNetworkError()
func testDailyAdviceDecoding()
```

### 成功基準
- [ ] `POST /api/advice` が正常に動作
- [ ] プロンプトが `ai-prompt-spec.md` 通りに構築される
- [ ] iOSからAPI呼び出しが成功
- [ ] エラー時のフォールバックが動作

---

## Phase 5: UI実装

**ブランチ名**: `feature/phase-5-ui-implementation`

### ゴール
1. Onboarding画面フロー
2. Home画面（Dashboard）
3. Analytics画面
4. Settings画面

### 参照ドキュメント
- `docs/specs/product-spec.md`（**画面構成必読**）
- `docs/specs/ui-spec.md`（カラー・フォント）
- `.claude/ux_concepts.md`

### ディレクトリ構造

```
ios/TempoAI/Features/
├── Onboarding/
│   ├── OnboardingView.swift
│   ├── OnboardingViewModel.swift
│   └── Steps/
│       ├── WelcomeStep.swift
│       ├── HealthKitStep.swift
│       ├── NicknameStep.swift
│       ├── BasicInfoStep.swift
│       ├── ChronotypeStep.swift
│       ├── BedtimeGoalStep.swift
│       ├── LifestyleStep.swift
│       ├── LocationStep.swift
│       └── CompleteStep.swift
├── Home/
│   ├── HomeView.swift
│   ├── HomeViewModel.swift
│   └── Components/
│       ├── AIDailyInsightCard.swift
│       ├── MorningCheckIn.swift
│       ├── ScoresSection.swift
│       ├── CircadianClock.swift
│       ├── EnvironmentCard.swift
│       └── QuickActionCard.swift
├── Analytics/
│   ├── AnalyticsView.swift
│   ├── AnalyticsViewModel.swift
│   └── Components/
│       ├── ScoreTrendsChart.swift
│       ├── RhythmConsistencyCard.swift
│       └── InsightsCard.swift
└── Settings/
    ├── SettingsView.swift
    └── SettingsViewModel.swift
```

### 実装ステップ

#### Step 1: 共通コンポーネント・デザインシステム
1. カラー定義（`ui-spec.md` 参照）
2. フォントスケール
3. 共通ボタン・カードコンポーネント

#### Step 2: Onboarding
1. 各ステップViewを実装
2. HealthKitからの自動推定ロジック（クロノタイプ、就寝時刻）
3. ProgressIndicator
4. データ永続化

#### Step 3: Home画面
1. AI Daily Insightカード（要約 + 続きを読む）
2. Morning Check-in（気分 + 今日のモード）
3. Scores表示（キャリブレーション期間対応）
4. Circadian Clock
5. Environment & Quick Action

#### Step 4: AI Insight詳細画面
1. フルスクリーンモーダル
2. セクション分け表示
3. フィードバックUI（👍👎）

#### Step 5: Analytics画面
1. 期間セレクター（週間/月間）
2. スコアトレンドグラフ
3. リズム一貫性カード
4. インサイトカード

#### Step 6: Settings画面
1. プロフィール編集
2. HealthKit連携状態
3. アプリ情報

### UIテストケース

```swift
// Snapshot Tests or UI Tests
func testOnboardingFlowCompletion()
func testHomeScreenDisplaysScores()
func testAnalyticsChartRendering()
```

### 成功基準
- [ ] 全画面が `product-spec.md` のワイヤーフレーム通り
- [ ] カラー・フォントが `ui-spec.md` 通り
- [ ] VoiceOver対応
- [ ] Dynamic Type対応

---

## Phase 6: 統合・最終調整

**ブランチ名**: `feature/phase-6-integration`

### ゴール
1. E2E動作確認
2. オフラインフォールバック実装
3. バックグラウンド処理実装
4. パフォーマンス最適化

### 実装ステップ

#### Step 1: 統合テスト
1. 実機でのHealthKit連携確認
2. API経由でのAI Insight取得確認
3. 全画面遷移の確認

#### Step 2: オフラインフォールバック
`docs/specs/technical-spec.md` Section 8参照
1. LocalAdviceGenerator実装
2. キャッシュ戦略実装
3. ネットワーク状態監視

#### Step 3: バックグラウンド処理
`docs/specs/technical-spec.md` Section 7参照
1. Background App Refresh設定
2. Advice事前取得
3. HealthKit Background Delivery

#### Step 4: パフォーマンス最適化
1. 起動時間最適化
2. メモリ使用量確認
3. API応答時間確認

### 成功基準
- [ ] 実機で全機能動作
- [ ] オフライン時にローカルアドバイス表示
- [ ] 起床時にキャッシュ済みInsight表示
- [ ] クラッシュなし

---

## ⚠️ 重要な制約

### 絶対に守るべきこと

1. **医学的アドバイス・診断は絶対に行わない**
2. **any型は使用禁止**（unknownを使用）
3. **コメントアウトされたコードは残さない**
4. **テストなしでPRを出さない**

### 3回試行ルール

同じ問題で3回以上失敗した場合は、以下を実行：

1. `IMPLEMENTATION_PLAN.md` に問題を記録
2. アプローチを変更するか、スコープを縮小
3. 必要に応じてフェーズを分割

---

## 🤖 Claude Codeへの指示

### 開始時

```
TempoAIプロジェクトの開発を開始します。

1. まず docs/specs/ 配下の全仕様書を読んでください
2. Phase 1から順に、IMPLEMENTATION_PLAN.md を作成してください
3. 実装は必ずテストファーストで進めてください
4. 各フェーズ完了時にPRを作成してください

現在のプロジェクト状態を確認し、
どのフェーズから開始すべきか判断してください。
```

### フェーズ開始時

```
Phase N を開始します。

1. このフェーズの IMPLEMENTATION_PLAN.md を作成してください
2. 参照ドキュメントを確認してください
3. ブランチを作成してください: feature/phase-N-[name]
4. Step 1から順にTDDで実装してください
```

### フェーズ完了時

```
Phase N が完了しました。

1. 全テストがパスしていることを確認してください
2. Lint/Formatエラーがないことを確認してください
3. PRを作成してください
4. IMPLEMENTATION_PLAN.md の完了チェックリストを更新してください
```

---

## 📝 備考

- このドキュメントはプロジェクトルートに `TEMPOAI_MASTER_PROMPT.md` として保存
- 必要に応じて各フェーズの詳細を追記可能
- 仕様変更があった場合は、該当する `docs/specs/` ファイルを更新し、このドキュメントも更新

---

**最終更新**: 2025年1月1日
**作成者**: Masakazu + Claude
