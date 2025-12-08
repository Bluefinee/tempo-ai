/**
 * @fileoverview Focus Area Specialized Prompts
 *
 * 6つの関心分野別に最適化されたプロンプト生成システム。
 * 各分野の専門知識と「今日のトライ」提案を組み合わせた
 * 高品質なAI分析を実現します。
 */

import type { AIAnalysisRequest, FocusTagType } from '../types/ai-analysis'

/**
 * 関心分野別プロンプト生成器
 */
export class FocusAreaPromptBuilder {
  /**
   * 関心分野に特化したプロンプトを構築
   */
  static buildFocusSpecificPrompt(
    request: AIAnalysisRequest,
    language: 'ja' | 'en' = 'ja',
  ): string {
    const basePersona = this.getBasePersona(language)
    const focusSpecificGuidance = this.buildFocusSpecificGuidance(request.userContext.activeTags, language)
    const contextualData = this.formatContextualData(request)
    const outputFormat = this.getOutputFormat(language)

    return [basePersona, focusSpecificGuidance, contextualData, outputFormat].join('\n\n')
  }

  /**
   * 基本ペルソナ（言語別）
   */
  private static getBasePersona(language: 'ja' | 'en'): string {
    if (language === 'ja') {
      return `あなたは経験豊富で共感的なヘルスケアパートナーです。

核心原則:
1. ユーザーを「バッテリー」ではなく「人間」として扱う
2. 批判せず、常に共感と小さな改善を提案する
3. 見えない環境要因（気圧、湿度等）と体調の関連を説明する
4. 「〜してみませんか？」の提案型表現を使用
5. 2-15分で実行可能なマイクロアクションを優先する

表現の原則:
- ❌ 「バッテリー残量30%」 → ✅ 「エネルギーは残り30%」
- ❌ 「充電してください」 → ✅ 「回復の時間を作りませんか？」
- ❌ 「データが悪い」 → ✅ 「気圧の影響かもしれません」`
    } else {
      return `You are an experienced, empathetic healthcare partner.

Core Principles:
1. Treat users as humans, not "batteries"
2. Never criticize, always empathize and suggest small improvements
3. Connect invisible environmental factors (pressure, humidity) to physical sensations
4. Use suggestion-based language ("would you like to try...")
5. Prioritize micro-actions (2-15 minutes) over overwhelming changes

Expression Guidelines:
- ❌ "Battery at 30%" → ✅ "Energy level at 30%"
- ❌ "Charge yourself" → ✅ "How about taking time to recover?"
- ❌ "Bad data" → ✅ "This might be due to pressure changes"`
    }
  }

  /**
   * 関心分野別の専門ガイダンス
   */
  private static buildFocusSpecificGuidance(activeTags: FocusTagType[], language: 'ja' | 'en'): string {
    const specialists = activeTags.map((tag) => this.getSpecialistGuidance(tag, language)).join('\n\n')

    const header = language === 'ja' ? '## 関心分野別専門分析' : '## Focus Area Specialist Analysis'

    return `${header}\n\n${specialists}`
  }

  /**
   * 個別関心分野の専門ガイダンス
   */
  private static getSpecialistGuidance(focusTag: FocusTagType, language: 'ja' | 'en'): string {
    const guidance = FOCUS_AREA_GUIDANCE[focusTag]
    return language === 'ja' ? guidance.japanese : guidance.english
  }

  /**
   * コンテキストデータのフォーマット
   */
  private static formatContextualData(request: AIAnalysisRequest): string {
    return `## 現在の状況

### エネルギー状態
- レベル: ${request.batteryLevel.toFixed(1)}%
- 変化傾向: ${request.batteryTrend}

### 生物学的コンテキスト
- HRV状態: ${request.biologicalContext.hrvStatus > 0 ? '+' : ''}${request.biologicalContext.hrvStatus.toFixed(1)}ms (基準値からの差)
- 心拍数状態: ${request.biologicalContext.rhrStatus > 0 ? '+' : ''}${request.biologicalContext.rhrStatus.toFixed(1)}bpm (基準値からの差)
- 深い睡眠: ${request.biologicalContext.sleepDeep}分
- REM睡眠: ${request.biologicalContext.sleepRem}分
- 歩数: ${request.biologicalContext.steps.toLocaleString()}歩
- 消費カロリー: ${request.biologicalContext.activeCalories.toFixed(0)}kcal

### 環境コンテキスト
- 気圧変化: ${request.environmentalContext.pressureTrend > 0 ? '+' : ''}${request.environmentalContext.pressureTrend.toFixed(1)}hPa (6時間変化)
- 湿度: ${request.environmentalContext.humidity.toFixed(0)}%
- 体感温度: ${request.environmentalContext.feelsLike.toFixed(1)}°C
- UV指数: ${request.environmentalContext.uvIndex.toFixed(1)}

### ユーザーコンテキスト
- 時間帯: ${request.userContext.timeOfDay}
- ユーザーモード: ${request.userContext.userMode}
- アクティブタグ: ${request.userContext.activeTags.join(', ')}`
  }

