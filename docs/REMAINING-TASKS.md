# 残りタスク詳細（PR #60対応用）

## 📊 概要

**作成日**: 2026-01-07  
**対象PR**: #60  
**前回完了**: PR #59 - Major Issues 31/99件完了  
**残りタスク**: 68件  
**優先度**: Low〜Medium

---

## ✅ 前回完了サマリー（参考）

### 完了内容
- ✅ Critical Issues: 3/3 (100%)
- ✅ TypeScript Errors: 0
- ✅ ESLint Errors: 0
- ✅ ヘルパー関数型付け: 7件
- ✅ 未使用インポート・変数削除: 15+件
- ✅ `Array<T>` → `T[]`: 2箇所
- ✅ インラインスタイル → StyleSheet: 2ファイル

### 現在の状態
```bash
✅ TypeScript: PASS (0 errors)
✅ ESLint: PASS (0 errors, 47 warnings)
✅ Build: Ready
✅ 本番デプロイ可能
```

---

## 🎯 残りタスク一覧（68件）

### カテゴリ1: 未使用型エクスポート削除（低優先度）

#### 対象ファイル: `app/src/constants/mockData/health/details.ts`

**削除対象（12件）**:
```typescript
// 以下の未使用型インポート/エクスポートを削除または修正

// Line 7-21: 未使用型インポート
import {
  HealthMetrics,        // ❌ 未使用
  SleepMetrics,         // ❌ 未使用
  HRVMetrics,          // ❌ 未使用
  ActivityMetrics,     // ❌ 未使用
  RhythmAnalysis,      // ❌ 未使用
  DailyScoreSnapshot,  // ❌ 未使用
  QuickAction,         // ❌ 未使用
  RecommendedAction,   // ❌ 未使用
  SimpleWeatherData,   // ❌ 未使用
  // ...
  DailySnapshot,       // ❌ 未使用
  RealtimeMetrics,     // ❌ 未使用
  RealtimeHealthMetric,// ❌ 未使用
} from "../../domain/models";

// Line 25-32: 未使用関数エクスポート
export {
  getMockMetricHistory,           // ❌ 未使用
  getAllHealthMetricHistories,    // ❌ 未使用
  formatDateString,               // ❌ 未使用
  calculateDeviationPercent,      // ❌ 未使用
};
```

**修正方法**:
```typescript
// Option 1: 削除（推奨）
// 使用していない場合は削除

// Option 2: コメントアウト（将来使用予定の場合）
// import {
//   HealthMetrics,  // TODO: 将来使用予定
// } from "../../domain/models";
```

**優先度**: Low  
**理由**: 実行時エラーなし、将来的に使用する可能性あり

---

#### 対象ファイル: `app/src/constants/mockData/health/metrics.ts`

**削除対象（10件）**:
```typescript
// Line 18-22: 未使用型インポート
import {
  HealthMetricHistory,   // ❌ 未使用
  DailySnapshot,         // ❌ 未使用
  RealtimeMetrics,       // ❌ 未使用
  RealtimeHealthMetric,  // ❌ 未使用
  BarChartDataPoint,     // ❌ 未使用
} from "../../domain/models";

// Line 25-32: 未使用関数エクスポート
export {
  getMockMetricHistory,           // ❌ 未使用
  getAllScoreHistories,           // ❌ 未使用
  getAllHealthMetricHistories,    // ❌ 未使用
  formatDateString,               // ❌ 未使用
  toBarChartData,                 // ❌ 未使用
  calculateDeviationPercent,      // ❌ 未使用
};
```

**優先度**: Low

---

#### 対象ファイル: `app/src/constants/mockData/health/snapshots.ts`

**削除対象（10件）**:
```typescript
// Line 7-22: 未使用型インポート
import {
  HealthMetrics,         // ❌ 未使用
  SleepMetrics,          // ❌ 未使用
  HRVMetrics,           // ❌ 未使用
  ActivityMetrics,      // ❌ 未使用
  RhythmAnalysis,       // ❌ 未使用
  DailyScoreSnapshot,   // ❌ 未使用
  QuickAction,          // ❌ 未使用
  RecommendedAction,    // ❌ 未使用
  SimpleWeatherData,    // ❌ 未使用
  HealthMetricHistory,  // ❌ 未使用
  BarChartDataPoint,    // ❌ 未使用
} from "../../domain/models";
```

