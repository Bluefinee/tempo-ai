# Phase 10: Backend調整設計書

**フェーズ**: 10 / 15  
**Part**: C（新仕様への調整）  
**前提フェーズ**: Phase 7（Claude API統合）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書（新仕様）
- **[AI Prompt Spec v4.0](../ai-prompts/spec.md)** - AIプロンプト仕様書
- **[Metrics Spec v3.0](../metrics-spec.md)** - メトリクス仕様書

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

Phase 7で実装した旧仕様のClaude API統合を、新仕様に準拠するよう調整します。

**削除する機能**:
1. 追加アドバイス生成（Claude Haiku使用）
2. 今週のトライ生成ロジック

**追加する機能**:
1. `condition_insight`フィールド（AIの見立て）
2. リクエストデータの拡張（rhythm_stability, factors, scores）

---

## 完了条件

- [ ] 追加アドバイス生成ロジックが削除されている
- [ ] 今週のトライ生成ロジックが削除されている
- [ ] Claude Haikuの呼び出しコードが削除されている
- [ ] `condition_insight`フィールドが追加されている
- [ ] システムプロンプトがAI Prompt Spec v4.0に準拠している
- [ ] リクエストデータに`rhythm_stability`、`factors`、`scores`が含まれている
- [ ] 型定義が新仕様に一致している

---

## 変更前後の比較

### 旧仕様（Phase 7完了時点）

```typescript
// 旧: 生成するコンテンツ
interface DailyAdvice {
  greeting: string;
  condition: {
    summary: string;
    detail: string;
  };
  actionSuggestions: ActionSuggestion[];  // 削除
  dailyTry: DailyTry;
  weeklyTry: WeeklyTry | null;            // 削除
  closingMessage: string;
}

// 旧: 追加アドバイス（別途生成）
interface AdditionalAdvice {              // 削除
  timeSlot: "afternoon" | "evening";
  message: string;
}
```

### 新仕様（Phase 10完了後）

```typescript
// 新: 生成するコンテンツ
interface DailyAdvice {
  greeting: string;
  condition: {
    summary: string;    // 3-4文（ホーム画面用）
    detail: string;     // 8-12文（ホーム詳細画面用）
  };
  conditionInsight: string;  // 3-5文（コンディション画面用）← 追加
  dailyTry: DailyTry;
  closingMessage: string;
}
```

---

## 削除対象の詳細

### 1. 追加アドバイス生成の削除

**削除対象ファイル/コード**:

```
backend/src/
├── services/
│   └── claude.ts           # generateAdditionalAdvice() 削除
├── prompts/
│   └── additionalAdvice.ts # ファイル削除
├── routes/
│   └── advice.ts           # 追加アドバイスエンドポイント削除
└── types/
    └── index.ts            # AdditionalAdvice型 削除
```

**削除するコード例**:
```typescript
// 削除: services/claude.ts
export const generateAdditionalAdvice = async (
  params: AdditionalAdviceParams
): Promise<AdditionalAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  const response = await client.messages.create({
    model: "claude-haiku-4-5-20251001",  // Haiku削除
    max_tokens: 1024,
    // ...
  });

  return parseAdditionalAdviceResponse(response);
};
```

### 2. 今週のトライ生成の削除

**削除するコード**:
```typescript
// 削除: プロンプト内の今週のトライ関連指示
const systemPrompt = `
...
// 以下を削除
<weekly_try>
月曜日の場合のみ、今週のトライを生成してください。
- title: 20文字以内
- summary: 1文
- detail: 3-5文
- category: bodycare/mental/nutrition/exercise/sleep/mindfulness
</weekly_try>
...
`;

// 削除: 月曜判定ロジック
const isMonday = new Date().getDay() === 1;
if (isMonday) {
  // 今週のトライ生成
}
```

### 3. actionSuggestions削除

