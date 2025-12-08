/**
 * @fileoverview Gemini AI Analysis Service
 *
 * Google Gemini 2.0 Flash を使用したAI分析サービス。
 * ヘルスケアデータの包括的分析とパーソナライズされた
 * アドバイス生成を提供します。
 */

import { GoogleGenerativeAI } from '@google/generative-ai'

/**
 * Gemini AI分析リクエスト
 */
export interface GeminiAnalysisRequest {
  prompt: string
  apiKey: string
  language?: 'ja' | 'en'
  maxTokens?: number
  temperature?: number
}

/**
 * Gemini AI分析サービス
 */
export class GeminiAIAnalysisService {
  /**
   * Gemini 2.0 Flash でヘルスケア分析を生成
   */
  static async generateHealthAnalysis(request: GeminiAnalysisRequest): Promise<string> {
    const { prompt, apiKey, maxTokens = 2000, temperature = 0.7, language = 'ja' } = request

    // Gemini クライアント初期化
    const genAI = new GoogleGenerativeAI(apiKey)
    
    // Gemini 2.0 Flash モデル設定
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        maxOutputTokens: maxTokens,
        temperature: temperature,
        topP: 0.9,
        topK: 40,
      },
    })

    try {
      // Gemini用プロンプト最適化
      const optimizedPrompt = this.optimizePromptForGemini(prompt, language)

      // リトライロジック付きでAPI呼び出し
      let lastError: Error | null = null
      const maxRetries = 3

      for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          const result = await model.generateContent(optimizedPrompt)
          const response = await result.response
          const text = response.text()

          // レスポンス検証
          if (!text || text.trim().length === 0) {
            throw new Error('Empty response from Gemini API')
          }

          return text

        } catch (error) {
          lastError = error as Error
          
          if (attempt < maxRetries) {
            // 指数バックオフで再試行
            const delay = Math.pow(2, attempt) * 1000
            await new Promise(resolve => setTimeout(resolve, delay))
            continue
          }
        }
      }

      throw lastError || new Error('Gemini API failed after retries')

    } catch (error) {
      console.error('Gemini API error:', error)
      throw new Error(`Gemini AI analysis failed: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  /**
   * プロンプトを Gemini 2.0 Flash 形式に最適化
   */
  private static optimizePromptForGemini(originalPrompt: string, language: string): string {
    let optimizedPrompt = originalPrompt

    // Gemini 2.0 Flash 特有の最適化
    if (language === 'ja') {
      optimizedPrompt += '\n\n重要指示: 必ず日本語で回答してください。JSON形式を厳密に守ってください。'
    } else {
      optimizedPrompt += '\n\nIMPORTANT: Respond in English. Strictly follow JSON format.'
    }

    // JSON 出力の強調
    optimizedPrompt += '\n\nResponse must be valid JSON only, no additional explanations or text outside JSON.'

    return optimizedPrompt
  }

  /**
   * Gemini API の可用性チェック
   */
  static async checkAvailability(apiKey: string): Promise<boolean> {
    try {
      const genAI = new GoogleGenerativeAI(apiKey)
      const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' })
      
      // 簡単なテスト プロンプト
      const result = await model.generateContent('Test connection. Respond with "OK".')
      const response = await result.response
      const text = response.text()
      
      return text.includes('OK')
    } catch {
      return false
    }
  }

  /**
   * 使用量情報取得（概算）
   */
  static estimateTokenUsage(prompt: string): number {
    // 概算: 日本語1文字 ≈ 2-3トークン、英語1単語 ≈ 1.3トークン
    const japaneseChars = (prompt.match(/[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]/g) || []).length
    const englishWords = prompt.split(/\s+/).length
    
    return Math.ceil(japaneseChars * 2.5 + englishWords * 1.3)
  }
}

