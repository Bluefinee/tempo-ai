# Tempo AI リリース準備 TODO

> 作成日: 2026-01-15
> 更新日: 2026-01-15 (Mock統合完了後)

---

## 概要

本ドキュメントは、Tempo AI アプリケーションの本番リリースに向けた残タスクを整理したものです。

### ✅ 完了済み: Mock/実データパイプライン統合

以下のハードコード問題は解決済み:

| 対象 | 問題 | 解決方法 |
|------|------|---------|
| Today画面 chartData | 固定配列 | `useScoreChartDataForToday()` |
| Rhythm Upcoming Windows | i18n固定時間 | `useUpcomingWindows()` |
| Health Detail | 全データハードコード | `createMetrics()` |
| Energy Detail Daily Curve | SVGパス固定 | `generateEnergyCurveSvgPath()` |
| Health Summary Card | レイアウト | 横並びに修正 |

**現状**: `USE_MOCK_HEALTHKIT=false` に切替でHealthKit実データに対応可能

---

## Phase 1: MVP必須タスク

### 🔴 P0: ブロッカー

#### TASK-001: HealthKitService 実装
- **優先度**: 🔴 Critical
- **見積り**: 大
- **説明**: HealthKit からの実データ取得を実装
- **対象メソッド**:
  - [ ] `getSleepMetrics()` - 睡眠データ取得
  - [ ] `getHRVMetrics()` - HRV データ取得
  - [ ] `getActivityMetrics()` - アクティビティデータ取得
  - [ ] `getRhythmAnalysis()` - リズム分析データ取得
  - [ ] `getRealtimeMetrics()` - リアルタイムメトリクス取得
- **関連ファイル**:
  - `app/src/services/dataSourceAdapter.ts` (呼び出し元)
  - `app/src/services/healthKitService.ts` (新規作成)
- **依存関係**: なし
- **ブロック**: 全ての実データ機能

#### TASK-002: HealthKit 履歴データ取得実装
- **優先度**: 🔴 Critical
- **見積り**: 中
- **説明**: 7D/30D/60D の履歴データを HealthKit から取得
- **対象メソッド**:
  - [ ] `getHRVHistory(timeRange)`
  - [ ] `getRHRHistory(timeRange)`
  - [ ] `getRespiratoryHistory(timeRange)`
  - [ ] `getSpO2History(timeRange)`
  - [ ] `getWristTempHistory(timeRange)`
  - [ ] `getSleepTimingHistory(timeRange)`
- **関連ファイル**:
  - `app/src/services/dataSourceAdapter.ts`
- **依存関係**: TASK-001

---

### 🟠 P1: 高優先度

#### TASK-003: スコア履歴 AsyncStorage 保存の有効化
- **優先度**: 🟠 High
- **見積り**: 小
- **説明**: Mock モードでもスコア履歴を保存するように修正
- **現在の問題**: `!DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT` 条件で保存がスキップ
- **対応**:
  - [ ] `healthStore/index.ts` の `calculateDailyScores()` 内の保存条件を見直し
  - [ ] 開発環境でも AsyncStorage の動作検証を可能に
- **関連ファイル**:
  - `app/src/stores/healthStore/index.ts`
  - `app/src/services/scoreHistoryStorage.ts`

#### TASK-004: 空データ時の UI 表示 (EmptyState)
- **優先度**: 🟠 High
- **見積り**: 小
- **説明**: データがない場合のフォールバック UI を実装
- **対象画面**:
  - [ ] Today 画面 - スコアが null の場合
  - [ ] 詳細画面 - チャートデータが空の場合
  - [ ] Rhythm 画面 - エネルギーカーブがない場合
- **コンポーネント**:
  - [ ] `EmptyChartState` コンポーネント作成
  - [ ] `EmptyScoreState` コンポーネント作成
- **関連ファイル**:
  - `app/src/components/` (新規)
  - 各画面ファイル

#### TASK-005: エラーハンドリング強化
- **優先度**: 🟠 High
- **見積り**: 中
- **説明**: API エラー、データ取得エラー時の適切なハンドリング
- **対応**:
  - [ ] `dataSourceAdapter` の try-catch 強化
  - [ ] Store の error state 追加
  - [ ] UI でのエラー表示コンポーネント
  - [ ] リトライ機構の実装