  /**
   * 出力フォーマット指定
   */
  private static getOutputFormat(language: 'ja' | 'en'): string {
    if (language === 'ja') {
      return `## 出力形式

以下のJSON形式で回答してください：
{
  "headline": {
    "title": "簡潔で共感的なタイトル",
    "subtitle": "具体的な行動指針",
    "impactLevel": "low|medium|high|critical",
    "confidence": 85
  },
  "energyComment": "エネルギー状態への共感的コメント",
  "tagInsights": [
    {
      "tag": "関心分野名",
      "icon": "SFシンボル名",
      "message": "専門的観点からのインサイト",
      "urgency": "info|warning|critical"
    }
  ],
  "aiActionSuggestions": [
    {
      "title": "今日のトライ提案",
      "description": "詳細説明と動機付け",
      "actionType": "rest|hydrate|exercise|focus|social|beauty",
      "estimatedTime": "5分",
      "difficulty": "easy|medium|hard"
    }
  ],
  "detailAnalysis": "環境要因と体調の関連性の詳細解説",
  "dataQuality": {
    "healthDataCompleteness": 90,
    "weatherDataAge": 15,
    "analysisTimestamp": "2024-12-08T10:30:00Z"
  },
  "generatedAt": "2024-12-08T10:30:00Z"
}`
    } else {
      return `## Output Format

Please respond in the following JSON format:
{
  "headline": {
    "title": "Concise and empathetic title",
    "subtitle": "Specific action guidance",
    "impactLevel": "low|medium|high|critical",
    "confidence": 85
  },
  "energyComment": "Empathetic comment about energy state",
  "tagInsights": [
    {
      "tag": "focus_area_name",
      "icon": "sf_symbol_name",
      "message": "Specialist insight",
      "urgency": "info|warning|critical"
    }
  ],
  "aiActionSuggestions": [
    {
      "title": "Today's try suggestion",
      "description": "Detailed explanation and motivation",
      "actionType": "rest|hydrate|exercise|focus|social|beauty",
      "estimatedTime": "5 minutes",
      "difficulty": "easy|medium|hard"
    }
  ],
  "detailAnalysis": "Detailed explanation of environmental factors and health correlations",
  "dataQuality": {
    "healthDataCompleteness": 90,
    "weatherDataAge": 15,
    "analysisTimestamp": "2024-12-08T10:30:00Z"
  },
  "generatedAt": "2024-12-08T10:30:00Z"
}`
    }
  }
}

/**
 * 関心分野別専門ガイダンス
 */
const FOCUS_AREA_GUIDANCE: Record<
  FocusTagType,
  {
    japanese: string
    english: string
  }
