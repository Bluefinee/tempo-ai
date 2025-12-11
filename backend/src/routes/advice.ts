import { Hono } from 'hono';
import type { Context } from 'hono';
import { rateLimit, validateApiKey } from '../middleware/auth.js';
import { validateAdviceRequest, type AdviceRequest } from '../types/request.js';
import type { LocationData, EnvironmentData } from '../types/domain.js';
import { HttpStatus } from '../types/response.js';
import { createValidationErrorResponse } from '../utils/errors.js';
import { fetchWeatherData } from '../services/weather.js';
import { fetchAirQualityData } from '../services/airQuality.js';
import { generateMainAdvice, createFallbackAdvice } from '../services/claude.js';
import type { RequestContext } from '../types/claude.js';

// =============================================================================
// Advice Router Setup
// =============================================================================

interface Bindings {
  ENVIRONMENT: 'development' | 'production' | 'staging';
  ANTHROPIC_API_KEY: string;
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

  // Fetch environment data (weather and air quality) with fallback handling
  const environmentData = await fetchEnvironmentData(adviceRequest.location);

  // Generate AI-powered advice using Claude API
  try {
    const apiKey = getApiKey(c);
    const requestContext = buildRequestContext(adviceRequest.context.currentTime);

    const advice = await generateMainAdvice({
      userProfile: adviceRequest.userProfile,
      healthData: adviceRequest.healthData,
      weatherData: environmentData.weather ?? undefined,
      airQualityData: environmentData.airQuality ?? undefined,
      context: requestContext,
      apiKey,
    });

    console.log('[Claude] Main advice generated successfully');

    const response = {
      success: true,
      data: advice,
    };

    // Log successful request (without sensitive data)
    console.log('Advice request processed:', {
      timestamp: new Date().toISOString(),
      nickname: adviceRequest.userProfile.nickname,
      timeSlot: advice.timeSlot,
      interests: adviceRequest.userProfile.interests,
      hasHealthData: !!adviceRequest.healthData.sleep,
      location: adviceRequest.location.city || 'coordinates-only',
      environment: {
        hasWeatherData: !!environmentData.weather,
        hasAirQualityData: !!environmentData.airQuality,
        weatherCondition: environmentData.weather?.condition,
        aqi: environmentData.airQuality?.aqi,
      },
      aiGenerated: true,
    });

    return c.json(response, HttpStatus.OK);

  } catch (error) {
    console.error('[Claude] Advice generation failed, using fallback:', error);
    
    // Fallback to mock response on Claude API failure
    const fallbackAdvice = createFallbackAdvice(adviceRequest.userProfile.nickname);
    const mockResponse = {
      success: true,
      data: fallbackAdvice,
    };

    // Log fallback usage
    console.log('Using fallback advice due to Claude API error:', {
      timestamp: new Date().toISOString(),
      nickname: adviceRequest.userProfile.nickname,
      error: error instanceof Error ? error.message : 'Unknown error',
    });

    return c.json(mockResponse, HttpStatus.OK);
  }
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
      message: 'Tempo AI Advice API - Phase 9 Implementation',
      status: 'active',
      version: '0.1.0',
      environment: c.env?.ENVIRONMENT || 'development',
      endpoints: {
        advice: 'POST /api/advice - Generate AI-powered daily advice with environmental data',
      },
      phase: {
        current: 9,
        description: 'Claude API integration for AI-powered advice generation',
        next: 'Phase 10 - iOS frontend integration',
      },
      features: {
        claudeApi: 'Claude Sonnet API for main advice generation',
        weatherApi: 'Open-Meteo Weather API integration',
        airQualityApi: 'Open-Meteo Air Quality API integration',
        promptCaching: 'Optimized prompt caching for cost reduction',
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
 * Claude API キーを環境変数から取得
 * @param c - Hono context
 * @returns API key
 * @throws AuthenticationError if API key is not configured
 */
const getApiKey = (c: Context<{ Bindings: Bindings }>): string => {
  const key = c.env.ANTHROPIC_API_KEY;
  if (!key) {
    throw new Error("ANTHROPIC_API_KEY is not configured");
  }
  return key;
};

/**
 * リクエストコンテキストを構築
 * @param currentTime - 現在時刻のISO文字列
 * @returns RequestContext
 */
const buildRequestContext = (currentTime: string): RequestContext => {
  const date = new Date(currentTime);
  const dayOfWeek = date.toLocaleDateString('ja-JP', { weekday: 'long' });
  const isMonday = date.getDay() === 1;

  // TODO: Phase 12で実際の履歴データを取得する予定
  const recentDailyTries: string[] = [];
  const lastWeeklyTry: string | null = null;

  return {
    currentTime,
    dayOfWeek,
    isMonday,
    recentDailyTries,
    lastWeeklyTry,
  };
};


export { adviceRouter };
