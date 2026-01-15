# Tempo AI 実装状況レポート

> 作成日: 2026-01-15
> 更新日: 2026-01-15
> 対象バージョン: Mock/実データパイプライン統合完了後

---

## 1. エグゼクティブサマリー

| 項目                       | 状態              |
| -------------------------- | ----------------- |
| **UI フレームワーク**      | ✅ 完成           |
| **ビジネスロジック**       | ✅ 完成           |
| **Mock データ**            | ✅ 完成           |
| **Mock→ パイプライン統合** | ✅ 完成           |
| **Weather API**            | ✅ 実装済み       |
| **AI API**                 | ✅ 実装済み       |
| **HealthKit 連携**         | ❌ 未実装         |
| **本番リリース準備**       | 🔶 ブロッカーあり |

**結論**: 全画面のデータが `healthStore` パイプラインを通過。`USE_MOCK_HEALTHKIT=false` への切替で実データ対応可能。HealthKit 統合のみ残タスク。

---

## 2. 画面別実装状況

### 2.1 Today 画面 (`app/(main)/index.tsx`)

| 機能                                        | 実装状態 | データソース                | パイプライン |
| ------------------------------------------- | -------- | --------------------------- | ------------ |
| 4 スコア表示 (Recovery/Sleep/Rhythm/Energy) | ✅       | healthStore.dailySnapshot   | ✅ 統合済    |
| 4 スコア chartData (7 日間履歴)             | ✅       | useScoreChartDataForToday() | ✅ 統合済    |
| Health Summary (HRV/RHR/呼吸数/SpO2/体温)   | ✅       | healthStore.realtimeMetrics | ✅ 統合済    |
| AI Insight カード                           | ✅       | insightStore                | ✅ 統合済    |
| Today's One Thing カード                    | ✅       | insightStore                | ✅ 統合済    |
| 天気表示                                    | ✅       | healthStore.environmentData | ✅ 統合済    |

### 2.2 Rhythm 画面 (`app/(main)/rhythm.tsx`)

| 機能                                   | 実装状態 | データソース         | パイプライン |
| -------------------------------------- | -------- | -------------------- | ------------ |
| サーカディアンリズムチャート           | ✅       | useRhythmChartData() | ✅ 統合済    |
| Upcoming Windows 時間 (Peak/Melatonin) | ✅       | useUpcomingWindows() | ✅ 統合済    |
| Environmental Data (6 項目)            | ✅       | useEnvironmentData() | ✅ 統合済    |

### 2.3 詳細画面

| 画面            | 実装状態 | チャート                           | データソース                            | パイプライン |
| --------------- | -------- | ---------------------------------- | --------------------------------------- | ------------ |
| Recovery Detail | ✅       | 7D/30D/60D                         | useRecoveryDetail()                     | ✅ 統合済    |
| Sleep Detail    | ✅       | Dual Ring + 履歴                   | useSleepDetail()                        | ✅ 統合済    |
| Rhythm Detail   | ✅       | 一貫性チャート                     | useRhythmDetail()                       | ✅ 統合済    |
| Energy Detail   | ✅       | Contributing Factors + Daily Curve | useEnergyDetail() + energyCurve         | ✅ 統合済    |
| Health Detail   | ✅       | 5 メトリクス履歴                   | createMetrics(realtimeMetrics, history) | ✅ 統合済    |
| Action Detail   | ✅       | -                                  | insightStore                            | ✅ 統合済    |
| Insight Detail  | ✅       | -                                  | insightStore                            | ✅ 統合済    |

---

## 3. データフロー詳細

### 3.1 Today 画面のスコア計算

```
healthStore.initialize()
    │
    ├─ fetchTodayMetrics()
    │     ├─ dataSourceAdapter.getSleepMetrics()   → MOCK_SLEEP_METRICS
    │     ├─ dataSourceAdapter.getHRVMetrics()     → MOCK_HRV_METRICS
    │     ├─ dataSourceAdapter.getActivityMetrics() → MOCK_ACTIVITY_METRICS
    │     └─ dataSourceAdapter.getRhythmAnalysis() → MOCK_RHYTHM_ANALYSIS
    │
    ├─ fetchRealtimeMetrics()
    │     └─ dataSourceAdapter.getRealtimeMetrics() → createMockRealtimeMetrics()
    │
    ├─ fetchWeather() / fetchEnvironmentData()
    │     └─ dataSourceAdapter.getWeather/EnvironmentData()
    │           └─ USE_MOCK_WEATHER ? MOCK_* : apiClient.getWeather()
    │
    └─ calculateDailyScores()
          ├─ calculateRecoveryScore()  → HRV(60%) + RHR(20%) + SleepQuality(20%)
          ├─ calculateSleepScore()     → Duration(40%) + Quality(40%) + Timing(20%)
          ├─ calculateRhythmScore()    → BedtimeConsistency(50%) + WakeConsistency(50%)
          └─ calculateEnergyScore()    → Recovery(50%) + Sleep(40%) + Weather(10%)
```

