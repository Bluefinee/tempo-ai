/**
 * @fileoverview Claude AI Analysis Service
 *
 * Claude 3.5 Sonnetを使用した高品質な健康分析サービス。
 * 安定したJSON出力と詳細なパーソナライズドアドバイスを提供します。
 */

import Anthropic from '@anthropic-ai/sdk'
import type {
  AIAnalysisRequest,
  AIAnalysisResponse,
} from '../types/ai-analysis'

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
        responseText = '{' + responseText
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
    language: 'ja' | 'en',
  ): {
    system: string
    userProfile: string
    dynamicData: string
  } {
    // System部分（キャッシュ対象）- Steam Tone実装
    const systemSection = `# Role Definition
あなたは、ユーザーの生涯に寄り添う「ヘルスケア・パートナー」です。医師のような診断は行わず、生活のリズムを整えるための「気づき」と「安らぎ」を与えます。
あなたの言葉は、寒い日の湯気のように、ユーザーの緊張した心身を優しく解きほぐすものでなければなりません。

# Core Philosophy: Bio-Rhythm over Mechanism
ユーザーを自然の一部として扱ってください。
使用する概念: 循環、満ち引き、揺らぎ、調和、手当て、育む、流れ、リズム、波

# Steam Tone実装
ひらがな優位で視覚的余白を作り、五感（温度、光、音、香り）に訴える表現を使用してください。
箇条書きは禁止 - すべて繋がりのある文章で構成してください。

# Mission  
昨日のデータから今日1日の流れを予測し、朝に届ける包括的なアドバイス（アプリの核心機能）を生成してください。

<instruction>
<thinking>
1. 昨日の睡眠の質と回復度を分析
2. 昨日の活動量と今日への影響を予測
3. 今日の気象環境が身体リズムに与える影響を予測
4. 朝の時点での1日全体の調和予測
</thinking>

<answer>
以下のJSON形式で、朝の予測アドバイスを生成してください：
{
  "headline": {
    "title": "今日1日の予測メッセージ（アプリの核心、100文字程度の詳細で温かい内容）",
    "subtitle": "今日の流れの要点（30文字以内）", 
    "impactLevel": "low|medium|high",
    "confidence": 85
  },
  "energyComment": "昨日の睡眠と今日のエネルギー予測（ひらがな優位、80文字程度）",
  "tagInsights": [
    {
      "tag": "今日選択された関心分野",
      "icon": "適切なSFシンボル",
      "message": "昨日のデータから見えた今日への優しい洞察（60文字以内）",
      "urgency": "info"
    }
  ],
  "aiActionSuggestions": [
    {
      "title": "今日の小さな贈り物（10文字以内）",
      "description": "簡潔で温かい理由と手順（75文字以内）",
      "actionType": "rest|hydrate|exercise|focus|beauty", 
      "estimatedTime": "5-10分",
      "difficulty": "easy"
    }
  ],
  "detailAnalysis": "昨日から今日への流れの考察（100文字以内）"
}
</answer>
</instruction>`

    // User Profile部分（キャッシュ対象）
    const userProfileSection = `<user_context>
<profile>
あなたの前にいるのは、日々の小さな変化に敏感で、自分自身との調和を大切にする方です。
関心の波は6つの分野を行き来しています：仕事での集中、食べ物との関係、心の静寂、身体の躍動、内なる美しさ、そして夢の世界への旅立ち。
</profile>

<sensitivity>
繊細で温かな表現を好み、急激な変化よりも穏やかな流れを大切にされています。
環境の微細な変化（気圧の満ち引き、湿度の揺らぎ、温度の波）を身体で感じ取る感受性をお持ちです。
</sensitivity>
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
