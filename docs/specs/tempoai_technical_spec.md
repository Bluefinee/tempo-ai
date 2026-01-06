# TempoAI 技術仕様書

**バージョン**: 7.0
**最終更新日**: 2026年1月6日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [tempoai_product_spec.md](./tempoai_product_spec.md) | プロダクト仕様 |
| [tempoai_metrics_spec.md](./tempoai_metrics_spec.md) | スコア算出アルゴリズム |
| [tempoai_ai_prompt_spec.md](./tempoai_ai_prompt_spec.md) | AIプロンプト仕様 |
| [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) | 科学的根拠 |

---

## 1. 技術スタック

| レイヤー | 技術 | バージョン |
|---------|------|-----------|
| Mobile | React Native (Expo) | SDK 54 |
| Mobile | TypeScript | 5.x |
| Mobile | expo-router | 4.x |
| State | Zustand | 5.x |
| Storage | AsyncStorage | - |
| Location | expo-location | 18.x |
| Backend | Cloudflare Workers | - |
| Backend | Hono | 4.x |
| AI | Claude Sonnet 4 | claude-sonnet-4-20250514 |
| Weather | Open-Meteo API | Free tier |

### 将来のヘルスデータ統合

| プラットフォーム | ライブラリ | 状態 |
|----------------|-----------|------|
| iOS | react-native-health (HealthKit) | 計画中 |
| Android | react-native-health-connect | 計画中 |

---

## 2. アーキテクチャ

### 設計原則

- **データベースレス**: ヘルスケアデータは端末内のみで処理
- **ドメイン駆動**: スコアリング等のビジネスロジックはドメインモデルに凝集
- **テスト容易性**: 純粋関数・依存性注入を前提
- **クロスプラットフォーム**: iOS/Android 両対応

### レイヤー構成

```
┌─────────────────────────────────────────────────────┐
│ Presentation (React Native Screens/Components)      │
├─────────────────────────────────────────────────────┤
│ Application (Zustand Stores / Hooks)                │
├─────────────────────────────────────────────────────┤
│ Domain (Models / Services) ← ビジネスロジック集約    │
├─────────────────────────────────────────────────────┤
│ Infrastructure (Health Repo / Location / API)       │
└─────────────────────────────────────────────────────┘
```

### データフロー

```
HealthRepository → Domain Models → AdviceRequest → API → DailyAdvice
                        ↓
                  Score (値オブジェクト)
                  HealthMetrics (集約)
```

---

## 3. モバイルアプリ設計

### 3.1 ディレクトリ構造

```
app/                          # Expo React Native
├── app/                      # expo-router ページ
│   ├── (onboarding)/        # オンボーディングフロー
│   │   ├── index.tsx        # Welcome
│   │   ├── healthkit.tsx
│   │   ├── nickname.tsx
│   │   ├── basic-info.tsx
│   │   ├── chronotype.tsx
│   │   ├── bedtime.tsx
│   │   ├── lifestyle.tsx
│   │   ├── location.tsx
│   │   └── complete.tsx
│   ├── (main)/              # メインタブ
│   │   ├── _layout.tsx      # Tab Navigator
│   │   ├── index.tsx        # Home
│   │   ├── analytics.tsx
│   │   └── settings.tsx
│   ├── insight-detail.tsx   # Modal
│   ├── index.tsx            # Root redirect
│   └── _layout.tsx          # Root layout
├── src/
│   ├── components/          # 共通 UI コンポーネント
│   │   ├── Card.tsx
│   │   ├── PrimaryButton.tsx
│   │   ├── SecondaryButton.tsx
│   │   ├── ProgressBar.tsx
│   │   ├── ScoreGauge.tsx
│   │   ├── MoodSelector.tsx
│   │   ├── LoadingView.tsx
│   │   └── CircadianClock.tsx
│   ├── domain/
│   │   ├── models/          # TypeScript 型定義
│   │   │   ├── score.ts
│   │   │   ├── healthMetrics.ts
│   │   │   ├── userProfile.ts
│   │   │   ├── advice.ts
│   │   │   ├── weather.ts
│   │   │   └── index.ts
│   │   └── services/        # スコア計算ロジック
│   │       ├── sleepScoreCalculator.ts
│   │       ├── autonomicScoreCalculator.ts
│   │       ├── rhythmScoreCalculator.ts
│   │       ├── activityScoreCalculator.ts
│   │       └── scoreCalculator.ts
│   ├── stores/              # Zustand ストア
│   │   ├── userStore.ts
│   │   ├── healthStore.ts
│   │   ├── insightStore.ts
│   │   └── index.ts
│   ├── infrastructure/      # ネイティブ機能抽象化
│   │   ├── health/
│   │   │   ├── HealthRepository.ts
│   │   │   └── MockHealthRepository.ts
│   │   └── location/
│   │       ├── LocationRepository.ts
│   │       ├── ExpoLocationRepository.ts
│   │       └── MockLocationRepository.ts
│   ├── api/                 # API クライアント
│   │   ├── config.ts
│   │   ├── types.ts
│   │   └── client.ts
│   ├── theme/               # デザイントークン
│   │   ├── colors.ts
│   │   ├── spacing.ts
│   │   └── typography.ts
│   ├── constants/           # 定数・モックデータ
│   │   └── mockData.ts
│   └── utils/               # ユーティリティ
├── assets/
├── app.json
└── package.json
```

