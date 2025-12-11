// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import app from '../index.js';
import { generateMainAdvice } from '../services/claude.js';
import { fetchWeatherData } from '../services/weather.js';
import { fetchAirQualityData } from '../services/airQuality.js';
import { clearRateLimiter } from '../middleware/auth.js';

// Mock external services
vi.mock('../services/claude.js');
vi.mock('../services/weather.js');
vi.mock('../services/airQuality.js');

const mockGenerateMainAdvice = vi.mocked(generateMainAdvice);
const mockFetchWeatherData = vi.mocked(fetchWeatherData);
const mockFetchAirQualityData = vi.mocked(fetchAirQualityData);

describe('Advice Routes - Claude API Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    
    // Clear rate limiter for test isolation
    clearRateLimiter();
    
    // Mock successful weather data
    mockFetchWeatherData.mockResolvedValue({
      condition: '晴れ',
      tempCurrentC: 22,
      tempMaxC: 25,
      tempMinC: 18,
      humidityPercent: 60,
      uvIndex: 5,
      pressureHpa: 1013,
      precipitationProbability: 10,
    });

    // Mock successful air quality data
    mockFetchAirQualityData.mockResolvedValue({
      aqi: 25,
      pm25: 12,
    });
  });

  const validRequestBody = {
    userProfile: {
      nickname: 'テストユーザー',
      age: 28,
      gender: 'female',
      weightKg: 55.0,
      heightCm: 165.0,
      interests: ['fitness', 'beauty'],
      occupation: 'it_engineer',
      lifestyleRhythm: 'morning',
      exerciseFrequency: 'three_to_four',
    },
    healthData: {
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
    },
    location: {
      latitude: 35.6762,
      longitude: 139.6503,
      city: '東京',
    },
    context: {
      currentTime: '2025-12-11T07:00:00.000Z',
      dayOfWeek: 'wednesday',
      isMonday: false,
      recentDailyTries: [],
    },
  };

  const mockAdviceResponse = {
    greeting: 'テストユーザーさん、おはようございます',
    condition: {
      summary: '良好な状態です。',
      detail: 'HRVが45msと良好で、8時間の睡眠も確保できています。',
    },
    actionSuggestions: [
      {
        icon: 'fitness' as const,
        title: '今日も軽い運動を',
        detail: '昨日のヨガの効果で体調が良いので継続しましょう。',
      },
    ],
    closingMessage: '今日も良い一日をお過ごしください。',
    dailyTry: {
      title: '朝のストレッチ',
      summary: '目覚めを良くする軽いストレッチ',
      detail: '起床後5分間、軽く体を伸ばしてみてください。',
    },
    weeklyTry: {
      title: '新しい運動に挑戦',
      summary: 'ヨガ以外の運動を試してみる',
      detail: 'ピラティスやダンスなど新しい運動を一つ試してみませんか。',
    },
    generatedAt: '2025-12-11T07:00:00.000Z',
    timeSlot: 'morning' as const,
  };

  describe('POST /api/advice - Claude API Integration', () => {
    it('should generate advice using Claude API successfully', async () => {
      mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
          'ANTHROPIC_API_KEY': 'test-claude-key',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);

      const json = await res.json() as { success: boolean; data?: any };
      expect(json.success).toBe(true);
      
      if (json.data) {
        expect(json.data.greeting).toContain('テストユーザーさん');
        expect(json.data.timeSlot).toBe('morning');
      }

      // Verify Claude API was called
      expect(mockGenerateMainAdvice).toHaveBeenCalledTimes(1);
      
      const callArgs = mockGenerateMainAdvice.mock.calls[0]?.[0];
      expect(callArgs).toBeDefined();
      
      if (callArgs) {
        expect(callArgs.userProfile.nickname).toBe('テストユーザー');
        expect(callArgs.userProfile.interests).toEqual(['fitness', 'beauty']);
        expect(callArgs.apiKey).toBe('test-claude-key');
      }
    });

    it('should use fallback when Claude API fails', async () => {
      mockGenerateMainAdvice.mockRejectedValue(new Error('Claude API Error'));

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);

      const json = await res.json() as { success: boolean; data?: any };
      expect(json.success).toBe(true);
      
      if (json.data) {
        expect(json.data.greeting).toContain('テストユーザーさん');
        expect(json.data.condition.summary).toContain('あなたのペースで');
      }
    });

    it('should handle missing ANTHROPIC_API_KEY environment variable', async () => {
      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);

      const json = await res.json() as { success: boolean; data?: any };
      expect(json.success).toBe(true);
      
      if (json.data) {
        // Should fallback due to missing API key
        expect(json.data.condition.summary).toContain('あなたのペースで');
      }
    });

    it('should work with partial environment data', async () => {
      mockFetchWeatherData.mockRejectedValue(new Error('Weather API failed'));
      mockFetchAirQualityData.mockRejectedValue(new Error('Air Quality API failed'));
      mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);

      const json = await res.json() as { success: boolean; data?: any };
      expect(json.success).toBe(true);
      
      if (json.data) {
        expect(json.data).toBeTruthy();
      }

      // Verify Claude was called with undefined environment data
      expect(mockGenerateMainAdvice).toHaveBeenCalledWith(
        expect.objectContaining({
          weatherData: undefined,
          airQualityData: undefined,
        })
      );
    });

    it('should include environment data in response logging', async () => {
      mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);

      const consoleSpy = vi.spyOn(console, 'log').mockImplementation(() => {
        // Mock implementation for testing
      });

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      await app.request(req, {}, testEnv);

      // Verify that logs were called (exact content may vary)
      expect(consoleSpy).toHaveBeenCalled();
      
      // Check that sensitive data is not in logs
      const allLogs = consoleSpy.mock.calls.flat().join(' ');
      expect(allLogs).not.toContain('45'); // HRV value
      expect(allLogs).not.toContain('ヨガ'); // Workout type

      consoleSpy.mockRestore();
    });

    it('should handle Claude API timeout gracefully', async () => {
      mockGenerateMainAdvice.mockRejectedValue(new Error('Request timeout'));

      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {
        // Mock implementation for testing
      });

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);
      expect(consoleSpy).toHaveBeenCalledWith(
        '[Claude] Advice generation failed, using fallback:',
        expect.any(Error)
      );

      consoleSpy.mockRestore();
    });
  });

  describe('GET /api/advice - Development Info Update', () => {
    it('should return Phase 9 information', async () => {
      const req = new Request('http://localhost/api/advice', {
        method: 'GET',
        headers: {
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
      });

      const res = await app.request(req);

      expect(res.status).toBe(200);

      const json = await res.json() as { 
        message: string; 
        phase: { current: number; description: string }; 
        features: { claudeApi: string; promptCaching: string } 
      };
      expect(json.message).toContain('Phase 9 Implementation');
      expect(json.phase.current).toBe(9);
      expect(json.phase.description).toContain('Claude API');
      expect(json.features.claudeApi).toContain('Claude Sonnet');
      expect(json.features.promptCaching).toContain('prompt caching');
    });
  });

  describe('Request Context Building', () => {
    it('should build request context correctly', async () => {
      mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);

      const mondayRequest = {
        ...validRequestBody,
        context: {
          currentTime: '2025-12-15T07:00:00.000Z', // Monday
          dayOfWeek: 'monday',
          isMonday: true,
          recentDailyTries: ['水分補給', '深呼吸'],
        },
      };

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(mondayRequest),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      await app.request(req, {}, testEnv);

      expect(mockGenerateMainAdvice).toHaveBeenCalledWith(
        expect.objectContaining({
          context: expect.objectContaining({
            currentTime: '2025-12-15T07:00:00.000Z',
            dayOfWeek: '月曜日',
            isMonday: true,
            recentDailyTries: [],
            lastWeeklyTry: null,
          }),
        })
      );
    });
  });

  describe('Enhanced Error Scenarios', () => {
    it('should handle malformed JSON request body', async () => {
      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: '{ invalid json }',
      });

      const testEnv = { ENVIRONMENT: 'development' as const };
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(400);
      const json = await res.json() as { success: boolean; error: string };
      expect(json.success).toBe(false);
      expect(json.error).toBeTruthy();
    });

    it('should handle missing required userProfile fields', async () => {
      const invalidRequest = {
        userProfile: {
          nickname: 'test',
          // Missing required fields
        },
        healthData: validRequestBody.healthData,
        location: validRequestBody.location,
        context: validRequestBody.context,
      };

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(invalidRequest),
      });

      const testEnv = { ENVIRONMENT: 'development' as const };
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(400);
      const json = await res.json() as { success: boolean; error: string };
      expect(json.success).toBe(false);
      expect(json.error).toContain('Validation failed');
    });

    it('should handle different user profiles correctly', async () => {
      mockGenerateMainAdvice.mockResolvedValue({
        ...mockAdviceResponse,
        greeting: 'たろうさん、おはようございます',
      });

      const maleUserRequest = {
        ...validRequestBody,
        userProfile: {
          nickname: 'たろう',
          age: 35,
          gender: 'male' as const,
          weightKg: 70,
          heightCm: 175,
          interests: ['work_performance', 'fitness'],
          occupation: 'sales' as const,
          lifestyleRhythm: 'irregular' as const,
          exerciseFrequency: 'one_to_two' as const,
        },
      };

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(maleUserRequest),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(200);
      const json = await res.json() as { success: boolean; data?: any };
      expect(json.data?.greeting).toContain('たろう');
    });

    it('should not log sensitive health data', async () => {
      mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);

      const consoleSpy = vi.spyOn(console, 'log');

      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: JSON.stringify(validRequestBody),
      });

      const testEnv = {
        ANTHROPIC_API_KEY: 'test-claude-key',
        ENVIRONMENT: 'development' as const,
      };
      
      await app.request(req, {}, testEnv);

      // Verify that sensitive data is not logged
      const logCalls = consoleSpy.mock.calls.flat();
      const logString = JSON.stringify(logCalls);
      
      // Should not contain specific health values
      expect(logString).not.toContain('45'); // HRV value
      expect(logString).not.toContain('8500'); // Step count
      expect(logString).not.toContain('ヨガ'); // Workout type
    });
  });
});