**削除するコード**:
```typescript
// 削除: 型定義
interface ActionSuggestion {
  icon: string;
  title: string;
  detail: string;
}

// 削除: プロンプト指示
<action_suggestions>
3つの具体的な行動提案を生成してください。
</action_suggestions>
```

---

## 追加する機能

### 1. condition_insightフィールド

**型定義の追加**:
```typescript
// types/index.ts
export interface DailyAdvice {
  greeting: string;
  condition: {
    summary: string;
    detail: string;
  };
  conditionInsight: string;  // 追加
  dailyTry: DailyTry;
  closingMessage: string;
  generatedAt: string;
}
```

**プロンプトへの追加**:
```typescript
// prompts/system.ts
export const buildSystemPrompt = (): string => `
<role>
プロフェッショナルなヘルスケアアドバイザー。
HealthKit・気象・環境データを活用し、精密栄養学的アプローチでパーソナライズされた提案を行う。
</role>

<character>
年上の落ち着いた優しいお姉さん。
- 温かく励ましつつ根拠を示す
- ニックネームで「〇〇さん」と呼びかける
- 押し付けず、提案する
</character>

<output_format>
以下のJSON形式で出力してください：

{
  "greeting": "〇〇さん、おはようございます",
  "condition": {
    "summary": "3-4文（ホーム画面用）",
    "detail": "8-12文（ホーム詳細画面用、改行\\nで段落分け）"
  },
  "condition_insight": "3-5文（コンディション画面用、要因の統合解釈）",
  "closing_message": "1-2文",
  "daily_try": {
    "title": "15文字以内",
    "summary": "1文（ホーム画面用）",
    "detail": "5-7文（なぜ今日これなのか含む）"
  }
}
</output_format>

<condition_insight_guidelines>
condition_insightは、コンディション画面に表示される「今日の見立て」です。
以下の要素を含めてください：

1. HRVの状態: 「自律神経の回復は良好です」など
2. リズム安定度の影響: 「3日連続でリズムが安定していることで〜」
3. 主要な要因の説明: 睡眠・環境・活動のうち、最も影響が大きいもの
4. 今日の過ごし方の示唆: 「午後は気圧が下がるので〜」など

conditionとの違い:
- condition.summary: 今日の体調を伝える（状態の説明）
- condition.detail: 今日の過ごし方を提案（行動提案）
- condition_insight: なぜその状態なのかを説明（因果関係の説明）
</condition_insight_guidelines>

<constraints>
- 医学的診断・処方は行わない
- 絵文字不使用
- 「！」は控えめに（2-3個まで）
</constraints>
`;
```

### 2. リクエストデータの拡張

**新しいリクエスト型**:
```typescript
// types/index.ts
export interface AdviceRequest {
  profile: UserProfile;
  healthData: HealthData;
  location: {
    latitude: number;
    longitude: number;
    city: string;
  };
  // 追加フィールド
  scores: MetricScores;
  rhythmStability: RhythmStability;
  factors: Factors;
}

export interface MetricScores {
  sleep: number;      // 0-100
  hrv: number;        // 0-100
  rhythm: number;     // 0-100
  activity: number;   // 0-100
}

export interface RhythmStability {
  status: "良好" | "やや不安定" | "不安定";
  consecutiveStableDays: number;
  description: string;
}

export interface Factors {
  sleep: {
    contribution: ContributionLevel;
    detail: string;
  };
  environment: {
    contribution: ContributionLevel;
    detail: string;
    pressureChange6h?: number;
  };
  activity: {
    contribution: ContributionLevel;
    detail: string;
  };
}

export type ContributionLevel = 
  | "highPositive" 
  | "positive" 
  | "neutral" 
  | "negative" 
  | "highNegative";
```

### 3. ユーザーデータプロンプトの更新

```typescript
// utils/prompt.ts
export const buildUserDataPrompt = (params: {
  userProfile: UserProfile;
  healthData: HealthData;
  weatherData?: WeatherData;
  airQualityData?: AirQualityData;
  scores: MetricScores;
  rhythmStability: RhythmStability;
  factors: Factors;
  context: RequestContext;
}): string => {
  return `
