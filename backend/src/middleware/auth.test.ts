// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { Hono } from 'hono';
import { validateApiKey, rateLimit } from './auth.js';

// Create a test app with auth middleware and proper error handling
const createTestApp = () => {
  const app = new Hono<{ Bindings: { ENVIRONMENT?: string } }>();
  
  // Error handling similar to main app
  app.onError((err, c) => {
    const statusCode: number =
      'statusCode' in err && typeof err.statusCode === 'number' ? err.statusCode : 500;
    const errorCode = 'code' in err && typeof err.code === 'string' ? err.code : 'INTERNAL_ERROR';

    return c.json(
      {
        success: false,
        error: err.message,
        code: errorCode,
      },
      // biome-ignore lint/suspicious/noExplicitAny: Test error handler requires flexible status code typing
      statusCode as any,
    );
  });
  
  app.use('/*', validateApiKey);
  app.use('/*', rateLimit);
  
  app.get('/test', (c) => c.json({ success: true }));
  app.post('/test', (c) => c.json({ success: true }));
  
  return app;
};

describe('Authentication Middleware', () => {
  let testApp: ReturnType<typeof createTestApp>;

  beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(console, 'log').mockImplementation(() => {
      // Mock implementation for testing
    });
    vi.spyOn(console, 'error').mockImplementation(() => {
      // Mock implementation for testing
    });
    
    testApp = createTestApp();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    // Reset environment
    // biome-ignore lint/complexity/useLiteralKeys: Environment variable requires bracket notation
    process.env['TEMPO_API_KEY'] = undefined;
  });

  describe('validateApiKey', () => {
    it('should validate correct API key successfully', async () => {
      const req = new Request('http://localhost/test', {
        headers: {
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
      });

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'development' });

      expect(res.status).toBe(200);
      const json = await res.json() as { success: boolean };
      expect(json.success).toBe(true);
    });

    it('should return 401 when API key is missing', async () => {
      const req = new Request('http://localhost/test');

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'development' });

      expect(res.status).toBe(401);
      const json = await res.json() as { success: boolean; error: string };
      expect(json.success).toBe(false);
      expect(json.error).toBe('API key is required');
    });

    it('should return 401 when API key is invalid', async () => {
      const req = new Request('http://localhost/test', {
        headers: {
          'X-API-Key': 'invalid-key',
        },
      });

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'development' });

      expect(res.status).toBe(401);
      const json = await res.json() as { success: boolean; error: string };
      expect(json.success).toBe(false);
      expect(json.error).toBe('Invalid API key');
    });

    it('should accept valid development API key', async () => {
      const req = new Request('http://localhost/test', {
        headers: {
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
      });

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'development' });

      expect(res.status).toBe(200);
    });

    it('should handle production environment configuration error', async () => {
      const req = new Request('http://localhost/test', {
        headers: {
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
      });

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'production' });

      expect(res.status).toBe(401);
      const json = await res.json() as { success: boolean; error: string };
      expect(json.error).toBe('Server configuration error');
    });
  });

  describe('rateLimit', () => {
    it('should allow requests within rate limit', async () => {
      const req = new Request('http://localhost/test', {
        headers: {
          'X-API-Key': 'tempo-ai-mobile-app-key-v1',
        },
      });

      const res = await testApp.request(req, {}, { ENVIRONMENT: 'development' });

      expect(res.status).toBe(200);
    });

  });
});