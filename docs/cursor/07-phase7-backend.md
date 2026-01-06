# Phase 7: バックエンド更新

## 目的

- AIアドバイスAPIの新形式対応
- リクエスト/レスポンス型の更新
- プロンプト構築の更新
- テストの更新

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | TypeScript規約、エラーハンドリング |
| TypeScript+Hono規約 | `/.claude/typescript-hono-standards.md` | Hono実装パターン、テスト規約 |
| 技術仕様 | `/docs/specs/technical_spec.md` | API設計、リクエスト/レスポンス形式 |
| AIプロンプト仕様 | `/docs/specs/ai_prompt_spec.md` | システムプロンプト、出力形式 |
| メトリクス仕様 | `/docs/specs/metrics_spec.md` | Tempo Score算出ロジック |

---

## Task 7.1: 型定義更新

### `backend/src/services/advice/types.ts`

```typescript
/**
 * AIアドバイスAPI型定義
 * @see docs/specs/technical_spec.md
 * @see docs/specs/ai_prompt_spec.md
 */

// ユーザープロフィール
export interface UserProfile {
  goals: UserGoal[];
  wakeUpTime: string;      // "07:00"
  windDownTime: string;    // "23:00"
}

export type UserGoal = 'better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance';

// 睡眠データ
export interface SleepData {
  durationMinutes: number;
  deepSleepMinutes: number;
  remSleepMinutes: number;
  bedtime?: string;
  wakeTime?: string;
}

// HRVデータ
export interface HrvData {
  value: number;
  baseline30d: number;
}

// 活動データ
export interface ActivityData {
  steps: number;
}

// ヘルスメトリクス
export interface HealthMetrics {
  sleep: SleepData;
  hrv: HrvData;
  activity: ActivityData;
}

// 天気データ
export interface WeatherData {
  temperature: number;
  pressure: number;
  pressureTrend: PressureTrend;
  sunrise: string;
  sunset: string;
  description?: string;
  location?: string;
}

export type PressureTrend = 'rising' | 'stable' | 'falling';

// APIリクエスト
export interface AdviceRequest {
  user: UserProfile;
  healthMetrics: HealthMetrics;
  weather: WeatherData;
  tempoScore?: number;
  locale?: string;
}

// AIメッセージ
export interface AiMessage {
  title: string;
  body: string;
}

// Today's One Thing
export interface TodayOneThing {
  icon: OneThingIcon;
  text: string;
  time?: string;
}

export type OneThingIcon = 'walking' | 'breathing' | 'rest' | 'coffee' | 'sun';

// Related Insight
export interface RelatedInsight {
  text: string;
  insightId: string;
}

// メトリクス別インサイト
export interface MetricInsights {
  sleep: string;
  hrv: string;
  steps: string;
}

// APIレスポンス
export interface AdviceResponse {
  tempoScore: number;
  message: AiMessage;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
  metricInsights: MetricInsights;
}

// Claude API出力形式
export interface ClaudeAdviceOutput {
  message: AiMessage;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
  metricInsights: MetricInsights;
}

// バリデーション
export const isValidAdviceRequest = (data: unknown): data is AdviceRequest => {
  if (typeof data !== 'object' || data === null) return false;

  const req = data as Record<string, unknown>;

  // user validation
  if (typeof req.user !== 'object' || req.user === null) return false;
  const user = req.user as Record<string, unknown>;
  if (!Array.isArray(user.goals)) return false;
  if (typeof user.wakeUpTime !== 'string') return false;
  if (typeof user.windDownTime !== 'string') return false;

  // healthMetrics validation
  if (typeof req.healthMetrics !== 'object' || req.healthMetrics === null) return false;
  const metrics = req.healthMetrics as Record<string, unknown>;

  // sleep validation
  if (typeof metrics.sleep !== 'object' || metrics.sleep === null) return false;
  const sleep = metrics.sleep as Record<string, unknown>;
  if (typeof sleep.durationMinutes !== 'number') return false;
  if (typeof sleep.deepSleepMinutes !== 'number') return false;
  if (typeof sleep.remSleepMinutes !== 'number') return false;

  // hrv validation
  if (typeof metrics.hrv !== 'object' || metrics.hrv === null) return false;
  const hrv = metrics.hrv as Record<string, unknown>;
  if (typeof hrv.value !== 'number') return false;
  if (typeof hrv.baseline30d !== 'number') return false;

  // activity validation
  if (typeof metrics.activity !== 'object' || metrics.activity === null) return false;
  const activity = metrics.activity as Record<string, unknown>;
  if (typeof activity.steps !== 'number') return false;

  // weather validation
  if (typeof req.weather !== 'object' || req.weather === null) return false;
  const weather = req.weather as Record<string, unknown>;
  if (typeof weather.temperature !== 'number') return false;
  if (typeof weather.pressure !== 'number') return false;
  if (!['rising', 'stable', 'falling'].includes(weather.pressureTrend as string)) return false;
  if (typeof weather.sunrise !== 'string') return false;
  if (typeof weather.sunset !== 'string') return false;

  return true;
};

// フォールバックレスポンス
export const createFallbackResponse = (tempoScore: number): AdviceResponse => ({
  tempoScore,
  message: {
    title: 'New Day',
    body: 'データの取得に時間がかかっています。少し後でもう一度お試しください。',
  },
  todayOneThing: {
    icon: 'breathing',
    text: '深呼吸で1日をスタートしましょう',
  },
  relatedInsight: {
    text: '',
    insightId: '',
  },
  metricInsights: {
    sleep: '',
    hrv: '',
    steps: '',
  },
});
```

