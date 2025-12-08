/**
 * @fileoverview Health Data Type Definitions
 *
 * HealthKitから取得されるヘルスケアデータの型定義。
 * 睡眠、心拍変動、心拍数、アクティビティなどの
 * 包括的なヘルスメトリクスとユーザープロファイル情報を定義します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { z } from 'zod'

/**
 * HealthKitから取得される包括的なヘルスデータ
 * AI分析に必要なすべての健康指標を含む
 */
export interface HealthData {
  /** 睡眠データ（時間、深度、効率など） */
  sleep: SleepData
  /** 心拍変動データ（自律神経の状態指標） */
  hrv: HRVData
  /** 心拍数データ（安静時、平均、最大・最小値） */
  heartRate: HeartRateData
  /** 活動データ（歩数、距離、カロリー消費など） */
  activity: ActivityData
}

/**
 * 睡眠データの詳細情報
 * HealthKitから取得される睡眠分析結果
 */
export interface SleepData {
  /** 睡眠時間（時間単位） */
  duration: number
  /** 深い睡眠時間（時間単位） */
  deep: number
  /** REM睡眠時間（時間単位） */
  rem: number
  /** 浅い睡眠時間（時間単位） */
  light: number
  /** 覚醒時間（時間単位） */
  awake: number
  /** 睡眠効率（パーセント） */
  efficiency: number
}

/**
 * 心拍変動（HRV）データ
 * 自律神経系の状態を示す重要な指標
 */
export interface HRVData {
  average: number
  min: number
  max: number
}

/**
 * 心拍数データ
 * 安静時、活動時、最大・最小心拍数の記録
 */
export interface HeartRateData {
  resting: number
  average: number
  min: number
  max: number
}

/**
 * 日常活動データ
 * 歩数、移動距離、消費カロリーなどの活動指標
 */
export interface ActivityData {
  steps: number
  distance: number
  calories: number
  activeMinutes: number
}

/**
 * ユーザープロファイル情報
 * パーソナライズされたアドバイス生成に必要な個人情報
 */
export interface UserProfile {
  age: number
  gender: 'male' | 'female' | 'other' | 'prefer_not_to_say'
  goals: string[]
  dietaryPreferences: string
  exerciseHabits: string
  exerciseFrequency: 'daily' | 'weekly' | 'monthly' | 'rarely' | 'never'
}

// Zod schemas for runtime validation
export const HealthDataSchema = z.object({
  sleep: z.object({
    duration: z.number().min(0),
    deep: z.number().min(0),
    rem: z.number().min(0),
    light: z.number().min(0),
    awake: z.number().min(0),
    efficiency: z.number().min(0).max(100),
  }),
  hrv: z.object({
    average: z.number().positive(),
    min: z.number().positive(),
    max: z.number().positive(),
  }),
  heartRate: z.object({
    resting: z.number().positive(),
    average: z.number().positive(),
    min: z.number().positive(),
    max: z.number().positive(),
  }),
  activity: z.object({
    steps: z.number().int().min(0),
    distance: z.number().min(0),
    calories: z.number().int().min(0),
    activeMinutes: z.number().int().min(0),
  }),
})

export const UserProfileSchema = z.object({
  age: z.number().int().positive(),
  gender: z.enum(['male', 'female', 'other', 'prefer_not_to_say']),
  goals: z.array(z.string()), // Empty goals allowed - matches iOS validation
  dietaryPreferences: z.string().min(1),
  exerciseHabits: z.string().min(1),
  exerciseFrequency: z.enum(['daily', 'weekly', 'monthly', 'rarely', 'never']),
})
