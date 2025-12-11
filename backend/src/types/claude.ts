import type {
  UserProfile,
  HealthData,
  WeatherData,
  AirQualityData,
  DailyAdvice,
} from './domain.js';

export interface GenerateAdviceParams {
  userProfile: UserProfile;
  healthData: HealthData;
  weatherData?: WeatherData | undefined;
  airQualityData?: AirQualityData | undefined;
  context: RequestContext;
  apiKey: string;
}

export interface AdditionalAdviceParams {
  mainAdvice: DailyAdvice;
  timeSlot: 'midday' | 'evening';
  userProfile: UserProfile;
  apiKey: string;
}

export interface ClaudePromptLayer {
  type: 'text';
  text: string;
  cache_control?: { type: 'ephemeral' };
}

export interface RequestContext {
  currentTime: string;
  dayOfWeek: string;
  isMonday: boolean;
  recentDailyTries: string[];
  lastWeeklyTry: string | null;
}

export interface AdditionalAdvice {
  greeting: string;
  message: string;
  actionSuggestion?: {
    icon: 'hydration' | 'movement' | 'rest' | 'nutrition' | 'mindfulness';
    title: string;
    detail: string;
  };
  generatedAt: string;
  timeSlot: 'midday' | 'evening';
}
