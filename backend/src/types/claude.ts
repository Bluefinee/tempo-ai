import type { UserProfile, HealthData, WeatherData, AirQualityData } from './domain.js';

export interface GenerateAdviceParams {
  userProfile: UserProfile;
  healthData: HealthData;
  weatherData?: WeatherData | undefined;
  airQualityData?: AirQualityData | undefined;
  context: RequestContext;
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
