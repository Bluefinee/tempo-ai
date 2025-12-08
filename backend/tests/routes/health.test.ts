/**
 * @fileoverview Health Route API Tests
 *
 * このファイルは、ヘルス分析APIエンドポイント（/api/health/*）のテストを担当します。
 * ヘルスデータの分析リクエスト処理、天気データとの統合、AIサービスとの連携、
 * およびエラーハンドリングを検証します。
 *
 * テスト対象:
 * - POST /api/health/analyze - ヘルスデータ分析エンドポイント
 * - GET /api/health/status - ヘルスサービス状態確認
 * - リクエストバリデーション（必須フィールド検証）
 * - AIサービス統合とエラーハンドリング
 * - 天気データサービス統合
 * - レスポンス形式の検証
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { healthRoutes } from '@/routes/health'

// Mock services
vi.mock('@/services/health-advice')
vi.mock('@/services/weather')
vi.mock('@/utils/errors')

import { generateHealthAdvice } from '@/services/health-advice'
import { getWeather } from '@/services/weather'
import type { DailyAdvice } from '@/types/advice'
import { handleError } from '@/utils/errors'

// Response type definitions
interface SuccessResponse {
  success: true
  data: DailyAdvice
}

interface ErrorResponse {
  success: false
  error: string
}

interface StatusResponse {
  success: true
  data: {
    status: string
    service: string
    timestamp: string
  }
}

const mockGenerateHealthAdvice = vi.mocked(generateHealthAdvice)
const mockGetWeather = vi.mocked(getWeather)
const mockHandleError = vi.mocked(handleError)

// Test data
const validRequestBody = {
  healthData: {
    sleep: {
      duration: 7.5,
      deep: 1.2,
      rem: 1.8,
      light: 4.5,
      awake: 0,
      efficiency: 88,
    },
    hrv: {
      average: 45.2,
      min: 38.1,
      max: 52.7,
    },
    heartRate: {
      resting: 58,
      average: 72,
      min: 55,
      max: 85,
    },
    activity: {
      steps: 8234,
      distance: 6.2,
      calories: 420,
      activeMinutes: 35,
    },
  },
  location: {
    latitude: 35.6895,
    longitude: 139.6917,
  },
  userProfile: {
    age: 30,
    gender: 'male',
    goals: ['疲労回復', '集中力向上'],
    dietaryPreferences: 'バランス重視',
    exerciseHabits: '週3回ジム',
    exerciseFrequency: 'weekly',
  },
}

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

const mockAdviceResult = {
  theme: 'バランス調整の日',
  summary: 'HRVが標準的で、睡眠の質も良好です。',
  breakfast: {
    recommendation: 'タンパク質豊富な朝食を',
    reason: '良好な睡眠を活かして筋肉合成を促進',
    examples: ['ゆで卵とアボカド', 'ギリシャヨーグルト'],
  },
  lunch: {
    recommendation: 'バランスの良い昼食',
    reason: 'エネルギー補給',
    examples: ['和定食', 'サラダボウル'],
  },
  dinner: {
    recommendation: '軽めの夕食',
    reason: '睡眠への影響を考慮',
    examples: ['焼き魚', 'スープ'],
  },
  exercise: {
    recommendation: '中強度の有酸素運動30分',
    intensity: 'Moderate' as const,
    reason: 'HRVが安定しており回復状態が良好',
    timing: '午前10時頃',
    avoid: ['高強度インターバル'],
  },
  hydration: {
    target: '2L',
    schedule: {
      morning: '500ml',
      afternoon: '800ml',
      evening: '700ml',
    },
    reason: '代謝促進のため',
  },
  breathing: {
    technique: '4-7-8呼吸法',
    duration: '10分',
    frequency: '朝晩2回',
    instructions: ['4秒で吸う', '7秒止める', '8秒で吐く'],
  },
  sleep_preparation: {
    bedtime: '22:30',
    routine: ['入浴', '読書', 'ストレッチ'],
    avoid: ['スマホ', 'カフェイン'],
  },
  weather_considerations: {
    warnings: ['強風注意'],
    opportunities: ['散歩日和'],
  },
  priority_actions: ['水分補給', '軽い運動', '早めの就寝'],
}

describe('Health Routes', () => {
  beforeEach(() => {
    vi.clearAllMocks()

    // Default successful mocks
    mockGetWeather.mockResolvedValue(mockWeatherData)
    mockGenerateHealthAdvice.mockResolvedValue(mockAdviceResult)
    mockHandleError.mockReturnValue({ message: 'Test error', statusCode: 500 })
  })

  describe('POST /analyze', () => {
    it('should successfully analyze health data with valid request', async () => {
      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(validRequestBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(200)
      const result = (await response.json()) as SuccessResponse
      expect(result.success).toBe(true)
      expect(result.data).toEqual(mockAdviceResult)
    })

    it('should return 400 for invalid JSON in request body', async () => {
      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: 'invalid json',
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toBe('Invalid JSON in request body')
    })

    it('should return 400 when healthData is missing', async () => {
      const invalidBody = {
        ...validRequestBody,
        healthData: undefined,
      }

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(invalidBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toContain('Validation failed:')
    })

    it('should return 400 when location is missing', async () => {
      const invalidBody = {
        ...validRequestBody,
        location: undefined,
      }

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(invalidBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toContain('Validation failed:')
    })

    it('should return 400 when userProfile is missing', async () => {
      const invalidBody = {
        ...validRequestBody,
        userProfile: undefined,
      }

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(invalidBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toContain('Validation failed:')
    })

    it('should return 400 for invalid latitude type', async () => {
      const invalidBody = {
        ...validRequestBody,
        location: {
          latitude: 'invalid',
          longitude: 139.6917,
        },
      }

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(invalidBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toContain('Validation failed:')
    })

    it('should return 400 for invalid longitude type', async () => {
      const invalidBody = {
        ...validRequestBody,
        location: {
          latitude: 35.6895,
          longitude: 'invalid',
        },
      }

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(invalidBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(400)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toContain('Validation failed:')
    })

    it('should return 500 when GEMINI_API_KEY is missing', async () => {
      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(validRequestBody),
        },
        {
          // No GEMINI_API_KEY in env
        },
      )

      expect(response.status).toBe(500)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toBe('API configuration error')
    })

    it('should handle weather service errors', async () => {
      mockGetWeather.mockRejectedValueOnce(new Error('Weather API failed'))

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(validRequestBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(response.status).toBe(500)
    })

    it('should handle health advice generation errors', async () => {
      const testError = new Error('Health advice generation failed')
      mockGenerateHealthAdvice.mockRejectedValueOnce(testError)

      // Mock handleError to verify it's called with the correct error
      mockHandleError.mockReturnValueOnce({
        message: 'Health advice generation failed',
        statusCode: 500,
      })

      const app = healthRoutes
      const response = await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(validRequestBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      // Verify status code and response format
      expect(response.status).toBe(500)
      const result = (await response.json()) as ErrorResponse
      expect(result.success).toBe(false)
      expect(result.error).toBe('Health advice generation failed')

      // Verify handleError was called with the original error
      expect(mockHandleError).toHaveBeenCalledWith(testError)
    })

    it('should call services with correct parameters', async () => {
      const app = healthRoutes
      await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(validRequestBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      // Verify weather service called with correct coordinates
      expect(mockGetWeather).toHaveBeenCalledWith(35.6895, 139.6917)

      // Verify health advice service called with correct parameters
      expect(mockGenerateHealthAdvice).toHaveBeenCalledWith({
        healthData: validRequestBody.healthData,
        weather: mockWeatherData,
        userProfile: validRequestBody.userProfile,
        apiKey: 'test-api-key',
      })
    })

    it('should handle edge case coordinates', async () => {
      const edgeCaseBody = {
        ...validRequestBody,
        location: {
          latitude: 0,
          longitude: 0,
        },
      }

      const app = healthRoutes
      await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(edgeCaseBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(mockGetWeather).toHaveBeenCalledWith(0, 0)
    })

    it('should handle extreme coordinates', async () => {
      const extremeBody = {
        ...validRequestBody,
        location: {
          latitude: -90,
          longitude: 180,
        },
      }

      const app = healthRoutes
      await app.request(
        '/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(extremeBody),
        },
        {
          GEMINI_API_KEY: 'test-api-key',
        },
      )

      expect(mockGetWeather).toHaveBeenCalledWith(-90, 180)
    })
  })

  describe('GET /status', () => {
    it('should return health status', async () => {
      const app = healthRoutes
      const response = await app.request('/status')

      expect(response.status).toBe(200)
      const result = (await response.json()) as StatusResponse
      expect(result.success).toBe(true)
      expect(result.data.status).toBe('healthy')
      expect(result.data.service).toBe('Tempo AI Health Analysis')
      expect(result.data.timestamp).toBeDefined()
    })

    it('should return valid timestamp format', async () => {
      const app = healthRoutes
      const response = await app.request('/status')
      const result = (await response.json()) as StatusResponse

      // Check if timestamp is a valid ISO string
      expect(() => new Date(result.data.timestamp)).not.toThrow()
      expect(new Date(result.data.timestamp).toISOString()).toBe(
        result.data.timestamp,
      )
    })
  })
})