- **関連ファイル**:
  - `app/src/services/dataSourceAdapter.ts`
  - `app/src/stores/healthStore/index.ts`

---

## Phase 2: 品質向上タスク

### 🟡 P2: 中優先度

#### TASK-006: 環境データ完全実装
- **優先度**: 🟡 Medium
- **見積り**: 小
- **説明**: UV index、湿度、気圧24h変化の実データ対応
- **現在の問題**: ハードコード値を使用
- **対応**:
  - [ ] Weather API から UV index を取得（API 拡張後）
  - [ ] Weather API から湿度を取得
  - [ ] 気圧の24時間変化を計算するロジック追加
- **関連ファイル**:
  - `app/src/services/dataSourceAdapter.ts` (178, 183, 186行目の TODO)

#### TASK-007: USE_MOCK_DATA フラグ一元化
- **優先度**: 🟡 Medium
- **見積り**: 小
- **説明**: マスタースイッチとして機能するように改善
- **現在の問題**: `USE_MOCK_DATA` は insightStore でのみ使用
- **対応**:
  - [ ] 全フラグを `USE_MOCK_DATA` で制御可能に
  - [ ] または `USE_MOCK_DATA` を削除して個別フラグに統一
- **関連ファイル**:
  - `app/src/config/dataSource.ts`
  - `app/src/services/dataSourceAdapter.ts`
  - `app/src/stores/insightStore.ts`

#### TASK-008: 単体テスト追加（スコア計算）
- **優先度**: 🟡 Medium
- **見積り**: 中
- **説明**: スコア計算ロジックの単体テスト
- **対象**:
  - [ ] `calculateRecoveryScore()` のテスト
  - [ ] `calculateSleepScore()` のテスト
  - [ ] `calculateRhythmScore()` のテスト
  - [ ] `calculateEnergyScore()` のテスト
  - [ ] `calculateEnergyCurve()` のテスト
- **関連ファイル**:
  - `app/src/domain/services/scoreCalculator.ts`
  - `app/src/domain/services/rhythmCalculator.ts`
  - `app/__tests__/` (新規)

---

### 🟢 P3: 低優先度

#### TASK-009: 環境変数管理整備
- **優先度**: 🟢 Low
- **見積り**: 小
- **説明**: .env ファイルの分割と管理整備
- **対応**:
  - [ ] `.env.development` 作成
  - [ ] `.env.production` 作成
  - [ ] `.env.example` 更新
  - [ ] 環境別設定の切り替えロジック

#### TASK-010: E2E テスト追加
- **優先度**: 🟢 Low
- **見積り**: 大
- **説明**: 主要フローの E2E テスト
- **対象フロー**:
  - [ ] アプリ起動 → Today 画面表示
  - [ ] スコアカードタップ → 詳細画面遷移
  - [ ] Rhythm タブ → リズム画面表示
  - [ ] 期間切替（7D/30D/60D）動作確認

---

## Phase 3: 拡張機能タスク

### 🔵 Future

#### TASK-011: リマインダー機能実装
- **優先度**: 🔵 Future
- **見積り**: 中
- **説明**: Today's One Thing のリマインダー通知
- **対応**:
  - [ ] ローカル通知の設定
  - [ ] 通知スケジュール管理
  - [ ] ユーザー設定 UI

#### TASK-012: Apple Watch 連携
- **優先度**: 🔵 Future
- **見積り**: 大
- **説明**: watchOS コンパニオンアプリ
- **対応**:
  - [ ] Watch App 基盤構築
  - [ ] スコア表示
  - [ ] コンプリケーション対応

#### TASK-013: ウィジェット対応
- **優先度**: 🔵 Future
- **見積り**: 中
- **説明**: iOS ホーム画面ウィジェット
- **対応**:
  - [ ] WidgetKit 設定
  - [ ] スコア表示ウィジェット
  - [ ] Today's One Thing ウィジェット

---

## 完了済みタスク (2026-01-15)

### ✅ TASK-PRE: Mock/実データパイプライン統合
- **状態**: ✅ 完了
- **内容**:
  - [x] Today画面 4スコアchartData → `useScoreChartDataForToday()` フック追加
  - [x] Rhythm Upcoming Windows時間 → `useUpcomingWindows()` フック追加
  - [x] Health Detail全メトリクス → `createMetrics()` 関数で動的化
  - [x] Energy Detail Daily Curve SVG → `generateEnergyCurveSvgPath()` で動的化
  - [x] Health Summary Card レイアウト修正
