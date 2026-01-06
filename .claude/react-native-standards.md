# React Native / Expo コーディング規約

このドキュメントは TempoAI の React Native (Expo) アプリ開発における規約とベストプラクティスを定義します。

---

## 1. プロジェクト構造

```
app/
├── app/                      # expo-router ページ
│   ├── (onboarding)/        # オンボーディングフロー（グループ）
│   ├── (main)/              # メインタブ（グループ）
│   ├── _layout.tsx          # ルートレイアウト
│   └── index.tsx            # エントリーポイント
├── src/
│   ├── components/          # 再利用可能な UI コンポーネント
│   ├── domain/              # ドメインモデル・サービス
│   │   ├── models/          # 型定義
│   │   └── services/        # ビジネスロジック
│   ├── stores/              # Zustand ストア
│   ├── infrastructure/      # ネイティブ機能抽象化
│   ├── api/                 # API クライアント
│   ├── theme/               # デザイントークン
│   ├── constants/           # 定数・モックデータ
│   ├── hooks/               # カスタムフック
│   └── utils/               # ユーティリティ関数
├── assets/                  # 静的アセット
└── app.json                 # Expo 設定
```

---

## 2. ファイル命名規則

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| コンポーネント | PascalCase | `ScoreGauge.tsx` |
| ページ（expo-router） | kebab-case | `basic-info.tsx` |
| フック | camelCase (use prefix) | `useHealthMetrics.ts` |
| ストア | camelCase (Store suffix) | `userStore.ts` |
| サービス | camelCase | `sleepScoreCalculator.ts` |
| 型定義 | camelCase | `healthMetrics.ts` |
| 定数 | camelCase | `mockData.ts` |

---

## 3. コンポーネント設計

### 3.1 関数コンポーネント（Arrow Function）

```typescript
// ✅ Good
export const ScoreGauge: React.FC<ScoreGaugeProps> = ({ score, label }) => {
  return (
    <View style={styles.container}>
      <Text>{label}</Text>
      <Text>{score.value}</Text>
    </View>
  );
};

// ❌ Bad - function 宣言
export function ScoreGauge({ score, label }: ScoreGaugeProps) {
  // ...
}
```

### 3.2 Props 型定義

```typescript
// ✅ Good - interface で明示的に定義
interface ScoreGaugeProps {
  score: Score;
  label: string;
  onPress?: () => void;
}

// ❌ Bad - インライン型
export const ScoreGauge = ({ score, label }: { score: Score; label: string }) => {
  // ...
};
```

### 3.3 スタイル定義

```typescript
// ✅ Good - StyleSheet.create を使用
const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: Spacing.md,
    backgroundColor: Colors.gray[50],
  },
  title: {
    ...Typography.heading2,
    color: Colors.gray[900],
  },
});

// ❌ Bad - インラインスタイル
<View style={{ flex: 1, padding: 16 }}>
```

### 3.4 デザイントークンの使用

```typescript
// ✅ Good - テーマから参照
import { Colors, Spacing, Typography } from '@/theme';

const styles = StyleSheet.create({
  container: {
    padding: Spacing.lg,
    backgroundColor: Colors.primary[500],
  },
});

// ❌ Bad - ハードコード
const styles = StyleSheet.create({
  container: {
    padding: 24,
    backgroundColor: '#4F46E5',
  },
});
```

---

## 4. 状態管理（Zustand）

### 4.1 ストア構成

```typescript
// ✅ Good - 関心の分離
// userStore.ts - ユーザー関連のみ
interface UserState {
  profile: UserProfile | null;
  setProfile: (profile: UserProfile) => void;
}

// healthStore.ts - ヘルスデータ関連のみ
interface HealthState {
  metrics: HealthMetrics | null;
  scores: Scores | null;
  calculateScores: () => void;
}
```

### 4.2 永続化

```typescript
// ✅ Good - persist middleware
export const useUserStore = create<UserState>()(
  persist(
    (set, get) => ({
      profile: null,
      setProfile: (profile) => set({ profile }),
    }),
    {
      name: 'user-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

### 4.3 セレクターの使用

```typescript
// ✅ Good - 必要なプロパティのみ選択（リレンダリング最適化）
const nickname = useUserStore((state) => state.profile?.nickname);
const sleepScore = useHealthStore((state) => state.sleepScore);

// ❌ Bad - ストア全体を選択
const userStore = useUserStore();
const healthStore = useHealthStore();
```

---

## 5. ナビゲーション（expo-router）

### 5.1 ファイルベースルーティング

```
app/
├── (onboarding)/            # グループ（URL に含まれない）
│   ├── _layout.tsx          # Stack Navigator
│   ├── index.tsx            # /onboarding
│   └── nickname.tsx         # /onboarding/nickname
├── (main)/                  # グループ
│   ├── _layout.tsx          # Tab Navigator
│   ├── index.tsx            # / (Home)
│   ├── analytics.tsx        # /analytics
│   └── settings.tsx         # /settings
└── insight-detail.tsx       # /insight-detail (Modal)
```

### 5.2 ナビゲーション

```typescript
import { useRouter, useLocalSearchParams } from 'expo-router';

