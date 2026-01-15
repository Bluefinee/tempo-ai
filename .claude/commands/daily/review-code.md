---
description: 指定されたファイル/PRのコードレビューを実行
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git log:*)
---

# コードレビューコマンド

対象: $ARGUMENTS

## レビュー観点

### 1. 型安全性

- [ ] `any` 型が使用されていないか
- [ ] 戻り値型が明示されているか
- [ ] `unknown` の適切な型ガードがあるか
- [ ] Zod スキーマとの整合性

```typescript
// ❌ 問題
const process = (data: any) => data.value;

// ✅ 修正
const process = (data: unknown): string => {
  if (!isValidData(data)) throw new Error('Invalid');
  return data.value;
};
```

### 2. React Native / コンポーネント

- [ ] Props に interface が定義されているか
- [ ] StyleSheet.create を使用しているか
- [ ] デザイントークン（Colors, Spacing）を使用しているか
- [ ] 不要な再レンダリングがないか（useMemo, useCallback）

```typescript
// ❌ 問題
<View style={{ padding: 16 }}>

// ✅ 修正
<View style={styles.container}>
const styles = StyleSheet.create({
  container: { padding: Spacing.md }
});
```

### 3. Zustand ストア

- [ ] セレクターで必要なプロパティのみ選択しているか
- [ ] 永続化対象が適切か
- [ ] アクションが副作用を分離しているか

```typescript
// ❌ 問題
const store = useHealthStore();

// ✅ 修正
const sleepScore = useHealthStore((state) => state.sleepScore);
```

### 4. ドメインサービス

- [ ] 純粋関数になっているか（副作用なし）
- [ ] 入出力の型が明確か
- [ ] ビジネスロジックがサービスに集約されているか
- [ ] テストが書きやすい設計か

### 5. エラーハンドリング

- [ ] Result 型が適切に使用されているか
- [ ] エラーメッセージが具体的か
- [ ] 例外を握りつぶしていないか

```typescript
// ❌ 問題
try { doSomething(); } catch (e) { /* 無視 */ }

// ✅ 修正
const result = await service.doSomething();
if (!isOk(result)) {
  console.error('Failed:', result.error);
  return handleError(result.error);
}
```

### 6. パフォーマンス

- [ ] 不要な計算がレンダリング毎に発生していないか
- [ ] 大きなリストに virtualization があるか
- [ ] API 呼び出しが適切にキャッシュされているか

### 7. セキュリティ

- [ ] ユーザー入力が適切にバリデーションされているか
- [ ] 機密情報がログに出力されていないか
- [ ] API キーがハードコードされていないか

## 出力フォーマット

```markdown
## コードレビュー結果

### サマリー
- 重大な問題: X 件
- 改善提案: X 件
- 良い点: X 件

### 重大な問題 🔴

#### [ファイル:行番号] 問題タイトル
**問題**: 説明
**修正案**: コード例

### 改善提案 🟡

#### [ファイル:行番号] 提案タイトル
**現状**: 説明
**提案**: コード例

### 良い点 ✅

- 説明
```