### 3.2 Rhythm 画面のチャート生成

```
rhythm.tsx
    │
    ├─ useRhythmChartData()
    │     └─ healthStore.energyCurve
    │           └─ calculateEnergyCurve(wakeUpTime, windDownTime)
    │                 └─ 時刻ベースのエネルギーレベル計算
    │                       ├─ Wake Window (0-2h): 30→60
    │                       ├─ Peak Focus (2-5h): 60→90
    │                       ├─ Post-Peak (5-7h): 90→70
    │                       ├─ Afternoon Dip (7-9h): 70→50
    │                       ├─ Recovery (9-10h): 50→70
    │                       ├─ Second Wind (10-13h): 70→80
    │                       └─ Wind Down (13h+): 80→30
    │
    └─ useEnvironmentData()
          └─ healthStore.environmentData
                └─ MOCK_ENVIRONMENT_DATA
                      ├─ sunrise: "6:50"
                      ├─ sunset: "16:48"
                      ├─ weather: { condition, temperature, humidity }
                      ├─ pressure: { value, trend, change24h }
                      ├─ uv: { index, level }
                      └─ moonPhase: { phase, illumination }
```

### 3.3 AI Insight/Today's One Thing

```
insightStore.initializeWithMockData()
    │
    └─ DATA_SOURCE_CONFIG.USE_MOCK_DATA === true
          └─ setDailyInsight(MOCK_AI_RESPONSE)
                ├─ todayInsight: { title, summary, whyThisMatters, whatThisMeansForToday }
                └─ todayOneThing: { action, summary, time, benefits, howToDoIt }
```

---

## 4. Mock/実データ切り替え機構

### 4.1 設定ファイル

**ファイル**: `app/src/config/dataSource.ts`

```typescript
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_DATA: true, // マスタースイッチ（insightStore用）
  USE_MOCK_AI: true, // AIアドバイス
  USE_MOCK_WEATHER: true, // 天気データ
  USE_MOCK_HEALTHKIT: true, // HealthKit
} as const;
```

### 4.2 フラグ適用マトリックス

| フラグ               | 適用コンポーネント | Mock 時                  | 実データ時             |
| -------------------- | ------------------ | ------------------------ | ---------------------- |
| `USE_MOCK_DATA`      | insightStore       | MOCK_AI_RESPONSE         | -                      |
| `USE_MOCK_AI`        | apiClient          | -                        | generateAdvice()       |
| `USE_MOCK_WEATHER`   | dataSourceAdapter  | MOCK_WEATHER/ENVIRONMENT | apiClient.getWeather() |
| `USE_MOCK_HEALTHKIT` | dataSourceAdapter  | MOCK\_\*\_METRICS        | **throw Error**        |

### 4.3 現在の切り替え可能状況

| データソース      | Mock→ 実データ切替 | 備考                                |
| ----------------- | ------------------ | ----------------------------------- |
| **天気データ**    | ✅ 可能            | apiClient.getWeather() 実装済み     |
| **AI アドバイス** | ✅ 可能            | apiClient.generateAdvice() 実装済み |
| **HealthKit**     | ❌ 不可            | HealthKitService 未実装             |

---

## 5. スコア計算アルゴリズム

### 5.1 Recovery Score

```typescript
// 重み: HRV(60%) + RHR(20%) + Sleep Quality(20%)

// HRVスコア計算
const hrvRatio = input.hrv.current / input.hrv.baseline;
const hrvScore = clamp(((hrvRatio - 0.7) / 0.6) * 100, 0, 100);
// ベースラインの70-130%範囲で0-100点

// RHRスコア計算（低いほど良い）
const rhrRatio = input.rhr.baseline / input.rhr.current;
const rhrScore = clamp(((rhrRatio - 0.85) / 0.3) * 100, 0, 100);

// 最終スコア
return hrvScore * 0.6 + rhrScore * 0.2 + sleepQualityScore * 0.2;
```

