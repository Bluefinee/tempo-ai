---
# 🎯 TempoAI 完全実装指示書 v2.0

## 📋 実装の最終ゴール

1. ✅ **仕様書を現実装に合わせて完全に最適化**
2. ✅ **Mock ⇔ 実データの簡単な切り替え（フラグ 1 つ）**
3. ✅ **バックエンドも含めた完全な実装**
4. ✅ **「API に繋ぐだけで本番稼働」状態**
---

## 🔴 Phase 0: データソース切り替え機構の実装（最優先）

### **タスク 0-1: 設定ファイルの作成**

**新規作成**: `app/src/config/dataSource.ts`

```typescript
/**
 * データソース切り替え設定
 * このフラグを false にするだけで実データに切り替わります
 */
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_DATA: true, // 全体の切り替えマスタースイッチ

  // 個別の切り替え（デバッグ用）
  USE_MOCK_AI: true, // AIアドバイスのMock
  USE_MOCK_WEATHER: true, // 天気データのMock
  USE_MOCK_HEALTHKIT: true, // HealthKitのMock
} as const;

/**
 * 設定の取得（将来的に環境変数から読み込む可能性も考慮）
 */
export const getDataSourceConfig = () => {
  // 将来的にはここで環境変数から読み込む
  // if (process.env.EXPO_PUBLIC_USE_MOCK_DATA === 'false') { ... }

  return DATA_SOURCE_CONFIG;
};
```

---

### **タスク 0-2: DataSourceAdapter の実装**

**新規作成**: `app/src/services/dataSourceAdapter.ts`

```typescript
import { DATA_SOURCE_CONFIG } from "../config/dataSource";
import * as APIClient from "../api/client";
import * as HealthKitService from "../services/healthKitService"; // 未実装（後で作成）
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
  MOCK_AI_RESPONSE,
} from "../constants/mockData";
import type {
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  SimpleWeatherData,
  AdviceRequest,
  AdviceResponse,
} from "../domain/models";

/**
 * データソースアダプター
 * Mock と実データを統一インターフェースで提供
 */
class DataSourceAdapter {
  /**
   * 睡眠メトリクスを取得
   */
  async getSleepMetrics(): Promise<SleepMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_SLEEP_METRICS;
    }
    return await HealthKitService.fetchSleepMetrics();
  }

  /**
   * HRVメトリクスを取得
   */
  async getHRVMetrics(): Promise<HRVMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_HRV_METRICS;
    }
    return await HealthKitService.fetchHRVMetrics();
  }

  /**
   * アクティビティメトリクスを取得
   */
  async getActivityMetrics(): Promise<ActivityMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_ACTIVITY_METRICS;
    }
    return await HealthKitService.fetchActivityMetrics();
  }

  /**
   * リズム分析を取得
   */
  async getRhythmAnalysis(): Promise<RhythmAnalysis> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_RHYTHM_ANALYSIS;
    }
    return await HealthKitService.fetchRhythmAnalysis();
  }

  /**
   * 天気データを取得
   */
  async getWeather(lat: number, lon: number): Promise<SimpleWeatherData> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
      return MOCK_WEATHER;
    }

    const result = await APIClient.getWeather(lat, lon);
    if (!result.success) {
      throw new Error("Failed to fetch weather data");
    }

    return {
      temperature: result.data.temperature,
      pressure: result.data.pressure,
      pressureTrend: result.data.pressureTrend,
      description: result.data.description,
    };
  }

  /**
   * AIアドバイスを取得
   */
  async getAIAdvice(request: AdviceRequest): Promise<AdviceResponse> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_AI) {
      return MOCK_AI_RESPONSE;
    }

    const result = await APIClient.generateAdvice(request);
    if (!result.success) {
      throw new Error("Failed to generate AI advice");
    }

    return result.data;
  }
}

// シングルトンインスタンス
export const dataSourceAdapter = new DataSourceAdapter();
```

---

### **タスク 0-3: healthStore の書き換え**

