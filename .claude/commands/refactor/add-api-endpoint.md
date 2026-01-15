---
description: 新しいAPIエンドポイントを追加
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# APIエンドポイント追加

エンドポイント: $ARGUMENTS

## 手順

### 1. 型定義の作成

ファイル: `backend/src/services/[feature]/types.ts`

```typescript
import { z } from 'zod';

// リクエストスキーマ
export const FeatureRequestSchema = z.object({
  // フィールド定義
});

export type FeatureRequest = z.infer<typeof FeatureRequestSchema>;

// レスポンススキーマ
export const FeatureResponseSchema = z.object({
  // フィールド定義
});

export type FeatureResponse = z.infer<typeof FeatureResponseSchema>;

// エラーコード
export type FeatureErrorCode =
  | 'INVALID_REQUEST'
  | 'NOT_FOUND'
  | 'INTERNAL_ERROR';
```

### 2. サービスの作成

ファイル: `backend/src/services/[feature]/FeatureService.ts`

```typescript
import { Result, ok, err } from '@/utils/result';
import { FeatureRequest, FeatureResponse, FeatureErrorCode } from './types';

export interface FeatureServiceDeps {
  // 依存関係（外部API、設定など）
}

export class FeatureService {
  constructor(private deps: FeatureServiceDeps) {}

  async execute(
    request: FeatureRequest
  ): Promise<Result<FeatureResponse, { code: FeatureErrorCode; message: string }>> {
    // 1. バリデーション
    const validation = FeatureRequestSchema.safeParse(request);
    if (!validation.success) {
      return err({ code: 'INVALID_REQUEST', message: validation.error.message });
    }

    // 2. ビジネスロジック
    try {
      const result = await this.processRequest(validation.data);
      return ok(result);
    } catch (error) {
      return err({ code: 'INTERNAL_ERROR', message: String(error) });
    }
  }

  private async processRequest(data: FeatureRequest): Promise<FeatureResponse> {
    // 実装
  }
}
```

### 3. ルートの作成

ファイル: `backend/src/routes/[feature].ts`

```typescript
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { FeatureService } from '@/services/[feature]/FeatureService';
import { FeatureRequestSchema } from '@/services/[feature]/types';
import { isOk } from '@/utils/result';

const featureRoutes = new Hono<{ Bindings: Bindings }>();

const errorCodeToStatus: Record<string, number> = {
  INVALID_REQUEST: 400,
  NOT_FOUND: 404,
  INTERNAL_ERROR: 500,
};

featureRoutes.post(
  '/',
  zValidator('json', FeatureRequestSchema),
  async (c) => {
    const request = c.req.valid('json');

    const service = new FeatureService({
      // 依存関係を注入
    });

    const result = await service.execute(request);

    if (isOk(result)) {
      return c.json({ success: true, data: result.data });
    }

    const status = errorCodeToStatus[result.error.code] ?? 500;
    return c.json({ success: false, error: result.error.message }, status);
  }
);

export { featureRoutes };
```

### 4. メインアプリへの登録

ファイル: `backend/src/index.ts`

```typescript
import { featureRoutes } from './routes/[feature]';

app.route('/api/[feature]', featureRoutes);
```

### 5. テストの作成

ファイル: `backend/src/routes/[feature].test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { testClient } from 'hono/testing';
import app from '../index';

describe('[feature] routes', () => {
  const client = testClient(app);

  describe('POST /api/[feature]', () => {
    it('should return success for valid request', async () => {
      const response = await client.api.[feature].$post({
        json: { /* valid request */ },
      });

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data.success).toBe(true);
    });

    it('should return 400 for invalid request', async () => {
      const response = await client.api.[feature].$post({
        json: { /* invalid request */ },
      });

      expect(response.status).toBe(400);
    });
  });
});
```

### 6. フロントエンドAPIクライアントの更新

ファイル: `app/src/api/client.ts`

```typescript
async [featureName](request: FeatureRequest): Promise<ApiResponse<FeatureResponse>> {
  return this.fetch('/api/[feature]', {
    method: 'POST',
    body: request,
  });
}
```

## チェックリスト

- [ ] 型定義が完了
- [ ] サービスが実装済み
- [ ] ルートが登録済み
- [ ] テストが通過
- [ ] フロントエンドクライアントが更新済み
- [ ] 型チェックがパス
