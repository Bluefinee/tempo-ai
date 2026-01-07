import { z } from 'zod';

// ========================================
// User Profile Schema
// ========================================

export const UserProfileSchema = z.object({
  goals: z.array(z.enum(['better_sleep', 'more_energy', 'less_stress', 'peak_performance'])),
  wakeUpTime: z.string().regex(/^\d{2}:\d{2}$/), // HH:mm format
  windDownTime: z.string().regex(/^\d{2}:\d{2}$/), // HH:mm format
});

export type UserProfile = z.infer<typeof UserProfileSchema>;

export type UserGoal = 'better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance';

// ========================================
// Scores Schema (新規追加)
// ========================================

export const ScoresDataSchema = z.object({
  recovery: z.number().min(0).max(100),
  sleep: z.number().min(0).max(100),
  rhythm: z.number().min(0).max(100),
  energy: z.number().min(0).max(100),
});

export type ScoresData = z.infer<typeof ScoresDataSchema>;

// ========================================
// Health Metrics Schema
// ========================================

export const SleepDataSchema = z.object({
  durationMinutes: z.number().int().min(0),
  deepSleepMinutes: z.number().int().min(0),
  deepSleepPercent: z.number().min(0).max(100),
  remSleepMinutes: z.number().int().min(0),
  remSleepPercent: z.number().min(0).max(100),
  bedtime: z.string().optional(),
  wakeTime: z.string().optional(),
  vsTargetBedtime: z.string().optional(), // "+15min" or "-10min"
});

export type SleepData = z.infer<typeof SleepDataSchema>;

export const HRVDataSchema = z.object({
  current: z.number().min(0),
  baseline: z.number().min(0),
  deviation: z.number().optional(),
});

export type HRVData = z.infer<typeof HRVDataSchema>;

export const RHRDataSchema = z.object({
  current: z.number().min(0),
  baseline: z.number().min(0),
});

export type RHRData = z.infer<typeof RHRDataSchema>;

export const HealthMetricsSchema = z.object({
  hrv: HRVDataSchema,
  rhr: RHRDataSchema,
  sleep: SleepDataSchema,
});

export type HealthMetrics = z.infer<typeof HealthMetricsSchema>;

// ========================================
// Weather Schema
// ========================================

export const WeatherDataSchema = z.object({
  temperature: z.number(),
  pressure: z.number().min(0),
  pressureTrend: z.enum(['rising', 'stable', 'falling']),
  sunrise: z.string().regex(/^\d{2}:\d{2}$/),
  sunset: z.string().regex(/^\d{2}:\d{2}$/),
  description: z.string().optional(),
  location: z.string().optional(),
});

export type WeatherData = z.infer<typeof WeatherDataSchema>;
export type PressureTrend = 'rising' | 'stable' | 'falling';

// ========================================
// Rhythm Phases Schema (新規追加)
// ========================================

export const RhythmPhasesSchema = z.object({
  peakFocus: z.object({
    start: z.string().regex(/^\d{2}:\d{2}$/),
    end: z.string().regex(/^\d{2}:\d{2}$/),
  }),
  afternoonDip: z.object({
    start: z.string().regex(/^\d{2}:\d{2}$/),
    end: z.string().regex(/^\d{2}:\d{2}$/),
  }),
  secondWind: z.object({
    start: z.string().regex(/^\d{2}:\d{2}$/),
    end: z.string().regex(/^\d{2}:\d{2}$/),
  }),
  windDown: z.object({
    start: z.string().regex(/^\d{2}:\d{2}$/),
    end: z.string().regex(/^\d{2}:\d{2}$/),
  }),
});

export type RhythmPhases = z.infer<typeof RhythmPhasesSchema>;

// ========================================
// Request Schema
// ========================================

export const AdviceRequestSchema = z.object({
  user: UserProfileSchema,
  scores: ScoresDataSchema,
  healthMetrics: HealthMetricsSchema,
  weather: WeatherDataSchema,
  rhythmPhases: RhythmPhasesSchema,
  locale: z.string().optional().default('ja'),
});

export type AdviceRequest = z.infer<typeof AdviceRequestSchema>;

// ========================================
// Response Types
// ========================================

export type OneThingIcon = 'walking' | 'breathing' | 'rest' | 'coffee' | 'sun';

export interface WhyThisMattersItem {
  headline: string;
  explanation: string;
}

export interface TodayInsight {
  title: string; // 英語、詩的（2-4語）
  summary: string; // 日本語、100-150文字
  whyThisMatters: {
    hrv: WhyThisMattersItem;
    sleep: WhyThisMattersItem;
    rhythm: WhyThisMattersItem;
  };
  whatThisMeansForToday: string; // 日本語、80-120文字
}

export interface TodayOneThing {
  icon: OneThingIcon;
  action: string; // 20文字以内
  summary: string; // 40文字以内
  time: string; // HH:MM形式
  whyThisAction: string; // 3-4文
  benefits: string[]; // 各15文字以内
  howToDoIt: string[]; // 各20文字以内
  expectedBenefit: {
    text: string;
    source: string;
  };
}

export interface RelatedInsight {
  label: string; // "Research Finding"
  text: string; // 30文字以内
  source: string;
}

export interface AdviceResponse {
  todayInsight: TodayInsight;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
}

// Claude API出力形式
export interface ClaudeAdviceOutput {
  todayInsight: TodayInsight;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
}

// ========================================
// Error Types
// ========================================

export type AdviceErrorCode =
  | 'INVALID_REQUEST'
  | 'AI_API_ERROR'
  | 'RATE_LIMIT_ERROR'
  | 'NETWORK_ERROR'
  | 'PARSE_ERROR';

export interface AdviceError {
  code: AdviceErrorCode;
  message: string;
  details?: unknown;
}

// ========================================
// Validation & Fallback
// ========================================

export const isValidAdviceRequest = (data: unknown): data is AdviceRequest => {
  const result = AdviceRequestSchema.safeParse(data);
  return result.success;
};

export const createFallbackResponse = (): AdviceResponse => ({
  todayInsight: {
    title: 'New Day',
    summary:
      '今日も新しい1日が始まりました。身体の声に耳を傾けながら、自分のペースで過ごしましょう。',
    whyThisMatters: {
      hrv: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。',
      },
      sleep: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。',
      },
      rhythm: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。',
      },
    },
    whatThisMeansForToday: '無理のない範囲で、今日のタスクに取り組みましょう。',
  },
  todayOneThing: {
    icon: 'breathing',
    action: '深呼吸で1日をスタート',
    summary: '心と身体を整えます',
    time: '07:00',
    whyThisAction: '深呼吸は自律神経を整え、1日の良いスタートを切る助けになります。',
    benefits: ['心を落ち着ける', '集中力を高める', 'ストレスを軽減'],
    howToDoIt: ['楽な姿勢で座る', '4秒かけて吸う', '7秒止めて8秒で吐く'],
    expectedBenefit: {
      text: '呼吸法は自律神経のバランスを整えます',
      source: '一般的な知見',
    },
  },
  relatedInsight: {
    label: 'Tip',
    text: '規則正しい生活がリズムを整えます',
    source: '一般的な知見',
  },
});
