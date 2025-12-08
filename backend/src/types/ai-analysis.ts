/**
 * @fileoverview AI Analysis Type Definitions
 *
 * AI分析システム用の型定義。
 * ヘルスケアデータの包括的分析とパーソナライズされた
 * アドバイス生成のためのデータ構造を定義します。
 */

import { z } from 'zod'

// MARK: - Analysis Request Types

/**
 * AI分析リクエストのスキーマ
 * ヘルスケアデータとユーザーコンテキストを統合
 */
export const AIAnalysisRequestSchema = z.object({
  /** 現在のエネルギーレベル (0-100) */
  batteryLevel: z.number().min(0).max(100),
  /** エネルギーの変化傾向 */
  batteryTrend: z.enum(['recovering', 'declining', 'stable']),
  /** 生物学的コンテキスト */
  biologicalContext: z.object({
    /** HRV状態（基準値からの偏差 ms） */
    hrvStatus: z.number(),
    /** 心拍数状態（基準値からの差分 bpm） */
    rhrStatus: z.number(),
    /** 深い睡眠時間（分） */
    sleepDeep: z.number().int().min(0),
    /** REM睡眠時間（分） */
    sleepRem: z.number().int().min(0),
    /** 呼吸数（回/分） */
    respiratoryRate: z.number().positive(),
    /** 歩数 */
    steps: z.number().int().min(0),
    /** 消費カロリー（kcal） */
    activeCalories: z.number().min(0),
  }),
  /** 環境コンテキスト */
  environmentalContext: z.object({
    /** 気圧変化（6時間での変動 hPa） */
    pressureTrend: z.number(),
    /** 相対湿度（%） */
    humidity: z.number().min(0).max(100),
    /** 体感温度（°C） */
    feelsLike: z.number(),
    /** UVインデックス */
    uvIndex: z.number().min(0).max(11),
    /** 天候コード（WMO） */
    weatherCode: z.number().int(),
  }),
  /** ユーザーコンテキスト */
  userContext: z.object({
    /** アクティブなフォーカスタグ */
    activeTags: z.array(
      z.enum(['work', 'beauty', 'diet', 'chill', 'sleep', 'fitness']),
    ),
    /** 時間帯 */
    timeOfDay: z.enum(['morning', 'afternoon', 'evening', 'night']),
    /** 言語設定 */
    language: z.enum(['ja', 'en']),
    /** ユーザーモード */
    userMode: z.enum(['standard', 'athlete']),
  }),
})

export type AIAnalysisRequest = z.infer<typeof AIAnalysisRequestSchema>

// MARK: - Analysis Response Types

/**
 * AI分析レスポンスのスキーマ
 * ヘッドライン、詳細分析、アクション提案を含む
 */
export const AIAnalysisResponseSchema = z.object({
  /** ヘッドライン */
  headline: z.object({
    /** メインタイトル */
    title: z.string().min(1),
    /** サブタイトル */
    subtitle: z.string().min(1),
    /** 影響レベル */
    impactLevel: z.enum(['low', 'medium', 'high', 'critical']),
    /** AI信頼度（0-100%） */
    confidence: z.number().min(0).max(100),
  }),
  /** エネルギー状態のコメント */
  energyComment: z.string().min(1),
  /** フォーカスタグ別インサイト */
  tagInsights: z.array(
    z.object({
      /** 対象タグ */
      tag: z.enum(['work', 'beauty', 'diet', 'chill', 'sleep', 'fitness']),
      /** アイコン名 */
      icon: z.string(),
      /** メッセージ */
      message: z.string().min(1),
      /** 緊急度 */
      urgency: z.enum(['info', 'warning', 'critical']),
    }),
  ),
  /** AI生成アクション提案 */
  aiActionSuggestions: z.array(
    z.object({
      /** 提案タイトル */
      title: z.string().min(1),
      /** 詳細説明 */
      description: z.string().min(1),
      /** アクションタイプ */
      actionType: z.enum([
        'rest',
        'hydrate',
        'exercise',
        'focus',
        'social',
        'beauty',
      ]),
      /** 推定所要時間 */
      estimatedTime: z.string(),
      /** 難易度 */
      difficulty: z.enum(['easy', 'medium', 'hard']),
    }),
  ),
  /** 詳細分析 */
  detailAnalysis: z.string().min(1),
  /** データ品質情報 */
  dataQuality: z.object({
    /** HealthKitデータの完全性（0-100%） */
    healthDataCompleteness: z.number().min(0).max(100),
    /** 気象データの鮮度（分） */
    weatherDataAge: z.number().int().min(0),
    /** 分析タイムスタンプ */
    analysisTimestamp: z.string().datetime(),
  }),
  /** 生成日時 */
  generatedAt: z.string().datetime(),
})