**対象**: `app/src/stores/healthStore.ts`

**変更箇所**:

```typescript
import { dataSourceAdapter } from '../services/dataSourceAdapter';

// Before: 直接Mockデータを使用
fetchTodayMetrics: async () => {
  set({ isLoadingMetrics: true, metricsError: null });
  try {
    // TODO: Replace with actual HealthKit/Health Connect integration
    await new Promise((resolve) => setTimeout(resolve, 500));

    set({
      sleepMetrics: MOCK_SLEEP_METRICS,
      hrvMetrics: MOCK_HRV_METRICS,
      activityMetrics: MOCK_ACTIVITY_METRICS,
      rhythmAnalysis: MOCK_RHYTHM_ANALYSIS,
      lastMetricsUpdate: new Date(),
      isLoadingMetrics: false,
    });
  } catch (error) {
    set({
      metricsError:
        error instanceof Error
          ? error.message
          : "Failed to fetch metrics",
      isLoadingMetrics: false,
    });
  }
},

// After: Adapterを使用
fetchTodayMetrics: async () => {
  set({ isLoadingMetrics: true, metricsError: null });
  try {
    const [sleep, hrv, activity, rhythm] = await Promise.all([
      dataSourceAdapter.getSleepMetrics(),
      dataSourceAdapter.getHRVMetrics(),
      dataSourceAdapter.getActivityMetrics(),
      dataSourceAdapter.getRhythmAnalysis(),
    ]);

    set({
      sleepMetrics: sleep,
      hrvMetrics: hrv,
      activityMetrics: activity,
      rhythmAnalysis: rhythm,
      lastMetricsUpdate: new Date(),
      isLoadingMetrics: false,
    });
  } catch (error) {
    set({
      metricsError:
        error instanceof Error
          ? error.message
          : "Failed to fetch metrics",
      isLoadingMetrics: false,
    });
  }
},

// fetchWeather も同様に変更
fetchWeather: async (lat?: number, lon?: number) => {
  set({ isLoadingWeather: true, weatherError: null });
  try {
    const coords = lat && lon ? { lat, lon } : await getCurrentLocation();
    const weather = await dataSourceAdapter.getWeather(coords.lat, coords.lon);

    set({
      weather,
      lastWeatherUpdate: new Date(),
      isLoadingWeather: false,
    });
  } catch (error) {
    set({
      weatherError:
        error instanceof Error
          ? error.message
          : "Failed to fetch weather",
      isLoadingWeather: false,
    });
  }
},
```

---

## 🔴 Phase 1: 型定義とスコア計算の統一

### **タスク 1-1: DailyScores 型の統一**

**対象ファイル**: `app/src/domain/models/score.ts`

```typescript
// Before
export interface DailyScores {
  autonomic: number;
  sleep: number;
  rhythm: number;
  activity: number;
}

// After
export interface DailyScores {
  recovery: number; // autonomic → recovery
  sleep: number;
  rhythm: number;
  energy: number; // activity → energy
}
```

**影響を受けるファイルの一括変更**:

1. `app/src/constants/mockData.ts` の `MOCK_SCORES`
2. `app/src/stores/healthStore.ts`（インポートのみなら問題なし）
3. 他に `autonomic` / `activity` を使用している箇所

**検索コマンド**:

```bash
cd app
grep -r "autonomic\|activity" --include="*.ts" --include="*.tsx"
```

---

### **タスク 1-2: スコア計算関数の実装**

**対象ファイル**: `app/src/domain/services/scoreCalculator.ts`（新規作成または既存ファイルに追加）

#### **1. Recovery Score**