### 3.2 ドメインモデル

#### Score（値オブジェクト）

スコアとその評価を内包するリッチな値オブジェクト。

```typescript
export interface Score {
  value: number;  // 0-100
  status: ScoreStatus;
}

export type ScoreStatus =
  | 'excellent'  // 80-100: 絶好調
  | 'good'       // 60-79: 良好
  | 'fair'       // 40-59: 普通
  | 'poor'       // 20-39: 要休息
  | 'rest';      // 0-19: 休養優先

export const createScore = (value: number): Score => {
  const clampedValue = Math.max(0, Math.min(100, value));
  return {
    value: clampedValue,
    status: getScoreStatus(clampedValue),
  };
};

export const getScoreStatus = (value: number): ScoreStatus => {
  if (value >= 80) return 'excellent';
  if (value >= 60) return 'good';
  if (value >= 40) return 'fair';
  if (value >= 20) return 'poor';
  return 'rest';
};
```

#### HealthMetrics（エンティティ）

ヘルスデータリポジトリから取得した生データを保持。

```typescript
export interface HealthMetrics {
  date: Date;
  sleep?: SleepMetrics;
  hrv?: HRVMetrics;
  activity?: ActivityMetrics;
  auxiliary?: AuxiliaryMetrics;
}

export interface SleepMetrics {
  bedtime: Date;
  wakeTime: Date;
  durationMinutes: number;
  deepSleepMinutes: number;
  remSleepMinutes: number;
}

export interface HRVMetrics {
  value: number;           // ms
  baseline30d: number;
}

export interface ActivityMetrics {
  stepsYesterday: number;
  activeMinutesYesterday: number;
}

export interface AuxiliaryMetrics {
  daylight?: DaylightMetrics;
  wristTemperature?: WristTemperatureMetrics;
}
```

#### UserProfile（エンティティ）

```typescript
export interface UserProfile {
  id: string;
  nickname: string;
  age: number;
  gender: Gender;
  heightCm?: number;
  weightKg?: number;
  chronotype: Chronotype;
  targetBedtime: string;  // "HH:mm" format
  occupation?: Occupation;
  exerciseFrequency?: ExerciseFrequency;
  alcoholFrequency?: AlcoholFrequency;
  calibrationDaysCompleted: number;
  createdAt: Date;
  updatedAt: Date;
}

export type Gender = 'male' | 'female' | 'other' | 'preferNotToSay';
export type Chronotype = 'morning' | 'intermediate' | 'evening';
export type Occupation = 'deskWork' | 'standingWork' | 'physicalWork' | 'hybrid' | 'other';
export type ExerciseFrequency = 'rarely' | 'onceWeek' | 'twiceWeek' | 'threeOrMore' | 'daily';
export type AlcoholFrequency = 'never' | 'rarely' | 'weekly' | 'daily';
```

