import { create } from 'zustand';
import {
  DailyScores,
  RhythmAnalysis,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  SimpleWeatherData,
} from '../domain/models';
import { calculateConditionAssessment, calculatePressureTrend } from '../domain/services';
import { getWeatherCondition } from '../domain/models/weather';
import { apiClient } from '../api/client';
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
} from '../constants/mockData';

interface HealthState {
  // Health metrics
  sleepMetrics: SleepMetrics | null;
  hrvMetrics: HRVMetrics | null;
  activityMetrics: ActivityMetrics | null;

  // Calculated scores
  dailyScores: DailyScores | null;
  rhythmAnalysis: RhythmAnalysis | null;

  // Weather
  weather: SimpleWeatherData | null;

  // Loading states
  isLoadingMetrics: boolean;
  isLoadingWeather: boolean;

  // Error states
  metricsError: string | null;
  weatherError: string | null;

  // Last updated
  lastMetricsUpdate: Date | null;
  lastWeatherUpdate: Date | null;

  // Actions
  fetchTodayMetrics: () => Promise<void>;
  fetchWeather: (latitude: number, longitude: number) => Promise<void>;
  calculateScores: () => void;

  // For testing/mock
  setMockData: () => void;

  // Reset
  resetHealth: () => void;
}

export const useHealthStore = create<HealthState>()((set, get) => ({
  sleepMetrics: null,
  hrvMetrics: null,
  activityMetrics: null,
  dailyScores: null,
  rhythmAnalysis: null,
  weather: null,
  isLoadingMetrics: false,
  isLoadingWeather: false,
  metricsError: null,
  weatherError: null,
  lastMetricsUpdate: null,
  lastWeatherUpdate: null,

  fetchTodayMetrics: async (): Promise<void> => {
    set({ isLoadingMetrics: true, metricsError: null });

    try {
      // TODO: Replace with actual HealthKit/Health Connect integration
      // For now, simulate a delay and use mock data
      await new Promise((resolve) => setTimeout(resolve, 500));

      set({
        sleepMetrics: MOCK_SLEEP_METRICS,
        hrvMetrics: MOCK_HRV_METRICS,
        activityMetrics: MOCK_ACTIVITY_METRICS,
        rhythmAnalysis: MOCK_RHYTHM_ANALYSIS,
        isLoadingMetrics: false,
        lastMetricsUpdate: new Date(),
      });

      // Calculate scores after fetching metrics
      get().calculateScores();
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
      const response = await apiClient.weather.get({ latitude, longitude });

      if (!response.success || !response.data) {
        throw new Error(response.error || 'Failed to fetch weather');
      }

      const { temperature, pressure, weatherCode, uvIndexMax } = response.data;

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

  calculateScores: (): void => {
    const { sleepMetrics, hrvMetrics, activityMetrics, rhythmAnalysis } = get();

    if (!sleepMetrics || !hrvMetrics || !activityMetrics || !rhythmAnalysis) {
      return;
    }

    // Combine metrics into HealthMetrics format
    const healthMetrics = {
      date: new Date(),
      sleep: sleepMetrics,
      hrv: hrvMetrics,
      activity: activityMetrics,
    };

    const assessment = calculateConditionAssessment(healthMetrics, rhythmAnalysis);

    set({
      dailyScores: {
        autonomic: assessment.autonomicScore.value,
        sleep: assessment.sleepScore.value,
        rhythm: assessment.rhythmScore.value,
        activity: assessment.activityScore.value,
      },
    });
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
    get().calculateScores();
  },

  resetHealth: () =>
    set({
      sleepMetrics: null,
      hrvMetrics: null,
      activityMetrics: null,
      dailyScores: null,
      rhythmAnalysis: null,
      weather: null,
      isLoadingMetrics: false,
      isLoadingWeather: false,
      metricsError: null,
      weatherError: null,
      lastMetricsUpdate: null,
      lastWeatherUpdate: null,
    }),
}));

// Selectors
export const selectTodayScores = (state: HealthState): DailyScores | null =>
  state.dailyScores;
export const selectIsHealthDataStale = (state: HealthState): boolean => {
  if (!state.lastMetricsUpdate) return true;
  const hoursSinceUpdate =
    (Date.now() - state.lastMetricsUpdate.getTime()) / (1000 * 60 * 60);
  return hoursSinceUpdate > 6; // Consider stale after 6 hours
};
