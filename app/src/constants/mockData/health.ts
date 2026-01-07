/**
 * Mock Health Data
 * HealthKit関連のモックデータ
 */

import type {
  HealthMetrics,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  DailyScoreSnapshot,
  QuickAction,
  RecommendedAction,
  SimpleWeatherData,
} from "../../domain/models";
import type {
  HealthMetricHistory,
  DailySnapshot,
  RealtimeMetrics,
  RealtimeHealthMetric,
  BarChartDataPoint,
} from "../../domain/models/healthHistory";
import {
  getMockMetricHistory,
  getAllScoreHistories,
  getAllHealthMetricHistories,
  formatDateString,
} from "../mockDataFactory";
import {
  toBarChartData,
  calculateDeviationPercent,
} from "../../utils/healthDataTransformer";

/**
 * MOCK WEATHER DATA
 */
export const MOCK_WEATHER: SimpleWeatherData = {
  temp: 8,
  condition: "晴れ",
  pressure: 1018,
  pressureTrend: "stable",
  uv: 3,
  location: "東京",
};

/**
 * MOCK QUICK ACTIONS
 */
export const MOCK_QUICK_ACTIONS: QuickAction[] = [
  {
    id: "1",
    type: "activity",
    text: "昼食後に10分間の散歩",
    icon: "footprints",
  },
  { id: "2", type: "breathing", text: "1分間の深呼吸", icon: "wind" },
];

/**
 * MOCK RECOMMENDED ACTION
 */
export const MOCK_RECOMMENDED_ACTION: RecommendedAction = {
  type: "activity",
  message: "昼食後に10分間の散歩",
  icon: "footprints",
  displayName: "活動",
};

/**
 * MOCK SLEEP METRICS
 */
export const MOCK_SLEEP_METRICS: SleepMetrics = {
  bedtime: new Date("2025-01-05T23:15:00"),
  wakeTime: new Date("2025-01-06T06:45:00"),
  durationMinutes: 450,
  deepSleepMinutes: 105,
  remSleepMinutes: 90,
};

/**
 * MOCK HRV METRICS
 */
export const MOCK_HRV_METRICS: HRVMetrics = {
  value: 68,
  baseline30d: 55,
};

/**
 * MOCK ACTIVITY METRICS
 */
export const MOCK_ACTIVITY_METRICS: ActivityMetrics = {
  stepsYesterday: 8500,
  activeMinutesYesterday: 35,
};

/**
 * MOCK HEALTH METRICS
 */
export const MOCK_HEALTH_METRICS: HealthMetrics = {
  date: new Date(),
  sleep: MOCK_SLEEP_METRICS,
  hrv: MOCK_HRV_METRICS,
  activity: MOCK_ACTIVITY_METRICS,
  auxiliary: {
    daylightMinutesYesterday: 25,
    wristTemperatureDeviation: 0.3,
  },
};

/**
 * MOCK RHYTHM ANALYSIS
 */
export const MOCK_RHYTHM_ANALYSIS: RhythmAnalysis = {
  bedtimeStddevMinutes: 22,
  wakeTimeStddevMinutes: 18,
  consecutiveStableDays: 5,
  status: "stable",
  isStable: true,
  bedtimeConsistencyScore: 85,
  wakeTimeConsistencyScore: 88,
};

/**
 * MOCK WEEKLY SCORES
 */
export const MOCK_WEEKLY_SCORES: DailyScoreSnapshot[] = [
  {
    id: "1",
    date: new Date("2025-01-01"),
    recoveryScore: 78,
    sleepScore: 65,
    rhythmScore: 82,
    energyScore: 70,
  },
  {
    id: "2",
    date: new Date("2025-01-02"),
    recoveryScore: 80,
    sleepScore: 70,
    rhythmScore: 85,
    energyScore: 75,
  },
  {
    id: "3",
    date: new Date("2025-01-03"),
    recoveryScore: 75,
    sleepScore: 68,
    rhythmScore: 88,
    energyScore: 65,
  },
  {
    id: "4",
    date: new Date("2025-01-04"),
    recoveryScore: 82,
    sleepScore: 74,
    rhythmScore: 90,
    energyScore: 78,
  },
  {
    id: "5",
    date: new Date("2025-01-05"),
    recoveryScore: 85,
    sleepScore: 72,
    rhythmScore: 94,
    energyScore: 80,
  },
  {
    id: "6",
    date: new Date("2025-01-06"),
    recoveryScore: 85,
    sleepScore: 72,
    rhythmScore: 94,
    energyScore: 82,
  },
  {
    id: "7",
    date: new Date("2025-01-07"),
    recoveryScore: 88,
    sleepScore: 76,
    rhythmScore: 95,
    energyScore: 85,
  },
];

