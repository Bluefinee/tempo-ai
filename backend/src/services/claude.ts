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
export const callClaude = async (
  params: ClaudeParams
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  if (!params.apiKey || params.apiKey === PLACEHOLDER_API_KEY) {
    throw new APIError(
      'Claude API key not configured. Please set ANTHROPIC_API_KEY environment variable.',
      500,
      'MISSING_API_KEY'
    )
  }

  try {
    const anthropic = new Anthropic({
      apiKey: params.apiKey,
      ...(params.customFetch && { fetch: params.customFetch }),
    })

    const message = await anthropic.messages.create({
      model: ANTHROPIC_MODEL,
      max_tokens: MAX_TOKENS,
      temperature: TEMPERATURE,
      system:
        'You are a health advisor that provides personalized daily health advice based on health metrics and weather conditions. Always respond in valid JSON format exactly matching the requested structure. Be specific and actionable in all recommendations.',
      messages: [
        {
          role: 'user',
          content: params.prompt,
        },
      ],
    })

    // Extract text content from response
    const textContent = message.content.find(content => content.type === 'text')
    if (!textContent || textContent.type !== 'text') {
      throw new APIError('Invalid response format from Claude API', 502, 'INVALID_AI_RESPONSE')
    }

    // 型安全なJSONパースとバリデーション
    let parsed: unknown
    try {
      parsed = JSON.parse(textContent.text)
    } catch (_parseError) {
      console.error('Failed to parse AI response. Length:', textContent.text.length)
      throw new APIError('AI response is not valid JSON', 502, 'INVALID_JSON_RESPONSE')
    }

    // Zodスキーマによる検証
    const validationResult = DailyAdviceSchema.safeParse(parsed)

    if (!validationResult.success) {
      const firstIssue = validationResult.error.issues[0]
      const field = firstIssue ? firstIssue.path.join('.') || '(root)' : '(unknown)'
      const message = firstIssue ? firstIssue.message : 'Validation failed'

      const validationMessage = `AI response missing required fields: ${message} (field: ${field})`
      throw new APIError(validationMessage, 502, 'INVALID_AI_RESPONSE_STRUCTURE')
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
      throw new APIError('Claude API rate limit exceeded', 429, 'RATE_LIMIT_EXCEEDED')
    }

    if (error instanceof Error) {
      throw new APIError(`AI analysis failed: ${error.message}`, 502, 'AI_ANALYSIS_ERROR')
    }

    throw new APIError('Unexpected error during AI analysis', 500, 'UNKNOWN_AI_ERROR')
  }
}
