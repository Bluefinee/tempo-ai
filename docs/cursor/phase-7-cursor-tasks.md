# Phase 7: API連携実装 - Cursor向け詳細タスク

> **重要**: このドキュメントはCursor AIへの指示書です。
> 各タスクを順番に実行し、完了したらチェックを入れてください。

---

## 概要

| 項目 | 内容 |
|------|------|
| **目的** | アプリからバックエンドAPIを呼び出し、モックデータを実データに置き換え |
| **依存** | Phase 6（バックエンド稼働） |
| **成果物** | 天気・AIアドバイスが実データで動作するアプリ |

---

## 前提条件（人間が完了済み）

| タスク | 状態 | 詳細 |
|--------|------|------|
| Cloudflare Workersデプロイ | ✅ 完了 | ステージング環境 |
| ANTHROPIC_API_KEY設定 | ✅ 完了 | ステージング環境 |
| API動作確認 | ✅ 完了 | health, weather, advice |
| `.env.example` 作成 | ✅ 完了 | `app/.env.example` |

### 確定した環境情報

| 環境 | URL |
|------|-----|
| **ステージング** | `https://tempo-ai-api-staging.tempo-ai.workers.dev` |
| ローカル | `http://localhost:8787` |

---

## 重要: 型の不整合について

### 現状の問題

バックエンドAPIとアプリで型定義が異なります。バックエンドを修正してアプリに合わせます。

**バックエンドAPI（現在）**:
```typescript
interface AdviceResponse {
  summary: string;          // 100-150文字
  fullInsight: string;      // 400-600文字（テキスト一塊）
  recommendedAction: { type, message }
}
```

**アプリが期待**:
```typescript
interface AIInsightFull {
  greeting: string;
  condition: string;
  sleep: string;
  rhythm: string;
  environment: string;
  advice: string;
  closing: string;
}
```

---

## タスク一覧

### Part 1: バックエンド修正（7セクション対応）

- [ ] タスク1: `backend/src/services/advice/types.ts` - 型定義修正
- [ ] タスク2: `backend/src/services/advice/PromptBuilder.ts` - プロンプト修正
- [ ] タスク3: `backend/src/services/advice/AnthropicClient.ts` - パーサー修正
- [ ] タスク4: バックエンドテスト実行

### Part 2: アプリ修正（API連携）

- [ ] タスク5: `app/src/api/types.ts` - 型定義更新
- [ ] タスク6: `app/src/api/config.ts` - ポート番号修正
- [ ] タスク7: `app/src/domain/services/pressureService.ts` - 新規作成
- [ ] タスク8: `app/src/stores/healthStore.ts` - 天気API連携
- [ ] タスク9: `app/src/api/helpers/adviceRequestBuilder.ts` - 新規作成
- [ ] タスク10: `app/src/stores/insightStore.ts` - AIアドバイスAPI連携

### Part 3: オフライン対応

- [ ] タスク11: `@react-native-community/netinfo` 追加
- [ ] タスク12: `app/src/hooks/useNetworkStatus.ts` - 新規作成
- [ ] タスク13: `app/src/api/utils/retry.ts` - 新規作成

### Part 4: 確認

- [ ] タスク14: Lintチェック
- [ ] タスク15: 型チェック
- [ ] タスク16: テスト実行

---

## Part 1: バックエンド修正

### タスク1: 型定義修正

**ファイル**: `backend/src/services/advice/types.ts`

**変更内容**: `AdviceResponse` インターフェースを7セクション形式に変更

```typescript
// 行154-161を以下に置き換え

/** インサイトの7セクション */
export interface InsightSections {
  /** 挨拶（1文） */
  greeting: string;
  /** 今日のコンディション総評（2-3文） */
  condition: string;
  /** 睡眠分析（3-4文） */
  sleep: string;
  /** リズム分析（2-3文） */
  rhythm: string;
  /** 環境影響予測（2-3文） */
  environment: string;
  /** 今日の過ごし方提案（3-4文） */
  advice: string;
  /** クロージング（1文） */
  closing: string;
}

/** AI生成アドバイスのレスポンス */
export interface AdviceResponse {
  /** ホーム画面に表示する要約（100-150文字） */
  summary: string;
  /** 詳細画面に表示する7セクション形式のインサイト */
  insight: InsightSections;
  /** 推奨アクション */
  recommendedAction: RecommendedAction;
}
```