---

## Task 7.2: PromptBuilder更新

### `backend/src/services/advice/PromptBuilder.ts`

```typescript
import type { AdviceRequest, HealthMetrics, UserProfile, WeatherData } from './types';

/**
 * システムプロンプト
 * @see docs/specs/ai_prompt_spec.md
 */
const SYSTEM_PROMPT = `<role>
あなたは「Tempo」という名前のAIヘルスケアアドバイザーです。
サーカディアンリズム（体内時計）と自律神経の専門知識を持ち、
ユーザーの身体データと環境データを分析して、
今日1日を最適に過ごすためのパーソナライズされた提案を行います。
</role>

<character>
- 温かみがありながらも、専門家としての信頼感がある
- 押し付けず、提案する（「〜してみてください」「〜するといいかもしれません」）
- 科学的根拠を示しながらも、難しい言葉は使わない
- ポジティブな面を先に伝え、改善点は建設的に提案
- 詩的で穏やかな表現を好む
</character>

<output_format>
以下のJSON形式で出力してください。JSONのみを出力し、それ以外のテキストは含めないでください。

{
  "message": {
    "title": "詩的なタイトル（2-4語、英語）",
    "body": "温かいコンディション説明（3-4文、日本語、100-150文字）"
  },
  "todayOneThing": {
    "icon": "walking | breathing | rest | coffee | sun",
    "text": "具体的なアクション提案（日本語、50文字以内）",
    "time": "推奨時間（HH:MM形式、任意）"
  },
  "relatedInsight": {
    "text": "データに基づく発見（日本語、30文字以内）",
    "insightId": "一意の識別子"
  },
  "metricInsights": {
    "sleep": "睡眠の詳細分析（日本語、2-3文）",
    "hrv": "HRVの詳細分析（日本語、2-3文）",
    "steps": "活動量の詳細分析（日本語、2-3文）"
  }
}
</output_format>

<scientific_knowledge>
サーカディアンリズムの原則:
- 脳の視交叉上核（SCN）が体内時計の司令塔
- 朝の光（特に青色光）がSCNをリセットし、14〜16時間後のメラトニン分泌をセット
- 就寝・起床時刻の一貫性がリズム安定の鍵

自律神経の原則:
- HRV（心拍変動）は自律神経バランスの客観的指標
- HRVが高い = 副交感神経優位 = リラックス・回復状態
- HRVが低い = 交感神経優位 = 緊張・ストレス状態

データの解釈:
- 深い睡眠は全体の15-25%が理想
- 気圧の急低下は頭痛・倦怠感のリスク要因
</scientific_knowledge>

<personalization_rules>
ユーザーの目標に応じてアドバイスをパーソナライズしてください。

目標別:
- better_sleep → 睡眠改善に関連するインサイト・アドバイスを優先
- more_energy → 日中の活動、Peak Focus活用を優先
- less_stress → 呼吸法、リラックス提案を優先
- peak_performance → 最適タイミング、集中力向上を優先
</personalization_rules>

