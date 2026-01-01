import { type Result, err } from '../../utils/result';
import type { OpenMeteoClient } from './OpenMeteoClient';
import {
  type WeatherData,
  type WeatherError,
  type WeatherRequest,
  WeatherRequestSchema,
} from './types';

export class WeatherService {
  constructor(private readonly client: OpenMeteoClient) {}

  /**
   * Gets weather data for the given coordinates
   * Validates input and delegates to the OpenMeteoClient
   */
  getWeather = async (request: WeatherRequest): Promise<Result<WeatherData, WeatherError>> => {
    const validation = WeatherRequestSchema.safeParse(request);

    if (!validation.success) {
      return err({
        code: 'INVALID_COORDINATES',
        message: 'Invalid coordinates provided',
        details: validation.error.format(),
      });
    }

    const { latitude, longitude } = validation.data;
    return this.client.fetchWeather(latitude, longitude);
  };
}
