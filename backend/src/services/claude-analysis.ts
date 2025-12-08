/**
 * @fileoverview Comprehensive Claude AI Analysis Service
 *
 * ヘルスケアデータの包括的なAI分析を提供するサービス。
 * ヘルスケアデータ、環境データ、ユーザープロファイルを組み合わせて
 * パーソナライズされた詳細な健康分析とアドバイスを生成します。
 *
 * @author Tempo AI Team
 * @since 2.0.0
 */

import { z } from 'zod'
import type { DailyAdvice } from '../types/advice'
import type { HealthData, UserProfile } from '../types/health'
import type { WeatherData } from '../types/weather'
import { APIError } from '../utils/errors'
import type { LocalizationContext } from '../utils/localization'
import { generateAdviceWithRetry } from './claude'

/**
 * 包括的健康分析リクエスト
 */
export interface ComprehensiveAnalysisRequest {
  /** ヘルスケアデータ */
  healthData: HealthData
  /** ユーザープロファイル */
  userProfile: UserProfile
  /** 環境データ */
  weatherData?: WeatherData
  /** 分析タイプ */
  analysisType: AnalysisType
  /** 言語設定 */
  language: 'japanese' | 'english'
  /** ユーザーコンテキスト */
  userContext?: UserContext
}

/**
 * 分析タイプの定義
 */
export enum AnalysisType {
  /** 日次包括分析 */
  DAILY_COMPREHENSIVE = 'daily_comprehensive',
  /** 週次詳細レビュー */
  WEEKLY_REVIEW = 'weekly_review',
  /** クリティカルアラート分析 */
  CRITICAL_ALERT = 'critical_alert',
  /** ユーザー要求分析 */
  USER_REQUESTED = 'user_requested',
  /** パターン変化分析 */
  PATTERN_CHANGE = 'pattern_change',
  /** クイック分析 */
  QUICK_ANALYSIS = 'quick_analysis',
}

/**
 * ユーザーコンテキスト情報
 */
export interface UserContext {
  /** 時刻帯 */
  timeOfDay: 'morning' | 'afternoon' | 'evening' | 'night'
  /** エンゲージメントレベル */
  engagementLevel: 'high' | 'medium' | 'low'
  /** 前回分析からの経過時間 */
  timeSinceLastAnalysis?: number
  /** 特定の関心事項 */
  specificConcerns?: string[]
}

/**
 * AI健康インサイトの包括的な構造
 */
export const AIHealthInsightsSchema = z.object({
  /** 全体的な健康スコア (0-100) */
  overallScore: z.number().min(0).max(100),
  /** 主要なインサイト */
  keyInsights: z.array(z.string()).min(1),
  /** リスクファクター */
  riskFactors: z.array(
    z.object({
      category: z.string(),
      level: z.enum(['low', 'moderate', 'high', 'critical']),
      description: z.string(),
      recommendations: z.array(z.string()),
    })
  ),
  /** パーソナライズされた推奨事項 */
  recommendations: z.object({
    immediate: z.array(z.string()),
    shortTerm: z.array(z.string()),
    longTerm: z.array(z.string()),
  }),
  /** 今日の最適プラン */
  todaysOptimalPlan: z.object({
    morning: z.string(),
    afternoon: z.string(),
    evening: z.string(),
    sleepOptimization: z.string(),
  }),
  /** 環境要因の考慮 */
  environmentalFactors: z
    .object({
      weatherImpact: z.string(),
      exerciseRecommendations: z.string(),
      indoorActivities: z.array(z.string()).optional(),
    })
    .optional(),
  /** 文化的配慮事項 */
  culturalNotes: z.array(z.string()).optional(),
  /** 信頼度スコア (0-100) */
  confidenceScore: z.number().min(0).max(100),
  /** 分析の制限事項 */
  limitations: z.array(z.string()).optional(),
  /** 生成日時 */
  generatedAt: z.string().transform(str => new Date(str)),
  /** 使用言語 */
  language: z.string(),
})

export type AIHealthInsights = z.infer<typeof AIHealthInsightsSchema>

/**
 * 包括的Claude分析サービス
 */
export class ClaudeAnalysisService {
  private readonly requestCount: Map<string, number> = new Map()

