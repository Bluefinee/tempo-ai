import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Mood, TodayMode } from '../domain/models';
import { apiClient } from '../api/client';
import { buildAdviceRequest } from '../api/helpers/adviceRequestBuilder';
import { Alert, TopDiscovery } from '../domain/models/insight';
import { useHealthStore } from './healthStore';
import { useUserStore } from './userStore';
import type { WeatherData, TodayInsight, TodayOneThing, RelatedInsight } from '../api/types';

type InsightFeedback = 'helpful' | 'not-helpful' | null;

interface InsightState {
  // AI Daily Insight
  todayInsight: TodayInsight | null;
  todayOneThing: TodayOneThing | null;
  relatedInsight: RelatedInsight | null;

  // User check-in
  todayMood: Mood | null;
  todayMode: TodayMode | null;

  // Feedback
  insightFeedback: InsightFeedback;

  // Loading state
  isGeneratingInsight: boolean;
  generationPhase: number;
  generationMessages: string[];

  // Error state
  insightError: string | null;

  // Last updated
  lastInsightUpdate: Date | null;

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
  generateDailyInsight: () => Promise<void>;
  setMood: (mood: Mood) => void;
  setTodayMode: (mode: TodayMode) => void;
  setInsightFeedback: (feedback: InsightFeedback) => void;
  resetInsight: () => void;
  setDailyInsight: (insight: {
    todayInsight: TodayInsight;
    todayOneThing: TodayOneThing;
    relatedInsight: RelatedInsight;
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

const GENERATION_MESSAGES = [
  '睡眠データを分析中...',
  'HRVを解析中...',
  'アドバイスを生成中...',
];

const initialState = {
  todayInsight: null,
  todayOneThing: null,
  relatedInsight: null,
  weeklyScores: [],
  topDiscovery: null,
  recentAlerts: [],
  lastFetchedDate: null,
  isLoading: false,
  error: null,
};

export const useInsightStore = create<InsightState>()(
  persist(
    (set, get) => ({
      ...initialState,
      todayMood: null,
      todayMode: null,
      insightFeedback: null,
      isGeneratingInsight: false,
      generationPhase: 0,
      generationMessages: GENERATION_MESSAGES,
      insightError: null,
      lastInsightUpdate: null,

  generateDailyInsight: async () => {
    set({
      isGeneratingInsight: true,
      generationPhase: 0,
      insightError: null,
    });

    try {
      // Labor Illusion: API呼び出しと並行してフェーズ表示
      const advicePromise = (async () => {
        const healthStoreState = useHealthStore.getState();
        const userStoreState = useUserStore.getState();
        
        // 天気データは一時的に空のオブジェクトを使用（実際にはuseWeatherフックから取得する必要がある）
        const weather: WeatherData = {
          temperature: 20,
          pressure: 1013,
          pressureTrend: 'stable',
          sunrise: '06:00',
          sunset: '18:00',
        };

        const request = buildAdviceRequest({
          healthStore: {
            metrics: {
              sleep: healthStoreState.metrics.sleep ? {
                durationMinutes: healthStoreState.metrics.sleep.durationMinutes,
                deepSleepMinutes: Math.round(healthStoreState.metrics.sleep.durationMinutes * healthStoreState.metrics.sleep.deepSleepRatio),
                remSleepMinutes: Math.round(healthStoreState.metrics.sleep.durationMinutes * healthStoreState.metrics.sleep.remSleepRatio),
              } : null,
              hrv: healthStoreState.metrics.hrv ? {
                current: healthStoreState.metrics.hrv.current,
                baseline30d: healthStoreState.metrics.hrv.baseline30d,
              } : null,
            },
          },
          userStore: {
            profile: userStoreState.profile ? {
              goals: (userStoreState.profile as { goals?: unknown }).goals ?? ['better_sleep'],
              wakeUpTime: (userStoreState.profile as { wakeUpTime?: unknown }).wakeUpTime ?? '07:00',
              windDownTime: (userStoreState.profile as { windDownTime?: unknown }).windDownTime ?? '23:00',
            } : null,
          },
          weather,
        });

        return apiClient.generateAdvice(request);
      })();

      // フェーズ表示（Labor Illusion）
      for (let phase = 0; phase < GENERATION_MESSAGES.length; phase++) {
        set({ generationPhase: phase });
        await new Promise((resolve) => setTimeout(resolve, 800));
      }

      // API レスポンス待機
      const response = await advicePromise;

      if (!response.success) {
        throw new Error(response.error?.message || 'アドバイスの生成に失敗しました');
      }

      if (!response.data) {
        throw new Error('アドバイスの生成に失敗しました');
      }

      const data = response.data;

      set({
        todayInsight: data.todayInsight,
        todayOneThing: data.todayOneThing,
        relatedInsight: data.relatedInsight,
        isGeneratingInsight: false,
        lastInsightUpdate: new Date(),
        lastFetchedDate: new Date().toISOString().split('T')[0],
        error: null,
      });
    } catch (error) {
      set({
        isGeneratingInsight: false,
        insightError:
          error instanceof Error ? error.message : 'アドバイスの生成に失敗しました',
      });
    }
  },

      setMood: (mood) => set({ todayMood: mood }),

      setTodayMode: (mode) => set({ todayMode: mode }),

      setInsightFeedback: (feedback) => {
        set({ insightFeedback: feedback });
        // TODO: Send feedback to backend
      },

      resetInsight: () =>
        set({
          todayInsight: null,
          todayOneThing: null,
          relatedInsight: null,
          todayMood: null,
          todayMode: null,
          insightFeedback: null,
          isGeneratingInsight: false,
          generationPhase: 0,
          insightError: null,
          lastInsightUpdate: null,
          lastFetchedDate: null,
        }),

      setDailyInsight: (insight) => {
        const today = new Date().toISOString().split('T')[0];
        set({
          todayInsight: insight.todayInsight,
          todayOneThing: insight.todayOneThing,
          relatedInsight: insight.relatedInsight,
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
          recentAlerts: [alert, ...state.recentAlerts].slice(0, 10),
        }));
      },

      setLoading: (isLoading) => set({ isLoading }),

      setError: (error) => set({ error }),

      clearCache: () => {
        set({
          todayInsight: null,
          todayOneThing: null,
          relatedInsight: null,
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

// Selectors (既存)
export const selectCurrentGenerationMessage = (state: InsightState): string =>
  state.generationMessages[state.generationPhase] || '';

export const selectIsInsightStale = (state: InsightState): boolean => {
  if (!state.lastInsightUpdate) return true;
  const lastUpdate = state.lastInsightUpdate;
  const now = new Date();
  return (
    lastUpdate.getDate() !== now.getDate() ||
    lastUpdate.getMonth() !== now.getMonth() ||
    lastUpdate.getFullYear() !== now.getFullYear()
  );
};

// Selectors
export const selectTodayInsight = (state: InsightState): TodayInsight | null =>
  state.todayInsight;

export const selectTodayOneThing = (state: InsightState): TodayOneThing | null =>
  state.todayOneThing;

export const selectRelatedInsight = (state: InsightState): RelatedInsight | null =>
  state.relatedInsight;

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