```typescript
/**
 * Recovery Score 計算
 * Recovery = HRV (60%) + RHR (20%) + Sleep Quality (20%)
 */
export interface RecoveryScoreInput {
  hrv: {
    current: number; // 現在のHRV (ms)
    baseline: number; // ベースライン (60日平均)
  };
  rhr: {
    current: number; // 現在のRHR (bpm)
    baseline: number; // ベースライン (60日平均)
  };
  sleepQuality: number; // Sleep Scoreから取得 (0-100)
}

export const calculateRecoveryScore = (input: RecoveryScoreInput): number => {
  // HRVスコア（60%）- 高いほど良い
  // ベースラインの70-130%の範囲で0-100点に変換
  const hrvRatio = input.hrv.current / input.hrv.baseline;
  const hrvScore = clamp(((hrvRatio - 0.7) / 0.6) * 100, 0, 100);

  // RHRスコア（20%）- 低いほど良い
  // ベースラインの85-115%の範囲で0-100点に変換（逆比）
  const rhrRatio = input.rhr.baseline / input.rhr.current;
  const rhrScore = clamp(((rhrRatio - 0.85) / 0.3) * 100, 0, 100);

  // 睡眠の質（20%）
  const sleepScore = input.sleepQuality;

  return Math.round(hrvScore * 0.6 + rhrScore * 0.2 + sleepScore * 0.2);
};
```

#### **2. Sleep Score（更新）**

```typescript
/**
 * Sleep Score 計算
 * Sleep = Duration (40%) + Quality (40%) + Timing (20%)
 */
export interface SleepScoreInput {
  duration: {
    minutes: number; // 実際の睡眠時間 (分)
    targetMinutes: number; // 目標睡眠時間 (分、デフォルト450 = 7.5h)
  };
  stages: {
    deepMinutes: number;
    remMinutes: number;
    lightMinutes: number;
    awakeMinutes: number;
  };
  timing?: {
    // オプション（データがない場合はDurationとQualityのみで計算）
    actualBedtime: Date;
    targetBedtime: Date;
    actualWakeTime: Date;
    targetWakeTime: Date;
  };
}

export const calculateSleepScore = (input: SleepScoreInput): number => {
  const totalSleep =
    input.stages.deepMinutes +
    input.stages.remMinutes +
    input.stages.lightMinutes;

  // Duration Score (40%)
  const durationRatio = input.duration.minutes / input.duration.targetMinutes;
  const durationScore = clamp(durationRatio * 100, 0, 100);

  // Quality Score (40%)
  const deepRatio = input.stages.deepMinutes / totalSleep;
  const remRatio = input.stages.remMinutes / totalSleep;

  const deepScore = scoreRange(deepRatio, 0.15, 0.25); // 15-25%が理想
  const remScore = scoreRange(remRatio, 0.2, 0.25); // 20-25%が理想

  const qualityScore = deepScore * 0.5 + remScore * 0.5;

  // Timing Score (20%)
  let timingScore = 100; // デフォルト
  if (input.timing) {
    const bedtimeDeviation =
      Math.abs(
        input.timing.actualBedtime.getTime() -
          input.timing.targetBedtime.getTime()
      ) /
      (1000 * 60); // 分

    const wakeDeviation =
      Math.abs(
        input.timing.actualWakeTime.getTime() -
          input.timing.targetWakeTime.getTime()
      ) /
      (1000 * 60);

    timingScore = clamp(100 - (bedtimeDeviation + wakeDeviation) / 4, 0, 100);
  }

  return Math.round(
    durationScore * 0.4 + qualityScore * 0.4 + timingScore * 0.2
  );
};

// Helper function
const scoreRange = (value: number, min: number, max: number): number => {
  if (value >= min && value <= max) return 100;
  if (value < min) return (value / min) * 100;
  return Math.max(0, 100 - (value - max) * 200);
};

const clamp = (value: number, min: number, max: number): number => {
  return Math.min(Math.max(value, min), max);
};
```

#### **3. Energy Score（新規）**

