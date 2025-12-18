# Phase 7: Backend基盤設計書

**フェーズ**: 7 / 14  
**Part**: B（バックエンド）  
**前提フェーズ**: なし（独立、Part Aと並行開発可能）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書

### 🔧 Backend専用資料
- **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - TypeScript + Hono 開発標準

### ✅ 実装完了後の必須作業
実装完了後は必ず以下を実行してください：
```bash
# TypeScript型チェック
npm run typecheck

# リント・フォーマット確認
npm run lint

# テスト実行
npm test
```

---

## このフェーズで実現すること

1. **Hono Router**のセットアップ
2. **`/api/advice`エンドポイント**の実装（固定JSON返却）
3. **型定義**（リクエスト・レスポンス）
4. **iOS APIClient**の実装と疎通確認

---

## 完了条件

- [ ] Cloudflare Workersにデプロイ可能な状態
- [ ] `/api/advice` エンドポイントがPOSTリクエストを受け付ける
- [ ] 固定のアドバイスJSONが返却される
- [ ] iOSアプリからAPIを呼び出し、レスポンスを受け取れる
- [ ] リクエスト/レスポンスの型定義が完了している

---

## ディレクトリ構造

```
backend/
├── src/
│   ├── index.ts              # エントリーポイント
│   ├── routes/
│   │   └── advice.ts         # アドバイスエンドポイント
│   ├── types/
│   │   ├── request.ts        # リクエスト型定義
│   │   ├── response.ts       # レスポンス型定義
│   │   └── domain.ts         # ドメイン型定義
│   └── middleware/
│       └── auth.ts           # API認証（シンプル版）
├── wrangler.toml
├── package.json
└── tsconfig.json
```

---

## エンドポイント設計

### POST /api/advice

メインアドバイス生成エンドポイント。

このフェーズでは実際のAI生成は行わず、固定のMockレスポンスを返す。

#### リクエスト

```typescript
interface AdviceRequest {
  userProfile: UserProfile;
  healthData: HealthData;
  location: LocationData;
  context: RequestContext;
}
```

#### レスポンス

```typescript
interface AdviceResponse {
  success: boolean;
  data?: {
    mainAdvice: DailyAdvice;
    additionalAdvice?: AdditionalAdvice;
  };
  error?: string;
}
```

---

## 型定義

### UserProfile

```typescript
interface UserProfile {
  nickname: string;
  age: number;
  gender: "male" | "female" | "other" | "not_specified";
  weightKg: number;
  heightCm: number;
  occupation?: Occupation;
  lifestyleRhythm?: "morning" | "night" | "irregular";
  exerciseFrequency?: "daily" | "three_to_four" | "one_to_two" | "rarely";
  alcoholFrequency?: "never" | "monthly" | "one_to_two" | "three_or_more";
  interests: Interest[];
}

type Occupation =
  | "it_engineer"
  | "sales"
  | "standing_work"
  | "medical"
  | "creative"
  | "homemaker"
  | "student"
  | "freelance"
  | "other";

type Interest =
  | "beauty"
  | "fitness"
  | "mental_health"
  | "work_performance"
  | "nutrition"
  | "sleep";
```

### HealthData

```typescript
interface HealthData {
  date: string; // ISO 8601
  sleep?: SleepData;
  morningVitals?: MorningVitals;
  yesterdayActivity?: ActivityData;
  weekTrends?: WeekTrends;
}

interface SleepData {
  bedtime?: string;
  wakeTime?: string;
  durationHours: number;
  deepSleepHours?: number;
  remSleepHours?: number;
  awakenings: number;
  avgHeartRate?: number;
}

interface MorningVitals {
  restingHeartRate?: number;
  hrvMs?: number;
  bloodOxygen?: number;
}

interface ActivityData {
  steps: number;
  workoutMinutes?: number;
  workoutType?: string;
  caloriesBurned?: number;
}

interface WeekTrends {
  avgSleepHours: number;
  avgHrv?: number;
  avgRestingHeartRate?: number;
  avgSteps: number;
  totalWorkoutHours?: number;
}
```

### LocationData

```typescript
interface LocationData {
  latitude: number;
  longitude: number;
  city?: string;
}
```

### RequestContext

```typescript
interface RequestContext {
  currentTime: string; // ISO 8601
  dayOfWeek: DayOfWeek;
  isMonday: boolean;
  recentDailyTries: string[]; // 過去2週間のトピック
  lastWeeklyTry?: string;
}

type DayOfWeek =
  | "monday"
  | "tuesday"
  | "wednesday"
  | "thursday"
  | "friday"
  | "saturday"
  | "sunday";
```

### DailyAdvice（レスポンス）

