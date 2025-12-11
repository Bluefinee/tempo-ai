import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { Mock } from 'vitest';
import Anthropic from '@anthropic-ai/sdk';
import { 
  generateMainAdvice, 
  generateAdditionalAdvice, 
  createFallbackAdvice 
} from './claude.js';
import type { 
  GenerateAdviceParams, 
  AdditionalAdviceParams 
} from '../types/claude.js';
import type { 
  UserProfile, 
  HealthData, 
  WeatherData, 
  AirQualityData 
} from '../types/domain.js';
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
      const mockAdviceResponse = {
        greeting: 'テストユーザーさん、おはようございます',
        condition: {
          summary: 'とても良い状態です。',
          detail: '8時間の睡眠とHRV45msで体調良好です。',
        },
        actionSuggestions: [
          {
            icon: 'fitness',
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
        timeSlot: 'morning',
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
      expect(result.condition.summary).toBe(mockAdviceResponse.condition.summary);
      expect(result.actionSuggestions).toHaveLength(1);
      expect(result.timeSlot).toBe('morning');
      expect(result.generatedAt).toBeTruthy();
    });

    it('should handle JSON response wrapped in code blocks', async () => {
      const mockAdviceResponse = {
        greeting: 'テストユーザーさん、おはようございます',
        condition: { summary: 'test', detail: 'test' },
        actionSuggestions: [{ icon: 'fitness', title: 'test', detail: 'test' }],
        closingMessage: 'test',
        dailyTry: { title: 'test', summary: 'test', detail: 'test' },
        generatedAt: '2025-12-11T07:00:00.000Z',
        timeSlot: 'morning',
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
    });
  });

  describe('generateAdditionalAdvice', () => {
    const mockMainAdvice = {
      greeting: 'テストユーザーさん、おはようございます',
      condition: { summary: 'test', detail: 'test' },
      actionSuggestions: [{ icon: 'fitness' as const, title: 'test', detail: 'test' }],
      closingMessage: 'test',
      dailyTry: { title: 'test', summary: 'test', detail: 'test' },
      generatedAt: '2025-12-11T07:00:00.000Z',
      timeSlot: 'morning' as const,
    };

    const mockAdditionalAdviceParams: AdditionalAdviceParams = {
      mainAdvice: mockMainAdvice,
      timeSlot: 'midday',
      userProfile: mockUserProfile,
      apiKey: 'test-api-key',
    };

    it('should generate valid additional advice with Claude Haiku', async () => {
      const mockAdditionalResponse = {
        greeting: 'テストユーザーさん、お疲れ様です',
        message: '午後も頑張っていきましょう。',
        actionSuggestion: {
          icon: 'hydration',
          title: '水分補給',
          detail: 'こまめに水分を取りましょう。',
        },
        generatedAt: '2025-12-11T12:00:00.000Z',
        timeSlot: 'midday',
      };

      const mockClaudeResponse = {
        content: [{ type: 'text', text: JSON.stringify(mockAdditionalResponse) }],
      };

      mockClient.messages.create.mockResolvedValue(mockClaudeResponse);

      const result = await generateAdditionalAdvice(mockAdditionalAdviceParams);

      expect(mockClient.messages.create).toHaveBeenCalledWith({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 1024,
        system: expect.any(String),
        messages: [
          {
            role: 'user',
            content: expect.stringContaining('テストユーザー'),
          },
        ],
      });

      expect(result.greeting).toBe(mockAdditionalResponse.greeting);
      expect(result.timeSlot).toBe('midday');
    });

    it('should handle additional advice API errors with fallback', async () => {
      mockClient.messages.create.mockRejectedValue(new Error('API Error'));

      await expect(generateAdditionalAdvice(mockAdditionalAdviceParams)).rejects.toThrow(ClaudeApiError);
    });
  });

  describe('createFallbackAdvice', () => {
    it('should create valid fallback advice', () => {
      const nickname = 'テストユーザー';
      const fallback = createFallbackAdvice(nickname);

      expect(fallback.greeting).toContain(nickname);
      expect(fallback.condition.summary).toBeTruthy();
      expect(fallback.actionSuggestions).toHaveLength(2);
      expect(fallback.dailyTry).toBeTruthy();
      expect(fallback.timeSlot).toBe('morning');
      expect(fallback.generatedAt).toBeTruthy();
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