<constraints>
- 医学的診断や処方は行わない
- 絵文字は使用しない
- データがない項目については言及しない
- 不確実な推測は「〜かもしれません」と表現
</constraints>`;

/**
 * PromptBuilder クラス
 */
export class PromptBuilder {
  /**
   * システムプロンプトを取得
   */
  getSystemPrompt(): string {
    return SYSTEM_PROMPT;
  }

  /**
   * ユーザーデータXMLを構築
   */
  buildUserDataXml(request: AdviceRequest): string {
    const { user, healthMetrics, weather, tempoScore } = request;
    const now = new Date();
    const dayOfWeek = this.getDayOfWeekJapanese(now.getDay());
    const dateStr = this.formatDate(now);
    const currentTime = this.formatTime(now);

    return `<user_data>
  <profile>
    <goals>${user.goals.join(', ')}</goals>
    <wake_up_time>${user.wakeUpTime}</wake_up_time>
    <wind_down_time>${user.windDownTime}</wind_down_time>
  </profile>

  <health date="${dateStr}" day_of_week="${dayOfWeek}">
    ${this.buildSleepXml(healthMetrics.sleep)}
    ${this.buildHrvXml(healthMetrics.hrv)}
    ${this.buildActivityXml(healthMetrics.activity)}
    ${tempoScore !== undefined ? `<tempo_score>${tempoScore}</tempo_score>` : ''}
  </health>

  <environment>
    ${weather.location ? `<location>${weather.location}</location>` : ''}
    ${weather.description ? `<weather>${weather.description}</weather>` : ''}
    <temperature_celsius>${weather.temperature}</temperature_celsius>
    <pressure_hpa>${weather.pressure}</pressure_hpa>
    <pressure_trend>${weather.pressureTrend}</pressure_trend>
    <sunrise>${weather.sunrise}</sunrise>
    <sunset>${weather.sunset}</sunset>
  </environment>

  <context>
    <current_time>${currentTime}</current_time>
  </context>
</user_data>`;
  }

  private buildSleepXml(sleep: HealthMetrics['sleep']): string {
    const deepSleepRatio = sleep.durationMinutes > 0
      ? (sleep.deepSleepMinutes / sleep.durationMinutes).toFixed(2)
      : '0.00';

    return `<sleep>
      ${sleep.bedtime ? `<bedtime>${sleep.bedtime}</bedtime>` : ''}
      ${sleep.wakeTime ? `<wake_time>${sleep.wakeTime}</wake_time>` : ''}
      <duration_minutes>${sleep.durationMinutes}</duration_minutes>
      <deep_sleep_minutes>${sleep.deepSleepMinutes}</deep_sleep_minutes>
      <deep_sleep_ratio>${deepSleepRatio}</deep_sleep_ratio>
      <rem_sleep_minutes>${sleep.remSleepMinutes}</rem_sleep_minutes>
    </sleep>`;
  }

  private buildHrvXml(hrv: HealthMetrics['hrv']): string {
    const deviation = hrv.baseline30d > 0
      ? (((hrv.value - hrv.baseline30d) / hrv.baseline30d) * 100).toFixed(1)
      : '0.0';
    const sign = Number(deviation) >= 0 ? '+' : '';

    return `<hrv>
      <value_ms>${hrv.value}</value_ms>
      <baseline_30d_ms>${hrv.baseline30d}</baseline_30d_ms>
      <deviation_percent>${sign}${deviation}</deviation_percent>
    </hrv>`;
  }

  private buildActivityXml(activity: HealthMetrics['activity']): string {
    return `<activity>
      <steps_yesterday>${activity.steps}</steps_yesterday>
    </activity>`;
  }

  private getDayOfWeekJapanese(day: number): string {
    const days = ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'];
    return days[day] ?? '';
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private formatTime(date: Date): string {
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}
```

---

## Task 7.3: AnthropicClient更新

### `backend/src/services/advice/AnthropicClient.ts`