```typescript
/**
 * Energy Score 計算
 * Energy = Recovery (50%) + Sleep (40%) + Weather (10%)
 */
export interface EnergyScoreInput {
  recovery: number; // Recovery Score (0-100)
  sleep: number; // Sleep Score (0-100)
  weather: {
    pressure: number; // hPa
    pressureTrend: "rising" | "stable" | "falling";
  };
}

export const calculateEnergyScore = (input: EnergyScoreInput): number => {
  // ベーススコア（Recovery 50%, Sleep 40%）
  const baseScore = input.recovery * 0.5 + input.sleep * 0.4;

  // 天気補正（10%）
  let weatherFactor = 100;

  if (
    input.weather.pressureTrend === "falling" &&
    input.weather.pressure < 1010
  ) {
    weatherFactor -= 20; // 気圧急低下: -20%
  } else if (input.weather.pressureTrend === "rising") {
    weatherFactor += 5; // 気圧上昇: +5%
  }

  const weatherScore = clamp(weatherFactor, 0, 100);

  return Math.round(baseScore + weatherScore * 0.1);
};
```

---

### **タスク 1-3: healthStore でスコア計算を呼び出す**

**対象**: `app/src/stores/healthStore.ts`

```typescript
import {
  calculateRecoveryScore,
  calculateSleepScore,
  calculateRhythmScore,
  calculateEnergyScore,
} from '../domain/services/scoreCalculator';

/**
 * 4つの独立スコアを計算
 */
calculateDailyScores: () => {
  const { sleepMetrics, hrvMetrics, activityMetrics, rhythmAnalysis, weather } = get();

  if (!sleepMetrics || !hrvMetrics || !activityMetrics || !rhythmAnalysis) {
    console.warn('Missing metrics for score calculation');
    return;
  }

  // 1. Sleep Score計算（先に計算する必要がある）
  const sleepScore = calculateSleepScore({
    duration: {
      minutes: sleepMetrics.durationMinutes,
      targetMinutes: 450, // TODO: userProfileから取得
    },
    stages: {
      deepMinutes: sleepMetrics.deepSleepMinutes,
      remMinutes: sleepMetrics.remSleepMinutes,
      lightMinutes: sleepMetrics.lightSleepMinutes ?? 0,
      awakeMinutes: sleepMetrics.awakeMinutes ?? 0,
    },
    // timingは後で実装（HealthKitから就寝・起床時刻を取得）
  });

  // 2. Recovery Score計算
  const recoveryScore = calculateRecoveryScore({
    hrv: {
      current: hrvMetrics.current,
      baseline: hrvMetrics.baseline30d,
    },
    rhr: {
      current: hrvMetrics.rhr ?? 60, // TODO: 実際のRHRを取得
      baseline: 60, // TODO: RHRベースラインを計算
    },
    sleepQuality: sleepScore,
  });

  // 3. Rhythm Score計算（既存実装を使用）
  const rhythmScore = calculateRhythmScore({
    bedtimeStddevMinutes: rhythmAnalysis.bedtimeStddevMinutes,
    wakeTimeStddevMinutes: rhythmAnalysis.wakeTimeStddevMinutes,
  });

  // 4. Energy Score計算
  const energyScore = calculateEnergyScore({
    recovery: recoveryScore,
    sleep: sleepScore,
    weather: {
      pressure: weather?.pressure ?? 1013,
      pressureTrend: weather?.pressureTrend ?? 'stable',
    },
  });

  // 5. DailyScoresとして保存
  const dailyScores: DailyScores = {
    recovery: recoveryScore,
    sleep: sleepScore,
    rhythm: rhythmScore,
    energy: energyScore,
  };

  set({
    dailySnapshot: {
      ...get().dailySnapshot,
      scores: dailyScores,
    },
  });
},

/**
 * アプリ起動時に呼び出す初期化関数
 */
initialize: async () => {
  await get().fetchTodayMetrics();
  await get().fetchWeather();
  get().calculateDailyScores(); // ← 追加
},
```

---

## 🟠 Phase 2: リズムフェーズの 4 フェーズ対応

### **タスク 2-1: RhythmPhases 型の拡張**

**対象**: `app/src/api/types.ts`、`backend/src/services/advice/types.ts`

