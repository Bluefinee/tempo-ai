/**
 * @fileoverview Health Advice Domain Service
 *
 * ヘルスケアアドバイス生成のドメインロジックを担当するサービス。
 * Claude APIとの統合は行わず、純粋にヘルスケア分析のビジネスロジックに特化。
 * プロンプト生成からAI応答処理まで、ヘルスケア関連の責務を統合します。
 *
 * CLAUDE.md準拠：単一責務原則、ドメイン分離、型安全性
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { z } from 'zod'
import type { DailyAdviceSchema } from '../types/advice'
import type { HealthData, UserProfile } from '../types/health'
import type { WeatherData } from '../types/weather'
import { APIError } from '../utils/errors'
import { buildPrompt } from '../utils/prompts'
import { callClaude } from './claude'

/**
 * ヘルスアドバイス生成関数のパラメータ型定義
 */
export interface HealthAdviceParams {
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
 * ヘルスケアドメイン固有の入力バリデーション
 *
 * @param params - バリデーション対象のパラメータ
 * @throws {APIError} 必須フィールドが不足している場合
 */
const validateHealthAdviceInputs = (params: HealthAdviceParams): void => {
  if (!params.healthData) {
    throw new APIError('Health data is required', 400, 'MISSING_HEALTH_DATA')
  }

  if (!params.weather) {
    throw new APIError('Weather data is required', 400, 'MISSING_WEATHER_DATA')
  }

  if (!params.userProfile) {
    throw new APIError('User profile is required', 400, 'MISSING_USER_PROFILE')
  }

  if (!params.apiKey || params.apiKey.trim() === '') {
    throw new APIError('API key is required', 400, 'MISSING_API_KEY')
  }
}

/**
 * ヘルスデータをAI分析してパーソナライズされたアドバイスを生成
 *
 * HealthKitデータ、天気情報、ユーザープロファイルを統合してプロンプトを構築し、
 * Claude AIで分析して具体的で実行可能な健康アドバイスを提供します。
 *
 * @param params - 分析に必要なパラメータ
 * @param params.healthData - HealthKitから取得したヘルスメトリクス
 * @param params.weather - 現在位置の天気データ
 * @param params.userProfile - ユーザーの基本情報
 * @param params.apiKey - Anthropic Claude APIキー
 * @param params.customFetch - テスト用のカスタムfetch関数
 * @returns パーソナライズされた健康アドバイス
 * @throws {APIError} 入力バリデーションエラー
 * @throws {APIError} プロンプト生成エラー
 * @throws {APIError} Claude API呼び出しエラー
 */
export const generateHealthAdvice = async (
  params: HealthAdviceParams,
): Promise<z.infer<typeof DailyAdviceSchema>> => {
  // ドメイン固有のバリデーション
  validateHealthAdviceInputs(params)

  try {
    // ヘルスケア専用プロンプト生成
    const prompt = buildPrompt({
      healthData: params.healthData,
      weather: params.weather,
      userProfile: params.userProfile,
    })

    // Claude API呼び出し（統合サービス経由）
    const claudeParams: {
      prompt: string
      apiKey: string
      customFetch?: typeof fetch
    } = {
      prompt,
      apiKey: params.apiKey,
    }

    if (params.customFetch) {
      claudeParams.customFetch = params.customFetch
    }

    const advice = await callClaude(claudeParams)

    return advice
  } catch (error) {
    // エラーハンドリング: 既存のAPIErrorはそのまま再スロー
    if (error instanceof APIError) {
      throw error
    }

    // 予期しないエラーをAPIErrorでラップ
    throw new APIError(
      `Health advice generation failed: ${
        error instanceof Error ? error.message : 'Unknown error'
      }`,
      500,
      'HEALTH_ADVICE_GENERATION_ERROR',
    )
  }
}