  /**
   * 包括的健康分析を実行
   */
  async analyzeComprehensiveHealth(
    request: ComprehensiveAnalysisRequest,
    apiKey: string,
    customFetch?: typeof fetch
  ): Promise<AIHealthInsights> {
    // コスト追跡
    this.trackRequest(request)

    try {
      // リクエスト検証
      this.validateRequest(request)

      // 包括的プロンプトを生成
      const prompt = this.generateComprehensivePrompt(request)

      // ローカライゼーションコンテキストを作成
      const localizationContext = this.createLocalizationContext(request)

      // Claude API呼び出し（基本実装を拡張）
      const claudeParams: Parameters<typeof generateAdviceWithRetry>[0] = {
        prompt,
        apiKey,
        localizationContext,
      }

      if (customFetch) {
        claudeParams.customFetch = customFetch
      }

      const rawResponse = await generateAdviceWithRetry(claudeParams)

      // レスポンスを包括的な分析に変換
      const comprehensiveInsights = await this.transformToComprehensiveInsights(
        rawResponse,
        request
      )

      // レスポンス品質検証
      this.validateInsightsQuality(comprehensiveInsights, request.language)

      // 分析メトリクスをログ
      this.logAnalysisMetrics(request, comprehensiveInsights)

      return comprehensiveInsights
    } catch (error) {
      if (error instanceof APIError) {
        throw error
      }
      throw new APIError(
        `Comprehensive health analysis failed: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`,
        502,
        'COMPREHENSIVE_ANALYSIS_ERROR'
      )
    }
  }

  /**
   * クイック分析を実行
   */
  async analyzeQuick(
    request: Pick<ComprehensiveAnalysisRequest, 'healthData' | 'userProfile' | 'language'>,
    apiKey: string,
    customFetch?: typeof fetch
  ): Promise<AIHealthInsights> {
    const quickRequest: ComprehensiveAnalysisRequest = {
      ...request,
      analysisType: AnalysisType.QUICK_ANALYSIS,
      userContext: {
        timeOfDay: this.getCurrentTimeOfDay(),
        engagementLevel: 'medium',
      },
    }

    return this.analyzeComprehensiveHealth(quickRequest, apiKey, customFetch)
  }

  /**
   * 包括的プロンプトを生成
   */
  private generateComprehensivePrompt(request: ComprehensiveAnalysisRequest): string {
    const promptBuilder = new HealthPromptBuilder(request.language)

    return promptBuilder
      .addSystemRole()
      .addAnalysisGoals(request.analysisType)
      .addHealthDataContext(request.healthData)
      .addUserProfileContext(request.userProfile)
      .addEnvironmentalContext(request.weatherData)
      .addUserContext(request.userContext)
      .addCulturalContext(request.language)
      .addOutputFormatInstructions()
      .build()
  }

  /**
   * リクエスト検証
   */
  private validateRequest(request: ComprehensiveAnalysisRequest): void {
    if (!request.healthData) {
      throw new APIError('Health data is required', 400, 'MISSING_HEALTH_DATA')
    }

    if (!request.userProfile) {
      throw new APIError('User profile is required', 400, 'MISSING_USER_PROFILE')
    }

    // データの完全性チェック
    const dataCompleteness = this.assessDataCompleteness(request.healthData)
    if (dataCompleteness < 0.3) {
      // 30%未満の場合はエラー
      throw new APIError(
        'Insufficient health data for comprehensive analysis',
        400,
        'INSUFFICIENT_DATA'
      )
    }
  }

  /**
   * データの完全性評価
   */
  private assessDataCompleteness(healthData: HealthData): number {
    const fields = [
      healthData.sleep.duration,
      healthData.heartRate.resting,
      healthData.activity.steps,
      healthData.hrv.average,
    ]

    const validFields = fields.filter(field => field !== undefined && field > 0)
    return validFields.length / fields.length
  }