<user_data>
  <profile>
    <nickname>${params.userProfile.nickname}</nickname>
    <age>${params.userProfile.age}</age>
    <gender>${formatGender(params.userProfile.gender)}</gender>
    <occupation>${formatOccupation(params.userProfile.occupation)}</occupation>
    <exercise_frequency>${formatExercise(params.userProfile.exerciseFrequency)}</exercise_frequency>
    <interests>
      ${params.userProfile.interests.map((interest, i) => 
        `<interest priority="${i + 1}">${interest}</interest>`
      ).join("\n      ")}
    </interests>
  </profile>

  <health date="${params.healthData.date}" day_of_week="${params.context.dayOfWeek}">
    <sleep>
      <bedtime>${params.healthData.sleep?.bedtime ?? "不明"}</bedtime>
      <wake_time>${params.healthData.sleep?.wakeTime ?? "不明"}</wake_time>
      <duration_hours>${params.healthData.sleep?.durationHours ?? "不明"}</duration_hours>
      <deep_sleep_minutes>${params.healthData.sleep?.deepSleepMinutes ?? "不明"}</deep_sleep_minutes>
      <rem_sleep_minutes>${params.healthData.sleep?.remSleepMinutes ?? "不明"}</rem_sleep_minutes>
      <awakenings>${params.healthData.sleep?.awakenings ?? "不明"}</awakenings>
    </sleep>
    <vitals>
      <resting_hr>${params.healthData.morningVitals?.restingHeartRate ?? "不明"}</resting_hr>
      <hrv_ms>${params.healthData.morningVitals?.hrvMs ?? "不明"}</hrv_ms>
    </vitals>
    <activity>
      <steps_yesterday>${params.healthData.yesterdayActivity?.steps ?? "不明"}</steps_yesterday>
      <active_minutes_yesterday>${params.healthData.yesterdayActivity?.activeMinutes ?? "不明"}</active_minutes_yesterday>
    </activity>
    <trends_7d>
      <avg_sleep_hours>${params.healthData.weekTrends?.avgSleepHours ?? "不明"}</avg_sleep_hours>
      <avg_hrv>${params.healthData.weekTrends?.avgHrv ?? "不明"}</avg_hrv>
      <avg_steps>${params.healthData.weekTrends?.avgSteps ?? "不明"}</avg_steps>
    </trends_7d>
    <scores>
      <sleep>${params.scores.sleep}</sleep>
      <hrv>${params.scores.hrv}</hrv>
      <rhythm>${params.scores.rhythm}</rhythm>
      <activity>${params.scores.activity}</activity>
    </scores>
    <rhythm_stability>
      <status>${params.rhythmStability.status}</status>
      <consecutive_stable_days>${params.rhythmStability.consecutiveStableDays}</consecutive_stable_days>
      <description>${params.rhythmStability.description}</description>
    </rhythm_stability>
    <factors>
      <sleep contribution="${params.factors.sleep.contribution}">
        <detail>${params.factors.sleep.detail}</detail>
      </sleep>
      <environment contribution="${params.factors.environment.contribution}">
        <detail>${params.factors.environment.detail}</detail>
        ${params.factors.environment.pressureChange6h !== undefined 
          ? `<pressure_change_6h>${params.factors.environment.pressureChange6h}</pressure_change_6h>` 
          : ""}
      </environment>
      <activity contribution="${params.factors.activity.contribution}">
        <detail>${params.factors.activity.detail}</detail>
      </activity>
    </factors>
  </health>

  <environment>
    ${params.weatherData ? `
    <weather condition="${params.weatherData.condition}" temp_c="${params.weatherData.tempCurrentC}" humidity="${params.weatherData.humidityPercent}" pressure_hpa="${params.weatherData.pressureHpa}" uv_index="${params.weatherData.uvIndex}" />
    ` : "<weather>取得できませんでした</weather>"}
    
    ${params.airQualityData ? `
    <air_quality aqi="${params.airQualityData.aqi}" pm25="${params.airQualityData.pm25}" />
    ` : "<air_quality>取得できませんでした</air_quality>"}
    
    <location>${params.weatherData?.city ?? "不明"}</location>
  </environment>

  <history>
    <recent_daily_tries>
      ${params.context.recentDailyTries.map((t, i) => 
        `<try date="${t.date}">${t.title}</try>`
      ).join("\n      ")}
    </recent_daily_tries>
  </history>
