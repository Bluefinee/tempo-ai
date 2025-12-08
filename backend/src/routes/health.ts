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
import { z } from 'zod'
import {
  AnalysisType,
  type ComprehensiveAnalysisRequest,
  claudeAnalysisService,
} from '../services/claude-analysis'
import { EnhancedAIAnalysisService } from '../services/enhanced-ai-analysis'
import { validateAIAnalysisRequest } from '../types/ai-analysis'
import { performHealthAnalysis } from '../services/health-analysis'
import type { Bindings } from '../types/bindings'
import { HealthDataSchema, UserProfileSchema } from '../types/health'
import { AnalyzeRequestSchema } from '../types/requests'
import { WeatherDataSchema } from '../types/weather'
import { handleError } from '../utils/errors'
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
    // Direct status code approach
    if (statusCode >= 500) {
      return c.json({ success: false, error: message }, 500)
    }
    return c.json({ success: false, error: message }, 400)
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

// Comprehensive Analysis Request Schema
const ComprehensiveAnalysisRequestSchema = z.object({
  healthData: HealthDataSchema,
  userProfile: UserProfileSchema,
  weatherData: WeatherDataSchema.optional(),
  analysisType: z.nativeEnum(AnalysisType),
  language: z.enum(['japanese', 'english']),
  userContext: z
    .object({
      timeOfDay: z.enum(['morning', 'afternoon', 'evening', 'night']),
      engagementLevel: z.enum(['high', 'medium', 'low']),
      timeSinceLastAnalysis: z.number().optional(),
      specificConcerns: z.array(z.string()).optional(),
    })
    .optional(),
})

// Quick Analysis Request Schema
const QuickAnalysisRequestSchema = z.object({
  healthData: HealthDataSchema,
  userProfile: UserProfileSchema,
  language: z.enum(['japanese', 'english']),
})

/**
 * POST /ai/analyze-comprehensive
 *
 * 包括的なAI健康分析を実行します。
 * 健康データ、環境データ、ユーザーコンテキストを統合して
 * 詳細なパーソナライズされた健康分析を提供します。
 *
 * @param healthData - 包括的な健康データ
 * @param userProfile - ユーザープロファイル
 * @param weatherData - 環境データ（オプション）
 * @param analysisType - 分析タイプ
 * @param language - 言語設定
 * @param userContext - ユーザーコンテキスト（オプション）
 * @returns 包括的AI健康分析結果
 * @throws {400} リクエストが無効な場合
 * @throws {429} レート制限に達した場合
 * @throws {500} AI分析エラー
 */
healthRoutes.post('/ai/analyze-comprehensive', async (c): Promise<Response> => {
  try {
    console.log('Received comprehensive AI analysis request')

    // 型安全なリクエストボディ検証
    const validationResult = await validateRequestBody(
      c,
      ComprehensiveAnalysisRequestSchema,
    )

    if (!isValidationSuccess(validationResult)) {
      return createValidationErrorResponse(c, validationResult.error)
    }

    const request = validationResult.data as ComprehensiveAnalysisRequest

    // API key取得
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return CommonErrors.internalError(c, 'API configuration error')
    }

    // 包括的AI分析実行
    const insights = await claudeAnalysisService.analyzeComprehensiveHealth(
      request,
      apiKey,
    )

    return sendSuccessResponse(c, insights)
  } catch (error) {
    console.error('Comprehensive AI analysis error:', error)

    const { message, statusCode } = handleError(error)

    if (statusCode === 429) {
      return c.json(
        {
          success: false,
          error: 'Rate limit exceeded. Please try again later.',
          retryAfter: 3600,
        },
        429,
      )
    }

    if (statusCode >= 500) {
      return c.json({ success: false, error: message }, 500)
    }
    return c.json({ success: false, error: message }, 400)
  }
})

/**
 * POST /ai/quick-analyze
 *
 * クイックAI健康分析を実行します。
 * 基本的な健康データから迅速な洞察を提供します。
 *
 * @param healthData - 基本的な健康データ
 * @param userProfile - ユーザープロファイル
 * @param language - 言語設定
 * @returns クイックAI健康分析結果
 * @throws {400} リクエストが無効な場合
 * @throws {429} レート制限に達した場合
 * @throws {500} AI分析エラー
 */