### 3.3 ドメインサービス

#### ScoreCalculator

純粋関数でスコアを算出。テスト容易性を最大化。

```typescript
// sleepScoreCalculator.ts
export const calculateSleepScore = (
  sleep: SleepMetrics,
  targetHours: number = 7.5
): Score => {
  const durationScore = calculateDurationScore(sleep.durationMinutes / 60, targetHours);
  const deepSleepRatio = sleep.deepSleepMinutes / sleep.durationMinutes;
  const deepScore = calculateDeepSleepScore(deepSleepRatio);

  const rawScore = durationScore * 0.5 + deepScore * 0.5;
  return createScore(Math.round(rawScore));
};

// autonomicScoreCalculator.ts
export const calculateAutonomicScore = (
  hrv: HRVMetrics,
  sleep?: SleepMetrics
): Score => {
  const baseScore = 70;
  const deviation = hrv.baseline30d > 0
    ? ((hrv.value - hrv.baseline30d) / hrv.baseline30d) * 100
    : 0;

  let rawScore = baseScore + deviation;

  // 深い睡眠が不足している場合は減点
  if (sleep) {
    const deepSleepRatio = sleep.deepSleepMinutes / sleep.durationMinutes;
    if (deepSleepRatio < 0.15) {
      rawScore -= 5;
    }
  }

  return createScore(Math.round(rawScore));
};

// rhythmScoreCalculator.ts
export const calculateRhythmScore = (
  bedtimeStddevMinutes: number,
  wakeTimeStddevMinutes: number,
  wristTemperature?: WristTemperatureMetrics
): Score => {
  const bedtimeScore = calculateConsistencyScore(bedtimeStddevMinutes);
  const wakeScore = calculateConsistencyScore(wakeTimeStddevMinutes);

  let rawScore: number;
  if (wristTemperature) {
    const tempScore = calculateTemperatureScore(wristTemperature);
    rawScore = bedtimeScore * 0.35 + wakeScore * 0.35 + tempScore * 0.30;
  } else {
    rawScore = bedtimeScore * 0.5 + wakeScore * 0.5;
  }

  return createScore(Math.round(rawScore));
};
```

### 3.4 状態管理

#### Zustand ストア構成

```typescript
// userStore.ts
interface UserState {
  profile: UserProfile | null;
  isOnboardingComplete: boolean;
  draftProfile: Partial<UserProfile>;
  setProfile: (profile: UserProfile) => void;
  completeOnboarding: () => void;
  setDraftNickname: (nickname: string) => void;
  // ...
}

// healthStore.ts
interface HealthState {
  healthMetrics: HealthMetrics | null;
  sleepScore: Score | null;
  autonomicScore: Score | null;
  rhythmScore: Score | null;
  activityScore: Score | null;
  weather: SimpleWeatherData | null;
  calculateScores: () => void;
  // ...
}

// insightStore.ts
interface InsightState {
  dailyAdvice: DailyAdvice | null;
  isGenerating: boolean;
  laborIllusionStep: number;
  quickActions: QuickAction[];
  generateAdvice: () => Promise<void>;
  submitFeedback: (isPositive: boolean) => void;
  // ...
}
```

### 3.5 インフラストラクチャ

#### HealthRepository

```typescript
export interface HealthRepository {
  requestAuthorization(): Promise<HealthAuthorizationStatus>;
  fetchTodayMetrics(): Promise<HealthMetrics>;
  fetchSleepHistory(days: number): Promise<SleepMetrics[]>;
  fetchHRVBaseline(days: number): Promise<number>;
}

export type HealthAuthorizationStatus =
  | 'authorized'
  | 'denied'
  | 'notDetermined'
  | 'restricted';

// MockHealthRepository - モックデータを返す実装
export class MockHealthRepository implements HealthRepository {
  async requestAuthorization(): Promise<HealthAuthorizationStatus> {
    return 'authorized';
  }

  async fetchTodayMetrics(): Promise<HealthMetrics> {
    return MOCK_HEALTH_METRICS;
  }
  // ...
}
```

#### LocationRepository