</user_data>

上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。
`;
};
```

---

## Claude API呼び出しの修正

### 修正後のgenerateMainAdvice

```typescript
// services/claude.ts
import Anthropic from "@anthropic-ai/sdk";

export const generateMainAdvice = async (
  params: GenerateAdviceParams
): Promise<DailyAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  const systemPrompt = buildSystemPrompt();
  const examples = getExamplesForInterest(params.userProfile.interests[0]);
  const userData = buildUserDataPrompt({
    userProfile: params.userProfile,
    healthData: params.healthData,
    weatherData: params.weatherData,
    airQualityData: params.airQualityData,
    scores: params.scores,
    rhythmStability: params.rhythmStability,
    factors: params.factors,
    context: params.context,
  });

  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2000,
    system: [
      {
        type: "text",
        text: systemPrompt,
        cache_control: { type: "ephemeral" },
      },
      {
        type: "text",
        text: examples,
        cache_control: { type: "ephemeral" },
      },
    ],
    messages: [
      {
        role: "user",
        content: userData,
      },
    ],
  });

  return parseAdviceResponse(response);
};

// 削除: generateAdditionalAdvice関数は完全に削除
```

---

## JSONパースの修正

```typescript
// utils/parse.ts
const parseAdviceResponse = (response: Anthropic.Message): DailyAdvice => {
  const textContent = response.content.find((c) => c.type === "text");
  if (!textContent || textContent.type !== "text") {
    throw new Error("No text content in response");
  }

  let jsonString = textContent.text;
  const jsonMatch = jsonString.match(/```json\s*([\s\S]*?)\s*```/);
  if (jsonMatch) {
    jsonString = jsonMatch[1];
  }

  const parsed = JSON.parse(jsonString);
  
  // 新仕様に対応したバリデーション
  validateDailyAdvice(parsed);
  
  // スネークケース → キャメルケース変換
  return {
    greeting: parsed.greeting,
    condition: {
      summary: parsed.condition.summary,
      detail: parsed.condition.detail,
    },
    conditionInsight: parsed.condition_insight,  // 追加
    dailyTry: {
      title: parsed.daily_try.title,
      summary: parsed.daily_try.summary,
      detail: parsed.daily_try.detail,
    },
    closingMessage: parsed.closing_message,
    generatedAt: new Date().toISOString(),
  };
};

const validateDailyAdvice = (data: unknown): void => {
  if (typeof data !== "object" || data === null) {
    throw new Error("Invalid response: not an object");
  }

  const advice = data as Record<string, unknown>;

  // 必須フィールドの確認
  const requiredFields = [
    "greeting",
    "condition",
    "condition_insight",  // 追加
    "daily_try",
    "closing_message",
  ];

  for (const field of requiredFields) {
    if (!(field in advice)) {
      throw new Error(`Invalid response: missing ${field}`);
    }
  }

  // condition構造の確認
  const condition = advice.condition as Record<string, unknown>;
  if (!condition.summary || !condition.detail) {
    throw new Error("Invalid response: condition missing summary or detail");
  }

  // daily_try構造の確認
  const dailyTry = advice.daily_try as Record<string, unknown>;
  if (!dailyTry.title || !dailyTry.summary || !dailyTry.detail) {
    throw new Error("Invalid response: daily_try missing required fields");
  }
};
```

---

## エンドポイントの修正

### POST /api/advice

