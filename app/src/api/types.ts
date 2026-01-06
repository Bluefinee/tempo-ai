/**
 * API Request/Response Types
 */

import {
  UserProfile,
  HealthMetrics,
  SimpleWeatherData,
  AIInsightFull,
  Mood,
  TodayMode,
} from '../domain/models';

// Advice API
export interface AdviceRequest {
  user: Pick<
    UserProfile,
    'nickname' | 'age' | 'gender' | 'chronotype' | 'targetBedtime'
  >;
  healthMetrics: {
    sleep: {
      bedtime: string; // ISO8601
      wakeTime: string; // ISO8601
      durationMinutes: number;
      deepSleepMinutes: number;
      remSleepMinutes: number;
    };
    hrv: {
      value: number;
      baseline30d: number;
    };
    activity: {
      stepsYesterday: number;
      activeMinutesYesterday: number;
    };
  };
  rhythmAnalysis: {
    status: 'stable' | 'recovering' | 'unstable';
    consecutiveStableDays: number;
    bedtimeStddevMinutes: number;
    wakeTimeStddevMinutes: number;
  };
  weather?: {
    temp: number;
    pressure: number;
    pressureTrend: 'up' | 'stable' | 'down';
  };
  mood?: Mood;
  todayMode?: TodayMode;
}

export interface AdviceResponse {
  success: boolean;
  data?: AIInsightFull;
  error?: string;
}

// Weather API
export interface WeatherRequest {
  latitude: number;
  longitude: number;
}

export interface WeatherResponse {
  success: boolean;
  data?: SimpleWeatherData;
  error?: string;
}

// Generic API Error
export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}
