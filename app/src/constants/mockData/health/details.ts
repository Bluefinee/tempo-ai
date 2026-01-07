/**
 * Mock Health Data
 * HealthKit関連のモックデータ
 */

import type {
  HealthMetricHistory,
  BarChartDataPoint,
} from "../../../domain/models/healthHistory";
import { getAllScoreHistories } from "../../mockDataFactory";
import { toBarChartData } from "../../../utils/healthDataTransformer";
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
  stages: {
    stage: "deep" | "rem" | "light" | "awake";
    percentage: number;
  }[];
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
  weeklyPattern: { day: string; offset: number }[];
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