healthRoutes.post('/ai/quick-analyze', async (c): Promise<Response> => {
  try {
    console.log('Received quick AI analysis request')

    // 型安全なリクエストボディ検証
    const validationResult = await validateRequestBody(
      c,
      QuickAnalysisRequestSchema,
    )

    if (!isValidationSuccess(validationResult)) {
      return createValidationErrorResponse(c, validationResult.error)
    }

    const { healthData, userProfile, language } = validationResult.data

    // API key取得
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return CommonErrors.internalError(c, 'API configuration error')
    }

    // クイックAI分析実行
    const insights = await claudeAnalysisService.analyzeQuick(
      { healthData, userProfile, language },
      apiKey,
    )

    return sendSuccessResponse(c, insights)
  } catch (error) {
    console.error('Quick AI analysis error:', error)

    const { message, statusCode } = handleError(error)

    if (statusCode === 429) {
      return c.json(
        {
          success: false,
          error: 'Rate limit exceeded. Please try again later.',
          retryAfter: 1800,
        },
        429,
      )
    }

    if (statusCode >= 500) {
      return c.json({ success: false, error: message }, 500)
    }
    return c.json({ success: false, error: message }, 400)
  }
})

/**
 * POST /ai/focus-analysis
 *
 * 関心分野に特化したAI分析を実行します。
 * フォーカスタグに基づく専門的な分析と「今日のトライ」提案を生成します。
 *
 * @param request - AI分析リクエスト（フォーカスタグ含む）
 * @returns 関心分野別AI分析結果
 * @throws {400} リクエストが無効な場合
 * @throws {500} AI分析エラー
 */
healthRoutes.post('/ai/focus-analysis', async (c): Promise<Response> => {
  try {
    console.log('Received focus area AI analysis request')

    // リクエストボディ取得と検証
    const body = await c.req.json()
    const request = validateAIAnalysisRequest(body)

    // API key取得
    const apiKey = c.env.ANTHROPIC_API_KEY
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not found in environment')
      return CommonErrors.internalError(c, 'API configuration error')
    }

    // 拡張AI分析実行
    const enhancedService = new EnhancedAIAnalysisService()
    const analysis = await enhancedService.generateFocusAreaAnalysis(request, apiKey)

    return sendSuccessResponse(c, analysis)
  } catch (error) {
    console.error('Focus area AI analysis error:', error)

    const { message, statusCode } = handleError(error)
    
    if (statusCode >= 500) {
      return c.json({ success: false, error: message }, 500)
    }
    return c.json({ success: false, error: message }, 400)
  }
})

/**
 * GET /ai/health-check
 *
 * AI分析サービスの可用性をチェックします。
 * Claude APIとの接続状態とサービス稼働状況を確認します。
 *
 * @returns AI分析サービスの状態情報
 */
healthRoutes.get('/ai/health-check', async (c): Promise<Response> => {
  try {
    // API key確認
    const apiKey = c.env.ANTHROPIC_API_KEY
    const hasValidApiKey =
      !!apiKey && apiKey !== 'sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

    // サービス状態情報
    const healthStatus = {
      status: hasValidApiKey ? 'healthy' : 'degraded',
      service: 'Claude AI Analysis Service',
      timestamp: new Date().toISOString(),
      capabilities: {
        comprehensiveAnalysis: hasValidApiKey,
        quickAnalysis: hasValidApiKey,
        rateLimiting: true,
        multiLanguage: true,
      },
      version: '2.0.0',
      apiKeyStatus: hasValidApiKey ? 'configured' : 'missing',
    }

    const statusCode = hasValidApiKey ? 200 : 503
    return c.json({ success: true, data: healthStatus }, statusCode)
  } catch (error) {
    console.error('AI health check error:', error)
    return c.json(
      {
        success: false,
        error: 'Health check failed',
        timestamp: new Date().toISOString(),
      },
      500,
    )
  }
})