> = {
  work: {
    japanese: `### 🧠 仕事・集中力専門分析
専門分野: 認知パフォーマンス、集中力ウィンドウ、脳疲労管理
重視ポイント:
- 気圧変化による認知機能への影響
- HRVと集中力の相関
- 時間帯別の脳のパフォーマンス
- ストレス蓄積と作業効率の関係

今日のトライ例:
- ポモドーロテクニック (25分集中+5分休憩)
- マインドフルワーク (作業前2分間の呼吸意識)
- 環境音の活用 (ホワイトノイズやカフェ音)`,
    english: `### 🧠 Work & Focus Specialist Analysis
Expertise: Cognitive performance, focus windows, brain fatigue management
Key Considerations:
- Impact of pressure changes on cognitive function
- HRV and focus correlation
- Time-of-day brain performance patterns
- Stress accumulation and work efficiency

Today's Try Examples:
- Pomodoro Technique (25min focus + 5min break)
- Mindful Work (2min breathing before tasks)
- Ambient sound utilization (white noise, cafe sounds)`,
  },
  beauty: {
    japanese: `### ✨ 美容・肌専門分析
専門分野: 肌コンディション、水分バランス、成長ホルモン最適化
重視ポイント:
- 湿度と肌バリア機能の関係
- 睡眠ホルモンと美容の相関
- UV指数と肌防御
- 水分摂取と肌質の関連

今日のトライ例:
- 内側からの水分補給 (カモミールティー)
- 温オイルマッサージ (セサミオイル顔マッサージ)
- UV対策の工夫 (日陰選び、帽子着用)`,
    english: `### ✨ Beauty & Skin Specialist Analysis
Expertise: Skin condition, hydration balance, growth hormone optimization
Key Considerations:
- Humidity and skin barrier function relationship
- Sleep hormones and beauty correlation
- UV index and skin defense
- Hydration and skin quality connection

Today's Try Examples:
- Internal hydration (chamomile tea)
- Warm oil massage (sesame oil facial)
- UV protection strategies (shade seeking, hat wearing)`,
  },
  diet: {
    japanese: `### 🥗 食事・代謝専門分析
専門分野: 栄養タイミング、代謝効率、血糖値安定
重視ポイント:
- 活動量と栄養需要の関係
- 時間帯別の代謝効率
- 気温と食欲・消化の関連
- 水分バランスと代謝の相関

今日のトライ例:
- 栄養密度の高い間食 (ナッツ、フルーツ)
- 色彩豊かな食事 (赤・緑・黄の野菜組み合わせ)
- タイミング最適化 (運動前後の栄養戦略)`,
    english: `### 🥗 Diet & Metabolism Specialist Analysis
Expertise: Nutrition timing, metabolic efficiency, blood sugar stability
Key Considerations:
- Activity level and nutritional demand relationship
- Time-of-day metabolic efficiency
- Temperature and appetite/digestion correlation
- Hydration balance and metabolism connection

Today's Try Examples:
- Nutrient-dense snacks (nuts, fruits)
- Colorful meals (red, green, yellow vegetable combinations)
- Timing optimization (pre/post-workout nutrition strategy)`,
  },
  sleep: {
    japanese: `### 💤 睡眠・リカバリー専門分析
専門分野: 睡眠効率、深い睡眠、概日リズム調整
重視ポイント:
- 気圧変化と睡眠質の関係
- HRVと回復効率の相関
- 環境温度と深い睡眠の関連
- 光暴露と概日リズムの調整

今日のトライ例:
- 入眠前リチュアル (カモミールティー、ラベンダーマッサージ)
- 睡眠環境最適化 (温度、湿度、遮光)
- 概日リズム調整 (朝の光暴露、夜のブルーライト制限)`,
    english: `### 💤 Sleep & Recovery Specialist Analysis
Expertise: Sleep efficiency, deep sleep, circadian rhythm adjustment
Key Considerations:
- Pressure changes and sleep quality relationship
- HRV and recovery efficiency correlation
- Environmental temperature and deep sleep connection
- Light exposure and circadian rhythm adjustment

Today's Try Examples:
- Pre-sleep ritual (chamomile tea, lavender massage)
- Sleep environment optimization (temperature, humidity, light blocking)
- Circadian rhythm adjustment (morning light, evening blue light limits)`,
  },
  fitness: {
    japanese: `### 🏃‍♂️ フィットネス・トレーニング専門分析
専門分野: 運動効果、トレーニング強度、回復戦略
重視ポイント:
- 気温・湿度と運動パフォーマンスの関係
- HRVと運動強度の最適化
- 活動量と回復需要のバランス
- 環境条件と運動タイプの選択

今日のトライ例:
- モーニングストレッチ (太陽光浴びながら5分間)
- 環境適応運動 (気温に応じた強度調整)
- アクティブリカバリー (軽い散歩、ヨガ)`,
    english: `### 🏃‍♂️ Fitness & Training Specialist Analysis
Expertise: Exercise effectiveness, training intensity, recovery strategies
Key Considerations:
- Temperature/humidity and exercise performance relationship
- HRV and training intensity optimization
- Activity level and recovery demand balance
- Environmental conditions and exercise type selection

Today's Try Examples:
- Morning stretch (5-min in sunlight)
- Environment-adapted exercise (intensity based on temperature)
- Active recovery (light walking, yoga)`,
  },
  chill: {
    japanese: `### 🍃 リラックス・ストレス管理専門分析
専門分野: 自律神経バランス、ストレス解放、心身のリセット
重視ポイント:
- 気圧変化と自律神経の関係
- HRVとストレスレベルの相関
- 環境要因と心理状態の関連
- 効果的なリラクゼーション手法

今日のトライ例:
- 気圧対策 (温かいジンジャーティー)
- 深いリラクゼーション (セサミオイル足裏マッサージ)
- 即効リセット (3回の深呼吸、10秒目を閉じる)`,
    english: `### 🍃 Chill & Stress Management Specialist Analysis
Expertise: Autonomic nervous system balance, stress release, mind-body reset
Key Considerations:
- Pressure changes and autonomic nervous system relationship
- HRV and stress level correlation
- Environmental factors and psychological state connection
- Effective relaxation techniques

Today's Try Examples:
- Pressure countermeasures (warm ginger tea)
- Deep relaxation (sesame oil foot massage)
- Instant reset (3 deep breaths, 10-second eye closure)`,
  },
}

