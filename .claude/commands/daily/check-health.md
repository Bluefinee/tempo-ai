---
description: プロジェクトのヘルスチェック（型エラー、リント、テスト、依存関係）
allowed-tools: Bash, Read, Glob
---

# プロジェクトヘルスチェック

## チェック項目

### 1. 型チェック

```bash
# アプリ
cd app && npm run typecheck

# バックエンド
cd backend && pnpm typecheck
```

### 2. リント

```bash
# アプリ
cd app && npm run lint

# バックエンド
cd backend && pnpm check
```

### 3. テスト

```bash
# アプリ
cd app && npm test

# バックエンド
cd backend && pnpm test
```

### 4. 依存関係の脆弱性

```bash
# アプリ
cd app && npm audit

# バックエンド
cd backend && pnpm audit
```

### 5. 未使用の依存関係

```bash
# package.json の dependencies を確認
# 実際に import されているかチェック
```

### 6. 古い依存関係

```bash
# アプリ
cd app && npm outdated

# バックエンド
cd backend && pnpm outdated
```

## レポートフォーマット

```markdown
# プロジェクトヘルスレポート

日時: YYYY-MM-DD HH:MM

## サマリー

| 項目 | アプリ | バックエンド |
|------|--------|-------------|
| 型チェック | ✅/❌ | ✅/❌ |
| リント | ✅/❌ | ✅/❌ |
| テスト | ✅/❌ | ✅/❌ |
| 脆弱性 | X 件 | X 件 |

## 詳細

### 型エラー
（あれば詳細）

### リントエラー
（あれば詳細）

### テスト失敗
（あれば詳細）

### 脆弱性
（あれば詳細）

## 推奨アクション
1. ...
2. ...
```