```typescript
import Anthropic from '@anthropic-ai/sdk';
import type { ClaudeAdviceOutput } from './types';

const MODEL = 'claude-sonnet-4-20250514';
const MAX_TOKENS = 2000;
const TIMEOUT_MS = 30000;

interface AnthropicClientConfig {
  apiKey: string;
}

/**
 * Anthropic Claude APIクライアント
 */
export class AnthropicClient {
  private client: Anthropic;

  constructor(config: AnthropicClientConfig) {
    this.client = new Anthropic({
      apiKey: config.apiKey,
    });
  }

  /**
   * AIアドバイスを生成
   */
  async generateAdvice(
    systemPrompt: string,
    userDataXml: string
  ): Promise<ClaudeAdviceOutput> {
    const response = await this.client.messages.create({
      model: MODEL,
      max_tokens: MAX_TOKENS,
      system: [
        {
          type: 'text',
          text: systemPrompt,
          cache_control: { type: 'ephemeral' },
        },
      ],
      messages: [
        {
          role: 'user',
          content: userDataXml,
        },
      ],
    });

    const textContent = response.content.find((block) => block.type === 'text');
    if (!textContent || textContent.type !== 'text') {
      throw new Error('No text content in response');
    }

    const output = this.parseJsonResponse(textContent.text);
    return output;
  }

  /**
   * JSONレスポンスをパース
   */
  private parseJsonResponse(text: string): ClaudeAdviceOutput {
    // JSONブロックを抽出（```json ... ``` または 直接JSON）
    let jsonString = text.trim();

    // コードブロック内のJSONを抽出
    const jsonBlockMatch = jsonString.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (jsonBlockMatch) {
      jsonString = jsonBlockMatch[1]?.trim() ?? '';
    }

    // JSON以外のテキストを除去
    const jsonStartIndex = jsonString.indexOf('{');
    const jsonEndIndex = jsonString.lastIndexOf('}');
    if (jsonStartIndex !== -1 && jsonEndIndex !== -1) {
      jsonString = jsonString.slice(jsonStartIndex, jsonEndIndex + 1);
    }

    try {
      const parsed = JSON.parse(jsonString) as ClaudeAdviceOutput;
      return this.validateAndNormalizeOutput(parsed);
    } catch (error) {
      throw new Error(`Failed to parse JSON response: ${(error as Error).message}`);
    }
  }

  /**
   * 出力を検証・正規化
   */
  private validateAndNormalizeOutput(output: unknown): ClaudeAdviceOutput {
    const data = output as Record<string, unknown>;

    // message の検証
    if (typeof data.message !== 'object' || data.message === null) {
      throw new Error('Invalid message in response');
    }
    const message = data.message as Record<string, unknown>;
    if (typeof message.title !== 'string' || typeof message.body !== 'string') {
      throw new Error('Invalid message format');
    }

    // todayOneThing の検証
    if (typeof data.todayOneThing !== 'object' || data.todayOneThing === null) {
      throw new Error('Invalid todayOneThing in response');
    }
    const oneThing = data.todayOneThing as Record<string, unknown>;
    if (typeof oneThing.icon !== 'string' || typeof oneThing.text !== 'string') {
      throw new Error('Invalid todayOneThing format');
    }

    // relatedInsight の検証
    if (typeof data.relatedInsight !== 'object' || data.relatedInsight === null) {
      throw new Error('Invalid relatedInsight in response');
    }
    const insight = data.relatedInsight as Record<string, unknown>;
    if (typeof insight.text !== 'string' || typeof insight.insightId !== 'string') {
      throw new Error('Invalid relatedInsight format');
    }

    // metricInsights の検証
    if (typeof data.metricInsights !== 'object' || data.metricInsights === null) {
      throw new Error('Invalid metricInsights in response');
    }
    const metrics = data.metricInsights as Record<string, unknown>;
    if (
      typeof metrics.sleep !== 'string' ||
      typeof metrics.hrv !== 'string' ||
      typeof metrics.steps !== 'string'
    ) {
      throw new Error('Invalid metricInsights format');
    }

    return {
      message: {
        title: message.title as string,
        body: message.body as string,
      },
      todayOneThing: {
        icon: oneThing.icon as ClaudeAdviceOutput['todayOneThing']['icon'],
        text: oneThing.text as string,
        time: typeof oneThing.time === 'string' ? oneThing.time : undefined,
      },
      relatedInsight: {
        text: insight.text as string,
        insightId: insight.insightId as string,
      },
      metricInsights: {
        sleep: metrics.sleep as string,
        hrv: metrics.hrv as string,
        steps: metrics.steps as string,
      },
    };
  }
}
```

---