---

### タスク2: プロンプト修正

**ファイル**: `backend/src/services/advice/PromptBuilder.ts`

**変更内容**: `<output_format>` セクションを7セクションJSON形式に変更

行158-169の `<output_format>` セクションを以下に置き換え:

```typescript
<output_format>
以下のJSON形式で出力してください。

{
  "summary": "ホーム画面に表示する要約（3-4文、100-150文字）",
  "insight": {
    "greeting": "挨拶（1文）- ニックネーム + 時間帯に応じた挨拶",
    "condition": "今日のコンディション総評（2-3文）",
    "sleep": "睡眠分析（3-4文）",
    "rhythm": "リズム分析（2-3文）",
    "environment": "環境影響予測（2-3文）",
    "advice": "今日の過ごし方提案（3-4文）",
    "closing": "クロージング（1文）- 温かいエールや励まし"
  },
  "recommended_action": {
    "type": "breathing | morning_light | rest | activity",
    "message": "Quick Actionに表示するメッセージ（20文字以内）"
  }
}

各セクションの詳細:
- greeting: ニックネームで呼びかけ、時間帯に応じた挨拶
- condition: スコアに基づく全体的な状態、ポジティブな面を先に
- sleep: 昨夜の睡眠の質と量、深い睡眠・レム睡眠の状態、目標就寝時刻との比較
- rhythm: 就寝・起床時刻の規則性、連続安定日数がある場合はその効果
- environment: 今日の気象条件（気圧、天気、気温）、体調への影響予測
- advice: 午前・午後・夜それぞれの具体的な提案、ユーザーの職業やクロノタイプを考慮
- closing: 温かいエールや励まし
</output_format>
```

また、行171-205の `<full_insight_structure>` セクションは削除（`<output_format>` に統合されたため）

---

### タスク3: パーサー修正

**ファイル**: `backend/src/services/advice/AnthropicClient.ts`

**変更内容**: `parseResponse` メソッドを7セクション形式に対応

行56-142の `parseResponse` メソッド全体を以下に置き換え:

```typescript
  /**
   * APIレスポンスをパース
   */
  private parseResponse = (
    response: PromptCachingBetaMessage,
  ): Result<AdviceResponse, AdviceError> => {
    const textBlock = response.content.find(
      (block): block is Anthropic.TextBlock => block.type === 'text',
    );

    if (!textBlock) {
      return err({
        code: 'PARSE_ERROR',
        message: 'No text content in response',
      });
    }

    try {
      const jsonMatch = textBlock.text.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        return err({
          code: 'PARSE_ERROR',
          message: 'No JSON found in response',
        });
      }

      const parsed = JSON.parse(jsonMatch[0]) as {
        summary?: string;
        insight?: {
          greeting?: string;
          condition?: string;
          sleep?: string;
          rhythm?: string;
          environment?: string;
          advice?: string;
          closing?: string;
        };
        recommended_action?: {
          type?: string;
          message?: string;
        };
      };

      // summary validation
      if (!parsed.summary || typeof parsed.summary !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid summary field',
        });
      }

      // insight validation
      if (!parsed.insight || typeof parsed.insight !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid insight field',
        });
      }

      const insightFields = ['greeting', 'condition', 'sleep', 'rhythm', 'environment', 'advice', 'closing'] as const;
      for (const field of insightFields) {
        if (!parsed.insight[field] || typeof parsed.insight[field] !== 'string') {
          return err({
            code: 'PARSE_ERROR',
            message: `Missing or invalid insight.${field} field`,
          });
        }
      }

      // recommended_action validation
      if (!parsed.recommended_action || typeof parsed.recommended_action !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid recommended_action field',
        });
      }

      const actionType = parsed.recommended_action.type;
      if (!this.isValidActionType(actionType)) {
        return err({
          code: 'PARSE_ERROR',
          message: `Invalid recommended_action.type: ${actionType}`,
        });
      }

      if (
        !parsed.recommended_action.message ||
        typeof parsed.recommended_action.message !== 'string'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid recommended_action.message field',
        });
      }

      return ok({
        summary: parsed.summary,
        insight: {
          greeting: parsed.insight.greeting!,
          condition: parsed.insight.condition!,
          sleep: parsed.insight.sleep!,
          rhythm: parsed.insight.rhythm!,
          environment: parsed.insight.environment!,
          advice: parsed.insight.advice!,
          closing: parsed.insight.closing!,
        },
        recommendedAction: {
          type: actionType,
          message: parsed.recommended_action.message,
        },
      });
    } catch (parseError) {
      return err({
        code: 'PARSE_ERROR',
        message: 'Failed to parse JSON response',
        details: parseError instanceof Error ? parseError.message : String(parseError),
      });
    }
  };
```

