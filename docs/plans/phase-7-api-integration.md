# Phase 7: API 連携実装

## 概要

| 項目 | 内容 |
|------|------|
| **目的** | アプリからバックエンド API を呼び出し、モックデータを実データに置き換え |
| **期間目安** | 2-3日 |
| **依存** | Phase 6（バックエンド稼働） |
| **成果物** | 天気・AI アドバイスが実データで動作するアプリ |

---

## 現状分析

### API クライアント実装状況

| 項目 | 状態 | ファイル |
|------|------|----------|
| API クライアント | ✅ 実装済み | `app/src/api/client.ts` |
| 型定義 | ✅ 実装済み | `app/src/api/types.ts` |
| 設定 | ✅ 実装済み | `app/src/api/config.ts` |
| healthStore 連携 | ⚠️ モック使用中 | `app/src/stores/healthStore.ts` |
| insightStore 連携 | ⚠️ モック使用中 | `app/src/stores/insightStore.ts` |

### 現在の API クライアント

```typescript
// app/src/api/client.ts
export const apiClient = {
  advice: {
    generate: (request: AdviceRequest): Promise<AdviceResponse> => { ... }
  },
  weather: {
    get: (request: WeatherRequest): Promise<WeatherResponse> => { ... }
  },
  health: {
    check: (): Promise<HealthCheckResponse> => { ... }
  }
}
```

---

## タスク詳細

### 7.1 環境変数設定

#### 7.1.1 `.env.local` 作成

```bash
cd app
touch .env.local
```

```env
# app/.env.local
EXPO_PUBLIC_API_URL=https://tempo-ai-api.xxx.workers.dev
```

**注意**: `.env.local` は `.gitignore` に含まれているため、リポジトリにはコミットされない。

#### 7.1.2 環境変数の読み込み確認

`app/src/api/config.ts` で正しく読み込まれることを確認:

```typescript
// 既存の実装
export const API_BASE_URL =
  process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000'
```

#### 7.1.3 開発環境での切り替え

| 環境 | API_URL |
|------|---------|
| ローカル開発 | `http://localhost:8787` |
| Simulator + 本番API | `https://tempo-ai-api.xxx.workers.dev` |
| 実機 | `https://tempo-ai-api.xxx.workers.dev` |

---

### 7.2 天気 API 連携

#### 7.2.1 現状のモック実装

```typescript
// app/src/stores/healthStore.ts
fetchWeather: async (latitude: number, longitude: number) => {
  set({ isLoadingWeather: true, weatherError: null })
  try {
    // TODO: Replace with actual API call
    await delay(300)
    set({
      weather: MOCK_WEATHER,
      // ...
    })
  } catch (error) {
    // ...
  }
}
```

#### 7.2.2 実装変更

```typescript
// app/src/stores/healthStore.ts
import { apiClient } from '@/api/client'

fetchWeather: async (latitude: number, longitude: number) => {
  set({ isLoadingWeather: true, weatherError: null })
  try {
    const response = await apiClient.weather.get({ latitude, longitude })

    if (!response.success) {
      throw new Error(response.error || 'Failed to fetch weather')
    }

    // API レスポンスを SimpleWeatherData に変換
    const weather: SimpleWeatherData = {
      temperature: response.data.temperature,
      humidity: response.data.humidity,
      pressure: response.data.pressure,
      weatherCode: response.data.weatherCode,
      pressureTrend: calculatePressureTrend(response.data.pressure), // 別途実装
    }

    set({
      weather,
      lastWeatherUpdate: new Date(),
      isLoadingWeather: false,
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error'
    set({
      weatherError: message,
      isLoadingWeather: false,
    })
    console.error('Weather fetch error:', error)
  }
}
```

#### 7.2.3 気圧トレンド計算

バックエンド API は現在の気圧のみ返すため、トレンドはアプリ側で計算:

```typescript
// app/src/domain/services/weatherService.ts
const PRESSURE_HISTORY_KEY = 'pressure_history'

interface PressureRecord {
  value: number
  timestamp: number
}

export const calculatePressureTrend = async (
  currentPressure: number
): Promise<'rising' | 'falling' | 'stable'> => {
  // 過去の気圧履歴を取得
  const history = await getPressureHistory()

  // 履歴に追加
  const now = Date.now()
  history.push({ value: currentPressure, timestamp: now })

  // 24時間以内のデータのみ保持
  const recentHistory = history.filter(
    (r) => now - r.timestamp < 24 * 60 * 60 * 1000
  )
  await savePressureHistory(recentHistory)

  // 3時間前との比較
  const threeHoursAgo = now - 3 * 60 * 60 * 1000
  const oldRecord = recentHistory.find((r) => r.timestamp <= threeHoursAgo)

  if (!oldRecord) return 'stable'

  const diff = currentPressure - oldRecord.value
  if (diff > 2) return 'rising'
  if (diff < -2) return 'falling'
  return 'stable'
}
```