## Task 7.4: AdviceService更新

### `backend/src/services/advice/AdviceService.ts`

```typescript
import { AnthropicClient } from './AnthropicClient';
import { PromptBuilder } from './PromptBuilder';
import type { AdviceRequest, AdviceResponse } from './types';
import { createFallbackResponse, isValidAdviceRequest } from './types';

interface AdviceServiceConfig {
  anthropicApiKey: string;
}

/**
 * AIアドバイスサービス
 */
export class AdviceService {
  private anthropicClient: AnthropicClient;
  private promptBuilder: PromptBuilder;

  constructor(config: AdviceServiceConfig) {
    this.anthropicClient = new AnthropicClient({
      apiKey: config.anthropicApiKey,
    });
    this.promptBuilder = new PromptBuilder();
  }

  /**
   * AIアドバイスを生成
   */
  async generateAdvice(request: AdviceRequest): Promise<AdviceResponse> {
    // リクエストバリデーション
    if (!isValidAdviceRequest(request)) {
      throw new Error('Invalid advice request');
    }

    const tempoScore = request.tempoScore ?? this.calculateTempoScore(request);

    try {
      const systemPrompt = this.promptBuilder.getSystemPrompt();
      const userDataXml = this.promptBuilder.buildUserDataXml({
        ...request,
        tempoScore,
      });

      const claudeOutput = await this.anthropicClient.generateAdvice(
        systemPrompt,
        userDataXml
      );

      return {
        tempoScore,
        ...claudeOutput,
      };
    } catch (error) {
      console.error('Failed to generate advice:', error);
      return createFallbackResponse(tempoScore);
    }
  }

  /**
   * Tempo Scoreを算出（フロントエンドから送信されない場合のフォールバック）
   * @see docs/specs/metrics_spec.md
   */
  private calculateTempoScore(request: AdviceRequest): number {
    const { healthMetrics } = request;

    // HRV Score (40%)
    const hrvDeviation = healthMetrics.hrv.baseline30d > 0
      ? (healthMetrics.hrv.value - healthMetrics.hrv.baseline30d) / healthMetrics.hrv.baseline30d
      : 0;
    const hrvScore = Math.min(100, Math.max(0, 70 + hrvDeviation * 100));

    // Sleep Score (35%)
    const targetSleepMinutes = 480; // 8時間
    const sleepRatio = healthMetrics.sleep.durationMinutes / targetSleepMinutes;
    const deepSleepRatio = healthMetrics.sleep.durationMinutes > 0
      ? healthMetrics.sleep.deepSleepMinutes / healthMetrics.sleep.durationMinutes
      : 0;
    const sleepScore = Math.min(100, (sleepRatio * 70) + (deepSleepRatio * 150));

    // Activity Score (10%)
    const targetSteps = 8000;
    const activityScore = Math.min(100, (healthMetrics.activity.steps / targetSteps) * 100);

    // Rhythm Score (15%) - 簡易版
    const rhythmScore = 70; // 本来はCircadian Rhythm計算が必要

    // 加重平均
    const score = (hrvScore * 0.40) + (sleepScore * 0.35) + (rhythmScore * 0.15) + (activityScore * 0.10);

    return Math.round(score);
  }
}
```

---

## Task 7.5: ルート更新

### `backend/src/routes/advice.ts`

```typescript
import { Hono } from 'hono';
import type { Env } from '../types';
import { AdviceService } from '../services/advice/AdviceService';
import { isValidAdviceRequest } from '../services/advice/types';

const adviceRoutes = new Hono<{ Bindings: Env }>();

/**
 * POST /api/advice
 * AIアドバイス生成
 */
adviceRoutes.post('/', async (c) => {
  const apiKey = c.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    return c.json({ error: 'API key not configured' }, 500);
  }

  try {
    const body = await c.req.json();

    if (!isValidAdviceRequest(body)) {
      return c.json({ error: 'Invalid request body' }, 400);
    }

    const adviceService = new AdviceService({
      anthropicApiKey: apiKey,
    });

    const response = await adviceService.generateAdvice(body);
    return c.json(response);
  } catch (error) {
    console.error('Advice generation error:', error);
    return c.json({ error: 'Failed to generate advice' }, 500);
  }
});

export { adviceRoutes };
```

---

## Task 7.6: テスト更新