### 5.2 Sleep Score

```typescript
// 重み: Duration(40%) + Quality(40%) + Timing(20%)

// 睡眠時間スコア（7-9時間が理想）
const durationScore = scoreRange(durationMinutes, 420, 540);

// 品質スコア（Deep Sleep 15-25%, REM 20-25%が理想）
const deepRatio = deepSleepMinutes / durationMinutes;
const remRatio = remSleepMinutes / durationMinutes;
const qualityScore =
  (scoreRange(deepRatio, 0.15, 0.25) + scoreRange(remRatio, 0.2, 0.25)) / 2;

// タイミングスコア（就寝22-23時、起床6-7時が理想）
const timingScore = (bedtimeScore + wakeScore) / 2;

return durationScore * 0.4 + qualityScore * 0.4 + timingScore * 0.2;
```

### 5.3 Rhythm Score

```typescript
// 重み: Bedtime一貫性(50%) + Wake一貫性(50%)

// 標準偏差からスコアを計算
// ≤15分: 100点
// ≤30分: 85点
// ≤45分: 70点
// ≤60分: 55点
// ≤90分: 40点
// >90分: 25点

const bedtimeScore = stddevToScore(bedtimeStddevMinutes);
const wakeScore = stddevToScore(wakeTimeStddevMinutes);

return bedtimeScore * 0.5 + wakeScore * 0.5;
```

### 5.4 Energy Score

```typescript
// 重み: Recovery(50%) + Sleep(40%) + Weather(10%)

// 天気影響
let weatherFactor = 0;
if (pressureTrend === "falling" && pressure < 1010) {
  weatherFactor = -20; // 気圧急低下
} else if (pressureTrend === "rising") {
  weatherFactor = +5; // 気圧上昇
}

const baseScore = recoveryScore * 0.5 + sleepScore * 0.4;
return clamp(baseScore + weatherFactor, 0, 100);
```

---

## 6. Mock データ定義

### 6.1 HealthKit 系 (`mockData/health/metrics.ts`)

```typescript
// 睡眠メトリクス
MOCK_SLEEP_METRICS = {
  durationMinutes: 450, // 7.5時間
  deepSleepMinutes: 105, // 23%
  remSleepMinutes: 90, // 20%
  lightSleepMinutes: 195, // 43%
  awakeMinutes: 60, // 13%
  bedtime: "23:15",
  wakeTime: "06:45",
};

// HRVメトリクス
MOCK_HRV_METRICS = {
  value: 68,
  baseline30d: 55,
};

// アクティビティメトリクス
MOCK_ACTIVITY_METRICS = {
  steps: 8500,
  activeMinutes: 35,
  caloriesBurned: 320,
};

// リズム分析
MOCK_RHYTHM_ANALYSIS = {
  bedtimeStddevMinutes: 22,
  wakeTimeStddevMinutes: 18,
  averageBedtime: "23:00",
  averageWakeTime: "07:00",
};
```

### 6.2 環境データ (`mockData/health/metrics.ts`)

```typescript
MOCK_ENVIRONMENT_DATA = {
  sunrise: "6:50",
  sunset: "16:48",
  weather: {
    condition: "Clear",
    temperature: 8,
    humidity: 45,
  },
  pressure: {
    value: 1018,
    trend: "stable",
    change24h: 2,
  },
  uv: {
    index: 3,
    level: "Moderate",
  },
  moonPhase: {
    phase: "First Quarter",
    illumination: 48,
  },
};
```

### 6.3 AI レスポンス (`mockData/aiResponse.ts`)

```typescript
MOCK_AI_RESPONSE = {
  todayInsight: {
    title: "A Quiet Harmony",
    summary: "You recovered well last night...",
    whyThisMatters: {
      hrv: { headline: "HRV +24% above baseline", explanation: "..." },
      sleep: { headline: "Deep sleep duration optimal", explanation: "..." },
      rhythm: { headline: "Consistent bedtime", explanation: "..." },
    },
    whatThisMeansForToday: "Make the most of your Peak Focus window...",
  },
  todayOneThing: {
    action: "Take a 5-min walk around 2pm",
    summary: "Prevents afternoon drowsiness...",
    time: "14:00",
    benefits: ["Restores afternoon focus", "Boosts energy naturally", ...],
    howToDoIt: ["Step away from your desk", "Walk outside if possible", ...],
  },
};
```

---

## 7. 問題点と対応策

### 7.1 重大度: 高

