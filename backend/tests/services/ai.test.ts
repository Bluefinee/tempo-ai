/**
 * @fileoverview AI Service Unit Tests
 *
 * このファイルは、Claude AI分析サービス（@/services/ai）のユニットテストを担当します。
 * ヘルスデータ、天気データ、ユーザープロファイルを基にした健康アドバイス生成機能、
 * Anthropic API との連携、およびエラーハンドリングを検証します。
 *
 * テスト対象:
 * - analyzeHealth関数 - AIによるヘルス分析
 * - Anthropic Claude API統合
 * - APIキー検証とエラーハンドリング
 * - プロンプト生成とAIレスポンス処理
 * - カスタムfetch関数の統合
 * - レスポンス形式の検証
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { analyzeHealth } from '@/services/ai'
import type { HealthData, UserProfile } from '@/types/health'
import type { WeatherData } from '@/types/weather'
import { APIError } from '@/utils/errors'

// No module mocking needed - we'll use custom fetch

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
  exerciseFrequency: '3回/週',
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
    intensity: 'Moderate',
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

describe('AI Service', () => {
  beforeEach(async () => {
    vi.clearAllMocks()
  })

  // Removed costly test logic - not currently used

  describe('analyzeHealth', () => {
    it('should throw APIError when API key is missing', async () => {
      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: '',
        }),
      ).rejects.toThrow(APIError)
    })

    it('should throw APIError when API key is placeholder', async () => {
      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        }),
      ).rejects.toThrow('Claude API key not configured')
    })

    it('should successfully analyze health data with valid inputs', async () => {
      const mockFetch = vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        statusText: 'OK',
        headers: new Headers({
          'content-type': 'application/json',
        }),
        json: async () => ({
          id: 'msg_test',
          type: 'message',
          role: 'assistant',
          content: [
            {
              type: 'text',
              text: JSON.stringify(mockValidAdvice),
            },
          ],
          model: 'claude-3-5-sonnet-20241022',
          stop_reason: 'end_turn',
          usage: { input_tokens: 10, output_tokens: 20 },
        }),
      } as Response)

      const result = await analyzeHealth({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
        apiKey: 'sk-ant-api03-valid-key-12345',
        customFetch: mockFetch as typeof fetch,
      })

      expect(result).toEqual(mockValidAdvice)
      expect(mockFetch).toHaveBeenCalledTimes(1)
      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.anthropic.com/v1/messages',
        expect.objectContaining({
          method: 'POST',
          body: expect.any(String),
        }),
      )
    })

    it('should handle invalid JSON response from Claude', async () => {
      const mockFetch = vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        statusText: 'OK',
        headers: new Headers({
          'content-type': 'application/json',
        }),
        json: async () => ({
          id: 'msg_test',
          type: 'message',
          role: 'assistant',
          content: [
            {
              type: 'text',
              text: 'Invalid JSON response',
            },
          ],
          model: 'claude-3-5-sonnet-20241022',
          stop_reason: 'end_turn',
          usage: { input_tokens: 10, output_tokens: 20 },
        }),
      } as Response)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-valid-key-12345',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('AI response is not valid JSON')
    })

    it('should handle missing text content in response', async () => {
      const mockFetch = vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        statusText: 'OK',
        headers: new Headers({
          'content-type': 'application/json',
        }),
        json: async () => ({
          id: 'msg_test',
          type: 'message',
          role: 'assistant',
          content: [
            {
              type: 'image',
              source: { data: 'base64data' },
            },
          ],
          model: 'claude-3-5-sonnet-20241022',
          stop_reason: 'end_turn',
          usage: { input_tokens: 10, output_tokens: 20 },
        }),
      } as Response)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-valid-key-12345',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('Invalid response format from Claude API')
    })

    it('should handle incomplete AI response', async () => {
      const incompleteAdvice = {
        theme: 'バランス調整の日',
        summary: 'HRVが標準的で...',
        // Missing required fields: breakfast, exercise
      }

      const mockFetch = vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        statusText: 'OK',
        headers: new Headers({
          'content-type': 'application/json',
        }),
        json: async () => ({
          id: 'msg_test',
          type: 'message',
          role: 'assistant',
          content: [
            {
              type: 'text',
              text: JSON.stringify(incompleteAdvice),
            },
          ],
          model: 'claude-3-5-sonnet-20241022',
          stop_reason: 'end_turn',
          usage: { input_tokens: 10, output_tokens: 20 },
        }),
      } as Response)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-valid-key-12345',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('AI response missing required fields')
    })

    it('should handle authentication errors', async () => {
      const authError = new Error('authentication failed')
      const mockFetch = vi.fn().mockRejectedValue(authError)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-invalid-key',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('AI analysis failed: Connection error')
    })

    it('should handle rate limit errors', async () => {
      const rateLimitError = new Error('rate limit exceeded')
      const mockFetch = vi.fn().mockRejectedValue(rateLimitError)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-valid-key-12345',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('AI analysis failed: Connection error')
    })

    it('should handle unknown errors', async () => {
      const unknownError = 'unknown error'
      const mockFetch = vi.fn().mockRejectedValue(unknownError)

      await expect(
        analyzeHealth({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: mockUserProfile,
          apiKey: 'sk-ant-api03-valid-key-12345',
          customFetch: mockFetch as typeof fetch,
        }),
      ).rejects.toThrow('AI analysis failed: Connection error')
    })
  })
})