```typescript
// routes/advice.ts
import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { generateMainAdvice } from "../services/claude";
import { getWeatherData } from "../services/weather";
import { getAirQualityData } from "../services/airQuality";

const app = new Hono();

const adviceRequestSchema = z.object({
  profile: z.object({
    nickname: z.string(),
    age: z.number(),
    gender: z.enum(["male", "female", "other", "prefer_not_to_say"]),
    occupation: z.string().optional(),
    exerciseFrequency: z.string().optional(),
    interests: z.array(z.string()),
  }),
  healthData: z.object({
    date: z.string(),
    sleep: z.object({
      bedtime: z.string().optional(),
      wakeTime: z.string().optional(),
      durationHours: z.number().optional(),
      deepSleepMinutes: z.number().optional(),
      remSleepMinutes: z.number().optional(),
      awakenings: z.number().optional(),
    }).optional(),
    morningVitals: z.object({
      restingHeartRate: z.number().optional(),
      hrvMs: z.number().optional(),
    }).optional(),
    yesterdayActivity: z.object({
      steps: z.number().optional(),
      activeMinutes: z.number().optional(),
    }).optional(),
    weekTrends: z.object({
      avgSleepHours: z.number().optional(),
      avgHrv: z.number().optional(),
      avgSteps: z.number().optional(),
    }).optional(),
  }),
  location: z.object({
    latitude: z.number(),
    longitude: z.number(),
    city: z.string(),
  }),
  // 新規追加フィールド
  scores: z.object({
    sleep: z.number(),
    hrv: z.number(),
    rhythm: z.number(),
    activity: z.number(),
  }),
  rhythmStability: z.object({
    status: z.enum(["良好", "やや不安定", "不安定"]),
    consecutiveStableDays: z.number(),
    description: z.string(),
  }),
  factors: z.object({
    sleep: z.object({
      contribution: z.enum(["highPositive", "positive", "neutral", "negative", "highNegative"]),
      detail: z.string(),
    }),
    environment: z.object({
      contribution: z.enum(["highPositive", "positive", "neutral", "negative", "highNegative"]),
      detail: z.string(),
      pressureChange6h: z.number().optional(),
    }),
    activity: z.object({
      contribution: z.enum(["highPositive", "positive", "neutral", "negative", "highNegative"]),
      detail: z.string(),
    }),
  }),
  recentDailyTries: z.array(z.object({
    date: z.string(),
    title: z.string(),
  })),
});

app.post(
  "/",
  zValidator("json", adviceRequestSchema),
  async (c) => {
    const body = c.req.valid("json");
    const env = c.env as { ANTHROPIC_API_KEY: string };

    try {
      // 環境データ取得
      const [weatherData, airQualityData] = await Promise.all([
        getWeatherData(body.location.latitude, body.location.longitude),
        getAirQualityData(body.location.latitude, body.location.longitude),
      ]);

      // アドバイス生成（Sonnetのみ使用）
      const advice = await generateMainAdvice({
        apiKey: env.ANTHROPIC_API_KEY,
        userProfile: body.profile,
        healthData: body.healthData,
        weatherData,
        airQualityData,
        scores: body.scores,
        rhythmStability: body.rhythmStability,
        factors: body.factors,
        context: {
          currentTime: new Date().toISOString(),
          dayOfWeek: getDayOfWeekJa(new Date()),
          recentDailyTries: body.recentDailyTries,
        },
      });

      return c.json({
        advice,
        generatedAt: new Date().toISOString(),
      });
    } catch (error) {
      console.error("Advice generation failed:", error);
      return c.json(
        { error: "Failed to generate advice" },
        500
      );
    }
  }
);

// 削除: 追加アドバイスエンドポイント
// app.post("/additional", ...) は削除

export default app;
```

---

## ディレクトリ構造の変更

### 削除対象

```
backend/src/
├── prompts/
│   └── additionalAdvice.ts  # 削除
├── services/
│   └── claude.ts            # generateAdditionalAdvice() 削除
└── types/
    └── index.ts             # AdditionalAdvice, WeeklyTry 型削除
```

