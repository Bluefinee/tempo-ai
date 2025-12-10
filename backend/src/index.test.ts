import { describe, expect, it } from 'vitest';
import app from './index';
import {
  ApiInfoResponseSchema,
  HealthCheckResponseSchema,
  PlaceholderAdviceResponseSchema,
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

  it('should handle advice endpoint placeholder', async () => {
    const req = new Request('http://localhost/api/advice');
    const res = await app.request(req);

    expect(res.status).toBe(200);

    const json = await res.json();
    const parsed = PlaceholderAdviceResponseSchema.safeParse(json);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.status).toBe('coming_soon');
      expect(parsed.data.message).toBeTruthy();
    }
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
