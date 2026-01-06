/**
 * 活動量スコア計算
 * Swift ActivityScoreCalculator から移植
 */

import { ActivityMetrics } from '../models/healthMetrics';
import { Score, createScore } from '../models/score';

// 定数
const STEPS_WEIGHT = 0.6;
const EXERCISE_WEIGHT = 0.4;
const TARGET_STEPS = 8000;
const TARGET_EXERCISE_MINUTES = 30;

/**
 * 歩数スコアを計算
 */
const calculateStepScore = (steps: number): number => {
  const stepRatio = steps / TARGET_STEPS;

  if (stepRatio >= 1.0) {
    return 100;
  } else if (stepRatio >= 0.75) {
    // 80-100の範囲で線形補間
    return 80 + (stepRatio - 0.75) * 80;
  } else if (stepRatio >= 0.5) {
    // 60-80の範囲で線形補間
    return 60 + (stepRatio - 0.5) * 80;
  } else {
    // 0-60の範囲で線形補間
    return stepRatio * 120;
  }
};

/**
 * 運動時間スコアを計算
 */
const calculateExerciseScore = (minutes: number): number => {
  if (minutes >= 30) return 100;
  if (minutes >= 20) return 80;
  if (minutes >= 10) return 60;
  if (minutes >= 5) return 40;
  return 20;
};

/**
 * 活動量スコアを計算する
 * @param activity 活動量メトリクス
 * @returns 計算されたスコア（0-100）
 */
export const calculateActivityScore = (activity: ActivityMetrics): Score => {
  const stepScore = calculateStepScore(activity.stepsYesterday);
  const exerciseScore = calculateExerciseScore(activity.activeMinutesYesterday);

  const finalScore = stepScore * STEPS_WEIGHT + exerciseScore * EXERCISE_WEIGHT;

  return createScore(Math.round(finalScore));
};

// 目標値のエクスポート（設定画面などで使用）
export const ACTIVITY_TARGETS = {
  steps: TARGET_STEPS,
  exerciseMinutes: TARGET_EXERCISE_MINUTES,
};