/**
 * HealthKit 対応版の詳細データ構造
 *
 * 特徴:
 * - rawHistory: Date 型を含む HealthKit 形式のデータ
 * - history: BarChart 互換形式への変換ゲッター
 * - ベースライン・典型範囲を含む
 */
export interface MockDetailRecovery {
  score: number;
  status: string;
  hrv: { value: number; unit: string; change: number; baseline: number };
  rhr: { value: number; unit: string; change: number; baseline: number };
  analysis: string;
  calculatedAt: string;
  rawHistory: HealthMetricHistory;
  history: {
    "7D": BarChartDataPoint[];
    "30D": BarChartDataPoint[];
    "60D": BarChartDataPoint[];
  };
  weeklyAverage: number;
}

export interface MockDetailSleep {
  score: number;
  duration: { hours: number; minutes: number; percentage: number };
  quality: { percentage: number };
  analysis: string;
  stages: Array<{
    stage: "deep" | "rem" | "light" | "awake";
    percentage: number;
  }>;
  timing: {
    bedtime: { actual: string; target: string; diff: string };
    wakeTime: { actual: string; target: string; diff: string };
  };
  rawHistory: HealthMetricHistory;
  history: {
    "7D": BarChartDataPoint[];
    "30D": BarChartDataPoint[];
    "60D": BarChartDataPoint[];
  };
}

export interface MockDetailRhythm {
  score: number;
  status: string;
  analysis: string;
  consistency: {
    bedtime: { target: string; deviation: string };
    wakeTime: { target: string; deviation: string };
  };
  contributingFactors: {
    bedtimeVariance: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    wakeVariance: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    weekendShift: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    socialJetlag: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
  };
  weeklyPattern: Array<{ day: string; offset: number }>;
  rawHistory: HealthMetricHistory;
  history: {
    "7D": BarChartDataPoint[];
    "30D": BarChartDataPoint[];
    "60D": BarChartDataPoint[];
  };
}

export interface MockDetailEnergy {
  score: number;
  status: string;
  analysis: string;
  contributingFactors: {
    recovery: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    sleep: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    activity: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
    weather: {
      value: number;
      label: string;
      trend: string;
      trendDirection: "up" | "down" | "stable";
      detail: string;
    };
  };
  peakFocus: { start: string; end: string };
  afternoonDip: { start: string; end: string };
  rawHistory: HealthMetricHistory;
  history: {
    "7D": BarChartDataPoint[];
    "30D": BarChartDataPoint[];
    "60D": BarChartDataPoint[];
  };
}

export interface MockDetail {
  recovery: MockDetailRecovery;
  sleep: MockDetailSleep;
  rhythm: MockDetailRhythm;
  energy: MockDetailEnergy;
}

/**
 * HealthKit 対応版のモックデータを生成
 * rawHistory は Date を含む HealthKit 形式、history は BarChart 互換形式
 */