```typescript
// Before
export interface RhythmPhases {
  peakFocus: {
    start: string; // HH:mm
    end: string;
  };
  afternoonDip: {
    start: string;
    end: string;
  };
}

// After
export interface RhythmPhases {
  peakFocus: {
    start: string; // HH:mm
    end: string;
  };
  afternoonDip: {
    start: string;
    end: string;
  };
  secondWind: {
    // 追加
    start: string;
    end: string;
  };
  windDown: {
    // 追加
    start: string;
    end: string;
  };
}
```

**フロントエンドとバックエンド両方で同じ変更を適用してください。**

---

### **タスク 2-2: リズムフェーズ計算関数の実装**

**新規作成**: `app/src/domain/services/rhythmPhaseCalculator.ts`

```typescript
import type { RhythmPhases } from "../api/types";

/**
 * サーカディアンリズムのフェーズを計算
 */
export interface RhythmPhaseInput {
  wakeUpTime: Date; // 起床時刻
  bedtime: Date; // 就寝時刻
}

export const calculateRhythmPhases = (
  input: RhythmPhaseInput
): RhythmPhases => {
  const { wakeUpTime, bedtime } = input;

  // 起床時刻を基準にフェーズを計算
  const peakFocusStart = addHours(wakeUpTime, 2); // 起床 + 2h
  const peakFocusEnd = addHours(wakeUpTime, 5); // 起床 + 5h

  const afternoonDipStart = addHours(wakeUpTime, 7); // 起床 + 7h
  const afternoonDipEnd = addHours(wakeUpTime, 9); // 起床 + 9h

  const secondWindStart = addHours(wakeUpTime, 10); // 起床 + 10h
  const secondWindEnd = addHours(wakeUpTime, 13); // 起床 + 13h

  const windDownStart = addHours(bedtime, -2); // 就寝 - 2h
  const windDownEnd = bedtime;

  return {
    peakFocus: {
      start: formatTime(peakFocusStart),
      end: formatTime(peakFocusEnd),
    },
    afternoonDip: {
      start: formatTime(afternoonDipStart),
      end: formatTime(afternoonDipEnd),
    },
    secondWind: {
      start: formatTime(secondWindStart),
      end: formatTime(secondWindEnd),
    },
    windDown: {
      start: formatTime(windDownStart),
      end: formatTime(windDownEnd),
    },
  };
};

// Helper functions
const addHours = (date: Date, hours: number): Date => {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
};

const formatTime = (date: Date): string => {
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  return `${hours}:${minutes}`;
};
```

---

### **タスク 2-3: バックエンドの PromptBuilder を更新**

**対象**: `backend/src/services/advice/PromptBuilder.ts`

**変更箇所**: `buildUserDataXml()` 関数

```typescript
// Before
<rhythm_phases>
  <peak_focus start="${rhythmPhases.peakFocus.start}" end="${rhythmPhases.peakFocus.end}" />
  <afternoon_dip start="${rhythmPhases.afternoonDip.start}" end="${rhythmPhases.afternoonDip.end}" />
</rhythm_phases>

// After
<rhythm_phases>
  <peak_focus start="${rhythmPhases.peakFocus.start}" end="${rhythmPhases.peakFocus.end}" />
  <afternoon_dip start="${rhythmPhases.afternoonDip.start}" end="${rhythmPhases.afternoonDip.end}" />
  <second_wind start="${rhythmPhases.secondWind.start}" end="${rhythmPhases.secondWind.end}" />
  <wind_down start="${rhythmPhases.windDown.start}" end="${rhythmPhases.windDown.end}" />
</rhythm_phases>
```

---

## 🔴 Phase 3: バックエンドの完全実装

### **タスク 3-1: 気圧トレンド計算の実装**

**対象**: `backend/src/services/weather/OpenMeteoClient.ts`

**変更箇所**: `fetchWeatherData()` 関数