```typescript
interface DailyAdvice {
  greeting: string;
  condition: {
    summary: string;
    detail: string;
  };
  actionSuggestions: ActionSuggestion[];
  closingMessage: string;
  dailyTry: TryContent;
  weeklyTry: TryContent | null;
  generatedAt: string;
  timeSlot: "morning" | "afternoon" | "evening";
}

interface ActionSuggestion {
  icon: IconType;
  title: string;
  detail: string;
}

type IconType =
  | "fitness"
  | "stretch"
  | "nutrition"
  | "hydration"
  | "rest"
  | "work"
  | "sleep"
  | "mental"
  | "beauty"
  | "outdoor";

interface TryContent {
  title: string;
  summary: string;
  detail: string;
}
```

### AdditionalAdvice

```typescript
interface AdditionalAdvice {
  timeSlot: "afternoon" | "evening";
  greeting: string;
  message: string;
  generatedAt: string;
}
```

---

## Mockレスポンス

このフェーズで返却する固定レスポンス:

```typescript
const mockAdviceResponse: AdviceResponse = {
  success: true,
  data: {
    mainAdvice: {
      greeting: "〇〇さん、おはようございます",
      condition: {
        summary: "昨夜は7時間の良質な睡眠が取れましたね。今朝のHRVは72msと高く、体の回復が十分に進んでいます。今日はトレーニングに最適なコンディションですよ！",
        detail: "昨夜は7時間の良質な睡眠が取れましたね。深い睡眠が1時間45分と、筋肉の回復に理想的な状態です。\n\n今朝のHRVは72msと、過去7日平均の68msを上回っています。日曜日のアクティブレストが功を奏して、体の回復が十分に進んでいます。\n\n今日は晴れて気温も14℃まで上がる予報です。トレーニングに最適なコンディションですよ！",
      },
      actionSuggestions: [
        {
          icon: "fitness",
          title: "午前中に高強度トレーニング",
          detail: "HRVが高く、睡眠の質も良いため、パフォーマンスを最大限発揮できる状態です。",
        },
        {
          icon: "nutrition",
          title: "トレーニング後の栄養補給",
          detail: "30分以内にプロテインと炭水化物を一緒に摂ることで、筋グリコーゲンの回復が早まります。",
        },
      ],
      closingMessage: "今日は心身ともに最高のコンディションです。ぜひ全力でチャレンジして、充実した一日をお過ごしください。",
      dailyTry: {
        title: "ドロップセット法に挑戦",
        summary: "トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？",
        detail: "今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？...",
      },
      weeklyTry: null,
      generatedAt: new Date().toISOString(),
      timeSlot: "morning",
    },
  },
};
```

---

## API認証（シンプル版）

MVP段階ではシンプルなAPIキー認証を使用:

```typescript
const API_KEY_HEADER = "X-API-Key";
const VALID_API_KEY = "tempo-ai-mobile-app-key-v1";
```

**注意**: 
- モバイルアプリに埋め込んだキーはリバースエンジニアリングで漏洩する可能性がある
- 本番運用では適切な認証方式への移行が必要
- 現段階では識別子・レート制限・ロギング用途として使用

---

## iOS APIClient

iOSアプリ側に実装するAPIクライアント:

### 基本構造

```
APIClient
├── baseURL: String
├── session: URLSession
└── methods:
    ├── generateAdvice(request:) async throws -> DailyAdvice
    └── generateAdditionalAdvice(request:) async throws -> AdditionalAdvice
```

### 実装ポイント

- URLSessionを使用
- async/awaitで非同期処理
- エラーハンドリング（ネットワークエラー、APIエラー）
- JSONデコード

---

## 環境変数

### wrangler.toml

```toml
name = "tempo-ai-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
ENVIRONMENT = "development"
```

### Secrets（Phase 9で追加）

- `ANTHROPIC_API_KEY` - Claude APIキー

---

## エラーレスポンス形式

```typescript
interface ErrorResponse {
  success: false;
  error: string;
  code?: string;
}
```

### エラーコード例

| コード | 意味 |
|--------|------|
| `UNAUTHORIZED` | 認証エラー |
| `VALIDATION_ERROR` | リクエストバリデーションエラー |
| `INTERNAL_ERROR` | サーバー内部エラー |

---

## 疎通確認手順

1. Backend をローカルで起動（`wrangler dev`）
2. iOSシミュレータでアプリを起動
3. APIClient から `/api/advice` を呼び出し
4. Mockレスポンスが正しく返却されることを確認
5. JSONデコードが正しく行われることを確認

---

## 今後のフェーズとの関係

### Phase 8で追加

- Open-Meteo Weather API 統合
- Open-Meteo Air Quality API 統合
- LocationDataを使った気象データ取得

### Phase 9で追加

- Claude API統合
- Mockレスポンスを実際のAI生成に置き換え

### Phase 10で変更

- iOS側のMockデータを削除し、このAPIに接続

---

## 関連ドキュメント

- `technical-spec.md` - セクション3「バックエンド設計」
- `ai-prompt-design.md` - セクション2「JSON出力スキーマ」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
