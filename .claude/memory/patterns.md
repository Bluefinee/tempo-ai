# コーディングパターン集

このドキュメントには、TempoAI で使用されるコーディングパターンを記録します。

---

## TypeScript パターン

### Result 型（Rust 風エラーハンドリング）

```typescript
// backend/src/utils/result.ts

export type Result<T, E = string> = Ok<T> | Err<E>;

interface Ok<T> {
  ok: true;
  data: T;
}

interface Err<E> {
  ok: false;
  error: E;
}

export const ok = <T>(data: T): Ok<T> => ({ ok: true, data });
export const err = <E>(error: E): Err<E> => ({ ok: false, error });
export const isOk = <T, E>(result: Result<T, E>): result is Ok<T> => result.ok;
export const isErr = <T, E>(result: Result<T, E>): result is Err<E> => !result.ok;

// 使用例
const result = await service.doSomething();
if (isOk(result)) {
  console.log(result.data);
} else {
  console.error(result.error);
}
```

### 型ガード

```typescript
// 型ガード関数
const isValidRequest = (data: unknown): data is AdviceRequest => {
  return (
    typeof data === 'object' &&
    data !== null &&
    'user' in data &&
    'scores' in data
  );
};

// 使用例
if (isValidRequest(body)) {
  // body は AdviceRequest 型として扱える
  processRequest(body);
}
```

### Zod スキーマからの型推論

```typescript
import { z } from 'zod';

// スキーマ定義
const UserProfileSchema = z.object({
  id: z.string(),
  nickname: z.string().min(1).max(20),
  chronotype: z.enum(['morning', 'intermediate', 'evening']),
  age: z.number().min(18).max(120).optional(),
});

// 型を推論
type UserProfile = z.infer<typeof UserProfileSchema>;

// バリデーション
const result = UserProfileSchema.safeParse(data);
if (result.success) {
  // result.data は UserProfile 型
}
```

---

## React Native パターン

### コンポーネント Props パターン

```typescript
// 1. 基本パターン
interface CardProps {
  title: string;
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}

// 2. イベントハンドラ付き
interface ButtonProps {
  label: string;
  onPress: () => void;
  disabled?: boolean;
}

// 3. 制御/非制御コンポーネント
interface InputProps {
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
}
```

### セレクターパターン（Zustand）

```typescript
// ❌ 悪い例：ストア全体を選択
const store = useHealthStore();
// store が変更されるたびに再レンダリング

// ✅ 良い例：必要なプロパティのみ選択
const sleepScore = useHealthStore((state) => state.sleepScore);
const fetchData = useHealthStore((state) => state.fetchData);
// sleepScore が変更された時のみ再レンダリング

// ✅ さらに良い例：セレクター関数を使用
import { selectSleepScore } from '@/stores/healthStore/selectors';
const sleepScore = useHealthStore(selectSleepScore);
```

### Optimistic Update パターン

```typescript
const updateProfile = async (updates: Partial<UserProfile>): Promise<void> => {
  const previousProfile = get().profile;

  // 1. 即座に UI を更新（楽観的更新）
  set((state) => ({
    profile: state.profile ? { ...state.profile, ...updates } : null,
  }));

  try {
    // 2. API に送信
    await apiClient.updateProfile(updates);
  } catch (error) {
    // 3. 失敗時はロールバック
    set({ profile: previousProfile });
    throw error;
  }
};
```

### メモ化パターン

```typescript
// useMemo: 計算結果のメモ化
const expensiveValue = useMemo(() => {
  return calculateExpensiveValue(data);
}, [data]);

// useCallback: 関数のメモ化
const handlePress = useCallback(() => {
  navigation.navigate('Detail', { id });
}, [id, navigation]);

// React.memo: コンポーネントのメモ化
export const ScoreCard = React.memo<ScoreCardProps>(({ score, label }) => {
  return (
    <View>
      <Text>{label}</Text>
      <Text>{score}</Text>
    </View>
  );
});
```

---

## Hono/バックエンドパターン

### ミドルウェアパターン

```typescript
// エラーハンドリングミドルウェア
const errorHandler = (): MiddlewareHandler => {
  return async (c, next) => {
    try {
      await next();
    } catch (error) {
      if (error instanceof ApiError) {
        return c.json({ error: error.message }, error.statusCode);
      }
      console.error('Unexpected error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  };
};

// 使用
app.use('*', errorHandler());
```

### サービスクラスパターン

```typescript
// 依存関係を注入可能なサービス
export interface ServiceDeps {
  apiKey: string;
  timeout?: number;
}

export class FeatureService {
  constructor(private deps: ServiceDeps) {}

  async execute(input: Input): Promise<Result<Output, Error>> {
    // 実装
  }
}

// 使用（テスト時にモック可能）
const service = new FeatureService({
  apiKey: c.env.API_KEY,
  timeout: 5000,
});
```

### レスポンスフォーマットパターン

```typescript
// 成功レスポンス
return c.json({
  success: true,
  data: result,
});

// エラーレスポンス
return c.json({
  success: false,
  error: 'Error message',
}, 400);

// ページネーション付き
return c.json({
  success: true,
  data: items,
  meta: {
    total: 100,
    limit: 10,
    offset: 0,
  },
});
```

---

## ドメインサービスパターン

### 純粋関数パターン

```typescript
// ✅ 純粋関数（推奨）
export const calculateScore = (
  input: ScoreInput
): ScoreResult => {
  // 同じ入力に対して常に同じ出力
  // 副作用なし
  const normalized = normalize(input.value, input.baseline);
  const score = clamp(normalized * 100, 0, 100);
  return { score, status: determineStatus(score) };
};

// ヘルパー関数もpure
const normalize = (value: number, baseline: number): number =>
  baseline !== 0 ? value / baseline : 0;

const clamp = (value: number, min: number, max: number): number =>
  Math.max(min, Math.min(max, value));
```

### 合成パターン

```typescript
// 小さな関数を組み合わせて複雑な計算を構築
export const calculateDailyScores = (
  metrics: HealthMetrics,
  weather: WeatherData
): DailyScores => {
  const recovery = calculateRecoveryScore(metrics);
  const sleep = calculateSleepScore(metrics.sleep);
  const rhythm = calculateRhythmScore(metrics.rhythm);
  const energy = calculateEnergyScore({ recovery, sleep, weather });

  return { recovery, sleep, rhythm, energy };
};
```

---

## エラーハンドリングパターン

### ドメインエラー

```typescript
// カスタムエラークラス
export class TempoError extends Error {
  constructor(
    message: string,
    public code: TempoErrorCode,
    public originalError?: Error
  ) {
    super(message);
    this.name = 'TempoError';
  }
}

export type TempoErrorCode =
  | 'HEALTH_NOT_AUTHORIZED'
  | 'NETWORK_ERROR'
  | 'API_ERROR'
  | 'VALIDATION_ERROR';

// 使用
throw new TempoError(
  'HealthKit authorization required',
  'HEALTH_NOT_AUTHORIZED'
);
```

### 非同期エラーハンドリング

```typescript
// try-catch パターン
try {
  const data = await fetchData();
  processData(data);
} catch (error) {
  if (error instanceof TempoError) {
    handleTempoError(error);
  } else if (error instanceof Error) {
    handleGenericError(error);
  } else {
    handleUnknownError(error);
  }
}

// Result パターン（推奨）
const result = await service.fetchData();
if (isErr(result)) {
  return handleError(result.error);
}
processData(result.data);
```
