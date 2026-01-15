# テストテンプレート

## Jest（フロントエンド）

### ドメインサービステスト

```typescript
// ============================================
// app/src/domain/services/[service].test.ts
// ============================================

import { describe, it, expect, beforeEach } from '@jest/globals';
import {
  calculateScore,
  CalculationInput,
  CalculationResult,
} from './[service]';

describe('[serviceName]', () => {
  // ============================================
  // Setup
  // ============================================

  let defaultInput: CalculationInput;

  beforeEach(() => {
    defaultInput = {
      value: 42,
      baseline: 40,
    };
  });

  // ============================================
  // Test Suites
  // ============================================

  describe('calculateScore', () => {
    // 正常系
    describe('正常系', () => {
      it('正しいスコアを計算する', () => {
        const result = calculateScore(defaultInput);

        expect(result.score).toBeGreaterThan(0);
        expect(result.score).toBeLessThanOrEqual(100);
      });

      it('ベースラインより高い値で高スコアになる', () => {
        const input = { ...defaultInput, value: 50 };
        const result = calculateScore(input);

        expect(result.status).toBe('excellent');
      });
    });

    // 境界条件
    describe('境界条件', () => {
      it('最小値でも動作する', () => {
        const input = { ...defaultInput, value: 0 };
        const result = calculateScore(input);

        expect(result.score).toBeGreaterThanOrEqual(0);
      });

      it('ゼロ除算を回避する', () => {
        const input = { ...defaultInput, baseline: 0 };

        expect(() => calculateScore(input)).not.toThrow();
      });
    });

    // エラーケース
    describe('エラーケース', () => {
      it('不正な入力でエラーをスローしない', () => {
        const input = { value: NaN, baseline: 42 };

        expect(() => calculateScore(input as CalculationInput)).not.toThrow();
      });
    });
  });
});
```

### コンポーネントテスト

```typescript
// ============================================
// app/src/components/[Component].test.tsx
// ============================================

import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { ScoreCard } from './ScoreCard';

describe('ScoreCard', () => {
  const defaultProps = {
    score: { value: 85, status: 'excellent' as const },
    label: 'Recovery',
  };

  describe('レンダリング', () => {
    it('ラベルを表示する', () => {
      render(<ScoreCard {...defaultProps} />);

      expect(screen.getByText('Recovery')).toBeTruthy();
    });

    it('スコア値を表示する', () => {
      render(<ScoreCard {...defaultProps} />);

      expect(screen.getByText('85')).toBeTruthy();
    });
  });

  describe('インタラクション', () => {
    it('onPressが呼ばれる', () => {
      const onPress = jest.fn();
      render(<ScoreCard {...defaultProps} onPress={onPress} />);

      fireEvent.press(screen.getByTestId('score-card'));

      expect(onPress).toHaveBeenCalledTimes(1);
    });
  });

  describe('条件分岐', () => {
    it('excellent状態で緑色になる', () => {
      render(<ScoreCard {...defaultProps} />);

      // スタイルのテスト
      const scoreText = screen.getByText('85');
      expect(scoreText.props.style).toContainEqual(
        expect.objectContaining({ color: expect.any(String) })
      );
    });
  });
});
```

---

## Vitest（バックエンド）

### サービステスト

```typescript
// ============================================
// backend/src/services/[feature]/[Service].test.ts
// ============================================

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { FeatureService } from './FeatureService';
import { isOk, isErr } from '@/utils/result';

describe('FeatureService', () => {
  let service: FeatureService;

  beforeEach(() => {
    service = new FeatureService({
      apiKey: 'test-key',
    });
  });

  describe('create', () => {
    it('有効な入力で成功する', async () => {
      const result = await service.create({
        name: 'Test',
        value: 50,
      });

      expect(isOk(result)).toBe(true);
      if (isOk(result)) {
        expect(result.data.name).toBe('Test');
        expect(result.data.value).toBe(50);
      }
    });

    it('無効な入力でエラーを返す', async () => {
      const result = await service.create({
        name: '',
        value: -1,
      });

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('INVALID_REQUEST');
      }
    });
  });

  describe('getById', () => {
    it('存在しないIDでNOT_FOUNDを返す', async () => {
      const result = await service.getById('non-existent');

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('NOT_FOUND');
      }
    });
  });
});
```

### ルートテスト

```typescript
// ============================================
// backend/src/routes/[feature].test.ts
// ============================================

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { testClient } from 'hono/testing';
import app from '../index';

describe('[feature] routes', () => {
  const client = testClient(app);

  describe('POST /api/[feature]', () => {
    it('正常なリクエストで201を返す', async () => {
      const response = await client.api.[feature].$post({
        json: {
          name: 'Test',
          value: 50,
        },
      });

      expect(response.status).toBe(201);

      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.name).toBe('Test');
    });

    it('不正なリクエストで400を返す', async () => {
      const response = await client.api.[feature].$post({
        json: {
          name: '', // 空文字は無効
          value: 50,
        },
      });

      expect(response.status).toBe(400);

      const body = await response.json();
      expect(body.success).toBe(false);
    });

    it('必須フィールド欠如で400を返す', async () => {
      const response = await client.api.[feature].$post({
        json: {
          // name が欠如
          value: 50,
        } as any,
      });

      expect(response.status).toBe(400);
    });
  });

  describe('GET /api/[feature]/:id', () => {
    it('存在しないIDで404を返す', async () => {
      const response = await client.api.[feature][':id'].$get({
        param: { id: 'non-existent' },
      });

      expect(response.status).toBe(404);
    });
  });
});
```

### モックの使用

```typescript
// ============================================
// 外部依存のモック
// ============================================

import { vi } from 'vitest';

// モジュール全体をモック
vi.mock('@/services/external/ExternalClient', () => ({
  ExternalClient: vi.fn().mockImplementation(() => ({
    fetch: vi.fn().mockResolvedValue({ data: 'mocked' }),
  })),
}));

// 個別のモック
const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

beforeEach(() => {
  mockFetch.mockReset();
  mockFetch.mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ data: 'test' }),
  });
});
```

---

## テスト戦略

### カバレッジ目標

| カテゴリ | 目標 |
|---------|------|
| ドメインサービス | 90%+ |
| API ルート | 80%+ |
| コンポーネント | 60%+ |
| ユーティリティ | 95%+ |

### テストの種類

1. **Unit Test**: 単一の関数/クラス
2. **Integration Test**: 複数のコンポーネント連携
3. **E2E Test**: 実際のユーザーフロー（今後追加）

### テスト命名規則

```typescript
describe('対象の名前', () => {
  describe('メソッド/機能', () => {
    it('should [期待される動作] when [条件]', () => {
      // ...
    });
  });
});
```
