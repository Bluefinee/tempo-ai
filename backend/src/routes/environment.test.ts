import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import app from '../index.js';
import type { EnvironmentResponse } from '../types/domain.js';

// Mock services
vi.mock('../services/weather.js', () => ({
  fetchWeatherData: vi.fn(),
}));
vi.mock('../services/airQuality.js', () => ({
  fetchAirQualityData: vi.fn(),
}));
vi.mock('../services/environmentAdvice.js', () => ({
  generateEnvironmentAdvice: vi.fn(),
}));
vi.mock('../utils/pressure.js', () => ({
  calculatePressureTrend: vi.fn(),
}));

import { fetchWeatherData } from '../services/weather.js';
import { fetchAirQualityData } from '../services/airQuality.js';
import { generateEnvironmentAdvice } from '../services/environmentAdvice.js';
import { calculatePressureTrend } from '../utils/pressure.js';

describe('Environment Routes', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(console, 'log').mockImplementation(() => {
      // Mock implementation
    });
    vi.spyOn(console, 'error').mockImplementation(() => {
      // Mock implementation
    });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  const mockWeatherData = {
    condition: '晴れ',
    tempCurrentC: 22.5,
    tempMaxC: 25.3,
    tempMinC: 18.7,
    humidityPercent: 65,
    uvIndex: 5.2,
    pressureHpa: 1013.2,
    precipitationProbability: 20,
    hourlyPressure: {
      pressure3hAgo: 1015.5,
    },
  };

  const mockAirQualityData = {
    aqi: 45,
    pm25: 12,
    pm10: 28,
  };

  const mockAdvice = [
    {
      type: 'air_quality' as const,
      message: '大気質は良好。屋外運動に適しています',
    },
    {
      type: 'uv' as const,
      message: 'UV指数は中程度。長時間の外出には日焼け止めを',
    },
  ];

  describe('GET /api/environment', () => {
    it('should return environment data successfully', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as EnvironmentResponse;

      expect(res.status).toBe(200);
      expect(data).toHaveProperty('location');
      expect(data.location.latitude).toBe(35.6762);
      expect(data.location.longitude).toBe(139.6503);
      expect(data).toHaveProperty('weather');
      expect(data.weather.current.condition).toBe('晴れ');
      expect(data.weather.pressureTrend).toBe('stable');
      expect(data).toHaveProperty('airQuality');
      expect(data.airQuality.aqi).toBe(45);
      expect(data).toHaveProperty('advice');
      expect(data.advice).toHaveLength(2);
      expect(data).toHaveProperty('fetchedAt');
    });

    it('should include pressure trend in response', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('rising');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as EnvironmentResponse;

      expect(data.weather.pressureTrend).toBe('rising');
      expect(vi.mocked(calculatePressureTrend)).toHaveBeenCalledWith(1013.2, 1015.5);
    });

    it('should include environment advice (max 3 items)', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as EnvironmentResponse;

      expect(data.advice).toHaveLength(2);
      expect(data.advice[0]).toHaveProperty('type');
      expect(data.advice[0]).toHaveProperty('message');
    });

    it('should return fetchedAt in ISO8601 format', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as EnvironmentResponse;

      expect(data.fetchedAt).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
    });

    it('should call fetchWeatherData with includeHourlyPressure: true', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      await app.request('/api/environment?lat=35.6762&lon=139.6503');

      expect(vi.mocked(fetchWeatherData)).toHaveBeenCalledWith({
        latitude: 35.6762,
        longitude: 139.6503,
        includeHourlyPressure: true,
      });
    });

    it('should fetch weather and air quality data in parallel', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);

      await app.request('/api/environment?lat=35.6762&lon=139.6503');

      expect(vi.mocked(fetchWeatherData)).toHaveBeenCalled();
      expect(vi.mocked(fetchAirQualityData)).toHaveBeenCalled();
    });
  });

  describe('Validation Errors', () => {
    it('should return 400 when lat parameter is missing', async () => {
      const res = await app.request('/api/environment?lon=139.6503');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lon parameter is missing', async () => {
      const res = await app.request('/api/environment?lat=35.6762');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lat is invalid (> 90)', async () => {
      const res = await app.request('/api/environment?lat=95&lon=139.6503');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lat is invalid (< -90)', async () => {
      const res = await app.request('/api/environment?lat=-95&lon=139.6503');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lon is invalid (> 180)', async () => {
      const res = await app.request('/api/environment?lat=35.6762&lon=185');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lon is invalid (< -180)', async () => {
      const res = await app.request('/api/environment?lat=35.6762&lon=-185');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lat is not a number', async () => {
      const res = await app.request('/api/environment?lat=invalid&lon=139.6503');

      expect(res.status).toBe(400);
    });

    it('should return 400 when lon is not a number', async () => {
      const res = await app.request('/api/environment?lat=35.6762&lon=invalid');

      expect(res.status).toBe(400);
    });
  });

  describe('Boundary Values', () => {
    beforeEach(() => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);
      vi.mocked(calculatePressureTrend).mockReturnValue('stable');
      vi.mocked(generateEnvironmentAdvice).mockReturnValue(mockAdvice);
    });

    it('should accept lat = -90', async () => {
      const res = await app.request('/api/environment?lat=-90&lon=0');

      expect(res.status).toBe(200);
    });

    it('should accept lat = 90', async () => {
      const res = await app.request('/api/environment?lat=90&lon=0');

      expect(res.status).toBe(200);
    });

    it('should accept lon = -180', async () => {
      const res = await app.request('/api/environment?lat=0&lon=-180');

      expect(res.status).toBe(200);
    });

    it('should accept lon = 180', async () => {
      const res = await app.request('/api/environment?lat=0&lon=180');

      expect(res.status).toBe(200);
    });
  });

  describe('Error Handling', () => {
    it('should return 500 when weather API fails', async () => {
      vi.mocked(fetchWeatherData).mockRejectedValue(new Error('Weather API error'));
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as { error: string; message: string };

      expect(res.status).toBe(500);
      expect(data).toHaveProperty('error');
      expect(data.error).toBe('Failed to fetch environment data');
      expect(data).toHaveProperty('message');
    });

    it('should return 500 when air quality API fails', async () => {
      vi.mocked(fetchWeatherData).mockResolvedValue(mockWeatherData);
      vi.mocked(fetchAirQualityData).mockRejectedValue(new Error('Air quality API error'));

      const res = await app.request('/api/environment?lat=35.6762&lon=139.6503');
      const data = (await res.json()) as { error: string; message: string };

      expect(res.status).toBe(500);
      expect(data).toHaveProperty('error');
      expect(data.error).toBe('Failed to fetch environment data');
    });

    it('should log errors to console', async () => {
      const consoleErrorSpy = vi.spyOn(console, 'error');
      vi.mocked(fetchWeatherData).mockRejectedValue(new Error('Test error'));
      vi.mocked(fetchAirQualityData).mockResolvedValue(mockAirQualityData);

      await app.request('/api/environment?lat=35.6762&lon=139.6503');

      expect(consoleErrorSpy).toHaveBeenCalledWith('[Environment] Error:', expect.any(Error));
    });
  });
});
