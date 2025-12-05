/**
 * @fileoverview Claude API Integration Service
 *
 * Anthropic Claude API専用の統合サービス。
 * プロンプトを受け取ってClaude APIに送信し、レスポンスを処理します。
 * ヘルスケアドメインロジックは別サービスに分離されています。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import Anthropic from '@anthropic-ai/sdk'
import type { z } from 'zod'
import { DailyAdviceSchema } from '../types/advice'
import { APIError } from '../utils/errors'
import type { LocalizationContext } from '../utils/localization'
import {
  claudeErrorMessages,
  createDefaultLocalizationContext,
  getLocalizedMessage,
} from '../utils/localization'

// 型安全なJSONパース処理は直接実装（Zodスキーマとの統合）

// AI設定定数
const ANTHROPIC_MODEL = 'claude-sonnet-4-20250514'
const PLACEHOLDER_API_KEY = 'sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
const MAX_TOKENS = 4000
const TEMPERATURE = 0.3 // Lower temperature for consistent JSON output

/**
 * Claude API呼び出し関数のパラメータ型定義
 */
interface ClaudeParams {
  /** Claude APIに送信するプロンプト */
  prompt: string
  /** Anthropic Claude APIキー */
  apiKey: string
  /** カスタムfetch関数（テスト用） */
  customFetch?: typeof fetch
  /** 多言語化コンテキスト */
  localizationContext?: LocalizationContext
}

/**
 * Claude APIにプロンプトを送信してDailyAdviceを生成
 *
 * プロンプト文字列を受け取ってClaude APIに送信し、
 * 構造化されたDailyAdviceレスポンスを返します。
 *
 * @param params - Claude API呼び出しに必要なパラメータ
 * @param params.prompt - Claude APIに送信するプロンプト文字列
 * @param params.apiKey - Anthropic Claude APIキー
 * @param params.customFetch - テスト用のカスタムfetch関数
 * @returns パーソナライズされた健康アドバイス
 * @throws {APIError} APIキーが無効またはClaude API呼び出しエラー
 * @throws {APIError} AI応答が無効な形式の場合
 * @throws {APIError} レート制限に達した場合
 */
/**
 * リトライオプション型定義
 */
interface RetryOptions {
  /** 最大リトライ回数 */
  maxRetries?: number
  /** タイムアウト時間（ミリ秒） */
  timeout?: number
}

/**
 * リトライロジック付きのClaude API呼び出し関数
 *
 * 指数バックオフによるリトライ機能とタイムアウト処理を提供します。
 * 一時的なエラーに対して自動的にリトライを行い、テスト安定性を向上させます。
 *
 * @param params - Claude API呼び出しパラメータ
 * @param options - リトライオプション
 * @returns パーソナライズされた健康アドバイス
 * @throws {APIError} 最大リトライ回数に達した場合
 * @throws {APIError} タイムアウトに達した場合
 */
export const generateAdviceWithRetry = async (
  params: ClaudeParams,
  options: RetryOptions = {},
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  const { maxRetries = 3, timeout = 15000 } = options

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await callClaudeAPIWithTimeout(params, timeout)
      return response
    } catch (error) {
      if (attempt === maxRetries || !isRetryableError(error)) {
        throw error
      }

      const backoffDelay = calculateExponentialBackoff(attempt)
      await new Promise((resolve) => setTimeout(resolve, backoffDelay))
    }
  }

  // This should never be reached, but TypeScript requires it
  throw new APIError('Max retries exceeded', 500, 'MAX_RETRIES_EXCEEDED')
}

/**
 * タイムアウト付きClaude API呼び出し
 */
const callClaudeAPIWithTimeout = async (
  params: ClaudeParams,
  timeout: number,
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  return Promise.race([
    callClaude(params),
    new Promise<never>((_, reject) =>
      setTimeout(
        () =>
          reject(
            new APIError(
              `Request timed out after ${timeout}ms`,
              408,
              'TIMEOUT_ERROR',
            ),
          ),
        timeout,
      ),
    ),
  ])
}

/**
 * エラーがリトライ可能かどうかを判定
 */
const isRetryableError = (error: unknown): boolean => {
  if (error instanceof APIError) {
    return (
      error.code === 'INVALID_JSON_RESPONSE' ||
      error.code === 'TIMEOUT_ERROR' ||
      error.code === 'AI_ANALYSIS_ERROR' ||
      error.code === 'RATE_LIMIT_EXCEEDED'
    )
  }
  return false
}

/**
 * 指数バックオフ遅延時間計算
 */
