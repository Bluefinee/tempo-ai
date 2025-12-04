/**
 * @fileoverview Health Analysis API Routes
 *
 * ヘルスデータ分析に関連するAPIエンドポイントを定義します。
 * HealthKitデータ、位置情報、天気データを統合してAI分析を実行し、
 * パーソナライズされた健康アドバイスを提供します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { Hono } from 'hono'
import { performHealthAnalysis } from '../services/health-analysis'
import type { HealthData, UserProfile } from '../types/health'
import { handleError } from '../utils/errors'

/**
 * Cloudflare Workers環境変数の型定義
 */
type Bindings = {
  /** Anthropic Claude API キー */
  ANTHROPIC_API_KEY: string
}

/**
 * ヘルス分析APIのルーターインスタンス
 */
export const healthRoutes = new Hono<{ Bindings: Bindings }>()

/**
 * ヘルス分析リクエストの型定義
 */
interface AnalyzeRequest {
  /** HealthKitから取得したヘルスデータ */
  healthData: HealthData
  /** GPS位置情報 */
  location: {
    /** 緯度 */
    latitude: number
    /** 経度 */
    longitude: number
  }
  /** ユーザープロファイル情報 */
  userProfile: UserProfile
}

/**
 * POST /analyze
 *
 * ヘルスデータを分析してパーソナライズされたアドバイスを生成します。
 * HealthKitデータ、位置情報、天気データを統合してClaudeAIで分析を実行します。
 *
 * @param healthData - HealthKitから取得したヘルスデータ
 * @param location - GPS位置情報（緯度・経度）
 * @param userProfile - ユーザープロファイル情報
 * @returns AIが生成した健康アドバイス
 * @throws {400} リクエストが無効な場合
 * @throws {500} API設定エラーまたは内部エラー
 */
healthRoutes.post('/analyze', async (c): Promise<Response> => {
  try {
    console.log('Received analyze request')

    // Parse request body
    let body: AnalyzeRequest
    try {
      body = (await c.req.json()) as AnalyzeRequest
    } catch (parseError) {
      console.error('Failed to parse request body:', parseError)
      return c.json(
        { success: false, error: 'Invalid JSON in request body' },
        400,
      )
    }

    // Validate required fields
    const { healthData, location, userProfile } = body

    if (!healthData || !location || !userProfile) {
      return c.json(
        {
          success: false,
          error: 'Missing required fields: healthData, location, userProfile',
        },
        400,
      )
    }

    // Validate location coordinates type and range
    if (
      typeof location.latitude !== 'number' ||
      typeof location.longitude !== 'number' ||
      location.latitude < -90 ||
      location.latitude > 90 ||
      location.longitude < -180 ||
      location.longitude > 180 ||
      Number.isNaN(location.latitude) ||
      Number.isNaN(location.longitude)
    ) {
      return c.json(
        {
          success: false,
          error:
            'Invalid coordinates: latitude must be -90 to 90, longitude must be -180 to 180',
        },
        400,
      )
    }

    // API key取得
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return c.json(
        {
          success: false,
          error: 'API configuration error',
        },
        500,
      )
    }

    // Service層呼び出し
    const advice = await performHealthAnalysis({
      healthData,
      location,
      userProfile,
      apiKey,
    })

    return c.json({
      success: true,
      data: advice,
    })
  } catch (error) {
    console.error('Analysis error:', error)

    const { message, statusCode } = handleError(error)
    // Ensure statusCode is a valid HTTP status code and cast to proper type
    const validStatusCode = (
      statusCode >= 400 && statusCode <= 599 ? statusCode : 500
    ) as 400 | 401 | 403 | 404 | 409 | 422 | 429 | 500 | 502 | 503 | 504
    return c.json(
      {
        success: false,
        error: message,
      },
      validStatusCode,
    )
  }
})

/**
 * GET /status
 *
 * ヘルス分析サービスの状態を確認します。
 * サービスが正常に動作しているかを確認するためのヘルスチェックエンドポイントです。
 *
 * @returns サービスの状態情報とタイムスタンプ
 */
healthRoutes.get('/status', async (c): Promise<Response> => {
  return c.json({
    success: true,
    data: {
      status: 'healthy',
      service: 'Tempo AI Health Analysis',
      timestamp: new Date().toISOString(),
    },
  })
})
