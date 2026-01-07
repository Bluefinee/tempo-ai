/**
 * AdviceRequest構築ヘルパー
 * ストアの状態からAPIリクエストを構築（新形式）
 */

import type { AdviceRequest, HealthMetrics, UserProfile, WeatherData, ScoresData, RhythmPhases } from '../types';

interface BuildAdviceRequestParams {
  healthStore: {
    metrics: {
      sleep: {
        durationMinutes: number;
        deepSleepMinutes: number;
        deepSleepPercent?: number;
        remSleepMinutes: number;
        remSleepPercent?: number;
        bedtime?: string;
        wakeTime?: string;
      } | null;
      hrv: { current?: number; baseline?: number; baseline30d?: number } | null;
      rhr?: { current: number; baseline: number } | null;
    };
    // 4スコア（将来的に実装）
    recoveryScore?: number;
    sleepScore?: number;
    rhythmScore?: number;
    energyScore?: number;
  };
  userStore: {
    profile: { goals?: unknown; wakeUpTime?: unknown; windDownTime?: unknown } | null;
  };
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
  const profile = userStore.profile;
  const goals = (profile?.goals as string[]) ?? ['better_sleep'];
  const wakeUpTime = (profile?.wakeUpTime as string) ?? '07:00';
  const windDownTime = (profile?.windDownTime as string) ?? '23:00';

  const user: UserProfile = {
    goals: goals as ('better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance')[],
    wakeUpTime,
    windDownTime,
  };

  // 4スコア（現在はモックデータ、将来的にhealthStoreから取得）
  const scores: ScoresData = {
    recovery: healthStore.recoveryScore ?? 70,
    sleep: healthStore.sleepScore ?? 85,
    rhythm: healthStore.rhythmScore ?? 92,
    energy: healthStore.energyScore ?? 78,
  };

  const sleep = healthStore.metrics.sleep;
  const hrv = healthStore.metrics.hrv;
  const rhr = healthStore.metrics.rhr;

  // 睡眠データの計算
  const durationMinutes = sleep?.durationMinutes ?? 428;
  const deepSleepMinutes = sleep?.deepSleepMinutes ?? 105;
  const remSleepMinutes = sleep?.remSleepMinutes ?? 95;
  const deepSleepPercent = sleep?.deepSleepPercent ?? (durationMinutes > 0 ? Math.round((deepSleepMinutes / durationMinutes) * 100) : 23);
  const remSleepPercent = sleep?.remSleepPercent ?? (durationMinutes > 0 ? Math.round((remSleepMinutes / durationMinutes) * 100) : 22);

  const healthMetrics: HealthMetrics = {
    hrv: {
      current: hrv?.current ?? hrv?.baseline30d ?? 82,
      baseline: hrv?.baseline ?? hrv?.baseline30d ?? 77,
      deviation: hrv?.current && hrv?.baseline ? ((hrv.current - hrv.baseline) / hrv.baseline * 100) : 6,
    },
    rhr: {
      current: rhr?.current ?? 59,
      baseline: rhr?.baseline ?? 59,
    },
    sleep: {
      durationMinutes,
      deepSleepMinutes,
      deepSleepPercent,
      remSleepMinutes,
      remSleepPercent,
      bedtime: sleep?.bedtime ?? '23:15',
      wakeTime: sleep?.wakeTime ?? '06:45',
      vsTargetBedtime: '+15min', // TODO: 実際の計算を実装
    },
  };

  // RhythmPhases（現在はモックデータ、将来的に計算）
  const rhythmPhases: RhythmPhases = {
    peakFocus: {
      start: '09:00',
      end: '12:00',
    },
    afternoonDip: {
      start: '14:00',
      end: '16:00',
    },
    secondWind: {
      start: '17:00',
      end: '19:00',
    },
    windDown: {
      start: '21:00',
      end: '23:00',
    },
  };

  return {
    user,
    scores,
    healthMetrics,
    weather,
    rhythmPhases,
    locale: 'ja',
  };
};
