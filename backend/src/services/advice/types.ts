import { z } from 'zod';

// ========================================
// User Profile Schema
// ========================================

export const UserProfileSchema = z.object({
  nickname: z.string().min(1),
  age: z.number().int().min(1).max(120),
  gender: z.enum(['male', 'female', 'other', 'preferNotToSay']),
  chronotype: z.enum(['morning', 'intermediate', 'evening']),
  occupation: z.enum(['deskWork', 'standingWork', 'physicalWork', 'hybrid', 'other']).optional(),
  exerciseFrequency: z.enum(['rarely', 'onceWeek', 'twiceWeek', 'threeOrMore', 'daily']).optional(),
  targetBedtime: z.string(), // HH:mm format
});

export type UserProfile = z.infer<typeof UserProfileSchema>;

// ========================================
// Health Data Schemas
// ========================================

export const SleepDataSchema = z.object({
  bedtime: z.string(),
  wakeTime: z.string(),
  durationHours: z.number().min(0).max(24),
  deepSleepMinutes: z.number().int().min(0),
  remSleepMinutes: z.number().int().min(0),
  deepSleepRatio: z.number().min(0).max(1),
});

export type SleepData = z.infer<typeof SleepDataSchema>;

export const HRVDataSchema = z.object({
  value: z.number().min(0),
  baseline30d: z.number().min(0),
  deviationPercent: z.number(),
});

export type HRVData = z.infer<typeof HRVDataSchema>;

export const ActivityDataSchema = z.object({
  stepsYesterday: z.number().int().min(0),
  activeMinutesYesterday: z.number().int().min(0),
});

export type ActivityData = z.infer<typeof ActivityDataSchema>;

export const RhythmAnalysisSchema = z.object({
  bedtimeStddevMinutes: z.number().min(0),
  wakeTimeStddevMinutes: z.number().min(0),
  consecutiveStableDays: z.number().int().min(0),
  status: z.enum(['stable', 'recovering', 'unstable']),
});

export type RhythmAnalysis = z.infer<typeof RhythmAnalysisSchema>;

export const AuxiliaryDataSchema = z
  .object({
    daylightMinutesYesterday: z.number().int().min(0).optional(),
    wristTemperatureDeviation: z.number().optional(),
  })
  .optional();

export type AuxiliaryData = z.infer<typeof AuxiliaryDataSchema>;

export const ScoresSchema = z.object({
  autonomic: z.number().int().min(0).max(100),
  sleep: z.number().int().min(0).max(100),
  rhythm: z.number().int().min(0).max(100),
  activity: z.number().int().min(0).max(100),
});

export type Scores = z.infer<typeof ScoresSchema>;

export const HealthDataSchema = z.object({
  sleep: SleepDataSchema.optional(),
  hrv: HRVDataSchema.optional(),
  activity: ActivityDataSchema.optional(),
  scores: ScoresSchema,
  rhythmAnalysis: RhythmAnalysisSchema,
  auxiliary: AuxiliaryDataSchema,
});

export type HealthData = z.infer<typeof HealthDataSchema>;

// ========================================
// Location Schema
// ========================================

export const LocationSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  city: z.string(),
});

export type Location = z.infer<typeof LocationSchema>;

// ========================================
// Context Schema
// ========================================

export const ContextSchema = z.object({
  currentTime: z.string(),
  dayOfWeek: z.string(),
  mood: z.number().int().min(1).max(5).optional(),
  todayMode: z.enum(['normal', 'challenge', 'holiday']).default('normal'),
});

export type Context = z.infer<typeof ContextSchema>;

// ========================================
// Weather Schema
// ========================================

export const WeatherSchema = z.object({
  temperature: z.number(),
  humidity: z.number().min(0).max(100),
  pressure: z.number().min(0),
  weatherCode: z.number().int(),
  uvIndexMax: z.number().min(0),
});

export type Weather = z.infer<typeof WeatherSchema>;

// ========================================
// Full Request Schema
// ========================================

export const AdviceRequestSchema = z.object({
  profile: UserProfileSchema,
  healthData: HealthDataSchema,
  location: LocationSchema,
  context: ContextSchema,
  weather: WeatherSchema.optional(),
});

export type AdviceRequest = z.infer<typeof AdviceRequestSchema>;

// ========================================
// Response Types
// ========================================

/** 推奨アクションのタイプ */
export type RecommendedActionType = 'breathing' | 'morning_light' | 'rest' | 'activity';

/** 推奨アクション */
export interface RecommendedAction {
  type: RecommendedActionType;
  message: string;
}

/** AI生成アドバイスのレスポンス */
export interface AdviceResponse {
  /** ホーム画面に表示する要約（100-150文字） */
  summary: string;
  /** 詳細画面に表示するフルバージョン（400-600文字） */
  fullInsight: string;
  /** 推奨アクション */
  recommendedAction: RecommendedAction;
}

// ========================================
// Error Types
// ========================================

/** エラーコード */
export type AdviceErrorCode =
  | 'INVALID_REQUEST'
  | 'AI_API_ERROR'
  | 'RATE_LIMIT_ERROR'
  | 'NETWORK_ERROR'
  | 'PARSE_ERROR';

/** エラー型 */
export interface AdviceError {
  code: AdviceErrorCode;
  message: string;
  details?: unknown;
}