**優先度**: Low

---

### カテゴリ2: React Hooks依存配列（中優先度）

#### 対象ファイル: `app/src/components/CircularProgress.tsx`

**問題（Line 44）**:
```typescript
React.useEffect(() => {
  progressValue.value = withTiming(progress, { duration: 600 });
}, [progress]); // ⚠️ 'progressValue' is missing
```

**修正方法**:
```typescript
// Option 1: 依存配列に追加（推奨）
React.useEffect(() => {
  progressValue.value = withTiming(progress, { duration: 600 });
}, [progress, progressValue]);

// Option 2: ESLint無効化（意図的な最適化の場合）
React.useEffect(() => {
  progressValue.value = withTiming(progress, { duration: 600 });
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [progress]);
```

**優先度**: Medium  
**理由**: アニメーションの動作に影響する可能性あり

---

#### 対象ファイル: `app/src/components/DualRingProgress.tsx`

**問題（Line 56）**:
```typescript
React.useEffect(() => {
  outerProgressValue.value = withTiming(outerProgress, { duration: 800 });
  innerProgressValue.value = withDelay(
    100,
    withTiming(innerProgress, { duration: 800 })
  );
}, [outerProgress, innerProgress]); 
// ⚠️ 'innerProgressValue' and 'outerProgressValue' are missing
```

**修正方法**:
```typescript
React.useEffect(() => {
  outerProgressValue.value = withTiming(outerProgress, { duration: 800 });
  innerProgressValue.value = withDelay(
    100,
    withTiming(innerProgress, { duration: 800 })
  );
}, [outerProgress, innerProgress, outerProgressValue, innerProgressValue]);
```

**優先度**: Medium

---

#### 対象ファイル: `app/src/components/HealthAreaChart.tsx`

**問題（Line 155）**:
```typescript
const chartElement = useMemo(() => (
  <Svg width={width} height={height}>
    {/* ... */}
  </Svg>
), [width, height, points, gradientStops, yScaleFormatter, formatLabel]); 
// ⚠️ 'handleTouch' is missing
```

**修正方法**:
```typescript
const chartElement = useMemo(() => (
  <Svg width={width} height={height}>
    {/* ... */}
  </Svg>
), [width, height, points, gradientStops, yScaleFormatter, formatLabel, handleTouch]);
```

**優先度**: Medium  
**理由**: タッチ操作の動作に影響する可能性あり

---

### カテゴリ3: import/first warnings（低優先度）

#### 対象ファイル: `app/app/(main)/action-detail.tsx`

**問題（Line 31）**:
```typescript
import { useFadeIn } from '../../src/hooks/useFadeIn';
import { MOCK_DETAIL } from "../../src/constants/mockData";
import { MOCK_AI_RESPONSE } from "../../src/constants/mockData";
// ... other imports ...

const { t, locale } = i18n; // ⚠️ Line 31: Import in body of module
```

**修正方法**:
```typescript
// すべてのimportをファイル先頭に移動
import { useFadeIn } from '../../src/hooks/useFadeIn';
import { MOCK_DETAIL } from "../../src/constants/mockData";
import { MOCK_AI_RESPONSE } from "../../src/constants/mockData";
import { i18n } from '../../src/i18n';

// その後に変数定義
const { t, locale } = i18n;
```

**優先度**: Low  
**理由**: 実行時エラーなし、コードスタイルの問題のみ

---

#### 対象ファイル: `app/app/(main)/settings.tsx`

**問題（Line 43）**:
```typescript
const { t } = i18n; // ⚠️ Line 43: Import in body of module
```

**修正方法**: `action-detail.tsx`と同様

**優先度**: Low

---

### カテゴリ4: インラインスタイル → StyleSheet（中優先度）

#### 残り対象ファイル（推定8-10ファイル）:

