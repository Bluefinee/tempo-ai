import { z } from 'zod';

// =============================================================================
// User Profile Types
// =============================================================================

const GenderSchema = z.enum(['male', 'female', 'other', 'not_specified']);
const OccupationSchema = z.enum([
  'it_engineer',
  'sales',
  'standing_work',
  'medical',
  'creative',
  'homemaker',
  'student',
  'freelance',
  'other',
]);
const LifestyleRhythmSchema = z.enum(['morning', 'night', 'irregular']);
const ExerciseFrequencySchema = z.enum(['daily', 'three_to_four', 'one_to_two', 'rarely']);
const AlcoholFrequencySchema = z.enum(['never', 'monthly', 'one_to_two', 'three_or_more']);
const InterestSchema = z.enum([
  'beauty',
  'fitness',
  'mental_health',
  'work_performance',
  'nutrition',
  'sleep',
]);

export const UserProfileSchema = z.object({
  nickname: z.string().min(1),
  age: z.number().int().min(1).max(120),
  gender: GenderSchema,
  weightKg: z.number().positive(),
  heightCm: z.number().positive(),
  occupation: OccupationSchema.optional(),
  lifestyleRhythm: LifestyleRhythmSchema.optional(),
  exerciseFrequency: ExerciseFrequencySchema.optional(),
  alcoholFrequency: AlcoholFrequencySchema.optional(),
  interests: z.array(InterestSchema).min(1),
});

// =============================================================================
// Health Data Types
// =============================================================================

export const SleepDataSchema = z.object({
  bedtime: z.string().optional(), // ISO 8601
  wakeTime: z.string().optional(), // ISO 8601
  durationHours: z.number().nonnegative(),
  deepSleepHours: z.number().nonnegative().optional(),
  remSleepHours: z.number().nonnegative().optional(),
  awakenings: z.number().int().nonnegative(),
  avgHeartRate: z.number().int().positive().optional(),
});

export const MorningVitalsSchema = z.object({
  restingHeartRate: z.number().int().positive().optional(),
  hrvMs: z.number().positive().optional(),
  bloodOxygen: z.number().int().min(70).max(100).optional(),
});

export const ActivityDataSchema = z.object({
  steps: z.number().int().nonnegative(),
  workoutMinutes: z.number().int().nonnegative().optional(),
  workoutType: z.string().optional(),
  caloriesBurned: z.number().int().nonnegative().optional(),
});

export const WeekTrendsSchema = z.object({
  avgSleepHours: z.number().nonnegative(),
  avgHrv: z.number().positive().optional(),
  avgRestingHeartRate: z.number().int().positive().optional(),
  avgSteps: z.number().int().nonnegative(),
  totalWorkoutHours: z.number().nonnegative().optional(),
});

/**
 * 健康スコア（0-100）
 * HRV、睡眠、リズム、活動量の4つのメトリクスで構成
 */
export const HealthScoresSchema = z.object({
  hrv: z.number().int().min(0).max(100),
  sleep: z.number().int().min(0).max(100),
  rhythm: z.number().int().min(0).max(100),
  activity: z.number().int().min(0).max(100),
});

/**
 * リズム安定性
 */
export const RhythmStabilitySchema = z.object({
  status: z.enum(['良好', '普通', '不安定']),
  consecutiveStableDays: z.number().int().nonnegative(),
});

export const HealthDataSchema = z.object({
  date: z.string(), // ISO 8601
  sleep: SleepDataSchema.optional(),
  morningVitals: MorningVitalsSchema.optional(),
  yesterdayActivity: ActivityDataSchema.optional(),
  weekTrends: WeekTrendsSchema.optional(),
  scores: HealthScoresSchema, // iOS側で計算されたスコア
  rhythmStability: RhythmStabilitySchema.optional(),
});

// =============================================================================
// Location Types
// =============================================================================

export const LocationDataSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  city: z.string().optional(),
});

// =============================================================================
// Request Context Types
// =============================================================================

const DayOfWeekSchema = z.enum([
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
]);

export const RequestContextSchema = z.object({
  currentTime: z.string(), // ISO 8601
  dayOfWeek: DayOfWeekSchema,
  isMonday: z.boolean(),
  recentDailyTries: z.array(z.string()), // 過去2週間のトピック
  lastWeeklyTry: z.string().optional(),
});

// =============================================================================
// Response Types
// =============================================================================

export const TryContentSchema = z.object({
  title: z.string().min(1),
  detail: z.string().min(1),
});

const TimeSlotSchema = z.enum(['morning', 'afternoon', 'evening']);

export const DailyAdviceSchema = z.object({
  greeting: z.string().min(1),
  energyComment: z.string().min(1), // エネルギーレベルに応じたAIコメント
  condition: z.object({
    summary: z.string().min(1),
    detail: z.string().min(1),
  }),
  insight: z.string().min(1), // 因果関係を明示したAIの見立て
  dailyTry: TryContentSchema,
  closingMessage: z.string().min(1),
  scores: HealthScoresSchema, // 必須
  generatedAt: z.string(), // ISO 8601
  timeSlot: TimeSlotSchema,
});


