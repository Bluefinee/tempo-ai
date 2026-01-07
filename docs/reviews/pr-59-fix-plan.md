# PR #59 CodeRabbit レビュー修正計画書

**作成日**: 2026-01-07  
**PR**: #59 - feat: Phase 0-5 Complete Implementation  
**レビュー総数**: 126 件（Critical: 3, Potential issue: 58, Nitpick: 43, Trivial: 43）

---

## 📊 修正の優先度と分類

### 🔴 Critical（最優先）- 3 件

1. **ファイル行数制限超過（400 行ルール）**
2. **React 19 互換性問題**
3. **型安全性の重大な問題**

### ⚠️ Potential Issue（高優先度）- 58 件

1. **重複コードの統合**
2. **型アノテーションの欠如**
3. **未使用コード**
4. **ハードコーディング**

### 🧹 Nitpick（中優先度）- 43 件

1. **コーディングスタイル統一**
2. **関数宣言 → Arrow 関数**
3. **React.FC の削除**

### 🔵 Trivial（低優先度）- 43 件

1. **コメント改善**
2. **命名の改善**

---

## 🎯 Phase 1: Critical Issues（最優先）

### 1.1 ファイル行数制限超過の修正

#### 📁 `app/src/constants/mockData.ts` (918 行 → 400 行以下)

**現状**: 918 行の巨大ファイル

**修正計画**:

```
app/src/constants/
├── mockData/
│   ├── index.ts          # 全てのre-export
│   ├── aiResponse.ts     # MOCK_AI_RESPONSE
│   ├── screens.ts        # MOCK_TODAY, MOCK_RHYTHM, MOCK_INSIGHTS, etc.
│   ├── health.ts         # MOCK_HEALTH_METRICS, MOCK_DETAIL, etc.
│   └── user.ts           # MOCK_USER, MOCK_SETTINGS
└── mockDataFactory.ts    # (既存)

app/src/utils/
└── dateFormatters.ts     # getGreeting, formatTime, formatDate, formatDateEnglish
```

**タスク**:

- [ ] `mockData/aiResponse.ts` を作成（MOCK_AI_RESPONSE）
- [ ] `mockData/screens.ts` を作成（画面別 Mock）
- [ ] `mockData/health.ts` を作成（ヘルスデータ Mock）
- [ ] `mockData/user.ts` を作成（ユーザー設定 Mock）
- [ ] `mockData/index.ts` を作成（re-export）
- [ ] `utils/dateFormatters.ts` を作成（日付フォーマット関数）
- [ ] 元の`mockData.ts`を削除
- [ ] 全ての import を更新

---

#### 📁 `app/src/stores/healthStore.ts` (503 行 → 400 行以下)

**現状**: 503 行の巨大ストア

**修正計画**:

```
app/src/stores/
├── healthStore/
│   ├── index.ts           # メインストア（sliceを統合）
│   ├── metricsSlice.ts    # sleepMetrics, hrvMetrics, activityMetrics, rhythmAnalysis
│   ├── weatherSlice.ts    # weather, weatherCode, weatherHumidity
│   ├── tempoSlice.ts      # tempoScore, circadianRhythm, energyCurve, calibration
│   └── snapshotSlice.ts   # dailySnapshot, realtimeMetrics
└── selectors/
    └── healthSelectors.ts # セレクター関数
```

**タスク**:

- [ ] `healthStore/metricsSlice.ts` を作成
- [ ] `healthStore/weatherSlice.ts` を作成
- [ ] `healthStore/tempoSlice.ts` を作成
- [ ] `healthStore/snapshotSlice.ts` を作成
- [ ] `healthStore/index.ts` で slice を統合
- [ ] `selectors/healthSelectors.ts` を作成
- [ ] 元の`healthStore.ts`を削除
- [ ] 全ての import を更新

---

#### 📁 `app/app/(main)/index.tsx` (617 行 → 400 行以下)

**現状**: 617 行の TodayScreen

**修正計画**:

