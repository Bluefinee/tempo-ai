# Phase 8: フロントエンドAPI連携

## 目的

- フロントエンドのAPI型定義を新形式に更新
- APIクライアントの更新
- リクエストビルダーの更新
- Store との連携

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | TypeScript規約、エラーハンドリング |
| React Native規約 | `/.claude/react-native-standards.md` | API呼び出しパターン |
| 技術仕様 | `/docs/specs/technical_spec.md` | API設計、リクエスト/レスポンス形式 |
| Phase 4完了 | `/docs/cursor/04-phase4-stores.md` | Store構造 |
| Phase 7完了 | `/docs/cursor/07-phase7-backend.md` | バックエンド型定義 |

---

## Task 8.1: API型定義

### `app/src/api/types.ts`

```typescript
/**
 * API型定義
 * @see docs/specs/technical_spec.md
 */

// ユーザーゴール
export type UserGoal = 'better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance';

// One Thingアイコン
export type OneThingIcon = 'walking' | 'breathing' | 'rest' | 'coffee' | 'sun';

// 気圧トレンド
export type PressureTrend = 'rising' | 'stable' | 'falling';

// ユーザープロフィール
export interface UserProfile {
  goals: UserGoal[];
  wakeUpTime: string;
  windDownTime: string;
}

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

// アドバイスリクエスト
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

// アドバイスレスポンス
export interface AdviceResponse {
  tempoScore: number;
  message: AiMessage;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
  metricInsights: MetricInsights;
}

// 天気レスポンス
export interface WeatherResponse {
  temperature: number;
  pressure: number;
  pressureTrend: PressureTrend;
  sunrise: string;
  sunset: string;
  description: string;
  location: string;
}

// APIエラー
export interface ApiError {
  error: string;
  message?: string;
  statusCode?: number;
}

// APIレスポンス（ジェネリック）
export type ApiResponse<T> = { success: true; data: T } | { success: false; error: ApiError };
```

---

## Task 8.2: APIクライアント

### `app/src/api/client.ts`

```typescript
import Constants from 'expo-constants';
import type {
  AdviceRequest,
  AdviceResponse,
  ApiError,
  ApiResponse,
  WeatherResponse,
} from './types';

const API_BASE_URL = Constants.expoConfig?.extra?.apiBaseUrl ?? 'http://localhost:8787';
const API_TIMEOUT = 30000;

interface FetchOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  body?: unknown;
  timeout?: number;
}

/**
 * APIクライアント
 */
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  /**
   * フェッチラッパー
   */
  private async fetch<T>(endpoint: string, options: FetchOptions = {}): Promise<ApiResponse<T>> {
    const { method = 'GET', body, timeout = API_TIMEOUT } = options;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({})) as Partial<ApiError>;
        return {
          success: false,
          error: {
            error: errorData.error ?? 'Request failed',
            message: errorData.message,
            statusCode: response.status,
          },
        };
      }

      const data = await response.json() as T;
      return { success: true, data };
    } catch (error) {
      clearTimeout(timeoutId);

      if (error instanceof Error && error.name === 'AbortError') {
        return {
          success: false,
          error: {
            error: 'Request timeout',
            message: 'The request took too long to complete',
          },
        };
      }

      return {
        success: false,
        error: {
          error: 'Network error',
          message: error instanceof Error ? error.message : 'Unknown error',
        },
      };
    }
  }

  /**
   * ヘルスチェック
   */
  async health(): Promise<ApiResponse<{ status: string }>> {
    return this.fetch('/api/health');
  }

  /**
   * 天気情報取得
   */
  async getWeather(lat: number, lon: number): Promise<ApiResponse<WeatherResponse>> {
    return this.fetch(`/api/weather?lat=${lat}&lon=${lon}`);
  }

  /**
   * AIアドバイス生成
   */
  async generateAdvice(request: AdviceRequest): Promise<ApiResponse<AdviceResponse>> {
    return this.fetch('/api/advice', {
      method: 'POST',
      body: request,
    });
  }
}

// シングルトンインスタンス
export const apiClient = new ApiClient(API_BASE_URL);

// 型エクスポート
export type { ApiClient };
```

---

## Task 8.3: リクエストビルダー

### `app/src/api/helpers/adviceRequestBuilder.ts`

