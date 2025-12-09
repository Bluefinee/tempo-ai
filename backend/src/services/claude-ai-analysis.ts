/**
 * @fileoverview Claude AI Analysis Service
 *
 * Claude 3.5 Sonnetを使用した高品質な健康分析サービス。
 * 安定したJSON出力と詳細なパーソナライズドアドバイスを提供します。
 */

import Anthropic from '@anthropic-ai/sdk'

/**
 * Claude AI分析リクエスト
 */
interface ClaudeAnalysisRequest {
  prompt: string
  apiKey: string
  maxTokens?: number
  temperature?: number
  language?: 'ja' | 'en'
}

/**
 * Claude AI分析サービス
 * 安定した出力と高品質な分析を提供
 */
export class ClaudeAIAnalysisService {
  /**
   * Claude 3.5 Sonnetによる健康分析（Prompt Caching対応）
   */
  static async generateHealthAnalysis(
    request: ClaudeAnalysisRequest,
  ): Promise<string> {
    const {
      prompt,
      apiKey,
      maxTokens = 2000,
      temperature = 0.3,
      language = 'ja',
    } = request

    console.log('🚀 Initializing Claude 3.5 Sonnet with Prompt Caching...')

    // Claude クライアント初期化
    const anthropic = new Anthropic({
      apiKey: apiKey,
    })

    try {
      // プロンプトをXML構造に最適化（ベストプラクティス適用）
      const {
        system: systemPrompt,
        userProfile,
        dynamicData,
      } = ClaudeAIAnalysisService.optimizePromptForClaude(prompt, language)

      // === CLAUDE REQUEST DETAILS ===
      console.log('='.repeat(60))
      console.log('📝 CLAUDE AI ANALYSIS REQUEST')
      console.log('='.repeat(60))

      console.log('🧠 SYSTEM PROMPT (cached):')
      console.log('-'.repeat(40))
      console.log(systemPrompt)
      console.log('-'.repeat(40))

      console.log('👤 USER PROFILE (cached):')
      console.log('-'.repeat(40))
      console.log(userProfile)
      console.log('-'.repeat(40))

      console.log("📊 TODAY'S DYNAMIC DATA:")
      console.log('-'.repeat(40))
      console.log(dynamicData)
      console.log('-'.repeat(40))

      console.log('⚙️ CLAUDE CONFIG:')
      console.log(
        '  - Model: claude-3-5-haiku-20241022 (fast & cost-effective)',
      )
      console.log('  - maxTokens:', maxTokens)
      console.log('  - temperature:', temperature)
      console.log('  - System parameter: ✅ enabled')
      console.log('  - JSON Prefill: ✅ enabled')
      console.log('  - Prompt Caching: ✅ enabled')
      console.log('='.repeat(60))

      const message = await anthropic.messages.create({
        // model: 'claude-3-5-sonnet-20241022', // 高品質版（後で切り替え用）
        // もしくは　claude-3-5-haiku-20241022
        model: 'claude-sonnet-4-20250514', // 高速・低コスト版
        max_tokens: maxTokens,
        temperature: temperature,
        // System Parameter（ベストプラクティス：役割定義をsystemに配置）
        system: systemPrompt,
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: userProfile,
                cache_control: { type: 'ephemeral' }, // キャッシュ対象
              },
              {
                type: 'text',
                text: dynamicData, // 動的データはキャッシュしない
              },
            ],
          },
          {
            // JSON Prefill（ベストプラクティス：JSON出力を強制）
            role: 'assistant',
            content: '{',
          },
        ],
      })

      // === CLAUDE RESPONSE ANALYSIS ===
      console.log('='.repeat(60))
      console.log('🤖 CLAUDE RESPONSE RECEIVED')
      console.log('='.repeat(60))

      let responseText =
        message.content[0]?.type === 'text' ? message.content[0].text : ''

      // JSON Prefill対応：先頭に'{' を追加してJSONを完成
      if (responseText && !responseText.trim().startsWith('{')) {
        responseText = `{${responseText}`
        console.log('🔧 JSON Prefill applied - added opening brace')
      }

      console.log('📝 FULL CLAUDE RESPONSE:')
      console.log('-'.repeat(40))
      console.log(responseText)
      console.log('-'.repeat(40))

      console.log('📊 RESPONSE STATISTICS:')
      console.log('  📏 Length:', responseText.length, 'characters')
      console.log('  🧮 Input tokens:', message.usage.input_tokens)
      console.log('  🧮 Output tokens:', message.usage.output_tokens)
      console.log('  🏁 Stop reason:', message.stop_reason)
      console.log(
        '  💾 Cache creation:',
        message.usage.cache_creation_input_tokens || 0,
        'tokens',
      )
      console.log(
        '  💾 Cache hit:',
        message.usage.cache_read_input_tokens || 0,
        'tokens',
      )
      console.log('='.repeat(60))

      // レスポンス検証
      if (!responseText || responseText.trim().length === 0) {
        console.error('❌ CLAUDE RESPONSE FAILED')
        console.error('❌ Empty response content')
        console.error(
          '❌ Full message object:',
          JSON.stringify(message, null, 2),
        )
        throw new Error('Empty response from Claude API')
      }

      console.log('✅ Claude API response validated successfully')
      return responseText
    } catch (error) {
      console.error('❌ Claude API error:', error)
      throw error
    }
  }

  /**
   * Claude用プロンプト最適化（XMLタグ構造 + CoT対応）
   */
  private static optimizePromptForClaude(
    prompt: string,
    _language: 'ja' | 'en', // 将来の多言語対応で使用予定
  ): {
    system: string
    userProfile: string
    dynamicData: string
  } {
    // System部分（キャッシュ対象）- 実用的なトーン
    const systemSection = `# Role Definition
あなたは、経験豊富なヘルスアドバイザーです。ユーザーの健康データを分析し、実践的で具体的なアドバイスを提供します。
医療診断は行わず、生活習慣の改善と健康維持のための実用的な提案に焦点を当てます。

# Core Philosophy: Evidence-Based Practical Advice
科学的根拠に基づいた実用性の高いアドバイスを提供してください。
使用する概念: 効率、改善、実践、習慣、バランス、パフォーマンス、健康管理

# Communication Style
明確で理解しやすい表現を使用し、具体的な行動提案を中心に構成してください。
箇条書きや数値を活用し、実行可能なアクションプランを提示してください。

# Mission  
昨日のデータから今日の健康状態を分析し、朝に届ける実用的なアドバイスを生成してください。

<instruction>
<thinking>
1. 昨日の睡眠データと回復状況を分析
2. 昨日の活動量と今日への影響を評価
3. 今日の天候が活動に与える影響を予測
4. 朝の時点での1日の活動計画を提案
</thinking>

<answer>
以下のJSON形式で、実用的な朝のアドバイスを生成してください：
{
  "headline": {
    "title": "今日の状況評価と重要な推奨事項（80文字以内、具体的で明確）",
    "subtitle": "最優先アクション（30文字以内）", 
    "impactLevel": "low|medium|high",
    "confidence": 85
  },
  "energyComment": "昨日の睡眠データに基づく今日のエネルギー状態の分析（70文字程度）",
  "tagInsights": [
    {
      "tag": "今日の重点分野",
      "icon": "適切なSFシンボル",
      "message": "データに基づく具体的な改善ポイント（60文字以内）",
      "urgency": "info"
    }
  ],
  "aiActionSuggestions": [
    {
      "title": "今日の推奨行動（10文字以内）",
      "description": "具体的な方法と期待される効果（75文字以内）",
      "actionType": "rest|hydrate|exercise|focus|beauty", 
      "estimatedTime": "5-10分",
      "difficulty": "easy"
    }
  ],
  "detailAnalysis": "データ分析結果と今日の行動指針（100文字以内）"
}
</answer>
</instruction>`

    // User Profile部分（キャッシュ対象）
    const userProfileSection = `<user_context>
<profile>
健康管理に関心があり、データに基づいた実用的なアドバイスを求めています。
主な関心分野：仕事の生産性向上、栄養管理、ストレス管理、運動習慣、美容・健康、睡眠の質向上。
</profile>

<preferences>
明確で実行しやすい提案を好み、科学的根拠のある健康管理方法を重視します。
環境要因（気圧、湿度、温度）が体調に与える影響を理解し、それに応じた対策を求めています。
</preferences>
</user_context>`

    // 動的データ部分
    const dynamicDataSection = `<daily_data>
${prompt}
</daily_data>`

    return {
      system: systemSection,
      userProfile: userProfileSection,
      dynamicData: dynamicDataSection,
    }
  }
}