```
app/app/(main)/
├── index.tsx                    # TodayScreen本体（~200行）
└── components/
    ├── TodayHeader.tsx          # ヘッダー部分
    ├── MetricGridCard.tsx       # スコアカード（既存を活用）
    ├── AIInsightCard.tsx        # AIインサイトカード
    ├── OneThingCard.tsx         # Today's One Thingカード
    └── HealthSummaryCard.tsx    # ヘルスサマリーカード（既存を活用）
```

**タスク**:

- [ ] `TodayHeader.tsx` を作成（greeting, date 表示）
- [ ] `AIInsightCard.tsx` を作成（AI メッセージカード）
- [ ] `OneThingCard.tsx` を作成（Today's One Thing カード）
- [ ] `renderMetricCard`を`MetricGridCard`に統合
- [ ] `renderHealthCard`を`HealthSummaryCard`に統合
- [ ] `index.tsx`をリファクタリング（~200 行に削減）
- [ ] default export → named export に変更

---

#### 📁 `app/app/(main)/breathe.tsx` (400 行超過)

**現状**: 400 行超過

**修正計画**:

```
app/app/(main)/
├── breathe.tsx                  # メイン画面（~200行）
└── components/
    ├── BreathingCircle.tsx      # アニメーションサークル
    └── useBreathingAnimation.ts # アニメーションロジック
```

**タスク**:

- [ ] `BreathingCircle.tsx` を作成
- [ ] `useBreathingAnimation.ts` を作成
- [ ] `breathe.tsx`をリファクタリング
- [ ] 未使用 import 削除（Defs, RadialGradient, Stop, withRepeat, withSequence）
- [ ] 未使用変数削除（SCREEN_HEIGHT, breatheRingOpacity）

---

### 1.2 React 19 互換性問題

**問題**: Expo SDK 54 と React 19 の互換性問題

**修正計画**:

1. **検証**: iOS, Android, Web でビルドテスト
2. **選択肢 A**: React 18.x にダウングレード
3. **選択肢 B**: Expo SDK 55+にアップグレード（利用可能な場合）
4. **選択肢 C**: パッチ適用

**タスク**:

- [ ] iOS/Android/Web でビルドテスト実行
- [ ] 問題が発生した場合、React 18.x へのダウングレードを検討
- [ ] `package.json`を更新
- [ ] 依存関係を再インストール

---

### 1.3 絶対パスのハードコーディング

**問題**: `.claude/settings.local.json`に絶対パス

**修正計画**:

```diff
- "Bash(for file in /Users/masakazuiwahara/Development/tempo-ai/app/src/domain/services/*.ts)"
+ "Bash(for file in ./app/src/domain/services/*.ts)"
```

または`.gitignore`に追加:

```
.claude/settings.local.json
```

**タスク**:

- [ ] `.claude/settings.local.json`の絶対パスを相対パスに変更
- [ ] または`.gitignore`に`.claude/settings.local.json`を追加

---

## 🎯 Phase 2: 重複コードの統合（高優先度）

### 2.1 useFadeIn hook の重複

**問題**: 3 箇所で重複定義

- `app/app/(main)/action-detail.tsx`
- `app/app/(main)/settings.tsx`
- `app/src/hooks/useFadeIn.ts`（共有版）

**修正計画**:

1. 共有版を最新の reanimated 実装に更新
2. ローカル定義を削除して import に置き換え

**タスク**:

- [ ] `app/src/hooks/useFadeIn.ts`を reanimated 実装に更新
- [ ] `action-detail.tsx`のローカル定義を削除
- [ ] `settings.tsx`のローカル定義を削除
- [ ] 両ファイルで共有 hook を import

---

### 2.2 seededRandom 関数の重複

**問題**: 2 箇所で重複定義

- `app/app/(main)/health-detail.tsx`
- `app/src/constants/mockDataFactory.ts`（共有版）

**修正計画**:

1. `health-detail.tsx`のローカル定義を削除
2. `mockDataFactory.ts`から import

**タスク**:

- [ ] `health-detail.tsx`の`seededRandom`を削除
- [ ] `mockDataFactory`から`seededRandom`を import

---

### 2.3 Timeframe 型の重複

**問題**: 2 箇所で重複定義

