/**
 * Mock Data - 開発・テスト用モックデータ
 *
 * このファイルは実APIからのレスポンスを模倣しています。
 * AI プロンプト仕様書（docs/specs/ai_prompt_spec.md）の出力形式に準拠。
 *
 * 実API接続時は、このファイルのMOCK_AI_RESPONSEをAPIレスポンスに置き換えるだけで移行可能です。
 */

import { Sun, Moon } from "lucide-react-native";
import { Colors } from "../theme";
import {
  UserProfile,
  SimpleWeatherData,
  QuickAction,
  RecommendedAction,
  HealthMetrics,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  DailyScoreSnapshot,
  AIResponse,
} from "../domain/models";

// =============================================================================
// AI RESPONSE MOCK DATA
// APIから返却されるレスポンス形式に完全準拠
// @see docs/specs/ai_prompt_spec.md Section 5.1 (良い日のシナリオ)
// =============================================================================

export const MOCK_AI_RESPONSE: AIResponse = {
  todayInsight: {
    title: "A Quiet Harmony",
    summary:
      "昨夜はしっかり回復できましたね。今日は晴れで気圧も安定しているので、体調は良好なはず。深い睡眠が十分に取れていて、自律神経も落ち着いた状態です。今日は少し負荷のかかる仕事にも取り組める余裕があります。午前中の集中力が特に高まっているので、大事なタスクは早めに片付けてしまいましょう。",
    whyThisMatters: {
      hrv: {
        headline: "HRVがベースラインより6%高い",
        explanation:
          "副交感神経がしっかり働いている証拠です。ストレスへの耐性が高く、落ち着いて判断できる状態にあります。",
      },
      sleep: {
        headline: "深い睡眠が1時間45分（23%）",
        explanation:
          "成長ホルモンの分泌が十分だったサインです。筋肉や細胞の修復がしっかり行われました。",
      },
      rhythm: {
        headline: "就寝が目標より15分遅れ",
        explanation:
          "許容範囲内のズレです。今日のコンディションにはほとんど影響していません。",
      },
    },
    whatThisMeansForToday:
      "9時〜12時のPeak Focus時間帯をぜひご活用ください。複雑な資料作成や重要な意思決定は、この時間帯に集中して取り組むのがおすすめです。午後は軽めのタスクに切り替えると、1日を通してエネルギーを維持できます。",
  },
  todayOneThing: {
    icon: "walking",
    action: "14時頃に5分だけ外を歩く",
    summary: "午後の眠気を防ぎ、夜の睡眠の質も上がります",
    time: "14:00",
    whyThisAction:
      "14時〜16時は、体内時計の影響で自然と眠気が出やすい時間帯です。今日は気圧が安定しているので、体が動きやすい日です。この「Afternoon Dip」のタイミングで軽く体を動かすと、コーヒーに頼らなくても覚醒度が戻ります。さらに、日中の適度な活動は夜のメラトニン分泌を助け、寝つきが良くなる効果もあります。",
    benefits: [
      "午後の集中力が回復する",
      "夜の寝つきが良くなる",
      "気分転換になる",
    ],
    howToDoIt: [
      "デスクを離れて外に出る",
      "5分ほど軽いペースで歩く",
      "できれば日光を浴びる",
    ],
    expectedBenefit: {
      text: "日中の短い散歩は、睡眠効率を10〜15%改善するという報告があります",
      source: "サーカディアンリズム研究",
    },
  },
  relatedInsight: {
    label: "Research Finding",
    text: "午前中の集中作業で生産性が23%向上",
    source: "時間生物学研究",
  },
};

// =============================================================================
// TODAY SCREEN MOCK DATA
// 画面表示用に整形したデータ（MOCK_AI_RESPONSEから派生）
// =============================================================================

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

// =============================================================================
// RHYTHM SCREEN MOCK DATA
// =============================================================================

/**
 * 気圧トレンド型
 */
export type PressureTrend = "up" | "stable" | "down";

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
  _longitude?: number
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
      (sunsetTime.getTime() - sunriseTime.getTime()) / 60000
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

// =============================================================================
// INSIGHTS SCREEN MOCK DATA
// =============================================================================

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

export type AlertType =
  | "recovery_complete"
  | "late_caffeine"
  | "weekend_jetlag";

// =============================================================================
// SETTINGS SCREEN MOCK DATA
// =============================================================================

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