| #   | 問題                               | 影響                             | 対応策                                  | 状態      |
| --- | ---------------------------------- | -------------------------------- | --------------------------------------- | --------- |
| 1   | **HealthKit 統合が完全未実装**     | 実データでアプリが動作しない     | HealthKitService の実装が必須           | ❌ 未対応 |
| 2   | **スコア履歴保存が Mock 時に無効** | 開発環境で AsyncStorage 検証不可 | 保存条件 `!USE_MOCK_HEALTHKIT` の見直し | ❌ 未対応 |

### 7.2 重大度: 中

| #   | 問題                             | 影響                             | 対応策                   | 状態      |
| --- | -------------------------------- | -------------------------------- | ------------------------ | --------- |
| 3   | **環境データの部分実装**         | UV index/湿度がハードコード      | API 拡張後に対応         | ❌ 未対応 |
| 4   | **USE_MOCK_DATA フラグが限定的** | マスタースイッチとして機能しない | 一元化ロジック追加を検討 | ❌ 未対応 |

### 7.3 重大度: 低

| #   | 問題                      | 影響           | 対応策           | 状態      |
| --- | ------------------------- | -------------- | ---------------- | --------- |
| 5   | **気圧 24h 変化が常に 0** | 表示精度低下   | 計算ロジック追加 | ❌ 未対応 |
| 6   | **環境変数管理が限定的**  | 環境切替が煩雑 | .env 分割を検討  | ❌ 未対応 |

### 7.4 解決済み（2026-01-15）

| #   | 問題                               | 対応内容                                  |
| --- | ---------------------------------- | ----------------------------------------- |
| ✅  | Today 画面 chartData ハードコード  | `useScoreChartDataForToday()` フック追加  |
| ✅  | Rhythm Upcoming Windows 時間固定   | `useUpcomingWindows()` フック追加         |
| ✅  | Health Detail 全データハードコード | `createMetrics()` で動的生成に変更        |
| ✅  | Energy Detail Daily Curve SVG 固定 | `generateEnergyCurveSvgPath()` で動的生成 |
| ✅  | Health Summary カードレイアウト    | 横並びレイアウトに修正                    |

### 7.5 解決済み: ハードコードレビュー（2026-01-15 追加）

| #   | 問題                                        | 対応内容                                                              |
| --- | ------------------------------------------- | --------------------------------------------------------------------- |
| ✅  | settings.tsx MOCK_DATA                      | `userStore` から動的取得、`DEFAULT_*` 定数化                          |
| ✅  | health-detail.tsx Baseline 固定             | `realtimeMetrics.*.baseline` から動的取得、`DEFAULT_BASELINES` 定数化 |
| ✅  | healthStore 目標睡眠時間固定                | `onboarding.ts` の `DEFAULT_*` 定数を使用                             |
| ✅  | rhythm.tsx 日付配列固定                     | `formatDate()` + `getLocale()` で i18n 対応                           |
| ✅  | RhythmInteractiveChart X 軸ラベル固定       | `chart.timeAxis.*` i18n キー追加                                      |
| ✅  | HealthMetricDetail タイムフレームラベル固定 | `chart.timeframeLabels.*` i18n キー追加                               |
| ✅  | energy-detail.tsx 時間軸ラベル固定          | `chart.timeAxis.*` i18n キー追加                                      |
| ✅  | breathe.tsx HEX カラー直書き                | `BREATHE_COLORS` 定数化（`colors` オブジェクト使用）                  |
| ✅  | 各 Detail 画面 typicalRange 分散            | `chartConstants.ts` に `SCORE_TYPICAL_RANGE` 共通化                   |
| ✅  | selectors.ts データ鮮度閾値マジックナンバー | `DATA_STALE_THRESHOLD_HOURS` 定数化                                   |

### 7.6 解決済み: 第三者監査レビュー（2026-01-15 追加）

`docs/DATA_PIPELINE_AUDIT_REPORT.md` の監査結果に基づく 23 件の NG 項目を全て修正。

