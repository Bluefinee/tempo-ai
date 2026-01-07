/**
 * モックデータファクトリ
 *
 * HealthKit Statistics Query 形式のモックデータを生成するためのファクトリ関数群。
 * シード値を指定することで再現可能なデータを生成できます。
 *
 * @see docs/plans/healthkit-mock-data-improvement.md
 */

import {
  DailyHealthSample,
  HealthMetricHistory,
  HealthMetricType,
  HealthTimeRange,
  DEFAULT_TYPICAL_RANGES,
  TrendDirection,
} from '../domain/models/healthHistory';

// =============================================================================
// 日付生成ユーティリティ
// =============================================================================

/**
 * 過去 N 日分の Date 配列を生成
 * @param days - 生成する日数
 * @returns Date 配列（古い順）
 */
export const generateDateRange = (days: number): Date[] => {
  const dates: Date[] = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    dates.push(date);
  }
  return dates;
};

/**
 * 日付を YYYY-MM-DD 形式の文字列に変換
 * @param date - 変換する日付
 * @returns YYYY-MM-DD 形式の文字列
 */
export const formatDateString = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

// =============================================================================
// 乱数生成（シード付き）
// =============================================================================

/**
 * シード付き疑似乱数生成器
 * 同じシードで同じ結果を返すため、テストで再現可能
 * @param seed - シード値
 * @returns 0-1 の間の数値
 */
export const seededRandom = (seed: number): number => {
  const x = Math.sin(seed * 12.9898 + seed * 78.233) * 43758.5453;
  return x - Math.floor(x);
};

/**
 * 範囲内のシード付き乱数を生成
 * @param seed - シード値
 * @param min - 最小値
 * @param max - 最大値
 * @returns min-max の間の数値
 */
export const seededRandomInRange = (
  seed: number,
  min: number,
  max: number
): number => {
  return min + seededRandom(seed) * (max - min);
};

// =============================================================================
// サンプルデータ生成
// =============================================================================

/**
 * リアルな日次サンプルデータを生成
 *
 * 基準値と分散を指定して、自然な変動を持つデータを生成します。
 * シード値を指定することで再現可能なデータを得られます。
 *
 * @param baseValue - 基準値（平均値）
 * @param variance - 分散（基準値からの最大変動幅）
 * @param days - 生成する日数
 * @param seed - シード値（デフォルト: 42）
 * @returns DailyHealthSample 配列
 */
export const generateDailySamples = (
  baseValue: number,
  variance: number,
  days: number,
  seed: number = 42
): DailyHealthSample[] => {
  const dates = generateDateRange(days);

  return dates.map((date, index) => {
    const random = seededRandom(seed + index);
    const variation = (random - 0.5) * variance * 2;
    const value = Math.round((baseValue + variation) * 10) / 10;

    return {
      date,
      value: Math.max(0, value), // 負の値を防ぐ
      sampleCount: Math.floor(seededRandomInRange(seed + index + 1000, 1, 20)),
    };
  });
};

// =============================================================================
// 統計計算
// =============================================================================

/**
 * サンプルからベースライン（平均値）を計算
 * @param samples - サンプル配列
 * @param days - 計算に使用する直近の日数
 * @returns 平均値（小数点1桁）
 */
export const calculateBaseline = (
  samples: DailyHealthSample[],
  days: number
): number => {
  const relevantSamples = samples.slice(-days);
  if (relevantSamples.length === 0) return 0;

  const sum = relevantSamples.reduce((acc, s) => acc + s.value, 0);
  return Math.round((sum / relevantSamples.length) * 10) / 10;
};

/**
 * サンプルから典型範囲（P5-P95）を計算
 *
 * 14日以上のデータがある場合は個人データから計算、
 * それ以下の場合はデフォルト値を使用。
 *
 * @param samples - サンプル配列
 * @param defaultRange - デフォルトの範囲
 * @returns 典型範囲とソース
 */
export const calculateTypicalRange = (
  samples: DailyHealthSample[],
  defaultRange: { min: number; max: number }
): { min: number; max: number; source: 'personal' | 'default' } => {
  if (samples.length < 14) {
    return { ...defaultRange, source: 'default' };
  }

  const values = samples.map((s) => s.value).sort((a, b) => a - b);
  const p5Index = Math.floor(values.length * 0.05);
  const p95Index = Math.floor(values.length * 0.95);

  return {
    min: Math.round(values[p5Index] * 10) / 10,
    max: Math.round(values[p95Index] * 10) / 10,
    source: 'personal',
  };
};

/**
 * サンプルからトレンド方向を計算
 *
 * 直近7日と前の7日を比較し、5%以上の変化があれば
 * improving/declining、それ以外は stable を返す。
 *
 * @param samples - サンプル配列
 * @returns トレンド方向
 */