---

### タスク4: バックエンドテスト実行

```bash
cd backend
npm run lint
npm run type-check
npm test
```

エラーがあれば修正してください。

---

## Part 2: アプリ修正

### タスク5: 型定義更新

**ファイル**: `app/src/api/types.ts`

**変更内容**: バックエンドの新しい型定義に合わせて更新

全体を以下に置き換え:

```typescript
/**
 * API Request/Response Types
 */

import {
  UserProfile,
  AIInsightFull,
  Mood,
  TodayMode,
  RecommendedAction,
} from '../domain/models';

// ========================================
// Advice API
// ========================================

export interface AdviceRequestProfile {
  nickname: string;
  age: number;
  gender: string;
  chronotype: string;
  occupation?: string;
  exerciseFrequency?: string;
  targetBedtime: string;
}

export interface AdviceRequestHealthData {
  sleep?: {
    bedtime: string;
    wakeTime: string;
    durationHours: number;
    deepSleepMinutes: number;
    remSleepMinutes: number;
    deepSleepRatio: number;
  };
  hrv?: {
    value: number;
    baseline30d: number;
    deviationPercent: number;
  };
  activity?: {
    stepsYesterday: number;
    activeMinutesYesterday: number;
  };
  scores: {
    autonomic: number;
    sleep: number;
    rhythm: number;
    activity: number;
  };
  rhythmAnalysis: {
    bedtimeStddevMinutes: number;
    wakeTimeStddevMinutes: number;
    consecutiveStableDays: number;
    status: 'stable' | 'recovering' | 'unstable';
  };
}

export interface AdviceRequestLocation {
  latitude: number;
  longitude: number;
  city: string;
}

export interface AdviceRequestContext {
  currentTime: string;
  dayOfWeek: string;
  mood?: Mood;
  todayMode: TodayMode;
}

export interface AdviceRequestWeather {
  temperature: number;
  humidity: number;
  pressure: number;
  weatherCode: number;
  uvIndexMax: number;
}

export interface AdviceRequest {
  profile: AdviceRequestProfile;
  healthData: AdviceRequestHealthData;
  location: AdviceRequestLocation;
  context: AdviceRequestContext;
  weather?: AdviceRequestWeather;
}

export interface AdviceResponseData {
  summary: string;
  insight: AIInsightFull;
  recommendedAction: {
    type: 'breathing' | 'morning_light' | 'rest' | 'activity';
    message: string;
  };
}

export interface AdviceResponse {
  success: boolean;
  data?: AdviceResponseData;
  error?: string;
}

// ========================================
// Weather API
// ========================================

export interface WeatherRequest {
  latitude: number;
  longitude: number;
}

export interface WeatherResponseData {
  temperature: number;
  humidity: number;
  pressure: number;
  weatherCode: number;
  uvIndexMax: number;
  sunrise: string;
  sunset: string;
  airQuality: {
    pm25: number;
    aqi: number;
  };
}

export interface WeatherResponse {
  success: boolean;
  data?: WeatherResponseData;
  error?: string;
}

// ========================================
// Health Check API
// ========================================

export interface HealthCheckResponse {
  status: string;
  timestamp?: string;
}

// ========================================
// Generic API Error
// ========================================

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}
```

---

### タスク6: API設定のポート修正

