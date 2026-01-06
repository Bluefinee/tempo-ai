# Phase 4: Store 更新

## 目的

- healthStore に Tempo Score、Circadian Rhythm 関連の状態を追加
- insightStore に新 AI レスポンス形式、週間データ、アラートを追加
- breatheStore を新規作成
- userStore に新しいユーザー設定を追加

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | 状態管理の原則 |
| React Native規約 | `/.claude/react-native-standards.md` | **Zustand ストア構成、永続化、セレクター** |
| 技術仕様 | `/docs/specs/technical_spec.md` | **ローカルストレージ構造（AsyncStorage）** |
| AIプロンプト仕様 | `/docs/specs/ai_prompt_spec.md` | **AI レスポンス形式** |
| 製品仕様 | `/docs/specs/product_spec.md` | ユーザー設定項目 |

**特に重要**:
- `/.claude/react-native-standards.md` Section 4: 状態管理（Zustand）
- `/docs/specs/technical_spec.md` Section 5: ローカルストレージ

---

## Task 4.1: healthStore 更新

### `app/src/stores/healthStore.ts` を更新

```typescript
/**
 * Health Store - ヘルスデータ・スコア管理
 * @see docs/specs/metrics_spec.md
 */

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  TempoScoreResult,
  calculateTempoScore,
  HrvMetrics,
  SleepMetrics,
  RhythmMetrics,
  ActivityMetrics,
} from '@/domain/services/tempoScoreCalculator';
import {
  CircadianRhythm,
  EnergyCurve,
  RhythmPhase,
} from '@/domain/models/rhythm';
import {
  calculateCircadianRhythm,
  calculateEnergyCurve,
} from '@/domain/services/rhythmCalculator';

// ========================================
// Types
// ========================================

interface HealthMetrics {
  hrv: HrvMetrics | null;
  sleep: SleepMetrics | null;
  rhythm: RhythmMetrics | null;
  activity: ActivityMetrics | null;
}

interface HealthState {
  // メトリクス
  metrics: HealthMetrics;

  // Tempo Score
  tempoScore: TempoScoreResult | null;

  // Circadian Rhythm
  circadianRhythm: CircadianRhythm | null;
  energyCurve: EnergyCurve | null;

  // Calibration
  calibrationStartDate: string | null;
  calibrationDaysCompleted: number;

  // Loading State
  isLoading: boolean;
  error: string | null;

  // Actions
  setMetrics: (metrics: Partial<HealthMetrics>) => void;
  calculateAndSetTempoScore: () => void;
  calculateAndSetCircadianRhythm: (
    wakeUpTime: string,
    windDownTime: string,
    sunrise: string,
    sunset: string
  ) => void;
  startCalibration: () => void;
  incrementCalibrationDay: () => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
}

// ========================================
// Initial State
// ========================================

const initialState = {
  metrics: {
    hrv: null,
    sleep: null,
    rhythm: null,
    activity: null,
  },
  tempoScore: null,
  circadianRhythm: null,
  energyCurve: null,
  calibrationStartDate: null,
  calibrationDaysCompleted: 0,
  isLoading: false,
  error: null,
};

// ========================================
// Store
// ========================================

export const useHealthStore = create<HealthState>()(
  persist(
    (set, get) => ({
      ...initialState,

      setMetrics: (newMetrics) => {
        set((state) => ({
          metrics: {
            ...state.metrics,
            ...newMetrics,
          },
        }));
      },

      calculateAndSetTempoScore: () => {
        const { metrics, calibrationDaysCompleted } = get();
        const isCalibrating = calibrationDaysCompleted < 7;

        const tempoScore = calculateTempoScore(
          metrics.hrv,
          metrics.sleep,
          metrics.rhythm,
          metrics.activity,
          isCalibrating
        );

        set({ tempoScore });
      },

      calculateAndSetCircadianRhythm: (wakeUpTime, windDownTime, sunrise, sunset) => {
        const circadianRhythm = calculateCircadianRhythm(
          wakeUpTime,
          windDownTime,
          sunrise,
          sunset
        );
        const energyCurve = calculateEnergyCurve(wakeUpTime, windDownTime);

        set({ circadianRhythm, energyCurve });
      },

      startCalibration: () => {
        const now = new Date().toISOString();
        set({
          calibrationStartDate: now,
          calibrationDaysCompleted: 0,
        });
      },

      incrementCalibrationDay: () => {
        set((state) => ({
          calibrationDaysCompleted: Math.min(state.calibrationDaysCompleted + 1, 7),
        }));
      },

      setLoading: (isLoading) => set({ isLoading }),

      setError: (error) => set({ error }),

      reset: () => set(initialState),
    }),
    {
      name: 'tempo-health-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        calibrationStartDate: state.calibrationStartDate,
        calibrationDaysCompleted: state.calibrationDaysCompleted,
      }),
    }
  )
);

// ========================================
// Selectors
// ========================================

export const selectTempoScore = (state: HealthState): number | null =>
  state.tempoScore?.score ?? null;

export const selectIsCalibrating = (state: HealthState): boolean =>
  state.tempoScore?.isCalibrating ?? true;

export const selectCurrentPhase = (state: HealthState): RhythmPhase | null =>
  state.circadianRhythm?.currentPhase ?? null;

export const selectCalibrationProgress = (state: HealthState): number =>
  state.calibrationDaysCompleted / 7;
```

