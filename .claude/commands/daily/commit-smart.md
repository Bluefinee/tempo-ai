---
description: 変更内容を分析してスマートなコミットメッセージを生成
allowed-tools: Bash, Read, Glob
---

# スマートコミットコマンド

## 実行手順

### 1. 変更内容の確認

```bash
git status
git diff --staged
git diff
```

### 2. 変更の分類

| タイプ | 説明 | 例 |
|--------|------|-----|
| `feat` | 新機能 | 新しいコンポーネント、API エンドポイント |
| `fix` | バグ修正 | 計算ロジックの修正、エラーハンドリング |
| `refactor` | リファクタリング | コード整理、パフォーマンス改善 |
| `docs` | ドキュメント | README、コメント、仕様書 |
| `test` | テスト | テストケース追加、修正 |
| `chore` | その他 | 依存関係更新、設定変更 |

### 3. コミットメッセージの生成

フォーマット:
```
<type>: <summary>

[optional body]
```

ガイドライン:
- summary は50文字以内
- 動詞は現在形（add, fix, update）
- 「何を」「なぜ」を明確に

### 4. コミットの実行

```bash
# ステージング（未ステージの場合）
git add <files>

# コミット
git commit -m "<type>: <summary>"
```

## 良いコミットメッセージの例

```bash
# 新機能
git commit -m "feat: add Recovery score calculation service"

# バグ修正
git commit -m "fix: correct HRV baseline calculation for new users"

# リファクタリング
git commit -m "refactor: extract common chart logic to useChartData hook"

# 複数行の説明が必要な場合
git commit -m "feat: implement AI advice caching

- Add 24-hour cache for daily advice
- Reduce API calls to Claude
- Improve app launch time"
```

## 禁止事項

- `git commit --no-verify` は使用しない
- 曖昧なメッセージ（"fix bug", "update"）は避ける
- 複数の無関係な変更を1つのコミットにまとめない
