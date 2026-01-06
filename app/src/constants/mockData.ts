/**
 * モックデータ
 * 開発・テスト用のサンプルデータ
 */

import {
  UserProfile,
  DailyScores,
  SimpleWeatherData,
  QuickAction,
  AIInsightFull,
  RecommendedAction,
  DailyAdvice,
  HealthMetrics,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  DailyScoreSnapshot,
} from '../domain/models';

// モックユーザー
export const MOCK_USER: UserProfile = {
  id: 'mock_user_1',
  nickname: '太郎',
  age: 30,
  gender: 'male',
  heightCm: 175,
  weightKg: 70,
  chronotype: 'morning',
  targetBedtime: '23:00',
  occupation: 'deskWork',
  exerciseFrequency: 'twiceWeek',
  calibrationDaysCompleted: 7,
  createdAt: new Date(),
  updatedAt: new Date(),
};

// モックスコア
export const MOCK_SCORES: DailyScores = {
  autonomic: 85,
  sleep: 72,
  rhythm: 94,
  activity: 78,
};

// モック天気
export const MOCK_WEATHER: SimpleWeatherData = {
  temp: 8,
  condition: '晴れ',
  pressure: 1018,
  pressureTrend: 'down',
  uv: 3,
  location: 'Tokyo',
};

// クイックアクション
export const MOCK_QUICK_ACTIONS: QuickAction[] = [
  { id: '1', type: 'activity', text: 'ランチ後に10分の散歩を', icon: 'footprints' },
  { id: '2', type: 'breathing', text: '1分間の深呼吸', icon: 'wind' },
];

// AI グリーティング（短縮版）
export const MOCK_AI_GREETING_SHORT = (nickname: string): string =>
  `${nickname}さん、おはようございます。昨夜は7時間半の深い睡眠が取れ、HRVも30日平均より約10%高い状態です。5日連続でリズムが安定しており...`;

// AI インサイト（フルバージョン）
export const MOCK_AI_INSIGHT_FULL = (nickname: string): AIInsightFull => ({
  greeting: `${nickname}さん、おはようございます。`,
  condition:
    '今日のコンディションはとても良好です。自律神経スコアは85と高く、身体がしっかり回復できている状態ですね。',
  sleep:
    '昨夜は23時15分に就寝し、目標の23時から15分遅れでしたが、7時間半の睡眠が取れました。深い睡眠が1時間45分（全体の23%）と理想的な範囲で、これがHRV 68msという高い値につながっています。',
  rhythm:
    '5日連続でリズムが安定しています。就寝・起床時刻のばらつきがそれぞれ22分、18分と小さく、体内時計が整っています。',
  environment:
    '今日は午後から気圧が下がる予報です。通常なら倦怠感が出やすい条件ですが、これだけコンディションが整っていれば影響は最小限に抑えられるでしょう。',
  advice: `朝型の${nickname}さんにとって、午前中がゴールデンタイムです。集中力が必要な仕事は10時〜12時に片付けてしまいましょう。ランチ後に10分だけ外を歩くと、午後の気圧低下の影響を和らげられます。`,
  closing: '今日も良い1日になりますように。',
});

// モック推奨アクション
export const MOCK_RECOMMENDED_ACTION: RecommendedAction = {
  type: 'activity',
  message: 'ランチ後に10分の散歩を',
  icon: 'footprints',
  displayName: '活動',
};

// モックデイリーアドバイス
export const MOCK_DAILY_ADVICE = (nickname: string): DailyAdvice => {
  const insight = MOCK_AI_INSIGHT_FULL(nickname);
  return {
    id: `advice_${Date.now()}`,
    date: new Date(),
    greeting: insight.greeting,
    condition: insight.condition,
    sleep: insight.sleep,
    rhythm: insight.rhythm,
    environment: insight.environment,
    advice: insight.advice,
    closing: insight.closing,
  };
};

// モック睡眠データ
export const MOCK_SLEEP_METRICS: SleepMetrics = {
  bedtime: new Date('2025-01-05T23:15:00'),
  wakeTime: new Date('2025-01-06T06:45:00'),
  durationMinutes: 450,
  deepSleepMinutes: 105,
  remSleepMinutes: 90,
};

// モック HRV データ
export const MOCK_HRV_METRICS: HRVMetrics = {
  value: 68,
  baseline30d: 55,
};

// モックアクティビティデータ
export const MOCK_ACTIVITY_METRICS: ActivityMetrics = {
  stepsYesterday: 8500,
  activeMinutesYesterday: 35,
};

// モックヘルスメトリクス
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

// モックリズム分析
export const MOCK_RHYTHM_ANALYSIS: RhythmAnalysis = {
  bedtimeStddevMinutes: 22,
  wakeTimeStddevMinutes: 18,
  consecutiveStableDays: 5,
  status: 'stable',
  isStable: true,
  bedtimeConsistencyScore: 85,
  wakeTimeConsistencyScore: 88,
};

// モック日次スコア履歴（週間）
export const MOCK_WEEKLY_SCORES: DailyScoreSnapshot[] = [
  {
    id: '1',
    date: new Date('2025-01-01'),
    autonomicScore: 78,
    sleepScore: 65,
    rhythmScore: 82,
    activityScore: 70,
  },
  {
    id: '2',
    date: new Date('2025-01-02'),
    autonomicScore: 80,
    sleepScore: 70,
    rhythmScore: 85,
    activityScore: 75,
  },
  {
    id: '3',
    date: new Date('2025-01-03'),
    autonomicScore: 75,
    sleepScore: 68,
    rhythmScore: 88,
    activityScore: 65,
  },
  {
    id: '4',
    date: new Date('2025-01-04'),
    autonomicScore: 82,
    sleepScore: 74,
    rhythmScore: 90,
    activityScore: 78,
  },
  {
    id: '5',
    date: new Date('2025-01-05'),
    autonomicScore: 85,
    sleepScore: 72,
    rhythmScore: 94,
    activityScore: 80,
  },
  {
    id: '6',
    date: new Date('2025-01-06'),
    autonomicScore: 85,
    sleepScore: 72,
    rhythmScore: 94,
    activityScore: 82,
  },
  {
    id: '7',
    date: new Date('2025-01-07'),
    autonomicScore: 88,
    sleepScore: 76,
    rhythmScore: 95,
    activityScore: 85,
  },
];

// 分析期間
export type TimePeriod = 'weekly' | 'monthly';
