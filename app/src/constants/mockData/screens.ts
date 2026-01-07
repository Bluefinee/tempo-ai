/**
 * Mock Screen Data
 * 各画面で使用するモックデータ
 */

import { Sun, Moon } from "lucide-react-native";
import { Colors } from "../../theme";
import { MOCK_AI_RESPONSE } from "./aiResponse";

/**
 * 気圧トレンド型
 */
export type PressureTrend = "rising" | "stable" | "falling";

/**
 * 環境データ型（API準備用）
 * 将来的にはWeather APIから動的に取得
 */
export interface EnvironmentData {
  // 日の出・日の入り
  sunrise: string; // "6:50" 形式
  sunset: string; // "16:48" 形式
  sunriseTime: Date; // フルDate（計算用）
  sunsetTime: Date; // フルDate（計算用）
  dayLengthMinutes: number; // 日照時間（分）
  location: string;
  // 天気
  weather: {
    condition: string; // 天気状態（晴れ、曇り等）
    temperature: number; // 気温 °C
    humidity: number; // 湿度 %
  };
  // 気圧
  pressure: {
    value: number; // 気圧 hPa
    trend: PressureTrend; // トレンド
    change24h: number; // 24時間変化 hPa
  };
  // UV指数
  uv: {
    index: number; // UVインデックス (0-11+)
    level: string; // レベル（弱い、中程度等）
  };
  // 月齢
  moonPhase: {
    phase: string; // 月相（新月、満月等）
    illumination: number; // 輝面比 0-100%
  };
}

/**
 * 環境データを取得（現在はモック、将来API対応）
 * @param _latitude 緯度（将来のAPI用）
 * @param _longitude 経度（将来のAPI用）
 * @returns 環境データ
 */
export const getEnvironmentData = (
  _latitude?: number,
  _longitude?: number,
): EnvironmentData => {
  // TODO: 実APIからの取得に置き換え
  // const response = await fetch(`/api/environment?lat=${latitude}&lon=${longitude}`);
  const today = new Date();
  const sunriseTime = new Date(today);
  sunriseTime.setHours(6, 50, 0, 0);
  const sunsetTime = new Date(today);
  sunsetTime.setHours(16, 48, 0, 0);

  return {
    // 日の出・日の入り
    sunrise: "6:50",
    sunset: "16:48",
    sunriseTime,
    sunsetTime,
    dayLengthMinutes: Math.round(
      (sunsetTime.getTime() - sunriseTime.getTime()) / 60000,
    ),
    location: "東京",
    // 天気
    weather: {
      condition: "晴れ",
      temperature: 8,
      humidity: 45,
    },
    // 気圧
    pressure: {
      value: 1018,
      trend: "stable",
      change24h: 2,
    },
    // UV指数
    uv: {
      index: 3,
      level: "中程度",
    },
    // 月齢
    moonPhase: {
      phase: "上弦の月",
      illumination: 48,
    },
  };
};

/**
 * TODAY SCREEN MOCK DATA
 * 画面表示用に整形したデータ（MOCK_AI_RESPONSEから派生）
 */
export const MOCK_TODAY = {
  // AI Insight カード用
  aiMessage: {
    title: MOCK_AI_RESPONSE.todayInsight.title,
    body: MOCK_AI_RESPONSE.todayInsight.summary,
  },
  // Today's One Thing 用
  oneThing: {
    icon: MOCK_AI_RESPONSE.todayOneThing.icon,
    action: MOCK_AI_RESPONSE.todayOneThing.action,
    summary: MOCK_AI_RESPONSE.todayOneThing.summary,
    time: MOCK_AI_RESPONSE.todayOneThing.time,
  },
  // Related Insight 用
  insight: {
    label: MOCK_AI_RESPONSE.relatedInsight.label,
    text: MOCK_AI_RESPONSE.relatedInsight.text,
  },
  // スコア（フロントエンド計算）
  scores: {
    recovery: 70,
    sleep: 85,
    rhythm: 92,
    energy: 78,
  },
  // Health指標（フロントエンド計算）
  health: {
    hrv: { value: 82, unit: "ms", baseline: 77, deviation: "+6%" },
    rhr: { value: 59, unit: "bpm", baseline: 59, deviation: "0%" },
    sleep: {
      duration: "7時間8分",
      deepSleep: "1時間45分",
      deepSleepPercent: 23,
      remSleep: "1時間35分",
      remSleepPercent: 22,
      bedtime: "23:15",
      wakeTime: "06:45",
    },
  },
};