export type AIAnalysisResponse = z.infer<typeof AIAnalysisResponseSchema>

// MARK: - Analysis Result Container

/**
 * 分析結果の統合コンテナ
 */
export const AnalysisResultSchema = z.object({
  /** 静的分析結果 */
  staticAnalysis: z
    .object({
      /** エネルギーレベル */
      energyLevel: z.number().min(0).max(100),
      /** バッテリー状態 */
      batteryState: z.enum(['low', 'medium', 'high', 'critical']),
      /** 基本メトリクス */
      basicMetrics: z.object({
        /** 睡眠スコア */
        sleepScore: z.number().min(0).max(100),
        /** 活動スコア */
        activityScore: z.number().min(0).max(100),
        /** ストレススコア */
        stressScore: z.number().min(0).max(100),
      }),
      /** 生成時刻 */
      generatedAt: z.string().datetime(),
    })
    .optional(),
  /** AI分析結果 */
  aiAnalysis: AIAnalysisResponseSchema.optional(),
  /** データソース */
  source: z.enum(['static_only', 'hybrid', 'cached', 'fallback']),
  /** 最終更新時刻 */
  lastUpdated: z.string().datetime(),
})

export type AnalysisResult = z.infer<typeof AnalysisResultSchema>

// MARK: - Focus Tag Enums and Utilities

/**
 * フォーカスタグの定義
 */
export const FocusTag = {
  WORK: 'work',
  BEAUTY: 'beauty',
  DIET: 'diet',
  CHILL: 'chill',
  SLEEP: 'sleep',
  FITNESS: 'fitness',
} as const

export type FocusTagType = (typeof FocusTag)[keyof typeof FocusTag]

/**
 * フォーカスタグのメタデータ
 */
export const FocusTagMetadata: Record<
  FocusTagType,
  {
    analysisWeight: number
    environmentalFactors: string[]
  }
> = {
  [FocusTag.WORK]: {
    analysisWeight: 1.2,
    environmentalFactors: ['気圧', '湿度', '気温'],
  },
  [FocusTag.BEAUTY]: {
    analysisWeight: 0.8,
    environmentalFactors: ['湿度', 'UV指数', '気温'],
  },
  [FocusTag.DIET]: {
    analysisWeight: 1.0,
    environmentalFactors: ['気温', '湿度'],
  },
  [FocusTag.SLEEP]: {
    analysisWeight: 1.3,
    environmentalFactors: ['気圧', '気温', '湿度'],
  },
  [FocusTag.FITNESS]: {
    analysisWeight: 1.1,
    environmentalFactors: ['気温', '湿度', 'UV指数'],
  },
  [FocusTag.CHILL]: {
    analysisWeight: 0.9,
    environmentalFactors: ['気圧', '湿度'],
  },
}

// MARK: - User Mode Enums and Utilities

/**
 * ユーザーモードの定義
 */
export const UserMode = {
  STANDARD: 'standard',
  ATHLETE: 'athlete',
} as const

export type UserModeType = (typeof UserMode)[keyof typeof UserMode]

/**
 * ユーザーモードのメタデータ
 */
export const UserModeMetadata: Record<
  UserModeType,
  {
    energyConsumptionModifier: number
    recoverySpeedModifier: number
  }
> = {
  [UserMode.STANDARD]: {
    energyConsumptionModifier: 1.0,
    recoverySpeedModifier: 1.0,
  },
  [UserMode.ATHLETE]: {
    energyConsumptionModifier: 1.2,
    recoverySpeedModifier: 1.1,
  },
}

// MARK: - Validation Helpers

/**
 * AI分析リクエストを検証
 */
export const validateAIAnalysisRequest = (data: unknown): AIAnalysisRequest => {
  return AIAnalysisRequestSchema.parse(data)
}

/**
 * AI分析レスポンスを検証
 */
export const validateAIAnalysisResponse = (
  data: unknown,
): AIAnalysisResponse => {
  return AIAnalysisResponseSchema.parse(data)
}

/**
 * 分析結果を検証
 */
export const validateAnalysisResult = (data: unknown): AnalysisResult => {
  return AnalysisResultSchema.parse(data)
}