| #   | 問題                                       | 対応内容                                                                           |
| --- | ------------------------------------------ | ---------------------------------------------------------------------------------- |
| ✅  | TOTAL_ONBOARDING_STEPS 矛盾                | `userStore.ts` で `onboarding.ts` の `ONBOARDING_TOTAL_STEPS` をインポートして統一 |
| ✅  | healthStore 初期化時のハードコード時刻     | `DEFAULT_WAKE_UP_TIME`, `DEFAULT_BED_TIME` を参照に変更                            |
| ✅  | rhythm.tsx DEFAULT_ENVIRONMENT_DATA        | `environmentConstants.ts` に分離、プレースホルダー値でフォールバック               |
| ✅  | settings.tsx Alert 日本語ハードコード      | `t("screen.settings.resetAlert.*")` に置換                                         |
| ✅  | recovery-detail.tsx Loading 英語           | `t("screen.loading.recovery")` に置換                                              |
| ✅  | sleep-detail.tsx Loading 英語              | `t("screen.loading.sleep")` に置換                                                 |
| ✅  | rhythm-detail.tsx Loading 英語             | `t("screen.loading.rhythm")` に置換                                                |
| ✅  | energy-detail.tsx Loading 英語             | `t("screen.loading.energy")` に置換                                                |
| ✅  | health-detail.tsx 曜日ラベル英語           | `t("screen.healthDetail.weekdays.*")` に置換                                       |
| ✅  | health-detail.tsx Low/High ステータス英語  | `t("screen.healthDetail.status.*")` に置換                                         |
| ✅  | health-detail.tsx Health ヘッダー英語      | `t("screen.healthDetail.title")` に置換                                            |
| ✅  | action-detail.tsx "にリマインド"日本語     | `t("screen.actionDetail.remindAt")` に置換                                         |
| ✅  | RhythmInteractiveChart "Now"英語           | `t("chart.now")` に置換                                                            |
| ✅  | RhythmInteractiveChart "Peak Focus"英語    | `t("screen.rhythm.labels.peakFocus")` に置換                                       |
| ✅  | RhythmInteractiveChart "Afternoon Dip"英語 | `t("screen.rhythm.labels.afternoonDip")` に置換                                    |
| ✅  | HealthMetricDetail "Most Recent"英語       | `t("detail.health.mostRecent")` に置換                                             |
| ✅  | HealthMetricDetail "Baseline"英語          | `t("detail.health.baseline")` に置換                                               |
| ✅  | rhythmPhaseCalculator.ts マジックナンバー  | `CIRCADIAN_PHASE_OFFSETS` 定数オブジェクトを `rhythmConstants.ts` に定義           |
| ✅  | alertGenerator.ts 閾値ハードコード         | `ALERT_THRESHOLDS` 定数オブジェクトを `alertConstants.ts` に定義                   |
| ✅  | RhythmInteractiveChart setTimeout 1500     | `TOOLTIP_AUTO_HIDE_DELAY` 定数を `rhythmConstants.ts` に定義                       |

---

## 8. 主要ファイルパス

### 画面コンポーネント

```
app/app/(main)/
├── index.tsx           # Today画面
├── rhythm.tsx          # Rhythm画面
├── recovery-detail.tsx # Recovery詳細
├── sleep-detail.tsx    # Sleep詳細
├── rhythm-detail.tsx   # Rhythm詳細
├── energy-detail.tsx   # Energy詳細
├── action-detail.tsx   # Action詳細
└── insight-detail.tsx  # Insight詳細
```

### 状態管理

```
app/src/stores/
├── healthStore/
│   ├── index.ts        # メインStore
│   ├── types.ts        # 型定義
│   └── selectors.ts    # セレクター
├── insightStore.ts     # AI Insight
├── userStore.ts        # ユーザー設定
└── breatheStore.ts     # 呼吸エクササイズ
```

### ドメインロジック

```
app/src/domain/
├── services/
│   ├── scoreCalculator.ts   # スコア計算
│   ├── rhythmCalculator.ts  # リズム計算
│   └── detailCalculator.ts  # 詳細データ計算
└── models/
    ├── index.ts             # 型エクスポート
    ├── rhythm.ts            # リズム関連型
    └── environment.ts       # 環境データ型
```

### サービス・設定

```
app/src/
├── config/
│   └── dataSource.ts        # Mock/実データ切替設定
├── services/
│   ├── dataSourceAdapter.ts # データソースアダプター
│   └── scoreHistoryStorage.ts # スコア履歴永続化
└── constants/mockData/
    ├── index.ts             # Mockデータエクスポート
    ├── aiResponse.ts        # AIレスポンスMock
    └── health/
        ├── metrics.ts       # HealthKit系Mock
        └── snapshots.ts     # リアルタイムメトリクスMock
```

---

## 9. アーキテクチャの強み

