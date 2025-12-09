# Phase 2 Backend Implementation: Deep Personalization

## Overview

Phase 2 introduces advanced **"6 Focus Areas Hyper-Personalization"** system with intelligent AI synthesis engine. Backend implements sophisticated prompt construction, multi-tag analysis logic, and Claude API integration for weekly analysis.

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

## 1. Enhanced AI Prompt Construction System

### A. EnhancedPromptBuilder Architecture

```typescript
class EnhancedPromptBuilder {
  buildAnalysisPrompt(context: AIAnalysisRequest): string {
    const basePersona = this.getBasePersona(context.userContext.mode);
    const tagPersonas = this.getTagPersonas(context.userContext.activeTags);
    const conflictResolution = this.getConflictResolution(
      context.userContext.activeTags,
      context.energyLevel
    );
    const dataFocus = this.getDataFocusInstructions(
      context.userContext.activeTags
    );

    return `
${basePersona}

ACTIVE TAG LENSES:
${tagPersonas
  .map((persona) => `- ${persona.name}: ${persona.instructions}`)
  .join("\n")}

CONFLICT RESOLUTION STRATEGY:
${conflictResolution}

DATA ANALYSIS PRIORITIES:
${dataFocus
  .map((focus) => `- ${focus.tag}: Focus on ${focus.metrics.join(", ")}`)
  .join("\n")}

CURRENT CONTEXT:
- Energy Level: ${context.energyLevel}% (${this.getEnergyState(
      context.energyLevel
    )})
- Time of Day: ${context.userContext.timeOfDay}
- Environmental Factors: ${this.formatEnvironmentalContext(
      context.environmentalContext
    )}
- Biological State: ${this.formatBiologicalContext(context.biologicalContext)}

RESPONSE REQUIREMENTS:
1. Start with a clear HEADLINE (conclusion first)
2. Provide tag-specific insights for each active tag
3. Offer micro-actions, never overwhelming changes
4. Validate feelings, don't criticize data
5. Connect environmental factors to internal sensations
6. Use the unified persona voice for multi-tag scenarios
    `;
  }

  private getTagPersonas(tags: FocusTag[]): TagPersona[] {
    const personaMap = {
      Work: {
        name: "Executive Assistant",
        instructions:
          "Analyze cognitive capacity, predict brain fog, optimize mental performance windows",
      },
      Beauty: {
        name: "Aesthetician Coach",
        instructions:
          "Monitor skin health factors, growth hormone optimization, stress-aging prevention",
      },
      Athlete: {
        name: "Sports Science Coach",
        instructions:
          "Assess training readiness, monitor recovery metrics, prevent overtraining",
      },
      Chill: {
        name: "Nervous System Expert",
        instructions:
          "Monitor autonomic balance, suggest stress interventions, promote nervous system recovery",
      },
    };

    return tags.map((tag) => personaMap[tag]).filter(Boolean);
  }

  private getConflictResolution(tags: FocusTag[], battery: number): string {
    if (battery < 20)
      return "OVERRIDE ALL TAGS: Rest is mandatory for biological safety.";
    if (battery < 40)
      return "GENTLE APPROACH: Favor recovery-oriented tags (Beauty, Chill) over demanding ones (Work, Athlete).";
    if (tags.length > 2)
      return "HOLISTIC SYNTHESIS: Find recommendations that serve multiple goals simultaneously.";
    return "BALANCED APPROACH: Respect all active tag perspectives equally.";
  }
}
```

### B. Tag Synthesis Strategy Implementation

```typescript
interface TagSynthesisStrategy {
  // Priority Matrix (Biological Safety First)
  conflictResolution: {
    energyLevel_0_20: "Override all tags - rest is mandatory";
    energyLevel_21_40: "Gentle activities only, focus on recovery tags (Chill, Beauty)";
    energyLevel_41_70: "Balanced approach, respect all active tags equally";
    energyLevel_71_100: "High energy allows pursuit of demanding tags (Work, Athlete)";
  };

  // Synthesis Examples
  common_combinations: {
    "Work + Beauty": "Optimize for both cognitive performance AND skin health. Early sleep benefits both brain recovery and growth hormone release.";
    "Work + Chill": "High performance requires deep recovery. Use stress management techniques to enhance focus capacity.";
    "Beauty + Athlete": "Recovery drives both performance and appearance. Prioritize sleep quality and hydration for dual benefits.";
    "All Four Tags": "You're optimizing holistically. Today's recommendation balances all aspects based on your current energy state.";
  };
}
```