  /**
   * 基本レスポンスを包括的インサイトに変換
   */
  private async transformToComprehensiveInsights(
    rawResponse: unknown,
    request: ComprehensiveAnalysisRequest
  ): Promise<AIHealthInsights> {
    // レスポンスが既に包括的な形式かチェック
    if (this.isComprehensiveFormat(rawResponse)) {
      return rawResponse
    }

    // Type guard for DailyAdvice-like format
    const isDailyAdvice = (obj: unknown): obj is Partial<DailyAdvice> => {
      return typeof obj === 'object' && obj !== null && ('theme' in obj || 'summary' in obj)
    }

    const dailyAdvice = isDailyAdvice(rawResponse) ? rawResponse : {}

    // 基本形式から包括形式に変換
    return {
      overallScore: this.calculateOverallScore(request.healthData),
      keyInsights: [dailyAdvice.theme || '', dailyAdvice.summary || ''].filter(Boolean),
      riskFactors: this.extractRiskFactors(rawResponse, request.healthData),
      recommendations: {
        immediate: [
          typeof dailyAdvice.breakfast === 'object' ? JSON.stringify(dailyAdvice.breakfast) : '',
          typeof dailyAdvice.lunch === 'object' ? JSON.stringify(dailyAdvice.lunch) : '',
          typeof dailyAdvice.dinner === 'object' ? JSON.stringify(dailyAdvice.dinner) : '',
        ].filter(Boolean),
        shortTerm: [
          typeof dailyAdvice.exercise === 'object' ? JSON.stringify(dailyAdvice.exercise) : '',
          typeof dailyAdvice.sleep_preparation === 'object'
            ? JSON.stringify(dailyAdvice.sleep_preparation)
            : '',
        ].filter(Boolean),
        longTerm: [],
      },
      todaysOptimalPlan: {
        morning:
          typeof dailyAdvice.breakfast === 'object' ? JSON.stringify(dailyAdvice.breakfast) : '',
        afternoon: typeof dailyAdvice.lunch === 'object' ? JSON.stringify(dailyAdvice.lunch) : '',
        evening: typeof dailyAdvice.dinner === 'object' ? JSON.stringify(dailyAdvice.dinner) : '',
        sleepOptimization:
          typeof dailyAdvice.sleep_preparation === 'object'
            ? JSON.stringify(dailyAdvice.sleep_preparation)
            : '',
      },
      environmentalFactors: request.weatherData
        ? {
            weatherImpact: this.generateWeatherImpact(request.weatherData),
            exerciseRecommendations: this.generateExerciseRecommendations(request.weatherData),
          }
        : undefined,
      culturalNotes: [],
      confidenceScore: 85,
      limitations: this.identifyAnalysisLimitations(request),
      generatedAt: new Date(),
      language: request.language,
    }
  }

  /**
   * インサイト品質検証
   */
  private validateInsightsQuality(insights: AIHealthInsights, language: string): void {
    // 汎用的なレスポンスパターンをチェック
    const genericPatterns = this.getGenericPatterns(language)

    for (const insight of insights.keyInsights) {
      for (const pattern of genericPatterns) {
        if (pattern.test(insight)) {
          throw new APIError(`Generic response detected: ${insight}`, 502, 'GENERIC_RESPONSE_ERROR')
        }
      }
    }

    // 最小詳細レベルチェック
    if (insights.keyInsights.every(insight => insight.length < 30)) {
      throw new APIError('Insights lack sufficient detail', 502, 'INSUFFICIENT_DETAIL_ERROR')
    }
  }

  /**
   * 汎用パターンを取得
   */
  private getGenericPatterns(language: string): RegExp[] {
    if (language === 'japanese') {
      return [/健康状態は良好です/, /バランスの取れた食事を/, /適度な運動を/, /十分な睡眠を/]
    } else {
      return [
        /your health is good/i,
        /eat a balanced diet/i,
        /get regular exercise/i,
        /get enough sleep/i,
      ]
    }
  }

  /**
   * 全体的なスコアを計算
   */
  private calculateOverallScore(healthData: HealthData): number {
    // 複数の健康指標から総合スコアを算出
    const sleepScore = Math.min((healthData.sleep.efficiency / 100) * 100, 100)
    const activityScore = Math.min((healthData.activity.steps / 10000) * 100, 100)
    const heartRateScore = this.calculateHeartRateScore(healthData.heartRate.resting)
    const hrvScore = Math.min((healthData.hrv.average / 50) * 100, 100)

    return Math.round((sleepScore + activityScore + heartRateScore + hrvScore) / 4)
  }

