
import { describe, expect, it, vi, beforeEach } from 'vitest';
import app from './index';
import {
  ApiInfoResponseSchema,
  HealthCheckResponseSchema,
} from './types/response';
import { generateMainAdvice } from './services/claude';

// Mock external services to avoid real API calls
vi.mock('./services/claude');
vi.mock('./services/weather');
vi.mock('./services/airQuality');

const mockGenerateMainAdvice = vi.mocked(generateMainAdvice);

describe('Tempo AI Backend', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    
    // Mock successful Claude API response
    const mockAdviceResponse = {
      greeting: 'テストユーザーさん、おはようございます',
      condition: {
        summary: '良好な状態です。',
        detail: 'テスト用のアドバイスです。',
      },
      actionSuggestions: [
        {
          icon: 'fitness' as const,
          title: '軽い運動',
          detail: '今日も元気に過ごしましょう。',
        },
        {
          icon: 'hydration' as const,
          title: '水分補給',
          detail: 'こまめに水分を取りましょう。',
        },
      ],
      closingMessage: '今日も良い一日をお過ごしください。',
      dailyTry: {
        title: 'テスト用トライ',
        summary: 'テスト用の概要',
        detail: 'テスト用の詳細説明です。',
      },
      weeklyTry: undefined,
      generatedAt: new Date().toISOString(),
      timeSlot: 'morning' as const,
    };

    mockGenerateMainAdvice.mockResolvedValue(mockAdviceResponse);
  });
  it('should return health check', async () => {
    const req = new Request('http://localhost/health');
    const res = await app.request(req);

    expect(res.status).toBe(200);

    const json = await res.json();
    const parsed = HealthCheckResponseSchema.safeParse(json);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.status).toBe('ok');
      expect(parsed.data.service).toBe('tempo-ai-backend');
      expect(parsed.data.version).toBe('0.1.0');
      expect(parsed.data.timestamp).toBeTruthy();
      expect(parsed.data.environment).toBeTruthy();
    }
  });

  it('should return API info on root', async () => {
    const req = new Request('http://localhost/');
    const res = await app.request(req);

    expect(res.status).toBe(200);

    const json = await res.json();
    const parsed = ApiInfoResponseSchema.safeParse(json);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.message).toBe('Tempo AI Backend API');
      expect(parsed.data.version).toBe('0.1.0');
      expect(parsed.data.endpoints).toBeTruthy();
    }
  });

  it('should require API key for advice endpoint', async () => {
    const req = new Request('http://localhost/api/advice', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        userProfile: { nickname: 'test' },
        healthData: { date: '2025-12-10T07:00:00.000Z' },
        location: { latitude: 35.6762, longitude: 139.6503 },
        context: {
          currentTime: '2025-12-10T07:00:00.000Z',
          dayOfWeek: 'tuesday',
          isMonday: false,
          recentDailyTries: [],
        },
      }),
    });
    const res = await app.request(req);

    expect(res.status).toBe(401); // Unauthorized - authentication required

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
    expect(json.error).toBe('API key is required');
  });

  it('should return advice with valid API key', async () => {
    const req = new Request('http://localhost/api/advice', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'tempo-ai-mobile-app-key-v1',
      },
      body: JSON.stringify({
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
          date: '2025-12-10T07:00:00.000Z',
          sleep: { durationHours: 7.5, awakenings: 2 },
          morningVitals: { restingHeartRate: 62 },
          yesterdayActivity: { steps: 8520 },
        },
        location: {
          latitude: 35.6762,
          longitude: 139.6503,
          city: '東京',
        },
        context: {
          currentTime: '2025-12-10T07:00:00.000Z',
          dayOfWeek: 'tuesday',
          isMonday: false,
          recentDailyTries: [],
        },
      }),
    });
    // Cloudflare Workers environment - pass as third parameter
    const testEnv = {
      ANTHROPIC_API_KEY: 'test-claude-key',
      ENVIRONMENT: 'development' as const,
    };
    
    const res = await app.request(req, {}, testEnv);

    expect(res.status).toBe(200);
    
    const json = await res.json() as { success: boolean; data?: { greeting: string; timeSlot: string; actionSuggestions: unknown[] } };
    expect(json.success).toBe(true);
    expect(json.data).toBeTruthy();
    
    if (json.data) {
      expect(json.data.greeting).toContain('テストユーザーさん');
      expect(json.data.timeSlot).toBeTruthy();
      expect(json.data.actionSuggestions).toHaveLength(2);
    }
  });

  it('should return validation error for invalid request', async () => {
    const req = new Request('http://localhost/api/advice', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'tempo-ai-mobile-app-key-v1',
      },
      body: JSON.stringify({
        userProfile: { nickname: 'test' }, // Missing required fields
      }),
    });
    const res = await app.request(req);

    expect(res.status).toBe(400);

    const json = (await res.json()) as { success: boolean; error: string };
    expect(json.success).toBe(false);
    expect(json.error).toContain('Validation failed');
  });

  it('should handle GET request to advice endpoint info', async () => {
    const req = new Request('http://localhost/api/advice', {
      method: 'GET',
      headers: {
        'X-API-Key': 'tempo-ai-mobile-app-key-v1',
      },
    });
    const res = await app.request(req);

    expect(res.status).toBe(200);

    const json = (await res.json()) as { message: string; phase: { current: number } };
    expect(json.message).toContain('Tempo AI Advice API');
    expect(json.phase.current).toBe(9);
  });

  it('should handle CORS preflight', async () => {
    const req = new Request('http://localhost/health', {
      method: 'OPTIONS',
      headers: {
        Origin: 'http://localhost:3000',
        'Access-Control-Request-Method': 'GET',
      },
    });
    const res = await app.request(req);

    expect(res.status).toBe(204); // CORS preflight returns 204 No Content
    expect(res.headers.get('Access-Control-Allow-Origin')).toBe('http://localhost:3000');
  });

  describe('Error Handling', () => {
    it('should handle 404 for unknown routes', async () => {
      const req = new Request('http://localhost/unknown-route');
      const res = await app.request(req);

      expect(res.status).toBe(404);
    });

    it('should handle POST to health endpoint', async () => {
      const req = new Request('http://localhost/health', {
        method: 'POST',
      });
      const res = await app.request(req);

      expect(res.status).toBe(404); // Not Found - POST to health endpoint
    });

    it('should handle invalid content-type for advice endpoint', async () => {
      const req = new Request('http://localhost/api/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'text/plain',
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
        body: 'invalid body',
      });

      const testEnv = { ENVIRONMENT: 'development' as const };
      const res = await app.request(req, {}, testEnv);

      expect(res.status).toBe(400);
    });
  });

  describe('Environment Handling', () => {
    it('should work with production environment', async () => {
      const req = new Request('http://localhost/health');
      const res = await app.request(req, {}, { ENVIRONMENT: 'production' });

      expect(res.status).toBe(200);
      const json = await res.json();
      const parsed = HealthCheckResponseSchema.safeParse(json);
      
      expect(parsed.success).toBe(true);
      if (parsed.success) {
        expect(parsed.data.environment).toBe('production');
      }
    });

    it('should work with staging environment', async () => {
      const req = new Request('http://localhost/health');
      const res = await app.request(req, {}, { ENVIRONMENT: 'staging' });

      expect(res.status).toBe(200);
      const json = await res.json();
      const parsed = HealthCheckResponseSchema.safeParse(json);
      
      expect(parsed.success).toBe(true);
      if (parsed.success) {
        expect(parsed.data.environment).toBe('staging');
      }
    });
  });
});