- `app/app/(main)/health-detail.tsx`
- `app/src/components/TimeframeSelector.tsx`

**修正計画**:

1. `health-detail.tsx`の型定義を削除
2. `TimeframeSelector`から import

**タスク**:

- [ ] `health-detail.tsx`の`Timeframe`型を削除
- [ ] `TimeframeSelector`から`Timeframe`を import

---

## 🎯 Phase 3: 型安全性の向上（高優先度）

### 3.1 明示的な戻り値型の追加

**対象ファイル**: 全コンポーネント・関数

**修正パターン**:

```typescript
// Before
export const Component = () => {
  return <View />;
};

// After
export const Component = (): React.ReactElement => {
  return <View />;
};

// Before
const handlePress = () => {
  router.push("/path");
};

// After
const handlePress = (): void => {
  router.push("/path");
};
```

**タスク**:

- [ ] 全コンポーネントに`: React.ReactElement`を追加
- [ ] 全ハンドラー関数に`: void`を追加
- [ ] ヘルパー関数に適切な型を追加

---

### 3.2 React.FC の削除

**対象**: 全コンポーネント

**修正パターン**:

```typescript
// Before
export const Card: React.FC<CardProps> = ({ children }) => {
  return <View>{children}</View>;
};

// After
export const Card = ({ children }: CardProps): React.ReactElement => {
  return <View>{children}</View>;
};
```

**タスク**:

- [ ] `Card.tsx`
- [ ] `PrimaryButton.tsx`
- [ ] その他全ての React.FC 使用箇所

---

### 3.3 any 型の排除

**対象**: 全ファイル

**タスク**:

- [ ] `any`型を検索
- [ ] 適切な型定義に置き換え
- [ ] 必要に応じて新しい型を定義

---

## 🎯 Phase 4: function 宣言 → Arrow 関数（中優先度）

### 4.1 コンポーネント

**対象ファイル**:

- `app/app/(onboarding)/bedtime.tsx`
- `app/app/(main)/rhythm.tsx`
- `app/app/(main)/rhythm-detail.tsx`
- `app/app/(main)/sleep-detail.tsx`
- その他全ての function 宣言

**修正パターン**:

```typescript
// Before
export default function Screen(): JSX.Element {
  return <View />;
}

// After
const Screen = (): JSX.Element => {
  return <View />;
};

export default Screen;
```

**タスク**:

- [ ] 全画面コンポーネントを arrow 関数に変換
- [ ] default export を分離

---

## 🎯 Phase 5: ハードコーディングの解消（中優先度）

### 5.1 i18n 未対応の日本語文字列

**対象ファイルと箇所**:

#### `app/app/(main)/action-detail.tsx`

```typescript
// Line 263
<Text>{todayOneThing.time}にリマインド</Text>
// → t('screen.actionDetail.remindAt', { time: todayOneThing.time })
```

#### `app/app/(main)/insights.tsx`

```typescript
// Line 114-116
<Text>Insights</Text>
// → t('screen.insights.title')
```

#### `app/app/(main)/rhythm-detail.tsx`

```typescript
// Line 183-186
<Text>目標からのズレ</Text>
<Text>上: 早い / 下: 遅い</Text>
// → t('rhythm.deviationLabel')
// → t('rhythm.deviationHint')
```

#### `app/app/(onboarding)/chronotype.tsx`

```typescript
// Line 118-120
<PrimaryButton>Continue</PrimaryButton>
// → t('common.continue')
```

#### `app/app/(onboarding)/nickname.tsx`

```typescript
// Line 66-70
// タイトルと説明をニックネーム用に更新
```

**タスク**:

- [ ] 全ての日本語文字列を抽出
- [ ] i18n キーを定義
- [ ] `t()`関数で置き換え
- [ ] ロケールファイルに翻訳を追加

---

## 🎯 Phase 6: 未使用コードの削除（中優先度）

### 6.1 未使用 import

**対象ファイル**:

