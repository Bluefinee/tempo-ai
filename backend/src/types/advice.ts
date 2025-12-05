/**
 * @fileoverview Health Advice Type Definitions
 *
 * AI分析によって生成される健康アドバイスの型定義。
 * Claude AIが返すパーソナライズされたヘルスアドバイスの構造を定義し、
 * 食事、運動、睡眠、水分補給などの包括的な健康ガイダンスを提供します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { z } from 'zod'

/**
 * 1日の包括的な健康アドバイス
 * AI分析の結果として生成される、パーソナライズされた健康ガイダンス
 */
export interface DailyAdvice {
  /** その日のテーマ（例：リカバリーデー、アクティブデー） */
  theme: string
  /** 全体的な健康状態の要約 */
  summary: string
  /** 朝食に関するアドバイス */
  breakfast: MealAdvice
  /** 昼食に関するアドバイス */
  lunch: MealAdvice
  /** 夕食に関するアドバイス */
  dinner: MealAdvice
  /** 運動に関するアドバイス */
  exercise: ExerciseAdvice
  /** 水分補給に関するアドバイス */
  hydration: HydrationAdvice
  /** 呼吸法に関するアドバイス */
  breathing: BreathingAdvice
  /** 睡眠準備に関するアドバイス */
  sleep_preparation: SleepPreparation
  /** 天気を考慮したアドバイス */
  weather_considerations: WeatherConsiderations
  /** 優先すべき行動リスト */
  priority_actions: string[]
}

/**
 * 食事に関するアドバイス
 * 朝食、昼食、夕食それぞれの推奨事項を定義
 */
export interface MealAdvice {
  /** 推奨される食事内容 */
  recommendation: string
  /** 推奨理由 */
  reason: string
  /** 具体的な食事例 */
  examples?: string[]
  /** 推奨される食事時間 */
  timing?: string
  /** 避けるべき食品 */
  avoid?: string[]
}

/**
 * 運動に関するアドバイス
 * その日の体調と天気を考慮した運動推奨事項
 */
export interface ExerciseAdvice {
  recommendation: string
  intensity: 'Low' | 'Moderate' | 'High'
  reason: string
  timing: string
  avoid: string[]
}

/**
 * 水分補給に関するアドバイス
 * 1日の水分補給計画とタイミング
 */
export interface HydrationAdvice {
  target: string
  schedule: {
    morning: string
    afternoon: string
    evening: string
  }
  reason: string
}

/**
 * 呼吸法に関するアドバイス
 * ストレス軽減や体調改善のための呼吸エクササイズ
 */
export interface BreathingAdvice {
  technique: string
  duration: string
  frequency: string
  instructions: string[]
}

/**
 * 睡眠準備に関するアドバイス
 * 質の良い睡眠のための準備と習慣
 */
export interface SleepPreparation {
  bedtime: string
  routine: string[]
  avoid: string[]
}

/**
 * 天気を考慮したアドバイス
 * 気象条件に基づく注意点と機会
 */
export interface WeatherConsiderations {
  warnings: string[]
  opportunities: string[]
}

// Zod Schema Definitions for Type-Safe Validation

/**
 * 食事に関するアドバイスのzodスキーマ
 */
export const MealAdviceSchema = z.object({
  recommendation: z.string().min(1),
  reason: z.string().min(1),
  examples: z.array(z.string()).optional(),
  timing: z.string().optional(),
  avoid: z.array(z.string()).optional(),
})

/**
 * 運動に関するアドバイスのzodスキーマ
 */
export const ExerciseAdviceSchema = z.object({
  recommendation: z.string().min(1),
  intensity: z.enum(['Low', 'Moderate', 'High']),
  reason: z.string().min(1),
  timing: z.string().min(1),
  avoid: z.array(z.string()),
})

/**
 * 水分補給に関するアドバイスのzodスキーマ
 */
export const HydrationAdviceSchema = z.object({
  target: z.string().min(1),
  schedule: z.object({
    morning: z.string().min(1),
    afternoon: z.string().min(1),
    evening: z.string().min(1),
  }),
  reason: z.string().min(1),
})

/**
 * 呼吸法に関するアドバイスのzodスキーマ
 */
export const BreathingAdviceSchema = z.object({
  technique: z.string().min(1),
  duration: z.string().min(1),
  frequency: z.string().min(1),
  instructions: z.array(z.string()).min(1),
})

/**
 * 睡眠準備に関するアドバイスのzodスキーマ
 */
export const SleepPreparationSchema = z.object({
  bedtime: z.string().min(1),
  routine: z.array(z.string()).min(1),
  avoid: z.array(z.string()),
})

/**
 * 天気を考慮したアドバイスのzodスキーマ
 */
export const WeatherConsiderationsSchema = z.object({
  warnings: z.array(z.string()),
  opportunities: z.array(z.string()),
})

/**
 * DailyAdviceのzodスキーマ
 * AI応答のバリデーションとパースに使用
 */
export const DailyAdviceSchema = z.object({
  theme: z.string().min(1),
  summary: z.string().min(1),
  breakfast: MealAdviceSchema,
  lunch: MealAdviceSchema,
  dinner: MealAdviceSchema,
  exercise: ExerciseAdviceSchema,
  hydration: HydrationAdviceSchema,
  breathing: BreathingAdviceSchema,
  sleep_preparation: SleepPreparationSchema,
  weather_considerations: WeatherConsiderationsSchema,
  priority_actions: z.array(z.string()).min(1),
})

// Note: Interfaces above provide TypeScript types
// Zod schemas below provide runtime validation
// Both coexist for development convenience
