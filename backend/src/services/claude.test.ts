import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { Mock } from 'vitest';
import Anthropic from '@anthropic-ai/sdk';
import { generateMainAdvice, createFallbackAdvice } from './claude.js';
import type { GenerateAdviceParams } from '../types/claude.js';
import type { UserProfile, HealthData, WeatherData, AirQualityData } from '../types/domain.js';
import { ClaudeApiError } from '../utils/errors.js';

// Mock Anthropic SDK
vi.mock('@anthropic-ai/sdk');

const MockedAnthropic = vi.mocked(Anthropic);

describe('Claude API Service', () => {
  let mockClient: {
    messages: {
      create: Mock;
    };
  };

  beforeEach(() => {
    vi.clearAllMocks();

    mockClient = {
      messages: {
        create: vi.fn(),
      },
    };

    MockedAnthropic.mockImplementation(() => mockClient as unknown as Anthropic);
  });

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

  const mockScores = {
    hrv: 85,
    sleep: 82,
    rhythm: 78,
    activity: 70,
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
    scores: mockScores,
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
  };

  const mockRequestContext = {
    currentTime: '2025-12-11T07:00:00.000Z',
    dayOfWeek: '水曜日',
    isMonday: false,
    recentDailyTries: [],
    lastWeeklyTry: null,
  };

  const mockGenerateAdviceParams: GenerateAdviceParams = {
    userProfile: mockUserProfile,
    healthData: mockHealthData,
    weatherData: mockWeatherData,
    airQualityData: mockAirQualityData,
    context: mockRequestContext,
    apiKey: 'test-api-key',
  };

  describe('generateMainAdvice', () => {
    it('should generate valid main advice with Claude Sonnet', async () => {
      // Mock response in new snake_case format (as Claude returns it)
      const mockAdviceResponse = {
        greeting: 'テストユーザーさん、おはようございます',
        energy_comment: '今日は絶好調ですね！',
        condition: {
          summary: 'とても良い状態です。',
          detail: '8時間の睡眠とHRV45msで体調良好です。',
        },
        insight: '昨夜の良質な睡眠が、今日のコンディション向上に貢献しています。',
        daily_try: {
          title: '朝のストレッチ',
          detail: '起床後5分間、軽く体を伸ばしてみてください。',
        },
        closing_message: '今日も良い一日をお過ごしください。',
      };

      const mockClaudeResponse = {
        content: [
          {
            type: 'text',
            text: JSON.stringify(mockAdviceResponse),
          },
        ],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      const result = await generateMainAdvice(mockGenerateAdviceParams);

      expect(MockedAnthropic).toHaveBeenCalledWith({ apiKey: 'test-api-key' });
      expect(mockClient.messages.create).toHaveBeenCalledWith({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 4096,
        system: expect.arrayContaining([
          expect.objectContaining({
            type: 'text',
            cache_control: { type: 'ephemeral' },
          }),
        ]),
        messages: [
          {
            role: 'user',
            content: expect.stringContaining('テストユーザー'),
          },
        ],
      });

      expect(result.greeting).toBe(mockAdviceResponse.greeting);
      expect(result.energyComment).toBe(mockAdviceResponse.energy_comment);
      expect(result.condition.summary).toBe(mockAdviceResponse.condition.summary);
      expect(result.insight).toBe(mockAdviceResponse.insight);
      expect(result.dailyTry.title).toBe(mockAdviceResponse.daily_try.title);
      expect(result.closingMessage).toBe(mockAdviceResponse.closing_message);
      expect(result.scores).toEqual(mockScores);
      expect(result.timeSlot).toBe('morning');
      expect(result.generatedAt).toBeTruthy();
    });

    it('should handle JSON response wrapped in code blocks', async () => {
      const mockAdviceResponse = {
        greeting: 'テストユーザーさん、おはようございます',
        energy_comment: 'いいコンディションです',
        condition: { summary: 'test', detail: 'test' },
        insight: 'テストの洞察です。',
        daily_try: { title: 'test', detail: 'test' },
        closing_message: 'test',
      };

      const wrappedResponse = `\`\`\`json
${JSON.stringify(mockAdviceResponse, null, 2)}
\`\`\``;

      const mockClaudeResponse = {
        content: [{ type: 'text', text: wrappedResponse }],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      const result = await generateMainAdvice(mockGenerateAdviceParams);

      expect(result.greeting).toBe(mockAdviceResponse.greeting);
      expect(result.energyComment).toBe(mockAdviceResponse.energy_comment);
    });

    it('should handle Claude API errors gracefully', async () => {
      const apiError = new Error('API rate limit exceeded');
      mockClient.messages.create.mockRejectedValue(apiError);

      await expect(generateMainAdvice(mockGenerateAdviceParams)).rejects.toThrow(ClaudeApiError);
    });

    it('should handle invalid JSON responses with fallback', async () => {
      const mockClaudeResponse = {
        content: [{ type: 'text', text: 'Invalid JSON response' }],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      const result = await generateMainAdvice(mockGenerateAdviceParams);

      // Should return fallback advice
      expect(result.greeting).toContain('テストユーザーさん');
      expect(result.condition.summary).toContain('あなたのペースで');
      expect(result.scores).toEqual(mockScores);
    });

    it('should handle missing text content in response', async () => {
      const mockClaudeResponse = {
        content: [{ type: 'image', data: 'some-image-data' }],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      await expect(generateMainAdvice(mockGenerateAdviceParams)).rejects.toThrow(ClaudeApiError);
    });

    it('should validate required fields in Claude response', async () => {
      const invalidResponse = {
        greeting: 'Hello',
        // Missing required fields
      };

      const mockClaudeResponse = {
        content: [{ type: 'text', text: JSON.stringify(invalidResponse) }],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      const result = await generateMainAdvice(mockGenerateAdviceParams);

      // Should fallback due to validation error
      expect(result.greeting).toContain('テストユーザーさん');
      expect(result.scores).toEqual(mockScores);
    });
  });

  describe('createFallbackAdvice', () => {
    it('should create valid fallback advice', () => {
      const nickname = 'テストユーザー';
      const fallback = createFallbackAdvice(nickname, mockScores);

      expect(fallback.greeting).toContain(nickname);
      expect(fallback.energyComment).toBeTruthy();
      expect(fallback.condition.summary).toBeTruthy();
      expect(fallback.insight).toBeTruthy();
      expect(fallback.dailyTry).toBeTruthy();
      expect(fallback.closingMessage).toBeTruthy();
      expect(fallback.scores).toEqual(mockScores);
      expect(fallback.timeSlot).toBe('morning');
      expect(fallback.generatedAt).toBeTruthy();
    });

    it('should generate appropriate energy comment based on HRV score', () => {
      const nickname = 'テスト';

      // High HRV (80-100): excellent comments
      const highHrv = createFallbackAdvice(nickname, { ...mockScores, hrv: 85 });
      expect(highHrv.energyComment).toBeTruthy();
      expect(highHrv.energyComment.length).toBeGreaterThan(0);

      // Medium HRV (60-79): good comments
      const mediumHrv = createFallbackAdvice(nickname, { ...mockScores, hrv: 65 });
      expect(mediumHrv.energyComment).toBeTruthy();
      expect(mediumHrv.energyComment.length).toBeGreaterThan(0);

      // Low HRV (20-39): low comments
      const lowHrv = createFallbackAdvice(nickname, { ...mockScores, hrv: 35 });
      expect(lowHrv.energyComment).toBeTruthy();
      expect(lowHrv.energyComment.length).toBeGreaterThan(0);

      // Very low HRV (0-19): veryLow comments
      const veryLowHrv = createFallbackAdvice(nickname, { ...mockScores, hrv: 15 });
      expect(veryLowHrv.energyComment).toBeTruthy();
      expect(veryLowHrv.energyComment.length).toBeGreaterThan(0);
    });
  });

  describe('Error Handling', () => {
    it('should handle network errors', async () => {
      const networkError = new Error('Network error: fetch failed');
      mockClient.messages.create.mockRejectedValue(networkError);

      await expect(generateMainAdvice(mockGenerateAdviceParams)).rejects.toThrow(ClaudeApiError);
    });

    it('should handle authentication errors', async () => {
      const authError = new Error('Authentication failed');
      mockClient.messages.create.mockRejectedValue(authError);

      await expect(generateMainAdvice(mockGenerateAdviceParams)).rejects.toThrow(ClaudeApiError);
    });

    it('should preserve original error information', async () => {
      const originalError = new Error('Original API error');
      mockClient.messages.create.mockRejectedValue(originalError);

      try {
        await generateMainAdvice(mockGenerateAdviceParams);
      } catch (error) {
        expect(error).toBeInstanceOf(ClaudeApiError);
        expect((error as ClaudeApiError).originalError).toBe(originalError);
      }
    });
  });
});
