import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { fetchWeatherData } from './weather.js';
import { WeatherApiError } from '../utils/errors.js';

// Mock global fetch
const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

describe('Weather Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(console, 'log').mockImplementation(() => {
      // Mock implementation for testing
    });
    vi.spyOn(console, 'error').mockImplementation(() => {
      // Mock implementation for testing
    });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  const validParams = {
    latitude: 35.6762,
    longitude: 139.6503,
  };

  const mockOpenMeteoResponse = {
    current: {
      temperature_2m: 22.5,
      relative_humidity_2m: 65,
      weather_code: 1,
      surface_pressure: 1013.2,
    },
    daily: {
      temperature_2m_max: [25.3],
      temperature_2m_min: [18.7],
      uv_index_max: [5.2],
      precipitation_probability_max: [20],
    },
  };

  describe('fetchWeatherData', () => {
    it('should fetch weather data successfully', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchWeatherData(validParams);

      expect(result).toEqual({
        condition: '晴れ',
        tempCurrentC: 22.5,
        tempMaxC: 25.3,
        tempMinC: 18.7,
        humidityPercent: 65,
        uvIndex: 5.2,
        pressureHpa: 1013.2,
        precipitationProbability: 20,
      });

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('api.open-meteo.com/v1/forecast'),
        expect.objectContaining({
          signal: expect.any(AbortSignal),
        })
      );
    });

    it('should build correct API URL with parameters', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      await fetchWeatherData(validParams);

      const calledUrl = mockFetch.mock.calls[0]?.[0] as string;
      expect(calledUrl).toBeDefined();
      expect(calledUrl).toContain('latitude=35.6762');
      expect(calledUrl).toContain('longitude=139.6503');
      expect(calledUrl).toContain('current=temperature_2m%2Crelative_humidity_2m%2Cweather_code%2Csurface_pressure');
      expect(calledUrl).toContain('daily=temperature_2m_max%2Ctemperature_2m_min%2Cuv_index_max%2Cprecipitation_probability_max');
      expect(calledUrl).toContain('timezone=Asia%2FTokyo');
    });

    it('should validate latitude parameter', async () => {
      const invalidParams = { latitude: -95, longitude: 139.6503 };

      await expect(fetchWeatherData(invalidParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(invalidParams)).rejects.toThrow('Invalid latitude: -95');
    });

    it('should validate longitude parameter', async () => {
      const invalidParams = { latitude: 35.6762, longitude: 185 };

      await expect(fetchWeatherData(invalidParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(invalidParams)).rejects.toThrow('Invalid longitude: 185');
    });

    it('should handle API error responses', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 400,
        statusText: 'Bad Request',
      });

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('Weather API returned 400: Bad Request');
    });

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValue(new Error('Network error'));

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('Weather API request failed: Network error');
    });

    it('should handle timeout errors', async () => {
      mockFetch.mockRejectedValue(Object.assign(new Error('The operation was aborted.'), { name: 'AbortError' }));

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('Weather API request timed out after 5000ms');
    });

    it('should handle missing current data', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => ({ daily: mockOpenMeteoResponse.daily }),
      });

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('missing current or daily data');
    });

    it('should handle missing daily data', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => ({ current: mockOpenMeteoResponse.current }),
      });

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('missing current or daily data');
    });

    it('should handle incomplete daily forecast data', async () => {
      const incompleteResponse = {
        current: mockOpenMeteoResponse.current,
        daily: {
          temperature_2m_max: [], // Empty array
          temperature_2m_min: [18.7],
          uv_index_max: [5.2],
          precipitation_probability_max: [20],
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => incompleteResponse,
      });

      await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      await expect(fetchWeatherData(validParams)).rejects.toThrow('missing daily forecast data');
    });

    describe('Weather Code Conversion', () => {
      const weatherCodeTests = [
        { code: 0, expected: '快晴' },
        { code: 1, expected: '晴れ' },
        { code: 2, expected: '晴れ' },
        { code: 3, expected: '晴れ' },
        { code: 45, expected: '霧' },
        { code: 48, expected: '霧' },
        { code: 51, expected: '霧雨' },
        { code: 61, expected: '雨' },
        { code: 71, expected: '雪' },
        { code: 95, expected: '雷雨' },
        { code: 999, expected: '不明' }, // Unknown code
      ];

      for (const { code, expected } of weatherCodeTests) {
        it(`should convert weather code ${code} to ${expected}`, async () => {
          const responseWithCode = {
            ...mockOpenMeteoResponse,
            current: {
              ...mockOpenMeteoResponse.current,
              weather_code: code,
            },
          };

          mockFetch.mockResolvedValue({
            ok: true,
            json: async () => responseWithCode,
          });

          const result = await fetchWeatherData(validParams);
          expect(result.condition).toBe(expected);
        });
      }
    });

    it('should log request and response correctly', async () => {
      const consoleSpy = vi.spyOn(console, 'log');
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      await fetchWeatherData(validParams);

      expect(consoleSpy).toHaveBeenCalledWith('[Weather] Fetching for lat=35.6762, lon=139.6503');
      expect(consoleSpy).toHaveBeenCalledWith('[Weather] Response:', expect.any(Object));
    });

    it('should log errors correctly', async () => {
      const consoleErrorSpy = vi.spyOn(console, 'error');
      
      mockFetch.mockRejectedValue(new Error('Test error'));

      await expect(fetchWeatherData(validParams)).rejects.toThrow();

      expect(consoleErrorSpy).toHaveBeenCalledWith('[Weather] Error:', expect.stringContaining('Test error'));
    });
  });

  describe('Edge Cases', () => {
    it('should handle extreme coordinates', async () => {
      const extremeParams = { latitude: -89.9, longitude: 179.9 };
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchWeatherData(extremeParams);
      expect(result).toBeTruthy();
    });

    it('should handle zero coordinates', async () => {
      const zeroParams = { latitude: 0, longitude: 0 };
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchWeatherData(zeroParams);
      expect(result).toBeTruthy();
    });

    it('should handle fractional coordinates', async () => {
      const fractionalParams = { latitude: 35.6762123, longitude: 139.6503456 };
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchWeatherData(fractionalParams);
      expect(result).toBeTruthy();
    });
  });
});