```typescript
import type { AdviceRequest, HealthMetrics, UserProfile, WeatherData } from '../types';
import type { HealthStoreState } from '@/stores/healthStore';
import type { UserStoreState } from '@/stores/userStore';

interface BuildAdviceRequestParams {
  healthStore: Pick<HealthStoreState, 'sleepData' | 'hrvData' | 'activityData' | 'tempoScore'>;
  userStore: Pick<UserStoreState, 'goals' | 'wakeUpTime' | 'windDownTime'>;
  weather: WeatherData;
}

/**
 * アドバイスAPIリクエストを構築
 */
export const buildAdviceRequest = ({
  healthStore,
  userStore,
  weather,
}: BuildAdviceRequestParams): AdviceRequest => {
  const user: UserProfile = {
    goals: userStore.goals ?? ['better_sleep'],
    wakeUpTime: userStore.wakeUpTime ?? '07:00',
    windDownTime: userStore.windDownTime ?? '23:00',
  };

  const healthMetrics: HealthMetrics = {
    sleep: {
      durationMinutes: healthStore.sleepData?.durationMinutes ?? 0,
      deepSleepMinutes: healthStore.sleepData?.deepSleepMinutes ?? 0,
      remSleepMinutes: healthStore.sleepData?.remSleepMinutes ?? 0,
      bedtime: healthStore.sleepData?.bedtime,
      wakeTime: healthStore.sleepData?.wakeTime,
    },
    hrv: {
      value: healthStore.hrvData?.value ?? 0,
      baseline30d: healthStore.hrvData?.baseline30d ?? 0,
    },
    activity: {
      steps: healthStore.activityData?.steps ?? 0,
    },
  };

  return {
    user,
    healthMetrics,
    weather,
    tempoScore: healthStore.tempoScore ?? undefined,
    locale: 'ja',
  };
};

/**
 * HealthKitデータからHealthMetricsに変換
 */
export const convertHealthKitData = (
  sleepSamples: unknown[],
  hrvSamples: unknown[],
  stepSamples: unknown[]
): HealthMetrics => {
  // HealthKitデータの変換ロジック
  // 実際の実装はHealthKit連携の詳細に依存

  const sleep = parseSleepData(sleepSamples);
  const hrv = parseHrvData(hrvSamples);
  const activity = parseActivityData(stepSamples);

  return { sleep, hrv, activity };
};

const parseSleepData = (samples: unknown[]): HealthMetrics['sleep'] => {
  // 睡眠データのパース（プレースホルダー）
  // 実際のHealthKit統合時に実装
  return {
    durationMinutes: 0,
    deepSleepMinutes: 0,
    remSleepMinutes: 0,
  };
};

const parseHrvData = (samples: unknown[]): HealthMetrics['hrv'] => {
  // HRVデータのパース（プレースホルダー）
  return {
    value: 0,
    baseline30d: 0,
  };
};

const parseActivityData = (samples: unknown[]): HealthMetrics['activity'] => {
  // 歩数データのパース（プレースホルダー）
  return {
    steps: 0,
  };
};
```

---

## Task 8.4: データフェッチフック

### `app/src/hooks/useAdvice.ts`

```typescript
import { useCallback, useState } from 'react';
import { apiClient } from '@/api/client';
import { buildAdviceRequest } from '@/api/helpers/adviceRequestBuilder';
import type { AdviceResponse, WeatherData } from '@/api/types';
import { useHealthStore } from '@/stores/healthStore';
import { useInsightStore } from '@/stores/insightStore';
import { useUserStore } from '@/stores/userStore';

interface UseAdviceReturn {
  isLoading: boolean;
  error: string | null;
  fetchAdvice: (weather: WeatherData) => Promise<void>;
  refresh: () => Promise<void>;
}

/**
 * AIアドバイス取得フック
 */
export const useAdvice = (): UseAdviceReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastWeather, setLastWeather] = useState<WeatherData | null>(null);

  const healthStore = useHealthStore((state) => ({
    sleepData: state.sleepData,
    hrvData: state.hrvData,
    activityData: state.activityData,
    tempoScore: state.tempoScore,
    setTempoScore: state.setTempoScore,
  }));

  const userStore = useUserStore((state) => ({
    goals: state.goals,
    wakeUpTime: state.wakeUpTime,
    windDownTime: state.windDownTime,
  }));

  const setInsightData = useInsightStore((state) => state.setAdviceData);

  const fetchAdvice = useCallback(async (weather: WeatherData): Promise<void> => {
    setIsLoading(true);
    setError(null);
    setLastWeather(weather);

    try {
      const request = buildAdviceRequest({
        healthStore,
        userStore,
        weather,
      });

      const response = await apiClient.generateAdvice(request);

      if (response.success) {
        const data = response.data;

        // Storeに保存
        healthStore.setTempoScore(data.tempoScore);
        setInsightData({
          aiMessage: data.message,
          todayOneThing: data.todayOneThing,
          relatedInsight: data.relatedInsight,
          metricInsights: data.metricInsights,
        });
      } else {
        setError(response.error.message ?? 'Failed to fetch advice');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  }, [healthStore, userStore, setInsightData]);

  const refresh = useCallback(async (): Promise<void> => {
    if (lastWeather) {
      await fetchAdvice(lastWeather);
    }
  }, [lastWeather, fetchAdvice]);

  return {
    isLoading,
    error,
    fetchAdvice,
    refresh,
  };
};
```