- **関連ファイル**:
  - `app/src/stores/healthStore/selectors.ts`
  - `app/app/(main)/index.tsx`
  - `app/app/(main)/rhythm.tsx`
  - `app/app/(main)/health-detail.tsx`
  - `app/app/(main)/energy-detail.tsx`
  - `app/src/components/today/HealthSummaryCard.tsx`

### ✅ TASK-REVIEW: ハードコードレビュー＆修正
- **状態**: ✅ 完了
- **内容**: `docs/MOCK_IMPLEMENTATION_REVIEW.md` のレビュー結果に基づく10件の修正
  - [x] Fix 1: settings.tsx - MOCK_DATA → userStore動的取得
  - [x] Fix 2: health-detail.tsx - Baseline値 → realtimeMetricsから動的取得
  - [x] Fix 3: healthStore/index.ts - 目標睡眠時間 → onboarding.ts定数化
  - [x] Fix 4: rhythm.tsx - 日付配列 → formatDate() + getLocale()でi18n化
  - [x] Fix 5: RhythmInteractiveChart.tsx - X軸ラベル → i18n化
  - [x] Fix 6: HealthMetricDetail.tsx - タイムフレームラベル → i18n化
  - [x] Fix 7: energy-detail.tsx - 時間軸ラベル → i18n化
  - [x] Fix 8: breathe.tsx - HEXカラー → BREATHE_COLORS定数化
  - [x] Fix 9: 各Detail画面 - typicalRange → chartConstants.ts共通化
  - [x] Fix 10: selectors.ts - データ鮮度閾値 → DATA_STALE_THRESHOLD_HOURS定数化
- **新規作成ファイル**:
  - `app/src/constants/chartConstants.ts`
- **関連ファイル**:
  - `app/app/(main)/settings.tsx`
  - `app/app/(main)/health-detail.tsx`
  - `app/app/(main)/rhythm.tsx`
  - `app/app/(main)/energy-detail.tsx`
  - `app/app/(main)/breathe.tsx`
  - `app/app/(main)/recovery-detail.tsx`
  - `app/app/(main)/sleep-detail.tsx`
  - `app/app/(main)/rhythm-detail.tsx`
  - `app/src/stores/healthStore/index.ts`
  - `app/src/stores/healthStore/selectors.ts`
  - `app/src/components/HealthMetricDetail.tsx`
  - `app/src/components/RhythmInteractiveChart.tsx`
  - `app/src/domain/models/onboarding.ts`
  - `app/src/i18n/locales/en.json`
  - `app/src/i18n/locales/ja.json`

### ✅ TASK-AUDIT: 第三者監査レビュー＆修正
- **状態**: ✅ 完了
- **内容**: `docs/DATA_PIPELINE_AUDIT_REPORT.md` の監査結果に基づく23件のNG項目修正
  - [x] P0-1: TOTAL_ONBOARDING_STEPS矛盾 → userStore.tsでonboarding.tsから定数インポート
  - [x] P0-2: healthStore初期化時刻ハードコード → DEFAULT_WAKE_UP_TIME/BED_TIME参照に変更
  - [x] P1-1: rhythm.tsx DEFAULT_ENVIRONMENT_DATA → environmentConstants.tsに分離
  - [x] P1-2: settings.tsx Alert日本語 → i18n化
  - [x] P1-3: 各detail画面Loading英語 → i18n化（recovery, sleep, rhythm, energy）
  - [x] P1-4: health-detail.tsx 曜日・ステータス・タイトル → i18n化
  - [x] P1-5: action-detail.tsx "にリマインド" → i18n化
  - [x] P1-6: RhythmInteractiveChart "Now"/"Peak Focus"/"Afternoon Dip" → i18n化
  - [x] P1-7: HealthMetricDetail "Most Recent"/"Baseline" → i18n化
  - [x] P1-8: rhythmPhaseCalculator.ts マジックナンバー → CIRCADIAN_PHASE_OFFSETS定数化
  - [x] P1-9: alertGenerator.ts 閾値 → ALERT_THRESHOLDS定数化
  - [x] P2-1: RhythmInteractiveChart setTimeout 1500ms → TOOLTIP_AUTO_HIDE_DELAY定数化