export const calculateTrend = (samples: DailyHealthSample[]): TrendDirection => {
  if (samples.length < 7) return 'stable';

  const recent = samples.slice(-7);
  const previous = samples.slice(-14, -7);

  if (previous.length === 0) return 'stable';

  const recentAvg = recent.reduce((a, b) => a + b.value, 0) / recent.length;
  const previousAvg = previous.reduce((a, b) => a + b.value, 0) / previous.length;

  if (previousAvg === 0) return 'stable';

  const changePercent = ((recentAvg - previousAvg) / previousAvg) * 100;

  if (changePercent > 5) return 'improving';
  if (changePercent < -5) return 'declining';
  return 'stable';
};

// =============================================================================
// メトリクス別モックデータ生成設定
// =============================================================================

/**
 * メトリクス種別ごとの生成パラメータ
 * baseValue: 基準値
 * variance: 分散
 * seed: シード値（メトリクスごとに異なる値で一貫性を確保）
 */
const MOCK_GENERATOR_CONFIG: Record<
  HealthMetricType,
  { baseValue: number; variance: number; seed: number }
> = {
  hrv: { baseValue: 77, variance: 15, seed: 101 },
  rhr: { baseValue: 59, variance: 4, seed: 102 },
  respiratory: { baseValue: 11.2, variance: 0.8, seed: 103 },
  spo2: { baseValue: 98, variance: 1, seed: 104 },
  wristTemp: { baseValue: 36.4, variance: 0.3, seed: 105 },
  recoveryScore: { baseValue: 68, variance: 15, seed: 201 },
  sleepScore: { baseValue: 78, variance: 12, seed: 202 },
  rhythmScore: { baseValue: 88, variance: 8, seed: 203 },
  energyScore: { baseValue: 72, variance: 14, seed: 204 },
};

// =============================================================================
// メイン API
// =============================================================================

/**
 * 指定したメトリクスのモック履歴データを取得
 *
 * @param metricType - メトリクス種別
 * @param timeRange - 時間範囲（デフォルト: '60D'）
 * @returns HealthMetricHistory
 *
 * @example
 * const hrvHistory = getMockMetricHistory('hrv', '30D');
 * console.log(hrvHistory.baseline); // 77.2
 * console.log(hrvHistory.samples.length); // 30
 */
export const getMockMetricHistory = (
  metricType: HealthMetricType,
  timeRange: HealthTimeRange = '60D'
): HealthMetricHistory => {
  const days = timeRange === '7D' ? 7 : timeRange === '30D' ? 30 : 60;
  const config = MOCK_GENERATOR_CONFIG[metricType];

  if (!config) {
    throw new Error(`Unknown metric type: ${metricType}`);
  }

  const samples = generateDailySamples(
    config.baseValue,
    config.variance,
    days,
    config.seed
  );

  const defaultRange = DEFAULT_TYPICAL_RANGES[metricType];

  return {
    metricType,
    samples,
    baseline: calculateBaseline(samples, 60),
    typicalRange: calculateTypicalRange(samples, defaultRange),
    lastUpdated: new Date(),
  };
};

/**
 * すべてのスコアメトリクスのモック履歴データを一括取得
 *
 * @param timeRange - 時間範囲（デフォルト: '60D'）
 * @returns スコア種別をキーとした HealthMetricHistory のオブジェクト
 */
export const getAllScoreHistories = (
  timeRange: HealthTimeRange = '60D'
): Record<
  'recoveryScore' | 'sleepScore' | 'rhythmScore' | 'energyScore',
  HealthMetricHistory
> => {
  return {
    recoveryScore: getMockMetricHistory('recoveryScore', timeRange),
    sleepScore: getMockMetricHistory('sleepScore', timeRange),
    rhythmScore: getMockMetricHistory('rhythmScore', timeRange),
    energyScore: getMockMetricHistory('energyScore', timeRange),
  };
};

/**
 * すべてのヘルスメトリクスのモック履歴データを一括取得
 *
 * @param timeRange - 時間範囲（デフォルト: '60D'）
 * @returns メトリクス種別をキーとした HealthMetricHistory のオブジェクト
 */
export const getAllHealthMetricHistories = (
  timeRange: HealthTimeRange = '60D'
): Record<'hrv' | 'rhr' | 'respiratory' | 'spo2' | 'wristTemp', HealthMetricHistory> => {
  return {
    hrv: getMockMetricHistory('hrv', timeRange),
    rhr: getMockMetricHistory('rhr', timeRange),
    respiratory: getMockMetricHistory('respiratory', timeRange),
    spo2: getMockMetricHistory('spo2', timeRange),
    wristTemp: getMockMetricHistory('wristTemp', timeRange),
  };
};
