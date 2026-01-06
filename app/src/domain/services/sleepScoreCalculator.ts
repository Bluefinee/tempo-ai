/**
 * 睡眠スコア計算
 * Swift SleepScoreCalculator から移植
 */

import { SleepMetrics, getSleepDerivedMetrics } from '../models/healthMetrics';
import { Score, createScore } from '../models/score';

// 定数
const DURATION_WEIGHT = 0.45;
const DEEP_SLEEP_WEIGHT = 0.35;
const REM_SLEEP_WEIGHT = 0.2;
const DURATION_WEIGHT_NO_REM = 0.55;
const DEEP_SLEEP_WEIGHT_NO_REM = 0.45;

/**
 * 睡眠時間スコアを計算
 */
const calculateDurationScore = (hours: number): number => {
  if (hours >= 7 && hours <= 8) return 100;
  if (hours >= 6 && hours < 7) return 80;
  if (hours > 8 && hours <= 9) return 90;
  if (hours >= 5 && hours < 6) return 60;
  return 40;
};

/**
 * 深い睡眠スコアを計算
 */
const calculateDeepSleepScore = (ratio: number): number => {
  if (ratio >= 0.15 && ratio <= 0.25) return 100;
  if (ratio >= 0.1 && ratio < 0.15) return 70;
  if (ratio > 0.25 && ratio <= 0.3) return 80;
  return 50;
};

/**
 * レム睡眠スコアを計算
 */
const calculateRemSleepScore = (ratio: number): number => {
  if (ratio >= 0.2 && ratio <= 0.25) return 100;
  if (ratio >= 0.15 && ratio < 0.2) return 80;
  if (ratio > 0.25 && ratio <= 0.3) return 85;
  return 60;
};

/**
 * 睡眠スコアを計算する
 * @param sleep 睡眠メトリクス
 * @returns 計算されたスコア（0-100）
 */
export const calculateSleepScore = (sleep: SleepMetrics): Score => {
  const derived = getSleepDerivedMetrics(sleep);
  const durationScore = calculateDurationScore(derived.durationHours);
  const deepScore = calculateDeepSleepScore(derived.deepSleepRatio);

  let finalScore: number;

  // レム睡眠データがない場合は重みを再配分
  if (sleep.remSleepMinutes === 0) {
    finalScore =
      durationScore * DURATION_WEIGHT_NO_REM + deepScore * DEEP_SLEEP_WEIGHT_NO_REM;
  } else {
    const remScore = calculateRemSleepScore(derived.remSleepRatio);
    finalScore =
      durationScore * DURATION_WEIGHT +
      deepScore * DEEP_SLEEP_WEIGHT +
      remScore * REM_SLEEP_WEIGHT;
  }

  return createScore(Math.round(finalScore));
};