// =============================================================================
// Type Exports
// =============================================================================

export type Gender = z.infer<typeof GenderSchema>;
export type Occupation = z.infer<typeof OccupationSchema>;
export type LifestyleRhythm = z.infer<typeof LifestyleRhythmSchema>;
export type ExerciseFrequency = z.infer<typeof ExerciseFrequencySchema>;
export type AlcoholFrequency = z.infer<typeof AlcoholFrequencySchema>;
export type Interest = z.infer<typeof InterestSchema>;
export type DayOfWeek = z.infer<typeof DayOfWeekSchema>;
export type TimeSlot = z.infer<typeof TimeSlotSchema>;

export type UserProfile = z.infer<typeof UserProfileSchema>;
export type SleepData = z.infer<typeof SleepDataSchema>;
export type MorningVitals = z.infer<typeof MorningVitalsSchema>;
export type ActivityData = z.infer<typeof ActivityDataSchema>;
export type WeekTrends = z.infer<typeof WeekTrendsSchema>;
export type HealthData = z.infer<typeof HealthDataSchema>;
export type LocationData = z.infer<typeof LocationDataSchema>;
export type RequestContext = z.infer<typeof RequestContextSchema>;
export type TryContent = z.infer<typeof TryContentSchema>;
export type HealthScores = z.infer<typeof HealthScoresSchema>;
export type RhythmStability = z.infer<typeof RhythmStabilitySchema>;
export type DailyAdvice = z.infer<typeof DailyAdviceSchema>;

// =============================================================================
// Weather Data Types
// =============================================================================

export const WeatherDataSchema = z.object({
  condition: z.string().min(1), // Weather Codeから変換した日本語天気
  tempCurrentC: z.number(), // 現在気温（℃）
  tempMaxC: z.number(), // 最高気温（℃）
  tempMinC: z.number(), // 最低気温（℃）
  humidityPercent: z.number().min(0).max(100), // 湿度（%）
  uvIndex: z.number().nonnegative(), // UV指数
  pressureHpa: z.number().positive(), // 気圧（hPa）
  precipitationProbability: z.number().min(0).max(100), // 降水確率（%）
});

// =============================================================================
// Air Quality Data Types
// =============================================================================

export const AirQualityDataSchema = z.object({
  aqi: z.number().int().nonnegative(), // 大気質指数（AQI）
  pm25: z.number().nonnegative(), // PM2.5濃度
  pm10: z.number().nonnegative().optional(), // PM10濃度（オプション）
});

// =============================================================================
// Environment Data Types
// =============================================================================

export const EnvironmentDataSchema = z.object({
  weather: WeatherDataSchema.optional(), // 気象データ（取得失敗時はundefined）
  airQuality: AirQualityDataSchema.optional(), // 大気汚染データ（取得失敗時はundefined）
});

export type WeatherData = z.infer<typeof WeatherDataSchema>;
export type AirQualityData = z.infer<typeof AirQualityDataSchema>;
export type EnvironmentData = z.infer<typeof EnvironmentDataSchema>;

// =============================================================================
// Pressure Trend Types (Phase 10)
// =============================================================================

/**
 * 気圧トレンド
 * - rising: 上昇中 (2hPa以上の上昇)
 * - stable: 安定 (±2hPa以内の変化)
 * - falling: 下降中 (2hPa以上の下降)
 */
export const PressureTrendSchema = z.enum(['rising', 'stable', 'falling']);
export type PressureTrend = z.infer<typeof PressureTrendSchema>;

// =============================================================================
// Environment Advice Types (Phase 10)
// =============================================================================

/**
 * 環境アドバイスの種類
 */
export const EnvironmentAdviceTypeSchema = z.enum([
  'temperature',
  'uv',
  'air_quality',
  'humidity',
  'pressure',
]);

export type EnvironmentAdviceType = z.infer<typeof EnvironmentAdviceTypeSchema>;

/**
 * 環境アドバイス
 */
export const EnvironmentAdviceSchema = z.object({
  type: EnvironmentAdviceTypeSchema,
  message: z.string().min(1),
});

export type EnvironmentAdvice = z.infer<typeof EnvironmentAdviceSchema>;

// =============================================================================
// Hourly Pressure Data Types (Phase 10)
// =============================================================================

/**
 * 時間別気圧データ（内部使用）
 */
export const HourlyPressureDataSchema = z.object({
  pressure3hAgo: z.number().positive().optional(),
});

export type HourlyPressureData = z.infer<typeof HourlyPressureDataSchema>;

// =============================================================================
// Environment Response Types (Phase 10)
// =============================================================================

/**
 * 環境データAPIレスポンス
 */
export const EnvironmentResponseSchema = z.object({
  location: z.object({
    city: z.string(),
    latitude: z.number(),
    longitude: z.number(),
  }),
  weather: z.object({
    current: WeatherDataSchema,
    pressureTrend: PressureTrendSchema,
  }),
  airQuality: AirQualityDataSchema,
  advice: z.array(EnvironmentAdviceSchema).max(3),
  fetchedAt: z.string(), // ISO 8601
});

export type EnvironmentResponse = z.infer<typeof EnvironmentResponseSchema>;
