import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  RhythmAnalysis,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  SimpleWeatherData,
} from '../domain/models';
import { apiClient } from '../api/client';
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
} from '../constants/mockData';
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

interface HealthMetricsV2 {
  hrv: NewHrvMetrics | null;
  sleep: NewSleepMetrics | null;
  rhythm: RhythmMetrics | null;
  activity: NewActivityMetrics | null;
}

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
      const response = await apiClient.getWeather(latitude, longitude);

      if (!response.success || !response.data) {
        const errorMessage = response.success === false ? response.error?.message : 'Failed to fetch weather';
        throw new Error(errorMessage || 'Failed to fetch weather');
      }

      const { temperature, pressure, pressureTrend: apiPressureTrend, description, location } = response.data;

      // PressureTrend型を変換 ('rising' | 'stable' | 'falling' -> 'up' | 'stable' | 'down')
      const pressureTrend: SimpleWeatherData['pressureTrend'] = 
        apiPressureTrend === 'rising' ? 'up' : 
        apiPressureTrend === 'falling' ? 'down' : 
        'stable';

      // SimpleWeatherData形式に変換
      const weather: SimpleWeatherData = {
        temp: temperature,
        condition: description || 'sunny',
        pressure,
        pressureTrend,
        uv: 0, // TODO: UV index is not available in WeatherResponse
        location: location || '現在地',
      };

      set({
        weather,
        weatherCode: null, // WeatherResponseにはweatherCodeがない
        weatherHumidity: null, // WeatherResponseにはhumidityがない
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
