/**
 * @fileoverview AI Prompt Generation Utility Tests
 *
 * このファイルは、AIプロンプト生成ユーティリティ（@/utils/prompts）のユニットテストを担当します。
 * ヘルスデータ、天気データ、ユーザープロファイルを組み合わせた
 * Claude AI用プロンプトの生成と形式検証を行います。
 *
 * テスト対象:
 * - buildPrompt関数 - AI分析用プロンプト生成
 * - ヘルスデータの構造化
 * - 天気データの統合
 * - ユーザープロファイル情報の組み込み
 * - プロンプトテンプレートの検証
 * - 出力形式の一貫性確認
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { describe, expect, it } from 'vitest'
import type { HealthData, UserProfile } from '@/types/health'
import type { WeatherData } from '@/types/weather'
import { buildPrompt } from '@/utils/prompts'

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

describe('Prompt Utilities', () => {
  describe('buildPrompt', () => {
    it('should generate a complete prompt with all required sections', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      // Check main sections exist
      expect(prompt).toContain('USER PROFILE:')
      expect(prompt).toContain('HEALTH DATA (Last 24 hours):')
      expect(prompt).toContain('WEATHER CONDITIONS:')
      expect(prompt).toContain(
        'Based on this data, provide comprehensive health advice',
      )
    })

    it('should include user profile information', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      expect(prompt).toContain('Age: 30')
      expect(prompt).toContain('Gender: male')
      expect(prompt).toContain('Goals: 疲労回復, 集中力向上')
      expect(prompt).toContain('Dietary Preferences: バランス重視')
      expect(prompt).toContain('Exercise Habits: 週3回ジム')
      expect(prompt).toContain('Exercise Frequency: weekly')
    })

    it('should include health data metrics', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      // Sleep data
      expect(prompt).toContain('Sleep Duration: 7.5 hours')
      expect(prompt).toContain('Sleep Quality: Deep 1.2h, REM 1.8h, Light 4.5h')
      expect(prompt).toContain('Sleep Efficiency: 88%')

      // HRV data
      expect(prompt).toContain(
        'Heart Rate Variability (HRV): 45.2 ms (min: 38.1, max: 52.7)',
      )

      // Heart rate data
      expect(prompt).toContain('Resting Heart Rate: 58 bpm')
      expect(prompt).toContain('Average Heart Rate: 72 bpm')

      // Activity data
      expect(prompt).toContain('Steps: 8234')
      expect(prompt).toContain('Distance: 6.2 km')
      expect(prompt).toContain('Active Calories: 420 kcal')
      expect(prompt).toContain('Active Minutes: 35')
    })

    it('should include weather conditions', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      expect(prompt).toContain('Current Temperature: 22.5°C')
      expect(prompt).toContain('Feels Like: 24.1°C')
      expect(prompt).toContain('Humidity: 65%')
      expect(prompt).toContain('Max Temperature Today: 26.3°C')
      expect(prompt).toContain('Min Temperature Today: 18.7°C')
      expect(prompt).toContain('UV Index: 6.8')
      expect(prompt).toContain('Precipitation: 0mm')
      expect(prompt).toContain('Wind Speed: 8.2 km/h')
    })

    it('should include JSON structure specification', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      // Check for main JSON structure fields
      expect(prompt).toContain('"theme":')
      expect(prompt).toContain('"summary":')
      expect(prompt).toContain('"breakfast":')
      expect(prompt).toContain('"lunch":')
      expect(prompt).toContain('"dinner":')
      expect(prompt).toContain('"exercise":')
      expect(prompt).toContain('"hydration":')
      expect(prompt).toContain('"breathing":')
      expect(prompt).toContain('"sleep_preparation":')
      expect(prompt).toContain('"weather_considerations":')
      expect(prompt).toContain('"priority_actions":')
    })

    it('should include detailed field specifications', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      // Check nested field specifications
      expect(prompt).toContain('"recommendation":')
      expect(prompt).toContain('"reason":')
      expect(prompt).toContain('"examples":')
      expect(prompt).toContain('"intensity":')
      expect(prompt).toContain('"timing":')
      expect(prompt).toContain('"avoid":')
      expect(prompt).toContain('"schedule":')
      expect(prompt).toContain('"technique":')
      expect(prompt).toContain('"instructions":')
    })

    it('should include implementation guidelines', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      expect(prompt).toContain('Important guidelines:')
      expect(prompt).toContain(
        'All recommendations must be specific and actionable',
      )
      expect(prompt).toContain(
        'Consider the interaction between sleep quality, HRV, and activity levels',
      )
      expect(prompt).toContain('Adjust intensity based on recovery status')
      expect(prompt).toContain('Factor in weather for outdoor activities')
      expect(prompt).toContain('Provide exact times and quantities')
    })

    it('should handle missing optional user profile fields', () => {
      const minimalUserProfile: UserProfile = {
        age: 25,
        gender: 'female',
        goals: ['健康維持'],
        dietaryPreferences: 'never',
        exerciseHabits: 'never',
        exerciseFrequency: 'never',
      }

      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: minimalUserProfile,
      })

      expect(prompt).toContain('Age: 25')
      expect(prompt).toContain('Gender: female')
      expect(prompt).toContain('Goals: 健康維持')
      expect(prompt).toContain('Dietary Preferences: never')
      expect(prompt).toContain('Exercise Habits: never')
      expect(prompt).toContain('Exercise Frequency: never')
    })

    it('should handle empty goals array', () => {
      const userProfileWithEmptyGoals: UserProfile = {
        ...mockUserProfile,
        goals: [],
      }

      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: userProfileWithEmptyGoals,
      })

      expect(prompt).toContain('Goals: ')
    })

    it('should handle multiple goals correctly', () => {
      const userProfileWithManyGoals: UserProfile = {
        ...mockUserProfile,
        goals: ['疲労回復', '集中力向上', '体重管理', 'ストレス軽減'],
      }

      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: userProfileWithManyGoals,
      })

      expect(prompt).toContain(
        'Goals: 疲労回復, 集中力向上, 体重管理, ストレス軽減',
      )
    })

    it('should handle extreme weather conditions', () => {
      const extremeWeather: WeatherData = {
        current: {
          time: '2024-01-01T12:00',
          temperature_2m: -10.5,
          apparent_temperature: -15.2,
          relative_humidity_2m: 90,
          precipitation: 25.5,
          rain: 20.0,
          weather_code: 63,
          cloud_cover: 100,
          wind_speed_10m: 45.8,
        },
        daily: {
          time: ['2024-01-01'],
          temperature_2m_max: [-5.1],
          temperature_2m_min: [-18.3],
          sunrise: ['07:45'],
          sunset: ['16:30'],
          uv_index_max: [0.5],
          precipitation_sum: [30.2],
        },
      }

      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: extremeWeather,
        userProfile: mockUserProfile,
      })

      expect(prompt).toContain('Current Temperature: -10.5°C')
      expect(prompt).toContain('Feels Like: -15.2°C')
      expect(prompt).toContain('Precipitation: 25.5mm')
      expect(prompt).toContain('Wind Speed: 45.8 km/h')
    })

    it('should handle zero and decimal values correctly', () => {
      const precisionHealthData: HealthData = {
        sleep: {
          duration: 8.25,
          deep: 0.95,
          rem: 2.15,
          light: 5.15,
          awake: 0,
          efficiency: 92.5,
        },
        hrv: {
          average: 38.7,
          min: 29.3,
          max: 47.2,
        },
        heartRate: {
          resting: 52,
          average: 68,
          min: 48,
          max: 85,
        },
        activity: {
          steps: 12847,
          distance: 9.73,
          calories: 612,
          activeMinutes: 67,
        },
      }

      const prompt = buildPrompt({
        healthData: precisionHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      expect(prompt).toContain('Sleep Duration: 8.25 hours')
      expect(prompt).toContain('Sleep Efficiency: 92.5%')
      expect(prompt).toContain(
        'Heart Rate Variability (HRV): 38.7 ms (min: 29.3, max: 47.2)',
      )
      expect(prompt).toContain('Distance: 9.73 km')
    })

    it('should maintain consistent prompt structure', () => {
      const prompt1 = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      const prompt2 = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      // Both prompts should have identical structure
      expect(prompt1).toBe(prompt2)
    })

    it('should be a non-empty string', () => {
      const prompt = buildPrompt({
        healthData: mockHealthData,
        weather: mockWeatherData,
        userProfile: mockUserProfile,
      })

      expect(typeof prompt).toBe('string')
      expect(prompt.length).toBeGreaterThan(0)
      expect(prompt.trim().length).toBeGreaterThan(0) // Check trimmed content exists
    })

    it('should throw when required healthData fields are missing', () => {
      expect(() =>
        buildPrompt({
          healthData: {
            sleep: undefined as unknown as HealthData['sleep'],
            hrv: mockHealthData.hrv,
            heartRate: mockHealthData.heartRate,
            activity: mockHealthData.activity,
          },
          weather: mockWeatherData,
          userProfile: mockUserProfile,
        }),
      ).toThrow('Invalid healthData: missing required fields')
    })

    it('should throw when weather data is missing required sections', () => {
      expect(() =>
        buildPrompt({
          healthData: mockHealthData,
          weather: {
            current: undefined as unknown as WeatherData['current'],
            daily: undefined as unknown as WeatherData['daily'],
          },
          userProfile: mockUserProfile,
        }),
      ).toThrow('Invalid weather: missing required fields')
    })

    it('should throw when userProfile is missing required fields', () => {
      expect(() =>
        buildPrompt({
          healthData: mockHealthData,
          weather: mockWeatherData,
          userProfile: {
            age: undefined,
            gender: undefined,
            goals: undefined,
            dietaryPreferences: undefined,
            exerciseHabits: undefined,
            exerciseFrequency: undefined,
          } as unknown as UserProfile,
        }),
      ).toThrow('Invalid userProfile: missing required fields')
    })
  })
})
