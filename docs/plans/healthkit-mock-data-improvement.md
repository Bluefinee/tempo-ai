# HealthKit対応モックデータ改善計画

## 概要

HealthKit Statistics Query のベストプラクティスに基づき、モックデータ構造を改善する。

| 項目 | 内容 |
|------|------|
| 取得方式 | 統計クエリ（日ごとの集計値） |
| データ粒度 | 日次集計のみ（1日1レコード） |
| スコープ | モックデータ構造の改善 |

---

## データ更新タイミング要件

### 朝1回算出（起床時刻連動）
- **対象**: スコア（回復、睡眠、リズム、エネルギー）、AIアドバイス、今日のワンアクション
- **タイミング**: ユーザーの起床時刻から30分後
- **理由**: 「今日1日の状態」を表すため、1日を通して一貫した値を表示

### リアルタイム更新（アプリ起動ごと）
- **対象**: 全ヘルスメトリクス（HRV、RHR、呼吸数、SpO2、体温）
- **タイミング**: アプリを開くたびに最新データを取得
- **理由**: 現在の身体状態をリアルタイムで把握

---

## Stage 1: 型定義の作成

**Goal**: HealthKit Statistics Query に対応した型定義を作成

**Success Criteria**:
- [ ] `DailyHealthSample` 型が Date を含む
- [ ] `HealthMetricHistory` 型がベースライン・典型範囲を含む
- [ ] `DailySnapshot` / `RealtimeMetrics` 型で更新タイミングを区別
- [ ] TypeScript strict mode でエラーなし

**Tests**: 型定義のみのため、コンパイルテスト

**Status**: Complete

**Files**:
- `app/src/domain/models/healthHistory.ts`（新規）
- `app/src/domain/models/index.ts`（変更）

**実装内容**:

```typescript
/**
 * HealthKit Statistics Query に対応した日次サンプル型
 * @see https://developer.apple.com/documentation/healthkit/hkstatisticscollectionquery
 */
export interface DailyHealthSample {
  /** 日の開始時刻 (00:00:00) */
  date: Date;
  /** 日次集計値（mean/sum depending on metric） */
  value: number;
  /** 集計元のサンプル数（オプション） */
  sampleCount?: number;
}

export type HealthTimeRange = '7D' | '30D' | '60D';

export type HealthMetricType =
  | 'hrv' | 'rhr' | 'respiratory' | 'spo2' | 'wristTemp'
  | 'recoveryScore' | 'sleepScore' | 'rhythmScore' | 'energyScore';

/**
 * メトリクス履歴（ベースライン付き）
 * 将来の HealthKit 統合時にそのまま使用可能な構造
 */
export interface HealthMetricHistory {
  metricType: HealthMetricType;
  samples: DailyHealthSample[];
  /** 60日ローリング平均 */
  baseline: number;
  typicalRange: {
    min: number;
    max: number;
    /** 14日以上のデータがあれば 'personal'、なければ 'default' */
    source: 'personal' | 'default';
  };
  lastUpdated: Date;
}

/**
 * 日次スナップショット（朝1回算出、その日は固定）
 */
export interface DailySnapshot {
  /** 算出日 (YYYY-MM-DD) */
  date: string;
  /** 算出時刻 */
  calculatedAt: Date;
  scores: {
    recovery: number;
    sleep: number;
    rhythm: number;
    energy: number;
  };
}

/**
 * リアルタイムメトリクス（アプリ起動ごとに更新）
 */
export interface RealtimeHealthMetric {
  value: number;
  unit: string;
  baseline: number;
  deviationPercent: number;
  lastUpdated: Date;
}

export interface RealtimeMetrics {
  hrv: RealtimeHealthMetric;
  rhr: RealtimeHealthMetric;
  respiratory: RealtimeHealthMetric;
  spo2: RealtimeHealthMetric;
  wristTemp: RealtimeHealthMetric;
}
```

---

## Stage 2: モックデータファクトリの作成

**Goal**: リアルなモックデータを生成するファクトリ関数を作成

**Success Criteria**:
- [ ] `generateDailySamples()` が Date 付きのサンプルを生成
- [ ] `calculateBaseline()` が正しい平均を計算
- [ ] `calculateTypicalRange()` が P5/P95 を計算
- [ ] シード値により再現可能なデータ生成
- [ ] 単体テストが通る

**Tests**:
- `generateDailySamples(70, 10, 7, 42)` が 7 つの DailyHealthSample を返す
- `calculateBaseline([...], 30)` が直近 30 日の平均を返す
- 同じシードで同じ結果が得られる

**Status**: Complete

**Files**:
- `app/src/constants/mockDataFactory.ts`（新規）
- `app/src/constants/mockDataFactory.test.ts`（新規）

---

## Stage 3: データ変換ユーティリティの作成

**Goal**: HealthKit 形式から UI 表示形式への変換関数を作成