1. **✅ 完全な Mock/実データ分離**

   - `dataSourceAdapter` が統一インターフェースを提供
   - フラグ切替で段階的に実データへ移行可能

2. **✅ スコア計算ロジック完成**

   - 4 スコア（Recovery/Sleep/Rhythm/Energy）の計算式が実装済み
   - 科学的根拠に基づいたアルゴリズム

3. **✅ AI 連携準備完了**

   - `apiClient` 経由での API 呼び出しロジック実装済み
   - Mock/実データの切替が可能

4. **✅ 効率的な状態管理**

   - Zustand + AsyncStorage による永続化
   - セレクターによるメモ化

5. **✅ UI フレームワーク完成**
   - 全画面の UI 実装完了
   - アニメーション対応

---

## 10. 次のステップ

本番リリースに向けた推奨アクション:

1. **最優先**: HealthKitService の実装
2. **高優先**: スコア履歴保存の有効化
3. **高優先**: 空データ時の UI 対応（EmptyState）
4. **中優先**: 段階的な実データ移行（Weather → AI → HealthKit）
5. **中優先**: エラーハンドリング強化

詳細なタスクリストは `docs/TODO_RELEASE.md` を参照。

---

## 11. 最終レビュー ✅ 完了 (2026-01-15)

以下のレビュー項目を実施し、全て対応完了:

- [x] 全画面の数値・テキストがパイプラインを通っているか最終確認 → 10 件の修正完了
- [x] i18n ファイル内に動的であるべき値が固定されていないか確認 → X 軸ラベル、タイムフレームラベル等を i18n 化
- [x] フォールバック値の妥当性確認 → `DEFAULT_*` 定数として明示化

詳細は `docs/MOCK_IMPLEMENTATION_REVIEW.md` を参照。

---

## 12. 新規作成ファイル一覧 (2026-01-15)

| ファイル                                    | 説明                                                                         |
| ------------------------------------------- | ---------------------------------------------------------------------------- |
| `app/src/constants/chartConstants.ts`       | チャート関連の共通定数（SCORE_TYPICAL_RANGE, DATA_STALE_THRESHOLD_HOURS 等） |
| `app/src/constants/environmentConstants.ts` | 環境データのデフォルト値（DEFAULT_ENVIRONMENT_DATA, DEFAULT_LOCATION 等）    |
| `app/src/constants/rhythmConstants.ts`      | サーカディアンリズム定数（CIRCADIAN_PHASE_OFFSETS, TOOLTIP_AUTO_HIDE_DELAY） |
| `app/src/constants/alertConstants.ts`       | アラート閾値定数（ALERT_THRESHOLDS）                                         |

---

## 13. i18n 追加キー一覧 (2026-01-15)

### en.json / ja.json

```json
{
  "chart": {
    "now": "Now",
    "timeAxis": {
      "6am": "6 AM",
      "12pm": "12 PM",
      "6pm": "6 PM",
      "12am": "12 AM",
      "6": "6:00",
      "12": "12:00",
      "18": "18:00",
      "22": "22:00"
    },
    "timeframeLabels": {
      "30d": { "0": "W1", "1": "W2", "2": "W3", "3": "W4", "4": "Now" },
      "60d": { "0": "6w", "1": "4w", "2": "2w", "3": "1w", "4": "Now" }
    }
  },
  "detail": {
    "health": {
      "mostRecent": "Most Recent",
      "baseline": "Baseline"
    }
  },
  "screen": {
    "loading": {
      "recovery": "Loading recovery data...",
      "sleep": "Loading sleep data...",
      "rhythm": "Loading rhythm data...",
      "energy": "Loading energy data...",
      "health": "Loading health data..."
    },
    "settings": {
      "profile": {
        "defaultNickname": "User"
      },
      "resetAlert": {
        "title": "Reset Onboarding",
        "message": "Are you sure you want to reset the onboarding? All settings will be cleared.",
        "cancel": "Cancel",
        "reset": "Reset"
      }
    },
    "healthDetail": {
      "title": "Health",
      "weekdays": {
        "su": "Su",
        "m": "M",
        "t": "T",
        "w": "W",
        "th": "Th",
        "f": "F",
        "sa": "Sa"
      },
      "status": {
        "low": "Low",
        "high": "High"
      }
    },
    "actionDetail": {
      "remindAt": "Remind at"
    },
    "rhythm": {
      "labels": {
        "peakFocus": "Peak Focus",
        "afternoonDip": "Afternoon Dip"
      }
    }
  }
}
```
