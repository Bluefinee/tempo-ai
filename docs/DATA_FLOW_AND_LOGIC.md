# Tempo AI - 画面データフロー・ロジック仕様書

各画面がどのようにデータを表示しているか、データソース、計算ロジック、API利用状況を詳細に記載しています。

---

## 目次

1. [データソース概要](#データソース概要)
2. [Today画面](#today画面)
3. [Rhythm画面](#rhythm画面)
4. [Recovery詳細画面](#recovery詳細画面)
5. [Sleep詳細画面](#sleep詳細画面)
6. [Rhythm詳細画面](#rhythm詳細画面)
7. [Energy詳細画面](#energy詳細画面)
8. [Health詳細画面](#health詳細画面)
9. [Insight詳細画面](#insight詳細画面)
10. [Action詳細画面](#action詳細画面)
11. [Breathe画面](#breathe画面)
12. [Settings画面](#settings画面)
13. [スコア計算式](#スコア計算式)
14. [現在の実装状況](#現在の実装状況)

---

## データソース概要

### 現状: モックデータ

全画面で現在は `app/src/constants/mockData/` に定義された**モックデータ**を使用しています。実際のAPI・HealthKit連携は未実装です。

| データ種別 | 現在のソース | 将来のソース |
|-----------|-------------|-------------|
| 4つのスコア (Recovery, Sleep, Rhythm, Energy) | `scoreCalculator.ts`（モック入力） | HealthKit + 計算 |
| ヘルスメトリクス (HRV, RHR等) | コンポーネント内ハードコード | HealthKit |
| AI Insight / Today's One Thing | `MOCK_AI_RESPONSE` | Claude API (`/api/advice`) |
| 天気情報 | `MOCK_WEATHER` | Open-Meteo API (`/api/weather`) |
| ユーザープロファイル | `MOCK_USER`, `MOCK_SETTINGS` | AsyncStorage / バックエンド |

### データフローアーキテクチャ

```
┌─────────────────────────────────────────────────────────────────────┐
│                     現在のフロー（モック）                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  MockData (constants/)  ─────►  healthStore (Zustand)  ────►  UI   │
│                                                                     │
│  ┌──────────────────┐     ┌─────────────────────┐                  │
│  │ MOCK_SLEEP       │     │ calculateDailyScores│                  │
│  │ MOCK_HRV         │ ──► │ scoreCalculator.ts  │ ──► dailySnapshot│
│  │ MOCK_RHYTHM      │     │                     │                  │
│  │ MOCK_WEATHER     │     └─────────────────────┘                  │
│  └──────────────────┘                                              │
│                                                                     │
│  MOCK_AI_RESPONSE ──────────────────────────────────────► UIカード  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                   将来のフロー（本番）                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  HealthKit ──► dataSourceAdapter ──► healthStore ──► scores ──► UI │
│                                                                     │
│  APIサーバー (/api/advice) ──► Claude AI ──► AIResponse ──► UI     │
│                                                                     │
│  APIサーバー (/api/weather) ──► Open-Meteo ──► Weather ──► UI      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Today画面

**ファイル**: `app/app/(main)/index.tsx`

### 表示項目

| 項目 | データソース | ロジック/API | 備考 |
|------|-------------|-------------|------|
| **挨拶文** | `dateFormatters.getGreeting()` | 時間帯判定 | "Good Morning/Afternoon/Evening" |
| **日付** | `dateFormatters.formatDate()` | ローカル計算 | "Wednesday, January 15" |
| **Recoveryスコアカード** | `healthStore.dailySnapshot.scores.recovery` | `calculateRecoveryScore()` | 現在はモック入力 |
| **Sleepスコアカード** | `healthStore.dailySnapshot.scores.sleep` | `calculateSleepScore()` | 現在はモック入力 |
| **Rhythmスコアカード** | `healthStore.dailySnapshot.scores.rhythm` | `calculateRhythmScore()` | 現在はモック入力 |
| **Energyスコアカード** | `healthStore.dailySnapshot.scores.energy` | `calculateEnergyScore()` | 現在はモック入力 |
| **ミニチャート（7本棒）** | ハードコード配列 | 静的値 | `[40, 60, 55, 80, 70, 65, score]` |
| **AI Insightタイトル** | `MOCK_AI_RESPONSE.todayInsight.title` | **AI API必要** | 将来: Claude API |
| **AI Insight本文** | `MOCK_AI_RESPONSE.todayInsight.summary` | **AI API必要** | 将来: Claude API |
| **Today's One Thing** | `MOCK_AI_RESPONSE.todayOneThing` | **AI API必要** | 将来: Claude API |
| **Health Summary (HRV)** | ハードコード: `82 ms` | **HealthKit必要** | |
| **Health Summary (RHR)** | ハードコード: `59 bpm` | **HealthKit必要** | |
| **Health Summary (呼吸数)** | ハードコード: `11.0 brpm` | **HealthKit必要** | |
| **Health Summary (SpO2)** | ハードコード: `98%` | **HealthKit必要** | |
| **Health Summary (体温)** | ハードコード: `36.4°C` | **HealthKit必要** | |

### 初期化フロー

```typescript
// app/app/(main)/index.tsx
useEffect(() => {
  initialize();  // healthStore.initialize()を呼び出し
}, [initialize]);

// healthStore/index.ts
initialize: async () => {
  await get().fetchTodayMetrics();     // モックメトリクス取得
  await get().fetchWeather(35.6762, 139.6503);  // モック天気
  get().calculateDailyScores();        // 4スコア計算
}
```

---

## Rhythm画面

**ファイル**: `app/app/(main)/rhythm.tsx`（タブ画面）

### データソース

| 項目 | データソース | 備考 |
|------|-------------|------|
| 現在時刻 | システム時計 | リアルタイム |
| エネルギー曲線 | `MOCK_RHYTHM` | 静的な可視化 |
| Peak Focusウィンドウ | `MOCK_RHYTHM.upcomingWindows[0]` | "Now — 12:00" |
| Wind Downウィンドウ | `MOCK_RHYTHM.upcomingWindows[1]` | "21:30 — 7:00" |
| 日の出/日の入り | `getEnvironmentData()` | モック: 6:50 / 16:48 |
| 天気状態 | `MOCK_RHYTHM.weather` | "Clear", 8°C |
| 気圧 | `MOCK_RHYTHM.pressure` | 1018 hPa |
| UV指数 | `MOCK_RHYTHM.uv` | 指数3, "Moderate" |
| 月相 | `MOCK_RHYTHM.moonPhase` | "First Quarter" |

---

## Recovery詳細画面

**ファイル**: `app/app/(main)/recovery-detail.tsx`

### 表示項目

| 項目 | データソース | ロジック | 備考 |
|------|-------------|---------|------|
| **Recoveryスコア（円形）** | `healthStore.dailySnapshot.scores.recovery` | 計算済み | メイン表示 |
| **ステータスラベル** | `getRecoveryStatus(score)` | 閾値判定 | "Fully Recovered" 等 |
| **HRV値** | `MOCK_DETAIL.recovery.hrv.value` | モック: `82 ms` | |
| **HRVベースライン** | `MOCK_DETAIL.recovery.hrv.baseline` | モック: `77 ms` | |
| **HRV変化** | `MOCK_DETAIL.recovery.hrv.change` | モック: `+5%` | |
| **RHR値** | `MOCK_DETAIL.recovery.rhr.value` | モック: `59 bpm` | |
| **RHRベースライン** | `MOCK_DETAIL.recovery.rhr.baseline` | モック: `59 bpm` | |
| **分析テキスト** | `MOCK_DETAIL.recovery.analysis` | **AI必要** | AI生成の説明文 |
| **履歴チャート** | `MOCK_DETAIL.recovery.history[timeframe]` | モックデータ | 7D/30D/60D |
| **週間平均** | `MOCK_DETAIL.recovery.weeklyAverage` | モック: `64%` | |

### スコア計算

```typescript
// Recovery = HRV (60%) + RHR (20%) + 睡眠の質 (20%)
calculateRecoveryScore({
  hrv: { current: 82, baseline: 77 },
  rhr: { current: 59, baseline: 59 },
  sleepQuality: 85  // Sleepスコアから
})
```

---

## Sleep詳細画面

**ファイル**: `app/app/(main)/sleep-detail.tsx`

### 表示項目

| 項目 | データソース | ロジック | 備考 |
|------|-------------|---------|------|
| **Sleepスコア（二重リング）** | `healthStore.dailySnapshot.scores.sleep` | 計算済み | 外側: 時間, 内側: 質 |
| **ステータスラベル** | `getSleepStatus(score)` | 閾値判定 | "Excellent Sleep" 等 |
| **睡眠時間** | `MOCK_DETAIL.sleep.duration` | モック: `7h 8m` | |
| **睡眠の質%** | `MOCK_DETAIL.sleep.quality.percentage` | モック: `85%` | |
| **分析テキスト** | `MOCK_DETAIL.sleep.analysis` | **AI必要** | AI生成 |
| **睡眠ステージバー** | `MOCK_DETAIL.sleep.stages` | モックデータ | 深い/REM/浅い/覚醒 |
| **就寝時刻（実際）** | `MOCK_DETAIL.sleep.timing.bedtime.actual` | モック: `23:15` | |
| **就寝時刻（目標）** | `MOCK_DETAIL.sleep.timing.bedtime.target` | モック: `23:00` | |
| **起床時刻（実際）** | `MOCK_DETAIL.sleep.timing.wakeTime.actual` | モック: `06:45` | |
| **起床時刻（目標）** | `MOCK_DETAIL.sleep.timing.wakeTime.target` | モック: `07:00` | |
| **履歴チャート** | `MOCK_DETAIL.sleep.history[timeframe]` | モックデータ | 7D/30D/60D |

### スコア計算

```typescript
// Sleep = 時間 (40%) + 質 (40%) + タイミング (20%)
calculateSleepScore({
  duration: { minutes: 428, targetMinutes: 450 },
  stages: {
    deepMinutes: 105,   // 23%
    remMinutes: 95,     // 22%
    lightMinutes: 228,  // 53%
    awakeMinutes: 0
  }
})
```

---

## Rhythm詳細画面

**ファイル**: `app/app/(main)/rhythm-detail.tsx`

### 表示項目

| 項目 | データソース | ロジック | 備考 |
|------|-------------|---------|------|
| **Rhythmスコア（円形）** | `healthStore.dailySnapshot.scores.rhythm` | 計算済み | |
| **ステータスラベル** | `getRhythmStatus(score)` | 閾値判定 | "In Sync" 等 |
| **就寝一貫性** | `MOCK_DETAIL.rhythm.consistency.bedtime` | モック | 目標: 23:00, ±12分 |
| **起床一貫性** | `MOCK_DETAIL.rhythm.consistency.wakeTime` | モック | 目標: 07:00, ±8分 |
| **貢献要因** | | | 4つのカード: |
| - 就寝ばらつき | `contributingFactors.bedtimeVariance` | モック: `95%` | |
| - 起床ばらつき | `contributingFactors.wakeVariance` | モック: `98%` | |
| - 週末シフト | `contributingFactors.weekendShift` | モック: `85%` | |
| - 社会的時差 | `contributingFactors.socialJetlag` | モック: `90%` | |
| **分析テキスト** | `MOCK_DETAIL.rhythm.analysis` | **AI必要** | |
| **週間パターンチャート** | `MOCK_DETAIL.rhythm.weeklyPattern` | モック | 7日間の偏差バー |

### スコア計算

```typescript
// Rhythm = 就寝一貫性 (50%) + 起床一貫性 (50%)
calculateRhythmScore({
  bedtimeStddevMinutes: 12,  // 標準偏差
  wakeTimeStddevMinutes: 8
})
// ≤15分 → 100, ≤30分 → 85, ≤45分 → 70, など
```

---

## Energy詳細画面

**ファイル**: `app/app/(main)/energy-detail.tsx`

### 表示項目

| 項目 | データソース | ロジック | 備考 |
|------|-------------|---------|------|
| **Energyスコア（円形）** | `healthStore.dailySnapshot.scores.energy` | 計算済み | |
| **ステータスラベル** | `getEnergyStatus(score)` | 閾値判定 | "Moderate Energy" 等 |
| **貢献要因** | | | 4つのカード: |
| - Recovery | `contributingFactors.recovery` | モック: `70%` | |
| - Sleep | `contributingFactors.sleep` | モック: `85%` | |
| - Activity | `contributingFactors.activity` | モック: `75%` | |
| - Weather | `contributingFactors.weather` | モック: `80%` | |
| **分析テキスト** | `MOCK_DETAIL.energy.analysis` | **AI必要** | |
| **日中エネルギー曲線** | SVG正弦波 | ハードコード | Peak Focus / Afternoon Dip表示 |
| **Peak Focus時間帯** | `MOCK_DETAIL.energy.peakFocus` | モック: `09:00-12:00` | |
| **Afternoon Dip時間帯** | `MOCK_DETAIL.energy.afternoonDip` | モック: `14:00-16:00` | |
| **履歴チャート** | `MOCK_DETAIL.energy.history[timeframe]` | モックデータ | 7D/30D/60D |

### スコア計算

```typescript
// Energy = Recovery (50%) + Sleep (40%) + 天気補正 (10%)
calculateEnergyScore({
  recovery: 70,
  sleep: 85,
  weather: {
    pressure: 1018,
    pressureTrend: "stable"  // falling → -20%, rising → +5%
  }
})
```

---

## Health詳細画面

**ファイル**: `app/app/(main)/health-detail.tsx`

### 表示項目

全データがコンポーネント内の `getMetrics()` 関数に**ハードコード**されています。

| メトリクス | 値 | 単位 | 正常範囲 | データソース |
|-----------|-----|------|---------|-------------|
| **HRV** | 82 | ms | 58-97 | ハードコード |
| **RHR** | 59 | bpm | 54-63 | ハードコード |
| **呼吸数** | 11.0 | BrPM | 10.5-16 | ハードコード |
| **SpO2** | 98 | % | 96-99 | ハードコード |
| **手首体温** | 36.4 | °C | 36.1-36.9 | ハードコード |

### 機能

- サマリーグリッドカード（タップで詳細へスクロール）
- メトリクスごとの期間セレクター（7D/30D/60D）
- 正常範囲帯付きのエリアチャート
- 下部ナビゲーションピル

### 注意

この画面は**動的データソースなし**。全ての値がインラインで定義されています。将来的にはHealthKit連携が必要です。

---

## Insight詳細画面

**ファイル**: `app/app/(main)/insight-detail.tsx`

### 表示項目

| 項目 | データソース | AI関与 | 備考 |
|------|-------------|--------|------|
| **タイトル** | `MOCK_AI_RESPONSE.todayInsight.title` | **AI生成** | "A Quiet Harmony" |
| **サマリー** | `MOCK_AI_RESPONSE.todayInsight.summary` | **AI生成** | メインインサイト文 |
| **Why This Matters - HRV** | `whyThisMatters.hrv.headline/explanation` | **AI生成** | HRV固有の洞察 |
| **Why This Matters - Sleep** | `whyThisMatters.sleep.headline/explanation` | **AI生成** | 睡眠固有の洞察 |
| **Why This Matters - Rhythm** | `whyThisMatters.rhythm.headline/explanation` | **AI生成** | リズム固有の洞察 |
| **What This Means** | `todayInsight.whatThisMeansForToday` | **AI生成** | 実践的アドバイス |

### 将来: Claude API連携

```typescript
// APIエンドポイント: POST /api/advice
// リクエスト: AdviceRequest (ユーザーコンテキスト, スコア, ヘルスメトリクス, 天気)
// レスポンス: AIResponse (todayInsight と todayOneThing を含む)
```

---

## Action詳細画面

**ファイル**: `app/app/(main)/action-detail.tsx`

### 表示項目

| 項目 | データソース | AI関与 | 備考 |
|------|-------------|--------|------|
| **アクションタイトル** | `MOCK_AI_RESPONSE.todayOneThing.action` | **AI生成** | "Take a 5-min walk around 2pm" |
| **サマリー** | `todayOneThing.summary` | **AI生成** | 短い説明 |
| **Why This Action** | `todayOneThing.whyThisAction` | **AI生成** | 詳細な説明 |
| **Benefits** | `todayOneThing.benefits[]` | **AI生成** | 3つのメリットピル |
| **How To Do It** | `todayOneThing.howToDoIt[]` | **AI生成** | 番号付きステップ |
| **Expected Benefit** | `todayOneThing.expectedBenefit` | **AI生成** | 出典引用付き |
| **リマインダーボタン** | UIのみ | TODO | 未実装 |

---

## Breathe画面

**ファイル**: `app/app/(main)/breathe.tsx`

### 表示項目

| 項目 | データソース | ロジック | 備考 |
|------|-------------|---------|------|
| **タイトル** | i18n: `screen.breathe.title` | 静的 | "Breathe" |
| **サブタイトル** | i18n: `screen.breathe.subtitle` | 静的 | "Box Breathing • 4-4-4" |
| **タイマー** | ローカルステート: `timeLeft` | カウントダウン | 60秒 |
| **フェーズ** | ローカルステート: `phase` | ステートマシン | idle/inhale/hold/exhale |
| **指示テキスト** | `getInstruction()` | フェーズ依存 | "Breathe in..." 等 |
| **円アニメーション** | Reanimated `scale` | フェーズ依存 | 拡大/収縮 |
| **プログレスリング** | SVG stroke | 時間経過 | セッション進捗表示 |

### アニメーションロジック

```typescript
// フェーズ時間（ミリ秒）
const PHASE_DURATIONS = {
  inhale: 4000,  // 4秒
  hold: 4000,    // 4秒
  exhale: 4000   // 4秒
};
// 合計サイクル: 12秒

// フェーズごとのアニメーション目標
phase === "inhale" → scale: 1.0
phase === "hold"   → scale: 1.0
phase === "exhale" → scale: 0.5
phase === "idle"   → scale: 0.75
```

### データソース

**外部データソースなし**。全ロジックがローカル:
- タイマーカウントダウン
- フェーズステートマシン
- フェーズ変更時のハプティックフィードバック

---

## Settings画面

**ファイル**: `app/app/(main)/settings.tsx`

### 表示項目

| 項目 | データソース | 備考 |
|------|-------------|------|
| **ニックネーム** | ハードコード: `"John Doe"` | `MOCK_DATA` から |
| **プラン** | ハードコード: `"Free Plan"` | |
| **メンバー開始** | ハードコード: `"2024"` | |
| **目標就寝時刻** | ハードコード: `"22:30"` | |
| **目標起床時刻** | ハードコード: `"6:30"` | |
| **通知トグル** | ローカルステート | 永続化なし |
| **ハプティックトグル** | ローカルステート | 永続化なし |
| **Apple Health状態** | ハードコード: "Connected" | |
| **Oura Ring状態** | ハードコード: "Connect" | |
| **バージョン** | ハードコード | "TempoAI v1.0.2" |

### データソース

**全てハードコード**。以下との連携なし:
- ユーザープロファイルストレージ
- HealthKitパーミッション状態
- システム設定

---

## スコア計算式

**ファイル**: `app/src/domain/services/scoreCalculator.ts`

### Recovery Score

```
Recovery Score = HRVコンポーネント (60%) + RHRコンポーネント (20%) + 睡眠の質 (20%)

HRVコンポーネント:
  - ratio = 現在HRV / ベースラインHRV
  - score = clamp((ratio - 0.7) / 0.6 * 100, 0, 100)
  - 例: 82/77 = 1.065 → (1.065-0.7)/0.6*100 = 60.8%

RHRコンポーネント（逆数 - 低いほど良い）:
  - ratio = ベースラインRHR / 現在RHR
  - score = clamp((ratio - 0.85) / 0.3 * 100, 0, 100)
```

### Sleep Score

```
Sleep Score = 時間 (40%) + 質 (40%) + タイミング (20%)

時間:
  - score = (実際の分数 / 目標分数) * 100
  - 例: 428/450 = 95%

質:
  - deep_score = scoreRange(deep_ratio, 0.15, 0.25)  // 15-25%が理想
  - rem_score = scoreRange(rem_ratio, 0.20, 0.25)    // 20-25%が理想
  - quality = deep_score * 0.5 + rem_score * 0.5

タイミング（オプション）:
  - deviation = 就寝偏差 + 起床偏差（分）
  - timing_score = 100 - deviation/4
```

### Rhythm Score

```
Rhythm Score = (就寝一貫性 + 起床一貫性) / 2

標準偏差による一貫性スコア:
  - ≤15分 → 100
  - ≤30分 → 85
  - ≤45分 → 70
  - ≤60分 → 55
  - ≤90分 → 40
  - >90分 → 25
```

### Energy Score

```
Energy Score = Recovery (50%) + Sleep (40%) + 天気補正 (10%)

天気補正:
  - 基準: 100
  - 気圧下降中 かつ 気圧 < 1010 hPa: -20
  - 気圧上昇中: +5
```

---

## 現在の実装状況

### サマリー表

| コンポーネント | モックデータ | フロントロジック | API準備 | HealthKit準備 |
|---------------|-------------|-----------------|---------|--------------|
| 4スコアカード | ✅ | ✅ | ❌ | ❌ |
| AI Insight | ✅ | ✅ | ✅ (バックエンド) | N/A |
| Today's One Thing | ✅ | ✅ | ✅ (バックエンド) | N/A |
| Health Summary | ✅ (ハードコード) | ❌ | N/A | ❌ |
| Recovery詳細 | ✅ | ✅ | ❌ | ❌ |
| Sleep詳細 | ✅ | ✅ | ❌ | ❌ |
| Rhythm詳細 | ✅ | ✅ | ❌ | ❌ |
| Energy詳細 | ✅ | ✅ | ❌ | ❌ |
| Health詳細 | ✅ (ハードコード) | ❌ | N/A | ❌ |
| Breathe | N/A | ✅ | N/A | N/A |
| Settings | ✅ (ハードコード) | ❌ | N/A | N/A |
| 天気 | ✅ | ❌ | ✅ (バックエンド) | N/A |

---

## リリースまでのロードマップ

### フェーズ概要

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Phase 1        │     │  Phase 2        │     │  Phase 3        │
│  実機UI確認     │ ──► │  API連携テスト  │ ──► │  HealthKit実装  │
│  (モックデータ) │     │  (天気・AI)     │     │  (実データ)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
      1-2日                   2-3日                  5-7日
```

---

### Phase 1: 実機UI確認

**目的**: モックデータでUIが正しく表示されるか実機で確認

#### チェックリスト

- [ ] Expo Go または Development Build で実機起動
- [ ] Today画面 - 4スコアカード表示確認
- [ ] Today画面 - AI Insightカード表示確認
- [ ] Today画面 - Today's One Thingカード表示確認
- [ ] Today画面 - Health Summaryグリッド表示確認
- [ ] Recovery詳細画面 - スコア・チャート表示確認
- [ ] Sleep詳細画面 - スコア・ステージバー表示確認
- [ ] Rhythm詳細画面 - 一貫性データ・チャート表示確認
- [ ] Energy詳細画面 - エネルギー曲線表示確認
- [ ] Health詳細画面 - 全メトリクス表示確認
- [ ] Insight詳細画面 - AIコンテンツ表示確認
- [ ] Action詳細画面 - ステップ表示確認
- [ ] Rhythm画面 - インタラクティブチャート動作確認
- [ ] Breathe画面 - アニメーション・タイマー動作確認
- [ ] Settings画面 - トグル動作確認
- [ ] 英語表示確認（デフォルト）
- [ ] 日本語端末で日本語表示確認

---

### Phase 2: API連携テスト

**目的**: バックエンドAPIとの疎通確認

#### 準備完了状況

| 機能 | フロントエンド | バックエンド | 切り替え方法 |
|------|---------------|-------------|-------------|
| 天気API | ✅ 実装済み | ✅ 実装済み | フラグ切り替えのみ |
| AI Advice API | ⚠️ 要修正 | ✅ 実装済み | フラグ + コード修正 |

#### 天気API連携

**状態**: **準備完了** - フラグを切り替えるだけで動作

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_WEATHER: false,  // ← trueからfalseに変更
  // ...
};
```

**動作フロー**:
1. `healthStore.fetchWeather(lat, lon)` 呼び出し
2. `dataSourceAdapter.getWeather()` が `apiClient.getWeather()` を呼び出し
3. バックエンド `/api/weather` → Open-Meteo API → レスポンス

#### AI Advice API連携

**状態**: **要修正** - Today画面がAPIを経由していない

**現在の問題点**:
```typescript
// app/app/(main)/index.tsx - 現在の実装
import { MOCK_AI_RESPONSE } from "../../src/constants/mockData";
// 直接モックを使用 → dataSourceAdapterを経由していない
```

**修正内容**:
1. Today画面を `dataSourceAdapter.getAIAdvice()` を使うように変更
2. `buildAdviceRequest()` でリクエストを構築
3. フラグ切り替えで動作

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_AI: false,  // ← trueからfalseに変更
  // ...
};
```

#### チェックリスト

- [ ] バックエンドがCloudflare Workersにデプロイ済み確認
- [ ] `API_BASE_URL` が正しく設定されている確認
- [ ] `USE_MOCK_WEATHER: false` に変更
- [ ] 天気データが実機で表示されることを確認
- [ ] Today画面を `dataSourceAdapter.getAIAdvice()` に変更
- [ ] `USE_MOCK_AI: false` に変更
- [ ] AI Insightが実機で表示されることを確認
- [ ] Today's One Thingが実機で表示されることを確認
- [ ] エラーハンドリング（ネットワークエラー時）の確認

---

### Phase 3: HealthKit実装

**目的**: Apple HealthKitから実データを取得し、スコアを動的に計算

#### 準備状況

| 項目 | 状態 | 備考 |
|------|------|------|
| ライブラリ | ❌ 未導入 | `react-native-health` が必要 |
| パーミッション | ❌ 未実装 | iOS Info.plist設定が必要 |
| データ取得コード | ❌ 未実装 | `HealthKitService` の作成が必要 |
| アダプター接続 | ✅ 準備済み | `dataSourceAdapter` のインターフェースは定義済み |
| スコア計算 | ✅ 準備済み | `scoreCalculator.ts` は実装済み |

#### 必要なHealthKitデータ

| データ種別 | HealthKit識別子 | 使用先 |
|-----------|----------------|--------|
| 睡眠分析 | `HKCategoryTypeIdentifierSleepAnalysis` | Sleep Score, Recovery |
| HRV | `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` | Recovery Score, Health詳細 |
| 安静時心拍数 | `HKQuantityTypeIdentifierRestingHeartRate` | Recovery Score, Health詳細 |
| 呼吸数 | `HKQuantityTypeIdentifierRespiratoryRate` | Health詳細 |
| SpO2 | `HKQuantityTypeIdentifierOxygenSaturation` | Health詳細 |
| 体温 | `HKQuantityTypeIdentifierBodyTemperature` | Health詳細 |
| 歩数 | `HKQuantityTypeIdentifierStepCount` | 活動追跡 |

#### 実装ステップ

1. **ライブラリ導入**
   ```bash
   npx expo install react-native-health
   # または expo-health-kit-connect
   ```

2. **iOS設定**
   ```xml
   <!-- ios/Info.plist -->
   <key>NSHealthShareUsageDescription</key>
   <string>Tempo AI uses your health data to provide personalized insights</string>
   ```

3. **HealthKitService作成**
   ```typescript
   // app/src/services/healthKitService.ts
   class HealthKitService {
     async requestPermissions(): Promise<boolean>
     async getSleepData(date: Date): Promise<SleepMetrics>
     async getHRVData(date: Date): Promise<HRVMetrics>
     // ...
   }
   ```

4. **dataSourceAdapter接続**
   ```typescript
   // USE_MOCK_HEALTHKIT: false の場合
   async getSleepMetrics(): Promise<SleepMetrics> {
     return healthKitService.getSleepData(new Date());
   }
   ```

#### チェックリスト

- [ ] `react-native-health` または同等ライブラリをインストール
- [ ] Development Buildを再作成（Expo Go不可）
- [ ] iOS Info.plistにHealthKit権限を追加
- [ ] `HealthKitService` クラスを作成
- [ ] パーミッションリクエストUIを実装
- [ ] 睡眠データ取得を実装
- [ ] HRVデータ取得を実装
- [ ] RHRデータ取得を実装
- [ ] `dataSourceAdapter` を実データに接続
- [ ] `USE_MOCK_HEALTHKIT: false` に変更
- [ ] 実機で実データが表示されることを確認
- [ ] スコアが実データから計算されることを確認

---

## 技術詳細: データソース切り替え

### 設定ファイル

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_DATA: true,       // 全体のモック使用（将来用）
  USE_MOCK_AI: true,         // AI API → モック切り替え
  USE_MOCK_WEATHER: true,    // 天気API → モック切り替え
  USE_MOCK_HEALTHKIT: true,  // HealthKit → モック切り替え
} as const;
```

### dataSourceAdapter パターン

```typescript
// app/src/services/dataSourceAdapter.ts
class DataSourceAdapter {
  async getWeather(lat: number, lon: number): Promise<SimpleWeatherData> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
      return MOCK_WEATHER;  // モックデータ返却
    }
    // 実API呼び出し
    const result = await apiClient.getWeather(lat, lon);
    return transformToSimpleWeather(result);
  }

  async getAIAdvice(request: AdviceRequest): Promise<AdviceResponse> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_AI) {
      return MOCK_AI_RESPONSE;  // モックデータ返却
    }
    // 実API呼び出し
    const result = await apiClient.generateAdvice(request);
    return result.data;
  }
}
```

### バックエンドエンドポイント

| エンドポイント | メソッド | 説明 | 外部API |
|---------------|---------|------|---------|
| `/api/weather` | GET | 天気データ取得 | Open-Meteo API |
| `/api/advice` | POST | AIアドバイス生成 | Anthropic Claude API |

---

## クイックスタート: API連携テスト手順

### 1. バックエンド確認

```bash
# ローカルテスト
cd backend
pnpm dev

# 天気API確認
curl "http://localhost:8787/api/weather?lat=35.6762&lon=139.6503"

# AI API確認
curl -X POST "http://localhost:8787/api/advice" \
  -H "Content-Type: application/json" \
  -d '{"user":{"goals":["better_sleep"]},"scores":{"recovery":70}}'
```

### 2. フロントエンド設定

```typescript
// app/app.config.ts
export default {
  extra: {
    API_BASE_URL: "https://your-worker.workers.dev", // デプロイ後のURL
    // または開発時: "http://localhost:8787"
  }
};
```

### 3. フラグ切り替え

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_AI: false,       // ← AI API有効化
  USE_MOCK_WEATHER: false,  // ← 天気API有効化
  USE_MOCK_HEALTHKIT: true, // ← まだモック（Phase 3で変更）
};
```

### 4. 実機テスト

```bash
cd app
npx expo start
# 実機でQRコードをスキャン
```