---

## Task 4.2: insightStore 更新

### `app/src/stores/insightStore.ts` を更新

```typescript
/**
 * Insight Store - AI インサイト・アラート管理
 * @see docs/specs/ai_prompt_spec.md
 */

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Alert, TopDiscovery } from '@/domain/models/insight';

// ========================================
// Types (AI Response Format)
// ========================================

interface AIMessage {
  title: string;   // "A Quiet Harmony"
  body: string;    // 詩的な本文
}

interface TodayOneThing {
  icon: 'walking' | 'breathing' | 'rest' | 'coffee' | 'sun';
  text: string;
  time?: string;   // "14:00"
}

interface RelatedInsight {
  text: string;
  insightId: string;
}

interface MetricInsights {
  sleep: string;
  hrv: string;
  steps: string;
}

interface InsightState {
  // AI Daily Insight
  tempoScore: number | null;
  aiMessage: AIMessage | null;
  todayOneThing: TodayOneThing | null;
  relatedInsight: RelatedInsight | null;
  metricInsights: MetricInsights | null;

  // Weekly Data
  weeklyScores: readonly number[];
  topDiscovery: TopDiscovery | null;
  recentAlerts: readonly Alert[];

  // Cache
  lastFetchedDate: string | null;

  // Loading State
  isLoading: boolean;
  error: string | null;

  // Actions
  setDailyInsight: (insight: {
    tempoScore: number;
    message: AIMessage;
    todayOneThing: TodayOneThing;
    relatedInsight: RelatedInsight;
    metricInsights: MetricInsights;
  }) => void;
  setWeeklyData: (data: {
    weeklyScores: readonly number[];
    topDiscovery: TopDiscovery | null;
  }) => void;
  setAlerts: (alerts: readonly Alert[]) => void;
  addAlert: (alert: Alert) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  clearCache: () => void;
  reset: () => void;
}

// ========================================
// Initial State
// ========================================

const initialState = {
  tempoScore: null,
  aiMessage: null,
  todayOneThing: null,
  relatedInsight: null,
  metricInsights: null,
  weeklyScores: [],
  topDiscovery: null,
  recentAlerts: [],
  lastFetchedDate: null,
  isLoading: false,
  error: null,
};

// ========================================
// Store
// ========================================

export const useInsightStore = create<InsightState>()(
  persist(
    (set, get) => ({
      ...initialState,

      setDailyInsight: (insight) => {
        const today = new Date().toISOString().split('T')[0];
        set({
          tempoScore: insight.tempoScore,
          aiMessage: insight.message,
          todayOneThing: insight.todayOneThing,
          relatedInsight: insight.relatedInsight,
          metricInsights: insight.metricInsights,
          lastFetchedDate: today,
          error: null,
        });
      },

      setWeeklyData: (data) => {
        set({
          weeklyScores: data.weeklyScores,
          topDiscovery: data.topDiscovery,
        });
      },

      setAlerts: (alerts) => {
        set({ recentAlerts: alerts });
      },

      addAlert: (alert) => {
        set((state) => ({
          recentAlerts: [alert, ...state.recentAlerts].slice(0, 10), // 最大10件
        }));
      },

      setLoading: (isLoading) => set({ isLoading }),

      setError: (error) => set({ error }),

      clearCache: () => {
        set({
          aiMessage: null,
          todayOneThing: null,
          relatedInsight: null,
          metricInsights: null,
          lastFetchedDate: null,
        });
      },

      reset: () => set(initialState),
    }),
    {
      name: 'tempo-insight-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        weeklyScores: state.weeklyScores,
        lastFetchedDate: state.lastFetchedDate,
      }),
    }
  )
);

// ========================================
// Selectors
// ========================================

export const selectAIMessage = (state: InsightState): AIMessage | null =>
  state.aiMessage;

export const selectTodayOneThing = (state: InsightState): TodayOneThing | null =>
  state.todayOneThing;

export const selectWeeklyAverage = (state: InsightState): number => {
  if (state.weeklyScores.length === 0) return 0;
  const sum = state.weeklyScores.reduce((a, b) => a + b, 0);
  return Math.round(sum / state.weeklyScores.length);
};

export const selectIsCacheValid = (state: InsightState): boolean => {
  if (!state.lastFetchedDate) return false;
  const today = new Date().toISOString().split('T')[0];
  return state.lastFetchedDate === today;
};
```