### `backend/src/services/advice/types.test.ts`

```typescript
import { describe, expect, it } from 'vitest';
import { createFallbackResponse, isValidAdviceRequest } from './types';

describe('types', () => {
  describe('isValidAdviceRequest', () => {
    const validRequest = {
      user: {
        goals: ['better_sleep', 'more_energy'],
        wakeUpTime: '07:00',
        windDownTime: '23:00',
      },
      healthMetrics: {
        sleep: {
          durationMinutes: 450,
          deepSleepMinutes: 105,
          remSleepMinutes: 95,
        },
        hrv: {
          value: 52,
          baseline30d: 48,
        },
        activity: {
          steps: 8200,
        },
      },
      weather: {
        temperature: 8,
        pressure: 1018,
        pressureTrend: 'falling' as const,
        sunrise: '06:50',
        sunset: '16:48',
      },
    };

    it('should return true for valid request', () => {
      expect(isValidAdviceRequest(validRequest)).toBe(true);
    });

    it('should return false for null', () => {
      expect(isValidAdviceRequest(null)).toBe(false);
    });

    it('should return false for missing user', () => {
      const { user, ...rest } = validRequest;
      expect(isValidAdviceRequest(rest)).toBe(false);
    });

    it('should return false for invalid pressureTrend', () => {
      const invalid = {
        ...validRequest,
        weather: { ...validRequest.weather, pressureTrend: 'invalid' },
      };
      expect(isValidAdviceRequest(invalid)).toBe(false);
    });
  });

  describe('createFallbackResponse', () => {
    it('should create a fallback response with given tempo score', () => {
      const response = createFallbackResponse(75);
      expect(response.tempoScore).toBe(75);
      expect(response.message.title).toBe('New Day');
      expect(response.todayOneThing.icon).toBe('breathing');
    });
  });
});
```

### `backend/src/services/advice/PromptBuilder.test.ts`

```typescript
import { describe, expect, it } from 'vitest';
import { PromptBuilder } from './PromptBuilder';
import type { AdviceRequest } from './types';

describe('PromptBuilder', () => {
  const builder = new PromptBuilder();

  const mockRequest: AdviceRequest = {
    user: {
      goals: ['better_sleep', 'more_energy'],
      wakeUpTime: '07:00',
      windDownTime: '23:00',
    },
    healthMetrics: {
      sleep: {
        durationMinutes: 450,
        deepSleepMinutes: 105,
        remSleepMinutes: 95,
        bedtime: '23:15',
        wakeTime: '06:45',
      },
      hrv: {
        value: 52,
        baseline30d: 48,
      },
      activity: {
        steps: 8200,
      },
    },
    weather: {
      temperature: 8,
      pressure: 1018,
      pressureTrend: 'falling',
      sunrise: '06:50',
      sunset: '16:48',
      location: 'Tokyo',
      description: '晴れ',
    },
    tempoScore: 78,
  };

  describe('getSystemPrompt', () => {
    it('should return system prompt with required sections', () => {
      const prompt = builder.getSystemPrompt();
      expect(prompt).toContain('<role>');
      expect(prompt).toContain('<character>');
      expect(prompt).toContain('<output_format>');
      expect(prompt).toContain('<scientific_knowledge>');
      expect(prompt).toContain('<personalization_rules>');
      expect(prompt).toContain('<constraints>');
    });
  });

  describe('buildUserDataXml', () => {
    it('should build valid XML with all data', () => {
      const xml = builder.buildUserDataXml(mockRequest);
      expect(xml).toContain('<user_data>');
      expect(xml).toContain('<goals>better_sleep, more_energy</goals>');
      expect(xml).toContain('<wake_up_time>07:00</wake_up_time>');
      expect(xml).toContain('<duration_minutes>450</duration_minutes>');
      expect(xml).toContain('<value_ms>52</value_ms>');
      expect(xml).toContain('<steps_yesterday>8200</steps_yesterday>');
      expect(xml).toContain('<tempo_score>78</tempo_score>');
      expect(xml).toContain('<location>Tokyo</location>');
    });

    it('should calculate HRV deviation correctly', () => {
      const xml = builder.buildUserDataXml(mockRequest);
      // (52 - 48) / 48 * 100 = 8.3%
      expect(xml).toContain('<deviation_percent>+8.3</deviation_percent>');
    });

    it('should calculate deep sleep ratio correctly', () => {
      const xml = builder.buildUserDataXml(mockRequest);
      // 105 / 450 = 0.23
      expect(xml).toContain('<deep_sleep_ratio>0.23</deep_sleep_ratio>');
    });
  });
});
```