## 2. Tag Analysis Engine Implementation

### A. Focus Area Data Analysis Logic

```typescript
class TagAnalysisEngine {
  analyzeWorkTag(
    biologicalData: BiologicalContext,
    environmentalData: EnvironmentalContext
  ): TagInsight {
    let insights = [];

    // REM Sleep Analysis
    if (biologicalData.sleepRem < 60) {
      insights.push({
        type: "warning",
        message:
          "Memory consolidation was incomplete last night. Expect reduced learning capacity after 2 PM.",
        actionItem:
          "Schedule important decisions for this morning while REM recovery is still active.",
      });
    }

    // Pressure Drop Analysis
    if (environmentalData.pressureTrend < -5) {
      insights.push({
        type: "warning",
        message:
          "Barometric pressure dropped significantly. Brain fog and headaches likely by evening.",
        actionItem:
          "Front-load cognitively demanding tasks. Prepare pain management strategy for later.",
      });
    }

    // HRV-Focus Correlation
    if (biologicalData.hrvStatus < -10) {
      insights.push({
        type: "critical",
        message:
          "Stress levels are impacting cognitive resources. Focus will be fragmented today.",
        actionItem:
          "Use time-boxing (25min focus blocks) instead of expecting sustained attention.",
      });
    }

    return this.synthesizeWorkInsights(insights);
  }

  analyzeBeautyTag(
    biologicalData: BiologicalContext,
    environmentalData: EnvironmentalContext
  ): TagInsight {
    let insights = [];

    // Deep Sleep Analysis
    if (biologicalData.sleepDeep < 40) {
      insights.push({
        type: "warning",
        message: "Growth hormone production was suboptimal. Skin repair process incomplete.",
        actionItem: "Prioritize earlier bedtime tonight (before 10 PM) for optimal skin recovery window.",
      });
    }

    // Humidity Analysis
    if (environmentalData.humidity < 40) {
      insights.push({
        type: "warning",
        message: "Low humidity disrupts skin barrier function. Dehydration stress likely.",
        actionItem: "Increase water intake and consider humidifier for optimal skin hydration.",
      });
    }

    return this.synthesizeBeautyInsights(insights);
  }

  analyzeAthleteTag(
    biologicalData: BiologicalContext,
    environmentalData: EnvironmentalContext
  ): TagInsight {
    let insights = [];

    // HRV Training Readiness
    if (biologicalData.hrvTrend > 10) {
      insights.push({
        type: "positive",
        message: "HRV elevation indicates excellent adaptation. High-performance window available.",
        actionItem: "Consider pushing intensity today - your body is ready for performance gains.",
      });
    } else if (biologicalData.hrvTrend < -10) {
      insights.push({
        type: "warning",
        message: "HRV suppression suggests overreaching. Recovery is priority.",
        actionItem: "Active recovery only - trust your body's adaptation signals.",
      });
    }

    return this.synthesizeAthleteInsights(insights);
  }

  analyzeChillTag(
    biologicalData: BiologicalContext,
    environmentalData: EnvironmentalContext
  ): TagInsight {
    let insights = [];

    // Stress Pattern Detection
    if (biologicalData.hrvDrop > 15) {
      insights.push({
        type: "critical",
        message: "Acute stress detected. Sympathetic nervous system overactivation.",
        actionItem: "30-second breathing exercise available. Micro-intervention needed.",
      });
    }

    // Environmental Stress Correlation
    if (environmentalData.pressureTrend < -3 && biologicalData.restingHeartRate > biologicalData.baselineRHR + 10) {
      insights.push({
        type: "warning",
        message: "Weather sensitivity combined with elevated stress response.",
        actionItem: "Extra gentleness today. Consider warming techniques (tea, gentle movement).",
      });
    }

    return this.synthesizeChillInsights(insights);
  }
}
```

### B. Multi-Tag Synthesis Logic

