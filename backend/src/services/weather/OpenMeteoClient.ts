import { type Result, err, ok } from '../../utils/result';
import {
  OpenMeteoAirQualityResponseSchema,
  OpenMeteoWeatherResponseSchema,
  type WeatherData,
  type WeatherError,
} from './types';

const WEATHER_BASE_URL = 'https://api.open-meteo.com/v1/forecast';
const AIR_QUALITY_BASE_URL = 'https://air-quality-api.open-meteo.com/v1/air-quality';

export class OpenMeteoClient {
  /**
   * Builds the URL for the Open-Meteo Weather API
   */
  buildWeatherUrl = (latitude: number, longitude: number): URL => {
    const url = new URL(WEATHER_BASE_URL);
    url.searchParams.set('latitude', latitude.toString());
    url.searchParams.set('longitude', longitude.toString());
    url.searchParams.set(
      'current',
      'temperature_2m,relative_humidity_2m,pressure_msl,weather_code',
    );
    url.searchParams.set('daily', 'uv_index_max,sunrise,sunset');
    url.searchParams.set('timezone', 'auto');
    return url;
  };

  /**
   * Builds the URL for the Open-Meteo Air Quality API
   */
  buildAirQualityUrl = (latitude: number, longitude: number): URL => {
    const url = new URL(AIR_QUALITY_BASE_URL);
    url.searchParams.set('latitude', latitude.toString());
    url.searchParams.set('longitude', longitude.toString());
    url.searchParams.set('current', 'pm2_5,us_aqi');
    return url;
  };

  /**
   * Fetches weather and air quality data from Open-Meteo APIs
   */
  fetchWeather = async (
    latitude: number,
    longitude: number,
  ): Promise<Result<WeatherData, WeatherError>> => {
    try {
      const [weatherRes, airQualityRes] = await Promise.all([
        fetch(this.buildWeatherUrl(latitude, longitude).toString()),
        fetch(this.buildAirQualityUrl(latitude, longitude).toString()),
      ]);

      if (!weatherRes.ok) {
        return err({
          code: 'API_ERROR',
          message: `Weather API returned ${weatherRes.status}`,
        });
      }

      if (!airQualityRes.ok) {
        return err({
          code: 'API_ERROR',
          message: `Air Quality API returned ${airQualityRes.status}`,
        });
      }

      // Parse JSON responses
      let weatherJson: unknown;
      let airJson: unknown;
      try {
        [weatherJson, airJson] = await Promise.all([weatherRes.json(), airQualityRes.json()]);
      } catch (parseError) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Failed to parse API response as JSON',
          details: parseError instanceof Error ? parseError.message : String(parseError),
        });
      }

      // Validate with Zod schemas
      const weatherResult = OpenMeteoWeatherResponseSchema.safeParse(weatherJson);
      if (!weatherResult.success) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Weather API response validation failed',
          details: weatherResult.error.format(),
        });
      }

      const airResult = OpenMeteoAirQualityResponseSchema.safeParse(airJson);
      if (!airResult.success) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Air Quality API response validation failed',
          details: airResult.error.format(),
        });
      }

      const weatherData = weatherResult.data;
      const airData = airResult.data;

      return ok({
        temperature: weatherData.current.temperature_2m,
        humidity: weatherData.current.relative_humidity_2m,
        pressure: weatherData.current.pressure_msl,
        weatherCode: weatherData.current.weather_code,
        uvIndexMax: weatherData.daily.uv_index_max[0] ?? 0,
        sunrise: weatherData.daily.sunrise[0] ?? '',
        sunset: weatherData.daily.sunset[0] ?? '',
        airQuality: {
          pm25: airData.current.pm2_5,
          aqi: airData.current.us_aqi,
        },
      });
    } catch (error) {
      return err({
        code: 'NETWORK_ERROR',
        message: 'Failed to fetch weather data',
        details: error instanceof Error ? error.message : String(error),
      });
    }
  };
}