### `app/src/hooks/useWeather.ts`

```typescript
import { useCallback, useState } from 'react';
import * as Location from 'expo-location';
import { apiClient } from '@/api/client';
import type { WeatherResponse } from '@/api/types';
import { useHealthStore } from '@/stores/healthStore';

interface UseWeatherReturn {
  isLoading: boolean;
  error: string | null;
  weather: WeatherResponse | null;
  fetchWeather: () => Promise<WeatherResponse | null>;
}

/**
 * 天気情報取得フック
 */
export const useWeather = (): UseWeatherReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [weather, setWeather] = useState<WeatherResponse | null>(null);

  const setSunTimes = useHealthStore((state) => state.setSunTimes);

  const fetchWeather = useCallback(async (): Promise<WeatherResponse | null> => {
    setIsLoading(true);
    setError(null);

    try {
      // 位置情報の取得
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission denied');
        return null;
      }

      const location = await Location.getCurrentPositionAsync({});
      const { latitude, longitude } = location.coords;

      // 天気APIの呼び出し
      const response = await apiClient.getWeather(latitude, longitude);

      if (response.success) {
        setWeather(response.data);
        setSunTimes(response.data.sunrise, response.data.sunset);
        return response.data;
      } else {
        setError(response.error.message ?? 'Failed to fetch weather');
        return null;
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
      return null;
    } finally {
      setIsLoading(false);
    }
  }, [setSunTimes]);

  return {
    isLoading,
    error,
    weather,
    fetchWeather,
  };
};
```

---

## Task 8.5: データ取得統合フック

### `app/src/hooks/useDailyData.ts`

```typescript
import { useCallback, useEffect, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAdvice } from './useAdvice';
import { useWeather } from './useWeather';
import { useHealthStore } from '@/stores/healthStore';
import type { WeatherData } from '@/api/types';

const CACHE_KEY = '@daily_data_cache';
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24時間

interface CacheData {
  timestamp: number;
  date: string;
}

interface UseDailyDataReturn {
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

/**
 * 日次データ取得統合フック
 */
export const useDailyData = (): UseDailyDataReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { fetchWeather, isLoading: weatherLoading, error: weatherError } = useWeather();
  const { fetchAdvice, isLoading: adviceLoading, error: adviceError } = useAdvice();
  const calculateTempoScore = useHealthStore((state) => state.calculateTempoScore);
  const calculateCircadianPhases = useHealthStore((state) => state.calculateCircadianPhases);

  const getTodayString = (): string => {
    const now = new Date();
    return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
  };

  const shouldRefresh = useCallback(async (): Promise<boolean> => {
    try {
      const cached = await AsyncStorage.getItem(CACHE_KEY);
      if (!cached) return true;

      const data = JSON.parse(cached) as CacheData;
      const today = getTodayString();

      // 日付が変わったらリフレッシュ
      if (data.date !== today) return true;

      // キャッシュが24時間以上経過したらリフレッシュ
      if (Date.now() - data.timestamp > CACHE_DURATION) return true;

      return false;
    } catch {
      return true;
    }
  }, []);

  const saveCache = useCallback(async (): Promise<void> => {
    const data: CacheData = {
      timestamp: Date.now(),
      date: getTodayString(),
    };
    await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(data));
  }, []);

  const loadDailyData = useCallback(async (force = false): Promise<void> => {
    if (!force) {
      const needsRefresh = await shouldRefresh();
      if (!needsRefresh) return;
    }

    setIsLoading(true);
    setError(null);

    try {
      // 1. Tempo Score算出（ローカル）
      calculateTempoScore();

      // 2. Circadian Phases算出（ローカル）
      calculateCircadianPhases();

      // 3. 天気情報取得
      const weather = await fetchWeather();
      if (!weather) {
        throw new Error('Failed to fetch weather');
      }

      // 4. AIアドバイス取得
      const weatherData: WeatherData = {
        temperature: weather.temperature,
        pressure: weather.pressure,
        pressureTrend: weather.pressureTrend,
        sunrise: weather.sunrise,
        sunset: weather.sunset,
        description: weather.description,
        location: weather.location,
      };
      await fetchAdvice(weatherData);

      // 5. キャッシュ保存
      await saveCache();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load daily data');
    } finally {
      setIsLoading(false);
    }
  }, [shouldRefresh, calculateTempoScore, calculateCircadianPhases, fetchWeather, fetchAdvice, saveCache]);

  const refresh = useCallback(async (): Promise<void> => {
    await loadDailyData(true);
  }, [loadDailyData]);

  // 初回ロード
  useEffect(() => {
    loadDailyData();
  }, [loadDailyData]);

  return {
    isLoading: isLoading || weatherLoading || adviceLoading,
    error: error ?? weatherError ?? adviceError,
    refresh,
  };
};
```