```typescript
// 現在の実装に追加
async fetchWeatherData(lat: number, lon: number): Promise<Result<WeatherData, WeatherError>> {
  try {
    const url = new URL("https://api.open-meteo.com/v1/forecast");
    url.searchParams.set("latitude", lat.toString());
    url.searchParams.set("longitude", lon.toString());
    url.searchParams.set("current", "temperature_2m,relative_humidity_2m,pressure_msl,weather_code");
    url.searchParams.set("daily", "uv_index_max,sunrise,sunset");
    url.searchParams.set("timezone", "auto");
    url.searchParams.set("forecast_days", "1");

    // 気圧トレンド計算のため、過去24時間のデータも取得
    url.searchParams.set("hourly", "pressure_msl");
    url.searchParams.set("past_hours", "24");

    const response = await fetch(url.toString());

    // ... (既存のエラーハンドリング)

    const data = weatherResponseSchema.parse(await response.json());

    // 気圧トレンドの計算
    const currentPressure = data.current.pressure_msl;
    const pressure24hAgo = data.hourly.pressure_msl[0]; // 24時間前
    const pressureDiff = currentPressure - pressure24hAgo;

    const pressureTrend: PressureTrend =
      pressureDiff > 2 ? 'rising' :
      pressureDiff < -2 ? 'falling' :
      'stable';

    return ok({
      temperature: data.current.temperature_2m,
      pressure: currentPressure,
      pressureTrend, // ← 追加
      sunrise: formatTime(data.daily.sunrise[0]),
      sunset: formatTime(data.daily.sunset[0]),
      description: weatherCodeToDescription(data.current.weather_code),
      location: "現在地", // TODO: Reverse geocoding
    });

  } catch (error) {
    // ... (既存のエラーハンドリング)
  }
}

// Zodスキーマも更新
const weatherResponseSchema = z.object({
  current: z.object({
    temperature_2m: z.number(),
    relative_humidity_2m: z.number(),
    pressure_msl: z.number(),
    weather_code: z.number(),
  }),
  daily: z.object({
    uv_index_max: z.array(z.number()),
    sunrise: z.array(z.string()),
    sunset: z.array(z.string()),
  }),
  hourly: z.object({
    pressure_msl: z.array(z.number()),
  }),
});
```

---

### **タスク 3-2: AI API フォールバック処理の適用**

**対象**: `backend/src/services/advice/AdviceService.ts`

```typescript
import { createFallbackResponse } from './types';

// 既存の実装を修正
async generateAdvice(request: AdviceRequest): Promise<Result<AdviceResponse, AdviceError>> {
  try {
    // ... (既存のロジック)

    const aiResult = await this.client.generateAdvice(systemPrompt, userDataXml);

    if (!isOk(aiResult)) {
      // エラー時はフォールバックレスポンスを返す
      console.warn('AI API failed, returning fallback response', aiResult.error);
      return ok(createFallbackResponse());
    }

    // ... (既存のパースロジック)

  } catch (error) {
    console.error('Unexpected error in generateAdvice', error);
    // フォールバックレスポンスを返す
    return ok(createFallbackResponse());
  }
}
```

---

### **タスク 3-3: Weather API フォールバック処理**

**対象**: `backend/src/routes/weather.ts`

```typescript
weatherRoutes.get("/", async (c) => {
  const lat = parseFloat(c.req.query("lat") ?? "");
  const lon = parseFloat(c.req.query("lon") ?? "");

  if (isNaN(lat) || isNaN(lon)) {
    return c.json({ success: false, error: "Invalid coordinates" }, 400);
  }

  const result = await weatherService.getWeather(lat, lon);

  if (isOk(result)) {
    return c.json({ success: true, data: result.data });
  }

  // エラー時はデフォルト値を返す
  console.warn("Weather API failed, returning default data", result.error);
  return c.json({
    success: true,
    data: {
      temperature: 20,
      pressure: 1013,
      pressureTrend: "stable" as const,
      sunrise: "06:00",
      sunset: "18:00",
      description: "晴れ",
      location: "現在地",
    },
  });
});
```

---

### **タスク 3-4: `.dev.vars.example` ファイルの作成**

**新規作成**: `backend/.dev.vars.example`

