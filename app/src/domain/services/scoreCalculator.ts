/**
 * スコア計算 Facade
 * 各スコア計算を統合して ConditionAssessment を返す
 */

import { HealthMetrics, RhythmAnalysis } from '../models';
import { Score, ConditionAssessment, createScore, DEFAULT_SCORE } from '../models/score';
import { calculateSleepScore } from './sleepScoreCalculator';
import { calculateAutonomicScore } from './autonomicScoreCalculator';
import { calculateRhythmScore } from './rhythmScoreCalculator';
import { calculateActivityScore } from './activityScoreCalculator';

/**
 * 全スコアを計算してコンディション評価を返す
 * @param metrics ヘルスメトリクス
 * @param rhythmAnalysis リズム分析データ
 * @returns コンディション評価
 */
export const calculateConditionAssessment = (
  metrics: HealthMetrics,
  rhythmAnalysis: RhythmAnalysis
): ConditionAssessment => {
  // 各スコアを計算（データがない場合はデフォルトスコア）
  const sleepScore = metrics.sleep ? calculateSleepScore(metrics.sleep) : DEFAULT_SCORE;

  const autonomicScore = metrics.hrv
    ? calculateAutonomicScore(metrics.hrv, metrics.sleep)
    : DEFAULT_SCORE;

  const rhythmScore = calculateRhythmScore(
    rhythmAnalysis,
    metrics.auxiliary?.wristTemperatureDeviation
  );

  const activityScore = metrics.activity
    ? calculateActivityScore(metrics.activity)
    : DEFAULT_SCORE;

  // 平均スコアを計算
  const averageScore = Math.round(
    (sleepScore.value + autonomicScore.value + rhythmScore.value + activityScore.value) / 4
  );

  // 全体ステータスを決定
  const overallStatus = createScore(averageScore).status;

  // 最も弱い領域を特定
  const scores = [
    { area: 'sleep' as const, value: sleepScore.value },
    { area: 'autonomic' as const, value: autonomicScore.value },
    { area: 'rhythm' as const, value: rhythmScore.value },
    { area: 'activity' as const, value: activityScore.value },
  ];
  const weakest = scores.reduce((min, current) =>
    current.value < min.value ? current : min
  );
  const weakestArea = weakest.value < 60 ? weakest.area : null;

  return {
    sleepScore,
    autonomicScore,
    rhythmScore,
    activityScore,
    averageScore,
    overallStatus,
    weakestArea,
  };
};

/**
 * スコア値のみを計算（簡易版）
 */
export const calculateScoreValues = (
  metrics: HealthMetrics,
  rhythmAnalysis: RhythmAnalysis
): { autonomic: number; sleep: number; rhythm: number; activity: number } => {
  const assessment = calculateConditionAssessment(metrics, rhythmAnalysis);
  return {
    autonomic: assessment.autonomicScore.value,
    sleep: assessment.sleepScore.value,
    rhythm: assessment.rhythmScore.value,
    activity: assessment.activityScore.value,
  };
};