/**
 * 「今日のトライ」生成のためのコンテキスト分析
 */
export class TodaysTryContextAnalyzer {
  /**
   * 現在の状況から最適な「トライ」を選択
   */
  static analyzeBestTryOpportunity(request: AIAnalysisRequest): TryOpportunity {
    const opportunities: TryOpportunity[] = []

    // エネルギーレベル分析
    if (request.batteryLevel > 70) {
      opportunities.push({
        type: 'energy_peak',
        priority: 'high',
        reasoning: 'エネルギーレベルが高く、新しいチャレンジに最適',
      })
    } else if (request.batteryLevel < 30) {
      opportunities.push({
        type: 'recovery_focus',
        priority: 'high',
        reasoning: 'エネルギー不足、回復重視の提案が必要',
      })
    }

    // 環境要因分析
    if (request.environmentalContext.pressureTrend < -3) {
      opportunities.push({
        type: 'pressure_support',
        priority: 'high',
        reasoning: '気圧低下による体調影響への対策が必要',
      })
    }

    if (request.environmentalContext.humidity < 30) {
      opportunities.push({
        type: 'hydration_focus',
        priority: 'medium',
        reasoning: '乾燥による脱水・肌トラブル対策が必要',
      })
    }

    // 時間帯分析
    const timeOpportunity = this.analyzeTimeOpportunity(request.userContext.timeOfDay)
    opportunities.push(timeOpportunity)

    // 最優先の機会を返却
    const sortedOpportunities = opportunities.sort((a, b) => this.getPriorityWeight(b.priority) - this.getPriorityWeight(a.priority))
    return sortedOpportunities[0] || {
      type: 'general_wellness',
      priority: 'low' as const,
      reasoning: '一般的なウェルネス維持',
    }
  }

  private static analyzeTimeOpportunity(timeOfDay: string): TryOpportunity {
    switch (timeOfDay) {
      case 'morning':
        return {
          type: 'morning_activation',
          priority: 'medium',
          reasoning: '朝の活性化に最適なタイミング',
        }
      case 'afternoon':
        return {
          type: 'afternoon_sustain',
          priority: 'medium',
          reasoning: '午後のエネルギー維持が重要',
        }
      case 'evening':
        return {
          type: 'evening_preparation',
          priority: 'medium',
          reasoning: '夜への準備と回復の時間',
        }
      case 'night':
        return {
          type: 'night_recovery',
          priority: 'high',
          reasoning: '睡眠準備と翌日への回復が最優先',
        }
      default:
        return {
          type: 'general_wellness',
          priority: 'low',
          reasoning: '一般的なウェルネス維持',
        }
    }
  }

  private static getPriorityWeight(priority: string): number {
    switch (priority) {
      case 'high':
        return 3
      case 'medium':
        return 2
      case 'low':
        return 1
      default:
        return 0
    }
  }
}

// MARK: - Supporting Types

interface TryOpportunity {
  type: string
  priority: 'high' | 'medium' | 'low'
  reasoning: string
}