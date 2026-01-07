/**
 * Tempo Score 計算サービス
 * @see docs/specs/metrics_spec.md Section 2
 *
 * Tempo Score = HRV Score × 0.40
 *             + Sleep Score × 0.35
 *             + Rhythm Score × 0.15
 *             + Activity Score × 0.10
 */

// ========================================
// Types
// ========================================

export interface SleepMetrics {
  readonly durationMinutes: number;
  readonly deepSleepRatio: number; // 0.0-1.0
  readonly remSleepRatio: number;  // 0.0-1.0
}

export interface HrvMetrics {
  readonly current: number;       // ms
  readonly baseline30d: number;   // ms
}

export interface RhythmMetrics {
  readonly bedtimeStddevMinutes: number;
  readonly wakeTimeStddevMinutes: number;
}

export interface ActivityMetrics {
  readonly steps: number;
  readonly goal?: number; // default: 8000
}

export interface TempoScoreComponents {
  readonly hrvScore: number;
  readonly sleepScore: number;
  readonly rhythmScore: number;
  readonly activityScore: number;
}

export interface TempoScoreResult {
  readonly score: number;
  readonly components: TempoScoreComponents;
  readonly isCalibrating: boolean;
}

// ========================================
// Utility Functions
// ========================================

const clamp = (value: number, min: number, max: number): number =>
  Math.max(min, Math.min(max, value));

// ========================================
// HRV Score (40%)
// ========================================

export const calculateHrvScore = (hrv: HrvMetrics): number => {
  if (hrv.baseline30d === 0) return 70; // キャリブレーション中

  const ratio = hrv.current / hrv.baseline30d;
  const baseScore = 70;
  const deviation = (ratio - 1.0) * 100;

  return clamp(baseScore + deviation, 0, 100);
};

// ========================================
// Sleep Score (35%)
// ========================================

const scoreDuration = (minutes: number): number => {
  const hours = minutes / 60;
  if (hours >= 7 && hours <= 8) return 100;
  if (hours >= 6 && hours < 7) return 70 + (hours - 6) * 30;
  if (hours > 8 && hours <= 9) return 100 - (hours - 8) * 20;
  if (hours < 6) return Math.max(0, hours * 11.67);
  return 60; // 9時間超
};

const scoreDeepSleep = (ratio: number): number => {
  // 15-25%が理想
  if (ratio >= 0.15 && ratio <= 0.25) return 100;
  if (ratio < 0.15) return (ratio / 0.15) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
};

const scoreRemSleep = (ratio: number): number => {
  // 20-25%が理想
  if (ratio >= 0.2 && ratio <= 0.25) return 100;
  if (ratio < 0.2) return (ratio / 0.2) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
};

export const calculateSleepScore = (sleep: SleepMetrics): number => {
  const durationScore = scoreDuration(sleep.durationMinutes);
  const deepScore = scoreDeepSleep(sleep.deepSleepRatio);
  const remScore = scoreRemSleep(sleep.remSleepRatio);

  return durationScore * 0.5 + deepScore * 0.3 + remScore * 0.2;
};

// ========================================
// Rhythm Score (15%)
// ========================================

const consistencyScore = (stddevMinutes: number): number => {
  if (stddevMinutes <= 15) return 100; // 非常に安定
  if (stddevMinutes <= 30) return 85;  // 安定
  if (stddevMinutes <= 45) return 70;  // やや安定
  if (stddevMinutes <= 60) return 55;  // やや不安定
  if (stddevMinutes <= 90) return 40;  // 不安定
  return 25; // 非常に不安定
};

export const calculateRhythmScore = (rhythm: RhythmMetrics): number => {
  const bedtimeScore = consistencyScore(rhythm.bedtimeStddevMinutes);
  const wakeScore = consistencyScore(rhythm.wakeTimeStddevMinutes);

  return (bedtimeScore + wakeScore) / 2;
};

// ========================================
// Activity Score (10%)
// ========================================

export const calculateActivityScore = (activity: ActivityMetrics): number => {
  const goal = activity.goal ?? 8000;
  const ratio = activity.steps / goal;

  if (ratio >= 1.0) return 100;
  if (ratio >= 0.75) return 80 + (ratio - 0.75) * 80;
  if (ratio >= 0.5) return 60 + (ratio - 0.5) * 80;
  return ratio * 120;
};

// ========================================
// Tempo Score (Total)
// ========================================

export const calculateTempoScore = (
  hrvMetrics: HrvMetrics | null,
  sleepMetrics: SleepMetrics | null,
  rhythmMetrics: RhythmMetrics | null,
  activityMetrics: ActivityMetrics | null,
  isCalibrating: boolean = false
): TempoScoreResult => {
  // デフォルト値（キャリブレーション中）
  const hrvScore = hrvMetrics ? calculateHrvScore(hrvMetrics) : 70;
  const sleepScore = sleepMetrics ? calculateSleepScore(sleepMetrics) : 70;
  const rhythmScore = rhythmMetrics ? calculateRhythmScore(rhythmMetrics) : 70;
  const activityScore = activityMetrics ? calculateActivityScore(activityMetrics) : 70;

  // 重み付け計算
  const score = clamp(
    hrvScore * 0.40 +
    sleepScore * 0.35 +
    rhythmScore * 0.15 +
    activityScore * 0.10,
    0,
    100
  );

  return {
    score: Math.round(score),
    components: {
      hrvScore: Math.round(hrvScore),
      sleepScore: Math.round(sleepScore),
      rhythmScore: Math.round(rhythmScore),
      activityScore: Math.round(activityScore),
    },
    isCalibrating,
  };
};