---

## Task 4.3: breatheStore 新規作成

### `app/src/stores/breatheStore.ts` を新規作成

```typescript
/**
 * Breathe Store - 呼吸エクササイズ状態管理
 * @see docs/specs/product_spec.md
 */

import { create } from 'zustand';

// ========================================
// Types
// ========================================

type BreathePhase = 'idle' | 'inhale' | 'hold' | 'exhale';

interface BreatheState {
  // Session State
  isActive: boolean;
  isPaused: boolean;
  phase: BreathePhase;

  // Timing
  sessionDuration: number;      // 総セッション時間（秒）
  elapsedTime: number;          // 経過時間（秒）
  phaseTimeRemaining: number;   // 現在フェーズ残り時間（ミリ秒）

  // Settings
  hapticEnabled: boolean;

  // Stats
  completedSessions: number;

  // Actions
  startSession: () => void;
  pauseSession: () => void;
  resumeSession: () => void;
  stopSession: () => void;
  setPhase: (phase: BreathePhase) => void;
  updateElapsedTime: (seconds: number) => void;
  setPhaseTimeRemaining: (ms: number) => void;
  setHapticEnabled: (enabled: boolean) => void;
  incrementCompletedSessions: () => void;
  reset: () => void;
}

// ========================================
// Constants
// ========================================

const DEFAULT_SESSION_DURATION = 60; // 1分

// ========================================
// Store
// ========================================

export const useBreatheStore = create<BreatheState>((set, get) => ({
  // Initial State
  isActive: false,
  isPaused: false,
  phase: 'idle',
  sessionDuration: DEFAULT_SESSION_DURATION,
  elapsedTime: 0,
  phaseTimeRemaining: 0,
  hapticEnabled: true,
  completedSessions: 0,

  // Actions
  startSession: () => {
    set({
      isActive: true,
      isPaused: false,
      phase: 'inhale',
      elapsedTime: 0,
    });
  },

  pauseSession: () => {
    set({ isPaused: true });
  },

  resumeSession: () => {
    set({ isPaused: false });
  },

  stopSession: () => {
    set({
      isActive: false,
      isPaused: false,
      phase: 'idle',
      elapsedTime: 0,
      phaseTimeRemaining: 0,
    });
  },

  setPhase: (phase) => {
    set({ phase });
  },

  updateElapsedTime: (seconds) => {
    const { sessionDuration } = get();
    set({ elapsedTime: Math.min(seconds, sessionDuration) });
  },

  setPhaseTimeRemaining: (ms) => {
    set({ phaseTimeRemaining: ms });
  },

  setHapticEnabled: (enabled) => {
    set({ hapticEnabled: enabled });
  },

  incrementCompletedSessions: () => {
    set((state) => ({
      completedSessions: state.completedSessions + 1,
    }));
  },

  reset: () => {
    set({
      isActive: false,
      isPaused: false,
      phase: 'idle',
      elapsedTime: 0,
      phaseTimeRemaining: 0,
    });
  },
}));

// ========================================
// Selectors
// ========================================

export const selectIsSessionComplete = (state: BreatheState): boolean =>
  state.elapsedTime >= state.sessionDuration;

export const selectSessionProgress = (state: BreatheState): number =>
  state.sessionDuration > 0 ? state.elapsedTime / state.sessionDuration : 0;

export const selectFormattedElapsedTime = (state: BreatheState): string => {
  const minutes = Math.floor(state.elapsedTime / 60);
  const seconds = state.elapsedTime % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};
```

---

## Task 4.4: userStore 更新

### `app/src/stores/userStore.ts` を更新

既存の userStore に以下のフィールドを追加:

