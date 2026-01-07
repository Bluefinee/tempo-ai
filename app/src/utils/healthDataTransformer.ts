/**
 * ヘルスデータ変換ユーティリティ
 *
 * HealthKit 形式（DailyHealthSample）から UI 表示形式（BarChart/AreaChart）への
 * 変換関数を提供します。
 *
 * @see docs/plans/healthkit-mock-data-improvement.md
 */

import {
  DailyHealthSample,
  HealthTimeRange,
  BarChartDataPoint,
  AreaChartDataPoint,
  TrendDirection,
} from "../domain/models/healthHistory";

// =============================================================================
// 定数
// =============================================================================

/** 日本語の曜日ラベル（日曜始まり） */
const JAPANESE_WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"] as const;

/** 英語の曜日ラベル（日曜始まり） */
const ENGLISH_WEEKDAYS = ["S", "M", "T", "W", "T", "F", "S"] as const;

// =============================================================================
// BarChart 用変換
// =============================================================================

/**
 * DailyHealthSample 配列を BarChart 用データに変換
 *
 * @param samples - サンプル配列
 * @param timeRange - 時間範囲
 * @param locale - ロケール（'ja' | 'en'）
 * @returns BarChart 用データポイント配列
 *
 * @example
 * const chartData = toBarChartData(samples, '7D', 'ja');
 * // [{ label: '月', value: 70 }, { label: '火', value: 75 }, ...]
 */
export const toBarChartData = (
  samples: DailyHealthSample[],
  timeRange: HealthTimeRange,
  locale: "ja" | "en" = "ja",
): BarChartDataPoint[] => {
  const weekdays = locale === "ja" ? JAPANESE_WEEKDAYS : ENGLISH_WEEKDAYS;

  if (timeRange === "7D") {
    // 7日間: 曜日ラベル
    const relevantSamples = samples.slice(-7);
    return relevantSamples.map((sample) => ({
      label: weekdays[sample.date.getDay()],
      value: Math.round(sample.value),
    }));
  }

  // 30D/60D: 日付番号ラベル
  return samples.map((_, index) => ({
    label: String(index + 1),
    value: Math.round(samples[index].value),
  }));
};

// =============================================================================
// AreaChart 用変換
// =============================================================================

/**
 * DailyHealthSample 配列を AreaChart 用データに変換
 *
 * @param samples - サンプル配列
 * @param timeRange - 時間範囲
 * @returns AreaChart 用データポイント配列
 *
 * @example
 * const chartData = toAreaChartData(samples, '7D');
 * // [{ day: 'M', value: 70 }, { day: 'T', value: 75 }, ...]
 */
export const toAreaChartData = (
  samples: DailyHealthSample[],
  timeRange: HealthTimeRange,
): AreaChartDataPoint[] => {
  if (timeRange === "7D") {
    // 7日間: 英語曜日ラベル
    const relevantSamples = samples.slice(-7);
    return relevantSamples.map((sample) => ({
      day: ENGLISH_WEEKDAYS[sample.date.getDay()],
      value: Math.round(sample.value * 10) / 10,
    }));
  }

  if (timeRange === "30D") {
    // 30日間: 週ラベルに集約
    const weeklyData = aggregateByWeek(samples);
    return weeklyData.map((week, index) => ({
      day: index === weeklyData.length - 1 ? "Now" : `W${index + 1}`,
      value: week.value,
    }));
  }

  // 60D: 2週間ラベルに集約
  const biWeeklyData = aggregateByBiWeek(samples);
  const labels = ["8w", "6w", "4w", "2w", "Now"];
  return biWeeklyData.map((period, index) => ({
    day: labels[index] || `${8 - index * 2}w`,
    value: period.value,
  }));
};

// =============================================================================
// 集約ユーティリティ
// =============================================================================

/**
 * サンプルを週単位で集約
 * @param samples - サンプル配列
 * @returns 週ごとの平均値配列
 */
const aggregateByWeek = (samples: DailyHealthSample[]): { value: number }[] => {
  const weeks: number[][] = [];
  let currentWeek: number[] = [];

  samples.forEach((sample, index) => {
    currentWeek.push(sample.value);
    if ((index + 1) % 7 === 0 || index === samples.length - 1) {
      weeks.push([...currentWeek]);
      currentWeek = [];
    }
  });

  return weeks.map((week) => ({
    value:
      Math.round((week.reduce((a, b) => a + b, 0) / week.length) * 10) / 10,
  }));
};

/**
 * サンプルを2週間単位で集約
 * @param samples - サンプル配列
 * @returns 2週間ごとの平均値配列
 */
