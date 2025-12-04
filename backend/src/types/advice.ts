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
  recommendation: string
  reason: string
  examples?: string[]
  timing?: string
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