```bash
# Anthropic API Key
# Get your API key from: https://console.anthropic.com/
ANTHROPIC_API_KEY=sk-ant-api03-...

# Environment (development/staging/production)
ENVIRONMENT=development
```

---

## 🟡 Phase 4: エネルギーカーブ生成の実装

### **タスク 4-1: エネルギーカーブ生成関数**

**新規作成**: `app/src/domain/services/energyCurveGenerator.ts`

```typescript
export interface EnergyCurvePoint {
  time: string; // "HH:MM"
  energy: number; // 0-100
}

/**
 * サーカディアンリズムに基づくエネルギーカーブ生成
 */
export const generateEnergyCurve = (
  wakeUpTime: Date,
  bedtime: Date,
  recoveryScore: number // その日のRecoveryスコアで全体調整
): EnergyCurvePoint[] => {
  const baseEnergy = recoveryScore * 0.8;
  const points: EnergyCurvePoint[] = [];

  // 24時間を30分刻みで計算
  for (let hour = 0; hour < 24; hour += 0.5) {
    const time = new Date(wakeUpTime);
    time.setHours(Math.floor(hour), (hour % 1) * 60, 0, 0);

    const hoursSinceWake =
      (time.getTime() - wakeUpTime.getTime()) / (1000 * 60 * 60);

    let energy: number;

    if (hoursSinceWake < 0) {
      // 就寝中（深夜）
      energy = 20 + Math.random() * 5;
    } else if (hoursSinceWake < 2) {
      // Wake Window: 緩やかに上昇
      energy = 40 + hoursSinceWake * 10;
    } else if (hoursSinceWake < 5) {
      // Peak Focus: 最高値（サイン波）
      const t = (hoursSinceWake - 2) / 3;
      energy = 80 + Math.sin(t * Math.PI) * 15;
    } else if (hoursSinceWake < 7) {
      // Midday: 緩やかに低下
      energy = 75 - (hoursSinceWake - 5) * 5;
    } else if (hoursSinceWake < 9) {
      // Afternoon Dip: 最低値
      const t = (hoursSinceWake - 7) / 2;
      energy = 50 - Math.sin(t * Math.PI) * 5;
    } else if (hoursSinceWake < 13) {
      // Second Wind: 回復
      energy = 50 + (hoursSinceWake - 9) * 5;
    } else {
      // Wind Down: 就寝に向けて低下
      const hoursToBedtime =
        (bedtime.getTime() - time.getTime()) / (1000 * 60 * 60);
      energy = Math.max(30, 70 - Math.max(0, 13 - hoursSinceWake) * 3);
    }

    // Recoveryスコアで全体調整
    energy = energy * (baseEnergy / 70);

    points.push({
      time: formatTime(time),
      energy: clamp(energy, 0, 100),
    });
  }

  return points;
};

const formatTime = (date: Date): string => {
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  return `${hours}:${minutes}`;
};

const clamp = (value: number, min: number, max: number): number => {
  return Math.min(Math.max(value, min), max);
};
```

---

## 📝 Phase 5: 仕様書の更新

### **タスク 5-1: metrics_spec.md の更新**

**対象**: `docs/specs/metrics_spec.md`

**更新内容**:

1. **Section 2.1 Recovery Score** を実装通りに修正

   - 計算式: HRV 60% + RHR 20% + Sleep Quality 20%

2. **Section 2.2 Sleep Score** を実装通りに修正

   - 計算式: Duration 40% + Quality 40% + Timing 20%

3. **Section 2.4 Energy Score** を実装通りに修正

   - 計算式: Recovery 50% + Sleep 40% + Weather 10%

4. **Section 5.1 フェーズ定義** を 4 フェーズに更新
   - `secondWind` と `windDown` を追加

---

### **タスク 5-2: ai_prompt_spec.md の更新**

**対象**: `docs/specs/ai_prompt_spec.md`

**Section 4.1 リクエスト XML** の `<rhythm_phases>` を 4 フェーズに更新:

