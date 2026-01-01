import { beforeEach, describe, expect, it, vi } from 'vitest';
import { err, ok } from '../../utils/result';
import { AdviceService } from './AdviceService';
import { AnthropicClient } from './AnthropicClient';
import type { AdviceRequest, AdviceResponse } from './types';

// AnthropicClientをモック
vi.mock('./AnthropicClient');

describe('AdviceService', () => {
  let mockGenerateAdvice: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.clearAllMocks();
    mockGenerateAdvice = vi.fn();
    (AnthropicClient as unknown as ReturnType<typeof vi.fn>).mockImplementation(() => ({
      generateAdvice: mockGenerateAdvice,
    }));
  });

  const createValidRequest = (): AdviceRequest => ({
    profile: {
      nickname: 'マサ',
      age: 28,
      gender: 'male',
      chronotype: 'morning',
      targetBedtime: '23:00',
    },
    healthData: {
      scores: {
        autonomic: 85,
        sleep: 78,
        rhythm: 88,
        activity: 68,
      },
      rhythmAnalysis: {
        bedtimeStddevMinutes: 22,
        wakeTimeStddevMinutes: 18,
        consecutiveStableDays: 5,
        status: 'stable',
      },
    },
    location: {
      latitude: 35.6762,
      longitude: 139.6503,
      city: 'Tokyo',
    },
    context: {
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      todayMode: 'normal',
    },
  });

  const createMockResponse = (): AdviceResponse => ({
    summary: 'テストサマリー',
    fullInsight: 'テストインサイト',
    recommendedAction: {
      type: 'breathing',
      message: '深呼吸をしましょう',
    },
  });

  describe('generateAdvice', () => {
    it('should return advice on valid request', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      const result = await service.generateAdvice(createValidRequest());

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.summary).toBe('テストサマリー');
        expect(result.data.fullInsight).toBe('テストインサイト');
        expect(result.data.recommendedAction.type).toBe('breathing');
      }
    });

    it('should call AnthropicClient with correct prompts', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      await service.generateAdvice(createValidRequest());

      expect(mockGenerateAdvice).toHaveBeenCalledTimes(1);
      const calls = mockGenerateAdvice.mock.calls;
      expect(calls.length).toBeGreaterThan(0);
      const [systemPrompt, userDataXml] = calls[0] as [string, string];

      // System promptにはroleタグが含まれる
      expect(systemPrompt).toContain('<role>');
      expect(systemPrompt).toContain('Tempo');

      // User data XMLにはuser_dataタグが含まれる
      expect(userDataXml).toContain('<user_data>');
      expect(userDataXml).toContain('<nickname>マサ</nickname>');
    });

    it('should return INVALID_REQUEST when profile is missing', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        healthData: createValidRequest().healthData,
        location: createValidRequest().location,
        context: createValidRequest().context,
      };

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
        expect(result.error.message).toBe('Invalid request data');
      }
    });

    it('should return INVALID_REQUEST when healthData is missing', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        profile: createValidRequest().profile,
        location: createValidRequest().location,
        context: createValidRequest().context,
      };

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
      }
    });

    it('should return INVALID_REQUEST when age is out of range', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = createValidRequest();
      invalidRequest.profile.age = 150;

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
      }
    });

    it('should return INVALID_REQUEST when gender is invalid', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        ...createValidRequest(),
        profile: {
          ...createValidRequest().profile,
          gender: 'invalid',
        },
      };

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
      }
    });

    it('should propagate AI_API_ERROR from client', async () => {
      mockGenerateAdvice.mockResolvedValue(
        err({
          code: 'AI_API_ERROR',
          message: 'API error occurred',
        }),
      );
      const service = new AdviceService('test-api-key');

      const result = await service.generateAdvice(createValidRequest());

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('AI_API_ERROR');
        expect(result.error.message).toBe('API error occurred');
      }
    });

    it('should propagate RATE_LIMIT_ERROR from client', async () => {
      mockGenerateAdvice.mockResolvedValue(
        err({
          code: 'RATE_LIMIT_ERROR',
          message: 'Rate limit exceeded',
        }),
      );
      const service = new AdviceService('test-api-key');

      const result = await service.generateAdvice(createValidRequest());

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('RATE_LIMIT_ERROR');
      }
    });

    it('should propagate PARSE_ERROR from client', async () => {
      mockGenerateAdvice.mockResolvedValue(
        err({
          code: 'PARSE_ERROR',
          message: 'Failed to parse response',
        }),
      );
      const service = new AdviceService('test-api-key');

      const result = await service.generateAdvice(createValidRequest());

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
      }
    });

    it('should handle request with optional fields', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      const requestWithOptionals = {
        ...createValidRequest(),
        profile: {
          ...createValidRequest().profile,
          occupation: 'deskWork' as const,
          exerciseFrequency: 'twiceWeek' as const,
        },
        healthData: {
          ...createValidRequest().healthData,
          sleep: {
            bedtime: '23:15',
            wakeTime: '06:45',
            durationHours: 7.5,
            deepSleepMinutes: 105,
            remSleepMinutes: 95,
            deepSleepRatio: 0.23,
          },
          hrv: {
            value: 68,
            baseline30d: 62,
            deviationPercent: 9.7,
          },
        },
        weather: {
          temperature: 20.5,
          humidity: 65,
          pressure: 1013.25,
          weatherCode: 0,
          uvIndexMax: 5.2,
        },
      };

      const result = await service.generateAdvice(requestWithOptionals);

      expect(result.ok).toBe(true);
    });

    it('should handle challenge mode', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      const requestWithChallengeMode = {
        ...createValidRequest(),
        context: {
          ...createValidRequest().context,
          todayMode: 'challenge' as const,
        },
      };

      const result = await service.generateAdvice(requestWithChallengeMode);

      expect(result.ok).toBe(true);

      const challengeCalls = mockGenerateAdvice.mock.calls;
      expect(challengeCalls.length).toBeGreaterThan(0);
      const [, challengeUserDataXml] = challengeCalls[0] as [string, string];
      expect(challengeUserDataXml).toContain('<today_mode>challenge</today_mode>');
    });

    it('should handle holiday mode', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      const requestWithHolidayMode = {
        ...createValidRequest(),
        context: {
          ...createValidRequest().context,
          todayMode: 'holiday' as const,
        },
      };

      const result = await service.generateAdvice(requestWithHolidayMode);

      expect(result.ok).toBe(true);

      const holidayCalls = mockGenerateAdvice.mock.calls;
      expect(holidayCalls.length).toBeGreaterThan(0);
      const [, holidayUserDataXml] = holidayCalls[0] as [string, string];
      expect(holidayUserDataXml).toContain('<today_mode>holiday</today_mode>');
    });
  });
});
