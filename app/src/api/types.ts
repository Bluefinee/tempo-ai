/**
 * API型定義
 * @see docs/specs/technical_spec.md
 */

// ========================================
// User Profile
// ========================================

export type UserGoal = 'better_sleep' | 'more_energy' | 'less_stress' | 'peak_performance';

export interface UserProfile {
  goals: UserGoal[];
  wakeUpTime: string;
  windDownTime: string;
}

// ========================================
// Scores (新規追加)
// ========================================

export interface ScoresData {
  recovery: number; // 0-100
  sleep: number; // 0-100
  rhythm: number; // 0-100
  energy: number; // 0-100
}

// ========================================
// Health Metrics
// ========================================

export interface SleepData {
  durationMinutes: number;
  deepSleepMinutes: number;
  deepSleepPercent: number;
  remSleepMinutes: number;
  remSleepPercent: number;
  bedtime?: string;
  wakeTime?: string;
  vsTargetBedtime?: string; // "+15min" or "-10min"
}

export interface HrvData {
  current: number;
  baseline: number;
  deviation?: number;
}

export interface RhrData {
  current: number;
  baseline: number;
}

export interface HealthMetrics {
  hrv: HrvData;
  rhr: RhrData;
  sleep: SleepData;
}

// ========================================
// Weather
// ========================================

export type PressureTrend = 'rising' | 'stable' | 'falling';

export interface WeatherData {
  temperature: number;
  pressure: number;
  pressureTrend: PressureTrend;
  sunrise: string;
  sunset: string;
  description?: string;
  location?: string;
}

// ========================================
// Rhythm Phases (新規追加)
// ========================================

export interface RhythmPhases {
  peakFocus: {
    start: string; // HH:mm
    end: string; // HH:mm
  };
  afternoonDip: {
    start: string; // HH:mm
    end: string; // HH:mm
  };
  secondWind: {
    start: string; // HH:mm
    end: string; // HH:mm
  };
  windDown: {
    start: string; // HH:mm
    end: string; // HH:mm
  };
}

// ========================================
// Advice Request/Response
// ========================================

export interface AdviceRequest {
  user: UserProfile;
  scores: ScoresData;
  healthMetrics: HealthMetrics;
  weather: WeatherData;
  rhythmPhases: RhythmPhases;
  locale?: string;
}

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
  time: string | null; // HH:MM形式 または null
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

// ========================================
// Weather Response
// ========================================

export interface WeatherResponse {
  temperature: number;
  pressure: number;
  pressureTrend: PressureTrend;
  sunrise: string;
  sunset: string;
  description: string;
  location: string;
}

// ========================================
// API Error
// ========================================

export interface ApiError {
  error: string;
  message?: string;
  statusCode?: number;
}

// ========================================
// API Response (Generic)
// ========================================

export type ApiResponse<T> = { success: true; data: T } | { success: false; error: ApiError };