const calculateExponentialBackoff = (attempt: number): number => {
  const baseDelay = 1000 // 1秒
  const maxDelay = 10000 // 10秒
  const delay = Math.min(baseDelay * 2 ** (attempt - 1), maxDelay)
  const jitter = Math.random() * 0.3 * delay // 30%のジッター
  return delay + jitter
}

/**
 * 多言語化されたシステムプロンプトを生成
 */
const generateLocalizedSystemPrompt = (
  context: LocalizationContext,
): string => {
  const { language, culturalContext } = context

  if (language === 'ja') {
    return `あなたは健康アドバイザーです。健康指標と天気条件に基づいて、パーソナライズされた日々の健康アドバイスを提供します。

重要な指示：
- 常に有効なJSON形式で応答してください
- 要求された構造に正確に一致させてください
- 全ての推奨事項は具体的で実行可能にしてください
- ${culturalContext?.formalityLevel === 'casual' ? 'フレンドリーで親しみやすい' : '丁寧で専門的な'}トーンを使用してください
- 日本の文化と生活様式を考慮してください
- 食事時間: 朝食${culturalContext?.mealTimes.breakfast || '07:00'}、昼食${culturalContext?.mealTimes.lunch || '12:00'}、夕食${culturalContext?.mealTimes.dinner || '19:00'}を基準にしてください`
  } else {
    return `You are a health advisor that provides personalized daily health advice based on health metrics and weather conditions.

Important instructions:
- Always respond in valid JSON format exactly matching the requested structure
- Be specific and actionable in all recommendations
- Use a ${culturalContext?.formalityLevel === 'formal' ? 'professional and formal' : 'friendly and approachable'} tone
- Consider Western lifestyle and cultural preferences
- Base meal recommendations around: breakfast ${culturalContext?.mealTimes.breakfast || '08:00'}, lunch ${culturalContext?.mealTimes.lunch || '12:30'}, dinner ${culturalContext?.mealTimes.dinner || '18:30'}`
  }
}

export const callClaude = async (
  params: ClaudeParams,
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  if (!params.apiKey || params.apiKey === PLACEHOLDER_API_KEY) {
    const localizationContext =
      params.localizationContext ?? createDefaultLocalizationContext()
    const errorMessage = getLocalizedMessage(
      claudeErrorMessages.apiKeyMissing,
      localizationContext.language,
    )
    throw new APIError(errorMessage, 500, 'MISSING_API_KEY')
  }

  try {
    const anthropic = new Anthropic({
      apiKey: params.apiKey,
      ...(params.customFetch && { fetch: params.customFetch }),
    })

    // 多言語化されたシステムプロンプトを生成
    const localizationContext =
      params.localizationContext ?? createDefaultLocalizationContext()
    const systemPrompt = generateLocalizedSystemPrompt(localizationContext)

    const message = await anthropic.messages.create({
      model: ANTHROPIC_MODEL,
      max_tokens: MAX_TOKENS,
      temperature: TEMPERATURE,
      system: systemPrompt,
      messages: [
        {
          role: 'user',
          content: params.prompt,
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

    // 型安全なJSONパースとバリデーション
    let parsed: unknown
    try {
      parsed = JSON.parse(textContent.text)
    } catch (_parseError) {
      console.error(
        'Failed to parse AI response. Length:',
        textContent.text.length,
      )
      throw new APIError(
        'AI response is not valid JSON',
        502,
        'INVALID_JSON_RESPONSE',
      )
    }

    // Zodスキーマによる検証
    const validationResult = DailyAdviceSchema.safeParse(parsed)

    if (!validationResult.success) {
      const firstIssue = validationResult.error.issues[0]
      const field = firstIssue
        ? firstIssue.path.join('.') || '(root)'
        : '(unknown)'
      const message = firstIssue ? firstIssue.message : 'Validation failed'

      const validationMessage = `AI response missing required fields: ${message} (field: ${field})`
      throw new APIError(
        validationMessage,
        502,
        'INVALID_AI_RESPONSE_STRUCTURE',
      )
    }

    return validationResult.data
  } catch (error) {
    if (error instanceof APIError) {
      throw error
    }

    // Check for specific Anthropic SDK errors
    if (error instanceof Anthropic.AuthenticationError) {
      throw new APIError('Invalid Claude API key', 401, 'INVALID_API_KEY')
    }

    if (error instanceof Anthropic.RateLimitError) {
      throw new APIError(
        'Claude API rate limit exceeded',
        429,
        'RATE_LIMIT_EXCEEDED',
      )
    }

    if (error instanceof Error) {
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