### 修正後の構造

```
backend/src/
├── index.ts
├── routes/
│   ├── advice.ts           # 修正（追加アドバイス削除）
│   └── environment.ts
├── services/
│   ├── claude.ts           # 修正（generateMainAdvice のみ）
│   ├── weather.ts
│   └── airQuality.ts
├── prompts/
│   ├── system.ts           # 修正（condition_insight追加）
│   └── examples/
│       ├── fitness.ts
│       ├── beauty.ts
│       ├── mental.ts
│       ├── energy.ts
│       ├── nutrition.ts
│       └── sleep.ts
├── utils/
│   ├── prompt.ts           # 修正（新データ形式対応）
│   └── parse.ts            # 修正（新レスポンス形式対応）
└── types/
    └── index.ts            # 修正（新型定義）
```

---

## コスト削減効果

### 旧仕様

| 項目 | モデル | 頻度 | コスト/回 |
|------|--------|------|-----------|
| メインアドバイス | Sonnet | 1回/日 | ~$0.024 |
| 追加アドバイス（昼） | Haiku | 1回/日 | ~$0.002 |
| 追加アドバイス（夕） | Haiku | 1回/日 | ~$0.002 |
| **合計** | | | **~$0.028/日** |

### 新仕様

| 項目 | モデル | 頻度 | コスト/回 |
|------|--------|------|-----------|
| メインアドバイス + condition_insight | Sonnet | 1回/日 | ~$0.026 |
| **合計** | | | **~$0.026/日** |

**削減率**: 約7%削減（Haiku呼び出し2回分が不要に）

---

## フォールバックアドバイスの修正

```typescript
// utils/fallback.ts
export const getFallbackAdvice = (nickname: string): DailyAdvice => ({
  greeting: `${nickname}さん、おはようございます`,
  condition: {
    summary: "今日も一日、あなたのペースで過ごしていきましょう。",
    detail: "本日のアドバイスを生成できませんでした。ヘルスケアデータと環境情報を確認して、また後でお試しください。",
  },
  conditionInsight: "データの取得に問題が発生したため、詳細な見立てを提供できませんでした。しばらくしてから再度お試しください。",
  dailyTry: {
    title: "深呼吸を3回",
    summary: "ゆっくりと深呼吸をして、心を落ち着けてみませんか？",
    detail: "4秒かけて鼻から息を吸い、7秒間息を止め、8秒かけて口から吐き出します。この呼吸法は、自律神経を整える効果があると言われています。",
  },
  closingMessage: "今日も良い一日をお過ごしください。",
  generatedAt: new Date().toISOString(),
});
```

---

## テスト観点

### 正常系

- [ ] メインアドバイスが正しく生成される
- [ ] `condition_insight`が含まれている
- [ ] 新しいリクエストフィールド（scores, rhythmStability, factors）が正しく処理される
- [ ] JSONパースが成功する

### 異常系

- [ ] Claude APIエラー時にフォールバックが返る
- [ ] 不正なリクエストで400エラーが返る
- [ ] タイムアウト時にフォールバックが返る

### 削除確認

- [ ] `/api/advice/additional`エンドポイントが404を返す
- [ ] 今週のトライが生成されない
- [ ] Claude Haikuが呼び出されていない

---

## 今後のフェーズとの関係

### Phase 12（コンディショントップ）

- `condition_insight`をコンディション画面で表示
- iOS側で`conditionInsight`を受け取って表示

### Phase 14（UI結合）

- 新しいAPIレスポンス形式に合わせてiOS側を修正

---

## 関連ドキュメント

- `ai-prompts/spec.md` - AIプロンプト仕様書 v4.0
- `product-spec.md` - セクション7「アドバイス生成ロジック」
- `metrics-spec.md` - セクション9「要因の貢献度算出」
- `09-phase-claude-api.md` - Phase 7詳細設計書（旧仕様）

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
