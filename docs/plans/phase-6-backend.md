# Phase 6: バックエンド整理・最適化

## 概要

| 項目 | 内容 |
|------|------|
| **目的** | 本番運用に耐えうるバックエンド環境を整備 |
| **期間目安** | 1日 |
| **依存** | なし |
| **成果物** | 本番稼働する API + 確定した URL |

---

## 現状分析

### バックエンド実装状況

| 項目 | 状態 | 詳細 |
|------|------|------|
| フレームワーク | ✅ Hono | Cloudflare Workers 向け |
| エンドポイント | ✅ 3つ | `/api/health`, `/api/weather`, `/api/advice` |
| テスト | ✅ 155件合格 | Vitest + @cloudflare/vitest-pool-workers |
| TypeScript | ✅ strict mode | エラーなし |
| Claude API | ✅ Prompt Caching | コスト最適化済み |
| デプロイ | ⚠️ 未実施 | wrangler 設定済み |

### ファイル構成

```
backend/
├── src/
│   ├── index.ts              # エントリーポイント
│   ├── middleware/           # エラーハンドリング、ロギング
│   ├── routes/               # API ルート定義
│   ├── services/             # ビジネスロジック
│   │   ├── advice/           # AI アドバイス生成
│   │   └── weather/          # 天気データ取得
│   └── utils/                # Result 型など
├── wrangler.toml             # Cloudflare 設定
├── .dev.vars                 # ローカル環境変数
└── package.json
```

---

## タスク詳細

### 6.1 Cloudflare Workers デプロイ

#### 6.1.1 API キー設定

```bash
cd backend
wrangler secret put ANTHROPIC_API_KEY
# プロンプトで API キーを入力
```

**確認事項**:
- Anthropic Console で API キーを取得済みか
- キーに十分なクレジットがあるか

#### 6.1.2 ステージング環境デプロイ

```bash
npm run deploy:staging
```

**期待される出力**:
```
Published tempo-ai-api-staging (https://tempo-ai-api-staging.xxx.workers.dev)
```

#### 6.1.3 本番環境デプロイ

```bash
npm run deploy
```

**期待される出力**:
```
Published tempo-ai-api (https://tempo-ai-api.xxx.workers.dev)
```

#### 6.1.4 動作確認

各エンドポイントをテスト:

```bash
# ヘルスチェック
curl https://tempo-ai-api.xxx.workers.dev/api/health

# 天気 API
curl "https://tempo-ai-api.xxx.workers.dev/api/weather?latitude=35.6762&longitude=139.6503"

# AI アドバイス（POST）
curl -X POST https://tempo-ai-api.xxx.workers.dev/api/advice \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "nickname": "テスト",
      "age": 30,
      "gender": "male",
      "chronotype": "morning",
      "targetBedtime": "23:00"
    },
    "healthData": {
      "scores": {
        "autonomic": 80,
        "sleep": 75,
        "rhythm": 90,
        "activity": 70
      },
      "rhythmAnalysis": {
        "bedtimeStddevMinutes": 15,
        "wakeTimeStddevMinutes": 20,
        "consecutiveStableDays": 5,
        "status": "stable"
      }
    },
    "location": {
      "latitude": 35.6762,
      "longitude": 139.6503,
      "city": "東京"
    },
    "context": {
      "currentTime": "08:00",
      "dayOfWeek": "Monday"
    }
  }'
```

---

### 6.2 環境変数・設定整理

#### 6.2.1 本番 API URL 確定

デプロイ後に確定した URL を記録:

| 環境 | URL |
|------|-----|
| 本番 | `https://tempo-ai-api.xxx.workers.dev` |
| ステージング | `https://tempo-ai-api-staging.xxx.workers.dev` |

#### 6.2.2 CORS 設定確認

`backend/src/index.ts` で CORS が適切に設定されているか確認:

```typescript
import { cors } from 'hono/cors'

app.use('/*', cors({
  origin: '*', // 開発中は全許可、本番では制限を検討
  allowMethods: ['GET', 'POST', 'OPTIONS'],
  allowHeaders: ['Content-Type'],
}))
```

**本番環境での推奨**:
- `origin: '*'` → 特定ドメインに制限（必要に応じて）
- モバイルアプリからのアクセスは基本的に問題なし

#### 6.2.3 レート制限の検討

Claude API のコスト管理のため、以下を検討:

| 対策 | 実装難易度 | 効果 |
|------|-----------|------|
| 1日1回制限（アプリ側） | 低 | 高 |
| IP ベースレート制限 | 中 | 中 |
| ユーザー認証 + 制限 | 高 | 高 |

**MVP では**: アプリ側で1日1回制限を推奨（Phase 7 で実装）

---

### 6.3 ドキュメント整理

#### 6.3.1 仕様書ファイル名の統一

CLAUDE.md で参照しているパスと実際のファイル名を一致させる:

| 現在のファイル名 | 変更後 |
|-----------------|--------|
| `tempoai_product_spec.md` | `product-spec.md` |
| `tempoai_technical_spec.md` | `technical-spec.md` |
| `tempoai_metrics_spec.md` | `metrics-spec.md` |
| `tempoai_ai_prompt_spec.md` | `ai-prompt-spec.md` |
| `tempoai_knowledge_base.md` | `knowledge-base.md` |
| `ui-spec.md` | （変更なし） |

```bash
cd docs/specs
mv tempoai_product_spec.md product-spec.md
mv tempoai_technical_spec.md technical-spec.md
mv tempoai_metrics_spec.md metrics-spec.md
mv tempoai_ai_prompt_spec.md ai-prompt-spec.md
mv tempoai_knowledge_base.md knowledge-base.md
```

#### 6.3.2 API 仕様書の更新

`docs/specs/technical-spec.md` に本番 API URL を追記:

```markdown
## API エンドポイント

| 環境 | ベース URL |
|------|-----------|
| 本番 | `https://tempo-ai-api.xxx.workers.dev` |
| ステージング | `https://tempo-ai-api-staging.xxx.workers.dev` |
| ローカル | `http://localhost:8787` |
```

---

### 6.4 モニタリング（オプション）

#### 6.4.1 Cloudflare Analytics 確認

1. Cloudflare Dashboard → Workers & Pages
2. `tempo-ai-api` を選択
3. Analytics タブで確認可能な項目:
   - リクエスト数
   - エラー率
   - レイテンシ分布
   - 地域別アクセス

#### 6.4.2 エラーログ確認

```bash
# リアルタイムログ
wrangler tail

# 特定時間のログ
wrangler tail --since 1h
```

---

## チェックリスト

### デプロイ

- [ ] Anthropic API キーを `wrangler secret put` で設定
- [ ] ステージング環境にデプロイ
- [ ] 本番環境にデプロイ
- [ ] `/api/health` エンドポイント確認
- [ ] `/api/weather` エンドポイント確認
- [ ] `/api/advice` エンドポイント確認

### 設定

- [ ] 本番 API URL を記録
- [ ] CORS 設定確認
- [ ] レート制限方針決定

### ドキュメント

- [ ] `docs/specs/` ファイル名をリネーム
- [ ] API URL を仕様書に追記

### モニタリング

- [ ] Cloudflare Analytics 確認方法を把握
- [ ] `wrangler tail` でログ確認

---

## 完了条件

1. 本番 API が稼働し、3つのエンドポイントが正常に応答
2. API URL が確定し、ドキュメントに記載
3. 仕様書のファイル名が CLAUDE.md と一致

---

## 次のフェーズへ

Phase 6 完了後、Phase 7（API連携実装）に進む。

確定した API URL を `app/.env.local` に設定し、アプリからの呼び出しを実装。
