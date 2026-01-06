/**
 * API Request/Response Types
 */

import {
  AIInsightFull,
  Mood,
  TodayMode,
} from '../domain/models';

// ========================================
// Advice API
// ========================================

export interface AdviceRequestProfile {
  nickname: string;
  age: number;
  gender: string;
  chronotype: string;
  occupation?: string;
  exerciseFrequency?: string;
  targetBedtime: string;
}

export interface AdviceRequestHealthData {
  sleep?: {
    bedtime: string;
    wakeTime: string;
    durationHours: number;
    deepSleepMinutes: number;
    remSleepMinutes: number;
    deepSleepRatio: number;
  };
  hrv?: {
    value: number;
    baseline30d: number;
    deviationPercent: number;
  };
  activity?: {
    stepsYesterday: number;
    activeMinutesYesterday: number;
  };
  scores: {
    autonomic: number;
    sleep: number;
    rhythm: number;
    activity: number;
  };
  rhythmAnalysis: {
    bedtimeStddevMinutes: number;
    wakeTimeStddevMinutes: number;
    consecutiveStableDays: number;
    status: 'stable' | 'recovering' | 'unstable';
  };
}

export interface AdviceRequestLocation {
  latitude: number;
  longitude: number;
  city: string;
}

export interface AdviceRequestContext {
  currentTime: string;
  dayOfWeek: string;
  mood?: Mood;
  todayMode: TodayMode;
}

export interface AdviceRequestWeather {
  temperature: number;
  humidity: number;
  pressure: number;
  weatherCode: number;
  uvIndexMax: number;
}

export interface AdviceRequest {
  profile: AdviceRequestProfile;
  healthData: AdviceRequestHealthData;
  location: AdviceRequestLocation;
  context: AdviceRequestContext;
  weather?: AdviceRequestWeather;
}

export interface AdviceResponseData {
  summary: string;
  insight: AIInsightFull;
  recommendedAction: {
    type: 'breathing' | 'morning_light' | 'rest' | 'activity';
    message: string;
  };
}

export interface AdviceResponse {
  success: boolean;
  data?: AdviceResponseData;
  error?: string;
}

// ========================================
// Weather API
// ========================================

export interface WeatherRequest {
  latitude: number;
  longitude: number;
}

export interface WeatherResponseData {
  temperature: number;
  humidity: number;
  pressure: number;
  weatherCode: number;
  uvIndexMax: number;
  sunrise: string;
  sunset: string;
  airQuality: {
    pm25: number;
    aqi: number;
  };
}

export interface WeatherResponse {
  success: boolean;
  data?: WeatherResponseData;
  error?: string;
}

// ========================================
// Health Check API
// ========================================

export interface HealthCheckResponse {
  status: string;
  timestamp?: string;
}

// ========================================
// Generic API Error
// ========================================

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}
