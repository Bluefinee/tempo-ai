import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  RhythmAnalysis,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  SimpleWeatherData,
  DailySnapshot,
  RealtimeMetrics,
} from '../domain/models';
import { apiClient } from '../api/client';
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
  createMockDailySnapshot,
  createMockRealtimeMetrics,
} from '../constants/mockData';
import { formatDateString } from '../constants/mockDataFactory';
import { dataSourceAdapter } from '../services/dataSourceAdapter';
import {
  TempoScoreResult,
  calculateTempoScore,
  HrvMetrics as NewHrvMetrics,
  SleepMetrics as NewSleepMetrics,
  RhythmMetrics,
  ActivityMetrics as NewActivityMetrics,
} from '../domain/services/tempoScoreCalculator';
import {
  CircadianRhythm,
  EnergyCurve,
  RhythmPhase,
} from '../domain/models/rhythm';
import {
  calculateCircadianRhythm,
  calculateEnergyCurve,
} from '../domain/services/rhythmCalculator';
import {
  calculateRecoveryScore,
  calculateSleepScore,
  calculateRhythmScore,
  calculateEnergyScore,
} from '../domain/services/scoreCalculator';
import { DailyScores } from '../domain/models/score';

interface HealthMetricsV2 {
  hrv: NewHrvMetrics | null;
  sleep: NewSleepMetrics | null;
  rhythm: RhythmMetrics | null;
  activity: NewActivityMetrics | null;
}

/**
 * HealthStore の状態インターフェース
 *
 * データ更新タイミング:
 * - dailySnapshot: 朝1回算出（起床時刻連動）、その日は固定
 * - realtimeMetrics: アプリ起動ごとにリアルタイム更新
 */
interface HealthState {
  // Health metrics
  sleepMetrics: SleepMetrics | null;
  hrvMetrics: HRVMetrics | null;
  activityMetrics: ActivityMetrics | null;
  rhythmAnalysis: RhythmAnalysis | null;

  // Weather
  weather: SimpleWeatherData | null;
  weatherCode: number | null;
  weatherHumidity: number | null;

  // Loading states
  isLoadingMetrics: boolean;
  isLoadingWeather: boolean;

  // Error states
  metricsError: string | null;
  weatherError: string | null;

  // Last updated
  lastMetricsUpdate: Date | null;
  lastWeatherUpdate: Date | null;

  // Tempo Score
  metrics: HealthMetricsV2;
  tempoScore: TempoScoreResult | null;
  circadianRhythm: CircadianRhythm | null;
  energyCurve: EnergyCurve | null;
  calibrationStartDate: string | null;
  calibrationDaysCompleted: number;
  isLoading: boolean;
  error: string | null;

  // HealthKit 対応: 更新タイミング別データ
  /** 朝1回算出、その日は固定のスコア */
  dailySnapshot: DailySnapshot | null;
  /** 最後にスナップショットを算出した日付 (YYYY-MM-DD) */
  lastSnapshotDate: string | null;
  /** リアルタイム更新されるヘルスメトリクス */
  realtimeMetrics: RealtimeMetrics | null;

  // Actions
  fetchTodayMetrics: () => Promise<void>;
  fetchWeather: (latitude: number, longitude: number) => Promise<void>;
  setMockData: () => void;
  resetHealth: () => void;
  setMetrics: (metrics: Partial<HealthMetricsV2>) => void;
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

  // HealthKit 対応: 新規アクション
  /** 今日のスナップショットが算出済みかを判定 */
  shouldCalculateSnapshot: () => boolean;
  /** 日次スナップショットを算出（朝1回のみ） */
  calculateDailySnapshot: () => Promise<void>;
  /** リアルタイムメトリクスを取得（アプリ起動ごと） */
  fetchRealtimeMetrics: () => Promise<void>;
  /** 4つの独立スコアを計算 */
  calculateDailyScores: () => void;
  /** アプリ起動時に呼び出す初期化関数 */
  initialize: () => Promise<void>;
}

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
  // HealthKit 対応
  dailySnapshot: null,
  lastSnapshotDate: null,
  realtimeMetrics: null,
};