```typescript
export interface LocationRepository {
  requestPermission(): Promise<LocationPermissionStatus>;
  getCurrentLocation(): Promise<LocationData>;
  reverseGeocode(coords: Coordinates): Promise<string>;
}

export type LocationPermissionStatus =
  | 'granted'
  | 'denied'
  | 'undetermined';

// ExpoLocationRepository - expo-location を使用した実装
export class ExpoLocationRepository implements LocationRepository {
  async requestPermission(): Promise<LocationPermissionStatus> {
    const { status } = await Location.requestForegroundPermissionsAsync();
    // ...
  }

  async getCurrentLocation(): Promise<LocationData> {
    const location = await Location.getCurrentPositionAsync({});
    // ...
  }
}
```

---

## 4. Backend設計

### 4.1 構成

```
backend/
├── src/
│   ├── index.ts
│   ├── routes/
│   │   ├── advice.ts
│   │   ├── weather.ts
│   │   └── health.ts
│   ├── services/
│   │   ├── claude.ts
│   │   └── weather.ts
│   └── types/
│       └── index.ts
├── wrangler.toml
└── package.json
```

### 4.2 API

#### POST /api/advice

```typescript
interface AdviceRequest {
  user: {
    nickname: string;
    age: number;
    gender: Gender;
    chronotype: Chronotype;
    targetBedtime: string;
  };
  healthMetrics: {
    sleep: {
      bedtime: string;      // ISO8601
      wakeTime: string;     // ISO8601
      durationMinutes: number;
      deepSleepMinutes: number;
      remSleepMinutes: number;
    };
    hrv: {
      value: number;
      baseline30d: number;
    };
    activity: {
      stepsYesterday: number;
      activeMinutesYesterday: number;
    };
  };
  rhythmAnalysis: {
    status: 'stable' | 'recovering' | 'unstable';
    consecutiveStableDays: number;
    bedtimeStddevMinutes: number;
    wakeTimeStddevMinutes: number;
  };
  weather?: {
    temp: number;
    pressure: number;
    pressureTrend: 'up' | 'stable' | 'down';
  };
  mood?: Mood;
  todayMode?: TodayMode;
}

interface AdviceResponse {
  success: boolean;
  data?: AIInsightFull;
  error?: string;
}
```

#### GET /api/weather

```typescript
interface WeatherRequest {
  latitude: number;
  longitude: number;
}

interface WeatherResponse {
  success: boolean;
  data?: SimpleWeatherData;
  error?: string;
}
```

### 4.3 外部API（Open-Meteo）

無料で10,000リクエスト/日まで利用可能。

```typescript
// Weather
const weatherUrl = new URL("https://api.open-meteo.com/v1/forecast");
weatherUrl.searchParams.set("latitude", lat.toString());
weatherUrl.searchParams.set("longitude", lon.toString());
weatherUrl.searchParams.set("current", "temperature_2m,relative_humidity_2m,pressure_msl,weather_code");
weatherUrl.searchParams.set("daily", "uv_index_max,sunrise,sunset");
weatherUrl.searchParams.set("timezone", "auto");

// Air Quality
const aqUrl = new URL("https://air-quality-api.open-meteo.com/v1/air-quality");
aqUrl.searchParams.set("latitude", lat.toString());
aqUrl.searchParams.set("longitude", lon.toString());
aqUrl.searchParams.set("current", "pm2_5,us_aqi");
```

---

## 5. オンボーディング

### 5.1 フロー

| ステップ | 情報 | 必須 | 備考 |
|---------|------|------|------|
| 1 | Welcome | - | アプリ紹介 |
| 2 | HealthKit説明 | ○ | 権限リクエスト画面 |
| 3 | ニックネーム | ○ | |
| 4 | 年齢・性別・体重・身長 | ○ | 1画面に統合 |
| 5 | クロノタイプ | ○ | 将来的にHealthKitから自動推定 |
| 6 | 目標就寝時刻 | ○ | 将来的にHealthKitから自動提案 |
| 7 | 職業・運動頻度・飲酒頻度 | - | 任意、1画面に統合 |
| 8 | 位置情報認証 | ○ | |
| 9 | 完了 | - | メイン画面へ |