// =============================================================================
// BREATHE SCREEN MOCK DATA
// =============================================================================

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


// =============================================================================
// HEALTH STORE MOCK DATA
// healthStore で使用されるモックデータ
// =============================================================================

export const MOCK_USER: UserProfile = {
  id: "mock_user_1",
  nickname: "太郎",
  age: 30,
  gender: "male",
  heightCm: 175,
  weightKg: 70,
  chronotype: "morning",
  targetBedtime: "23:00",
  occupation: "deskWork",
  exerciseFrequency: "twiceWeek",
  calibrationDaysCompleted: 7,
  createdAt: new Date(),
  updatedAt: new Date(),
};

// MOCK_SCORES は削除（計算結果を使用するため不要）
// スコアは healthStore.calculateDailyScores() で計算される

export const MOCK_WEATHER: SimpleWeatherData = {
  temp: 8,
  condition: "晴れ",
  pressure: 1018,
  pressureTrend: "stable",
  uv: 3,
  location: "東京",
};

export const MOCK_QUICK_ACTIONS: QuickAction[] = [
  {
    id: "1",
    type: "activity",
    text: "昼食後に10分間の散歩",
    icon: "footprints",
  },
  { id: "2", type: "breathing", text: "1分間の深呼吸", icon: "wind" },
];

export const MOCK_RECOMMENDED_ACTION: RecommendedAction = {
  type: "activity",
  message: "昼食後に10分間の散歩",
  icon: "footprints",
  displayName: "活動",
};

export const MOCK_SLEEP_METRICS: SleepMetrics = {
  bedtime: new Date("2025-01-05T23:15:00"),
  wakeTime: new Date("2025-01-06T06:45:00"),
  durationMinutes: 450,
  deepSleepMinutes: 105,
  remSleepMinutes: 90,
};

export const MOCK_HRV_METRICS: HRVMetrics = {
  value: 68,
  baseline30d: 55,
};

export const MOCK_ACTIVITY_METRICS: ActivityMetrics = {
  stepsYesterday: 8500,
  activeMinutesYesterday: 35,
};

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

export const MOCK_RHYTHM_ANALYSIS: RhythmAnalysis = {
  bedtimeStddevMinutes: 22,
  wakeTimeStddevMinutes: 18,
  consecutiveStableDays: 5,
  status: "stable",
  isStable: true,
  bedtimeConsistencyScore: 85,
  wakeTimeConsistencyScore: 88,
};

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

export type TimePeriod = "weekly" | "monthly";

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * 時間帯に応じた挨拶を取得（「さん」付き）
 * @param name ユーザー名（省略時は挨拶のみ）
 * @returns "こんにちは太郎さん" 形式
 */
export const getGreeting = (name?: string): string => {
  const hour = new Date().getHours();
  let greeting: string;
  if (hour >= 5 && hour < 12) {
    greeting = "おはようございます";
  } else if (hour >= 12 && hour < 17) {
    greeting = "こんにちは";
  } else if (hour >= 17 && hour < 21) {
    greeting = "こんばんは";
  } else {
    greeting = "お疲れさまです";
  }
  return name ? `${greeting}${name}さん` : greeting;
};

/**
 * 現在時刻を "HH:MM" 形式でフォーマット
 * @param date 日時（省略時は現在日時）
 * @returns "10:42" 形式
 */
export const formatTime = (date: Date = new Date()): string => {
  const hours = date.getHours();
  const minutes = date.getMinutes().toString().padStart(2, "0");
  return `${hours}:${minutes}`;
};

/**
 * 現在時刻を "現在 HH:MM" 形式でフォーマット
 * @param date 日時（省略時は現在日時）
 * @returns "現在 10:42" 形式
 */
export const formatCurrentTime = (date: Date = new Date()): string => {
  return `現在 ${formatTime(date)}`;
};

/**
 * 日付を日本語形式でフォーマット
 * @param date 日付（省略時は現在日時）
 * @returns "1月7日（火）" 形式
 */
export const formatDate = (date: Date = new Date()): string => {
  const weekdays = ["日", "月", "火", "水", "木", "金", "土"];
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const weekday = weekdays[date.getDay()];
  return `${month}月${day}日（${weekday}）`;
};

/**
 * 日付を英語形式でフォーマット（詩的タイトル用）
 * @param date 日付（省略時は現在日時）
 * @returns "Tuesday, January 7" 形式
 */
