import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { isErr, isOk } from '../../utils/result';
import { OpenMeteoClient } from './OpenMeteoClient';
import type { OpenMeteoAirQualityResponse, OpenMeteoWeatherResponse } from './types';

/** Valid mock weather response matching the Zod schema */
const createMockWeatherResponse = (
  overrides?: Partial<OpenMeteoWeatherResponse>,
): OpenMeteoWeatherResponse => ({
  current: {
    temperature_2m: 20,
    relative_humidity_2m: 60,
    pressure_msl: 1013,
    weather_code: 0,
  },
  daily: {
    uv_index_max: [5],
    sunrise: ['2025-01-01T06:00'],
    sunset: ['2025-01-01T17:00'],
  },
  ...overrides,
});

/** Valid mock air quality response matching the Zod schema */
const createMockAirResponse = (
  overrides?: Partial<OpenMeteoAirQualityResponse>,
): OpenMeteoAirQualityResponse => ({
  current: {
    pm2_5: 10,
    us_aqi: 25,
  },
  ...overrides,
});

describe('OpenMeteoClient', () => {
  const client = new OpenMeteoClient();

  describe('buildWeatherUrl', () => {
    it('should build correct URL with all parameters', () => {
      const url = client.buildWeatherUrl(35.6762, 139.6503);

      expect(url.toString()).toContain('api.open-meteo.com');
      expect(url.searchParams.get('latitude')).toBe('35.6762');
      expect(url.searchParams.get('longitude')).toBe('139.6503');
      expect(url.searchParams.get('current')).toContain('temperature_2m');
      expect(url.searchParams.get('current')).toContain('relative_humidity_2m');
      expect(url.searchParams.get('current')).toContain('pressure_msl');
      expect(url.searchParams.get('current')).toContain('weather_code');
      expect(url.searchParams.get('daily')).toContain('uv_index_max');
      expect(url.searchParams.get('daily')).toContain('sunrise');
      expect(url.searchParams.get('daily')).toContain('sunset');
      expect(url.searchParams.get('timezone')).toBe('auto');
    });
  });

  describe('buildAirQualityUrl', () => {
    it('should build correct Air Quality URL', () => {
      const url = client.buildAirQualityUrl(35.6762, 139.6503);

      expect(url.toString()).toContain('air-quality-api.open-meteo.com');
      expect(url.searchParams.get('latitude')).toBe('35.6762');
      expect(url.searchParams.get('longitude')).toBe('139.6503');
      expect(url.searchParams.get('current')).toContain('pm2_5');
      expect(url.searchParams.get('current')).toContain('us_aqi');
    });
  });

  describe('fetchWeather', () => {
    const originalFetch = globalThis.fetch;

    beforeEach(() => {
      vi.resetAllMocks();
    });

    afterEach(() => {
      globalThis.fetch = originalFetch;
    });

    it('should return WeatherData on success', async () => {
      const mockWeatherResponse = createMockWeatherResponse();
      const mockAirResponse = createMockAirResponse();

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockWeatherResponse),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockAirResponse),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isOk(result)).toBe(true);
      if (isOk(result)) {
        expect(result.data.temperature).toBe(20);
        expect(result.data.humidity).toBe(60);
        expect(result.data.pressure).toBe(1013);
        expect(result.data.weatherCode).toBe(0);
        expect(result.data.uvIndexMax).toBe(5);
        expect(result.data.sunrise).toBe('2025-01-01T06:00');
        expect(result.data.sunset).toBe('2025-01-01T17:00');
        expect(result.data.airQuality.pm25).toBe(10);
        expect(result.data.airQuality.aqi).toBe(25);
      }
    });

    it('should return error on Weather API failure', async () => {
      globalThis.fetch = vi.fn().mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('API_ERROR');
        expect(result.error.message).toContain('Weather API');
      }
    });

    it('should return error on Air Quality API failure', async () => {
      const mockWeatherResponse = createMockWeatherResponse();

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockWeatherResponse),
        })
        .mockResolvedValueOnce({
          ok: false,
          status: 503,
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('API_ERROR');
        expect(result.error.message).toContain('Air Quality API');
      }
    });

    it('should return error on network failure', async () => {
      globalThis.fetch = vi.fn().mockRejectedValueOnce(new Error('Network error'));

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('NETWORK_ERROR');
      }
    });

    it('should handle empty daily arrays gracefully', async () => {
      const mockWeatherResponse = createMockWeatherResponse({
        daily: {
          uv_index_max: [],
          sunrise: [],
          sunset: [],
        },
      });
      const mockAirResponse = createMockAirResponse();

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockWeatherResponse),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockAirResponse),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isOk(result)).toBe(true);
      if (isOk(result)) {
        expect(result.data.uvIndexMax).toBe(0);
        expect(result.data.sunrise).toBe('');
        expect(result.data.sunset).toBe('');
      }
    });

    it('should return PARSE_ERROR when JSON parsing fails', async () => {
      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.reject(new Error('Invalid JSON')),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(createMockAirResponse()),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('parse');
      }
    });

    it('should return PARSE_ERROR when weather response schema validation fails', async () => {
      const invalidWeatherResponse = {
        current: {
          temperature_2m: 'not a number', // Invalid: should be number
          relative_humidity_2m: 60,
          pressure_msl: 1013,
          weather_code: 0,
        },
        daily: {
          uv_index_max: [5],
          sunrise: ['2025-01-01T06:00'],
          sunset: ['2025-01-01T17:00'],
        },
      };

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(invalidWeatherResponse),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(createMockAirResponse()),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('Weather API response validation failed');
      }
    });

    it('should return PARSE_ERROR when air quality response schema validation fails', async () => {
      const invalidAirResponse = {
        current: {
          pm2_5: 'invalid', // Invalid: should be number
          us_aqi: 25,
        },
      };

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(createMockWeatherResponse()),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(invalidAirResponse),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('Air Quality API response validation failed');
      }
    });

    it('should return PARSE_ERROR when response is missing required fields', async () => {
      const incompleteWeatherResponse = {
        current: {
          temperature_2m: 20,
          // Missing other required fields
        },
      };

      globalThis.fetch = vi
        .fn()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(incompleteWeatherResponse),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(createMockAirResponse()),
        });

      const result = await client.fetchWeather(35.6762, 139.6503);

      expect(isErr(result)).toBe(true);
      if (isErr(result)) {
        expect(result.error.code).toBe('PARSE_ERROR');
      }
    });
  });
});
