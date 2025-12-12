import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { fetchWeatherData } from '../services/weather.js';
import { fetchAirQualityData } from '../services/airQuality.js';
import { generateEnvironmentAdvice } from '../services/environmentAdvice.js';
import { calculatePressureTrend } from '../utils/pressure.js';
import type { EnvironmentResponse } from '../types/domain.js';

const app = new Hono();

// =============================================================================
// Query Parameter Validation
// =============================================================================

/**
 * クエリパラメータのバリデーションスキーマ
 */
const querySchema = z.object({
  lat: z.string().transform(Number).pipe(z.number().min(-90).max(90)),
  lon: z.string().transform(Number).pipe(z.number().min(-180).max(180)),
});

// =============================================================================
// Route Handler
// =============================================================================

/**
 * GET /api/environment
 *
 * 緯度経度を基に環境データ（天気、大気質、気圧トレンド、環境アドバイス）を取得
 *
 * @param lat - 緯度（-90 〜 90）
 * @param lon - 経度（-180 〜 180）
 * @returns EnvironmentResponse
 *
 * @example
 * ```
 * GET /api/environment?lat=35.6762&lon=139.6503
 * ```
 */
app.get('/', zValidator('query', querySchema), async (c): Promise<Response> => {
  const { lat, lon } = c.req.valid('query');

  console.log(`[Environment] Fetching data for lat=${lat}, lon=${lon}`);

  try {
    // 並列でデータ取得
    const [weatherData, airQualityData] = await Promise.all([
      fetchWeatherData({ latitude: lat, longitude: lon, includeHourlyPressure: true }),
      fetchAirQualityData({ latitude: lat, longitude: lon }),
    ]);

    // 気圧トレンド算出
    const pressureTrend = calculatePressureTrend(
      weatherData.pressureHpa,
      weatherData.hourlyPressure?.pressure3hAgo,
    );

    console.log(`[Environment] Pressure trend: ${pressureTrend}`);

    // 環境アドバイス生成
    const advice = generateEnvironmentAdvice(weatherData, airQualityData, pressureTrend);

    console.log(`[Environment] Generated ${advice.length} advice items`);

    // レスポンス構築
    const response: EnvironmentResponse = {
      location: {
        city: '東京', // TODO: Phase 11以降でgeocoding APIから取得
        latitude: lat,
        longitude: lon,
      },
      weather: {
        current: {
          condition: weatherData.condition,
          tempCurrentC: weatherData.tempCurrentC,
          tempMaxC: weatherData.tempMaxC,
          tempMinC: weatherData.tempMinC,
          humidityPercent: weatherData.humidityPercent,
          uvIndex: weatherData.uvIndex,
          pressureHpa: weatherData.pressureHpa,
          precipitationProbability: weatherData.precipitationProbability,
        },
        pressureTrend,
      },
      airQuality: airQualityData,
      advice,
      fetchedAt: new Date().toISOString(),
    };

    console.log('[Environment] Response prepared successfully');

    return c.json(response);
  } catch (error) {
    console.error('[Environment] Error:', error);
    return c.json(
      {
        error: 'Failed to fetch environment data',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      500,
    );
  }
});

export default app;