1. **`app/app/(main)/sleep-detail.tsx`**
   - 推定15箇所のインラインスタイル
   - `style={{ gap: 32 }}`, `style={{ fontFamily: FontFamily.serif }}` 等

2. **`app/app/(main)/rhythm-detail.tsx`**
   - 推定10箇所のインラインスタイル

3. **`app/app/(main)/health-detail.tsx`**
   - 推定12箇所のインラインスタイル

4. **`app/app/(main)/insights.tsx`**
   - 推定8箇所のインラインスタイル

5. **`app/app/(main)/insight-detail.tsx`**
   - 推定10箇所のインラインスタイル

6. **`app/app/(main)/breathe.tsx`**
   - 推定8箇所のインラインスタイル

7. **`app/app/(main)/rhythm.tsx`**
   - 推定12箇所のインラインスタイル

8. **`app/app/(main)/index.tsx` (Today画面)**
   - 推定15箇所のインラインスタイル

**修正パターン**:
```typescript
// Before
<View style={{ gap: 32 }}>
<Text style={{ fontFamily: FontFamily.serif }}>
<View style={{
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 4 },
  shadowOpacity: 0.06,
  shadowRadius: 10,
  elevation: 4,
}}>

// After
<View style={styles.container}>
<Text style={styles.scoreText}>
<View style={styles.cardShadow}>

const styles = StyleSheet.create({
  container: {
    gap: 32,
  },
  scoreText: {
    fontFamily: FontFamily.serif,
  },
  cardShadow: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 4,
  },
});
```

**優先度**: Medium  
**理由**: パフォーマンス向上、保守性向上

**推定作業時間**: 各ファイル15-30分 × 8ファイル = 2-4時間

---

### カテゴリ5: デザイントークン統一（中優先度）

#### 対象: ハードコードされた色・サイズの統一

**検索対象**:
```bash
# ハードコードされた色
grep -r "shadowColor: '#000'" app/app --include="*.tsx"
grep -r "backgroundColor: '#" app/app --include="*.tsx"
grep -r "color: '#" app/app --include="*.tsx"

# ハードコードされたサイズ
grep -r "gap: [0-9]" app/app --include="*.tsx"
grep -r "height: [0-9]" app/app --include="*.tsx"
```

**修正パターン**:
```typescript
// Before
shadowColor: '#000'
backgroundColor: '#10b981'
color: '#666'

// After
shadowColor: colors.black
backgroundColor: colors.emerald[500]
color: colors.stone[500]
```

**優先度**: Medium  
**理由**: デザインシステムの一貫性

**推定作業時間**: 2-3時間

---

### カテゴリ6: その他の軽微な改善（低優先度）

#### 6-1: `energyCurveGenerator.ts` 未使用変数

**ファイル**: `app/src/domain/services/energyCurveGenerator.ts`  
**Line**: 49

**問題**:
```typescript
const hoursToBedtime = // ... 計算 ...
// ⚠️ 'hoursToBedtime' is assigned but never used
```

**修正方法**:
```typescript
// Option 1: 削除
// const hoursToBedtime = ...

// Option 2: 使用する
const adjustment = hoursToBedtime > 2 ? 0.1 : 0;
```

**優先度**: Low

---

#### 6-2: コメント・ドキュメント追加

以下のファイルにJSDoc/コメント追加を推奨:

1. `app/src/domain/services/scoreCalculator.ts`
   - 各計算関数にJSDoc追加
   - 計算ロジックの説明追加

2. `app/src/domain/services/rhythmPhaseCalculator.ts`
   - フェーズ計算ロジックの説明追加

3. `app/src/services/dataSourceAdapter.ts`
   - Mock/Real切り替えロジックの説明追加

**優先度**: Low  
**推定作業時間**: 1-2時間

---

#### 6-3: テストカバレッジ向上

以下のファイルのユニットテスト追加を推奨:

1. `app/src/domain/services/scoreCalculator.ts`
2. `app/src/domain/services/rhythmPhaseCalculator.ts`
3. `app/src/domain/services/energyCurveGenerator.ts`

**優先度**: Low（機能追加後に実施推奨）

---

## 📋 実施手順（推奨）

