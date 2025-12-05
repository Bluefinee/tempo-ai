/**
 * @fileoverview API Request Type Definitions
 *
 * API エンドポイントで使用されるリクエスト型の定義。
 * Zodスキーマによる実行時検証と型安全性を提供します。
 * 本番環境でのリクエスト処理に使用される厳密な型定義。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { z } from 'zod'
import { HealthDataSchema, UserProfileSchema } from './health'

/**
 * 座標情報のZodスキーマ
 */
export const LocationSchema = z.object({
  /** 緯度（-90〜90の範囲） */
  latitude: z.number().min(-90).max(90),
  /** 経度（-180〜180の範囲） */
  longitude: z.number().min(-180).max(180),
})

/**
 * 座標情報の型定義
 */
export type Location = z.infer<typeof LocationSchema>

/**
 * ヘルス分析リクエストのZodスキーマ
 */
export const AnalyzeRequestSchema = z.object({
  /** HealthKitから取得したヘルスデータ */
  healthData: HealthDataSchema,
  /** GPS位置情報 */
  location: LocationSchema,
  /** ユーザープロファイル情報 */
  userProfile: UserProfileSchema,
})

/**
 * ヘルス分析リクエストの型定義
 */
export type AnalyzeRequest = z.infer<typeof AnalyzeRequestSchema>

/**
 * 天気テスト用リクエストのZodスキーマ
 * テスト環境でのシンプルな天気データ取得用
 */
export const WeatherTestRequestSchema = z.object({
  /** 緯度 */
  latitude: z.number().min(-90).max(90),
  /** 経度 */
  longitude: z.number().min(-180).max(180),
})

/**
 * 天気テスト用リクエストの型定義
 */
export type WeatherTestRequest = z.infer<typeof WeatherTestRequestSchema>

/**
 * 分析モックテスト用リクエストのZodスキーマ
 */
export const AnalyzeTestRequestSchema = z.object({
  /** 位置情報 */
  location: LocationSchema,
})

/**
 * 分析モックテスト用リクエストの型定義
 */
export type AnalyzeTestRequest = z.infer<typeof AnalyzeTestRequestSchema>
