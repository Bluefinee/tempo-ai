import { describe, expect, it } from 'vitest';
import app from './index';
import {
  ApiInfoResponseSchema,
  HealthCheckResponseSchema,
  AdviceResponseSchema,
} from './types/response';

describe('Tempo AI Backend', () => {
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

    expect(res.status).toBe(500); // Error handled by onError hook
    
    const json = await res.json() as { success: boolean; error: string };
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
    const res = await app.request(req);

    expect(res.status).toBe(200);

    const json = await res.json();
    const parsed = AdviceResponseSchema.safeParse(json);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.success).toBe(true);
      expect(parsed.data.data?.mainAdvice).toBeTruthy();
      expect(parsed.data.data?.mainAdvice.greeting).toContain('テストユーザーさん');
      expect(parsed.data.data?.mainAdvice.timeSlot).toBeTruthy();
      expect(parsed.data.data?.mainAdvice.actionSuggestions).toHaveLength(2);
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

    const json = await res.json() as { success: boolean; error: string };
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

    const json = await res.json() as { message: string; phase: { current: number } };
    expect(json.message).toContain('Tempo AI Advice API');
    expect(json.phase.current).toBe(7);
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
});
