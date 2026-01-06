/**
 * 自律神経スコア計算
 * Swift AutonomicScoreCalculator から移植
 */

import { HRVMetrics, SleepMetrics, getSleepDerivedMetrics } from '../models/healthMetrics';
import { Score, createScore } from '../models/score';

// 定数
const BASE_SCORE = 70.0;
const INDUSTRY_AVERAGE_HRV = 50.0;
const DEEP_SLEEP_DEFICIENCY_THRESHOLD = 0.15;
const SLEEP_DURATION_DEFICIENCY_HOURS = 6.0;
const ADJUSTMENT_PENALTY = 5.0;

/**
 * 有効なベースライン値を取得（0以下の場合は業界平均を使用）
 */
const effectiveBaseline = (baseline: number): number => {
  return baseline > 0 ? baseline : INDUSTRY_AVERAGE_HRV;
};

/**
 * 生スコアを計算（HRVベースライン比較）
 */
const calculateRawScore = (hrv: HRVMetrics): number => {
  const baseline = effectiveBaseline(hrv.baseline30d);
  const hrvRatio = hrv.value / baseline;
  const deviation = (hrvRatio - 1.0) * 100;
  return BASE_SCORE + deviation;
};

/**
 * 睡眠データに基づく補正値を計算
 */
const calculateAdjustments = (sleep?: SleepMetrics): number => {
  if (!sleep) return 0;

  const derived = getSleepDerivedMetrics(sleep);
  let adjustment = 0;

  // 深い睡眠不足の補正
  if (derived.deepSleepRatio < DEEP_SLEEP_DEFICIENCY_THRESHOLD) {
    adjustment -= ADJUSTMENT_PENALTY;
  }

  // 睡眠時間不足の補正
  if (derived.durationHours < SLEEP_DURATION_DEFICIENCY_HOURS) {
    adjustment -= ADJUSTMENT_PENALTY;
  }

  return adjustment;
};

/**
 * 自律神経スコアを計算する
 * @param hrv HRVメトリクス
 * @param sleep 睡眠メトリクス（補正計算に使用、undefinedの場合は補正なし）
 * @returns 計算されたスコア（0-100）
 */
export const calculateAutonomicScore = (hrv: HRVMetrics, sleep?: SleepMetrics): Score => {
  const rawScore = calculateRawScore(hrv);
  const adjustments = calculateAdjustments(sleep);
  const finalScore = Math.round(rawScore + adjustments);

  return createScore(finalScore);
};