```typescript
/**
 * User Store - ユーザープロファイル・設定管理
 * @see docs/specs/technical_spec.md
 */

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// ========================================
// Types
// ========================================

type Goal = 'better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance';

interface UserProfile {
  // 既存フィールド
  nickname: string;
  age: number | null;
  gender: string | null;
  weight: number | null;
  height: number | null;
  chronotype: string | null;
  occupation: string | null;
  exerciseFrequency: string | null;
  alcoholFrequency: string | null;

  // 新規フィールド
  goals: Goal[];
  wakeUpTime: string;      // "07:00"
  windDownTime: string;    // "23:00"
}

interface UserPreferences {
  gentleNudges: boolean;
  hapticFeedback: boolean;
}

interface UserState {
  // Profile
  profile: UserProfile | null;
  preferences: UserPreferences;

  // Onboarding
  onboardingCompleted: boolean;

  // Actions
  setProfile: (profile: Partial<UserProfile>) => void;
  setGoals: (goals: Goal[]) => void;
  setWakeUpTime: (time: string) => void;
  setWindDownTime: (time: string) => void;
  setPreferences: (prefs: Partial<UserPreferences>) => void;
  completeOnboarding: () => void;
  resetOnboarding: () => void;
  reset: () => void;
}

// ========================================
// Initial State
// ========================================

const initialProfile: UserProfile = {
  nickname: '',
  age: null,
  gender: null,
  weight: null,
  height: null,
  chronotype: null,
  occupation: null,
  exerciseFrequency: null,
  alcoholFrequency: null,
  goals: [],
  wakeUpTime: '07:00',
  windDownTime: '23:00',
};

const initialPreferences: UserPreferences = {
  gentleNudges: true,
  hapticFeedback: true,
};

// ========================================
// Store
// ========================================

export const useUserStore = create<UserState>()(
  persist(
    (set, get) => ({
      profile: null,
      preferences: initialPreferences,
      onboardingCompleted: false,

      setProfile: (partialProfile) => {
        set((state) => ({
          profile: {
            ...initialProfile,
            ...state.profile,
            ...partialProfile,
          },
        }));
      },

      setGoals: (goals) => {
        set((state) => ({
          profile: state.profile
            ? { ...state.profile, goals }
            : { ...initialProfile, goals },
        }));
      },

      setWakeUpTime: (time) => {
        set((state) => ({
          profile: state.profile
            ? { ...state.profile, wakeUpTime: time }
            : { ...initialProfile, wakeUpTime: time },
        }));
      },

      setWindDownTime: (time) => {
        set((state) => ({
          profile: state.profile
            ? { ...state.profile, windDownTime: time }
            : { ...initialProfile, windDownTime: time },
        }));
      },

      setPreferences: (prefs) => {
        set((state) => ({
          preferences: { ...state.preferences, ...prefs },
        }));
      },

      completeOnboarding: () => {
        set({ onboardingCompleted: true });
      },

      resetOnboarding: () => {
        set({
          onboardingCompleted: false,
          profile: null,
        });
      },

      reset: () => {
        set({
          profile: null,
          preferences: initialPreferences,
          onboardingCompleted: false,
        });
      },
    }),
    {
      name: 'tempo-user-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// ========================================
// Selectors
// ========================================

export const selectNickname = (state: UserState): string =>
  state.profile?.nickname ?? '';

export const selectGoals = (state: UserState): Goal[] =>
  state.profile?.goals ?? [];

export const selectWakeUpTime = (state: UserState): string =>
  state.profile?.wakeUpTime ?? '07:00';

export const selectWindDownTime = (state: UserState): string =>
  state.profile?.windDownTime ?? '23:00';

export const selectHapticEnabled = (state: UserState): boolean =>
  state.preferences.hapticFeedback;
```

---

## Task 4.5: Store index 更新

### `app/src/stores/index.ts` を更新

```typescript
export * from './userStore';
export * from './healthStore';
export * from './insightStore';
export * from './breatheStore';
```

---

## Phase 4 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト実行
pnpm test

# 4. iOS ビルド
pnpm ios --no-dev

# 5. Android ビルド
pnpm android --no-dev
```

### 完了チェックリスト

- [ ] `app/src/stores/healthStore.ts` が更新されている
- [ ] `app/src/stores/insightStore.ts` が更新されている
- [ ] `app/src/stores/breatheStore.ts` が新規作成されている
- [ ] `app/src/stores/userStore.ts` が更新されている
- [ ] `app/src/stores/index.ts` が更新されている
- [ ] 全てのセレクター関数に明示的な戻り値型がある
- [ ] 永続化設定が正しく実装されている
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` で全テストパス**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 4 の全てのチェックが完了したら、`05-phase5-navigation.md` に進む。
