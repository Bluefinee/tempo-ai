# セッション2: 作業指示書

**担当**: コードスタイル・パフォーマンス改善  
**目標**: Major Issues 34件完了  
**推定時間**: 30-40分

---

## 🎯 作業概要

このセッションでは、以下の4つのカテゴリーに取り組みます：

1. **インラインスタイル → StyleSheet変換** (10件)
2. **デザイントークン統一** (10件)
3. **useMemo/useCallback最適化** (10件)
4. **その他改善** (4件)

---

## 📋 詳細タスクリスト

### Phase 1: インラインスタイル → StyleSheet (10件)

#### 対象ファイル

**app/app/(main)/index.tsx**
```typescript
// 修正箇所1: AI Insight section (line ~250)
// Before
<View style={{ padding: 24, gap: 16 }}>
// After
<View style={styles.aiInsightContainer}>

// 修正箇所2: Health Summary ScrollView (line ~350)
// Before
<ScrollView contentContainerStyle={{ paddingHorizontal: 24, gap: 16 }}>
// After
<ScrollView contentContainerStyle={styles.healthScrollContent}>
```

**app/app/(main)/rhythm.tsx**
```typescript
// 修正箇所: Window cards container
// Before
<View style={{ gap: 16, padding: 24 }}>
// After
<View style={styles.windowCardsContainer}>
```

**app/app/(main)/energy-detail.tsx**
```typescript
// 修正箇所: Status badge
// Before
<View style={{ backgroundColor: badgeColor, padding: 8 }}>
// After
<View style={[styles.statusBadge, { backgroundColor: badgeColor }]}>
```

**その他7ファイル**
- sleep-detail.tsx: Card containers
- recovery-detail.tsx: Metric cards
- health-detail.tsx: Grid layout
- insights.tsx: List items

---

### Phase 2: デザイントークン統一 (10件)

#### 対象ファイル

**app/src/components/MetricGridCard.tsx**
```typescript
// Line 79
- backgroundColor: '#FFFFFF',
+ backgroundColor: Colors.white,

// Line 86
- shadowColor: '#000',
+ shadowColor: Colors.black,

// Line 105
- color: '#A8A29E',
+ color: colors.stone[400],
```

**app/app/(main)/rhythm.tsx**
```typescript
// ハードコードされた色を探す
grep -n "rgba\|#[0-9A-Fa-f]" rhythm.tsx

// 各色をColorsオブジェクトに置き換え
```

**app/src/components/HealthSummaryCard.tsx**
```typescript
// 同様に色を統一
```

---

### Phase 3: useMemo/useCallback最適化 (10件)

#### 問題のパターン

**SharedValue依存配列削除**
```typescript
// Before (NG)
useEffect(() => {
  // ...
}, [sharedValue]); // ← SharedValueは不要

// After (OK)
useEffect(() => {
  // ...
}, []); // SharedValueを削除
```

#### 対象ファイル

**app/src/components/RhythmInteractiveChart.tsx**
```typescript
// useMemoの依存配列を確認
// dataが変更された時のみ再計算されるように
```

**app/src/components/DualRingProgress.tsx**
```typescript
// Line ~60
// Before
useEffect(() => {
  innerProgressValue.value = withTiming(inner, { duration: 1000 });
  outerProgressValue.value = withTiming(outer, { duration: 1000 });
}, [inner, outer, innerProgressValue, outerProgressValue]); // NG

// After
useEffect(() => {
  innerProgressValue.value = withTiming(inner, { duration: 1000 });
  outerProgressValue.value = withTiming(outer, { duration: 1000 });
}, [inner, outer]); // OK: SharedValue削除
```

---

### Phase 4: その他改善 (4件)

1. **ドキュメント追加**
   - 複雑な関数にJSDocコメント追加
   
2. **コメント改善**
   - 不明瞭なコメントを明確化

3. **パフォーマンス最適化**
   - 不要な再レンダリング防止

4. **その他**
   - CodeRabbitの残りの軽微な指摘

---

## 🔍 確認方法

### 各Phase完了後

```bash
# TypeScript check
cd app && npm run typecheck

# Lint check
npm run lint 2>&1 | grep "warning" | wc -l
```

### 目標

- TypeScript errors: 0 ✅
- ESLint warnings: 開始時 55 → 目標 <25

---

## 📝 コミット戦略

### 10件ごとにコミット

```bash
git add -A
git commit -m "feat(major): [Phase名] - [完了件数]件完了

✅ 完了項目:
- [項目1]
- [項目2]
...

Progress: Major Issues X/99
Related: #59, #60"
```

### Phase完了時

```bash
git push
```

---

## ⚠️ 重要な注意事項

1. **セッション1と競合しないファイル**
   - セッション1: 型関連、未使用削除
   - セッション2: スタイル、パフォーマンス
   - **同じファイルを同時編集しない**

2. **TypeScriptエラーゼロを維持**
   - 各変更後にtypecheck実行

3. **段階的にコミット**
   - 大きな変更の前に現状をコミット

4. **進捗をSESSION-TASKS.mdに記録**
   - 10件完了ごとに更新

---

## 🚀 開始手順

1. ブランチ確認
```bash
cd /Users/masakazuiwahara/Development/tempo-ai
git status
# feature/coderabbit-159-fixesにいることを確認
```

2. 最新の状態を取得
```bash
git pull
```

3. Phase 1から開始
```bash
cd app
# インラインスタイルの修正開始
```

---

## 📊 進捗報告

SESSION-TASKS.mdを更新して、進捗を共有してください。

**完了報告フォーマット**:
```
### [時刻]
セッション2: Phase 1完了 (10/34件)
- インラインスタイル変換: 10件 ✅
- 次: Phase 2開始
```

---

## ✅ 完了条件

- [ ] Phase 1: インラインスタイル (10件)
- [ ] Phase 2: デザイントークン (10件)
- [ ] Phase 3: useMemo/useCallback (10件)
- [ ] Phase 4: その他 (4件)
- [ ] TypeScript: 0 errors
- [ ] ESLint: warnings <25
- [ ] 全変更コミット & プッシュ完了

---

**開始してください！セッション1と並行して進めましょう！** 🚀