---

## Task 8.6: Today画面へのフック統合

### `app/app/(main)/index.tsx` の更新（一部）

```typescript
import { useDailyData } from '@/hooks/useDailyData';

// ... 既存のimport

export default function TodayScreen(): React.ReactElement {
  const { isLoading, error, refresh } = useDailyData();

  // ... 既存のStore使用

  // Pull-to-refresh
  const handleRefresh = useCallback(async (): Promise<void> => {
    await refresh();
  }, [refresh]);

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={isLoading}
            onRefresh={handleRefresh}
            tintColor={Colors.indigo[500]}
          />
        }
      >
        {/* エラー表示 */}
        {error && (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>{error}</Text>
            <Pressable onPress={handleRefresh}>
              <Text style={styles.retryText}>{t('error.retry')}</Text>
            </Pressable>
          </View>
        )}

        {/* ... 既存のコンテンツ */}
      </ScrollView>
    </SafeAreaView>
  );
}

// ... 追加スタイル
const additionalStyles = StyleSheet.create({
  errorContainer: {
    backgroundColor: Colors.coral[50],
    padding: Spacing.md,
    borderRadius: 12,
    marginBottom: Spacing.md,
    alignItems: 'center',
  },
  errorText: {
    ...Typography.body,
    color: Colors.coral[600],
    textAlign: 'center',
  },
  retryText: {
    ...Typography.bodyMedium,
    color: Colors.indigo[500],
    marginTop: Spacing.sm,
  },
});
```

---

## Task 8.7: インデックスエクスポート

### `app/src/api/index.ts`

```typescript
export * from './types';
export { apiClient } from './client';
export { buildAdviceRequest, convertHealthKitData } from './helpers/adviceRequestBuilder';
```

### `app/src/hooks/index.ts`

```typescript
export { useAdvice } from './useAdvice';
export { useWeather } from './useWeather';
export { useDailyData } from './useDailyData';
```

---

## Phase 8 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト
pnpm test

# 4. ビルド確認（iOS）
pnpm ios --no-dev

# 5. ビルド確認（Android）
pnpm android --no-dev
```

### 動作確認

```
# バックエンドを起動
cd backend && pnpm dev

# 別ターミナルでアプリを起動
cd app && pnpm ios

# 確認項目
- [ ] アプリ起動時にデータが自動取得される
- [ ] Today画面にTempo Scoreが表示される
- [ ] AIメッセージが表示される
- [ ] Today's One Thingが表示される
- [ ] メトリクスカードに値が表示される
- [ ] Pull-to-refreshで再取得される
- [ ] エラー時にエラーメッセージが表示される
- [ ] リトライボタンが動作する
```

### 完了チェックリスト

- [ ] `app/src/api/types.ts` が新形式で作成されている
- [ ] `app/src/api/client.ts` が作成されている
- [ ] `app/src/api/helpers/adviceRequestBuilder.ts` が作成されている
- [ ] `app/src/hooks/useAdvice.ts` が作成されている
- [ ] `app/src/hooks/useWeather.ts` が作成されている
- [ ] `app/src/hooks/useDailyData.ts` が作成されている
- [ ] Today画面がフックと統合されている
- [ ] エラーハンドリングが実装されている
- [ ] Pull-to-refreshが実装されている
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` でエラーなし**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 8 の全てのチェックが完了したら、`09-phase9-testing.md` に進む。