export const useHealthStore = create<HealthState>()(
  persist(
    (set, get) => ({
      ...initialState,
      sleepMetrics: null,
      hrvMetrics: null,
      activityMetrics: null,
      rhythmAnalysis: null,
      weather: null,
      weatherCode: null,
      weatherHumidity: null,
      isLoadingMetrics: false,
      isLoadingWeather: false,
      metricsError: null,
      weatherError: null,
      lastMetricsUpdate: null,
      lastWeatherUpdate: null,

  fetchTodayMetrics: async (): Promise<void> => {
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
        isLoadingMetrics: false,
        lastMetricsUpdate: new Date(),
      });
    } catch (error) {
      set({
        isLoadingMetrics: false,
        metricsError: error instanceof Error ? error.message : 'Failed to fetch metrics',
      });
    }
  },

  fetchWeather: async (latitude: number, longitude: number): Promise<void> => {
    set({ isLoadingWeather: true, weatherError: null });

    try {
      const weather = await dataSourceAdapter.getWeather(latitude, longitude);

      set({
        weather,
        weatherCode: null,
        weatherHumidity: null,
        isLoadingWeather: false,
        lastWeatherUpdate: new Date(),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to fetch weather';
      set({
        isLoadingWeather: false,
        weatherError: message,
      });
    }
  },

  setMockData: () => {
    set({
      sleepMetrics: MOCK_SLEEP_METRICS,
      hrvMetrics: MOCK_HRV_METRICS,
      activityMetrics: MOCK_ACTIVITY_METRICS,
      rhythmAnalysis: MOCK_RHYTHM_ANALYSIS,
      weather: MOCK_WEATHER,
      lastMetricsUpdate: new Date(),
      lastWeatherUpdate: new Date(),
    });
  },

      resetHealth: () =>
        set({
          sleepMetrics: null,
          hrvMetrics: null,
          activityMetrics: null,
          rhythmAnalysis: null,
          weather: null,
          weatherCode: null,
          weatherHumidity: null,
          isLoadingMetrics: false,
          isLoadingWeather: false,
          metricsError: null,
          weatherError: null,
          lastMetricsUpdate: null,
          lastWeatherUpdate: null,
        }),

      // 新規: Actions
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

      // HealthKit 対応: 新規アクション実装
      shouldCalculateSnapshot: (): boolean => {
        const { lastSnapshotDate } = get();
        const today = formatDateString(new Date());
        return lastSnapshotDate !== today;
      },

      calculateDailySnapshot: async (): Promise<void> => {
        const state = get();

        // 今日すでに算出済みの場合はスキップ
        if (!state.shouldCalculateSnapshot()) {
          return;
        }

        set({ isLoading: true, error: null });

        try {
          // TODO: Replace with actual HealthKit data fetch and score calculation
          // For now, use mock data
          await new Promise((resolve) => setTimeout(resolve, 300));

          const snapshot = createMockDailySnapshot();

          set({
            dailySnapshot: snapshot,
            lastSnapshotDate: snapshot.date,
            isLoading: false,
          });
        } catch (error) {
          set({
            isLoading: false,
            error:
              error instanceof Error
                ? error.message
                : 'Failed to calculate daily snapshot',
          });
        }
      },

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
            lightMinutes: sleepMetrics.durationMinutes - sleepMetrics.deepSleepMinutes - sleepMetrics.remSleepMinutes,
            awakeMinutes: 0, // TODO: HealthKitから取得
          },
          // timingは後で実装（HealthKitから就寝・起床時刻を取得）
        });

        // 2. Recovery Score計算
        const recoveryScore = calculateRecoveryScore({
          hrv: {
            current: hrvMetrics.value,
            baseline: hrvMetrics.baseline30d,
          },
          rhr: {
            current: 60, // TODO: 実際のRHRを取得
            baseline: 60, // TODO: RHRベースラインを計算
          },
          sleepQuality: sleepScore,
        });

        // 3. Rhythm Score計算
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

        const currentSnapshot = get().dailySnapshot;
        set({
          dailySnapshot: {
            ...currentSnapshot,
            date: formatDateString(new Date()),
            scores: dailyScores,
          } as DailySnapshot,
        });
      },

      /**
       * アプリ起動時に呼び出す初期化関数
       */
      initialize: async () => {
        await get().fetchTodayMetrics();
        await get().fetchWeather(35.6762, 139.6503); // TODO: 実際の位置情報を取得
        get().calculateDailyScores();
      },

      fetchRealtimeMetrics: async (): Promise<void> => {
        set({ isLoadingMetrics: true, metricsError: null });

        try {
          // TODO: Replace with actual HealthKit data fetch
          // For now, use mock data
          await new Promise((resolve) => setTimeout(resolve, 200));

          const metrics = createMockRealtimeMetrics();

          set({
            realtimeMetrics: metrics,
            isLoadingMetrics: false,
            lastMetricsUpdate: new Date(),
          });
        } catch (error) {
          set({
            isLoadingMetrics: false,
            metricsError:
              error instanceof Error
                ? error.message
                : 'Failed to fetch realtime metrics',
          });
        }
      },
    }),
    {
      name: 'tempo-health-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        calibrationStartDate: state.calibrationStartDate,
        calibrationDaysCompleted: state.calibrationDaysCompleted,
        // DailySnapshot も永続化（日付変更まで保持）
        dailySnapshot: state.dailySnapshot,
        lastSnapshotDate: state.lastSnapshotDate,
      }),
    }
  )
);

// Selectors
export const selectIsHealthDataStale = (state: HealthState): boolean => {
  if (!state.lastMetricsUpdate) return true;
  const hoursSinceUpdate =
    (Date.now() - state.lastMetricsUpdate.getTime()) / (1000 * 60 * 60);
  return hoursSinceUpdate > 6;
};
export const selectTempoScore = (state: HealthState): number | null =>
  state.tempoScore?.score ?? null;

export const selectIsCalibrating = (state: HealthState): boolean =>
  state.tempoScore?.isCalibrating ?? true;

export const selectCurrentPhase = (state: HealthState): RhythmPhase | null =>
  state.circadianRhythm?.currentPhase ?? null;

export const selectCalibrationProgress = (state: HealthState): number =>
  state.calibrationDaysCompleted / 7;

// HealthKit 対応: 新規セレクター
export const selectDailySnapshot = (state: HealthState): DailySnapshot | null =>
  state.dailySnapshot;

export const selectRealtimeMetrics = (
  state: HealthState
): RealtimeMetrics | null => state.realtimeMetrics;

export const selectShouldCalculateSnapshot = (state: HealthState): boolean => {
  const today = formatDateString(new Date());
  return state.lastSnapshotDate !== today;
};
