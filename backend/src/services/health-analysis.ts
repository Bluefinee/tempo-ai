/**
 * @fileoverview Health Analysis Service
 *
 * ヘルスデータ分析のビジネスロジックを統合するサービス層。
 * Route層からビジネスロジックを分離し、責務を明確化します。
 *
 * CLAUDE.md準拠：Service層分離、型安全性、DRY原則
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { DailyAdvice } from '../types/advice'
import type { HealthData, UserProfile } from '../types/health'
import { APIError } from '../utils/errors'
import { analyzeHealth } from './ai'
import { getWeather } from './weather'

/**
 * ヘルスデータ分析のパラメータ型定義
 *
 * @interface AnalyzeHealthParams
 */
export interface AnalyzeHealthParams {
  /** HealthKitから取得したヘルスデータ */
  healthData: HealthData
  /** ユーザーの位置情報 */
  location: {
    latitude: number
    longitude: number
  }
  /** ユーザープロファイル情報 */
  userProfile: UserProfile
  /** Anthropic Claude APIキー */
  apiKey: string
}

/**
 * 座標バリデーション関数
 *
 * @param latitude - 緯度
 * @param longitude - 経度
 * @throws {APIError} 座標が有効範囲外の場合
 */
const validateCoordinates = (latitude: number, longitude: number): void => {
  if (
    typeof latitude !== 'number' ||
    typeof longitude !== 'number' ||
    Number.isNaN(latitude) ||
    Number.isNaN(longitude) ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180
  ) {
    throw new APIError(
      'Invalid coordinates: latitude must be -90 to 90, longitude must be -180 to 180',
      400,
      'INVALID_COORDINATES',
    )
  }
}

/**
 * ヘルスデータを統合分析してパーソナライズされたアドバイスを生成
 *
 * バリデーション、天気データ取得、AI分析の全ビジネスロジックを統合し、
 * Route層から完全に分離された責務を持ちます。
 *
 * @param params - 分析に必要なパラメータ
 * @returns パーソナライズされたヘルスアドバイス
 * @throws {APIError} バリデーションエラー、天気API エラー、AI分析エラー
 */
export const performHealthAnalysis = async (
  params: AnalyzeHealthParams,
): Promise<DailyAdvice> => {
  // 座標バリデーション
  validateCoordinates(params.location.latitude, params.location.longitude)

  // 天気データ取得
  const weather = await getWeather(
    params.location.latitude,
    params.location.longitude,
  )

  // AI分析実行
  const advice = await analyzeHealth({
    healthData: params.healthData,
    weather,
    userProfile: params.userProfile,
    apiKey: params.apiKey,
  })

  return advice
}
