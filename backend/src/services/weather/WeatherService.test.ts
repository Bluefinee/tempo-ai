import { describe, expect, it, vi } from 'vitest';
import { err, isErr, isOk, ok } from '../../utils/result';
import type { OpenMeteoClient } from './OpenMeteoClient';
import { WeatherService } from './WeatherService';
import type { WeatherData } from './types';

describe('WeatherService', () => {
  const mockWeatherData: WeatherData = {
    temperature: 20,
    humidity: 60,
    pressure: 1013,
    weatherCode: 0,
    uvIndexMax: 5,
    sunrise: '2025-01-01T06:00',
    sunset: '2025-01-01T17:00',
    airQuality: { pm25: 10, aqi: 25 },
  };

  const createMockClient = (fetchWeatherImpl: OpenMeteoClient['fetchWeather']): OpenMeteoClient => {
    return {
      fetchWeather: fetchWeatherImpl,
      buildWeatherUrl: vi.fn(),
      buildAirQualityUrl: vi.fn(),
    } as unknown as OpenMeteoClient;
  };

  describe('getWeather', () => {
    it('should validate latitude range', async () => {
      const mockClient = createMockClient(vi.fn());
      const service = new WeatherService(mockClient);

      // Invalid latitude (too high)
      const result1 = await service.getWeather({ latitude: 91, longitude: 0 });
      expect(isErr(result1)).toBe(true);
      if (isErr(result1)) {
        expect(result1.error.code).toBe('INVALID_COORDINATES');
      }

      // Invalid latitude (too low)
      const result2 = await service.getWeather({ latitude: -91, longitude: 0 });
      expect(isErr(result2)).toBe(true);
      if (isErr(result2)) {
        expect(result2.error.code).toBe('INVALID_COORDINATES');
      }
    });

    it('should validate longitude range', async () => {
      const mockClient = createMockClient(vi.fn());
      const service = new WeatherService(mockClient);

      // Invalid longitude (too high)
      const result1 = await service.getWeather({ latitude: 0, longitude: 181 });
      expect(isErr(result1)).toBe(true);
      if (isErr(result1)) {
        expect(result1.error.code).toBe('INVALID_COORDINATES');
      }

      // Invalid longitude (too low)
      const result2 = await service.getWeather({
        latitude: 0,
        longitude: -181,
      });
      expect(isErr(result2)).toBe(true);
      if (isErr(result2)) {
        expect(result2.error.code).toBe('INVALID_COORDINATES');
      }
    });

    it('should accept valid coordinates at boundaries', async () => {
      const mockClient = createMockClient(vi.fn().mockResolvedValue(ok(mockWeatherData)));
      const service = new WeatherService(mockClient);

      // Valid boundary values
      const result1 = await service.getWeather({
        latitude: 90,
        longitude: 180,
      });
      expect(isOk(result1)).toBe(true);

      const result2 = await service.getWeather({
        latitude: -90,
        longitude: -180,
      });
      expect(isOk(result2)).toBe(true);
    });

    it('should delegate to client on valid input', async () => {
      const mockFetch = vi.fn().mockResolvedValue(ok(mockWeatherData));
      const mockClient = createMockClient(mockFetch);
      const service = new WeatherService(mockClient);

      const result = await service.getWeather({
        latitude: 35.6762,
        longitude: 139.6503,
      });

      expect(isOk(result)).toBe(true);
      expect(mockFetch).toHaveBeenCalledWith(35.6762, 139.6503);
    });

    it('should propagate client errors', async () => {
      const mockClient = createMockClient(
        vi.fn().mockResolvedValue(
          err({
            code: 'API_ERROR' as const,
            message: 'API failed',
          }),
        ),
      );
      const service = new WeatherService(mockClient);

      const result = await service.getWeather({
        latitude: 35.6762,
        longitude: 139.6503,
      });

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('API_ERROR');
      }
    });
  });
});