  /**
   * 心拍数スコアを計算
   */
  private calculateHeartRateScore(restingHR: number): number {
    // 年齢調整済み安静時心拍数の評価
    if (restingHR < 60) return 100
    if (restingHR < 70) return 85
    if (restingHR < 80) return 70
    if (restingHR < 90) return 55
    return 40
  }

  /**
   * コスト追跡とレート制限
   */
  private trackRequest(_request: ComprehensiveAnalysisRequest): void {
    const userId = 'default_user' // 実際の実装ではuserIdを使用
    const currentCount = this.requestCount.get(userId) || 0

    // 日次制限チェック（例: 10リクエスト/日）
    if (currentCount >= 10) {
      throw new APIError('Daily request limit exceeded', 429, 'RATE_LIMIT_EXCEEDED')
    }

    this.requestCount.set(userId, currentCount + 1)
  }

  /**
   * 分析メトリクスをログ
   */
  private logAnalysisMetrics(
    request: ComprehensiveAnalysisRequest,
    insights: AIHealthInsights
  ): void {
    console.log(`Analysis completed: ${request.analysisType}`, {
      language: request.language,
      dataCompleteness: this.assessDataCompleteness(request.healthData),
      confidenceScore: insights.confidenceScore,
      keyInsightsCount: insights.keyInsights.length,
      riskFactorsCount: insights.riskFactors.length,
    })
  }

  /**
   * ローカライゼーションコンテキストを作成
   */
  private createLocalizationContext(request: ComprehensiveAnalysisRequest): LocalizationContext {
    return {
      language: request.language === 'japanese' ? 'ja' : 'en',
      region: request.language === 'japanese' ? 'JP' : 'US',
      timeZone: request.language === 'japanese' ? 'Asia/Tokyo' : 'America/New_York',
      culturalContext: {
        formalityLevel: 'casual',
        mealTimes: {
          breakfast: '07:00',
          lunch: '12:00',
          dinner: '19:00',
        },
      },
    }
  }

  /**
   * ユーティリティメソッド
   */
  private getCurrentTimeOfDay(): 'morning' | 'afternoon' | 'evening' | 'night' {
    const hour = new Date().getHours()
    if (hour < 12) return 'morning'
    if (hour < 17) return 'afternoon'
    if (hour < 21) return 'evening'
    return 'night'
  }

  private isComprehensiveFormat(response: unknown): response is AIHealthInsights {
    if (typeof response !== 'object' || response === null) {
      return false
    }

    const obj = response as {
      overallScore?: unknown
      keyInsights?: unknown
      riskFactors?: unknown
      [key: string]: unknown
    }
    return (
      typeof obj.overallScore === 'number' &&
      Array.isArray(obj.keyInsights) &&
      Array.isArray(obj.riskFactors)
    )
  }

  private extractRiskFactors(
    _response: unknown,
    healthData: HealthData
  ): AIHealthInsights['riskFactors'] {
    const riskFactors: AIHealthInsights['riskFactors'] = []

    // 睡眠リスク評価
    if (healthData.sleep.efficiency < 85) {
      riskFactors.push({
        category: 'sleep',
        level: healthData.sleep.efficiency < 70 ? ('high' as const) : ('moderate' as const),
        description: `Sleep efficiency is ${healthData.sleep.efficiency}%`,
        recommendations: ['Improve sleep hygiene', 'Maintain consistent bedtime'],
      })
    }

    return riskFactors
  }

  private generateWeatherImpact(weatherData: WeatherData): string {
    const temp = weatherData.current.temperature_2m
    if (temp < 5) {
      return 'Cold weather may affect cardiovascular health and exercise performance'
    } else if (temp > 30) {
      return 'Hot weather requires extra hydration and modified exercise intensity'
    }
    return 'Weather conditions are favorable for outdoor activities'
  }

  private generateExerciseRecommendations(weatherData: WeatherData): string {
    if (weatherData.current.precipitation > 5) {
      return 'Consider indoor exercises due to rain'
    }
    if (weatherData.current.temperature_2m > 28) {
      return 'Exercise during cooler morning or evening hours'
    }
    return 'Good conditions for outdoor exercise'
  }

