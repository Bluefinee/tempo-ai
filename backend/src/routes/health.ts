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
import { analyzeHealth } from '../services/ai'
import { getWeather } from '../services/weather'
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
healthRoutes.post('/analyze', async (c) => {
  try {
    console.log('Received analyze request')

    // Parse request body
    let body: AnalyzeRequest
    try {
      body = (await c.req.json()) as AnalyzeRequest
    } catch (parseError) {
      console.error('Failed to parse request body:', parseError)
      return c.json({ error: 'Invalid JSON in request body' }, 400)
    }

    // Validate required fields
    const { healthData, location, userProfile } = body

    if (!healthData || !location || !userProfile) {
      return c.json(
        {
          error: 'Missing required fields',
          required: ['healthData', 'location', 'userProfile'],
        },
        400,
      )
    }

    if (
      typeof location.latitude !== 'number' ||
      typeof location.longitude !== 'number'
    ) {
      return c.json(
        { error: 'Location must contain valid latitude and longitude numbers' },
        400,
      )
    }

    console.log('Request validation successful')
    console.log('User profile:', JSON.stringify(userProfile))
    console.log('Location:', `${location.latitude}, ${location.longitude}`)

    // Fetch weather data
    console.log('Fetching weather data...')
    const weather = await getWeather(location.latitude, location.longitude)
    console.log('Weather data retrieved successfully')

    // Get API key
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return c.json({ error: 'API configuration error' }, 500)
    }

    // Analyze with AI
    console.log('Starting AI analysis...')
    const advice = await analyzeHealth({
      healthData,
      weather,
      userProfile,
      apiKey,
    })
    console.log('AI analysis completed successfully')

    return c.json(advice)
  } catch (error) {
    console.error('Analysis error:', error)

    const { message, statusCode } = handleError(error)
    return c.json({ error: message }, statusCode as 500)
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
healthRoutes.get('/status', async (c) => {
  return c.json({
    status: 'healthy',
    service: 'Tempo AI Health Analysis',
    timestamp: new Date().toISOString(),
  })
})