### 5.2 将来実装: HealthKitからの自動推定ロジック

#### クロノタイプ推定（MSFsc: Mid-Sleep on Free days, Sleep-corrected）

```typescript
export const estimateChronotype = (
  sleepHistory: SleepMetrics[]
): { chronotype: Chronotype; confidence: number } => {
  if (sleepHistory.length < 7) {
    return { chronotype: 'intermediate', confidence: 0.3 };
  }

  // 睡眠中間点（MSF）を計算
  const midSleepTimes = sleepHistory.map(sleep => {
    const bedtimeMinutes = getMinutesSinceMidnight(sleep.bedtime);
    const durationMinutes = sleep.durationMinutes;
    return bedtimeMinutes + (durationMinutes / 2);
  });

  const avgMidSleep = midSleepTimes.reduce((a, b) => a + b, 0) / midSleepTimes.length;
  const midSleepHour = avgMidSleep / 60;

  // クロノタイプ判定
  let chronotype: Chronotype;
  if (midSleepHour < 3.0) {
    chronotype = 'morning';      // 〜3:00 → 朝型
  } else if (midSleepHour < 5.0) {
    chronotype = 'intermediate'; // 3:00-5:00 → 中間型
  } else {
    chronotype = 'evening';      // 5:00〜 → 夜型
  }

  const confidence = Math.min(1.0, sleepHistory.length / 30);
  return { chronotype, confidence };
};
```

---

## 6. キャリブレーション期間

### 6.1 概要

初期7日間はスコアの精度が低いため、スコア表示を控えAIコメント主体で運用。

### 6.2 状態管理

```typescript
interface CalibrationState {
  startDate: Date;
  daysCompleted: number;
  isComplete: boolean;
}

const REQUIRED_DAYS = 7;

export const updateCalibrationProgress = (
  state: CalibrationState,
  healthDataDays: number
): CalibrationState => {
  const daysCompleted = Math.min(healthDataDays, REQUIRED_DAYS);
  return {
    ...state,
    daysCompleted,
    isComplete: daysCompleted >= REQUIRED_DAYS,
  };
};
```

### 6.3 UI表示ロジック

```typescript
export const formatScoreDisplay = (
  score: Score,
  isCalibrating: boolean
): string => {
  return isCalibrating ? '---' : String(score.value);
};
```

---

## 7. ローカルストレージ

| キー | 内容 | 保持期間 |
|-----|------|---------|
| `user_profile` | ユーザープロフィール | 永続 |
| `calibration_state` | キャリブレーション状態 | 永続 |
| `advice_{date}` | 日次アドバイス | 7日 |
| `mood_logs` | 気分ログ | 30日 |
| `today_mode_logs` | 今日のモードログ | 30日 |
| `feedback_logs` | アドバイスフィードバック | 30日 |

---

## 8. エラーハンドリング

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
  | 'HEALTH_INSUFFICIENT_DATA'
  | 'NETWORK_ERROR'
  | 'API_ERROR'
  | 'LOCATION_DENIED';
```

| エラー | フォールバック |
|--------|---------------|
| ネットワークエラー | キャッシュ表示 → ローカル定型アドバイス |
| HealthKitデータ不足 | キャリブレーション期間として扱う |
| Claude APIエラー | 前日アドバイス + リトライ |

---

## 9. セキュリティ

| 原則 | 実装 |
|------|------|
| データ最小化 | ヘルスデータはデバイス内のみ |
| 暗号化 | HTTPS通信のみ |
| API保護 | API Key（MVP）→ OAuth（将来） |

---

## 10. コスト

| 項目 | コスト |
|------|--------|
| Claude API | ~$0.03/回 |
| 月間（1日1回） | ~$0.90/ユーザー |
| Open-Meteo | 無料 |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 5.0 | 2025-01-01 | ドメインモデル中心の設計に全面改訂 |
| 6.0 | 2025-01-01 | Geminiフィードバック反映: オンボーディング改善、キャリブレーション期間、バックグラウンド処理、オフラインフォールバック |
| 7.0 | 2026-01-06 | Swift/iOS → React Native (Expo) マイグレーション完了 |