```typescript
interface MultiTagPersona {
  "Work + Beauty": {
    unified_identity: "High-Performance Wellness Expert";
    synthesis_message: "Peak performance and radiant health are symbiotic - one enhances the other.";
    conflict_resolution: "When energy is limited, choose the option that serves both goals (quality sleep, stress management).";
  };

  "Work + Athlete": {
    unified_identity: "Elite Performance Optimizer";
    synthesis_message: "Mental and physical performance follow the same principles: strategic stress and strategic recovery.";
    conflict_resolution: "Prioritize recovery quality over recovery quantity - both brain and body need similar rest patterns.";
  };

  "Beauty + Chill": {
    unified_identity: "Holistic Wellness Sage";
    synthesis_message: "True beauty emerges from nervous system balance - stress disrupts both appearance and inner peace.";
    conflict_resolution: "Stress management techniques that also benefit skin (hydration, sleep, gentle movement).";
  };

  "Work + Chill": {
    unified_identity: "Mindful Performance Expert";
    synthesis_message: "Sustainable high performance requires nervous system mastery.";
    conflict_resolution: "Stress management enhances cognitive capacity rather than competing with it.";
  };
}
```

## 3. Monday Weekly Analysis System

### A. Claude API Integration for Deep Reflection

```typescript
interface MondayWeeklyAnalysis {
  // 月曜朝の特別なAI分析
  monday_morning_system: {
    trigger: "every_monday_08:00_jst",
    data_scope: "past_7_days_trend_analysis",
    processing: "claude_api_deep_reflection",
    
    analysis_components: {
      health_patterns: "週間の睡眠・活動・ストレスパターン分析",
      environmental_correlation: "天候・気圧変化との相関性",
      focus_area_progress: "選択した関心分野での成長度合い",
      trial_feedback: "前週のトライ体験の効果分析"
    },
    
    output_requirements: {
      tone: "温かく個人的、励ましベース",
      length: "300-500文字（詳細で心のこもった文章）",
      personalization: "ユーザー名を含む親密な語りかけ",
      cultural_wisdom: "アーユルヴェーダ等の伝統的知恵の統合",
      actionable_content: "1週間継続可能な具体的習慣提案"
    }
  }
}

class WeeklyAnalysisService {
  async generateWeeklyAnalysis(
    userId: string,
    weeklyData: WeeklyHealthData,
    activeTags: FocusTag[]
  ): Promise<WeeklyAnalysisResult> {
    const prompt = this.buildWeeklyAnalysisPrompt(weeklyData, activeTags);
    const claudeResponse = await this.claudeAPIService.analyze(prompt);
    
    return {
      weeklyInsight: claudeResponse.weeklyInsight,
      weeklyTry: claudeResponse.weeklyTryRecommendation,
      culturalWisdom: claudeResponse.culturalWisdomIntegration,
      personalizedMessage: claudeResponse.personalizedEncouragement
    };
  }

  private buildWeeklyAnalysisPrompt(
    data: WeeklyHealthData,
    tags: FocusTag[]
  ): string {
    return `
あなたは${this.getTagBasedPersona(tags)}として、1週間の健康データを深く分析し、
温かく個人的な週次提案を作成してください。

WEEKLY DATA ANALYSIS:
${JSON.stringify(data, null, 2)}

ACTIVE FOCUS AREAS: ${tags.join(", ")}

ANALYSIS REQUIREMENTS:
1. 週間パターンの洞察（睡眠、活動、ストレス、環境要因）
2. 選択された関心分野での成長機会の特定
3. アーユルヴェーダや東洋医学の知恵の統合
4. 1週間継続可能な具体的習慣提案
5. 温かく励ましに満ちたトーン（300-500文字）

OUTPUT FORMAT:
{
  "weeklyInsight": "週間データから得られた主要な洞察",
  "weeklyTryRecommendation": "今週の具体的トライ提案",
  "culturalWisdomIntegration": "伝統的知恵の活用",
  "personalizedEncouragement": "個人的な励ましメッセージ"
}
    `;
  }
}
```

### B. Weekly Try Generation Logic

```typescript
// 実装例：Chill + Beauty 選択ユーザーへの月曜提案生成
const weeklyTryExample = `
おはようございます、[ユーザー名]様。

先週は仕事でお忙しい中、しっかりと睡眠時間を確保されていましたね。
特に木曜日以降の睡眠の質が向上していたのが印象的でした。