---

### 7.3 AI アドバイス API 連携

#### 7.3.1 現状のモック実装

```typescript
// app/src/stores/insightStore.ts
generateDailyInsight: async (nickname: string) => {
  set({ isGeneratingInsight: true, generationPhase: 0 })
  try {
    // 労働幻想フェーズ表示
    for (let phase = 0; phase < 3; phase++) {
      set({ generationPhase: phase })
      await delay(800)
    }

    // TODO: Replace with actual API call
    await delay(500)
    const insight = MOCK_AI_INSIGHT_FULL(nickname)
    // ...
  }
}
```

#### 7.3.2 リクエスト構築ヘルパー

```typescript
// app/src/api/helpers/adviceRequestBuilder.ts
import { AdviceRequest } from '@/api/types'
import { useUserStore } from '@/stores/userStore'
import { useHealthStore } from '@/stores/healthStore'

export const buildAdviceRequest = (): AdviceRequest | null => {
  const userState = useUserStore.getState()
  const healthState = useHealthStore.getState()

  const { profile } = userState
  if (!profile) return null

  const {
    sleepMetrics,
    hrvMetrics,
    activityMetrics,
    dailyScores,
    rhythmAnalysis,
    weather,
  } = healthState

  // 現在時刻情報
  const now = new Date()
  const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
  const dayOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][now.getDay()]

  return {
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
      sleep: sleepMetrics ? {
        bedtime: sleepMetrics.bedtime.toISOString(),
        wakeTime: sleepMetrics.wakeTime.toISOString(),
        durationHours: sleepMetrics.durationMinutes / 60,
        deepSleepMinutes: sleepMetrics.deepSleepMinutes,
        remSleepMinutes: sleepMetrics.remSleepMinutes,
        deepSleepRatio: sleepMetrics.deepSleepMinutes / sleepMetrics.durationMinutes,
      } : undefined,
      hrv: hrvMetrics ? {
        value: hrvMetrics.value,
        baseline30d: hrvMetrics.baseline30d,
        deviationPercent: ((hrvMetrics.value - hrvMetrics.baseline30d) / hrvMetrics.baseline30d) * 100,
      } : undefined,
      activity: activityMetrics ? {
        stepsYesterday: activityMetrics.stepsYesterday,
        activeMinutesYesterday: activityMetrics.activeMinutesYesterday,
      } : undefined,
      scores: dailyScores || {
        autonomic: 0,
        sleep: 0,
        rhythm: 0,
        activity: 0,
      },
      rhythmAnalysis: rhythmAnalysis || {
        bedtimeStddevMinutes: 0,
        wakeTimeStddevMinutes: 0,
        consecutiveStableDays: 0,
        status: 'unknown' as const,
      },
    },
    location: {
      latitude: profile.location?.latitude || 35.6762,
      longitude: profile.location?.longitude || 139.6503,
      city: profile.location?.city || '東京',
    },
    context: {
      currentTime,
      dayOfWeek,
      mood: healthState.todayMood,
      todayMode: healthState.todayMode || 'normal',
    },
    weather: weather ? {
      temperature: weather.temperature,
      humidity: weather.humidity,
      pressure: weather.pressure,
      weatherCode: weather.weatherCode,
      uvIndexMax: 0, // TODO: API から取得
    } : undefined,
  }
}
```

#### 7.3.3 実装変更

```typescript
// app/src/stores/insightStore.ts
import { apiClient } from '@/api/client'
import { buildAdviceRequest } from '@/api/helpers/adviceRequestBuilder'

generateDailyInsight: async (nickname: string) => {
  set({ isGeneratingInsight: true, generationPhase: 0 })

  try {
    // 労働幻想フェーズ表示（並行して API 呼び出し）
    const advicePromise = (async () => {
      const request = buildAdviceRequest()
      if (!request) {
        throw new Error('Failed to build advice request')
      }
      return apiClient.advice.generate(request)
    })()

    // フェーズ表示
    for (let phase = 0; phase < 3; phase++) {
      set({ generationPhase: phase })
      await delay(800)
    }

    // API レスポンス待機
    const response = await advicePromise

    if (!response.success) {
      throw new Error(response.error || 'Failed to generate advice')
    }

    const { summary, fullInsight, recommendedAction } = response.data

    // DailyAdvice 形式に変換
    const dailyAdvice: DailyAdvice = {
      id: `advice-${Date.now()}`,
      date: new Date(),
      summary,
      fullInsight,
      recommendedAction: {
        type: recommendedAction.type,
        message: recommendedAction.message,
      },
      generatedAt: new Date(),
    }

    set({
      dailyAdvice,
      shortGreeting: summary,
      recommendedAction: dailyAdvice.recommendedAction,
      isGeneratingInsight: false,
      generationPhase: 0,
      lastInsightUpdate: new Date(),
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error'
    set({
      insightError: message,
      isGeneratingInsight: false,
      generationPhase: 0,
    })
    console.error('Insight generation error:', error)
  }
}
```