  private identifyAnalysisLimitations(request: ComprehensiveAnalysisRequest): string[] {
    const limitations = []

    if (!request.weatherData) {
      limitations.push('Environmental factors not considered due to missing weather data')
    }

    if (this.assessDataCompleteness(request.healthData) < 0.8) {
      limitations.push('Analysis limited by incomplete health data')
    }

    return limitations
  }
}

/**
 * ヘルスプロンプトビルダー
 */
class HealthPromptBuilder {
  private prompt: string[] = []

  constructor(private language: string) {}

  addSystemRole(): this {
    if (this.language === 'japanese') {
      this.prompt
        .push(`あなたは経験豊富な健康アドバイザーです。包括的なヘルスケアデータを分析し、個人に合わせた詳細で実行可能なアドバイスを提供してください。

重要な指示：
- データに基づいた客観的で科学的な評価を行う
- 個人の生活環境や文化的背景を考慮する
- 実行可能で継続しやすい具体的な改善提案を行う
- 健康リスクの適切な評価と優先順位付けを行う
- 前向きで励ましとなる専門的なトーンを使用する`)
    } else {
      this.prompt
        .push(`You are an experienced health advisor analyzing comprehensive user health data. Provide personalized, detailed, and actionable insights based on the following principles:

Critical instructions:
- Conduct evidence-based objective and scientific assessments
- Consider individual lifestyle and cultural contexts
- Provide specific, actionable, and sustainable improvement recommendations
- Perform appropriate risk assessment and prioritization
- Use an encouraging and professional communication tone`)
    }
    return this
  }

  addAnalysisGoals(analysisType: AnalysisType): this {
    const goals = this.getAnalysisGoals(analysisType)
    this.prompt.push(`Analysis Goals: ${goals.join(', ')}`)
    return this
  }

  addHealthDataContext(healthData: HealthData): this {
    this.prompt.push(`
# Comprehensive Health Data

## Sleep Analysis
- Duration: ${healthData.sleep.duration} hours
- Sleep Efficiency: ${healthData.sleep.efficiency}%
- Deep Sleep: ${healthData.sleep.deep} hours
- REM Sleep: ${healthData.sleep.rem} hours
- Light Sleep: ${healthData.sleep.light} hours

## Cardiovascular Health
- Resting Heart Rate: ${healthData.heartRate.resting} bpm
- Average Heart Rate: ${healthData.heartRate.average} bpm
- Heart Rate Variability: ${healthData.hrv.average} ms

## Daily Activity
- Steps: ${healthData.activity.steps}
- Distance: ${healthData.activity.distance} km
- Calories Burned: ${healthData.activity.calories} kcal
- Active Minutes: ${healthData.activity.activeMinutes} minutes`)
    return this
  }

  addUserProfileContext(userProfile: UserProfile): this {
    this.prompt.push(`
# User Profile
- Age: ${userProfile.age}
- Gender: ${userProfile.gender}
- Exercise Frequency: ${userProfile.exerciseFrequency}
- Health Goals: ${userProfile.goals.join(', ')}
- Dietary Preferences: ${userProfile.dietaryPreferences}`)
    return this
  }

  addEnvironmentalContext(weatherData?: WeatherData): this {
    if (weatherData) {
      this.prompt.push(`
# Environmental Conditions
- Temperature: ${weatherData.current.temperature_2m}°C
- Humidity: ${weatherData.current.relative_humidity_2m}%
- UV Index: ${weatherData.current.uv_index || 'N/A'}
- Precipitation: ${weatherData.current.precipitation}mm
- Air Quality: ${weatherData.airQuality?.category || 'N/A'}`)
    }
    return this
  }

  addUserContext(userContext?: UserContext): this {
    if (userContext) {
      this.prompt.push(`
# User Context
- Time of Day: ${userContext.timeOfDay}
- Engagement Level: ${userContext.engagementLevel}
- Specific Concerns: ${userContext.specificConcerns?.join(', ') || 'None'}`)
    }
    return this
  }

