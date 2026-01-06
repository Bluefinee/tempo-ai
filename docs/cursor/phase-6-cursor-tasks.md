# Phase 6: Cursor向け実装タスク

> **重要**: このドキュメントはCursor AIへの指示書です。
> 人間が完了した作業と、Cursorが実行すべきタスクを明確に分けています。

---

## 現在の状況

### 人間が完了した作業

| タスク | 状態 | 詳細 |
|--------|------|------|
| Cloudflareアカウント作成 | ✅ 完了 | - |
| wrangler CLIログイン | ✅ 完了 | - |
| ステージング環境デプロイ | ✅ 完了 | - |
| ANTHROPIC_API_KEY設定 | ✅ 完了 | ステージング環境 |
| 全エンドポイント動作確認 | ✅ 完了 | health, weather, advice |

### 確定した環境情報

| 環境 | URL |
|------|-----|
| **ステージング** | `https://tempo-ai-api-staging.tempo-ai.workers.dev` |
| 本番 | （Phase 9で設定予定） |
| ローカル | `http://localhost:8787` |

### 動作確認済みエンドポイント

```
GET  /api/health  → 200 OK
GET  /api/weather → 200 OK
POST /api/advice  → 200 OK（AIアドバイス生成成功）
```

---

## Cursorへの指示

### タスク1: backend/.dev.vars の修正

**ファイル**: `backend/.dev.vars`

**現在の内容**:
```
CLAUDE_API_KEY=sk-ant-api03-...
```

**修正後**:
```
# ローカル開発用 Anthropic API Key
ANTHROPIC_API_KEY=sk-ant-api03-...
```

**理由**: コード（`backend/src/index.ts`）では `ANTHROPIC_API_KEY` を参照しているため、変数名を統一する必要がある。

---

### タスク2: 技術仕様書にAPI URL追記

**ファイル**: `docs/specs/tempoai_technical_spec.md`

**追記する内容**（適切な場所に挿入）:

```markdown
## デプロイ済み API エンドポイント

### 環境別ベースURL

| 環境 | ベースURL | 状態 |
|------|-----------|------|
| ステージング | `https://tempo-ai-api-staging.tempo-ai.workers.dev` | ✅ 稼働中 |
| 本番 | （Phase 9で設定予定） | - |
| ローカル | `http://localhost:8787` | 開発用 |

### エンドポイント一覧

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/api/health` | ヘルスチェック |
| GET | `/api/weather?latitude=XX&longitude=YY` | 天気情報取得 |
| POST | `/api/advice` | AIアドバイス生成 |
```

---

### タスク3: app/.env.example 作成

**ファイル**: `app/.env.example`（新規作成）

**内容**:

```bash
# API Base URL
# ローカル開発: http://localhost:8787
# ステージング: https://tempo-ai-api-staging.tempo-ai.workers.dev
# 本番: （Phase 9で設定）
EXPO_PUBLIC_API_URL=https://tempo-ai-api-staging.tempo-ai.workers.dev
```

**目的**: Phase 7でアプリ開発者が環境変数を設定する際の参考テンプレート

---

## 実行順序

1. タスク1: `backend/.dev.vars` 修正
2. タスク2: 技術仕様書更新
3. タスク3: `app/.env.example` 作成

---

## 注意事項

- **コミットしないファイル**: `backend/.dev.vars`（.gitignoreに含まれている）
- **コミットするファイル**: 技術仕様書、.env.example
- **本番デプロイは不要**: Phase 9まで待つ