- `app/app/(main)/breathe.tsx`: Defs, RadialGradient, Stop, withRepeat, withSequence
- `app/app/(main)/energy-detail.tsx`: Circle, Line
- `app/app/(onboarding)/basic-info.tsx`: BorderRadius
- `app/app/(onboarding)/healthkit.tsx`: Heart
- `app/app/(onboarding)/index.tsx`: Spacing, BorderRadius
- `app/app/(onboarding)/lifestyle.tsx`: Spacing, BorderRadius
- `app/app/(onboarding)/nickname.tsx`: Spacing, BorderRadius

**タスク**:

- [ ] 各ファイルの未使用 import を削除

---

### 6.2 未使用変数・関数

**対象**:

- `app/app/(main)/breathe.tsx`: SCREEN_HEIGHT, breatheRingOpacity
- `app/app/(main)/energy-detail.tsx`: markerX
- `app/app/(main)/health-detail.tsx`: getStatusLabel（未使用または実装）

**タスク**:

- [ ] 未使用変数を削除
- [ ] `getStatusLabel`を実装するか削除

---

## 🎯 Phase 7: データソースの統一（中優先度）

### 7.1 Mock vs Store 混在の解消

#### `app/app/(main)/energy-detail.tsx`

```typescript
// Line 270-274
// Before: getEnergyStatus(data.score)
// After: getEnergyStatus(energyScore)
```

#### `app/app/(main)/rhythm-detail.tsx`

```typescript
// Line 88-92
// Before: getRhythmStatus(data.score)
// After: getRhythmStatus(rhythmScore)
```

**タスク**:

- [ ] 全ての詳細画面で store 値を使用
- [ ] Mock 値との混在を解消

---

## 🎯 Phase 8: パフォーマンス最適化（中優先度）

### 8.1 メモ化の追加

#### `app/app/(main)/health-detail.tsx`

```typescript
// Line 561-639
// renderMetricCardをuseCallbackでメモ化
const renderMetricCard = useCallback(
  (metric: MetricData) => {
    // ...
  },
  [cardWidth, cardHeight, colors, ICON_MAP]
);
```

#### `app/app/(main)/insights.tsx`

```typescript
// Line 250-252
// getAlerts()をuseMemoでメモ化
const memoizedAlerts = useMemo(
  () => getAlerts(),
  [
    /* dependencies */
  ]
);
```

**タスク**:

- [ ] `renderMetricCard`をメモ化
- [ ] `getAlerts()`をメモ化
- [ ] その他レンダー毎の再計算をメモ化

---

## 🎯 Phase 9: onPress ハンドラの実装（中優先度）

### 9.1 未実装の onPress

**対象**:

- `app/app/(main)/insights.tsx`: Line 177-240（AnimatedPressable）
- `app/app/(main)/settings.tsx`: Line 252-256（Profile 編集）
- `app/app/(main)/settings.tsx`: Line 341-351（Sign Out）

**タスク**:

- [ ] `insights.tsx`の discovery カードに onPress 実装
- [ ] `settings.tsx`の Profile 編集に onPress 実装
- [ ] `settings.tsx`の Sign Out に onpress 実装（認証処理）

---

## 🎯 Phase 10: Dimensions.get()の置き換え（低優先度）

### 10.1 useWindowDimensions()への移行

**対象**:

- `app/app/(onboarding)/complete.tsx`: Line 17-19
- `app/app/(onboarding)/index.tsx`: Line 15

**修正パターン**:

```typescript
// Before
const { width, height } = Dimensions.get("window");

// After
const { width, height } = useWindowDimensions();
```

**タスク**:

- [ ] `complete.tsx`を更新
- [ ] `index.tsx`を更新

---

## 🎯 Phase 11: スタイルの統一（低優先度）

### 11.1 インラインスタイル → StyleSheet

**対象**:

- `app/app/(main)/sleep-detail.tsx`: Line 55-57

**修正パターン**:

```typescript
// Before
<Pressable style={({ pressed }) => [{ backgroundColor: pressed ? colors.stone[100] : 'transparent' }]}>

// After
const styles = StyleSheet.create({
  pressable: { /* ... */ },
  pressablePressed: { backgroundColor: colors.stone[100] },
});

<Pressable style={({ pressed }) => [styles.pressable, pressed && styles.pressablePressed]}>
```

