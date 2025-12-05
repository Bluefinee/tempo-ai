/**
 * @fileoverview Test Route API Tests
 *
 * このファイルは、開発・テスト用APIエンドポイント（/api/test/*）のテストを担当します。
 * 外部API接続の検証、天気データ取得機能のテスト、および開発環境での
 * 動作確認用エンドポイントの動作を検証します。
 *
 * テスト対象:
 * - POST /api/test/weather - 天気データ取得テストエンドポイント
 * - 天気サービスの統合テスト
 * - エラーハンドリングの検証
 * - リクエスト/レスポンス形式の検証
 * - モックデータを使用したサービステスト
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { testRoutes } from '@/routes/test'
import { getWeather } from '@/services/weather'
import type { WeatherData } from '@/types/weather'
import { handleError } from '@/utils/errors'

// Response type definitions
interface WeatherDataResponse {
  data: WeatherData
  status: 'success'
}

interface MockAnalysisResponse {
  success: boolean
  message: string
  advice: {
    theme: string
    summary: string
    breakfast: {
      recommendation: string
      reason: string
      examples: string[]
    }
    lunch: {
      recommendation: string
      reason: string
      timing: string
      examples: string[]
      avoid: string[]
    }
    dinner: {
      recommendation: string
      reason: string
      timing: string
      examples: string[]
      avoid: string[]
    }
    hydration: {
      target: string
      reason: string
    }
    sleep_preparation: {
      bedtime: string
      routine: string[]
      avoid: string[]
    }
    weather_considerations: {
      warnings: string[]
      opportunities: string[]
    }
    priority_actions: string[]
  }
  weather_summary?: {
    temperature: number
    humidity: number
    uv_index: number
  }
}

interface ErrorResponse {
  error: string
  details?: unknown
}

type TestResponse = WeatherDataResponse | MockAnalysisResponse | ErrorResponse

// Type guards removed - using direct type assertions instead

// Mock dependencies
vi.mock('@/services/weather')
vi.mock('@/utils/errors')

const mockGetWeather = vi.mocked(getWeather)
const mockHandleError = vi.mocked(handleError)

// Test data
const mockWeatherData = {
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

describe('Test Routes', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockGetWeather.mockResolvedValue(mockWeatherData)
    mockHandleError.mockReturnValue({ message: 'Test error', statusCode: 500 })
  })

  describe('POST /weather', () => {
    it('should successfully test weather API with valid coordinates', async () => {
      const requestBody = {
        latitude: 35.6895,
        longitude: 139.6917,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      const result = (await response.json()) as TestResponse

      expect(result).toEqual({
        success: true,
        weather: mockWeatherData,
        message: 'Weather API integration working correctly',
      })

      expect(mockGetWeather).toHaveBeenCalledWith(35.6895, 139.6917)
    })

    it('should return 400 when latitude is missing', async () => {
      const requestBody = {
        longitude: 139.6917,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Invalid latitude/longitude')
    })

    it('should return 400 when longitude is missing', async () => {
      const requestBody = {
        latitude: 35.6895,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Invalid latitude/longitude')
    })

    it('should return 400 when latitude is not a number', async () => {
      const requestBody = {
        latitude: 'invalid',
        longitude: 139.6917,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Invalid latitude/longitude')
    })

    it('should return 400 when longitude is not a number', async () => {
      const requestBody = {
        latitude: 35.6895,
        longitude: 'invalid',
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Invalid latitude/longitude')
    })

    it('should handle extreme valid coordinates', async () => {
      const requestBody = {
        latitude: -90.0,
        longitude: 180.0,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      expect(mockGetWeather).toHaveBeenCalledWith(-90.0, 180.0)
    })

    it('should handle zero coordinates', async () => {
      const requestBody = {
        latitude: 0,
        longitude: 0,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      expect(mockGetWeather).toHaveBeenCalledWith(0, 0)
    })

    it('should handle weather service errors', async () => {
      mockGetWeather.mockRejectedValueOnce(new Error('Weather API failed'))
      mockHandleError.mockReturnValueOnce({
        message: 'Weather API failed',
        statusCode: 503,
      })

      const requestBody = {
        latitude: 35.6895,
        longitude: 139.6917,
      }

      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(503)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Weather API failed')
    })

    it('should handle invalid JSON in request body', async () => {
      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: 'invalid json',
      })

      expect(response.status).toBe(400) // Invalid JSON should return 400 Bad Request
    })

    it('should handle empty request body', async () => {
      const response = await testRoutes.request('/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Invalid latitude/longitude')
    })
  })

  describe('POST /analyze-mock', () => {
    it('should successfully return mock analysis with real weather data', async () => {
      const requestBody = {
        location: {
          latitude: 35.6895,
          longitude: 139.6917,
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      const result = (await response.json()) as MockAnalysisResponse

      expect(result.success).toBe(true)
      expect(result.message).toBe(
        'Mock analysis complete with real weather data',
      )

      // Verify mock advice structure
      expect(result.advice).toMatchObject({
        theme: 'Test Day',
        summary:
          'This is a test response. Weather data was successfully retrieved and integrated.',
        breakfast: {
          recommendation: 'Test breakfast recommendation',
          reason: 'This is a test reason',
          examples: ['Test meal 1', 'Test meal 2'],
        },
        lunch: {
          recommendation: 'Test lunch recommendation',
          reason: 'Test reason',
          timing: '12:30 PM',
          examples: ['Test meal 1'],
          avoid: ['Test avoid'],
        },
        dinner: {
          recommendation: 'Test dinner recommendation',
          reason: 'Test reason',
          timing: '6:30 PM',
          examples: ['Test meal 1'],
          avoid: ['Test avoid'],
        },
        exercise: {
          recommendation: 'Test exercise',
          intensity: 'Moderate',
          reason: 'Test reason',
          timing: 'Morning',
          avoid: ['Test avoid exercise'],
        },
        hydration: {
          target: '2.5L',
          schedule: {
            morning: '800ml',
            afternoon: '800ml',
            evening: '600ml',
          },
          reason: 'Test hydration reason',
        },
        breathing: {
          technique: 'Test breathing technique',
          duration: '5 minutes',
          frequency: '3 times',
          instructions: ['Step 1', 'Step 2', 'Step 3'],
        },
        sleep_preparation: {
          bedtime: '10:30 PM',
          routine: ['Activity 1', 'Activity 2'],
          avoid: ['Avoid 1', 'Avoid 2'],
        },
        weather_considerations: {
          warnings: [
            `Temperature: ${mockWeatherData.current.temperature_2m}°C`,
          ],
          opportunities: ['Good weather for outdoor activities'],
        },
        priority_actions: [
          'Test priority 1',
          'Test priority 2',
          'Test priority 3',
        ],
      })

      // Verify weather summary
      expect(result.weather_summary).toEqual({
        temperature: mockWeatherData.current.temperature_2m,
        humidity: mockWeatherData.current.relative_humidity_2m,
        uv_index: mockWeatherData.daily.uv_index_max[0],
      })

      expect(mockGetWeather).toHaveBeenCalledWith(35.6895, 139.6917)
    })

    it('should handle different coordinate values in mock analysis', async () => {
      const requestBody = {
        location: {
          latitude: 40.7128,
          longitude: -74.006,
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      expect(mockGetWeather).toHaveBeenCalledWith(40.7128, -74.006)
    })

    it('should integrate weather data into mock response correctly', async () => {
      const customWeatherData = {
        ...mockWeatherData,
        current: {
          ...mockWeatherData.current,
          temperature_2m: 15.5,
          relative_humidity_2m: 80,
        },
        daily: {
          ...mockWeatherData.daily,
          uv_index_max: [4.2],
        },
      }

      mockGetWeather.mockResolvedValueOnce(customWeatherData)

      const requestBody = {
        location: {
          latitude: 35.6895,
          longitude: 139.6917,
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      const result = (await response.json()) as MockAnalysisResponse

      expect(result.weather_summary).toEqual({
        temperature: 15.5,
        humidity: 80,
        uv_index: 4.2,
      })

      expect(result.advice.weather_considerations.warnings[0]).toContain(
        '15.5°C',
      )
    })

    it('should handle weather service errors in mock analysis', async () => {
      mockGetWeather.mockRejectedValueOnce(
        new Error('Weather service unavailable'),
      )
      mockHandleError.mockReturnValueOnce({
        message: 'Weather service unavailable',
        statusCode: 503,
      })

      const requestBody = {
        location: {
          latitude: 35.6895,
          longitude: 139.6917,
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(503)
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe('Weather service unavailable')
    })

    it('should handle missing location in request body', async () => {
      const requestBody = {}

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400) // Now properly validated and returns 400
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe(
        'Invalid location: coordinates must be valid numbers within range (lat: -90 to 90, lng: -180 to 180)',
      )
    })

    it('should handle invalid location structure', async () => {
      const requestBody = {
        location: {
          lat: 35.6895, // Wrong property name
          lng: 139.6917, // Wrong property name
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(400) // Now properly validated and returns 400
      const result = (await response.json()) as ErrorResponse
      expect(result.error).toBe(
        'Invalid location: coordinates must be valid numbers within range (lat: -90 to 90, lng: -180 to 180)',
      )
    })

    it('should validate that all mock advice fields are present', async () => {
      const requestBody = {
        location: {
          latitude: 35.6895,
          longitude: 139.6917,
        },
      }

      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      expect(response.status).toBe(200)
      const result = (await response.json()) as MockAnalysisResponse

      // Verify all required fields are present
      const requiredFields = [
        'theme',
        'summary',
        'breakfast',
        'lunch',
        'dinner',
        'exercise',
        'hydration',
        'breathing',
        'sleep_preparation',
        'weather_considerations',
        'priority_actions',
      ]

      requiredFields.forEach((field) => {
        expect(result.advice).toHaveProperty(field)
        expect((result.advice as Record<string, unknown>)[field]).toBeDefined()
      })
    })

    it('should handle invalid JSON in analyze-mock request', async () => {
      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: 'invalid json',
      })

      expect(response.status).toBe(400) // Invalid JSON should return 400 Bad Request
    })
  })

  describe('Error Handling', () => {
    it('should handle different types of errors consistently', async () => {
      const testCases = [
        {
          error: new Error('Generic error'),
          expectedMessage: 'Generic error',
          expectedStatus: 500,
        },
        {
          error: new TypeError('Type error'),
          expectedMessage: 'Type error',
          expectedStatus: 400,
        },
      ]

      for (const { error, expectedMessage, expectedStatus } of testCases) {
        mockGetWeather.mockRejectedValueOnce(error)
        mockHandleError.mockReturnValueOnce({
          message: expectedMessage,
          statusCode: expectedStatus,
        })

        const response = await testRoutes.request('/weather', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ latitude: 35.6895, longitude: 139.6917 }),
        })

        expect(response.status).toBe(expectedStatus)
        const result = (await response.json()) as ErrorResponse
        expect(result.error).toBe(expectedMessage)
      }
    })
  })

  describe('Content-Type Handling', () => {
    it('should handle requests without content-type header', async () => {
      const response = await testRoutes.request('/weather', {
        method: 'POST',
        body: JSON.stringify({ latitude: 35.6895, longitude: 139.6917 }),
      })

      // Without Content-Type header, should return 415 Unsupported Media Type
      // as the server expects application/json but receives no content type
      expect(response.status).toBe(415)
    })

    it('should handle analyze-mock without content-type header', async () => {
      const response = await testRoutes.request('/analyze-mock', {
        method: 'POST',
        body: JSON.stringify({
          location: { latitude: 35.6895, longitude: 139.6917 },
        }),
      })

      // Without Content-Type header, should return 415 Unsupported Media Type
      // as the server expects application/json but receives no content type
      expect(response.status).toBe(415)
    })
  })
})
