/**
 * ヘルスメトリクス関連の型定義
 */

// 睡眠データ
export interface SleepMetrics {
  bedtime: Date;
  wakeTime: Date;
  durationMinutes: number;
  deepSleepMinutes: number;
  remSleepMinutes: number;
}

// 睡眠データの算出プロパティ
export const getSleepDerivedMetrics = (sleep: SleepMetrics): {
  durationHours: number;
  deepSleepRatio: number;
  remSleepRatio: number;
  lightSleepMinutes: number;
} => ({
  durationHours: sleep.durationMinutes / 60,
  deepSleepRatio: sleep.durationMinutes > 0 ? sleep.deepSleepMinutes / sleep.durationMinutes : 0,
  remSleepRatio: sleep.durationMinutes > 0 ? sleep.remSleepMinutes / sleep.durationMinutes : 0,
  lightSleepMinutes: Math.max(0, sleep.durationMinutes - sleep.deepSleepMinutes - sleep.remSleepMinutes),
});

// HRV（心拍変動）データ
export interface HRVMetrics {
  value: number; // ms
  baseline30d: number; // ms (30日平均)
}

// HRVの算出プロパティ
export const getHRVDerivedMetrics = (hrv: HRVMetrics): {
  deviationPercent: number;
  status: HRVStatus;
} => {
  const deviationPercent = hrv.baseline30d > 0
    ? ((hrv.value - hrv.baseline30d) / hrv.baseline30d) * 100
    : 0;
  return {
    deviationPercent,
    status: getHRVStatus(deviationPercent),
  };
};

export type HRVStatus = 'elevated' | 'normal' | 'slightlyLow' | 'low';

export const getHRVStatus = (deviationPercent: number): HRVStatus => {
  if (deviationPercent >= 10) return 'elevated';
  if (deviationPercent >= -10) return 'normal';
  if (deviationPercent >= -20) return 'slightlyLow';
  return 'low';
};

export const getHRVStatusLabel = (status: HRVStatus): string => {
  switch (status) {
    case 'elevated':
      return '高め';
    case 'normal':
      return '正常';
    case 'slightlyLow':
      return 'やや低め';
    case 'low':
      return '低め';
  }
};

// アクティビティデータ
export interface ActivityMetrics {
  stepsYesterday: number;
  activeMinutesYesterday: number;
}

// アクティビティの算出プロパティ
export const getActivityAchievementRate = (
  activity: ActivityMetrics,
  targetSteps: number = 8000
): number => {
  return targetSteps > 0 ? Math.min(activity.stepsYesterday / targetSteps, 1.0) : 0;
};

// 補助データ（オプション）
export interface AuxiliaryMetrics {
  daylightMinutesYesterday?: number;
  wristTemperatureDeviation?: number; // °C
}

// 日光時間のステータス
export type DaylightStatus = 'sufficient' | 'moderate' | 'insufficient';

export const getDaylightStatus = (minutes?: number): DaylightStatus => {
  if (minutes === undefined) return 'insufficient';
  if (minutes >= 30) return 'sufficient';
  if (minutes >= 15) return 'moderate';
  return 'insufficient';
};

// 総合ヘルスメトリクス
export interface HealthMetrics {
  date: Date;
  sleep?: SleepMetrics;
  hrv?: HRVMetrics;
  activity?: ActivityMetrics;
  auxiliary?: AuxiliaryMetrics;
}

// 日次スコアスナップショット（分析用）
export interface DailyScoreSnapshot {
  id: string;
  date: Date;
  recoveryScore: number; // 旧: autonomicScore
  sleepScore: number;
  rhythmScore: number;
  energyScore: number; // 旧: activityScore
}