const createMockDetail = (): MockDetail => {
  const scoreHistories = getAllScoreHistories("60D");

  return {
    recovery: {
      score: 70,
      status: "トレーニング準備OK",
      hrv: { value: 82, unit: "ms", change: 5, baseline: 77 },
      rhr: { value: 59, unit: "bpm", change: 0, baseline: 59 },
      analysis:
        "回復スコアは、HRVの日中平均82ms（5:39に取得、60日平均の77msより6%高い）と、安静時心拍数59bpm（22:06に取得、60日平均の59bpmと同等）に基づいています。",
      calculatedAt: "5:39",
      rawHistory: scoreHistories.recoveryScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          "7D": toBarChartData(samples.slice(-7), "7D", "ja"),
          "30D": toBarChartData(samples.slice(-30), "30D", "ja"),
          "60D": toBarChartData(samples, "60D", "ja"),
        };
      },
      weeklyAverage: 64,
    },
    sleep: {
      score: 85,
      duration: { hours: 7, minutes: 8, percentage: 80 },
      quality: { percentage: 85 },
      analysis:
        "睡眠時間は目標を下回りましたが、REMと深い睡眠は通常より多くなっています。身体が睡眠不足を補おうと、回復的なステージを優先しているようです。",
      stages: [
        { stage: "deep" as const, percentage: 23 },
        { stage: "rem" as const, percentage: 22 },
        { stage: "light" as const, percentage: 53 },
        { stage: "awake" as const, percentage: 2 },
      ],
      timing: {
        bedtime: { actual: "23:15", target: "23:00", diff: "15分遅れ" },
        wakeTime: { actual: "06:45", target: "07:00", diff: "15分早起き" },
      },
      rawHistory: scoreHistories.sleepScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          "7D": toBarChartData(samples.slice(-7), "7D", "ja"),
          "30D": toBarChartData(samples.slice(-30), "30D", "ja"),
          "60D": toBarChartData(samples, "60D", "ja"),
        };
      },
    },
    rhythm: {
      score: 92,
      status: "同期済み",
      analysis:
        "サーカディアンリズムが睡眠-覚醒サイクルとよく調和しています。この1週間、就寝時刻の一貫性が優れており、高いリズムスコアに貢献しています。",
      consistency: {
        bedtime: { target: "23:00", deviation: "±12分" },
        wakeTime: { target: "07:00", deviation: "±8分" },
      },
      contributingFactors: {
        bedtimeVariance: {
          value: 95,
          label: "就寝ばらつき",
          trend: "+3%",
          trendDirection: "up" as const,
          detail: "平均 ±12分 (目標±15分)",
        },
        wakeVariance: {
          value: 98,
          label: "起床ばらつき",
          trend: "+5%",
          trendDirection: "up" as const,
          detail: "平均 ±8分 (目標±15分)",
        },
        weekendShift: {
          value: 85,
          label: "週末シフト",
          trend: "安定",
          trendDirection: "stable" as const,
          detail: "週末の遅れ 25分",
        },
        socialJetlag: {
          value: 90,
          label: "社会的時差",
          trend: "-2%",
          trendDirection: "down" as const,
          detail: "平日-週末差 32分",
        },
      },
      weeklyPattern: [
        { day: "木", offset: 0 },
        { day: "金", offset: -10 },
        { day: "土", offset: 5 },
        { day: "日", offset: 0 },
        { day: "月", offset: 15 },
        { day: "火", offset: 5 },
        { day: "水", offset: 0 },
      ],
      rawHistory: scoreHistories.rhythmScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          "7D": toBarChartData(samples.slice(-7), "7D", "ja"),
          "30D": toBarChartData(samples.slice(-30), "30D", "ja"),
          "60D": toBarChartData(samples, "60D", "ja"),
        };
      },
    },
    energy: {
      score: 78,
      status: "適度なエネルギー",
      analysis:
        "回復度と睡眠データに基づくと、今日は良好なエネルギーを保てそうです。Peak Focus時間帯は9:00〜12:00です。Afternoon Dip（14:00〜16:00）は軽めのタスクに切り替えるのがおすすめです。",
      contributingFactors: {
        recovery: {
          value: 70,
          label: "回復",
          trend: "+5%",
          trendDirection: "up" as const,
          detail: "HRV 82ms (基準+6%)",
        },
        sleep: {
          value: 85,
          label: "睡眠",
          trend: "+3%",
          trendDirection: "up" as const,
          detail: "深い睡眠 1h45m",
        },
        activity: {
          value: 75,
          label: "アクティビティ",
          trend: "安定",
          trendDirection: "stable" as const,
          detail: "昨日 8,500歩",
        },
        weather: {
          value: 80,
          label: "天気",
          trend: "安定",
          trendDirection: "stable" as const,
          detail: "晴れ・気圧安定",
        },
      },
      peakFocus: { start: "09:00", end: "12:00" },
      afternoonDip: { start: "14:00", end: "16:00" },
      rawHistory: scoreHistories.energyScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          "7D": toBarChartData(samples.slice(-7), "7D", "ja"),
          "30D": toBarChartData(samples.slice(-30), "30D", "ja"),
          "60D": toBarChartData(samples, "60D", "ja"),
        };
      },
    },
  };
};

/** HealthKit 対応版のモック詳細データ */
export const MOCK_DETAIL = createMockDetail();

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

