/**
 * @fileoverview Health Analysis API Routes
 *
 * ヘルスデータ分析に関連するAPIエンドポイントを定義します。
 * HealthKitデータ、位置情報、天気データを統合してAI分析を実行し、
 * パーソナライズされた健康アドバイスを提供します。
 * CLAUDE.md準拠の完全型安全実装。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { Hono } from 'hono'
import { performHealthAnalysis } from '../services/health-analysis'
import type { Bindings } from '../types/bindings'
import { AnalyzeRequestSchema } from '../types/requests'
import { handleError, toValidStatusCode } from '../utils/errors'
import {
  CommonErrors,
  createValidationErrorResponse,
  sendSuccessResponse,
} from '../utils/response'
import { isValidationSuccess, validateRequestBody } from '../utils/validation'

/**
 * ヘルス分析APIのルーターインスタンス
 */
export const healthRoutes = new Hono<{ Bindings: Bindings }>()

/**
 * POST /analyze
 *
 * ヘルスデータを分析してパーソナライズされたアドバイスを生成します。
 * HealthKitデータ、位置情報、天気データを統合してClaudeAIで分析を実行します。
 * 完全な型安全性とバリデーションを提供。
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

    // 型安全なリクエストボディ検証
    const validationResult = await validateRequestBody(c, AnalyzeRequestSchema)

    if (!isValidationSuccess(validationResult)) {
      return createValidationErrorResponse(c, validationResult.error)
    }

    const { healthData, location, userProfile } = validationResult.data

    // API key取得
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return CommonErrors.internalError(c, 'API configuration error')
    }

    // Service層呼び出し
    const advice = await performHealthAnalysis({
      healthData,
      location,
      userProfile,
      apiKey,
    })

    return sendSuccessResponse(c, advice)
  } catch (error) {
    console.error('Analysis error:', error)

    const { message, statusCode } = handleError(error)
    const validStatusCode = toValidStatusCode(statusCode)
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
  return sendSuccessResponse(c, {
    status: 'healthy',
    service: 'Tempo AI Health Analysis',
    timestamp: new Date().toISOString(),
  })
})
