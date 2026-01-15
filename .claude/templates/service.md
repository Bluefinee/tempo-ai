# ドメインサービステンプレート

## 基本サービス（純粋関数）

```typescript
// ============================================
// app/src/domain/services/[serviceName].ts
// ============================================

// ============================================
// Types
// ============================================

export interface CalculationInput {
  /** 入力値の説明 */
  value: number;
  /** ベースライン値 */
  baseline: number;
  /** オプションの設定 */
  options?: CalculationOptions;
}

export interface CalculationOptions {
  /** 補正係数 */
  correctionFactor?: number;
  /** 最小値 */
  min?: number;
  /** 最大値 */
  max?: number;
}

export interface CalculationResult {
  /** 計算結果のスコア（0-100） */
  score: number;
  /** ステータス */
  status: ScoreStatus;
  /** 詳細情報 */
  details: CalculationDetails;
}

export type ScoreStatus = 'excellent' | 'good' | 'moderate' | 'needs_attention';

interface CalculationDetails {
  /** 正規化された値 */
  normalizedValue: number;
  /** ベースラインとの差分 */
  deltaFromBaseline: number;
}

// ============================================
// Constants
// ============================================

const DEFAULT_OPTIONS: Required<CalculationOptions> = {
  correctionFactor: 1.0,
  min: 0,
  max: 100,
};

const STATUS_THRESHOLDS = {
  excellent: 80,
  good: 60,
  moderate: 40,
} as const;

// ============================================
// Main Function
// ============================================

/**
 * [関数の説明]
 *
 * 計算ロジック:
 * 1. ベースラインとの比率を計算
 * 2. 0-100 のスコアに正規化
 * 3. ステータスを判定
 *
 * @param input - 入力データ
 * @returns 計算結果
 *
 * @example
 * const result = calculateSomething({
 *   value: 45,
 *   baseline: 42,
 * });
 * // { score: 85, status: 'excellent', details: {...} }
 */
export const calculateSomething = (input: CalculationInput): CalculationResult => {
  const options = { ...DEFAULT_OPTIONS, ...input.options };

  // 1. 比率計算
  const ratio = input.value / input.baseline;

  // 2. スコア計算
  const rawScore = normalizeRatio(ratio);
  const score = clamp(rawScore * options.correctionFactor, options.min, options.max);

  // 3. ステータス判定
  const status = determineStatus(score);

  // 4. 結果の構築
  return {
    score: Math.round(score),
    status,
    details: {
      normalizedValue: ratio,
      deltaFromBaseline: input.value - input.baseline,
    },
  };
};

// ============================================
// Helper Functions (Private)
// ============================================

/**
 * 比率を 0-100 のスコアに正規化
 * 比率 0.7-1.3 を 0-100 にマッピング
 */
const normalizeRatio = (ratio: number): number => {
  // 0.7 = 0, 1.0 = 50, 1.3 = 100
  return ((ratio - 0.7) / 0.6) * 100;
};

/**
 * スコアからステータスを判定
 */
const determineStatus = (score: number): ScoreStatus => {
  if (score >= STATUS_THRESHOLDS.excellent) return 'excellent';
  if (score >= STATUS_THRESHOLDS.good) return 'good';
  if (score >= STATUS_THRESHOLDS.moderate) return 'moderate';
  return 'needs_attention';
};

/**
 * 値を指定範囲内に制限
 */
const clamp = (value: number, min: number, max: number): number =>
  Math.max(min, Math.min(max, value));
```

---

## テストファイル

```typescript
// ============================================
// app/src/domain/services/[serviceName].test.ts
// ============================================

import { describe, it, expect } from '@jest/globals';
import {
  calculateSomething,
  CalculationInput,
  CalculationResult,
} from './[serviceName]';

describe('[serviceName]', () => {
  describe('calculateSomething', () => {
    // ============================================
    // 正常系
    // ============================================

    describe('正常系', () => {
      it('ベースラインと同じ値の場合、中間スコアを返す', () => {
        const input: CalculationInput = {
          value: 42,
          baseline: 42,
        };

        const result = calculateSomething(input);

        expect(result.score).toBe(50);
        expect(result.status).toBe('moderate');
      });

      it('ベースラインより高い値の場合、高スコアを返す', () => {
        const input: CalculationInput = {
          value: 50,
          baseline: 42,
        };

        const result = calculateSomething(input);

        expect(result.score).toBeGreaterThan(50);
        expect(result.status).toBe('excellent');
      });

      it('ベースラインより低い値の場合、低スコアを返す', () => {
        const input: CalculationInput = {
          value: 35,
          baseline: 42,
        };

        const result = calculateSomething(input);

        expect(result.score).toBeLessThan(50);
      });
    });

    // ============================================
    // 境界条件
    // ============================================

    describe('境界条件', () => {
      it('スコアは0未満にならない', () => {
        const input: CalculationInput = {
          value: 10,
          baseline: 100,
        };

        const result = calculateSomething(input);

        expect(result.score).toBeGreaterThanOrEqual(0);
      });

      it('スコアは100を超えない', () => {
        const input: CalculationInput = {
          value: 100,
          baseline: 10,
        };

        const result = calculateSomething(input);

        expect(result.score).toBeLessThanOrEqual(100);
      });
    });

    // ============================================
    // オプション
    // ============================================

    describe('オプション', () => {
      it('correctionFactor が適用される', () => {
        const input: CalculationInput = {
          value: 42,
          baseline: 42,
          options: { correctionFactor: 1.2 },
        };

        const result = calculateSomething(input);

        expect(result.score).toBe(60); // 50 * 1.2
      });
    });

    // ============================================
    // ステータス判定
    // ============================================

    describe('ステータス判定', () => {
      const testCases: Array<{ score: number; expected: string }> = [
        { score: 85, expected: 'excellent' },
        { score: 70, expected: 'good' },
        { score: 50, expected: 'moderate' },
        { score: 30, expected: 'needs_attention' },
      ];

      testCases.forEach(({ score, expected }) => {
        it(`スコア ${score} は ${expected} ステータス`, () => {
          // スコアが指定値になるように入力を調整
          // ...
        });
      });
    });
  });
});
```

---

## 設計原則

### 純粋関数

- 同じ入力に対して常に同じ出力
- 副作用なし（外部状態の変更なし）
- 外部依存なし（グローバル変数、API呼び出しなし）

### 型安全性

- すべての入出力に明示的な型
- オプショナルパラメータには適切なデフォルト値
- Union 型でステータスを表現

### テスタビリティ

- 依存関係の注入（必要な場合）
- 小さな関数に分割
- 境界条件のテスト