**ファイル**: `app/src/api/config.ts`

**変更内容**: デフォルトのポートを3000から8787に変更

行6-7を以下に変更:

```typescript
export const API_BASE_URL: string =
  process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8787';
```

行9-11を以下に変更:

```typescript
if (__DEV__ && API_BASE_URL === 'http://localhost:8787') {
  console.warn('Using default API URL. Set EXPO_PUBLIC_API_URL environment variable for production.');
}
```

---

### タスク7: 気圧トレンドサービス作成

**ファイル**: `app/src/domain/services/pressureService.ts`（新規作成）

```typescript
/**
 * 気圧トレンド計算サービス
 * 過去の気圧履歴から上昇・下降・安定を判定
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import type { PressureTrend } from '../models/weather';

const PRESSURE_HISTORY_KEY = 'tempo_pressure_history';
const HISTORY_RETENTION_HOURS = 24;
const TREND_COMPARISON_HOURS = 3;
const TREND_THRESHOLD_HPA = 2;

interface PressureRecord {
  value: number;
  timestamp: number;
}

/**
 * 気圧履歴を取得
 */
const getPressureHistory = async (): Promise<PressureRecord[]> => {
  try {
    const data = await AsyncStorage.getItem(PRESSURE_HISTORY_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
};

/**
 * 気圧履歴を保存
 */
const savePressureHistory = async (history: PressureRecord[]): Promise<void> => {
  try {
    await AsyncStorage.setItem(PRESSURE_HISTORY_KEY, JSON.stringify(history));
  } catch (error) {
    console.warn('Failed to save pressure history:', error);
  }
};

/**
 * 気圧トレンドを計算
 * @param currentPressure 現在の気圧（hPa）
 * @returns 気圧トレンド（'up' | 'stable' | 'down'）
 */
export const calculatePressureTrend = async (
  currentPressure: number
): Promise<PressureTrend> => {
  const now = Date.now();
  const history = await getPressureHistory();

  // 履歴に追加
  history.push({ value: currentPressure, timestamp: now });

  // 24時間以内のデータのみ保持
  const retentionMs = HISTORY_RETENTION_HOURS * 60 * 60 * 1000;
  const recentHistory = history.filter((r) => now - r.timestamp < retentionMs);

  // 履歴を保存
  await savePressureHistory(recentHistory);

  // 3時間前のデータを探す
  const comparisonMs = TREND_COMPARISON_HOURS * 60 * 60 * 1000;
  const threeHoursAgo = now - comparisonMs;

  // 3時間前に最も近いデータを取得
  const oldRecords = recentHistory.filter((r) => r.timestamp <= threeHoursAgo);

  if (oldRecords.length === 0) {
    // 比較データがない場合は安定とする
    return 'stable';
  }

  // 最新の比較対象データ
  const oldRecord = oldRecords[oldRecords.length - 1];
  const diff = currentPressure - oldRecord.value;

  if (diff > TREND_THRESHOLD_HPA) {
    return 'up';
  }
  if (diff < -TREND_THRESHOLD_HPA) {
    return 'down';
  }
  return 'stable';
};

/**
 * 気圧履歴をクリア（テスト用）
 */
export const clearPressureHistory = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(PRESSURE_HISTORY_KEY);
  } catch (error) {
    console.warn('Failed to clear pressure history:', error);
  }
};
```

また、`app/src/domain/services/index.ts` にエクスポートを追加:

```typescript
// 既存のエクスポートの後に追加
export * from './pressureService';
```

---

### タスク8: healthStore - 天気API連携

**ファイル**: `app/src/stores/healthStore.ts`

**変更1**: importを追加（行1-17の後に追加）

```typescript
import { apiClient } from '../api/client';
import { calculatePressureTrend } from '../domain/services/pressureService';
import { getWeatherCondition } from '../domain/models/weather';
```

**変更2**: `fetchWeather` メソッドを実API呼び出しに変更

行97-116を以下に置き換え:

