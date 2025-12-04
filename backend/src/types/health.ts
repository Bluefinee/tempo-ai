/**
 * @fileoverview Health Data Type Definitions
 *
 * HealthKitから取得される健康データの型定義。
 * 睡眠、心拍変動、心拍数、アクティビティなどの
 * 包括的なヘルスメトリクスとユーザープロファイル情報を定義します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

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
  duration: number
  deep: number
  rem: number
  light: number
  awake: number
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
  gender: string
  goals: string[]
  dietaryPreferences: string
  exerciseHabits: string
  exerciseFrequency: string
}
