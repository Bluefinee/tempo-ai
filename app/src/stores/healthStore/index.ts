/**
 * HealthStore - メインストア
 */

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
  createMockDailySnapshot,
  createMockRealtimeMetrics,
} from '../../constants/mockData';
import { formatDateString } from '../../constants/mockDataFactory';
import { dataSourceAdapter } from '../../services/dataSourceAdapter';
import {
  calculateTempoScore,
} from '../../domain/services/tempoScoreCalculator';
import {
  calculateCircadianRhythm,
  calculateEnergyCurve,
} from '../../domain/services/rhythmCalculator';
import {
  calculateRecoveryScore,
  calculateSleepScore,
  calculateRhythmScore,
  calculateEnergyScore,
} from '../../domain/services/scoreCalculator';
import type { DailyScores } from '../../domain/models/score';
import type { DailySnapshot } from '../../domain/models';
import type { HealthState, HealthMetricsV2 } from './types';
import { initialHealthState } from './types';

export type { HealthState, HealthMetricsV2 } from './types';
export * from './selectors';

export const useHealthStore = create<HealthState>()(
  persist(
    (set, get) => ({
      ...initialHealthState,
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

      setMetrics: (newMetrics: Partial<HealthMetricsV2>) => {
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

      calculateAndSetCircadianRhythm: (wakeUpTime: string, windDownTime: string, sunrise: string, sunset: string) => {
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

      setLoading: (isLoading: boolean) => set({ isLoading }),

      setError: (error: string | null) => set({ error }),

      reset: () => set(initialHealthState),

      shouldCalculateSnapshot: (): boolean => {
        const { lastSnapshotDate } = get();
        const today = formatDateString(new Date());
        return lastSnapshotDate !== today;
      },

      calculateDailySnapshot: async (): Promise<void> => {
        const state = get();

        if (!state.shouldCalculateSnapshot()) {
          return;
        }

        set({ isLoading: true, error: null });

        try {
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

      calculateDailyScores: () => {
        const { sleepMetrics, hrvMetrics, activityMetrics, rhythmAnalysis, weather } = get();

        if (!sleepMetrics || !hrvMetrics || !activityMetrics || !rhythmAnalysis) {
          console.warn('Missing metrics for score calculation');
          return;
        }

        const sleepScore = calculateSleepScore({
          duration: {
            minutes: sleepMetrics.durationMinutes,
            targetMinutes: 450,
          },
          stages: {
            deepMinutes: sleepMetrics.deepSleepMinutes,
            remMinutes: sleepMetrics.remSleepMinutes,
            lightMinutes: sleepMetrics.durationMinutes - sleepMetrics.deepSleepMinutes - sleepMetrics.remSleepMinutes,
            awakeMinutes: 0,
          },
        });

        const recoveryScore = calculateRecoveryScore({
          hrv: {
            current: hrvMetrics.value,
            baseline: hrvMetrics.baseline30d,
          },
          rhr: {
            current: 60,
            baseline: 60,
          },
          sleepQuality: sleepScore,
        });

        const rhythmScore = calculateRhythmScore({
          bedtimeStddevMinutes: rhythmAnalysis.bedtimeStddevMinutes,
          wakeTimeStddevMinutes: rhythmAnalysis.wakeTimeStddevMinutes,
        });

        const energyScore = calculateEnergyScore({
          recovery: recoveryScore,
          sleep: sleepScore,
          weather: {
            pressure: weather?.pressure ?? 1013,
            pressureTrend: weather?.pressureTrend ?? 'stable',
          },
        });

        const dailyScores: DailyScores = {
          recovery: recoveryScore,
          sleep: sleepScore,
          rhythm: rhythmScore,
          energy: energyScore,
        };

        const currentSnapshot = get().dailySnapshot;
        set({
          dailySnapshot: currentSnapshot
            ? {
                ...currentSnapshot,
                date: formatDateString(new Date()),
                scores: dailyScores,
              }
            : ({
                date: formatDateString(new Date()),
                scores: dailyScores,
                calculatedAt: new Date(),
              } as DailySnapshot),
        });
      },

      initialize: async () => {
        await get().fetchTodayMetrics();
        await get().fetchWeather(35.6762, 139.6503);
        get().calculateDailyScores();
      },

      fetchRealtimeMetrics: async (): Promise<void> => {
        set({ isLoadingMetrics: true, metricsError: null });

        try {
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
        dailySnapshot: state.dailySnapshot,
        lastSnapshotDate: state.lastSnapshotDate,
      }),
    }
  )
);