```xml
<rhythm_phases>
  <peak_focus start="09:00" end="12:00" />
  <afternoon_dip start="14:00" end="16:00" />
  <second_wind start="17:00" end="20:00" />
  <wind_down start="21:00" end="23:00" />
</rhythm_phases>
```

---

## ✅ 実装完了の確認チェックリスト

### **Phase 0: データソース切り替え**

- [ ] `dataSource.ts` が作成されている
- [ ] `dataSourceAdapter.ts` が作成されている
- [ ] `healthStore.ts` が Adapter 経由でデータ取得している
- [ ] `DATA_SOURCE_CONFIG.USE_MOCK_DATA = false` で実データに切り替わる

### **Phase 1: 型定義とスコア計算**

- [ ] `DailyScores` 型が `recovery`/`energy` に統一されている
- [ ] `calculateRecoveryScore()` が実装されている
- [ ] `calculateSleepScore()` が仕様書通りに更新されている
- [ ] `calculateEnergyScore()` が実装されている
- [ ] `healthStore.calculateDailyScores()` が実装されている
- [ ] `healthStore.initialize()` からスコア計算が呼ばれている
- [ ] Today 画面で 4 つのスコアが正しく表示される

### **Phase 2: リズムフェーズ**

- [ ] `RhythmPhases` 型に `secondWind` / `windDown` が追加されている（フロント）
- [ ] `RhythmPhases` 型に `secondWind` / `windDown` が追加されている（バックエンド）
- [ ] `calculateRhythmPhases()` が実装されている
- [ ] バックエンドの PromptBuilder が 4 フェーズに対応している

### **Phase 3: バックエンド完全実装**

- [ ] 気圧トレンド計算が実装されている
- [ ] AI API フォールバック処理が適用されている
- [ ] Weather API フォールバック処理が実装されている
- [ ] `.dev.vars.example` が作成されている

### **Phase 4: エネルギーカーブ**

- [ ] `generateEnergyCurve()` が実装されている
- [ ] Rhythm 画面でエネルギーカーブが表示される

### **Phase 5: 仕様書更新**

- [ ] `metrics_spec.md` が実装に合わせて更新されている
- [ ] `ai_prompt_spec.md` が 4 フェーズに対応している

---

## 🚀 実装の優先順位

| Phase | タスク                             | 優先度  | 見積もり時間 |
| ----- | ---------------------------------- | ------- | ------------ |
| 0-1   | データソース設定ファイル作成       | 🔴 最高 | 10 分        |
| 0-2   | DataSourceAdapter 実装             | 🔴 最高 | 1 時間       |
| 0-3   | healthStore 書き換え               | 🔴 最高 | 30 分        |
| 1-1   | DailyScores 型の統一               | 🔴 最高 | 30 分        |
| 1-2   | 4 つの独立スコア計算関数の実装     | 🔴 最高 | 2 時間       |
| 1-3   | healthStore でスコア計算を呼び出す | 🔴 最高 | 1 時間       |
| 2-1   | RhythmPhases 型の拡張              | 🟠 高   | 15 分        |
| 2-2   | リズムフェーズ計算関数の実装       | 🟠 高   | 1 時間       |
| 2-3   | バックエンドの PromptBuilder 更新  | 🟠 高   | 30 分        |
| 3-1   | 気圧トレンド計算の実装             | 🔴 最高 | 1 時間       |
| 3-2   | AI API フォールバック処理の適用    | 🟠 高   | 30 分        |
| 3-3   | Weather API フォールバック処理     | 🟡 中   | 30 分        |
| 3-4   | .dev.vars.example の作成           | 🟢 低   | 10 分        |
| 4-1   | エネルギーカーブ生成関数           | 🟡 中   | 1 時間       |
| 5-1   | metrics_spec.md の更新             | 🟡 中   | 1 時間       |
| 5-2   | ai_prompt_spec.md の更新           | 🟡 中   | 30 分        |

**合計見積もり**: 約 11.5 時間

---
