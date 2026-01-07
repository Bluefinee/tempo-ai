import { beforeEach, describe, expect, it, vi } from 'vitest';
import { err, ok } from '../../utils/result';
import { AdviceService } from './AdviceService';
import { AnthropicClient } from './AnthropicClient';
import type { AdviceRequest } from './types';

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
    user: {
      goals: ['better_sleep'],
      wakeUpTime: '07:00',
      windDownTime: '23:00',
    },
    scores: {
      recovery: 70,
      sleep: 85,
      rhythm: 92,
      energy: 78,
    },
    healthMetrics: {
      hrv: {
        current: 82,
        baseline: 77,
        deviation: 6,
      },
      rhr: {
        current: 59,
        baseline: 59,
      },
      sleep: {
        durationMinutes: 428,
        deepSleepMinutes: 105,
        deepSleepPercent: 23,
        remSleepMinutes: 95,
        remSleepPercent: 22,
        bedtime: '23:15',
        wakeTime: '06:45',
        vsTargetBedtime: '+15min',
      },
    },
    weather: {
      temperature: 8,
      pressure: 1018,
      pressureTrend: 'stable',
      sunrise: '06:50',
      sunset: '16:48',
      description: '晴れ',
      location: 'Tokyo',
    },
    rhythmPhases: {
      peakFocus: {
        start: '09:00',
        end: '12:00',
      },
      afternoonDip: {
        start: '14:00',
        end: '16:00',
      },
      secondWind: {
        start: '17:00',
        end: '20:00',
      },
      windDown: {
        start: '21:00',
        end: '23:00',
      },
    },
    locale: 'ja',
  });

  const createMockResponse = () => ({
    todayInsight: {
      title: 'Morning Light',
      summary: '今日は良いスタートが切れそうです。',
      whyThisMatters: {
        hrv: {
          headline: 'HRVがベースラインより6%高い',
          explanation: '自律神経がしっかり回復しています。',
        },
        sleep: {
          headline: '深い睡眠が23%',
          explanation: '身体の修復に理想的な範囲でした。',
        },
        rhythm: {
          headline: '就寝時刻が目標の15分遅れ',
          explanation: 'この程度のズレは許容範囲です。',
        },
      },
      whatThisMeansForToday: '午前中は特に集中力が高まります。',
    },
    todayOneThing: {
      icon: 'breathing' as const,
      action: '深呼吸で1日をスタート',
      summary: '心と身体を整えます',
      time: '07:30',
      whyThisAction: '深呼吸は自律神経を整えます。',
      benefits: ['心を落ち着ける', '集中力を高める', 'ストレスを軽減'],
      howToDoIt: ['楽な姿勢で座る', '4秒かけて吸う', '8秒で吐く'],
      expectedBenefit: {
        text: '呼吸法は自律神経のバランスを整えます',
        source: '一般的な知見',
      },
    },
    relatedInsight: {
      label: 'Research Finding',
      text: 'HRVが基準値を上回っています',
      source: '研究に基づく',
    },
  });

  describe('generateAdvice', () => {
    it('should return advice on valid request', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      const result = await service.generateAdvice(createValidRequest());

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.todayInsight.title).toBe('Morning Light');
        expect(result.data.todayOneThing.icon).toBe('breathing');
        expect(result.data.todayOneThing.action).toBe('深呼吸で1日をスタート');
        expect(result.data.relatedInsight.label).toBe('Research Finding');
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
      expect(userDataXml).toContain('<goals>better_sleep</goals>');
      expect(userDataXml).toContain('<wake_up_time>07:00</wake_up_time>');
    });

    it('should return INVALID_REQUEST when user is missing', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        healthMetrics: createValidRequest().healthMetrics,
        weather: createValidRequest().weather,
      };

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
        expect(result.error.message).toBe('Invalid request data');
      }
    });

    it('should return INVALID_REQUEST when healthMetrics is missing', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        user: createValidRequest().user,
        weather: createValidRequest().weather,
      };

      const result = await service.generateAdvice(invalidRequest);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_REQUEST');
      }
    });

    it('should return INVALID_REQUEST when goals is invalid', async () => {
      const service = new AdviceService('test-api-key');

      const invalidRequest = {
        ...createValidRequest(),
        user: {
          ...createValidRequest().user,
          goals: ['invalid_goal'],
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

      // AI_API_ERROR時もフォールバックレスポンスを返すため、okになる
      expect(result.ok).toBe(true);
      if (result.ok) {
        // フォールバックレスポンスが返されていることを確認
        expect(result.data.todayInsight.title).toBe('New Day');
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

      // RATE_LIMIT_ERROR時もフォールバックレスポンスを返すため、okになる
      expect(result.ok).toBe(true);
      if (result.ok) {
        // フォールバックレスポンスが返されていることを確認
        expect(result.data.todayInsight.title).toBe('New Day');
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

      // PARSE_ERROR時はフォールバックレスポンスを返すため、okになる
      expect(result.ok).toBe(true);
      if (result.ok) {
        // フォールバックレスポンスが返されていることを確認
        expect(result.data.todayInsight.title).toBe('New Day');
      }
    });

    it('should include scores in XML', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      await service.generateAdvice(createValidRequest());

      const calls = mockGenerateAdvice.mock.calls;
      expect(calls.length).toBeGreaterThan(0);
      const [, userDataXml] = calls[0] as [string, string];
      expect(userDataXml).toContain('<scores');
      expect(userDataXml).toContain('<recovery value="70"');
      expect(userDataXml).toContain('<sleep value="85"');
      expect(userDataXml).toContain('<rhythm value="92"');
      expect(userDataXml).toContain('<energy value="78"');
    });

    it('should include rhythm_phases in XML', async () => {
      mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));
      const service = new AdviceService('test-api-key');

      await service.generateAdvice(createValidRequest());

      const calls = mockGenerateAdvice.mock.calls;
      expect(calls.length).toBeGreaterThan(0);
      const [, userDataXml] = calls[0] as [string, string];
      expect(userDataXml).toContain('<rhythm_phases>');
      expect(userDataXml).toContain('<peak_focus start="09:00" end="12:00"');
      expect(userDataXml).toContain('<afternoon_dip start="14:00" end="16:00"');
    });
  });
});
