/**
 * @fileoverview Main Application Entry Point
 *
 * Tempo AI API のメインアプリケーションファイル。
 * Hono フレームワークを使用してAPI サーバーを構築し、
 * CORS 設定、ルーティング、エラーハンドリングを管理します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { healthRoutes } from './routes/health'
import { testRoutes } from './routes/test'
import type { Bindings } from './types/bindings'
import { handleError, toValidStatusCode } from './utils/errors'

/**
 * メインアプリケーションインスタンス
 * Hono フレームワークを使用してAPI サーバーを構築
 */
const app = new Hono<{ Bindings: Bindings }>()

// CORS configuration
app.use(
  '/*',
  cors({
    origin: ['http://localhost:3000', 'http://127.0.0.1:3000'],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
  }),
)

// Health routes
app.route('/api/health', healthRoutes)

// Test routes (development only)
// biome-ignore lint/complexity/useLiteralKeys: TypeScript strict mode requires bracket notation for process.env
const nodeEnv = process.env['NODE_ENV'] || 'development'
if (nodeEnv !== 'production') {
  app.route('/api/test', testRoutes)
}

// Root endpoint
app.get('/', (c): Response => {
  return c.json({
    success: true,
    data: {
      service: 'Tempo AI API',
      version: '1.0.0',
      status: 'healthy',
      timestamp: new Date().toISOString(),
      endpoints: {
        'POST /api/health/analyze': 'Analyze health data and generate advice',
        'GET /api/health/status': 'Health service status check',
      },
    },
  })
})

// 404 handler
app.notFound((c): Response => {
  return c.json(
    {
      success: false,
      error: 'Not Found - The requested endpoint does not exist',
    },
    404,
  )
})

// Global error handler
app.onError((err, c): Response => {
  const { message, statusCode } = handleError(err)
  const validStatusCode = toValidStatusCode(statusCode)

  return c.json(
    {
      success: false,
      error: message,
    },
    validStatusCode,
  )
})

export { app }
export default app