今週は「夜のオイルマッサージ」を取り入れてみませんか。
温めたセサミオイルで足裏を優しくマッサージすることは、
ヴァータの乱れによる思考の巡りすぎや不安を鎮め、深い眠りへと誘います。

また、仕事でストレスを感じたり、イライラしそうになった時には、
数回ゆっくりと深呼吸をする習慣をつけましょう。
これは過剰になったピッタの火を鎮め、冷静さを取り戻すための簡単な瞑想法です。

これまでの実践で得た知識と、ご自身の体質への理解を両輪に、
これからも[ユーザー名]様らしい、エネルギッシュで穏やかな毎日を創造していってください。
`;
```

## 4. Enhanced AI Response Structure

### A. Response Interface Design

```typescript
interface EnhancedAIResponse extends AIAnalysisResponse {
  // Enhanced tag insights with persona-specific messaging
  tagInsights: Array<{
    tag: FocusTag;
    persona: string; // "Executive Assistant", "Aesthetician Coach", etc.
    icon: string; // SF Symbol name
    message: string; // Tag-specific insight
    urgency: "info" | "warning" | "critical";
    confidence: number; // 0-1, AI confidence in this insight
    actionItems: Array<{
      title: string;
      description: string;
      estimatedTime: string; // "2 minutes", "Tonight before bed"
      difficulty: "trivial" | "easy" | "moderate";
    }>;
  }>;

  // Multi-tag synthesis when applicable
  synthesis?: {
    unifiedPersona: string; // "High-Performance Wellness Expert"
    integrationMessage: string; // How tags work together
    priorityRecommendation: string; // Single most important action
  };

  // Enhanced environmental correlations
  environmentalInsights: Array<{
    factor: "pressure" | "humidity" | "temperature" | "uv";
    impact: string; // How this affects the user today
    recommendation: string; // Specific mitigation strategy
    confidence: number; // How certain AI is about this correlation
  }>;
}
```

### B. Environmental Correlation Analysis

```typescript
class EnvironmentalAnalysisEngine {
  analyzeEnvironmentalImpacts(
    environmentalData: EnvironmentalContext,
    biologicalData: BiologicalContext,
    activeTags: FocusTag[]
  ): EnvironmentalInsight[] {
    const insights = [];

    // Pressure-based analysis
    if (environmentalData.pressureTrend < -5) {
      if (activeTags.includes("Work")) {
        insights.push({
          factor: "pressure",
          impact: "Barometric pressure drop increases headache risk and reduces cognitive performance",
          recommendation: "Schedule important tasks for morning hours, prepare pain management strategy",
          confidence: 0.8
        });
      }
      if (activeTags.includes("Beauty")) {
        insights.push({
          factor: "pressure",
          impact: "Pressure changes can affect circulation and skin clarity",
          recommendation: "Increase lymphatic drainage through gentle facial massage",
          confidence: 0.6
        });
      }
    }

    // Humidity-based analysis
    if (environmentalData.humidity < 40) {
      if (activeTags.includes("Beauty")) {
        insights.push({
          factor: "humidity",
          impact: "Low humidity disrupts skin barrier function and accelerates moisture loss",
          recommendation: "Increase water intake and apply heavier moisturizer",
          confidence: 0.9
        });
      }
      if (activeTags.includes("Chill")) {
        insights.push({
          factor: "humidity",
          impact: "Dry air can increase sympathetic nervous system activation",
          recommendation: "Use humidifier and practice hydrating breathing exercises",
          confidence: 0.7
        });
      }
    }

    return insights;
  }
}
```

## 5. Chill Tag Implementation Logic

### A. Trigger-Based Micro-Interventions

