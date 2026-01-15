# Hono API ルートテンプレート

## 基本ルート

```typescript
// ============================================
// backend/src/routes/[feature].ts
// ============================================

import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { FeatureService } from '@/services/[feature]/FeatureService';
import { isOk } from '@/utils/result';
import type { Bindings } from '@/types';

// ============================================
// Request/Response Schemas
// ============================================

const GetRequestSchema = z.object({
  id: z.string().min(1),
});

const PostRequestSchema = z.object({
  name: z.string().min(1).max(100),
  value: z.number().min(0).max(100),
  options: z.object({
    enabled: z.boolean().default(true),
  }).optional(),
});

const QuerySchema = z.object({
  limit: z.coerce.number().min(1).max(100).default(10),
  offset: z.coerce.number().min(0).default(0),
});

// ============================================
// Error Code Mapping
// ============================================

const errorCodeToStatus: Record<string, number> = {
  INVALID_REQUEST: 400,
  NOT_FOUND: 404,
  UNAUTHORIZED: 401,
  RATE_LIMIT: 429,
  INTERNAL_ERROR: 500,
};

// ============================================
// Routes
// ============================================

const featureRoutes = new Hono<{ Bindings: Bindings }>();

/**
 * GET /api/[feature]
 * 一覧取得
 */
featureRoutes.get(
  '/',
  zValidator('query', QuerySchema),
  async (c) => {
    const query = c.req.valid('query');

    const service = new FeatureService({
      // 依存関係を注入
    });

    const result = await service.list(query);

    if (isOk(result)) {
      return c.json({
        success: true,
        data: result.data,
        meta: {
          limit: query.limit,
          offset: query.offset,
        },
      });
    }

    const status = errorCodeToStatus[result.error.code] ?? 500;
    return c.json({ success: false, error: result.error.message }, status);
  }
);

/**
 * GET /api/[feature]/:id
 * 詳細取得
 */
featureRoutes.get(
  '/:id',
  zValidator('param', GetRequestSchema),
  async (c) => {
    const { id } = c.req.valid('param');

    const service = new FeatureService({});
    const result = await service.getById(id);

    if (isOk(result)) {
      return c.json({ success: true, data: result.data });
    }

    const status = errorCodeToStatus[result.error.code] ?? 500;
    return c.json({ success: false, error: result.error.message }, status);
  }
);

/**
 * POST /api/[feature]
 * 新規作成
 */
featureRoutes.post(
  '/',
  zValidator('json', PostRequestSchema),
  async (c) => {
    const body = c.req.valid('json');

    const service = new FeatureService({});
    const result = await service.create(body);

    if (isOk(result)) {
      return c.json({ success: true, data: result.data }, 201);
    }

    const status = errorCodeToStatus[result.error.code] ?? 500;
    return c.json({ success: false, error: result.error.message }, status);
  }
);

export { featureRoutes };
```

---

## サービス

```typescript
// ============================================
// backend/src/services/[feature]/FeatureService.ts
// ============================================

import { Result, ok, err } from '@/utils/result';
import type { FeatureError, FeatureData, CreateInput, ListQuery } from './types';

export interface FeatureServiceDeps {
  apiKey?: string;
}

export class FeatureService {
  constructor(private deps: FeatureServiceDeps) {}

  async list(query: ListQuery): Promise<Result<FeatureData[], FeatureError>> {
    try {
      // 実装
      const data: FeatureData[] = [];
      return ok(data);
    } catch (error) {
      return err({
        code: 'INTERNAL_ERROR',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getById(id: string): Promise<Result<FeatureData, FeatureError>> {
    try {
      // 実装
      // if (!found) return err({ code: 'NOT_FOUND', message: 'Not found' });
      const data: FeatureData = { id, name: '', value: 0 };
      return ok(data);
    } catch (error) {
      return err({
        code: 'INTERNAL_ERROR',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async create(input: CreateInput): Promise<Result<FeatureData, FeatureError>> {
    try {
      // バリデーション
      if (!this.validateInput(input)) {
        return err({ code: 'INVALID_REQUEST', message: 'Invalid input' });
      }

      // 作成処理
      const data: FeatureData = {
        id: crypto.randomUUID(),
        name: input.name,
        value: input.value,
      };

      return ok(data);
    } catch (error) {
      return err({
        code: 'INTERNAL_ERROR',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  private validateInput(input: CreateInput): boolean {
    // カスタムバリデーション
    return true;
  }
}
```

---

## 型定義

```typescript
// ============================================
// backend/src/services/[feature]/types.ts
// ============================================

import { z } from 'zod';

// ============================================
// Schemas
// ============================================

export const FeatureDataSchema = z.object({
  id: z.string(),
  name: z.string(),
  value: z.number(),
});

export const CreateInputSchema = z.object({
  name: z.string().min(1).max(100),
  value: z.number().min(0).max(100),
});

// ============================================
// Types
// ============================================

export type FeatureData = z.infer<typeof FeatureDataSchema>;
export type CreateInput = z.infer<typeof CreateInputSchema>;

export type FeatureErrorCode =
  | 'INVALID_REQUEST'
  | 'NOT_FOUND'
  | 'UNAUTHORIZED'
  | 'RATE_LIMIT'
  | 'INTERNAL_ERROR';

export interface FeatureError {
  code: FeatureErrorCode;
  message: string;
  details?: unknown;
}

export interface ListQuery {
  limit: number;
  offset: number;
}
```

---

## テスト

```typescript
// ============================================
// backend/src/routes/[feature].test.ts
// ============================================

import { describe, it, expect, beforeEach } from 'vitest';
import { testClient } from 'hono/testing';
import app from '../index';

describe('[feature] routes', () => {
  const client = testClient(app);

  describe('GET /api/[feature]', () => {
    it('should return list with default pagination', async () => {
      const response = await client.api.[feature].$get();

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.meta.limit).toBe(10);
      expect(data.meta.offset).toBe(0);
    });

    it('should accept pagination params', async () => {
      const response = await client.api.[feature].$get({
        query: { limit: '20', offset: '10' },
      });

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data.meta.limit).toBe(20);
      expect(data.meta.offset).toBe(10);
    });
  });

  describe('POST /api/[feature]', () => {
    it('should create new item', async () => {
      const response = await client.api.[feature].$post({
        json: { name: 'Test', value: 50 },
      });

      expect(response.status).toBe(201);
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.data.name).toBe('Test');
    });

    it('should return 400 for invalid request', async () => {
      const response = await client.api.[feature].$post({
        json: { name: '', value: -1 },
      });

      expect(response.status).toBe(400);
    });
  });
});
```

---

## チェックリスト

- [ ] Zod スキーマでリクエストをバリデーション
- [ ] Result 型でエラーハンドリング
- [ ] エラーコードから HTTP ステータスへのマッピング
- [ ] サービスクラスでビジネスロジックを分離
- [ ] テストが全エンドポイントをカバー
- [ ] 型定義が明確
