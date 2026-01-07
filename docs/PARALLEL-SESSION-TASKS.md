# 並列セッション用タスク（Phase 2完了）

**作成日**: 2026-01-07  
**対象PR**: #60  
**並列作業**: Session 1がPhase 3実施中、このセッションでPhase 2完了

---

## 📋 このセッションの担当タスク

### タスク1: インラインスタイル→StyleSheet変換（残り3ファイル）

**対象ファイル**:
1. `app/app/(main)/insights.tsx` - 16箇所
2. `app/app/(main)/insight-detail.tsx` - 8箇所  
3. `app/app/(main)/breathe.tsx` - 17箇所

**優先度**: Medium  
**推定時間**: 45-60分

---

## 🎯 タスク詳細

### 変換パターン

```typescript
// ❌ Before (インラインスタイル)
<View style={{ gap: 12 }}>
<Text style={{ fontFamily: FontFamily.serif }}>
<View style={{
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 4 },
  shadowOpacity: 0.06,
  shadowRadius: 10,
  elevation: 4,
}}>

// ✅ After (StyleSheet)
<View style={styles.container}>
<Text style={styles.titleText}>
<View style={styles.cardShadow}>

const styles = StyleSheet.create({
  container: {
    gap: 12,
  },
  titleText: {
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

---

## 📝 実装手順

### Step 1: insights.tsx

1. **StyleSheetをインポート**:
```typescript
import { View, Text, ScrollView, Pressable, StyleSheet } from 'react-native';
```

2. **インラインスタイルを特定**:
```bash
grep -n "style={{" app/app/(main)/insights.tsx
```

3. **StyleSheet定義を追加** (ファイル末尾):
```typescript
const styles = StyleSheet.create({
  container: {
    gap: 32,
  },
  weeklyCard: {
    shadowColor: colors.stone[900],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 20,
    elevation: 4,
  },
  barContainer: {
    gap: 8,
  },
  // ... 他のスタイル
});
```

4. **置換実行**:
- `style={{ gap: 32 }}` → `style={styles.container}`
- `style={{ gap: 8 }}` → `style={styles.barContainer}`
- 繰り返し使用されるshadowスタイル → `style={styles.cardShadow}`

---

### Step 2: insight-detail.tsx

同様の手順で実施:
1. StyleSheetインポート追加
2. インラインスタイル特定 (8箇所)
3. StyleSheet定義追加
4. 置換実行

**主な対象**:
- `style={{ gap: 8 }}`
- `style={{ gap: 12 }}`
- `style={{ gap: 16 }}`
- shadow系のスタイル

---

### Step 3: breathe.tsx

同様の手順で実施:
1. StyleSheetインポート追加
2. インラインスタイル特定 (17箇所)
3. StyleSheet定義追加
4. 置換実行

**主な対象**:
- `style={{ gap: 24 }}`
- `style={{ gap: 16 }}`
- 呼吸エクササイズ用のUI要素スタイル

---

## ✅ 完了基準

### 必須
- ✅ 3ファイルすべてでStyleSheetを使用
- ✅ インラインスタイル（`style={{ ... }}`）が0箇所
- ✅ ESLint/TypeScriptエラーなし

### 確認コマンド
```bash
# インラインスタイルの残存確認
grep -r "style={{" app/app/(main)/insights.tsx app/app/(main)/insight-detail.tsx app/app/(main)/breathe.tsx

# TypeScriptエラー確認
cd app && npx tsc --noEmit

# ESLintエラー確認
cd app && npx eslint app/(main)/insights.tsx app/(main)/insight-detail.tsx app/(main)/breathe.tsx
```

---

## 🚀 開始方法

### ブランチ確認
```bash
git status
git branch
# feature/coderabbit-159-fixes にいることを確認
```

### ファイルを開く
```bash
code app/app/(main)/insights.tsx
code app/app/(main)/insight-detail.tsx
code app/app/(main)/breathe.tsx
```

---

## 📌 注意事項

### 1. 動的な値は残す
```typescript
// ✅ OK: 動的な値はインラインのまま
<View style={{ left: `${position}%` }}>
<View style={{ width: cardWidth, height: cardHeight }}>

// ❌ NG: これらは静的なのでStyleSheet化
<View style={{ gap: 12 }}>
```

### 2. 条件付きスタイルの扱い
```typescript
// ✅ OK: 条件付きスタイルは配列で処理
<View style={[styles.card, isActive && styles.activeCard]}>

// ✅ OK: 動的な色はインライン
<Text style={[styles.text, { color: getTrendColor() }]}>
```

### 3. StyleSheet定義の順序
```typescript
// 推奨順序:
const styles = StyleSheet.create({
  // 1. コンテナ系
  container: { ... },
  section: { ... },
  
  // 2. カード系
  card: { ... },
  cardShadow: { ... },
  
  // 3. テキスト系
  titleText: { ... },
  bodyText: { ... },
  
  // 4. アイコン/装飾系
  iconBg: { ... },
  badge: { ... },
});
```

---

## 🔄 Session 1との同期

### コミット前の確認
```bash
# Session 1の進捗を確認
git fetch origin
git log origin/feature/coderabbit-159-fixes --oneline -5

# 競合がないか確認（このセッションの対象ファイルは完全に別）
git diff origin/feature/coderabbit-159-fixes -- app/app/(main)/insights.tsx
```

### コミット方法
```bash
# 3ファイル完了後
git add app/app/(main)/insights.tsx app/app/(main)/insight-detail.tsx app/app/(main)/breathe.tsx
git commit -m "refactor: convert inline styles to StyleSheet (insights, insight-detail, breathe)

- Convert all inline styles to StyleSheet definitions
- Improve performance by eliminating inline style object creation
- Part of Phase 2 cleanup (parallel session)

Files:
- app/(main)/insights.tsx: 16 inline styles → StyleSheet
- app/(main)/insight-detail.tsx: 8 inline styles → StyleSheet
- app/(main)/breathe.tsx: 17 inline styles → StyleSheet
"

git push origin feature/coderabbit-159-fixes
```

---

## 📊 期待される成果

### Before（現在）
```
インラインスタイル総数: 41箇所（3ファイル合計）
- insights.tsx: 16箇所
- insight-detail.tsx: 8箇所
- breathe.tsx: 17箇所
```

### After（完了時）
```
インラインスタイル総数: 0箇所
StyleSheet化率: 100%
パフォーマンス改善: ✅
保守性向上: ✅
```

---

## 🆘 トラブルシューティング

### Q: TypeScriptエラーが出た
```bash
# エラー内容を確認
cd app && npx tsc --noEmit 2>&1 | grep -A 5 "insights\|insight-detail\|breathe"

# よくあるエラー:
# - StyleSheetのインポート忘れ
# - 括弧の閉じ忘れ
# - スタイル名のタイポ
```

### Q: 実行時エラーが出た
```bash
# アプリを起動して確認
cd app && npm start

# よくある原因:
# - 存在しないstyles.xxxを参照している
# - 配列スタイルの構文ミス
```

### Q: Session 1とコンフリクトした
```bash
# このセッションの対象ファイルは完全に別なので、コンフリクトは発生しないはず
# もし発生した場合:
git pull origin feature/coderabbit-159-fixes
# 手動でマージ（通常は不要）
```

---

**最終更新**: 2026-01-07  
**作成者**: Claude (Session 1)  
**対象ブランチ**: `feature/coderabbit-159-fixes`  
**並列セッション**: Session 1がPhase 3実施中

