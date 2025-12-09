/**
 * @fileoverview Gemini AI Analysis Service
 *
 * Google Gemini 2.5 Flash を使用したAI分析サービス。
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
  static async generateHealthAnalysis(
    request: GeminiAnalysisRequest,
  ): Promise<string> {
    const {
      prompt,
      apiKey,
      maxTokens = 2000,
      temperature = 0.7,
      language = 'ja',
    } = request

    // Gemini クライアント初期化
    const genAI = new GoogleGenerativeAI(apiKey)

    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      generationConfig: {
        maxOutputTokens: maxTokens,
        temperature: 0.3,
        topP: 0.8,
        topK: 32,
      },
    })

    try {
      // Gemini用プロンプト最適化
      const optimizedPrompt = GeminiAIAnalysisService.optimizePromptForGemini(
        prompt,
        language,
      )

      // === GEMINI REQUEST DETAILS ===
      console.log('='.repeat(50))
      console.log('📝 GEMINI PROMPT DETAILS')
      console.log('='.repeat(50))
      console.log('📊 プロンプト文字数:', optimizedPrompt.length)
      console.log('📝 送信プロンプト内容:')
      console.log(optimizedPrompt)
      console.log('⚙️ Generation Config:')
      console.log('  - Model: gemini-2.5-flash')
      console.log('  - maxOutputTokens:', maxTokens)
      console.log('  - temperature:', temperature)
      console.log('='.repeat(50))

      // リトライロジック付きでAPI呼び出し
      let lastError: Error | null = null
      const maxRetries = 3

      for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          const result = await model.generateContent(optimizedPrompt)
          const response = await result.response
          const text = response.text()

          // === GEMINI RESPONSE ANALYSIS ===
          console.log('🤖 GEMINI RESPONSE ANALYSIS')
          console.log('='.repeat(50))
          console.log('📏 Response length:', text?.length || 0)
          console.log(
            '📝 Response preview:',
            text?.substring(0, 200) || 'No text',
          )
          console.log('🧮 Token usage:')
          console.log(
            '  - Prompt tokens:',
            response.usageMetadata?.promptTokenCount || 0,
          )
          console.log(
            '  - Total tokens:',
            response.usageMetadata?.totalTokenCount || 0,
          )
          console.log(
            '🏁 Finish reason:',
            response.candidates?.[0]?.finishReason || 'unknown',
          )
          console.log('='.repeat(50))

          // レスポンス検証
          if (!text || text.trim().length === 0) {
            console.error('❌ GEMINI RESPONSE FAILED')
            console.error('❌ Empty text content')
            console.error('❌ Full response object:')
            console.error(JSON.stringify(response, null, 2))
            throw new Error('Empty response from Gemini API')
          }

          console.log('✅ Gemini API response validated successfully')
          return text
        } catch (error) {
          lastError = error as Error

          if (attempt < maxRetries) {
            // 指数バックオフで再試行
            const delay = 2 ** attempt * 1000
            await new Promise((resolve) => setTimeout(resolve, delay))
          }
        }
      }

      throw lastError || new Error('Gemini API failed after retries')
    } catch (error) {
      console.error('Gemini API error:', error)
      throw new Error(
        `Gemini AI analysis failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
      )
    }
  }

  /**
   * プロンプトを Gemini 2.0 Flash 形式に最適化
   */
  private static optimizePromptForGemini(
    originalPrompt: string,
    language: string,
  ): string {
    let optimizedPrompt = originalPrompt

    // Gemini 2.0 Flash 特有の最適化
    if (language === 'ja') {
      optimizedPrompt +=
        '\n\n重要指示: 必ず日本語で回答してください。JSON形式を厳密に守ってください。'
    } else {
      optimizedPrompt +=
        '\n\nIMPORTANT: Respond in English. Strictly follow JSON format.'
    }

    // JSON 出力の強調
    optimizedPrompt +=
      '\n\nResponse must be valid JSON only, no additional explanations or text outside JSON.'

    return optimizedPrompt
  }

  /**
   * Gemini API の可用性チェック
   */
  static async checkAvailability(apiKey: string): Promise<boolean> {
    try {
      const genAI = new GoogleGenerativeAI(apiKey)
      const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' })

      // 簡単なテスト プロンプト
      const result = await model.generateContent(
        'Test connection. Respond with "OK".',
      )
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
    const japaneseChars = (
      prompt.match(/[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]/g) || []
    ).length
    const englishWords = prompt.split(/\s+/).length

    return Math.ceil(japaneseChars * 2.5 + englishWords * 1.3)
  }
}
