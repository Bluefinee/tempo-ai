/**
 * リズムスコア計算
 * Swift RhythmScoreCalculator から移植
 */

import { RhythmAnalysis, RhythmStatus, Score, createScore } from '../models/score';

// 定数 (手首体温あり)
const BEDTIME_WEIGHT_WITH_TEMP = 0.35;
const WAKE_TIME_WEIGHT_WITH_TEMP = 0.35;
const TEMPERATURE_WEIGHT = 0.2;
const STAGE_TRANSITION_WEIGHT = 0.1;

// 定数 (手首体温なし)
const BEDTIME_WEIGHT_NO_TEMP = 0.45;
const WAKE_TIME_WEIGHT_NO_TEMP = 0.45;

// デフォルト値
const DEFAULT_STAGE_TRANSITION_SCORE = 70.0;

// 体温ステータス
type TemperatureStatus = 'stable' | 'slightlyVariable' | 'variable';

/**
 * 体温ステータスからスコアを算出
 */
const calculateTemperatureScore = (status: TemperatureStatus): number => {
  switch (status) {
    case 'stable':
      return 100;
    case 'slightlyVariable':
      return 70;
    case 'variable':
      return 40;
  }
};

/**
 * 体温偏差からステータスを取得
 * @param deviation 手首体温偏差（°C）
 * @returns 体温ステータス
 */
export const getTemperatureStatus = (deviation: number): TemperatureStatus => {
  const absDeviation = Math.abs(deviation);
  if (absDeviation <= 0.2) return 'stable';
  if (absDeviation <= 0.5) return 'slightlyVariable';
  return 'variable';
};

/**
 * リズムスコアを計算する
 * @param analysis リズム分析データ
 * @param wristTemp 手首体温情報（オプション）
 * @returns 計算されたスコア（0-100）
 */
export const calculateRhythmScore = (
  analysis: RhythmAnalysis,
  wristTempDeviation?: number
): Score => {
  const bedtimeScore = analysis.bedtimeConsistencyScore;
  const wakeTimeScore = analysis.wakeTimeConsistencyScore;
  const stageScore = DEFAULT_STAGE_TRANSITION_SCORE;

  let finalScore: number;

  if (wristTempDeviation !== undefined) {
    const tempStatus = getTemperatureStatus(wristTempDeviation);
    const tempScore = calculateTemperatureScore(tempStatus);
    finalScore =
      bedtimeScore * BEDTIME_WEIGHT_WITH_TEMP +
      wakeTimeScore * WAKE_TIME_WEIGHT_WITH_TEMP +
      tempScore * TEMPERATURE_WEIGHT +
      stageScore * STAGE_TRANSITION_WEIGHT;
  } else {
    finalScore =
      bedtimeScore * BEDTIME_WEIGHT_NO_TEMP +
      wakeTimeScore * WAKE_TIME_WEIGHT_NO_TEMP +
      stageScore * STAGE_TRANSITION_WEIGHT;
  }

  return createScore(Math.round(finalScore));
};

/**
 * 一貫性スコアを標準偏差から計算
 * 標準偏差が0分の場合100点、30分以上で0点に近づく
 */
export const calculateConsistencyScore = (stddevMinutes: number): number => {
  const maxStddev = 60; // 60分以上は最低点
  const normalized = Math.min(stddevMinutes, maxStddev) / maxStddev;
  return Math.round(100 * (1 - normalized));
};

/**
 * リズム分析を作成
 */
export const createRhythmAnalysis = (
  bedtimeStddevMinutes: number,
  wakeTimeStddevMinutes: number,
  consecutiveStableDays: number
): RhythmAnalysis => {
  const bedtimeConsistencyScore = calculateConsistencyScore(bedtimeStddevMinutes);
  const wakeTimeConsistencyScore = calculateConsistencyScore(wakeTimeStddevMinutes);
  const isStable = bedtimeStddevMinutes <= 30 && wakeTimeStddevMinutes <= 30;

  let status: RhythmStatus;
  if (isStable && consecutiveStableDays >= 3) {
    status = 'stable';
  } else if (consecutiveStableDays >= 1) {
    status = 'recovering';
  } else {
    status = 'unstable';
  }

  return {
    bedtimeStddevMinutes,
    wakeTimeStddevMinutes,
    consecutiveStableDays,
    status,
    isStable,
    bedtimeConsistencyScore,
    wakeTimeConsistencyScore,
  };
};
