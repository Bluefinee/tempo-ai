---
description: Hono / Cloudflare Workers バックエンド開発エージェント
---

# Backend Developer Agent

Hono + Cloudflare Workers バックエンド開発の専門エージェントです。

## 専門分野

- Hono 4.x フレームワーク
- Cloudflare Workers
- TypeScript
- Zod バリデーション
- Vitest テスト
- Result 型エラーハンドリング

## プロジェクト固有の知識

### ディレクトリ構造

```
backend/
├── src/
│   ├── index.ts            # アプリエントリーポイント
│   ├── routes/             # Hono ルート定義
│   │   ├── health.ts
│   │   ├── weather.ts
│   │   └── advice.ts
│   ├── services/           # ビジネスロジック
│   │   ├── advice/         # AI アドバイス生成
│   │   │   ├── AdviceService.ts
│   │   │   ├── AnthropicClient.ts
│   │   │   ├── PromptBuilder.ts
│   │   │   └── types.ts
│   │   └── weather/        # 天気情報取得
│   │       ├── WeatherService.ts
│   │       ├── OpenMeteoClient.ts
│   │       └── types.ts
│   ├── middleware/         # ミドルウェア
│   │   ├── errorHandler.ts
│   │   └── logger.ts
│   └── utils/              # ユーティリティ
│       └── result.ts       # Result 型
├── biome.json              # Biome 設定
├── vitest.config.ts        # Vitest 設定
└── wrangler.toml           # Cloudflare 設定
```

### Result 型パターン

```typescript
import { Result, ok, err, isOk, isErr } from '@/utils/result';

// サービスの戻り値
async execute(): Promise<Result<Data, Error>> {
  try {
    const data = await fetchData();
    return ok(data);
  } catch (error) {
    return err({ code: 'ERROR', message: String(error) });
  }
}

// ルートでの使用
const result = await service.execute();
if (isOk(result)) {
  return c.json({ success: true, data: result.data });
}
const status = errorCodeToStatus[result.error.code] ?? 500;
return c.json({ success: false, error: result.error.message }, status);
```

### Zod バリデーション

```typescript
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';

const RequestSchema = z.object({
  name: z.string().min(1).max(100),
  value: z.number().min(0).max(100),
});

route.post(
  '/',
  zValidator('json', RequestSchema),
  async (c) => {
    const body = c.req.valid('json');
    // body は型安全
  }
);
```

## タスク実行ガイド

### 新しいエンドポイントを追加する

1. `backend/src/services/[feature]/types.ts` で型定義
2. `backend/src/services/[feature]/FeatureService.ts` でサービス実装
3. `backend/src/routes/[feature].ts` でルート定義
4. `backend/src/index.ts` でルート登録
5. テストを追加

### 外部 API を統合する

1. `backend/src/services/[feature]/ExternalClient.ts` でクライアント作成
2. 環境変数を `wrangler.toml` に追加
3. `Bindings` 型を更新
4. サービスで依存関係として注入

### テストを作成する

```typescript
import { describe, it, expect } from 'vitest';
import { testClient } from 'hono/testing';
import app from '../index';

describe('feature routes', () => {
  const client = testClient(app);

  it('should return success', async () => {
    const response = await client.api.feature.$post({
      json: { /* request */ },
    });
    expect(response.status).toBe(200);
  });
});
```

## コマンド

```bash
pnpm dev          # 開発サーバー起動
pnpm typecheck    # 型チェック
pnpm check        # Biome チェック
pnpm check:fix    # Biome 自動修正
pnpm test         # テスト実行
pnpm test:watch   # テストウォッチ
pnpm deploy       # デプロイ
```

## チェックリスト

- [ ] Zod でリクエストバリデーション
- [ ] Result 型でエラーハンドリング
- [ ] エラーコードから HTTP ステータスへのマッピング
- [ ] サービスでビジネスロジックを分離
- [ ] テストが通過
- [ ] `pnpm check` がパス
- [ ] `pnpm typecheck` がパス

## 参照ドキュメント

- `.claude/typescript-hono-standards.md`
- `.claude/templates/api-route.md`
- `docs/specs/tempoai_technical_spec.md`
- `docs/specs/tempoai_ai_prompt_spec.md`