```typescript
  fetchWeather: async (latitude: number, longitude: number): Promise<void> => {
    set({ isLoadingWeather: true, weatherError: null });

    try {
      const response = await apiClient.weather.get({ latitude, longitude });

      if (!response.success || !response.data) {
        throw new Error(response.error || 'Failed to fetch weather');
      }

      const { temperature, humidity, pressure, weatherCode, uvIndexMax } = response.data;

      // 気圧トレンドを計算
      const pressureTrend = await calculatePressureTrend(pressure);

      // SimpleWeatherData形式に変換
      const weather: SimpleWeatherData = {
        temp: temperature,
        condition: getWeatherCondition(weatherCode),
        pressure,
        pressureTrend,
        uv: uvIndexMax,
        location: '現在地', // TODO: 逆ジオコーディングで都市名を取得
      };

      set({
        weather,
        isLoadingWeather: false,
        lastWeatherUpdate: new Date(),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to fetch weather';
      set({
        isLoadingWeather: false,
        weatherError: message,
      });
      console.error('Weather fetch error:', error);
    }
  },
```

---

### タスク9: アドバイスリクエストビルダー作成

**ファイル**: `app/src/api/helpers/adviceRequestBuilder.ts`（新規作成）

まず、ディレクトリを作成:
```bash
mkdir -p app/src/api/helpers
```

ファイル内容:

```typescript
/**
 * AdviceRequest構築ヘルパー
 * ストアの状態からAPIリクエストを構築
 */

import type { AdviceRequest } from '../types';
import { useUserStore } from '../../stores/userStore';
import { useHealthStore } from '../../stores/healthStore';
import { useInsightStore } from '../../stores/insightStore';

const DAY_NAMES = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/**
 * 現在のストア状態からAdviceRequestを構築
 * @returns AdviceRequest または null（プロファイルがない場合）
 */
export const buildAdviceRequest = (): AdviceRequest | null => {
  const userState = useUserStore.getState();
  const healthState = useHealthStore.getState();
  const insightState = useInsightStore.getState();

  const { profile } = userState;
  if (!profile) {
    console.warn('buildAdviceRequest: profile is null');
    return null;
  }

  const {
    sleepMetrics,
    hrvMetrics,
    activityMetrics,
    dailyScores,
    rhythmAnalysis,
    weather,
  } = healthState;

  const { todayMood, todayMode } = insightState;

  // 現在時刻情報
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  const minutes = now.getMinutes().toString().padStart(2, '0');
  const currentTime = `${hours}:${minutes}`;
  const dayOfWeek = DAY_NAMES[now.getDay()];

  // スコアのデフォルト値
  const scores = dailyScores || {
    autonomic: 0,
    sleep: 0,
    rhythm: 0,
    activity: 0,
  };

  // リズム分析のデフォルト値
  const rhythm = rhythmAnalysis || {
    bedtimeStddevMinutes: 0,
    wakeTimeStddevMinutes: 0,
    consecutiveStableDays: 0,
    status: 'unstable' as const,
  };

  const request: AdviceRequest = {
    profile: {
      nickname: profile.nickname,
      age: profile.age,
      gender: profile.gender,
      chronotype: profile.chronotype,
      occupation: profile.occupation,
      exerciseFrequency: profile.exerciseFrequency,
      targetBedtime: profile.targetBedtime,
    },
    healthData: {
      sleep: sleepMetrics
        ? {
            bedtime: sleepMetrics.bedtime.toISOString(),
            wakeTime: sleepMetrics.wakeTime.toISOString(),
            durationHours: sleepMetrics.durationMinutes / 60,
            deepSleepMinutes: sleepMetrics.deepSleepMinutes,
            remSleepMinutes: sleepMetrics.remSleepMinutes,
            deepSleepRatio:
              sleepMetrics.deepSleepMinutes / sleepMetrics.durationMinutes,
          }
        : undefined,
      hrv: hrvMetrics
        ? {
            value: hrvMetrics.value,
            baseline30d: hrvMetrics.baseline30d,
            deviationPercent:
              ((hrvMetrics.value - hrvMetrics.baseline30d) /
                hrvMetrics.baseline30d) *
              100,
          }
        : undefined,
      activity: activityMetrics
        ? {
            stepsYesterday: activityMetrics.stepsYesterday,
            activeMinutesYesterday: activityMetrics.activeMinutesYesterday,
          }
        : undefined,
      scores,
      rhythmAnalysis: rhythm,
    },
    location: {
      // TODO: 実際の位置情報を使用
      latitude: 35.6762,
      longitude: 139.6503,
      city: '東京',
    },
    context: {
      currentTime,
      dayOfWeek,
      mood: todayMood ?? undefined,
      todayMode: todayMode || 'normal',
    },
    weather: weather
      ? {
          temperature: weather.temp,
          humidity: 50, // TODO: APIから取得した値を使用
          pressure: weather.pressure,
          weatherCode: 0, // TODO: conditionからweatherCodeに逆変換
          uvIndexMax: weather.uv,
        }
      : undefined,
  };

  return request;
};
```