```typescript
interface ChillTriggerLogic {
  stress_patterns: {
    "HRV drop > 15ms suddenly": "Acute stress detected. 30-second breathing exercise available.";
    "RHR elevated > 10bpm for 2+ hours": "Sympathetic overdrive. Consider 5-minute reset break.";
    "Energy drain rate > 20%/hour": "Energy hemorrhaging detected. Micro-recovery suggested.";
  };

  environmental_triggers: {
    "Pressure drop + Work tag active": "Double stress factor. Brain needs extra support today.";
    "High humidity + Beauty tag": "Skin stress + heat stress. Cooling break recommended.";
    "Low pressure + any tag": "Weather sensitivity detected. Extra gentleness today.";
  };

  // Contextual Timing
  timing_awareness: {
    "Morning (6-10 AM)": "Gentle activation suggestions (warm shower, light stretch)";
    "Midday (10 AM-3 PM)": "Stress prevention (breathing breaks, hydration reminders)";
    "Evening (3-8 PM)": "Transition support (decompression, preparation for rest)";
    "Night (8 PM+)": "Nervous system downshift (cool shower, meditation, warmth)";
  };
}

// Implementation Examples
if (tags.includes("Chill") && tags.includes("Work") && hrvDrop > 10) {
  return {
    headline: "Stress Before Focus",
    message:
      "Your nervous system needs 2 minutes of reset before peak cognitive performance is possible.",
    suggestion:
      "Try the 4-7-8 breathing technique, then tackle your priority task.",
  };
}

if (tags.includes("Chill") && tags.includes("Athlete") && energyLevel < 40) {
  return {
    headline: "Recovery IS Training",
    message:
      "Elite athletes know: adaptation happens during rest, not just work.",
    suggestion: "Today's training: perfect your recovery routine.",
  };
}
```

## 6. API Endpoints Implementation

### A. Enhanced Analysis Endpoint

```typescript
// POST /api/v2/analysis/enhanced
export const enhancedAnalysisHandler = async (c: Context) => {
  const { userId, activeTags, biologicalData, environmentalData } = await c.req.json();
  
  const analysisEngine = new TagAnalysisEngine();
  const promptBuilder = new EnhancedPromptBuilder();
  
  // Generate tag-specific insights
  const tagInsights = await Promise.all(
    activeTags.map(tag => analysisEngine.analyzeTag(tag, biologicalData, environmentalData))
  );
  
  // Build enhanced prompt for Claude API
  const prompt = promptBuilder.buildAnalysisPrompt({
    userContext: { mode: "standard", activeTags, timeOfDay: new Date().getHours() },
    energyLevel: biologicalData.energyLevel,
    environmentalContext: environmentalData,
    biologicalContext: biologicalData
  });
  
  // Get AI response
  const claudeResponse = await claudeAPIService.analyze(prompt);
  
  // Format enhanced response
  const enhancedResponse: EnhancedAIResponse = {
    ...claudeResponse,
    tagInsights,
    synthesis: activeTags.length > 1 ? generateSynthesis(activeTags) : undefined,
    environmentalInsights: new EnvironmentalAnalysisEngine()
      .analyzeEnvironmentalImpacts(environmentalData, biologicalData, activeTags)
  };
  
  return c.json(enhancedResponse);
};
```

### B. Weekly Analysis Endpoint

```typescript
// POST /api/v2/analysis/weekly
export const weeklyAnalysisHandler = async (c: Context) => {
  const { userId } = await c.req.json();
  
  // Get past week data
  const weeklyData = await healthDataService.getWeeklyData(userId);
  const userProfile = await userService.getUserProfile(userId);
  
  // Generate weekly analysis
  const weeklyAnalysis = await new WeeklyAnalysisService()
    .generateWeeklyAnalysis(userId, weeklyData, userProfile.activeTags);
  
  // Store analysis for Monday delivery
  await weeklyAnalysisService.scheduleDelivery(userId, weeklyAnalysis);
  
  return c.json(weeklyAnalysis);
};
```

## 7. Implementation Priority

### Phase 2.1: Core Infrastructure
1. Enhanced AI Response structure
2. TagAnalysisEngine base implementation
3. EnhancedPromptBuilder architecture

### Phase 2.2: Tag Analysis Logic
1. Individual tag analysis methods
2. Multi-tag synthesis engine
3. Environmental correlation analysis

### Phase 2.3: Weekly Analysis System
1. Claude API integration for weekly insights
2. Monday delivery scheduling
3. Cultural wisdom integration

### Phase 2.4: Advanced Features
1. Chill tag micro-interventions
2. Advanced persona synthesis
3. Performance optimization

## Testing Requirements

- Unit tests for each tag analysis method
- Integration tests for multi-tag synthesis
- End-to-end tests for Claude API integration
- Performance tests for real-time analysis
- Mock environmental data for consistent testing

## Dependencies

- Claude API integration
- Enhanced health data models
- Real-time environmental data sources
- Notification scheduling system
- User preference management