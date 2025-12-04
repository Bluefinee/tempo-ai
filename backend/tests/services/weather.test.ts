/**
 * @fileoverview Weather Service Unit Tests
 *
 * このファイルは、天気データ取得サービス（@/services/weather）のユニットテストを担当します。
 * Open-Meteo API との連携、位置情報を基にした天気データの取得、
 * およびエラーハンドリングを検証します。
 *
 * テスト対象:
 * - getWeather関数 - 位置情報による天気データ取得
 * - Open-Meteo API統合
 * - レスポンス形式の変換と検証
 * - ネットワークエラーハンドリング
 * - APIエラーレスポンス処理
 * - 位置情報パラメータの検証
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { getWeather } from '@/services/weather'
import { APIError } from '@/utils/errors'

// Mock fetch globally
const mockFetch = vi.fn()
global.fetch = mockFetch as typeof fetch

const mockWeatherResponse = {
  current: {
    time: '2024-01-01T12:00',
    temperature_2m: 22.5,
    apparent_temperature: 24.1,
    relative_humidity_2m: 65,
    precipitation: 0,
    rain: 0,
    weather_code: 1,
    cloud_cover: 25,
    wind_speed_10m: 8.2,
  },
  daily: {
    time: ['2024-01-01'],
    temperature_2m_max: [26.3],
    temperature_2m_min: [18.7],
    sunrise: ['06:30'],
    sunset: ['18:45'],
    uv_index_max: [6.8],
    precipitation_sum: [0],
  },
}

describe('Weather Service', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('getWeather', () => {
    it('should successfully fetch weather data with valid coordinates', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      const result = await getWeather(35.6895, 139.6917)

      expect(result).toEqual(mockWeatherResponse)
      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=35.6895&longitude=139.6917'),
      )
      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('api.open-meteo.com'),
      )
    })

    it('should include all required weather parameters in URL', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      await getWeather(35.6895, 139.6917)

      const calledUrl = mockFetch.mock.calls[0]?.[0]

      // Current weather parameters
      expect(calledUrl).toContain(
        'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,cloud_cover,wind_speed_10m',
      )

      // Daily parameters
      expect(calledUrl).toContain(
        'daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum',
      )

      // Timezone
      expect(calledUrl).toContain('timezone=auto')
    })

    it('should handle positive coordinates correctly', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      await getWeather(40.7128, -74.006) // New York

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=40.7128&longitude=-74.006'),
      )
    })

    it('should handle negative coordinates correctly', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      await getWeather(-33.8688, 151.2093) // Sydney

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=-33.8688&longitude=151.2093'),
      )
    })

    it('should handle zero coordinates correctly', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      await getWeather(0, 0) // Null Island

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=0&longitude=0'),
      )
    })

    it('should throw APIError when weather API returns 4xx error', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
      })

      await expect(getWeather(35.6895, 139.6917)).rejects.toThrow(APIError)

      // Reset mock for second call
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
      })

      await expect(getWeather(35.6895, 139.6917)).rejects.toThrow(
        'Weather API failed with status 400',
      )
    })

    it('should throw APIError when weather API returns 5xx error', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 503,
      })

      await expect(getWeather(35.6895, 139.6917)).rejects.toThrow(APIError)

      // Reset mock for second call
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 503,
      })

      await expect(getWeather(35.6895, 139.6917)).rejects.toThrow(
        'Weather API failed with status 503',
      )
    })

    it('should throw APIError with correct error code for API failures', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      })

      try {
        await getWeather(35.6895, 139.6917)
      } catch (error) {
        expect(error).toBeInstanceOf(APIError)
        expect((error as APIError).code).toBe('WEATHER_API_ERROR')
        expect((error as APIError).statusCode).toBe(503)
      }
    })

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      const promise = getWeather(35.6895, 139.6917)
      await expect(promise).rejects.toThrow(APIError)
      await expect(promise).rejects.toThrow('Failed to fetch weather data')
    })

    it('should handle fetch throwing non-Error objects', async () => {
      mockFetch.mockRejectedValueOnce('string error')

      const promise = getWeather(35.6895, 139.6917)
      await expect(promise).rejects.toThrow(APIError)
      await expect(promise).rejects.toThrow('Failed to fetch weather data')
    })

    it('should throw APIError with correct error code for network failures', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      try {
        await getWeather(35.6895, 139.6917)
      } catch (error) {
        expect(error).toBeInstanceOf(APIError)
        expect((error as APIError).code).toBe('WEATHER_FETCH_ERROR')
        expect((error as APIError).statusCode).toBe(503)
      }
    })

    it('should handle JSON parsing errors from response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.reject(new Error('Invalid JSON')),
      })

      const promise = getWeather(35.6895, 139.6917)
      await expect(promise).rejects.toThrow(APIError)
      await expect(promise).rejects.toThrow('Failed to fetch weather data')
    })

    it('should preserve APIError when it is already thrown', async () => {
      const customAPIError = new APIError(
        'Custom API Error',
        400,
        'CUSTOM_ERROR',
      )
      mockFetch.mockRejectedValueOnce(customAPIError)

      try {
        await getWeather(35.6895, 139.6917)
      } catch (error) {
        expect(error).toBe(customAPIError)
        expect((error as APIError).message).toBe('Custom API Error')
        expect((error as APIError).code).toBe('CUSTOM_ERROR')
        expect((error as APIError).statusCode).toBe(400)
      }
    })

    it('should handle extreme coordinate values', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      // Test extreme but valid coordinates
      await getWeather(89.9999, 179.9999)

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=89.9999&longitude=179.9999'),
      )
    })

    it('should handle decimal precision in coordinates', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockWeatherResponse),
      })

      // Test high precision coordinates
      await getWeather(35.68949999, 139.69170001)

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('latitude=35.68949999&longitude=139.69170001'),
      )
    })
  })
})
