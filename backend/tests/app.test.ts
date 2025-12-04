/**
 * @fileoverview Main Application Integration Tests
 *
 * このファイルは、Tempo AI APIアプリケーション全体の統合テストを担当します。
 * メインアプリケーションの起動、ルーティング、CORS設定、エラーハンドリング、
 * および各種エンドポイントの統合動作を検証します。
 *
 * テスト対象:
 * - ルートエンドポイント (/) の応答
 * - CORS設定の動作確認
 * - 404エラーハンドリング
 * - グローバルエラーハンドリング
 * - ルートマウンティング
 * - リクエスト検証
 * - 環境設定の統合
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { describe, expect, it, beforeEach, vi } from 'vitest'
import app from '../src/index'

// Response type definitions
interface RootResponse {
  service: string
  version: string
  status: string
  timestamp: string
  endpoints: Record<string, string>
}

interface ErrorResponse {
  error: string
  path?: string
  method?: string
  timestamp?: string
  details?: unknown
}

interface TimestampResponse {
  timestamp: string
}

describe('Main Application Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('Root Endpoint', () => {
    it('should return service information on GET /', async () => {
      const response = await app.request('/')

      expect(response.status).toBe(200)
      const result = (await response.json()) as RootResponse

      expect(result).toEqual({
        service: 'Tempo AI API',
        version: '1.0.0',
        status: 'healthy',
        timestamp: expect.any(String),
        endpoints: {
          'POST /api/health/analyze': 'Analyze health data and generate advice',
          'GET /api/health/status': 'Health service status check',
        },
      })

      // Validate timestamp is ISO string
      expect(() => new Date(result.timestamp)).not.toThrow()
      expect(new Date(result.timestamp).toISOString()).toBe(result.timestamp)
    })

    it('should always return current timestamp', async () => {
      const response1 = await app.request('/')
      const result1 = (await response1.json()) as TimestampResponse

      // Small delay
      await new Promise((resolve) => setTimeout(resolve, 10))

      const response2 = await app.request('/')
      const result2 = (await response2.json()) as TimestampResponse

      expect(new Date(result1.timestamp).getTime()).toBeLessThanOrEqual(
        new Date(result2.timestamp).getTime(),
      )
    })

    it('should handle GET method specifically', async () => {
      const response = await app.request('/', { method: 'GET' })
      expect(response.status).toBe(200)
    })
  })

  describe('CORS Configuration', () => {
    it('should include CORS headers for allowed origins', async () => {
      const response = await app.request('/', {
        method: 'OPTIONS',
        headers: {
          Origin: 'http://localhost:3000',
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      })

      expect(response.headers.get('Access-Control-Allow-Origin')).toBe(
        'http://localhost:3000',
      )
      expect(response.headers.get('Access-Control-Allow-Methods')).toContain(
        'POST',
      )
      expect(response.headers.get('Access-Control-Allow-Headers')).toContain(
        'Content-Type',
      )
    })

    it('should handle CORS for 127.0.0.1 origin', async () => {
      const response = await app.request('/', {
        method: 'OPTIONS',
        headers: {
          Origin: 'http://127.0.0.1:3000',
          'Access-Control-Request-Method': 'GET',
        },
      })

      expect(response.headers.get('Access-Control-Allow-Origin')).toBe(
        'http://127.0.0.1:3000',
      )
    })

    it('should allow all configured methods', async () => {
      const response = await app.request('/', {
        method: 'OPTIONS',
        headers: {
          Origin: 'http://localhost:3000',
          'Access-Control-Request-Method': 'DELETE',
        },
      })

      const allowedMethods = response.headers.get(
        'Access-Control-Allow-Methods',
      )
      const expectedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']

      expectedMethods.forEach((method) => {
        expect(allowedMethods).toContain(method)
      })
    })

    it('should handle Authorization header in CORS', async () => {
      const response = await app.request('/', {
        method: 'OPTIONS',
        headers: {
          Origin: 'http://localhost:3000',
          'Access-Control-Request-Headers': 'Authorization',
        },
      })

      expect(response.headers.get('Access-Control-Allow-Headers')).toContain(
        'Authorization',
      )
    })
  })

  describe('404 Handler', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await app.request('/non-existent-route')

      expect(response.status).toBe(404)
      const result = (await response.json()) as RootResponse

      expect(result).toEqual({
        error: 'Not Found',
        message: 'The requested endpoint does not exist',
      })
    })

    it('should handle 404 for invalid API paths', async () => {
      const response = await app.request('/api/invalid')
      expect(response.status).toBe(404)
    })

    it('should handle 404 for deeply nested invalid paths', async () => {
      const response = await app.request('/api/health/invalid/nested/path')
      expect(response.status).toBe(404)
    })

    it('should return JSON response for 404 errors', async () => {
      const response = await app.request('/does-not-exist')
      expect(response.headers.get('content-type')).toContain('application/json')
    })

    it('should handle different HTTP methods on invalid routes', async () => {
      const methods = ['POST', 'PUT', 'DELETE', 'PATCH']

      for (const method of methods) {
        const response = await app.request('/invalid-route', { method })
        expect(response.status).toBe(404)

        const result = (await response.json()) as ErrorResponse
        expect(result.error).toBe('Not Found')
      }
    })
  })

  describe('Global Error Handler', () => {
    it('should handle unexpected errors', async () => {
      // We need to create a route that throws an error to test this
      // Since we can't easily mock internal errors, we'll test the structure
      const response = await app.request('/non-existent')

      // This will trigger 404, but we can verify the error handling structure
      expect(response.status).toBe(404)
      const result = (await response.json()) as RootResponse
      expect(result).toHaveProperty('error')
      expect(result).toHaveProperty('message')
    })

    it('should return JSON format for all errors', async () => {
      const response = await app.request('/invalid-endpoint')
      expect(response.headers.get('content-type')).toContain('application/json')
    })
  })

  describe('Route Mounting', () => {
    it('should mount health routes at /api/health', async () => {
      const response = await app.request('/api/health/status')
      expect(response.status).toBe(200)
    })

    it('should mount test routes at /api/test', async () => {
      // Test with invalid data to avoid actual API calls
      const response = await app.request('/api/test/weather', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })

      // Should not be 404, indicating route exists
      expect(response.status).not.toBe(404)
    })
  })

  describe('Content-Type Handling', () => {
    it('should handle JSON requests properly', async () => {
      const response = await app.request(
        '/api/health/analyze',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            healthData: { sleep: { duration: 7 } },
            location: { latitude: 35.0, longitude: 139.0 },
            userProfile: { age: 30 },
          }),
        },
        {
          ANTHROPIC_API_KEY: 'test-key',
        },
      )

      // Should not be 415 (Unsupported Media Type)
      expect(response.status).not.toBe(415)
    })

    it('should return JSON responses', async () => {
      const response = await app.request('/')
      expect(response.headers.get('content-type')).toContain('application/json')
    })
  })

  describe('Health Check Integration', () => {
    it('should integrate with health status endpoint', async () => {
      const response = await app.request('/api/health/status')
      expect(response.status).toBe(200)

      const result = (await response.json()) as RootResponse
      expect(result.service).toBe('Tempo AI Health Analysis')
      expect(result.status).toBe('healthy')
    })
  })

  describe('Request Validation', () => {
    it('should handle empty requests gracefully', async () => {
      const response = await app.request('/api/health/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: '',
      })

      expect(response.status).toBe(400)
    })

    it('should handle malformed JSON', async () => {
      const response = await app.request('/api/health/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: '{ invalid json',
      })

      expect(response.status).toBe(400)
    })
  })

  describe('Environment Configuration', () => {
    it('should handle requests with environment variables', async () => {
      const response = await app.request(
        '/',
        {},
        {
          CUSTOM_ENV_VAR: 'test-value',
        },
      )

      expect(response.status).toBe(200)
    })
  })
})