  addCulturalContext(language: string): this {
    if (language === 'japanese') {
      this.prompt.push(`
# 文化的配慮
- 日本の生活様式と価値観を反映
- 食事時間: 朝食7:00、昼食12:00、夕食19:00を基準
- 礼儀正しく丁寧な表現を使用
- 集団調和と個人の健康のバランスを考慮`)
    } else {
      this.prompt.push(`
# Cultural Context
- Western lifestyle and values
- Meal times: breakfast 8:00, lunch 12:30, dinner 18:30
- Direct and actionable communication style
- Focus on individual empowerment and self-care`)
    }
    return this
  }

  addOutputFormatInstructions(): this {
    if (this.language === 'japanese') {
      this.prompt.push(`
# 出力形式の指示

以下のJSON形式で必ず回答してください：
{
  "overallScore": 数値(0-100),
  "keyInsights": ["具体的な健康洞察1", "具体的な健康洞察2", ...],
  "riskFactors": [
    {
      "category": "カテゴリ名",
      "level": "low|moderate|high|critical",
      "description": "詳細な説明",
      "recommendations": ["推奨事項1", "推奨事項2"]
    }
  ],
  "recommendations": {
    "immediate": ["即座に実行できる推奨事項"],
    "shortTerm": ["短期的な推奨事項"],
    "longTerm": ["長期的な推奨事項"]
  },
  "todaysOptimalPlan": {
    "morning": "朝の最適な活動計画",
    "afternoon": "午後の最適な活動計画", 
    "evening": "夕方の最適な活動計画",
    "sleepOptimization": "睡眠最適化のアドバイス"
  },
  "environmentalFactors": {
    "weatherImpact": "天気による影響の説明",
    "exerciseRecommendations": "環境を考慮した運動推奨"
  },
  "culturalNotes": ["文化的配慮事項"],
  "confidenceScore": 数値(0-100),
  "limitations": ["分析の制限事項"],
  "generatedAt": "2024-03-15T10:30:00Z",
  "language": "japanese"
}`)
    } else {
      this.prompt.push(`
# Output Format Instructions

Please respond in the following JSON format:
{
  "overallScore": number(0-100),
  "keyInsights": ["specific health insight 1", "specific health insight 2", ...],
  "riskFactors": [
    {
      "category": "category name",
      "level": "low|moderate|high|critical", 
      "description": "detailed description",
      "recommendations": ["recommendation 1", "recommendation 2"]
    }
  ],
  "recommendations": {
    "immediate": ["immediately actionable recommendations"],
    "shortTerm": ["short-term recommendations"],
    "longTerm": ["long-term recommendations"]
  },
  "todaysOptimalPlan": {
    "morning": "optimal morning activity plan",
    "afternoon": "optimal afternoon activity plan",
    "evening": "optimal evening activity plan", 
    "sleepOptimization": "sleep optimization advice"
  },
  "environmentalFactors": {
    "weatherImpact": "weather impact explanation",
    "exerciseRecommendations": "environment-aware exercise recommendations"
  },
  "culturalNotes": ["cultural considerations"],
  "confidenceScore": number(0-100),
  "limitations": ["analysis limitations"],
  "generatedAt": "2024-03-15T10:30:00Z",
  "language": "english"
}`)
    }
    return this
  }

  build(): string {
    return this.prompt.join('\n\n')
  }

  private getAnalysisGoals(analysisType: AnalysisType): string[] {
    switch (analysisType) {
      case AnalysisType.DAILY_COMPREHENSIVE:
        return ['daily health optimization', 'risk identification', 'actionable recommendations']
      case AnalysisType.WEEKLY_REVIEW:
        return ['trend analysis', 'progress assessment', 'long-term planning']
      case AnalysisType.CRITICAL_ALERT:
        return ['immediate risk assessment', 'urgent recommendations', 'safety guidance']
      case AnalysisType.USER_REQUESTED:
        return ['detailed analysis', 'specific insights', 'personalized guidance']
      case AnalysisType.PATTERN_CHANGE:
        return ['pattern analysis', 'change explanation', 'intervention recommendations']
      case AnalysisType.QUICK_ANALYSIS:
        return ['rapid assessment', 'key priorities', 'immediate actions']
      default:
        return ['comprehensive analysis', 'actionable insights', 'personalized recommendations']
    }
  }
}

/**
 * サービスの便利な関数エクスポート
 */
export const claudeAnalysisService = new ClaudeAnalysisService()
