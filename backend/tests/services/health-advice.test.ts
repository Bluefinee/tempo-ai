/**
 * @fileoverview Health Advice Domain Service Unit Tests
 *
 * このファイルは、ヘルスアドバイスドメインサービス（@/services/health-advice）のユニットテストを担当します。
 * ヘルスケアドメインロジック、プロンプト生成、バリデーション、
 * およびClaude API統合の調整機能を検証します。
 *
 * テスト対象:
 * - generateHealthAdvice関数 - ヘルスアドバイス生成
 * - ドメイン固有のバリデーション
 * - プロンプト生成統合
 * - Claude API統合サービスとの連携
 * - エラーハンドリングとラッピング
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { generateHealthAdvice } from '@/services/health-advice'
import type { HealthData, UserProfile } from '@/types/health'
import type { WeatherData } from '@/types/weather'
import { APIError } from '@/utils/errors'

// Mock dependencies
vi.mock('@/services/claude')
vi.mock('@/utils/prompts')

import { callClaude } from '@/services/claude'
import { buildPrompt } from '@/utils/prompts'

const mockCallClaude = vi.mocked(callClaude)
const mockBuildPrompt = vi.mocked(buildPrompt)

const mockHealthData: HealthData = {
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
}

const mockUserProfile: UserProfile = {
  age: 30,
  gender: 'male',
  goals: ['疲労回復', '集中力向上'],
  dietaryPreferences: 'バランス重視',
  exerciseHabits: '週3回ジム',
  exerciseFrequency: 'weekly',
}

const mockWeatherData: WeatherData = {
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

const mockValidAdvice = {
  theme: 'バランス調整の日',
  summary:
    'HRVが標準的で、睡眠の質も良好です。今日は適度な運動と栄養バランスに注意を向けましょう。',
  breakfast: {
    recommendation: 'タンパク質豊富な朝食を',
    reason: '良好な睡眠を活かして筋肉合成を促進',
    examples: ['ゆで卵とアボカド', 'ギリシャヨーグルト', 'オートミール'],
  },
  exercise: {
    recommendation: '中強度の有酸素運動30分',
    intensity: 'Moderate' as const,
    reason: 'HRVが安定しており回復状態が良好',
    timing: '午前10時頃',
    avoid: ['高強度インターバル'],
  },
  lunch: {
    recommendation: '野菜中心のバランス食',
    reason: '午後のエネルギー維持',
    timing: '12:30 PM',
    examples: ['サラダボウル', '野菜炒め'],
    avoid: ['重い揚げ物'],
  },
  dinner: {
    recommendation: '軽めの消化しやすい食事',
    reason: '睡眠の質を保つため',
    timing: '6:30 PM',
    examples: ['魚料理', '蒸し野菜'],
    avoid: ['遅い時間の食事'],
  },
  hydration: {
    target: '2.5',
    schedule: {
      morning: '500',
      afternoon: '1000',
      evening: '1000',
    },
    reason: '適度な湿度と活動量に対応',
  },
  breathing: {
    technique: '4-7-8 breathing',
    duration: '5分',
    frequency: '2回',
    instructions: [
      '4秒で息を吸う',
      '7秒間息を止める',
      '8秒で息を吐く',
      '3-4サイクル繰り返す',
    ],
  },
  sleep_preparation: {
    bedtime: '22:30',
    routine: ['21:30 お風呂', '22:00 読書', '22:30 就寝'],
    avoid: ['スマホの使用', 'カフェイン'],
  },
  weather_considerations: {
    warnings: ['UV指数が高めなので日焼け止めを'],
    opportunities: ['散歩に最適な気温'],
  },
  priority_actions: [
    'バランスの良い朝食を摂る',
    '中強度運動を30分行う',
    '水分摂取を意識する',
  ],
}

describe('Health Advice Service', () => {
  beforeEach(async () => {
    vi.clearAllMocks()

    // Default successful mocks
    mockBuildPrompt.mockReturnValue('Generated health analysis prompt')
    mockCallClaude.mockResolvedValue(mockValidAdvice)
  })

  describe('generateHealthAdvice', () => {
    it('should successfully generate health advice with valid inputs', async () => {
      const result = await generateHealthAdvice({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
        apiKey: 'valid-api-key',
      })

      expect(mockBuildPrompt).toHaveBeenCalledWith({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })
      expect(mockCallClaude).toHaveBeenCalledWith({
        prompt: 'Generated health analysis prompt',
        apiKey: 'valid-api-key',
        customFetch: undefined,
      })
      expect(result).toEqual(mockValidAdvice)
    })

    it('should pass customFetch to Claude service', async () => {
      const mockFetch = vi.fn() as typeof fetch

      await generateHealthAdvice({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
        apiKey: 'valid-api-key',
        customFetch: mockFetch,
      })

      expect(mockCallClaude).toHaveBeenCalledWith({
        prompt: 'Generated health analysis prompt',
        apiKey: 'valid-api-key',
        customFetch: mockFetch,
      })
    })

    describe('input validation', () => {
      it('should throw APIError when healthData is missing', async () => {
        await expect(
          generateHealthAdvice({
            healthData: null as unknown as HealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'MISSING_HEALTH_DATA',
        })
      })

      it('should throw APIError when weather is missing', async () => {
        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: null as unknown as WeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'MISSING_WEATHER_DATA',
        })
      })

      it('should throw APIError when userProfile is missing', async () => {
        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: null as unknown as UserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'MISSING_USER_PROFILE',
        })
      })

      it('should throw APIError when apiKey is missing', async () => {
        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: '',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'MISSING_API_KEY',
        })
      })

      it('should throw APIError when apiKey is whitespace only', async () => {
        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: '   ',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'MISSING_API_KEY',
        })
      })
    })

    describe('error handling', () => {
      it('should propagate APIError from buildPrompt', async () => {
        const promptError = new APIError(
          'Invalid health data format',
          400,
          'INVALID_HEALTH_DATA',
        )
        mockBuildPrompt.mockImplementation(() => {
          throw promptError
        })

        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toThrow(promptError)
      })

      it('should propagate APIError from callClaude', async () => {
        const claudeError = new APIError(
          'Claude API error',
          502,
          'CLAUDE_API_ERROR',
        )
        mockCallClaude.mockRejectedValueOnce(claudeError)

        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toThrow(claudeError)
      })

      it('should wrap unknown errors in APIError', async () => {
        const unknownError = new Error('Unknown error')
        mockBuildPrompt.mockImplementation(() => {
          throw unknownError
        })

        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 500,
          code: 'HEALTH_ADVICE_GENERATION_ERROR',
        })
      })

      it('should wrap string errors in APIError', async () => {
        mockCallClaude.mockRejectedValueOnce('String error')

        await expect(
          generateHealthAdvice({
            healthData: mockHealthData,
            weather: mockWeatherData,
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 500,
          code: 'HEALTH_ADVICE_GENERATION_ERROR',
        })
      })
    })
  })
})
