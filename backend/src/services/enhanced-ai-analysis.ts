/**
 * @fileoverview Enhanced AI Analysis Service
 *
 * 関心分野別の専門AI分析サービス。
 * フォーカスタグに応じた専門的なプロンプトと
 * 「今日のトライ」提案を生成します。
 */

import type { AIAnalysisRequest, AIAnalysisResponse } from '../types/ai-analysis'
import { FocusAreaPromptBuilder, TodaysTryContextAnalyzer } from './focus-area-prompts'
import { generateAdviceWithRetry } from './claude'
import { APIError } from '../utils/errors'

/**
 * 拡張AI分析サービス
 * 関心分野専門化とコスト最適化を実現
 */
export class EnhancedAIAnalysisService {
  /**
   * 関心分野に特化したAI分析を実行
   */
  async generateFocusAreaAnalysis(
    request: AIAnalysisRequest,
    apiKey: string,
    customFetch?: typeof fetch,
  ): Promise<AIAnalysisResponse> {
    try {
      // 1. 最適な「トライ」機会を分析
      TodaysTryContextAnalyzer.analyzeBestTryOpportunity(request)
      
      // 2. 関心分野特化プロンプト構築
      const focusPrompt = FocusAreaPromptBuilder.buildFocusSpecificPrompt(request, request.userContext.language)
      
      // 3. コスト最適化されたプロンプト生成
      const optimizedPrompt = this.optimizePromptForCost(focusPrompt, request)
      
      // 4. Claude API呼び出し
      const claudeParams: any = {
        prompt: optimizedPrompt,
        apiKey,
        localizationContext: {
          language: request.userContext.language,
          region: request.userContext.language === 'ja' ? 'JP' : 'US',
          timeZone: request.userContext.language === 'ja' ? 'Asia/Tokyo' : 'America/New_York',
          culturalContext: {
            formalityLevel: 'casual' as const,
            mealTimes: {
              breakfast: '07:00',
              lunch: '12:00',
              dinner: '19:00',
            },
          },
        },
      }
      
      if (customFetch) {
        claudeParams.customFetch = customFetch
      }
      
      const rawResponse = await generateAdviceWithRetry(claudeParams)
      
      // 5. レスポンス構造化と検証
      const structuredResponse = await this.structureAIResponse(rawResponse, request)
      
      // 6. 品質検証
      this.validateResponseQuality(structuredResponse)
      
      return structuredResponse
      
    } catch (error) {
      throw new APIError(
        `Enhanced AI analysis failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
        502,
        'ENHANCED_AI_ANALYSIS_ERROR',
      )
    }
  }

  /**
   * プロンプトのコスト最適化
   * トークン数を2000以下に制限
   */
  private optimizePromptForCost(prompt: string, request: AIAnalysisRequest): string {
    // 重要な情報のみを抽出してトークン数を削減
    const essentialData = {
      energy: request.batteryLevel,
      trend: request.batteryTrend,
      focus: request.userContext.activeTags.slice(0, 3), // 最大3つまで
      time: request.userContext.timeOfDay,
      environment: {
        pressure: request.environmentalContext.pressureTrend,
        humidity: request.environmentalContext.humidity,
        temp: request.environmentalContext.feelsLike,
      },
      bio: {
        hrv: request.biologicalContext.hrvStatus,
        sleep: request.biologicalContext.sleepDeep + request.biologicalContext.sleepRem,
        activity: request.biologicalContext.steps,
      },
    }

    const compactPrompt = `${prompt}

## 分析データ (簡潔版)
${JSON.stringify(essentialData, null, 2)}

重要: 
- 2000トークン以内で回答
- 結論ファーストの構造
- 具体的で実行可能な提案のみ`

    return compactPrompt
  }

  /**
   * AI応答を構造化
   */
  private async structureAIResponse(
    rawResponse: unknown,
    request: AIAnalysisRequest,
  ): Promise<AIAnalysisResponse> {
    // Claude APIの応答をパース
    let parsedResponse: any
    try {
      if (typeof rawResponse === 'string') {
        // JSON文字列の場合
        const jsonMatch = rawResponse.match(/\{[\s\S]*\}/)
        if (jsonMatch) {
          parsedResponse = JSON.parse(jsonMatch[0])
        } else {
          throw new Error('No JSON found in response')
        }
      } else {
        parsedResponse = rawResponse
      }
    } catch {
      // フォールバック: 構造化された応答を生成
      return this.generateFallbackResponse(request)
    }

    // 応答を標準形式に変換
    return {
      headline: {
        title: parsedResponse.headline?.title || this.generateFallbackHeadline(request.batteryLevel),
        subtitle: parsedResponse.headline?.subtitle || 'バランスの取れた一日を過ごしましょう',
        impactLevel: parsedResponse.headline?.impactLevel || this.determineImpactLevel(request.batteryLevel),
        confidence: parsedResponse.headline?.confidence || 85,
      },
      energyComment: parsedResponse.energyComment || this.generateEnergyComment(request.batteryLevel),
      tagInsights: this.processTagInsights(parsedResponse.tagInsights, request.userContext.activeTags),
      aiActionSuggestions: this.processActionSuggestions(parsedResponse.aiActionSuggestions, request),
      detailAnalysis: parsedResponse.detailAnalysis || this.generateDetailAnalysis(request),
      dataQuality: {
        healthDataCompleteness: this.calculateDataCompleteness(request),
        weatherDataAge: 15, // デフォルト値
        analysisTimestamp: new Date().toISOString(),
      },
      generatedAt: new Date().toISOString(),
    }
  }

  /**
   * フォールバック応答生成
   */
  private generateFallbackResponse(request: AIAnalysisRequest): AIAnalysisResponse {
    return {
      headline: {
        title: this.generateFallbackHeadline(request.batteryLevel),
        subtitle: 'システム分析による基本的なアドバイスです',
        impactLevel: this.determineImpactLevel(request.batteryLevel),
        confidence: 70,
      },
      energyComment: this.generateEnergyComment(request.batteryLevel),
      tagInsights: [],
      aiActionSuggestions: this.generateBasicActionSuggestions(request),
      detailAnalysis: 'エネルギーレベルと環境要因に基づく基本分析です。',
      dataQuality: {
        healthDataCompleteness: this.calculateDataCompleteness(request),
        weatherDataAge: 15,
        analysisTimestamp: new Date().toISOString(),
      },
      generatedAt: new Date().toISOString(),
    }
  }

  private generateFallbackHeadline(energyLevel: number): string {
    if (energyLevel > 70) return 'エネルギー充分'
    if (energyLevel > 40) return 'バランス良好'
    if (energyLevel > 20) return 'エネルギー低下'
    return '要注意レベル'
  }

  private determineImpactLevel(energyLevel: number): 'low' | 'medium' | 'high' | 'critical' {
    if (energyLevel > 70) return 'low'
    if (energyLevel > 40) return 'medium'
    if (energyLevel > 20) return 'medium'
    return 'high'
  }

  private generateEnergyComment(energyLevel: number): string {
    if (energyLevel > 70) return '調子が良いですね！今日のエネルギーを有効活用しましょう。'
    if (energyLevel > 40) return 'バランスの取れた状態を保っています。'
    if (energyLevel > 20) return '少し疲れが見えます。無理をせず、ペースを調整してみませんか？'
    return 'エネルギーが低下しています。十分な休息を取りましょう。'
  }

  private processTagInsights(_rawInsights: any, activeTags: string[]): any[] {
    // TODO: タグ別インサイトの処理
    return activeTags.map((tag) => ({
      tag,
      icon: this.getTagIcon(tag),
      message: '関心分野に基づく分析結果です',
      urgency: 'info',
    }))
  }

  private processActionSuggestions(rawSuggestions: any[], request: AIAnalysisRequest): any[] {
    if (rawSuggestions && Array.isArray(rawSuggestions)) {
      return rawSuggestions.slice(0, 3) // 最大3つまで
    }
    return this.generateBasicActionSuggestions(request)
  }

  private generateBasicActionSuggestions(request: AIAnalysisRequest): any[] {
    const suggestions = []

    if (request.batteryLevel < 50) {
      suggestions.push({
        title: '深呼吸でリセット',
        description: '3回の深呼吸で気持ちを整えませんか？',
        actionType: 'rest',
        estimatedTime: '1分',
        difficulty: 'easy',
      })
    }

    if (request.environmentalContext.humidity < 40) {
      suggestions.push({
        title: '水分補給',
        description: '乾燥している環境です。コップ一杯の水で潤いを',
        actionType: 'hydrate',
        estimatedTime: '1分',
        difficulty: 'easy',
      })
    }

    return suggestions
  }

  private generateDetailAnalysis(request: AIAnalysisRequest): string {
    return `現在のエネルギーレベル${request.batteryLevel.toFixed(1)}%は、睡眠と活動のバランスを反映しています。環境要因（湿度${request.environmentalContext.humidity.toFixed(0)}%、気圧変化${request.environmentalContext.pressureTrend.toFixed(1)}hPa）も考慮した総合的な分析結果です。`
  }

  private calculateDataCompleteness(request: AIAnalysisRequest): number {
    let completeness = 0
    let totalFields = 0

    // 生物学的データの完全性
    if (request.biologicalContext.sleepDeep > 0) completeness++
    if (request.biologicalContext.sleepRem > 0) completeness++
    if (request.biologicalContext.steps > 0) completeness++
    if (request.biologicalContext.activeCalories > 0) completeness++
    totalFields += 4

    // 環境データの完全性
    if (request.environmentalContext.humidity > 0) completeness++
    if (Math.abs(request.environmentalContext.pressureTrend) > 0) completeness++
    totalFields += 2

    return Math.round((completeness / totalFields) * 100)
  }

  private getTagIcon(tag: string): string {
    const iconMap: Record<string, string> = {
      work: 'square.stack.3d.up',
      beauty: 'sparkles',
      diet: 'fork.knife.circle',
      sleep: 'bed.double.circle',
      fitness: 'figure.run.circle',
      chill: 'leaf',
    }
    return iconMap[tag] || 'questionmark.circle'
  }

  private validateResponseQuality(response: AIAnalysisResponse): void {
    if (!response.headline.title || response.headline.title.length < 3) {
      throw new APIError('Invalid headline title', 502, 'INVALID_RESPONSE_QUALITY')
    }

    if (!response.energyComment || response.energyComment.length < 10) {
      throw new APIError('Invalid energy comment', 502, 'INVALID_RESPONSE_QUALITY')
    }

    if (response.headline.confidence < 0 || response.headline.confidence > 100) {
      throw new APIError('Invalid confidence score', 502, 'INVALID_RESPONSE_QUALITY')
    }
  }
}