export const formatDateEnglish = (date: Date = new Date()): string => {
  const days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return `${days[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}`;
};

// =============================================================================
// MOCK_DETAIL - HealthKit 対応版
// =============================================================================

import {
  HealthMetricHistory,
  DailySnapshot,
  RealtimeMetrics,
  RealtimeHealthMetric,
  BarChartDataPoint,
} from '../domain/models/healthHistory';
import {
  getMockMetricHistory,
  getAllScoreHistories,
  getAllHealthMetricHistories,
  formatDateString,
} from './mockDataFactory';
import { toBarChartData, calculateDeviationPercent } from '../utils/healthDataTransformer';

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
    '7D': BarChartDataPoint[];
    '30D': BarChartDataPoint[];
    '60D': BarChartDataPoint[];
  };
  weeklyAverage: number;
}

export interface MockDetailSleep {
  score: number;
  duration: { hours: number; minutes: number; percentage: number };
  quality: { percentage: number };
  analysis: string;
  stages: Array<{ stage: 'deep' | 'rem' | 'light' | 'awake'; percentage: number }>;
  timing: {
    bedtime: { actual: string; target: string; diff: string };
    wakeTime: { actual: string; target: string; diff: string };
  };
  rawHistory: HealthMetricHistory;
  history: {
    '7D': BarChartDataPoint[];
    '30D': BarChartDataPoint[];
    '60D': BarChartDataPoint[];
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
    bedtimeVariance: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    wakeVariance: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    weekendShift: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    socialJetlag: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
  };
  weeklyPattern: Array<{ day: string; offset: number }>;
  rawHistory: HealthMetricHistory;
  history: {
    '7D': BarChartDataPoint[];
    '30D': BarChartDataPoint[];
    '60D': BarChartDataPoint[];
  };
}

