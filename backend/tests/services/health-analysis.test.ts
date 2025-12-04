/**
 * @fileoverview Health Analysis Service Tests
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import * as aiService from '../../src/services/ai'
import { performHealthAnalysis } from '../../src/services/health-analysis'
import * as weatherService from '../../src/services/weather'
import type { DailyAdvice } from '../../src/types/advice'
import type { HealthData, UserProfile } from '../../src/types/health'
import type { WeatherData } from '../../src/types/weather'
import { APIError } from '../../src/utils/errors'

// Mock dependencies
vi.mock('../../src/services/weather')
vi.mock('../../src/services/ai')

const mockGetWeather = vi.mocked(weatherService.getWeather)
const mockAnalyzeHealth = vi.mocked(aiService.analyzeHealth)

describe('Health Analysis Service', () => {
  const mockHealthData: HealthData = {
    sleep: {
      duration: 7.5,
      deep: 2.1,
      rem: 1.4,
      light: 3.8,
      awake: 0.2,
      efficiency: 0.87,
    },
    hrv: {
      average: 45,
      min: 30,
      max: 60,
    },
    heartRate: {
      resting: 65,
      average: 72,
      min: 58,
      max: 145,
    },
    activity: {
      steps: 8500,
      distance: 6.2,
      calories: 1800,
      activeMinutes: 85,
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
      time: '2024-12-04T12:00',
      temperature_2m: 22,
      relative_humidity_2m: 65,
      apparent_temperature: 20,
      precipitation: 0,
      rain: 0,
      weather_code: 0,
      cloud_cover: 20,
      wind_speed_10m: 5,
    },
    daily: {
      time: ['2024-12-04'],
      temperature_2m_max: [25],
      temperature_2m_min: [18],
      sunrise: ['06:30'],
      sunset: ['17:30'],
      uv_index_max: [6],
      precipitation_sum: [0],
    },
  }

  const mockAdvice: DailyAdvice = {
    theme: 'バランスデー',
    summary: 'テストアドバイス',
    breakfast: {
      recommendation: 'プロテインリッチな朝食',
      reason: '筋肉回復のため',
    },
    lunch: {
      recommendation: '栄養バランス重視',
      reason: 'エネルギー維持のため',
    },
    dinner: {
      recommendation: '軽めの食事',
      reason: '睡眠の質向上のため',
    },
    exercise: {
      recommendation: '軽い有酸素運動',
      intensity: 'Moderate' as const,
      reason: '心拍数向上のため',
      timing: '午後',
      avoid: ['激しい運動'],
    },
    hydration: {
      target: '2.5L',
      schedule: {
        morning: '500ml',
        afternoon: '1L',
        evening: '1L',
      },
      reason: '代謝向上のため',
    },
    breathing: {
      technique: '4-7-8呼吸法',
      duration: '5分',
      frequency: '3回/日',
      instructions: ['4秒で吸う', '7秒止める', '8秒で吐く'],
    },
    sleep_preparation: {
      bedtime: '23:00',
      routine: ['入浴', '読書'],
      avoid: ['スクリーン', 'カフェイン'],
    },
    weather_considerations: {
      warnings: ['紫外線注意'],
      opportunities: ['外での運動'],
    },
    priority_actions: ['水分補給', '軽い運動'],
  }

  beforeEach(() => {
    vi.resetAllMocks()
  })

  describe('performHealthAnalysis', () => {
    it('should successfully analyze health data with valid inputs', async () => {
      mockGetWeather.mockResolvedValueOnce(mockWeatherData)
      mockAnalyzeHealth.mockResolvedValueOnce(mockAdvice)

      const result = await performHealthAnalysis({
        healthData: mockHealthData,
        location: { latitude: 35.6895, longitude: 139.6917 },
        userProfile: mockUserProfile,
        apiKey: 'valid-api-key',
      })

      expect(mockGetWeather).toHaveBeenCalledWith(35.6895, 139.6917)
      expect(mockAnalyzeHealth).toHaveBeenCalledWith({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
        apiKey: 'valid-api-key',
      })
      expect(result).toEqual(mockAdvice)
    })

    describe('coordinate validation', () => {
      it('should throw error for latitude out of range', async () => {
        await expect(
          performHealthAnalysis({
            healthData: mockHealthData,
            location: { latitude: 91, longitude: 0 }, // Invalid latitude
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'INVALID_COORDINATES',
        })
      })

      it('should throw error for longitude out of range', async () => {
        await expect(
          performHealthAnalysis({
            healthData: mockHealthData,
            location: { latitude: 0, longitude: 181 }, // Invalid longitude
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'INVALID_COORDINATES',
        })
      })

      it('should throw error for non-number coordinates', async () => {
        await expect(
          performHealthAnalysis({
            healthData: mockHealthData,
            location: { latitude: NaN, longitude: 0 },
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).rejects.toMatchObject({
          statusCode: 400,
          code: 'INVALID_COORDINATES',
        })
      })

      it('should accept valid edge coordinates', async () => {
        mockGetWeather.mockResolvedValueOnce(mockWeatherData)
        mockAnalyzeHealth.mockResolvedValueOnce(mockAdvice)

        await expect(
          performHealthAnalysis({
            healthData: mockHealthData,
            location: { latitude: -90, longitude: 180 }, // Valid edge case
            userProfile: mockUserProfile,
            apiKey: 'valid-api-key',
          }),
        ).resolves.toEqual(mockAdvice)
      })
    })

    it('should propagate weather service errors', async () => {
      const weatherError = new APIError(
        'Weather service unavailable',
        503,
        'WEATHER_ERROR',
      )
      mockGetWeather.mockRejectedValueOnce(weatherError)

      await expect(
        performHealthAnalysis({
          healthData: mockHealthData,
          location: { latitude: 35.6895, longitude: 139.6917 },
          userProfile: mockUserProfile,
          apiKey: 'valid-api-key',
        }),
      ).rejects.toThrow(weatherError)
    })

    it('should propagate AI service errors', async () => {
      const aiError = new APIError('AI analysis failed', 502, 'AI_ERROR')
      mockGetWeather.mockResolvedValueOnce(mockWeatherData)
      mockAnalyzeHealth.mockRejectedValueOnce(aiError)

      await expect(
        performHealthAnalysis({
          healthData: mockHealthData,
          location: { latitude: 35.6895, longitude: 139.6917 },
          userProfile: mockUserProfile,
          apiKey: 'valid-api-key',
        }),
      ).rejects.toThrow(aiError)
    })
  })
})
