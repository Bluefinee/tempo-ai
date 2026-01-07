/**
 * AIアドバイス取得フック
 */

import { useCallback, useState } from 'react';
import { apiClient } from '../api/client';
import { buildAdviceRequest } from '../api/helpers/adviceRequestBuilder';
import type { WeatherData, UserGoal } from '../api/types';
import { useHealthStore } from '../stores/healthStore';
import { useInsightStore } from '../stores/insightStore';
import { useUserStore } from '../stores/userStore';

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
    metrics: {
      sleep: state.metrics.sleep ? {
        durationMinutes: state.metrics.sleep.durationMinutes,
        deepSleepMinutes: Math.round(state.metrics.sleep.durationMinutes * state.metrics.sleep.deepSleepRatio),
        remSleepMinutes: Math.round(state.metrics.sleep.durationMinutes * state.metrics.sleep.remSleepRatio),
      } : null,
      hrv: state.metrics.hrv ? {
        value: state.metrics.hrv.current,
        baseline30d: state.metrics.hrv.baseline30d,
      } : null,
      activity: state.metrics.activity ? {
        steps: state.metrics.activity.steps,
      } : null,
    },
    tempoScore: state.tempoScore,
  }));

  const userStore = useUserStore((state) => ({
    profile: state.profile ? {
      goals: (state.profile as { goals?: UserGoal[] }).goals ?? ['better_sleep'],
      wakeUpTime: (state.profile as { wakeUpTime?: string }).wakeUpTime ?? '07:00',
      windDownTime: (state.profile as { windDownTime?: string }).windDownTime ?? '23:00',
    } : null,
  }));

  const setDailyInsight = useInsightStore((state) => state.setDailyInsight);

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

        // Storeに保存（新形式）
        setDailyInsight({
          todayInsight: data.todayInsight,
          todayOneThing: data.todayOneThing,
          relatedInsight: data.relatedInsight,
        });
      } else {
        setError(response.error.message ?? 'Failed to fetch advice');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  }, [healthStore, userStore, setDailyInsight]);

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

