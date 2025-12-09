/**
 * @fileoverview Enhanced AI Analysis Service
 *
 * 関心分野別の専門AI分析サービス。
 * フォーカスタグに応じた専門的なプロンプトと
 * 「今日のトライ」提案を生成します。
 */

import type {
  AIAnalysisRequest,
  AIAnalysisResponse,
  FocusTagType,
} from '../types/ai-analysis'
import { APIError } from '../utils/errors'
import { ClaudeAIAnalysisService } from './claude-ai-analysis'
import {
  FocusAreaPromptBuilder,
  TodaysTryContextAnalyzer,
} from './focus-area-prompts'

/**
 * AI分析サービス
 * 関心分野専門化とコスト最適化を実現
 */
export class AIAnalysisService {
  /**
   * 関心分野に特化したAI分析を実行
   */
  async generateFocusAreaAnalysis(
    request: AIAnalysisRequest,
    apiKey: string,
  ): Promise<AIAnalysisResponse> {
    try {
      console.log(
        '🧠 Starting AI analysis for focus areas:',
        request.userContext.activeTags,
      )

      // 1. 今日の分析対象分野をランダム選択
      const todaysFocus = this.selectTodaysFocus(request.userContext.activeTags)
      console.log("🎯 Today's focus selected:", todaysFocus)

      // 2. 最適な「トライ」機会を分析
      TodaysTryContextAnalyzer.analyzeBestTryOpportunity(request)
      console.log('✨ Try opportunity analyzed')

      // 3. 選択された分野特化プロンプト構築
      const focusPrompt = FocusAreaPromptBuilder.buildFocusSpecificPrompt(
        request,
        request.userContext.language,
        todaysFocus,
      )
      console.log('📝 Focus-specific prompt built for:', todaysFocus)

      // 3. コスト最適化されたプロンプト生成
      const optimizedPrompt = this.optimizePromptForCost(focusPrompt, request)
      console.log('💰 Prompt optimized for cost')

      // 4. Claude AI呼び出し（詳細で個人的なレスポンス）
      console.log('🚀 Calling Claude 3.5 Sonnet...')
      const rawResponse = await ClaudeAIAnalysisService.generateHealthAnalysis({
        prompt: optimizedPrompt,
        apiKey,
        language: request.userContext.language,
        maxTokens: 2000, // Claude安定出力用
      })
      console.log(
        '🤖 Raw AI response received:',
        JSON.stringify(rawResponse, null, 2),
      )

      // 5. レスポンス構造化と検証
      const structuredResponse = await this.structureAIResponse(
        rawResponse,
        request,
      )
      console.log('🏗️ Response structured and validated')

      // 6. 品質検証 (一時的に無効化)
      this.validateResponseQuality(structuredResponse)
      console.log('✅ Response quality validation skipped for debugging')

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
  private optimizePromptForCost(
    prompt: string,
    request: AIAnalysisRequest,
  ): string {
    // トークン最適化：短縮キー + 全データ保持（Claude処理能力活用）
    const optimizedData = {
      eng: request.batteryLevel, // energy → eng
      trd: request.batteryTrend, // trend → trd
      tags: request.userContext.activeTags, // 全タグ（詳細分析用）
      tod: request.userContext.timeOfDay, // timeOfDay → tod
      env: {
        p_chg: request.environmentalContext.pressureTrend, // pressure_change → p_chg
        hmd: request.environmentalContext.humidity, // humidity → hmd
        temp: request.environmentalContext.feelsLike,
        uv: request.environmentalContext.uvIndex, // UV追加
      },
      bio: {
        hrv: request.biologicalContext.hrvStatus,
        slp_d: request.biologicalContext.sleepDeep, // sleep_deep → slp_d
        slp_r: request.biologicalContext.sleepRem, // sleep_rem → slp_r
        steps: request.biologicalContext.steps,
        cal: request.biologicalContext.activeCalories, // calories → cal
        rhr: request.biologicalContext.rhrStatus, // resting_heart_rate → rhr
        resp: request.biologicalContext.respiratoryRate, // respiratory → resp
      },
    }

    const compactPrompt = `${prompt}

## 分析データ (トークン最適化版)
${JSON.stringify(optimizedData, null, 2)}

Claude専用指示: 
- ユーザーの選択した関心分野(${request.userContext.activeTags.join(', ')})に焦点を当てる
- 最も関連性の高い1つの分野のinsightのみ生成
- 今日最も重要な1つのアクションのみ提案
- 環境要因と体調データの相関関係を重視
- 必ずJSON形式のみで回答`

    return compactPrompt
  }

  /**
   * 今日の分析対象分野をランダム選択
   */
  private selectTodaysFocus(activeTags: string[]): string[] {
    if (activeTags.length === 0) {
      return ['general'] // デフォルト
    }

    // 単体分野 vs 組み合わせをランダム決定
    const useCombo = Math.random() < 0.3 // 30%の確率で組み合わせ

    if (useCombo && activeTags.length >= 2) {
      // 組み合わせ選択（例: beauty + diet）
      const shuffled = [...activeTags].sort(() => Math.random() - 0.5)
      const combo = shuffled.slice(0, 2)
      console.log('🎨 Combination focus selected:', combo.join(' + '))
      return combo
    } else {
      // 単体分野選択
      const randomIndex = Math.floor(Math.random() * activeTags.length)
      const singleFocus = activeTags[randomIndex]
      if (!singleFocus) {
        return ['general'] // フォールバック
      }
      console.log('🎯 Single focus selected:', singleFocus)
      return [singleFocus]
    }
  }

  /**
   * AI応答を構造化
   */
  private async structureAIResponse(
    rawResponse: unknown,
    request: AIAnalysisRequest,
  ): Promise<AIAnalysisResponse> {
    // === RESPONSE STRUCTURING ANALYSIS ===
    console.log('🏗️ STRUCTURING AI RESPONSE')
    console.log('='.repeat(50))
    console.log('📥 Raw response type:', typeof rawResponse)
    console.log(
      '📝 Raw response preview:',
      typeof rawResponse === 'string'
        ? `${(rawResponse as string).substring(0, 300)}...`
        : 'Not a string',
    )
    console.log('='.repeat(50))

    // Gemini APIの応答をパース
    let parsedResponse: unknown
    try {
      if (typeof rawResponse === 'string') {
        console.log('🔍 Parsing string response...')
        // ```json マーカーを除去してJSON部分を抽出
        const cleanJson = (rawResponse as string)
          .replace(/```json\s*/g, '')
          .replace(/```\s*$/g, '')
          .trim()

        console.log(
          '🧹 Cleaned JSON preview:',
          `${cleanJson.substring(0, 200)}...`,
        )

        const jsonMatch = cleanJson.match(/\{[\s\S]*\}/)
        if (jsonMatch) {
          console.log('✅ JSON pattern found, parsing...')
          parsedResponse = JSON.parse(jsonMatch[0])
          console.log('✅ JSON parsed successfully')
        } else {
          console.error('❌ No JSON pattern found in response')
          throw new Error('No JSON found in response')
        }
      } else {
        console.log('📦 Using object response directly')
        parsedResponse = rawResponse
      }
    } catch (parseError) {
      console.error('❌ JSON parsing failed:', parseError)
      console.error('❌ Raw response was:', rawResponse)
      // フォールバック: 構造化された応答を生成
      return this.generateFallbackResponse(request)
    }

    // 応答を標準形式に変換
    console.log('🔧 Converting to standard format...')
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const response = parsedResponse as any
    console.log('🎯 Using Gemini headline:', !!response.headline?.title)
    console.log('💬 Using Gemini energyComment:', !!response.energyComment)
    console.log(
      '🏷️ Using Gemini tagInsights:',
      Array.isArray(response.tagInsights),
    )
    console.log(
      '💡 Using Gemini suggestions:',
      Array.isArray(response.aiActionSuggestions),
    )

    const structuredResponse = {
      headline: {
        title:
          response.headline?.title ||
          this.generateFallbackHeadline(request.batteryLevel),
        subtitle:
          response.headline?.subtitle || 'バランスの取れた一日を過ごしましょう',
        impactLevel:
          response.headline?.impactLevel ||
          this.determineImpactLevel(request.batteryLevel),
        confidence: response.headline?.confidence || 85,
      },
      energyComment:
        response.energyComment ||
        this.generateEnergyComment(request.batteryLevel),
      tagInsights: this.processTagInsights(
        response.tagInsights,
        request.userContext.activeTags,
      ),
      aiActionSuggestions: this.processActionSuggestions(
        response.aiActionSuggestions,
        request,
      ),
      detailAnalysis:
        response.detailAnalysis || this.generateDetailAnalysis(request),
      dataQuality: {
        healthDataCompleteness: this.calculateDataCompleteness(request),
        weatherDataAge: 15, // デフォルト値
        analysisTimestamp: new Date().toISOString(),
      },
      generatedAt: new Date().toISOString(),
    }

    console.log('📤 FINAL STRUCTURED RESPONSE:')
    console.log('  - Headline title:', structuredResponse.headline.title)
    console.log(
      '  - Energy comment length:',
      structuredResponse.energyComment.length,
    )
    console.log(
      '  - Tag insights count:',
      structuredResponse.tagInsights.length,
    )
    console.log(
      '  - AI suggestions count:',
      structuredResponse.aiActionSuggestions.length,
    )
    console.log('='.repeat(50))

    return structuredResponse
  }

  /**
   * フォールバック応答生成
   */
  private generateFallbackResponse(
    request: AIAnalysisRequest,
  ): AIAnalysisResponse {
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

  private determineImpactLevel(
    energyLevel: number,
  ): 'low' | 'medium' | 'high' | 'critical' {
    if (energyLevel > 70) return 'low'
    if (energyLevel > 40) return 'medium'
    if (energyLevel > 20) return 'medium'
    return 'high'
  }

  private generateEnergyComment(energyLevel: number): string {
    if (energyLevel > 70)
      return '調子が良いですね！今日のエネルギーを有効活用しましょう。'
    if (energyLevel > 40) return 'バランスの取れた状態を保っています。'
    if (energyLevel > 20)
      return '少し疲れが見えます。無理をせず、ペースを調整してみませんか？'
    return 'エネルギーが低下しています。十分な休息を取りましょう。'
  }

  private processTagInsights(
    _rawInsights: unknown,
    activeTags: string[],
  ): Array<{
    tag: FocusTagType
    icon: string
    message: string
    urgency: 'info' | 'warning' | 'critical'
  }> {
    // TODO: タグ別インサイトの処理
    return activeTags.map((tag) => ({
      tag: tag as FocusTagType,
      icon: this.getTagIcon(tag),
      message: '関心分野に基づく分析結果です',
      urgency: 'info' as const,
    }))
  }

  private processActionSuggestions(
    rawSuggestions: unknown[],
    request: AIAnalysisRequest,
  ): Array<{
    title: string
    description: string
    actionType: 'rest' | 'hydrate' | 'exercise' | 'focus' | 'social' | 'beauty'
    estimatedTime: string
    difficulty: 'easy' | 'medium' | 'hard'
  }> {
    if (rawSuggestions && Array.isArray(rawSuggestions)) {
      return rawSuggestions.slice(0, 3) as Array<{
        title: string
        description: string
        actionType:
          | 'rest'
          | 'hydrate'
          | 'exercise'
          | 'focus'
          | 'social'
          | 'beauty'
        estimatedTime: string
        difficulty: 'easy' | 'medium' | 'hard'
      }>
    }
    return this.generateBasicActionSuggestions(request)
  }

  private generateBasicActionSuggestions(request: AIAnalysisRequest): Array<{
    title: string
    description: string
    actionType: 'rest' | 'hydrate' | 'exercise' | 'focus' | 'social' | 'beauty'
    estimatedTime: string
    difficulty: 'easy' | 'medium' | 'hard'
  }> {
    const suggestions: Array<{
      title: string
      description: string
      actionType:
        | 'rest'
        | 'hydrate'
        | 'exercise'
        | 'focus'
        | 'social'
        | 'beauty'
      estimatedTime: string
      difficulty: 'easy' | 'medium' | 'hard'
    }> = []

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
      throw new APIError(
        'Invalid headline title',
        502,
        'INVALID_RESPONSE_QUALITY',
      )
    }

    if (!response.energyComment || response.energyComment.length < 10) {
      throw new APIError(
        'Invalid energy comment',
        502,
        'INVALID_RESPONSE_QUALITY',
      )
    }

    if (
      response.headline.confidence < 0 ||
      response.headline.confidence > 100
    ) {
      throw new APIError(
        'Invalid confidence score',
        502,
        'INVALID_RESPONSE_QUALITY',
      )
    }
  }
}