// ✅ Good
const router = useRouter();
router.push('/onboarding/nickname');
router.replace('/(main)');

// パラメータ付き
router.push({
  pathname: '/insight-detail',
  params: { insightId: '123' },
});
```

---

## 6. 型安全性

### 6.1 any 禁止

```typescript
// ✅ Good
const parseResponse = (data: unknown): UserProfile => {
  // Zod や 型ガードで検証
};

// ❌ Bad
const parseResponse = (data: any): UserProfile => {
  return data as UserProfile;
};
```

### 6.2 明示的な戻り値型

```typescript
// ✅ Good
export const calculateSleepScore = (sleep: SleepMetrics): Score => {
  // ...
};

// ❌ Bad - 推論に頼る
export const calculateSleepScore = (sleep: SleepMetrics) => {
  // ...
};
```

---

## 7. インフラストラクチャ抽象化

### 7.1 Repository パターン

```typescript
// インターフェース定義
export interface HealthRepository {
  requestAuthorization(): Promise<HealthAuthorizationStatus>;
  fetchTodayMetrics(): Promise<HealthMetrics>;
  fetchSleepHistory(days: number): Promise<SleepMetrics[]>;
}

// モック実装
export class MockHealthRepository implements HealthRepository {
  async requestAuthorization(): Promise<HealthAuthorizationStatus> {
    return 'authorized';
  }
  // ...
}

// 将来の実際の実装
export class HealthKitRepository implements HealthRepository {
  // iOS HealthKit 実装
}

export class HealthConnectRepository implements HealthRepository {
  // Android Health Connect 実装
}
```

---

## 8. エラーハンドリング

### 8.1 カスタムエラー

```typescript
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
  | 'API_ERROR';
```

### 8.2 try-catch

```typescript
// ✅ Good - 具体的なエラーハンドリング
try {
  const metrics = await healthRepository.fetchTodayMetrics();
  setMetrics(metrics);
} catch (error) {
  if (error instanceof TempoError) {
    handleTempoError(error);
  } else {
    console.error('Unexpected error:', error);
    showGenericError();
  }
}
```

---

## 9. パフォーマンス

### 9.1 memo 化

```typescript
// ✅ Good - 高コストな計算やコンポーネント
const memoizedScore = useMemo(
  () => calculateComplexScore(metrics),
  [metrics]
);

const MemoizedChart = React.memo(ScoreChart);
```

### 9.2 コールバックの安定性

```typescript
// ✅ Good
const handlePress = useCallback(() => {
  router.push('/detail');
}, [router]);

// ❌ Bad - 毎回新しい関数を生成
<Button onPress={() => router.push('/detail')} />
```

---

## 10. テスト

### 10.1 ドメインロジックのテスト

```typescript
// sleepScoreCalculator.test.ts
describe('calculateSleepScore', () => {
  it('should return excellent score for optimal sleep', () => {
    const sleep: SleepMetrics = {
      bedtime: new Date('2024-01-01T23:00:00'),
      wakeTime: new Date('2024-01-02T06:30:00'),
      durationMinutes: 450,
      deepSleepMinutes: 90,
      remSleepMinutes: 100,
    };

    const score = calculateSleepScore(sleep);
    expect(score.status).toBe('excellent');
  });
});
```

### 10.2 コンポーネントのテスト

```typescript
// ScoreGauge.test.tsx
import { render, screen } from '@testing-library/react-native';

describe('ScoreGauge', () => {
  it('should display score value', () => {
    const score = createScore(85);
    render(<ScoreGauge score={score} label="Sleep" />);

    expect(screen.getByText('85')).toBeTruthy();
    expect(screen.getByText('Sleep')).toBeTruthy();
  });
});
```

---

## 11. import パス

```typescript
// ✅ Good - エイリアスを使用
import { Colors, Spacing } from '@/theme';
import { useUserStore } from '@/stores';
import { Score } from '@/domain/models';

// ❌ Bad - 相対パス
import { Colors } from '../../../theme/colors';
```

---

## 12. コメントポリシー

```typescript
// ✅ Good - "なぜ" を説明
// HRV の基準値は 30 日間の平均から計算（研究ベース）
const baseline = calculateBaseline(hrvHistory, 30);

// ❌ Bad - "何を" の説明（コードで明らか）
// 基準値を計算する
const baseline = calculateBaseline(hrvHistory, 30);
```

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-06 | 初版作成 |