---

### 7.4 オフライン対応

#### 7.4.1 ネットワーク状態検出

```typescript
// app/src/hooks/useNetworkStatus.ts
import { useEffect, useState } from 'react'
import NetInfo, { NetInfoState } from '@react-native-community/netinfo'

export const useNetworkStatus = (): {
  isConnected: boolean
  isInternetReachable: boolean | null
} => {
  const [state, setState] = useState<NetInfoState | null>(null)

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(setState)
    return () => unsubscribe()
  }, [])

  return {
    isConnected: state?.isConnected ?? true,
    isInternetReachable: state?.isInternetReachable ?? null,
  }
}
```

**パッケージ追加**:
```bash
pnpm add @react-native-community/netinfo
```

#### 7.4.2 キャッシュ戦略

Zustand の persist middleware で自動的にキャッシュされるが、明示的なキャッシュ制御を追加:

```typescript
// app/src/stores/healthStore.ts
interface HealthState {
  // ... 既存のプロパティ

  // キャッシュ制御
  lastWeatherUpdate: Date | null
  lastMetricsUpdate: Date | null

  // オフライン時のフォールバック
  getCachedWeather: () => SimpleWeatherData | null
}

// セレクター
export const selectIsWeatherStale = (state: HealthState): boolean => {
  if (!state.lastWeatherUpdate) return true
  const hoursSinceUpdate =
    (Date.now() - state.lastWeatherUpdate.getTime()) / (1000 * 60 * 60)
  return hoursSinceUpdate > 1 // 1時間以上古い
}
```

#### 7.4.3 リトライロジック

```typescript
// app/src/api/utils/retry.ts
export const withRetry = async <T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> => {
  let lastError: Error | null = null

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error))

      if (attempt < maxRetries - 1) {
        await new Promise((resolve) => setTimeout(resolve, delay * (attempt + 1)))
      }
    }
  }

  throw lastError
}
```

**使用例**:
```typescript
const response = await withRetry(
  () => apiClient.weather.get({ latitude, longitude }),
  3,
  1000
)
```

---

### 7.5 テスト

#### 7.5.1 手動テスト手順

1. **ローカル API 確認**
   ```bash
   cd backend && npm run dev
   ```
   - `http://localhost:8787/api/health` にアクセス

2. **アプリから API 呼び出し**
   - `.env.local` を設定
   - `pnpm start` でアプリ起動
   - Simulator で動作確認

3. **本番 API 確認**
   - `.env.local` の URL を本番に変更
   - 同様に動作確認

#### 7.5.2 確認項目

| 項目 | 確認内容 |
|------|----------|
| 天気取得 | 位置情報から天気データ取得 |
| AI アドバイス | プロファイル + ヘルスデータから生成 |
| エラー表示 | API エラー時の UI 表示 |
| オフライン | ネットワーク切断時のキャッシュ表示 |
| ローディング | 労働幻想 UI の表示 |

---

## チェックリスト

### 環境設定

- [ ] `app/.env.local` 作成
- [ ] API URL 設定確認

### 天気 API

- [ ] `healthStore.fetchWeather()` を実 API 呼び出しに変更
- [ ] 気圧トレンド計算実装
- [ ] エラーハンドリング確認

### AI アドバイス API

- [ ] `buildAdviceRequest()` ヘルパー作成
- [ ] `insightStore.generateDailyInsight()` を実 API 呼び出しに変更
- [ ] 労働幻想 UI との連携確認
- [ ] エラーハンドリング確認

### オフライン対応

- [ ] `@react-native-community/netinfo` 追加
- [ ] `useNetworkStatus` フック作成
- [ ] リトライロジック実装
- [ ] キャッシュ表示確認

### テスト

- [ ] ローカル API での動作確認
- [ ] 本番 API での動作確認
- [ ] エラーケーステスト
- [ ] オフラインテスト

---

## 完了条件

1. Simulator でアプリを起動し、天気データが本番 API から取得される
2. AI アドバイスが本番 API から生成される
3. API エラー時に適切なエラー表示がされる
4. オフライン時にキャッシュデータが表示される

---

## 次のフェーズへ

Phase 7 完了後、Phase 8（HealthKit 連携）に進む。

現時点ではモックの健康データを使用しているが、Phase 8 で実際の HealthKit データに置き換える。
