---
description: 指定されたファイル/関数のテストを生成
allowed-tools: Read, Write, Glob, Grep, Bash
---

# テスト生成コマンド

対象: $ARGUMENTS

## 実行手順

### 1. 対象ファイルの分析

1. 対象ファイルを読み込む
2. エクスポートされている関数・クラスを特定
3. 依存関係を確認

### 2. テストファイルの配置

| 対象 | テストファイル配置 |
|-----|-------------------|
| `app/src/domain/services/xxx.ts` | `app/src/domain/services/xxx.test.ts` |
| `app/src/components/Xxx.tsx` | `app/src/components/Xxx.test.tsx` |
| `backend/src/services/xxx.ts` | `backend/src/services/xxx.test.ts` |

### 3. テストの構造

```typescript
import { describe, it, expect } from 'vitest'; // または jest

describe('関数名/クラス名', () => {
  describe('正常系', () => {
    it('should 期待される動作', () => {
      // Arrange
      const input = ...;

      // Act
      const result = functionUnderTest(input);

      // Assert
      expect(result).toEqual(expected);
    });
  });

  describe('異常系', () => {
    it('should handle invalid input', () => {
      // ...
    });
  });

  describe('境界条件', () => {
    it('should handle edge case', () => {
      // ...
    });
  });
});
```

### 4. TempoAI 固有のテストパターン

#### スコア計算のテスト

```typescript
describe('calculateSleepScore', () => {
  it('should return excellent for 7.5+ hours of quality sleep', () => {
    const metrics: SleepMetrics = {
      durationMinutes: 450, // 7.5 hours
      efficiency: 0.9,
      // ...
    };

    const score = calculateSleepScore(metrics);
    expect(score.status).toBe('excellent');
    expect(score.value).toBeGreaterThanOrEqual(80);
  });
});
```

#### モックデータの使用

```typescript
import { createMockHealthMetrics } from '@/constants/mockDataFactory';

const mockMetrics = createMockHealthMetrics({
  sleep: { durationMinutes: 420 }
});
```

### 5. テスト実行

```bash
# アプリ
cd app && npm test -- --watch

# バックエンド
cd backend && pnpm test:watch
```

## 完了条件

- [ ] テストファイルが作成されている
- [ ] すべてのテストがパスする
- [ ] カバレッジが向上している（目標: 80%+）
