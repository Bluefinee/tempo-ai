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

/**
 * Cloudflare Workers 環境変数の型定義
 */
type Bindings = {
  /** Anthropic Claude API キー */
  ANTHROPIC_API_KEY: string
}

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
app.route('/api/test', testRoutes)

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
  console.error('Unhandled error:', err)

  return c.json(
    {
      success: false,
      error: 'Internal Server Error - An unexpected error occurred',
    },
    500,
  )
})

export default app