const aggregateByBiWeek = (
  samples: DailyHealthSample[],
): { value: number }[] => {
  const periods: number[][] = [];
  let currentPeriod: number[] = [];

  samples.forEach((sample, index) => {
    currentPeriod.push(sample.value);
    if ((index + 1) % 14 === 0 || index === samples.length - 1) {
      periods.push([...currentPeriod]);
      currentPeriod = [];
    }
  });

  return periods.map((period) => ({
    value:
      Math.round((period.reduce((a, b) => a + b, 0) / period.length) * 10) / 10,
  }));
};

// =============================================================================
// トレンド計算
// =============================================================================

/**
 * サンプルからトレンド方向を計算
 *
 * 直近7日と前の7日を比較し、5%以上の変化があれば
 * improving/declining、それ以外は stable を返す。
 *
 * @param samples - サンプル配列
 * @returns トレンド方向
 */
export const calculateTrendFromSamples = (
  samples: DailyHealthSample[],
): TrendDirection => {
  if (samples.length < 7) return "stable";

  const recent = samples.slice(-7);
  const previous = samples.slice(-14, -7);

  if (previous.length === 0) return "stable";

  const recentAvg = recent.reduce((a, b) => a + b.value, 0) / recent.length;
  const previousAvg =
    previous.reduce((a, b) => a + b.value, 0) / previous.length;

  if (previousAvg === 0) return "stable";

  const changePercent = ((recentAvg - previousAvg) / previousAvg) * 100;

  if (changePercent > 5) return "improving";
  if (changePercent < -5) return "declining";
  return "stable";
};

/**
 * トレンド方向を日本語ラベルに変換
 * @param trend - トレンド方向
 * @returns 日本語ラベル
 */
export const getTrendLabel = (
  trend: TrendDirection,
  locale: "ja" | "en" = "ja",
): string => {
  const labels = {
    ja: {
      improving: "上昇傾向",
      stable: "安定",
      declining: "下降傾向",
    },
    en: {
      improving: "Improving",
      stable: "Stable",
      declining: "Declining",
    },
  };
  return labels[locale][trend];
};

// =============================================================================
// フィルタリング
// =============================================================================

/**
 * 時間範囲でサンプルをフィルタリング
 *
 * @param samples - サンプル配列
 * @param timeRange - 時間範囲
 * @returns フィルタされたサンプル配列
 */
export const filterByTimeRange = (
  samples: DailyHealthSample[],
  timeRange: HealthTimeRange,
): DailyHealthSample[] => {
  const days = timeRange === "7D" ? 7 : timeRange === "30D" ? 30 : 60;
  return samples.slice(-days);
};

/**
 * 時間範囲を日数に変換
 * @param timeRange - 時間範囲
 * @returns 日数
 */
export const timeRangeToDays = (timeRange: HealthTimeRange): number => {
  return timeRange === "7D" ? 7 : timeRange === "30D" ? 30 : 60;
};

// =============================================================================
// 統計計算
// =============================================================================

/**
 * サンプルの平均値を計算
 * @param samples - サンプル配列
 * @returns 平均値（小数点1桁）
 */
export const calculateAverage = (samples: DailyHealthSample[]): number => {
  if (samples.length === 0) return 0;
  const sum = samples.reduce((acc, s) => acc + s.value, 0);
  return Math.round((sum / samples.length) * 10) / 10;
};

/**
 * サンプルの最小値を取得
 * @param samples - サンプル配列
 * @returns 最小値
 */
export const findMinValue = (samples: DailyHealthSample[]): number => {
  if (samples.length === 0) return 0;
  return Math.min(...samples.map((s) => s.value));
};

/**
 * サンプルの最大値を取得
 * @param samples - サンプル配列
 * @returns 最大値
 */
export const findMaxValue = (samples: DailyHealthSample[]): number => {
  if (samples.length === 0) return 0;
  return Math.max(...samples.map((s) => s.value));
};

/**
 * ベースラインからの乖離率を計算
 * @param currentValue - 現在値
 * @param baseline - ベースライン
 * @returns 乖離率（%）
 */
export const calculateDeviationPercent = (
  currentValue: number,
  baseline: number,
): number => {
  if (baseline === 0) return 0;
  return Math.round(((currentValue - baseline) / baseline) * 100 * 10) / 10;
};

/**
 * 乖離率をフォーマット
 * @param deviationPercent - 乖離率
 * @returns フォーマットされた文字列（例: "+5%", "-3%", "0%"）
 */
export const formatDeviationPercent = (deviationPercent: number): string => {
  if (deviationPercent > 0) return `+${deviationPercent}%`;
  if (deviationPercent < 0) return `${deviationPercent}%`;
  return "0%";
};
