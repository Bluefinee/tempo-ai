/**
 * Mock Health Data
 * HealthKit関連のモックデータ
 */

import type {
  DailySnapshot,
  RealtimeMetrics,
  RealtimeHealthMetric,
} from "../../../domain/models/healthHistory";
import {
  formatDateString,
  getAllHealthMetricHistories,
} from "../../mockDataFactory";
import {
  calculateDeviationPercent,
} from "../../../utils/healthDataTransformer";

/**
 * モック日次スナップショットを生成
 * 朝1回算出、その日は固定の値
 */
export const createMockDailySnapshot = (): DailySnapshot => {
  const now = new Date();
  return {
    date: formatDateString(now),
    calculatedAt: now,
    scores: {
      recovery: 70,
      sleep: 85,
      rhythm: 92,
      energy: 78,
    },
  };
};

/**
 * モックリアルタイムメトリクスを生成
 * アプリ起動ごとに最新値を取得する想定
 */
export const createMockRealtimeMetrics = (): RealtimeMetrics => {
  const now = new Date();

  const createMetric = (
    value: number,
    unit: string,
    baseline: number
  ): RealtimeHealthMetric => ({
    value,
    unit,
    baseline,
    deviationPercent: calculateDeviationPercent(value, baseline),
    lastUpdated: now,
  });

  return {
    hrv: createMetric(82, "ms", 77),
    rhr: createMetric(59, "bpm", 59),
    respiratory: createMetric(11.2, "rpm", 11.0),
    spo2: createMetric(98, "%", 98),
    wristTemp: createMetric(36.4, "°C", 36.3),
  };
};

/** モック日次スナップショット（初期値） */
export const MOCK_DAILY_SNAPSHOT = createMockDailySnapshot();

/** モックリアルタイムメトリクス（初期値） */
export const MOCK_REALTIME_METRICS = createMockRealtimeMetrics();

/** すべてのヘルスメトリクス履歴（60日分） */
export const MOCK_HEALTH_METRIC_HISTORIES = getAllHealthMetricHistories("60D");