- **新規作成ファイル**:
  - `app/src/constants/environmentConstants.ts`
  - `app/src/constants/rhythmConstants.ts`
  - `app/src/constants/alertConstants.ts`
- **関連ファイル**:
  - `app/src/stores/userStore.ts`
  - `app/src/stores/healthStore/index.ts`
  - `app/app/(main)/rhythm.tsx`
  - `app/app/(main)/settings.tsx`
  - `app/app/(main)/recovery-detail.tsx`
  - `app/app/(main)/sleep-detail.tsx`
  - `app/app/(main)/rhythm-detail.tsx`
  - `app/app/(main)/energy-detail.tsx`
  - `app/app/(main)/health-detail.tsx`
  - `app/app/(main)/action-detail.tsx`
  - `app/src/components/RhythmInteractiveChart.tsx`
  - `app/src/components/HealthMetricDetail.tsx`
  - `app/src/domain/services/rhythmPhaseCalculator.ts`
  - `app/src/domain/services/alertGenerator.ts`
  - `app/src/i18n/locales/en.json`
  - `app/src/i18n/locales/ja.json`
  - `app/src/constants/index.ts`

---

## タスク進捗サマリー

| Phase | 総数 | 完了 | 進行中 | 未着手 |
|-------|------|------|--------|--------|
| Pre-release (パイプライン統合) | 1 | 1 | 0 | 0 |
| Pre-release (ハードコードレビュー) | 1 | 1 | 0 | 0 |
| Pre-release (第三者監査レビュー) | 1 | 1 | 0 | 0 |
| Phase 1 (MVP) | 5 | 0 | 0 | 5 |
| Phase 2 (品質) | 5 | 0 | 0 | 5 |
| Phase 3 (拡張) | 3 | 0 | 0 | 3 |
| **合計** | **16** | **3** | **0** | **13** |

---

## リリースクライテリア

### Pre-release 条件 ✅
- [x] TASK-PRE: Mock/実データパイプライン統合 ✅ 完了
- [x] TASK-REVIEW: ハードコードレビュー＆修正 ✅ 完了
- [x] TASK-AUDIT: 第三者監査レビュー＆修正 ✅ 完了

### MVP リリース条件
- [ ] TASK-001: HealthKitService 実装完了
- [ ] TASK-002: HealthKit 履歴データ取得完了
- [ ] TASK-003: スコア履歴保存有効化
- [ ] TASK-004: 空データ UI 対応
- [ ] TASK-005: 基本的なエラーハンドリング

### 品質リリース条件
- [ ] 上記 MVP 条件すべて
- [ ] TASK-006: 環境データ完全実装
- [ ] TASK-008: 単体テストカバレッジ 80%以上

---

## 最終レビュー ✅ 完了 (2026-01-15)

以下のレビュー項目を実施し、全て対応完了:
- [x] 全画面の数値・テキストがパイプラインを通っているか最終確認 → 10件の修正完了
- [x] i18nファイル内に動的であるべき値が固定されていないか確認 → X軸ラベル、タイムフレームラベル等をi18n化
- [x] フォールバック値の妥当性確認 → `DEFAULT_*` 定数として明示化

詳細は `docs/MOCK_IMPLEMENTATION_REVIEW.md` を参照。

## 第三者監査レビュー ✅ 完了 (2026-01-15)

`docs/DATA_PIPELINE_AUDIT_REPORT.md` による網羅的監査（23件NG / 47件要確認 / 55件OK）の結果に基づき、全23件のNG項目を修正完了:
- [x] P0: TOTAL_ONBOARDING_STEPS矛盾解消、healthStore初期化時刻定数化
- [x] P1: 12ファイルにわたるi18n未対応テキストの修正
- [x] P1: サーカディアンリズムフェーズオフセット定数化（CIRCADIAN_PHASE_OFFSETS）
- [x] P1: アラート閾値定数化（ALERT_THRESHOLDS）
- [x] P2: ツールチップタイムアウト定数化（TOOLTIP_AUTO_HIDE_DELAY）

詳細は `docs/DATA_PIPELINE_AUDIT_REPORT.md` を参照。

---

## 関連ドキュメント

- [実装状況レポート](./IMPLEMENTATION_STATUS.md)
- [プロダクト仕様書](./specs/tempoai_product_spec.md)
- [技術仕様書](./specs/tempoai_technical_spec.md)
- [メトリクス仕様書](./specs/tempoai_metrics_spec.md)