---

### タスク10: insightStore - AIアドバイスAPI連携

**ファイル**: `app/src/stores/insightStore.ts`

**変更1**: importを追加（行1-8の後に追加）

```typescript
import { apiClient } from '../api/client';
import { buildAdviceRequest } from '../api/helpers/adviceRequestBuilder';
import { createRecommendedAction } from '../domain/models/advice';
```

**変更2**: `generateDailyInsight` メソッドを実API呼び出しに変更

行70-116を以下に置き換え:

```typescript
  generateDailyInsight: async (_nickname: string) => {
    set({
      isGeneratingInsight: true,
      generationPhase: 0,
      insightError: null,
    });

    try {
      // Labor Illusion: API呼び出しと並行してフェーズ表示
      const advicePromise = (async () => {
        const request = buildAdviceRequest();
        if (!request) {
          throw new Error('プロファイルが設定されていません');
        }
        return apiClient.advice.generate(request);
      })();

      // フェーズ表示（Labor Illusion）
      for (let phase = 0; phase < GENERATION_MESSAGES.length; phase++) {
        set({ generationPhase: phase });
        await new Promise((resolve) => setTimeout(resolve, 800));
      }

      // API レスポンス待機
      const response = await advicePromise;

      if (!response.success || !response.data) {
        throw new Error(response.error || 'アドバイスの生成に失敗しました');
      }

      const { summary, insight, recommendedAction } = response.data;

      // DailyAdvice形式に変換
      const dailyAdvice: DailyAdvice = {
        id: `advice_${Date.now()}`,
        date: new Date(),
        greeting: insight.greeting,
        condition: insight.condition,
        sleep: insight.sleep,
        rhythm: insight.rhythm,
        environment: insight.environment,
        advice: insight.advice,
        closing: insight.closing,
      };

      // RecommendedAction形式に変換
      const action = createRecommendedAction(
        recommendedAction.type,
        recommendedAction.message
      );

      set({
        dailyAdvice,
        shortGreeting: summary,
        quickActions: MOCK_QUICK_ACTIONS, // TODO: APIから取得
        recommendedAction: action,
        isGeneratingInsight: false,
        lastInsightUpdate: new Date(),
      });
    } catch (error) {
      set({
        isGeneratingInsight: false,
        insightError:
          error instanceof Error ? error.message : 'アドバイスの生成に失敗しました',
      });
      console.error('Insight generation error:', error);
    }
  },
```

---

## Part 3: オフライン対応

### タスク11: NetInfoパッケージ追加

```bash
cd app
pnpm add @react-native-community/netinfo
```

Expoの場合、追加設定は不要です。

---

### タスク12: ネットワークステータスフック作成

**ファイル**: `app/src/hooks/useNetworkStatus.ts`（新規作成）

```typescript
/**
 * ネットワーク状態を監視するフック
 */

import { useEffect, useState } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

interface NetworkStatus {
  isConnected: boolean;
  isInternetReachable: boolean | null;
}

/**
 * ネットワーク状態を監視
 * @returns { isConnected, isInternetReachable }
 */
export const useNetworkStatus = (): NetworkStatus => {
  const [state, setState] = useState<NetInfoState | null>(null);

  useEffect(() => {
    // 初期状態を取得
    NetInfo.fetch().then(setState);

    // 状態変更を監視
    const unsubscribe = NetInfo.addEventListener(setState);
    return () => unsubscribe();
  }, []);

  return {
    isConnected: state?.isConnected ?? true,
    isInternetReachable: state?.isInternetReachable ?? null,
  };
};

/**
 * ネットワーク接続が利用可能かチェック（非フック版）
 */
export const checkNetworkConnection = async (): Promise<boolean> => {
  const state = await NetInfo.fetch();
  return state.isConnected ?? false;
};
```

