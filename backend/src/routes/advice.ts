import { Hono } from 'hono';
import type { Context } from 'hono';
import { rateLimit, validateApiKey } from '../middleware/auth.js';
import { validateAdviceRequest, type AdviceRequest } from '../types/request.js';
import type { LocationData, EnvironmentData } from '../types/domain.js';
import { HttpStatus } from '../types/response.js';
import { createValidationErrorResponse } from '../utils/errors.js';
import { createMockAdviceForTimeSlot } from '../utils/mockData.js';
import { fetchWeatherData } from '../services/weather.js';
import { fetchAirQualityData } from '../services/airQuality.js';

// =============================================================================
// Advice Router Setup
// =============================================================================

interface Bindings {
  ENVIRONMENT: 'development' | 'production' | 'staging';
}

const adviceRouter = new Hono<{ Bindings: Bindings }>();

// Apply authentication and rate limiting to all advice routes
adviceRouter.use('/*', validateApiKey);
adviceRouter.use('/*', rateLimit);

// =============================================================================
// Environment Data Integration
// =============================================================================

/**
 * 環境データ（気象・大気汚染）を取得する統合関数
 * フォールバック処理により、片方のAPI失敗時でも残りの処理を継続
 *
 * @param location - 位置情報（緯度・経度）
 * @returns 環境データ（失敗時は該当フィールドがundefined）
 */
const fetchEnvironmentData = async (location: LocationData): Promise<EnvironmentData> => {
  const results: EnvironmentData = {};

  // Weather APIとAir Quality APIの並行実行
  const [weatherResult, airQualityResult] = await Promise.allSettled([
    fetchWeatherData(location),
    fetchAirQualityData(location),
  ]);

  // Weather APIの結果処理
  if (weatherResult.status === 'fulfilled') {
    results.weather = weatherResult.value;
    console.log('[Environment] Weather data fetched successfully');
  } else {
    console.error(
      '[Environment] Weather fetch failed:',
      weatherResult.reason?.message || 'Unknown error',
    );
    // weatherフィールドはundefinedのまま（フォールバック）
  }

  // Air Quality APIの結果処理
  if (airQualityResult.status === 'fulfilled') {
    results.airQuality = airQualityResult.value;
    console.log('[Environment] Air quality data fetched successfully');
  } else {
    console.error(
      '[Environment] Air quality fetch failed:',
      airQualityResult.reason?.message || 'Unknown error',
    );
    // airQualityフィールドはundefinedのまま（フォールバック）
  }

  return results;
};

// =============================================================================
// POST /api/advice - Main Advice Generation
// =============================================================================

/**
 * Main advice generation endpoint
 *
 * Phase 7: Returns fixed mock response for development and iOS integration testing
 * Future phases: Will integrate with Claude API for real advice generation
 *
 * @param c - Hono context
 * @returns AdviceResponse with mock daily advice
 */
adviceRouter.post('/', async (c: Context): Promise<Response> => {
  // Get request body
  const requestBody = await c.req.json().catch(() => ({}));

  // Validate request data
  const validation = validateAdviceRequest(requestBody);

  if (!validation.success) {
    const errorResponse = createValidationErrorResponse(validation.errors || []);
    return c.json(errorResponse, HttpStatus.BAD_REQUEST);
  }

  const adviceRequest = validation.data as AdviceRequest;

  // Determine time slot based on current time
  const timeSlot = determineTimeSlot(adviceRequest.context.currentTime);

  // Fetch environment data (weather and air quality) with fallback handling
  const environmentData = await fetchEnvironmentData(adviceRequest.location);

  // Generate mock advice response
  const mockResponse = createMockAdviceForTimeSlot(adviceRequest.userProfile.nickname, timeSlot);

  // Log successful request (without sensitive data)
  console.log('Advice request processed:', {
    timestamp: new Date().toISOString(),
    nickname: adviceRequest.userProfile.nickname,
    timeSlot,
    interests: adviceRequest.userProfile.interests,
    hasHealthData: !!adviceRequest.healthData.sleep,
    location: adviceRequest.location.city || 'coordinates-only',
    environment: {
      hasWeatherData: !!environmentData.weather,
      hasAirQualityData: !!environmentData.airQuality,
      weatherCondition: environmentData.weather?.condition,
      aqi: environmentData.airQuality?.aqi,
    },
  });

  // Debug environment data (Phase 8 - will be used in Phase 9 for Claude API)
  console.log('Environment data for advice generation:', {
    weather: environmentData.weather,
    airQuality: environmentData.airQuality,
  });

  return c.json(mockResponse, HttpStatus.OK);
});

// =============================================================================
// GET /api/advice - Development Info
// =============================================================================

/**
 * Development endpoint to check advice route status
 * Will be removed in production
 */
adviceRouter.get('/', (c: Context): Response => {
  return c.json(
    {
      message: 'Tempo AI Advice API - Phase 8 Implementation',
      status: 'active',
      version: '0.1.0',
      environment: c.env?.ENVIRONMENT || 'development',
      endpoints: {
        advice: 'POST /api/advice - Generate daily advice with environmental data',
      },
      phase: {
        current: 8,
        description: 'External API integration (Weather + Air Quality)',
        next: 'Phase 9 - Claude API integration',
      },
      features: {
        weatherApi: 'Open-Meteo Weather API integration',
        airQualityApi: 'Open-Meteo Air Quality API integration',
        fallbackHandling: 'Graceful degradation on API failures',
      },
    },
    HttpStatus.OK,
  );
});

// =============================================================================
// Helper Functions
// =============================================================================

/**
 * Determines the current time slot based on ISO 8601 timestamp
 *
 * Maps hours to time slots:
 * - 05:00-11:59: morning
 * - 12:00-17:59: afternoon
 * - 18:00-04:59: evening
 *
 * @param currentTime - ISO 8601 timestamp string
 * @returns Time slot classification for advice personalization
 * @example
 * determineTimeSlot('2025-12-10T08:30:00.000Z') // returns 'morning'
 * determineTimeSlot('2025-12-10T15:45:00.000Z') // returns 'afternoon'
 */
const determineTimeSlot = (currentTime: string): 'morning' | 'afternoon' | 'evening' => {
  try {
    const date = new Date(currentTime);
    const hour = date.getHours();

    if (hour >= 5 && hour < 12) {
      return 'morning';
    }
    if (hour >= 12 && hour < 18) {
      return 'afternoon';
    }
    return 'evening';
  } catch {
    // Default to morning if timestamp parsing fails
    return 'morning';
  }
};

export { adviceRouter };