/**
 * RHYTHM SCREEN MOCK DATA
 */
export const MOCK_RHYTHM = {
  // 現在時刻インジケーター用
  currentTime: "10:42",
  // Upcoming Windows
  upcomingWindows: [
    {
      type: "peak" as const,
      icon: Sun,
      iconBg: Colors.amber[100],
      iconColor: Colors.amber[600],
      title: "Peak Focus",
      time: "現在 — 12:00",
      description:
        "複雑な問題解決や集中力を要する作業にぜひ取り組んでみてください。認知パフォーマンスが最大化される時間帯です。",
      active: true,
    },
    {
      type: "windDown" as const,
      icon: Moon,
      iconBg: Colors.indigo[100],
      iconColor: Colors.indigo[600],
      title: "Wind Down",
      time: "21:30 — 7:00",
      description:
        "照明を暗くし、画面を控えて睡眠の準備をしていきましょう。体が休息モードに入る時間帯です。",
      active: false,
    },
  ],
  // 環境データ - getEnvironmentData()で動的取得推奨
  ...getEnvironmentData(),
};

/**
 * Alert Type
 */
export type AlertType =
  | "recovery_complete"
  | "late_caffeine"
  | "weekend_jetlag";

/**
 * INSIGHTS SCREEN MOCK DATA
 */
export const MOCK_INSIGHTS = {
  weeklyScores: [40, 60, 75, 45, 80, 90, 70],
  avgScore: 74,
  todayIndex: 1, // 火曜日 (0 = 月曜日)
  // Top Discovery（AIが生成）
  topDiscovery: {
    title: "18時以降のウォーキングで深い睡眠が向上",
    description:
      "夕方に15分以上歩いた日は、深い睡眠スコアが18%高くなる傾向があります。",
  },
  // Recent Alerts（システム生成）
  recentAlerts: [
    {
      id: "1",
      type: "recovery_complete" as const,
      title: "回復完了",
      desc: "昨日のワークアウト後、HRVが基準値に戻りました。",
      time: "今日",
    },
    {
      id: "2",
      type: "late_caffeine" as const,
      title: "遅い時間のカフェイン",
      desc: "16時のコーヒーが入眠を45分遅らせた可能性があります。午後のカフェインは控えめにしてみてください。",
      time: "昨日",
    },
    {
      id: "3",
      type: "weekend_jetlag" as const,
      title: "週末の時差ボケ",
      desc: "今週末、起床時間が2時間ずれました。平日との差を少しずつ縮めていきましょう。",
      time: "日曜",
    },
  ],
};

/**
 * SETTINGS SCREEN MOCK DATA
 */
export const MOCK_SETTINGS = {
  profile: {
    name: "太郎",
    status: "キャリブレーション中...",
    initials: "T",
  },
  rhythm: {
    targetBedtime: "23:00",
    targetWakeUp: "7:00",
  },
  preferences: {
    notifications: true,
    haptics: true,
  },
  dataSource: {
    healthKit: true,
  },
};

/**
 * BREATHE SCREEN MOCK DATA
 */
export const MOCK_BREATHE = {
  technique: {
    name: "レゾナンス",
    pattern: "4-7-8 カーム",
  },
  phaseDurations: {
    inhale: 4,
    hold: 7,
    exhale: 8,
  },
};

/**
 * Time Period Type
 */
export type TimePeriod = "weekly" | "monthly";