`app/src/hooks/index.ts` にエクスポートを追加:

```typescript
export * from './useNetworkStatus';
```

---

### タスク13: リトライユーティリティ作成

**ファイル**: `app/src/api/utils/retry.ts`（新規作成）

まず、ディレクトリを作成:
```bash
mkdir -p app/src/api/utils
```

ファイル内容:

```typescript
/**
 * リトライユーティリティ
 * API呼び出しの自動リトライ機能
 */

interface RetryOptions {
  maxRetries?: number;
  initialDelayMs?: number;
  maxDelayMs?: number;
  backoffMultiplier?: number;
}

const DEFAULT_OPTIONS: Required<RetryOptions> = {
  maxRetries: 3,
  initialDelayMs: 1000,
  maxDelayMs: 10000,
  backoffMultiplier: 2,
};

/**
 * 指定した関数を失敗時にリトライして実行
 * @param fn 実行する非同期関数
 * @param options リトライオプション
 * @returns 関数の戻り値
 * @throws 最大リトライ回数を超えた場合
 */
export const withRetry = async <T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> => {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error | null = null;
  let delay = opts.initialDelayMs;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt < opts.maxRetries) {
        // 次の試行前に待機
        await sleep(delay);
        // バックオフ（待機時間を増加）
        delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelayMs);
      }
    }
  }

  throw lastError;
};

/**
 * 指定ミリ秒待機
 */
const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * 条件付きリトライ（特定のエラーのみリトライ）
 */
export const withConditionalRetry = async <T>(
  fn: () => Promise<T>,
  shouldRetry: (error: Error) => boolean,
  options: RetryOptions = {}
): Promise<T> => {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error | null = null;
  let delay = opts.initialDelayMs;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      // リトライ条件を満たさない場合は即座にエラー
      if (!shouldRetry(lastError)) {
        throw lastError;
      }

      if (attempt < opts.maxRetries) {
        await sleep(delay);
        delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelayMs);
      }
    }
  }

  throw lastError;
};
```

`app/src/api/utils/index.ts` を作成:

```typescript
export * from './retry';
```

---

## Part 4: 確認

### タスク14: Lintチェック

```bash
cd app
pnpm run lint
```

```bash
cd backend
npm run lint
```

---

### タスク15: 型チェック

```bash
cd app
pnpm run type-check
```

```bash
cd backend
npm run type-check
```

---

### タスク16: テスト実行

```bash
cd backend
npm test
```

```bash
cd app
pnpm test
```

---

## 完了条件

以下がすべて満たされていることを確認:

1. [ ] バックエンドの型定義が7セクション形式に更新されている
2. [ ] バックエンドのプロンプトが7セクションJSON形式を出力する
3. [ ] バックエンドのパーサーが7セクション形式を正しく解析する
4. [ ] アプリの型定義がバックエンドと整合している
5. [ ] `healthStore.fetchWeather()` が実APIを呼び出す
6. [ ] `insightStore.generateDailyInsight()` が実APIを呼び出す
7. [ ] 気圧トレンドサービスが実装されている
8. [ ] リトライユーティリティが実装されている
9. [ ] ネットワークステータスフックが実装されている
10. [ ] Lint/型チェック/テストがすべて通る

---

## 手動テスト手順（Cursor完了後）

人間が以下を確認:

1. `app/.env.local` を作成（`app/.env.example` をコピー）
2. `cd app && pnpm start` でアプリ起動
3. Simulatorで動作確認
   - 天気データが表示されるか
   - AIアドバイスが生成されるか
   - Labor Illusion UIが表示されるか

---

## 次のフェーズ

Phase 7 完了後、Phase 8（HealthKit連携）に進む。
