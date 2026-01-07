import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import app from '../index';
import type {
  OpenMeteoAirQualityResponse,
  OpenMeteoWeatherResponse,
  WeatherData,
} from '../services/weather/types';

describe('GET /api/weather', () => {
  const originalFetch = globalThis.fetch;

  const mockWeatherResponse: OpenMeteoWeatherResponse = {
    current: {
      temperature_2m: 20.5,
      relative_humidity_2m: 65,
      pressure_msl: 1013.25,
      weather_code: 0,
    },
    daily: {
      uv_index_max: [5.2],
      sunrise: ['2025-01-01T06:50:00+09:00'],
      sunset: ['2025-01-01T16:45:00+09:00'],
    },
  };

  const mockAirResponse: OpenMeteoAirQualityResponse = {
    current: {
      pm2_5: 12.5,
      us_aqi: 42,
    },
  };

  beforeEach(() => {
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
  });

  afterEach(() => {
    globalThis.fetch = originalFetch;
    vi.resetAllMocks();
  });

  it('should return 400 for missing parameters', async () => {
    const res = await app.request('/api/weather');

    expect(res.status).toBe(400);

    const json = (await res.json()) as { success: boolean };
    expect(json.success).toBe(false);
  });

  it('should return 400 for missing latitude', async () => {
    const res = await app.request('/api/weather?longitude=139');

    expect(res.status).toBe(400);
  });

  it('should return 400 for missing longitude', async () => {
    const res = await app.request('/api/weather?latitude=35');

    expect(res.status).toBe(400);
  });

  it('should return 400 for invalid latitude', async () => {
    const res = await app.request('/api/weather?latitude=91&longitude=139');

    expect(res.status).toBe(400);

    const json = (await res.json()) as { success: boolean };
    expect(json.success).toBe(false);
  });

  it('should return 400 for invalid longitude', async () => {
    const res = await app.request('/api/weather?latitude=35&longitude=181');

    expect(res.status).toBe(400);
  });

  it('should return 400 for non-numeric values', async () => {
    const res = await app.request('/api/weather?latitude=abc&longitude=def');

    expect(res.status).toBe(400);
  });

  it('should return weather data for valid coordinates', async () => {
    const res = await app.request('/api/weather?latitude=35.6762&longitude=139.6503');

    expect(res.status).toBe(200);

    const json = (await res.json()) as {
      success: boolean;
      data: {
        temperature: number;
        humidity: number;
        pressure: number;
        weatherCode: number;
        uvIndexMax: number;
        sunrise: string;
        sunset: string;
        airQuality: { pm25: number; aqi: number };
      };
    };

    expect(json.success).toBe(true);
    expect(json.data.temperature).toBe(20.5);
    expect(json.data.humidity).toBe(65);
    expect(json.data.pressure).toBe(1013.25);
    expect(json.data.weatherCode).toBe(0);
    expect(json.data.uvIndexMax).toBe(5.2);
    expect(json.data.sunrise).toBe('2025-01-01T06:50:00+09:00');
    expect(json.data.sunset).toBe('2025-01-01T16:45:00+09:00');
    expect(json.data.airQuality.pm25).toBe(12.5);
    expect(json.data.airQuality.aqi).toBe(42);
  });

  it('should handle API errors gracefully', async () => {
    globalThis.fetch = vi.fn().mockResolvedValueOnce({
      ok: false,
      status: 500,
    });

    const res = await app.request('/api/weather?latitude=35.6762&longitude=139.6503');

    // エラー時はデフォルト天気データを返すため、200になる
    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data?: WeatherData };
    expect(json.success).toBe(true);
    // デフォルトデータが返されていることを確認
    expect(json.data).toBeDefined();
  });

  it('should handle network errors gracefully', async () => {
    globalThis.fetch = vi.fn().mockRejectedValueOnce(new Error('Network error'));

    const res = await app.request('/api/weather?latitude=35.6762&longitude=139.6503');

    // エラー時はデフォルト天気データを返すため、200になる
    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data?: WeatherData };
    expect(json.success).toBe(true);
    // デフォルトデータが返されていることを確認
    expect(json.data).toBeDefined();
  });
});