**Success Criteria**:
- [ ] `toBarChartData()` が BarChart 用の `{ label, value }[]` を返す
- [ ] 7D は曜日ラベル、30D/60D は数字ラベル
- [ ] locale パラメータで日本語/英語切り替え
- [ ] 単体テストが通る

**Tests**:
- `toBarChartData(samples, '7D', 'ja')` が `['月', '火', ...]` 形式を返す
- `toBarChartData(samples, '30D', 'ja')` が `['1', '2', ..., '30']` 形式を返す

**Status**: Complete

**Files**:
- `app/src/utils/healthDataTransformer.ts`（新規）
- `app/src/utils/healthDataTransformer.test.ts`（新規）
- `app/src/utils/index.ts`（新規/変更）

---

## Stage 4: MOCK_DETAIL_V2 の作成

**Goal**: 既存の mockData.ts に新しい HealthKit 対応データを追加

**Success Criteria**:
- [ ] `MOCK_DETAIL_V2` が新しい型を使用
- [ ] 既存の `MOCK_DETAIL` は後方互換性のため維持
- [ ] `rawHistory` プロパティで Date 付きデータにアクセス可能
- [ ] `history` getter で従来形式も取得可能

**Tests**:
- `MOCK_DETAIL_V2.recovery.rawHistory.samples[0].date` が Date 型
- `MOCK_DETAIL_V2.recovery.history['7D'][0].label` が string 型

**Status**: Complete

**Files**:
- `app/src/constants/mockData.ts`（変更）

---

## Stage 5: healthStore の更新

**Goal**: DailySnapshot と RealtimeMetrics の管理ロジックを追加

**Success Criteria**:
- [ ] `dailySnapshot` state が追加される
- [ ] `realtimeMetrics` state が追加される
- [ ] `shouldCalculateSnapshot()` が今日まだ算出していないか判定
- [ ] `calculateDailySnapshot()` が朝1回のみスコアを算出
- [ ] `fetchRealtimeMetrics()` が毎回メトリクスを取得
- [ ] AsyncStorage に永続化される

**Tests**:
- 同じ日に2回 `calculateDailySnapshot()` を呼んでも1回目の値を返す
- 日付が変わると新しいスナップショットを算出

**Status**: Complete

**Files**:
- `app/src/stores/healthStore.ts`（変更）

---

## 変更対象ファイル一覧

| ファイル | 操作 | 説明 |
|---------|------|------|
| `app/src/domain/models/healthHistory.ts` | 新規 | HealthKit 対応型定義 |
| `app/src/domain/models/index.ts` | 変更 | 新型のエクスポート |
| `app/src/constants/mockDataFactory.ts` | 新規 | モックデータ生成ファクトリ |
| `app/src/constants/mockDataFactory.test.ts` | 新規 | ファクトリのテスト |
| `app/src/utils/healthDataTransformer.ts` | 新規 | データ変換ユーティリティ |
| `app/src/utils/healthDataTransformer.test.ts` | 新規 | 変換関数のテスト |
| `app/src/utils/index.ts` | 新規/変更 | 変換関数のエクスポート |
| `app/src/constants/mockData.ts` | 変更 | MOCK_DETAIL_V2 追加 |
| `app/src/stores/healthStore.ts` | 変更 | DailySnapshot/RealtimeMetrics 管理 |

---

## 設計原則

### HealthKit ベストプラクティス

1. **Statistics Query 前提**: 日ごとの集計値（mean/sum）を基本データ単位とする。60日分でも高速。
2. **Date 中心のデータモデル**: すべての履歴データに実際の Date 型を持たせる。表示ラベルは変換時に生成。

### アーキテクチャ（CLAUDE.md 準拠）

```
Presentation → Application → Domain → Infrastructure
                               ↓
                         ビジネスロジック集約
                         （ベースライン計算、トレンド分析）
```

### コード規約（react-native-standards.md 準拠）

- Arrow functions + 明示的戻り値型
- `any` 禁止、`unknown` + 型ガード使用
- JSDoc for public APIs
- Repository パターンで将来の HealthKit 実装に備える

---

## グラフ表示の最適化

| 期間 | データ点数 | ラベル形式 | 集約方法 |
|------|----------|-----------|---------|
| 7D   | 7点      | 曜日（月火水...） | 日次そのまま |
| 30D  | 30点     | 日付（1, 2, 3...30） | 日次そのまま |
| 60D  | 60点     | 日付（1, 2...60） | 日次そのまま |

**推奨**: HealthAreaChart のタッチ操作を活かし、60点すべて表示（現状維持）

---

## 将来の HealthKit 統合時の利点

1. **最小限の変更**: ファクトリ関数を実 HealthKit クエリに置き換えるだけ
2. **型安全性**: HealthKit 応答と同じ型を使用、コンパイル時にエラー検出
3. **パフォーマンス最適化**: 統計クエリ使用が型で強制される

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-07 | 初版作成 |
| 1.1 | 2026-01-07 | 全Stage実装完了 |