**タスク**:

- [ ] `sleep-detail.tsx`のインラインスタイルを StyleSheet に移行

---

## 🎯 Phase 12: コンポーネントの抽出（低優先度）

### 12.1 重複 UI パターンの統合

#### `app/app/(onboarding)/lifestyle.tsx`

```
Line 119-210: Work Type, Exercise Frequency, Alcohol Consumptionの3ブロック
→ LifestyleSection<T> コンポーネントに統合
```

**タスク**:

- [ ] `LifestyleSection.tsx`を作成
- [ ] 3 つの重複ブロックを置き換え

---

## 📋 実装チェックリスト

### Phase 1: Critical Issues

- [ ] mockData.ts を分割（918 行 → 400 行以下）
- [ ] healthStore.ts を分割（503 行 → 400 行以下）
- [ ] index.tsx を分割（617 行 → 400 行以下）
- [ ] breathe.tsx を分割（400 行超 → 400 行以下）
- [ ] React 19 互換性を検証・修正
- [ ] 絶対パスを相対パスに変更

### Phase 2: 重複コード

- [ ] useFadeIn hook を統合
- [ ] seededRandom 関数を統合
- [ ] Timeframe 型を統合

### Phase 3: 型安全性

- [ ] 全コンポーネントに戻り値型を追加
- [ ] React.FC を削除
- [ ] any 型を排除

### Phase 4: Arrow 関数

- [ ] 全 function 宣言を arrow 関数に変換

### Phase 5: i18n

- [ ] 全ハードコード文字列を i18n 化

### Phase 6: 未使用コード

- [ ] 未使用 import を削除
- [ ] 未使用変数を削除

### Phase 7: データソース統一

- [ ] Mock/Store 混在を解消

### Phase 8: パフォーマンス

- [ ] 必要な箇所にメモ化を追加

### Phase 9: onPress 実装

- [ ] 未実装の onPress を実装

### Phase 10: Dimensions

- [ ] useWindowDimensions()に移行

### Phase 11: スタイル

- [ ] インラインスタイルを StyleSheet に移行

### Phase 12: コンポーネント抽出

- [ ] LifestyleSection を作成

---

## 📊 見積もり

| Phase    | 優先度      | 見積もり時間 | 影響範囲 |
| -------- | ----------- | ------------ | -------- |
| Phase 1  | 🔴 Critical | 8-12 時間    | 大       |
| Phase 2  | ⚠️ High     | 2-3 時間     | 中       |
| Phase 3  | ⚠️ High     | 4-6 時間     | 大       |
| Phase 4  | 🧹 Medium   | 2-3 時間     | 中       |
| Phase 5  | 🧹 Medium   | 3-4 時間     | 中       |
| Phase 6  | 🧹 Medium   | 1-2 時間     | 小       |
| Phase 7  | 🧹 Medium   | 1-2 時間     | 小       |
| Phase 8  | 🧹 Medium   | 2-3 時間     | 小       |
| Phase 9  | 🧹 Medium   | 2-3 時間     | 中       |
| Phase 10 | 🔵 Low      | 1 時間       | 小       |
| Phase 11 | 🔵 Low      | 1-2 時間     | 小       |
| Phase 12 | 🔵 Low      | 1-2 時間     | 小       |

**合計見積もり**: 28-43 時間

---

## 🚀 実装順序の推奨

1. **Phase 1** (Critical) - 最優先で実施
2. **Phase 2, 3** (High) - 型安全性と重複削除
3. **Phase 4, 5, 6** (Medium) - コーディング規約準拠
4. **Phase 7, 8, 9** (Medium) - 機能完成度向上
5. **Phase 10, 11, 12** (Low) - 最適化とクリーンアップ

---

## 📝 注意事項

1. **各 Phase ごとにコミット**を推奨
2. **テストを実行**して既存機能が壊れていないことを確認
3. **Lint と typecheck を通過**させてからコミット
4. **PR を分割**することも検討（Phase 1 だけで 1 つの PR など）

---

**作成者**: Claude (Cursor AI)  
**最終更新**: 2026-01-07
