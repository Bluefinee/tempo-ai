import { zValidator } from '@hono/zod-validator';
import { Hono } from 'hono';
import type { ContentfulStatusCode } from 'hono/utils/http-status';
import { z } from 'zod';
import type { Bindings } from '../index';
import { OpenMeteoClient } from '../services/weather/OpenMeteoClient';
import { WeatherService } from '../services/weather/WeatherService';
import type { WeatherError } from '../services/weather/types';
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

/**
 * Maps weather error codes to HTTP status codes
 */
const getStatusCode = (errorCode: WeatherError['code']): ContentfulStatusCode => {
  const statusMap: Record<WeatherError['code'], ContentfulStatusCode> = {
    INVALID_COORDINATES: 400,
    API_ERROR: 502,
    NETWORK_ERROR: 503,
    PARSE_ERROR: 500,
  };
  return statusMap[errorCode];
};

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

    return c.json(
      { success: false, error: result.error.message },
      getStatusCode(result.error.code),
    );
  },
);

export { weatherRoutes };
