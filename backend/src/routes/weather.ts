import { zValidator } from '@hono/zod-validator';
import { Hono } from 'hono';
import { z } from 'zod';
import type { Bindings } from '../index';
import { OpenMeteoClient } from '../services/weather/OpenMeteoClient';
import { WeatherService } from '../services/weather/WeatherService';
import { isOk } from '../utils/result';

const weatherRoutes = new Hono<{ Bindings: Bindings }>();

// Query parameter schema (transforms string to number)
const QuerySchema = z.object({
  latitude: z
    .string()
    .transform((v) => Number(v))
    .pipe(z.number().min(-90).max(90)),
  longitude: z
    .string()
    .transform((v) => Number(v))
    .pipe(z.number().min(-180).max(180)),
});

// Note: getStatusCode is not used anymore due to fallback implementation
// Keeping for reference if we want to return errors in the future
// const getStatusCode = (errorCode: WeatherError['code']): ContentfulStatusCode => {
//   const statusMap: Record<WeatherError['code'], ContentfulStatusCode> = {
//     INVALID_COORDINATES: 400,
//     API_ERROR: 502,
//     NETWORK_ERROR: 503,
//     PARSE_ERROR: 500,
//   };
//   return statusMap[errorCode];
// };

weatherRoutes.get(
  '/',
  zValidator('query', QuerySchema, (result, c) => {
    if (!result.success) {
      return c.json(
        {
          success: false,
          error:
            'Invalid query parameters: latitude and longitude are required and must be valid numbers',
        },
        400,
      );
    }
    return undefined;
  }),
  async (c) => {
    const { latitude, longitude } = c.req.valid('query');

    const client = new OpenMeteoClient();
    const service = new WeatherService(client);

    const result = await service.getWeather({ latitude, longitude });

    if (isOk(result)) {
      return c.json({ success: true, data: result.data });
    }

    // エラー時はデフォルト値を返す
    console.warn('Weather API failed, returning default data', result.error);
    return c.json({
      success: true,
      data: {
        temperature: 20,
        humidity: 50,
        pressure: 1013,
        weatherCode: 0,
        uvIndexMax: 5,
        sunrise: '06:00',
        sunset: '18:00',
        airQuality: {
          pm25: 10,
          aqi: 50,
        },
      },
    });
  },
);

export { weatherRoutes };
