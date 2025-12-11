// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect } from 'vitest';
import { 
  getExamplesForInterest, 
  buildUserDataPrompt 
} from './prompt.js';
import type { GenerateAdviceParams } from '../types/claude.js';
import type { 
  UserProfile, 
  HealthData, 
  WeatherData, 
  AirQualityData 
} from '../types/domain.js';

describe('Prompt Utilities', () => {
  // Test data
  const mockUserProfile: UserProfile = {
    nickname: 'テストユーザー',
    age: 28,
    gender: 'female',
    weightKg: 55.0,
    heightCm: 165.0,
    interests: ['fitness', 'beauty'],
    occupation: 'it_engineer',
    lifestyleRhythm: 'morning',
    exerciseFrequency: 'three_to_four',
  };

  const mockHealthData: HealthData = {
    date: '2025-12-11T07:00:00.000Z',
    sleep: {
      bedtime: '2025-12-10T23:00:00.000Z',
      wakeTime: '2025-12-11T07:00:00.000Z',
      durationHours: 8,
      deepSleepHours: 2,
      awakenings: 1,
    },
    morningVitals: {
      restingHeartRate: 62,
      hrvMs: 45,
    },
    yesterdayActivity: {
      steps: 8500,
      workoutType: 'ヨガ',
    },
    weekTrends: {
      avgSleepHours: 7.5,
      avgHrv: 42,
      avgSteps: 8000,
    },
  };

  const mockWeatherData: WeatherData = {
    condition: '晴れ',
    tempCurrentC: 22,
    tempMaxC: 25,
    tempMinC: 18,
    humidityPercent: 60,
    uvIndex: 5,
    pressureHpa: 1013,
    precipitationProbability: 10,
  };

  const mockAirQualityData: AirQualityData = {
    aqi: 25,
    pm25: 12,
    pm10: 20,
  };

  const mockRequestContext = {
    currentTime: '2025-12-11T07:00:00.000Z',
    dayOfWeek: '水曜日',
    isMonday: false,
    recentDailyTries: ['深呼吸', '水分補給'],
    lastWeeklyTry: '新しい運動',
  };

  describe('getExamplesForInterest', () => {
    it('should return fitness examples for fitness interest', () => {
      const result = getExamplesForInterest('fitness');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('フィットネスに関心の高いユーザー');
      expect(result.text).toContain('良好な状態の例');
      expect(result.text).toContain('疲労気味の状態の例');
    });

    it('should return beauty examples for beauty interest', () => {
      const result = getExamplesForInterest('beauty');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('美容に関心の高いユーザー');
      expect(result.text).toContain('良好な状態の例');
    });

    it('should return mental health examples for mental_health interest', () => {
      const result = getExamplesForInterest('mental_health');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('メンタルヘルスに関心の高いユーザー');
    });

    it('should return work examples for work_performance interest', () => {
      const result = getExamplesForInterest('work_performance');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('仕事パフォーマンスに関心の高いユーザー');
    });

    it('should return nutrition examples for nutrition interest', () => {
      const result = getExamplesForInterest('nutrition');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('栄養に関心の高いユーザー');
    });

    it('should return sleep examples for sleep interest', () => {
      const result = getExamplesForInterest('sleep');
      
      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toContain('睡眠に関心の高いユーザー');
    });

    it('should return fitness examples as default for unknown interest', () => {
      // Cast to test default behavior for unknown string
      // biome-ignore lint/suspicious/noExplicitAny: Test requires invalid enum value
      const result = getExamplesForInterest('unknown_interest' as any);
      
      expect(result.type).toBe('text');
      expect(result.text).toContain('フィットネスに関心の高いユーザー');
    });

    it('should return fitness examples when no interest provided', () => {
      const result = getExamplesForInterest(undefined);
      
      expect(result.type).toBe('text');
      expect(result.text).toContain('フィットネスに関心の高いユーザー');
    });
  });

  describe('buildUserDataPrompt', () => {
    const mockParams: GenerateAdviceParams = {
      userProfile: mockUserProfile,
      healthData: mockHealthData,
      weatherData: mockWeatherData,
      airQualityData: mockAirQualityData,
      context: mockRequestContext,
      apiKey: 'test-key',
    };

    it('should build complete user data prompt with all data', () => {
      const result = buildUserDataPrompt(mockParams);
      
      // Check user profile section
      expect(result).toContain('<user_data>');
      expect(result).toContain('<profile>');
      expect(result).toContain('ニックネーム: テストユーザー');
      expect(result).toContain('年齢: 28歳');
      expect(result).toContain('性別: 女性');
      expect(result).toContain('体重: 55kg');
      expect(result).toContain('身長: 165cm');
      expect(result).toContain('職業: ITエンジニア');
      expect(result).toContain('生活リズム: 朝型');
      expect(result).toContain('運動習慣: 週3-4回');
      expect(result).toContain('関心ごと: fitness, beauty');
      
      // Check health data section
      expect(result).toContain('<health_data>');
      expect(result).toContain('日付: 2025-12-11T07:00:00.000Z');
      expect(result).toContain('睡眠時間: 8時間');
      expect(result).toContain('深い睡眠: 2時間');
      expect(result).toContain('中途覚醒: 1回');
      expect(result).toContain('安静時心拍数: 62bpm');
      expect(result).toContain('HRV: 45ms');
      expect(result).toContain('歩数: 8500歩');
      expect(result).toContain('運動: ヨガ');
      expect(result).toContain('平均睡眠時間: 7.5時間');
      
      // Check environment section
      expect(result).toContain('<environment>');
      expect(result).toContain('天気: 晴れ');
      expect(result).toContain('気温: 22℃');
      expect(result).toContain('湿度: 60%');
      expect(result).toContain('AQI: 25');
      expect(result).toContain('PM2.5: 12μg/m³');
      
      // Check context section
      expect(result).toContain('<context>');
      expect(result).toContain('現在時刻: 2025-12-11T07:00:00.000Z');
      expect(result).toContain('曜日: 水曜日');
      expect(result).toContain('月曜日: いいえ');
      expect(result).toContain('過去2週間の今日のトライ: 深呼吸, 水分補給');
      expect(result).toContain('先週の今週のトライ: 新しい運動');
      
      expect(result).toContain('上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。');
    });

    it('should handle missing optional health data fields', () => {
      const paramsWithPartialData: GenerateAdviceParams = {
        ...mockParams,
        healthData: {
          date: '2025-12-11T07:00:00.000Z',
          // Only partial health data
        },
      };

      const result = buildUserDataPrompt(paramsWithPartialData);
      
      expect(result).toContain('就寝: 不明');
      expect(result).toContain('起床: 不明');
      expect(result).toContain('睡眠時間: 不明時間');
      expect(result).toContain('安静時心拍数: 不明bpm');
      expect(result).toContain('HRV: 不明ms');
      expect(result).toContain('歩数: 不明歩');
      expect(result).toContain('運動: なし');
    });

    it('should handle missing optional user profile fields', () => {
      const paramsWithPartialProfile: GenerateAdviceParams = {
        ...mockParams,
        userProfile: {
          nickname: 'ユーザー',
          age: 25,
          gender: 'male',
          weightKg: 70,
          heightCm: 175,
          interests: ['fitness'],
          // Missing optional fields
        },
      };

      const result = buildUserDataPrompt(paramsWithPartialProfile);
      
      expect(result).toContain('職業: 未設定');
      expect(result).toContain('生活リズム: 未設定');
      expect(result).toContain('運動習慣: 未設定');
    });

    it('should handle missing weather data', () => {
      const paramsWithoutWeather: GenerateAdviceParams = {
        ...mockParams,
        weatherData: undefined,
      };

      const result = buildUserDataPrompt(paramsWithoutWeather);
      
      expect(result).toContain('気象データ: 取得できませんでした');
    });

    it('should handle missing air quality data', () => {
      const paramsWithoutAirQuality: GenerateAdviceParams = {
        ...mockParams,
        airQualityData: undefined,
      };

      const result = buildUserDataPrompt(paramsWithoutAirQuality);
      
      expect(result).toContain('大気汚染データ: 取得できませんでした');
    });

    it('should handle empty recent tries and null weekly try', () => {
      const paramsWithEmptyContext: GenerateAdviceParams = {
        ...mockParams,
        context: {
          currentTime: '2025-12-11T07:00:00.000Z',
          dayOfWeek: '水曜日',
          isMonday: false,
          recentDailyTries: [],
          lastWeeklyTry: null,
        },
      };

      const result = buildUserDataPrompt(paramsWithEmptyContext);
      
      expect(result).toContain('過去2週間の今日のトライ: なし');
      expect(result).toContain('先週の今週のトライ: なし');
    });

    it('should format gender correctly for all types', () => {
      const testCases = [
        { gender: 'male', expected: '男性' },
        { gender: 'female', expected: '女性' },
        { gender: 'other', expected: 'その他' },
        { gender: 'not_specified', expected: '未設定' },
      ] as const;

      for (const { gender, expected } of testCases) {
        const params: GenerateAdviceParams = {
          ...mockParams,
          userProfile: {
            ...mockUserProfile,
            gender,
          },
        };

        const result = buildUserDataPrompt(params);
        expect(result).toContain(`性別: ${expected}`);
      }
    });

    it('should format occupation correctly', () => {
      const testCases = [
        { occupation: 'it_engineer', expected: 'ITエンジニア' },
        { occupation: 'sales', expected: '営業' },
        { occupation: 'medical', expected: '医療従事者' },
        { occupation: 'student', expected: '学生' },
        { occupation: 'other', expected: 'その他' },
      ] as const;

      for (const { occupation, expected } of testCases) {
        const params: GenerateAdviceParams = {
          ...mockParams,
          userProfile: {
            ...mockUserProfile,
            occupation,
          },
        };

        const result = buildUserDataPrompt(params);
        expect(result).toContain(`職業: ${expected}`);
      }
    });

    it('should format exercise frequency correctly', () => {
      const testCases = [
        { exerciseFrequency: 'daily', expected: 'ほぼ毎日' },
        { exerciseFrequency: 'three_to_four', expected: '週3-4回' },
        { exerciseFrequency: 'one_to_two', expected: '週1-2回' },
        { exerciseFrequency: 'rarely', expected: '運動習慣なし' },
      ] as const;

      for (const { exerciseFrequency, expected } of testCases) {
        const params: GenerateAdviceParams = {
          ...mockParams,
          userProfile: {
            ...mockUserProfile,
            exerciseFrequency,
          },
        };

        const result = buildUserDataPrompt(params);
        expect(result).toContain(`運動習慣: ${expected}`);
      }
    });
  });
});