### Phase 1: 高優先度タスク（推定4-6時間）

1. **React Hooks依存配列修正（3ファイル）**
   - `CircularProgress.tsx`
   - `DualRingProgress.tsx`
   - `HealthAreaChart.tsx`
   
   **目標**: アニメーション・インタラクションの安定性向上

2. **インラインスタイル → StyleSheet（主要4ファイル）**
   - `sleep-detail.tsx`
   - `rhythm.tsx`
   - `index.tsx` (Today画面)
   - `health-detail.tsx`
   
   **目標**: パフォーマンス向上

---

### Phase 2: 中優先度タスク（推定2-3時間）

3. **デザイントークン統一**
   - ハードコードされた色をcolors.*に置換
   - 繰り返し使用されるサイズ値を定数化

4. **インラインスタイル → StyleSheet（残り4ファイル）**
   - `rhythm-detail.tsx`
   - `insights.tsx`
   - `insight-detail.tsx`
   - `breathe.tsx`

---

### Phase 3: 低優先度タスク（推定2-3時間）

5. **未使用型エクスポート削除**
   - `mockData/health/details.ts`
   - `mockData/health/metrics.ts`
   - `mockData/health/snapshots.ts`

6. **import/first warnings修正**
   - `action-detail.tsx`
   - `settings.tsx`

7. **未使用変数削除**
   - `energyCurveGenerator.ts`

---

### Phase 4: オプショナル（推定3-4時間）

8. **コメント・ドキュメント追加**
9. **テストカバレッジ向上**

---

## 🎯 成功基準

### 必須（Phase 1-2完了時）
- ✅ ESLint Warnings: 47 → 10以下
- ✅ パフォーマンス: 全画面でStyleSheet使用
- ✅ デザインシステム: 色・サイズの90%がトークン化

### 推奨（Phase 3完了時）
- ✅ ESLint Warnings: 10 → 0
- ✅ コードクリーンネス: 未使用コード0

### オプショナル（Phase 4完了時）
- ✅ ドキュメント: 主要関数にJSDoc
- ✅ テスト: カバレッジ60%以上

---

## 📊 推定作業時間

| Phase | タスク | 時間 | 優先度 |
|-------|--------|------|--------|
| Phase 1 | React Hooks + StyleSheet (4ファイル) | 4-6h | High |
| Phase 2 | デザイントークン + StyleSheet (4ファイル) | 2-3h | Medium |
| Phase 3 | 未使用コード削除 + warnings修正 | 2-3h | Low |
| Phase 4 | ドキュメント + テスト | 3-4h | Optional |
| **合計** | | **11-16h** | |

---

## 🚀 開始方法

### 1. このドキュメントを読む
```bash
cat docs/REMAINING-TASKS.md
```

### 2. 作業ブランチで開始
```bash
# 既存ブランチで継続
git checkout feature/coderabbit-159-fixes
git pull origin feature/coderabbit-159-fixes

# または新しいブランチで開始
git checkout -b feature/remaining-improvements
```

### 3. Phase 1から順次実施
- 各タスク完了後にcommit
- 定期的にpush
- Phase 1-2完了時にPR作成を推奨

---

## 📝 補足

### 実装時の注意点

1. **React Hooks依存配列**
   - `react-native-reanimated`のShared Valueは依存配列に含めるべき
   - パフォーマンステスト必須（アニメーションが重くなっていないか）

2. **StyleSheet移行**
   - 動的な値（変数に依存する値）はインラインのまま残す
   - 例: `style={{ left: `${position}%` }}` はそのまま
   - 静的な値のみStyleSheet化

3. **デザイントークン**
   - `colors`以外に`Spacing`, `BorderRadius`, `FontSize`も統一対象
   - 新しいトークンが必要な場合は`theme/`に追加

4. **未使用コード削除**
   - 削除前に必ずgrepで使用箇所を確認
   - 将来使用予定の場合はコメントアウトで残す

---

**最終更新**: 2026-01-07  
**作成者**: Claude (Session 1 & 2)  
**対象ブランチ**: `feature/coderabbit-159-fixes`  
**次のアクション**: Phase 1の実施を推奨

