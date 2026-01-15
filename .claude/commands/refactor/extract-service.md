---
description: ビジネスロジックをドメインサービスに抽出
allowed-tools: Read, Write, Edit, Glob, Grep
---

# サービス抽出リファクタリング

対象: $ARGUMENTS

## 手順

### 1. 対象コードの分析

1. 指定されたファイルを読み込む
2. 抽出すべきロジックを特定:
   - 計算ロジック
   - データ変換ロジック
   - ビジネスルール

### 2. サービス設計

```typescript
// 入力型
interface CalculationInput {
  // 必要なデータ
}

// 出力型
interface CalculationResult {
  // 結果データ
}

// 関数シグネチャ
export const calculateSomething = (input: CalculationInput): CalculationResult => {
  // 純粋関数として実装
};
```

### 3. サービス作成

ファイル: `app/src/domain/services/[serviceName].ts`

```typescript
/**
 * [サービスの説明]
 *
 * @param input - 入力データの説明
 * @returns 出力データの説明
 */
export const calculateSomething = (input: CalculationInput): CalculationResult => {
  // 1. 入力の検証（必要に応じて）

  // 2. 計算ロジック

  // 3. 結果の返却
  return result;
};

// ヘルパー関数（プライベート）
const helperFunction = (value: number): number => {
  // ...
};
```

### 4. テストの作成

ファイル: `app/src/domain/services/[serviceName].test.ts`

```typescript
import { describe, it, expect } from 'jest';
import { calculateSomething } from './[serviceName]';

describe('[serviceName]', () => {
  describe('calculateSomething', () => {
    it('should calculate correctly for normal input', () => {
      const input: CalculationInput = { /* ... */ };
      const result = calculateSomething(input);
      expect(result).toEqual({ /* expected */ });
    });

    it('should handle edge case', () => {
      // ...
    });
  });
});
```

### 5. 元のファイルを更新

1. 新しいサービスをインポート
2. インラインロジックをサービス呼び出しに置き換え

### 6. index.ts への追加

`app/src/domain/services/index.ts`:
```typescript
export * from './[serviceName]';
```

## 設計原則

### 純粋関数

```typescript
// ✅ 純粋関数（推奨）
export const calculate = (input: Input): Output => {
  return { value: input.a + input.b };
};

// ❌ 副作用あり（避ける）
export const calculate = (input: Input): Output => {
  console.log('Calculating...'); // 副作用
  someGlobalState.update();      // 副作用
  return { value: input.a + input.b };
};
```

### 単一責任

```typescript
// ✅ 単一責任
export const calculateHrvScore = (hrv: HrvMetrics): number => { /* ... */ };
export const calculateSleepScore = (sleep: SleepMetrics): number => { /* ... */ };

// ❌ 複数責任
export const calculateAllScores = (data: AllData): AllScores => {
  // HRV計算 + 睡眠計算 + リズム計算 + ...
};
```