export interface MockDetailEnergy {
  score: number;
  status: string;
  analysis: string;
  contributingFactors: {
    recovery: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    sleep: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    activity: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
    weather: { value: number; label: string; trend: string; trendDirection: 'up' | 'down' | 'stable'; detail: string };
  };
  peakFocus: { start: string; end: string };
  afternoonDip: { start: string; end: string };
  rawHistory: HealthMetricHistory;
  history: {
    '7D': BarChartDataPoint[];
    '30D': BarChartDataPoint[];
    '60D': BarChartDataPoint[];
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
  const scoreHistories = getAllScoreHistories('60D');

  return {
    recovery: {
      score: 70,
      status: 'トレーニング準備OK',
      hrv: { value: 82, unit: 'ms', change: 5, baseline: 77 },
      rhr: { value: 59, unit: 'bpm', change: 0, baseline: 59 },
      analysis:
        '回復スコアは、HRVの日中平均82ms（5:39に取得、60日平均の77msより6%高い）と、安静時心拍数59bpm（22:06に取得、60日平均の59bpmと同等）に基づいています。',
      calculatedAt: '5:39',
      rawHistory: scoreHistories.recoveryScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          '7D': toBarChartData(samples.slice(-7), '7D', 'ja'),
          '30D': toBarChartData(samples.slice(-30), '30D', 'ja'),
          '60D': toBarChartData(samples, '60D', 'ja'),
        };
      },
      weeklyAverage: 64,
    },
    sleep: {
      score: 85,
      duration: { hours: 7, minutes: 8, percentage: 80 },
      quality: { percentage: 85 },
      analysis:
        '睡眠時間は目標を下回りましたが、REMと深い睡眠は通常より多くなっています。身体が睡眠不足を補おうと、回復的なステージを優先しているようです。',
      stages: [
        { stage: 'deep' as const, percentage: 23 },
        { stage: 'rem' as const, percentage: 22 },
        { stage: 'light' as const, percentage: 53 },
        { stage: 'awake' as const, percentage: 2 },
      ],
      timing: {
        bedtime: { actual: '23:15', target: '23:00', diff: '15分遅れ' },
        wakeTime: { actual: '06:45', target: '07:00', diff: '15分早起き' },
      },
      rawHistory: scoreHistories.sleepScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          '7D': toBarChartData(samples.slice(-7), '7D', 'ja'),
          '30D': toBarChartData(samples.slice(-30), '30D', 'ja'),
          '60D': toBarChartData(samples, '60D', 'ja'),
        };
      },
    },
    rhythm: {
      score: 92,
      status: '同期済み',
      analysis:
        'サーカディアンリズムが睡眠-覚醒サイクルとよく調和しています。この1週間、就寝時刻の一貫性が優れており、高いリズムスコアに貢献しています。',
      consistency: {
        bedtime: { target: '23:00', deviation: '±12分' },
        wakeTime: { target: '07:00', deviation: '±8分' },
      },
      contributingFactors: {
        bedtimeVariance: {
          value: 95,
          label: '就寝ばらつき',
          trend: '+3%',
          trendDirection: 'up' as const,
          detail: '平均 ±12分 (目標±15分)',
        },
        wakeVariance: {
          value: 98,
          label: '起床ばらつき',
          trend: '+5%',
          trendDirection: 'up' as const,
          detail: '平均 ±8分 (目標±15分)',
        },
        weekendShift: {
          value: 85,
          label: '週末シフト',
          trend: '安定',
          trendDirection: 'stable' as const,
          detail: '週末の遅れ 25分',
        },
        socialJetlag: {
          value: 90,
          label: '社会的時差',
          trend: '-2%',
          trendDirection: 'down' as const,
          detail: '平日-週末差 32分',
        },
      },
      weeklyPattern: [
        { day: '木', offset: 0 },
        { day: '金', offset: -10 },
        { day: '土', offset: 5 },
        { day: '日', offset: 0 },
        { day: '月', offset: 15 },
        { day: '火', offset: 5 },
        { day: '水', offset: 0 },
      ],
      rawHistory: scoreHistories.rhythmScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          '7D': toBarChartData(samples.slice(-7), '7D', 'ja'),
          '30D': toBarChartData(samples.slice(-30), '30D', 'ja'),
          '60D': toBarChartData(samples, '60D', 'ja'),
        };
      },
    },
    energy: {
      score: 78,
      status: '適度なエネルギー',
      analysis:
        '回復度と睡眠データに基づくと、今日は良好なエネルギーを保てそうです。Peak Focus時間帯は9:00〜12:00です。Afternoon Dip（14:00〜16:00）は軽めのタスクに切り替えるのがおすすめです。',
      contributingFactors: {
        recovery: {
          value: 70,
          label: '回復',
          trend: '+5%',
          trendDirection: 'up' as const,
          detail: 'HRV 82ms (基準+6%)',
        },
        sleep: {
          value: 85,
          label: '睡眠',
          trend: '+3%',
          trendDirection: 'up' as const,
          detail: '深い睡眠 1h45m',
        },
        activity: {
          value: 75,
          label: 'アクティビティ',
          trend: '安定',
          trendDirection: 'stable' as const,
          detail: '昨日 8,500歩',
        },
        weather: {
          value: 80,
          label: '天気',
          trend: '安定',
          trendDirection: 'stable' as const,
          detail: '晴れ・気圧安定',
        },
      },
      peakFocus: { start: '09:00', end: '12:00' },
      afternoonDip: { start: '14:00', end: '16:00' },
      rawHistory: scoreHistories.energyScore,
      get history() {
        const samples = this.rawHistory.samples;
        return {
          '7D': toBarChartData(samples.slice(-7), '7D', 'ja'),
          '30D': toBarChartData(samples.slice(-30), '30D', 'ja'),
          '60D': toBarChartData(samples, '60D', 'ja'),
        };
      },
    },
  };
};

/** HealthKit 対応版のモック詳細データ */
export const MOCK_DETAIL = createMockDetail();

// =============================================================================
// モック日次スナップショット / リアルタイムメトリクス
// =============================================================================

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
    hrv: createMetric(82, 'ms', 77),
    rhr: createMetric(59, 'bpm', 59),
    respiratory: createMetric(11.2, 'rpm', 11.0),
    spo2: createMetric(98, '%', 98),
    wristTemp: createMetric(36.4, '°C', 36.3),
  };
};

/** モック日次スナップショット（初期値） */
export const MOCK_DAILY_SNAPSHOT = createMockDailySnapshot();

/** モックリアルタイムメトリクス（初期値） */
export const MOCK_REALTIME_METRICS = createMockRealtimeMetrics();

/** すべてのヘルスメトリクス履歴（60日分） */
export const MOCK_HEALTH_METRIC_HISTORIES = getAllHealthMetricHistories('60D');
