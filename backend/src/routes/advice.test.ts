import { Hono } from 'hono';
import type { ContentfulStatusCode } from 'hono/utils/http-status';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { AdviceService } from '../services/advice/AdviceService';
import type { AdviceErrorCode, AdviceResponse } from '../services/advice/types';
import { err, ok } from '../utils/result';
import { isOk } from '../utils/result';

// AdviceServiceをモック
vi.mock('../services/advice/AdviceService');

interface Bindings {
  ENVIRONMENT: 'development' | 'staging' | 'production';
  ANTHROPIC_API_KEY: string;
}

describe('POST /api/advice', () => {
  let mockGenerateAdvice: ReturnType<typeof vi.fn>;
  let testApp: Hono<{ Bindings: Bindings }>;

  const createValidRequestBody = () => ({
    user: {
      goals: ['better_sleep'] as const,
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
      pressureTrend: 'stable' as const,
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
    },
    locale: 'ja',
  });

  const createMockResponse = (): AdviceResponse => ({
    todayInsight: {
      title: 'A Quiet Harmony',
      summary: '今日のあなたは穏やかな波のように整っています。',
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
      icon: 'walking' as const,
      action: '14時頃に5分の散歩',
      summary: '夕方のリズムが整います',
      time: '14:00',
      whyThisAction: 'Afternoon Dipの時間帯に軽い動きを入れることで午後の集中力を回復できます。',
      benefits: ['覚醒度を回復', 'メラトニン分泌を改善', '体温リズムを安定'],
      howToDoIt: ['外に出る', '軽いペースで歩く', '自然光を浴びる'],
      expectedBenefit: {
        text: '午後の軽い運動は睡眠の質を10-20%改善する傾向があります',
        source: 'サーカディアンリズム研究に基づく',
      },
    },
    relatedInsight: {
      label: 'Research Finding',
      text: '23時前就寝で深い睡眠が20-25%増加',
      source: '睡眠科学研究に基づく',
    },
  });

  /**
   * Maps advice error codes to HTTP status codes
   */
  const getStatusCode = (errorCode: AdviceErrorCode): ContentfulStatusCode => {
    const statusMap: Record<AdviceErrorCode, ContentfulStatusCode> = {
      INVALID_REQUEST: 400,
      AI_API_ERROR: 502,
      RATE_LIMIT_ERROR: 429,
      NETWORK_ERROR: 503,
      PARSE_ERROR: 500,
    };
    return statusMap[errorCode];
  };

  beforeEach(() => {
    vi.clearAllMocks();
    mockGenerateAdvice = vi.fn();
    (AdviceService as unknown as ReturnType<typeof vi.fn>).mockImplementation(() => ({
      generateAdvice: mockGenerateAdvice,
    }));

    // テスト用アプリを作成（Bindingsなし、APIキーをenv経由で渡すルート）
    testApp = new Hono<{ Bindings: Bindings }>();
    testApp.post('/api/advice', async (c) => {
      const apiKey = c.env?.ANTHROPIC_API_KEY;
      if (!apiKey) {
        return c.json({ success: false, error: 'ANTHROPIC_API_KEY is not configured' }, 500);
      }

      let requestBody: unknown;
      try {
        requestBody = await c.req.json();
      } catch {
        return c.json({ success: false, error: 'Invalid JSON body' }, 400);
      }

      const service = new AdviceService(apiKey);
      const result = await service.generateAdvice(requestBody);

      if (isOk(result)) {
        return c.json({ success: true, data: result.data });
      }

      return c.json(
        { success: false, error: result.error.message },
        getStatusCode(result.error.code),
      );
    });
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  const makeRequest = (body: unknown, apiKey = 'test-api-key') => {
    const req = new Request('http://localhost/api/advice', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: typeof body === 'string' ? body : JSON.stringify(body),
    });

    // Honoのfetchを使ってenvを設定
    return testApp.fetch(req, {
      ENVIRONMENT: 'development',
      ANTHROPIC_API_KEY: apiKey,
    } as Bindings);
  };

  it('should return 200 with advice data for valid request', async () => {
    mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data: AdviceResponse };
    expect(json.success).toBe(true);
    expect(json.data.todayInsight.title).toBe('A Quiet Harmony');
    expect(json.data.todayInsight.summary).toBeTruthy();
    expect(json.data.todayOneThing.icon).toBe('walking');
    expect(json.data.todayOneThing.action).toBe('14時頃に5分の散歩');
    expect(json.data.relatedInsight.label).toBe('Research Finding');
  });

  it('should return 400 for invalid JSON body', async () => {
    const req = new Request('http://localhost/api/advice', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: 'invalid json',
    });
    const res = await testApp.fetch(req, {
      ENVIRONMENT: 'development',
      ANTHROPIC_API_KEY: 'test-api-key',
    } as Bindings);

    expect(res.status).toBe(400);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
    expect(json.error).toBe('Invalid JSON body');
  });

  it('should return 400 for INVALID_REQUEST error', async () => {
    mockGenerateAdvice.mockResolvedValue(
      err({
        code: 'INVALID_REQUEST',
        message: 'Invalid request data',
      }),
    );

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(400);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
    expect(json.error).toBe('Invalid request data');
  });

  it('should return 429 for RATE_LIMIT_ERROR', async () => {
    mockGenerateAdvice.mockResolvedValue(
      err({
        code: 'RATE_LIMIT_ERROR',
        message: 'Rate limit exceeded',
      }),
    );

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(429);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
  });

  it('should return 502 for AI_API_ERROR', async () => {
    mockGenerateAdvice.mockResolvedValue(
      err({
        code: 'AI_API_ERROR',
        message: 'Anthropic API error',
      }),
    );

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(502);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
  });

  it('should return 503 for NETWORK_ERROR', async () => {
    mockGenerateAdvice.mockResolvedValue(
      err({
        code: 'NETWORK_ERROR',
        message: 'Network error occurred',
      }),
    );

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(503);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
  });

  it('should return 500 for PARSE_ERROR', async () => {
    mockGenerateAdvice.mockResolvedValue(
      err({
        code: 'PARSE_ERROR',
        message: 'Failed to parse response',
      }),
    );

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(500);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
  });

  it('should return 500 when ANTHROPIC_API_KEY is not configured', async () => {
    const res = await makeRequest(createValidRequestBody(), '');

    expect(res.status).toBe(500);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
    expect(json.error).toBe('ANTHROPIC_API_KEY is not configured');
  });

  it('should handle request with all required fields', async () => {
    mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));

    const res = await makeRequest(createValidRequestBody());

    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data: AdviceResponse };
    expect(json.success).toBe(true);
    expect(json.data.todayInsight).toBeTruthy();
    expect(json.data.todayOneThing).toBeTruthy();
    expect(json.data.relatedInsight).toBeTruthy();
  });
});
