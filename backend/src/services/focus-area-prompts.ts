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
   * 今日選択された関心分野に特化したプロンプトを構築
   */
  static buildFocusSpecificPrompt(
    request: AIAnalysisRequest,
    language: 'ja' | 'en' = 'ja',
    todaysFocus?: string | string[],
  ): string {
    const basePersona = FocusAreaPromptBuilder.getBasePersona(language)
    // 今日選択された分野のみの特化ガイダンス
    const todaysGuidance = FocusAreaPromptBuilder.buildTodaysFocusGuidance(
      todaysFocus || request.userContext.activeTags,
      language,
    )
    const contextualData = FocusAreaPromptBuilder.formatContextualData(request)
    const outputFormat = FocusAreaPromptBuilder.getOutputFormat(language)

    return [basePersona, todaysGuidance, contextualData, outputFormat].join(
      '\n\n',
    )
  }

  /**
   * 基本ペルソナ（言語別）
   */
  private static getBasePersona(language: 'ja' | 'en'): string {
    if (language === 'ja') {
      return `あなたは経験豊富なヘルスアドバイザーです。

基本原則:
1. ユーザーの健康データを客観的に分析し、実用的な提案を行う
2. 批判せず、改善点を明確に示す
3. 環境要因（気圧、湿度等）と体調の関連を科学的に説明する
4. 具体的で実行可能な提案を行う
5. 2-15分で実行可能な行動を優先する

表現の原則:
- エネルギーレベルを数値で明確に示す
- 具体的な改善方法を提案する
- データに基づいた客観的な分析を行う`
    } else {
      return `You are an experienced health advisor.

Core Principles:
1. Analyze health data objectively and provide practical suggestions
2. Never criticize, clearly indicate improvement areas
3. Scientifically explain relationships between environmental factors and physical condition
4. Make specific and actionable recommendations
5. Prioritize actions that can be completed in 2-15 minutes

Expression Guidelines:
- Clearly indicate energy levels numerically
- Suggest specific improvement methods
- Provide objective data-based analysis`
    }
  }

  /**
   * 今日選択された分野の専門ガイダンス
   */
  private static buildTodaysFocusGuidance(
    todaysFocus: string | string[],
    language: 'ja' | 'en',
  ): string {
    const header =
      language === 'ja' ? '## 今日の専門分析対象' : "## Today's Focus Analysis"

    if (Array.isArray(todaysFocus)) {
      // 組み合わせ分析
      const combo = todaysFocus
        .map((tag) =>
          FocusAreaPromptBuilder.getSpecialistGuidance(
            tag as FocusTagType,
            language,
          ),
        )
        .join('\n\n')
      return `${header}（組み合わせ分析: ${todaysFocus.join(' + ')}）\n\n${combo}`
    } else {
      // 単体分析
      const specialist = FocusAreaPromptBuilder.getSpecialistGuidance(
        todaysFocus as FocusTagType,
        language,
      )
      return `${header}（今日の分野: ${todaysFocus}）\n\n${specialist}`
    }
  }

  /**
   * 関心分野別の専門ガイダンス（従来メソッド維持）
   */

  /**
   * 個別関心分野の専門ガイダンス
   */
  private static getSpecialistGuidance(
    focusTag: FocusTagType,
    language: 'ja' | 'en',
  ): string {
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
      return `## 1日分総合分析 - 6分野対応

以下のJSON形式で、実用的な健康分析結果を生成してください：

{
  "headline": {
    "title": "今日の健康状態評価（30文字以内）",
    "subtitle": "最優先の推奨行動（50文字以内）",
    "impactLevel": "low|medium|high",
    "confidence": 85
  },
  "energyComment": "エネルギー状態の客観的分析（100文字程度）",
  "tagInsights": [
    {
      "tag": "今日の重点分野（例: beauty, diet, beauty+diet）",
      "icon": "適切なSFシンボル名", 
      "message": "データに基づく具体的な改善点（120文字以内）",
      "urgency": "info|warning|critical"
    }
  ],
  "aiActionSuggestions": [
    {
      "title": "推奨アクション（15文字以内）",
      "description": "具体的な方法と効果の説明（150文字以内）", 
      "actionType": "rest|hydrate|exercise|focus|social|beauty",
      "estimatedTime": "5-15分",
      "difficulty": "easy|medium|hard"
    }
  ],
  "detailAnalysis": "データ分析結果と改善提案（200文字以内）"
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
    japanese: `### ✨ 美容・肌ケア分析
専門分野: 肌状態、水分補給、睡眠と肌の健康
重要な要素:
- 湿度レベルと肌バリア機能
- 睡眠の質と肌の回復
- UV指数と肌への影響
- 水分摂取量と肌質の関係

推奨行動例:
- 十分な水分補給 (1日2リットル目標)
- 保湿ケア (朝晩のスキンケアルーチン)
- UV対策 (日焼け止め、帽子、日陰の利用)`,
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
    japanese: `### 🍃 リラクゼーション・ストレス管理分析
専門分野: 自律神経調整、ストレス軽減、心身の回復
重要な要素:
- 気圧変化と自律神経への影響
- 心拍変動とストレス状態の関係
- 環境条件と心理状態の関連
- 効率的なリラクゼーション手法

推奨行動例:
- 気圧変化対策 (温かい飲み物の摂取)
- リラクゼーション (5分間のマッサージ)
- 即座にできるリセット方法 (深呼吸3回、短時間の瞑想)`,
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
    const timeOpportunity = TodaysTryContextAnalyzer.analyzeTimeOpportunity(
      request.userContext.timeOfDay,
    )
    opportunities.push(timeOpportunity)

    // 最優先の機会を返却
    const sortedOpportunities = opportunities.sort(
      (a, b) =>
        TodaysTryContextAnalyzer.getPriorityWeight(b.priority) -
        TodaysTryContextAnalyzer.getPriorityWeight(a.priority),
    )
    return (
      sortedOpportunities[0] || {
        type: 'general_wellness',
        priority: 'low' as const,
        reasoning: '一般的なウェルネス維持',
      }
    )
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
