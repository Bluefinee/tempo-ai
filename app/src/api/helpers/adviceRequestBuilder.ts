/**
 * AdviceRequest構築ヘルパー
 * ストアの状態からAPIリクエストを構築
 */

import type { AdviceRequest } from '../types';
import { useUserStore } from '../../stores/userStore';
import { useHealthStore } from '../../stores/healthStore';
import { useInsightStore } from '../../stores/insightStore';

const DAY_NAMES = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/**
 * 現在のストア状態からAdviceRequestを構築
 * @returns AdviceRequest または null（プロファイルがない場合）
 */
export const buildAdviceRequest = (): AdviceRequest | null => {
  const userState = useUserStore.getState();
  const healthState = useHealthStore.getState();
  const insightState = useInsightStore.getState();

  const { profile } = userState;
  if (!profile) {
    console.warn('buildAdviceRequest: profile is null');
    return null;
  }

  const {
    sleepMetrics,
    hrvMetrics,
    activityMetrics,
    dailyScores,
    rhythmAnalysis,
    weather,
  } = healthState;

  const { todayMood, todayMode } = insightState;

  // 現在時刻情報
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  const minutes = now.getMinutes().toString().padStart(2, '0');
  const currentTime = `${hours}:${minutes}`;
  const dayOfWeek = DAY_NAMES[now.getDay()];

  // スコアのデフォルト値
  const scores = dailyScores || {
    autonomic: 0,
    sleep: 0,
    rhythm: 0,
    activity: 0,
  };

  // リズム分析のデフォルト値
  const rhythm = rhythmAnalysis || {
    bedtimeStddevMinutes: 0,
    wakeTimeStddevMinutes: 0,
    consecutiveStableDays: 0,
    status: 'unstable' as const,
  };

  const request: AdviceRequest = {
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
      sleep: sleepMetrics
        ? {
            bedtime: sleepMetrics.bedtime.toISOString(),
            wakeTime: sleepMetrics.wakeTime.toISOString(),
            durationHours: sleepMetrics.durationMinutes / 60,
            deepSleepMinutes: sleepMetrics.deepSleepMinutes,
            remSleepMinutes: sleepMetrics.remSleepMinutes,
            deepSleepRatio:
              sleepMetrics.deepSleepMinutes / sleepMetrics.durationMinutes,
          }
        : undefined,
      hrv: hrvMetrics
        ? {
            value: hrvMetrics.value,
            baseline30d: hrvMetrics.baseline30d,
            deviationPercent:
              ((hrvMetrics.value - hrvMetrics.baseline30d) /
                hrvMetrics.baseline30d) *
              100,
          }
        : undefined,
      activity: activityMetrics
        ? {
            stepsYesterday: activityMetrics.stepsYesterday,
            activeMinutesYesterday: activityMetrics.activeMinutesYesterday,
          }
        : undefined,
      scores,
      rhythmAnalysis: rhythm,
    },
    location: {
      // TODO: 実際の位置情報を使用
      latitude: 35.6762,
      longitude: 139.6503,
      city: '東京',
    },
    context: {
      currentTime,
      dayOfWeek,
      mood: todayMood ?? undefined,
      todayMode: todayMode || 'normal',
    },
    weather: weather
      ? {
          temperature: weather.temp,
          humidity: 50, // TODO: APIから取得した値を使用
          pressure: weather.pressure,
          weatherCode: 0, // TODO: conditionからweatherCodeに逆変換
          uvIndexMax: weather.uv,
        }
      : undefined,
  };

  return request;
};

