/**
 * 4つの独立スコア計算関数
 * Recovery, Sleep, Rhythm, Energy
 */

// ========================================
// Helper Functions
// ========================================

const clamp = (value: number, min: number, max: number): number => {
  return Math.min(Math.max(value, min), max);
};

const scoreRange = (value: number, min: number, max: number): number => {
  if (value >= min && value <= max) return 100;
  if (value < min) return (value / min) * 100;
  return Math.max(0, 100 - (value - max) * 200);
};

// ========================================
// 1. Recovery Score
// ========================================

/**
 * Recovery Score 計算
 * Recovery = HRV (60%) + RHR (20%) + Sleep Quality (20%)
 */
export interface RecoveryScoreInput {
  hrv: {
    current: number; // 現在のHRV (ms)
    baseline: number; // ベースライン (60日平均)
  };
  rhr: {
    current: number; // 現在のRHR (bpm)
    baseline: number; // ベースライン (60日平均)
  };
  sleepQuality: number; // Sleep Scoreから取得 (0-100)
}

export const calculateRecoveryScore = (input: RecoveryScoreInput): number => {
  // HRVスコア（60%）- 高いほど良い
  // ベースラインの70-130%の範囲で0-100点に変換
  const hrvRatio = input.hrv.current / input.hrv.baseline;
  const hrvScore = clamp(((hrvRatio - 0.7) / 0.6) * 100, 0, 100);

  // RHRスコア（20%）- 低いほど良い
  // ベースラインの85-115%の範囲で0-100点に変換（逆比）
  const rhrRatio = input.rhr.baseline / input.rhr.current;
  const rhrScore = clamp(((rhrRatio - 0.85) / 0.3) * 100, 0, 100);

  // 睡眠の質（20%）
  const sleepScore = input.sleepQuality;

  return Math.round(hrvScore * 0.6 + rhrScore * 0.2 + sleepScore * 0.2);
};

// ========================================
// 2. Sleep Score
// ========================================

/**
 * Sleep Score 計算
 * Sleep = Duration (40%) + Quality (40%) + Timing (20%)
 */
export interface SleepScoreInput {
  duration: {
    minutes: number; // 実際の睡眠時間 (分)
    targetMinutes: number; // 目標睡眠時間 (分、デフォルト450 = 7.5h)
  };
  stages: {
    deepMinutes: number;
    remMinutes: number;
    lightMinutes: number;
    awakeMinutes: number;
  };
  timing?: {
    // オプション（データがない場合はDurationとQualityのみで計算）
    actualBedtime: Date;
    targetBedtime: Date;
    actualWakeTime: Date;
    targetWakeTime: Date;
  };
}

export const calculateSleepScore = (input: SleepScoreInput): number => {
  const totalSleep =
    input.stages.deepMinutes +
    input.stages.remMinutes +
    input.stages.lightMinutes;

  // Duration Score (40%)
  const durationRatio = input.duration.minutes / input.duration.targetMinutes;
  const durationScore = clamp(durationRatio * 100, 0, 100);

  // Quality Score (40%)
  const deepRatio = input.stages.deepMinutes / totalSleep;
  const remRatio = input.stages.remMinutes / totalSleep;

  const deepScore = scoreRange(deepRatio, 0.15, 0.25); // 15-25%が理想
  const remScore = scoreRange(remRatio, 0.2, 0.25); // 20-25%が理想

  const qualityScore = deepScore * 0.5 + remScore * 0.5;

  // Timing Score (20%)
  let timingScore = 100; // デフォルト
  if (input.timing) {
    const bedtimeDeviation =
      Math.abs(
        input.timing.actualBedtime.getTime() -
          input.timing.targetBedtime.getTime()
      ) /
      (1000 * 60); // 分

    const wakeDeviation =
      Math.abs(
        input.timing.actualWakeTime.getTime() -
          input.timing.targetWakeTime.getTime()
      ) /
      (1000 * 60);

    timingScore = clamp(100 - (bedtimeDeviation + wakeDeviation) / 4, 0, 100);
  }

  return Math.round(
    durationScore * 0.4 + qualityScore * 0.4 + timingScore * 0.2
  );
};

// ========================================
// 3. Rhythm Score (既存実装を使用)
// ========================================

/**
 * Rhythm Score 計算
 * Rhythm = Bedtime Consistency (50%) + Wake Time Consistency (50%)
 */
export interface RhythmScoreInput {
  bedtimeStddevMinutes: number;
  wakeTimeStddevMinutes: number;
}

export const calculateRhythmScore = (input: RhythmScoreInput): number => {
  const consistencyScore = (stddevMinutes: number): number => {
    if (stddevMinutes <= 15) return 100;
    if (stddevMinutes <= 30) return 85;
    if (stddevMinutes <= 45) return 70;
    if (stddevMinutes <= 60) return 55;
    if (stddevMinutes <= 90) return 40;
    return 25;
  };

  const bedtimeScore = consistencyScore(input.bedtimeStddevMinutes);
  const wakeScore = consistencyScore(input.wakeTimeStddevMinutes);

  return Math.round((bedtimeScore + wakeScore) / 2);
};

// ========================================
// 4. Energy Score
// ========================================

/**
 * Energy Score 計算
 * Energy = Recovery (50%) + Sleep (40%) + Weather (10%)
 */
export interface EnergyScoreInput {
  recovery: number; // Recovery Score (0-100)
  sleep: number; // Sleep Score (0-100)
  weather: {
    pressure: number; // hPa
    pressureTrend: 'rising' | 'stable' | 'falling';
  };
}

export const calculateEnergyScore = (input: EnergyScoreInput): number => {
  // ベーススコア（Recovery 50%, Sleep 40%）
  const baseScore = input.recovery * 0.5 + input.sleep * 0.4;

  // 天気補正（10%）
  let weatherFactor = 100;

  if (
    input.weather.pressureTrend === 'falling' &&
    input.weather.pressure < 1010
  ) {
    weatherFactor -= 20; // 気圧急低下: -20%
  } else if (input.weather.pressureTrend === 'rising') {
    weatherFactor += 5; // 気圧上昇: +5%
  }

  const weatherScore = clamp(weatherFactor, 0, 100);

  return Math.round(baseScore + weatherScore * 0.1);
};

