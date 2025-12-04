/**
 * @fileoverview AI Analysis Service
 *
 * Claude AIを使用したヘルスデータ分析サービス。
 * HealthKitデータ、天気情報、ユーザープロファイルを統合して
 * パーソナライズされた健康アドバイスを生成します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import Anthropic from '@anthropic-ai/sdk'
import type { DailyAdvice } from '../types/advice'
import type { HealthData, UserProfile } from '../types/health'
import type { WeatherData } from '../types/weather'
import { APIError } from '../utils/errors'
import { buildPrompt } from '../utils/prompts'

/**
 * AI分析関数のパラメータ型定義
 */
interface AnalyzeParams {
  /** HealthKitから取得したヘルスデータ */
  healthData: HealthData
  /** Open-Meteoから取得した天気データ */
  weather: WeatherData
  /** ユーザープロファイル情報 */
  userProfile: UserProfile
  /** Anthropic Claude APIキー */
  apiKey: string
  /** カスタムfetch関数（テスト用） */
  customFetch?: typeof fetch
}

/**
 * ヘルスデータをAI分析してパーソナライズされたアドバイスを生成
 *
 * HealthKitデータ、天気情報、ユーザープロファイルを統合してClaude AIで分析し、
 * その日の健康に関する具体的で実行可能なアドバイスを提供します。
 *
 * @param params - 分析に必要なパラメータ
 * @param params.healthData - HealthKitから取得したヘルスメトリクス
 * @param params.weather - 現在位置の天気データ
 * @param params.userProfile - ユーザーの基本情報
 * @param params.apiKey - Anthropic Claude APIキー
 * @param params.customFetch - テスト用のカスタムfetch関数
 * @returns パーソナライズされた健康アドバイス
 * @throws {APIError} APIキーが無効またはClaude API呼び出しエラー
 * @throws {APIError} AI応答が無効な形式の場合
 * @throws {APIError} レート制限に達した場合
 */
export const analyzeHealth = async (
  params: AnalyzeParams,
): Promise<DailyAdvice> => {
  if (
    !params.apiKey ||
    params.apiKey === 'sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  ) {
    throw new APIError(
      'Claude API key not configured. Please set ANTHROPIC_API_KEY environment variable.',
      500,
      'MISSING_API_KEY',
    )
  }

  try {
    const anthropic = new Anthropic({
      apiKey: params.apiKey,
      ...(params.customFetch && { fetch: params.customFetch }),
    })

    const prompt = buildPrompt(params)

    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 4000,
      temperature: 0.7,
      system:
        'You are a health advisor that provides personalized daily health advice based on health metrics and weather conditions. Always respond in valid JSON format exactly matching the requested structure. Be specific and actionable in all recommendations.',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
    })

    // Extract text content from response
    const textContent = message.content.find(
      (content) => content.type === 'text',
    )
    if (!textContent || textContent.type !== 'text') {
      throw new APIError(
        'Invalid response format from Claude API',
        502,
        'INVALID_AI_RESPONSE',
      )
    }

    // Parse JSON response
    let advice: DailyAdvice
    try {
      advice = JSON.parse(textContent.text) as DailyAdvice
    } catch (_parseError) {
      console.error('Failed to parse AI response:', textContent.text)
      throw new APIError(
        'AI response is not valid JSON',
        502,
        'INVALID_JSON_RESPONSE',
      )
    }

    // Validate required fields
    if (
      !advice.theme ||
      !advice.summary ||
      !advice.breakfast ||
      !advice.exercise
    ) {
      throw new APIError(
        'AI response missing required fields',
        502,
        'INCOMPLETE_AI_RESPONSE',
      )
    }

    return advice
  } catch (error) {
    if (error instanceof APIError) {
      throw error
    }

    if (error instanceof Error) {
      // Check for specific Anthropic errors
      if (error.message.includes('authentication')) {
        throw new APIError('Invalid Claude API key', 401, 'INVALID_API_KEY')
      }

      if (
        error.message.includes('quota') ||
        error.message.includes('rate limit')
      ) {
        throw new APIError(
          'Claude API rate limit exceeded',
          429,
          'RATE_LIMIT_EXCEEDED',
        )
      }

      throw new APIError(
        `AI analysis failed: ${error.message}`,
        502,
        'AI_ANALYSIS_ERROR',
      )
    }

    throw new APIError(
      'Unexpected error during AI analysis',
      500,
      'UNKNOWN_AI_ERROR',
    )
  }
}