### `backend/src/services/advice/AdviceService.test.ts`

```typescript
import { describe, expect, it, vi } from 'vitest';
import { AdviceService } from './AdviceService';
import type { AdviceRequest } from './types';

// AnthropicClient のモック
vi.mock('./AnthropicClient', () => ({
  AnthropicClient: vi.fn().mockImplementation(() => ({
    generateAdvice: vi.fn().mockResolvedValue({
      message: {
        title: 'A Quiet Harmony',
        body: '今日のあなたは穏やかな波のように整っています。',
      },
      todayOneThing: {
        icon: 'walking',
        text: '14時頃に5分の散歩を。',
        time: '14:00',
      },
      relatedInsight: {
        text: '23時前就寝で深い睡眠+24%',
        insightId: 'sleep-timing-001',
      },
      metricInsights: {
        sleep: '深い睡眠が理想的な範囲でした。',
        hrv: 'HRVは52msで良好です。',
        steps: '昨日は8,200歩と目標を達成。',
      },
    }),
  })),
}));

describe('AdviceService', () => {
  const service = new AdviceService({
    anthropicApiKey: 'test-api-key',
  });

  const mockRequest: AdviceRequest = {
    user: {
      goals: ['better_sleep'],
      wakeUpTime: '07:00',
      windDownTime: '23:00',
    },
    healthMetrics: {
      sleep: {
        durationMinutes: 450,
        deepSleepMinutes: 105,
        remSleepMinutes: 95,
      },
      hrv: {
        value: 52,
        baseline30d: 48,
      },
      activity: {
        steps: 8200,
      },
    },
    weather: {
      temperature: 8,
      pressure: 1018,
      pressureTrend: 'falling',
      sunrise: '06:50',
      sunset: '16:48',
    },
  };

  describe('generateAdvice', () => {
    it('should generate advice with tempo score', async () => {
      const response = await service.generateAdvice(mockRequest);
      expect(response.tempoScore).toBeGreaterThan(0);
      expect(response.message.title).toBe('A Quiet Harmony');
      expect(response.todayOneThing.icon).toBe('walking');
    });

    it('should use provided tempo score if available', async () => {
      const requestWithScore = { ...mockRequest, tempoScore: 85 };
      const response = await service.generateAdvice(requestWithScore);
      expect(response.tempoScore).toBe(85);
    });
  });
});
```

---

## Phase 7 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd backend

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト
pnpm test

# 4. ローカル起動確認
pnpm dev
```

### API動作確認

```bash
# ローカルサーバー起動後、curlでテスト
curl -X POST http://localhost:8787/api/advice \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "goals": ["better_sleep", "more_energy"],
      "wakeUpTime": "07:00",
      "windDownTime": "23:00"
    },
    "healthMetrics": {
      "sleep": {
        "durationMinutes": 450,
        "deepSleepMinutes": 105,
        "remSleepMinutes": 95
      },
      "hrv": {
        "value": 52,
        "baseline30d": 48
      },
      "activity": {
        "steps": 8200
      }
    },
    "weather": {
      "temperature": 8,
      "pressure": 1018,
      "pressureTrend": "falling",
      "sunrise": "06:50",
      "sunset": "16:48"
    }
  }'
```

### 完了チェックリスト

- [ ] `backend/src/services/advice/types.ts` が新形式に更新されている
- [ ] `backend/src/services/advice/PromptBuilder.ts` が新システムプロンプトで更新されている
- [ ] `backend/src/services/advice/AnthropicClient.ts` が新レスポンス形式に対応している
- [ ] `backend/src/services/advice/AdviceService.ts` が更新されている
- [ ] `backend/src/routes/advice.ts` が新形式に対応している
- [ ] 全テストファイルが新形式に更新されている
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` で全テスト通過**
- [ ] **ローカルサーバーが正常に起動する**
- [ ] **API呼び出しが正常に動作する**

---

## 次のフェーズ

Phase 7 の全てのチェックが完了したら、`08-phase8-api-integration.md` に進む。
