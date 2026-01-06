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
    summary: 'テストサマリーです。今日のコンディションは良好です。',
    insight: {
      greeting: 'マサさん、おはようございます。',
      condition: '今日のコンディションは全体的に良好です。',
      sleep: '昨夜の睡眠は目標通りで、深い睡眠も十分に取れています。',
      rhythm: 'リズムは安定しています。',
      environment: '今日の天気は良好です。',
      advice: '午前中に軽い運動をすることをおすすめします。',
      closing: '今日も良い一日になりますように。',
    },
    recommendedAction: {
      type: 'breathing',
      message: '深呼吸を3回してみましょう',
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
    expect(json.data.summary).toBe('テストサマリーです。今日のコンディションは良好です。');
    expect(json.data.insight.greeting).toContain('マサさん、おはようございます');
    expect(json.data.recommendedAction.type).toBe('breathing');
    expect(json.data.recommendedAction.message).toBe('深呼吸を3回してみましょう');
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

  it('should handle request with optional weather data', async () => {
    mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));

    const requestWithWeather = {
      ...createValidRequestBody(),
      weather: {
        temperature: 20.5,
        humidity: 65,
        pressure: 1013.25,
        weatherCode: 0,
        uvIndexMax: 5.2,
      },
    };

    const res = await makeRequest(requestWithWeather);

    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data: AdviceResponse };
    expect(json.success).toBe(true);
  });

  it('should handle challenge mode request', async () => {
    mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));

    const challengeRequest = {
      ...createValidRequestBody(),
      context: {
        ...createValidRequestBody().context,
        todayMode: 'challenge',
      },
    };

    const res = await makeRequest(challengeRequest);

    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data: AdviceResponse };
    expect(json.success).toBe(true);
  });

  it('should handle holiday mode request', async () => {
    mockGenerateAdvice.mockResolvedValue(ok(createMockResponse()));

    const holidayRequest = {
      ...createValidRequestBody(),
      context: {
        ...createValidRequestBody().context,
        todayMode: 'holiday',
      },
    };

    const res = await makeRequest(holidayRequest);

    expect(res.status).toBe(200);

    const json = (await res.json()) as { success: boolean; data: AdviceResponse };
    expect(json.success).toBe(true);
  });
});
