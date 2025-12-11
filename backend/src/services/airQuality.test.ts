// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { fetchAirQualityData } from './airQuality.js';
import { AirQualityApiError } from '../utils/errors.js';

// Mock global fetch
const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

describe('Air Quality Service', () => {
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
      pm2_5: 12.5,
      pm10: 20.3,
      us_aqi: 45,
    },
  };

  describe('fetchAirQualityData', () => {
    it('should fetch air quality data successfully', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchAirQualityData(validParams);

      expect(result).toEqual({
        aqi: 45,
        pm25: 12.5,
        pm10: 20.3,
      });

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('air-quality-api.open-meteo.com/v1/air-quality'),
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

      await fetchAirQualityData(validParams);

      const calledUrl = mockFetch.mock.calls[0]?.[0] as string;
      expect(calledUrl).toBeDefined();
      expect(calledUrl).toContain('latitude=35.6762');
      expect(calledUrl).toContain('longitude=139.6503');
      expect(calledUrl).toContain('current=pm2_5%2Cpm10%2Cus_aqi');
    });

    it('should validate latitude parameter', async () => {
      const invalidParams = { latitude: -95, longitude: 139.6503 };

      await expect(fetchAirQualityData(invalidParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(invalidParams)).rejects.toThrow('Invalid latitude: -95');
    });

    it('should validate longitude parameter', async () => {
      const invalidParams = { latitude: 35.6762, longitude: 185 };

      await expect(fetchAirQualityData(invalidParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(invalidParams)).rejects.toThrow('Invalid longitude: 185');
    });

    it('should handle API error responses', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
      });

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('Air Quality API returned 500: Internal Server Error');
    });

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValue(new Error('Network connection failed'));

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('Air Quality API request failed: Network connection failed');
    });

    it('should handle timeout errors', async () => {
      mockFetch.mockRejectedValue(Object.assign(new Error('The operation was aborted.'), { name: 'AbortError' }));

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('Air Quality API request timed out after 5000ms');
    });

    it('should handle missing current data', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => ({}),
      });

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('missing current data');
    });

    it('should handle missing required fields', async () => {
      const incompleteResponse = {
        current: {
          pm2_5: 12.5,
          // Missing us_aqi
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => incompleteResponse,
      });

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('missing required fields');
    });

    it('should handle negative values', async () => {
      const negativeResponse = {
        current: {
          pm2_5: -5,
          pm10: 20.3,
          us_aqi: 45,
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => negativeResponse,
      });

      await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      await expect(fetchAirQualityData(validParams)).rejects.toThrow('negative values detected');
    });

    it('should handle optional pm10 field', async () => {
      const responseWithoutPm10 = {
        current: {
          pm2_5: 12.5,
          us_aqi: 45,
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => responseWithoutPm10,
      });

      const result = await fetchAirQualityData(validParams);

      expect(result).toEqual({
        aqi: 45,
        pm25: 12.5,
        pm10: undefined,
      });
    });

    it('should handle negative pm10 by setting to undefined', async () => {
      const responseWithNegativePm10 = {
        current: {
          pm2_5: 12.5,
          pm10: -10,
          us_aqi: 45,
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => responseWithNegativePm10,
      });

      const result = await fetchAirQualityData(validParams);

      expect(result).toEqual({
        aqi: 45,
        pm25: 12.5,
        pm10: undefined,
      });
    });

    it('should log request and response correctly', async () => {
      const consoleSpy = vi.spyOn(console, 'log');
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      await fetchAirQualityData(validParams);

      expect(consoleSpy).toHaveBeenCalledWith('[AirQuality] Fetching for lat=35.6762, lon=139.6503');
      expect(consoleSpy).toHaveBeenCalledWith('[AirQuality] Response:', expect.any(Object));
    });

    it('should log errors correctly', async () => {
      const consoleErrorSpy = vi.spyOn(console, 'error');
      
      mockFetch.mockRejectedValue(new Error('Test error'));

      await expect(fetchAirQualityData(validParams)).rejects.toThrow();

      expect(consoleErrorSpy).toHaveBeenCalledWith('[AirQuality] Error:', expect.stringContaining('Test error'));
    });
  });

  describe('Edge Cases', () => {
    it('should handle extreme coordinates', async () => {
      const extremeParams = { latitude: -89.9, longitude: 179.9 };
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchAirQualityData(extremeParams);
      expect(result).toBeTruthy();
    });

    it('should handle zero coordinates', async () => {
      const zeroParams = { latitude: 0, longitude: 0 };
      
      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => mockOpenMeteoResponse,
      });

      const result = await fetchAirQualityData(zeroParams);
      expect(result).toBeTruthy();
    });

    it('should handle high pollution values', async () => {
      const highPollutionResponse = {
        current: {
          pm2_5: 150.7,
          pm10: 300.2,
          us_aqi: 250,
        },
      };

      mockFetch.mockResolvedValue({
        ok: true,
        json: async () => highPollutionResponse,
      });

      const result = await fetchAirQualityData(validParams);
      
      expect(result.aqi).toBe(250);
      expect(result.pm25).toBe(150.7);
      expect(result.pm10).toBe(300.2);
    });
  });
});