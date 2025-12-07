# Phase 2 Technical Specification: Deep Personalization

## Theme: Focus Tags, Multi-Context Logic, and "Chill" Integration

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール
5. **UX 設計原則**: [.claude/ux_concepts.md](../../.claude/ux_concepts.md) - UX 心理学原則
6. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

### 1. Overview

Phase 2 introduces "Focus Tags," allowing users to customize the AI's advice engine.
Crucially, **users can select MULTIPLE tags**. The system must handle conflicting or overlapping advice intelligently.
We also introduce a "Chill / Relax" concept (formerly Sauna) as a subtle, omnipresent support feature rather than a dominant mode.

### 2. Focus Tags Architecture (Enhanced Psychology)

#### A. Tag Definitions with Psychological Profiles

Users can toggle these On/Off in Settings/Onboarding. Each tag functions as a "lens" that reinterprets the same data through different psychological and physiological priorities.

1.  **🧠 Deep Focus (Work):** 
    - **Psychological Profile:** High-performing professional seeking cognitive optimization
    - **Data Priority:** REM sleep (memory consolidation), pressure trends (brain fog prediction), HRV (stress-focus correlation)
    - **Analysis Logic:** "Analyze `sleepRem` and `pressureTrend`. If REM < 60min OR pressure drops > 5hPa: warn about brain fog risk. Suggest completing critical tasks before cognitive decline."

2.  **✨ Beauty & Skin:**
    - **Psychological Profile:** Health-conscious individual prioritizing appearance and longevity  
    - **Data Priority:** Deep sleep (growth hormone), humidity (skin barrier), UV index (photoaging protection)
    - **Analysis Logic:** "Analyze `sleepDeep` and `humidity`. If deep sleep < 40min OR humidity < 40%: warn about skin barrier disruption. Emphasize growth hormone window (10PM-2AM)."

3.  **🥗 Diet & Metabolism:**
    - **Psychological Profile:** Nutrition-focused individual optimizing metabolic health
    - **Data Priority:** Active calories (energy balance), meal timing (circadian rhythm), blood sugar proxies
    - **Analysis Logic:** "Focus on energy expenditure vs intake balance. Suggest meal timing based on activity patterns and metabolic windows."

4.  **🍃 Chill / Relax:**
    - **Psychological Profile:** Stress-management focused, values mental peace and autonomic balance
    - **Data Priority:** HRV (autonomic nervous system), stress spikes, recovery metrics
    - **Analysis Logic:** "Monitor sympathetic nervous system activation. Suggest specific relaxation techniques (cold shower, warm bath, breathing) based on stress patterns."

5.  **🏃 Athlete Mode Integration:**
    - **Psychological Profile:** Performance-oriented individual treating body as optimization system
    - **Data Priority:** HRV trends (overtraining), temperature (heat stress), recovery ratios
    - **Analysis Logic:** "If HRV high (+10ms) AND conditions favorable: 'Go for PB'. If HRV low (-10ms): 'Active recovery only - trust your body's wisdom'."

#### B. Multi-Select Synthesis Engine (The "Context Mixer")

The AI must intelligently synthesize multiple tag perspectives into coherent, non-conflicting advice.

```typescript
interface TagSynthesisStrategy {
  // Priority Matrix (Biological Safety First)
  conflictResolution: {
    batteryLevel_0_20: "Override all tags - rest is mandatory";
    batteryLevel_21_40: "Gentle activities only, focus on recovery tags (Chill, Beauty)";  
    batteryLevel_41_70: "Balanced approach, respect all active tags equally";
    batteryLevel_71_100: "High energy allows pursuit of demanding tags (Work, Athlete)";
  };
  
  // Synthesis Examples
  common_combinations: {
    "Work + Beauty": "Optimize for both cognitive performance AND skin health. Early sleep benefits both brain recovery and growth hormone release.";
    "Work + Chill": "High performance requires deep recovery. Use stress management techniques to enhance focus capacity.";
    "Beauty + Athlete": "Recovery drives both performance and appearance. Prioritize sleep quality and hydration for dual benefits.";
    "All Four Tags": "You're optimizing holistically. Today's recommendation balances all aspects based on your current energy state.";
  };
}

### 3. "Chill / Relax" Implementation (Omnipresent Support Layer)

The Chill/Relax tag operates as a **"sympathetic nervous system guardian"** - monitoring stress patterns and suggesting micro-interventions before burnout occurs.

#### A. Trigger-Based Micro-Interventions

```typescript
interface ChillTriggerLogic {
  stress_patterns: {
    "HRV drop > 15ms suddenly": "Acute stress detected. 30-second breathing exercise available.";
    "RHR elevated > 10bpm for 2+ hours": "Sympathetic overdrive. Consider 5-minute reset break.";
    "Battery drain rate > 20%/hour": "Energy hemorrhaging detected. Micro-recovery suggested.";
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
```

#### B. Integration Strategy (Not a Mode, But a Lens)

- **UI Integration:** Small, subtle suggestions that don't interrupt primary workflows
- **Adaptive Presence:** More prominent when stress indicators are elevated, nearly invisible when user is balanced
- **Cross-Tag Synthesis:** Enhances other tags rather than competing (e.g., "Work efficiently by managing stress first")

#### C. Specific Implementation Examples

```javascript
// Chill Tag + Work Tag Synthesis
if (tags.includes('Chill') && tags.includes('Work') && hrvDrop > 10) {
  return {
    headline: "Stress Before Focus",
    message: "Your nervous system needs 2 minutes of reset before peak cognitive performance is possible.",
    suggestion: "Try the 4-7-8 breathing technique, then tackle your priority task."
  };
}

// Chill Tag + Athlete Tag Synthesis  
if (tags.includes('Chill') && tags.includes('Athlete') && batteryLevel < 40) {
  return {
    headline: "Recovery IS Training", 
    message: "Elite athletes know: adaptation happens during rest, not just work.",
    suggestion: "Today's training: perfect your recovery routine."
  };
}
```

### 4. Tag Experience Framework (Psychological Persona Implementation)

Each tag transforms the app's "personality" and interpretation focus, creating distinct user experiences from the same underlying data.

#### A. Tag-Specific Experience Design

```typescript
interface TagExperienceProfile {
  Work: {
    persona: "Elite Executive Assistant";
    battery_interpretation: "Remaining focus hours before cognitive decline";
    primary_warnings: ["Brain fog risk", "Attention fragmentation", "Decision fatigue"];
    success_metrics: ["Sustained attention", "Mental clarity", "Cognitive reserves"];
    messaging_tone: "Professional, predictive, strategic";
  };
  
  Beauty: {
    persona: "Expert Aesthetician & Wellness Coach";  
    battery_interpretation: "Skin vitality and cellular repair capacity";
    primary_warnings: ["Skin barrier compromise", "Hydration deficit", "Stress aging"];
    success_metrics: ["Glowing skin", "Cellular renewal", "Stress-free radiance"];
    messaging_tone: "Nurturing, sophisticated, science-backed";
  };
  
  Athlete: {
    persona: "Elite Sports Science Coach";
    battery_interpretation: "Training capacity and recovery readiness"; 
    primary_warnings: ["Overtraining risk", "Performance plateau", "Injury vulnerability"];
    success_metrics: ["Peak performance", "Optimal recovery", "Adaptation gains"];
    messaging_tone: "Disciplined, motivating, performance-focused";
  };
  
  Chill: {
    persona: "Mindfulness & Nervous System Expert";
    battery_interpretation: "Autonomic balance and stress resilience";
    primary_warnings: ["Sympathetic overdrive", "Burnout trajectory", "Nervous system fatigue"];
    success_metrics: ["Calm alertness", "Stress resilience", "Inner peace"];
    messaging_tone: "Gentle, wise, deeply understanding";
  };
}
```

#### B. Cross-Tag Integration Psychology

When multiple tags are active, the AI must create a **"unified persona"** that respects all perspectives:

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
}
```

### 5. UI Updates: Smart Suggestions & Detail Personalization

#### A. Smart Suggestion Cards

Insert contextual mini-cards below the Battery _only when relevant_.

- _Work Tag + Low Pressure (Weather):_ "Headache Risk: Focus on tasks now before pressure drops."
- _Beauty Tag + Low Humidity (Weather):_ "Dry Skin Alert: Hydrate more than usual."

#### B. Detail View Customization

Customize the `DetailView` content based on active tags.

- **Sleep Detail:**
  - _If Beauty:_ Show "Skin Repair Time" (Deep Sleep duration).
  - _If Work:_ Show "Mental Restoration" (REM Sleep duration).
- **Vital Grid:**
  - _If Diet:_ Highlight "Active Calories".
  - _If Chill:_ Highlight "HRV".

### 6. Backend Logic Updates (Enhanced AI Prompt Construction)

#### A. Sophisticated Prompt Builder Architecture

```typescript
class EnhancedPromptBuilder {
  
  buildAnalysisPrompt(context: AIAnalysisRequest): string {
    const basePersona = this.getBasePersona(context.userContext.mode);
    const tagPersonas = this.getTagPersonas(context.userContext.activeTags);
    const conflictResolution = this.getConflictResolution(context.userContext.activeTags, context.batteryLevel);
    const dataFocus = this.getDataFocusInstructions(context.userContext.activeTags);
    
    return `
${basePersona}

ACTIVE TAG LENSES:
${tagPersonas.map(persona => `- ${persona.name}: ${persona.instructions}`).join('\n')}

CONFLICT RESOLUTION STRATEGY:
${conflictResolution}

DATA ANALYSIS PRIORITIES:
${dataFocus.map(focus => `- ${focus.tag}: Focus on ${focus.metrics.join(', ')}`).join('\n')}

CURRENT CONTEXT:
- Battery Level: ${context.batteryLevel}% (${this.getBatteryState(context.batteryLevel)})
- Time of Day: ${context.userContext.timeOfDay}
- Environmental Factors: ${this.formatEnvironmentalContext(context.environmentalContext)}
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
      'Work': {
        name: "Executive Assistant",
        instructions: "Analyze cognitive capacity, predict brain fog, optimize mental performance windows"
      },
      'Beauty': {
        name: "Aesthetician Coach", 
        instructions: "Monitor skin health factors, growth hormone optimization, stress-aging prevention"
      },
      'Athlete': {
        name: "Sports Science Coach",
        instructions: "Assess training readiness, monitor recovery metrics, prevent overtraining"
      },
      'Chill': {
        name: "Nervous System Expert",
        instructions: "Monitor autonomic balance, suggest stress interventions, promote nervous system recovery"
      }
    };
    
    return tags.map(tag => personaMap[tag]).filter(Boolean);
  }
  
  private getConflictResolution(tags: FocusTag[], battery: number): string {
    if (battery < 20) return "OVERRIDE ALL TAGS: Rest is mandatory for biological safety.";
    if (battery < 40) return "GENTLE APPROACH: Favor recovery-oriented tags (Beauty, Chill) over demanding ones (Work, Athlete).";
    if (tags.length > 2) return "HOLISTIC SYNTHESIS: Find recommendations that serve multiple goals simultaneously.";
    return "BALANCED APPROACH: Respect all active tag perspectives equally.";
  }
}
```

#### B. Response Structure Enhancement

```typescript
interface EnhancedAIResponse extends AIAnalysisResponse {
  // Enhanced tag insights with persona-specific messaging
  tagInsights: Array<{
    tag: FocusTag;
    persona: string;              // "Executive Assistant", "Aesthetician Coach", etc.
    icon: string;                 // SF Symbol name
    message: string;              // Tag-specific insight
    urgency: 'info' | 'warning' | 'critical';
    confidence: number;           // 0-1, AI confidence in this insight
    actionItems: Array<{
      title: string;
      description: string;
      estimatedTime: string;     // "2 minutes", "Tonight before bed"
      difficulty: 'trivial' | 'easy' | 'moderate';
    }>;
  }>;
  
  // Multi-tag synthesis when applicable
  synthesis?: {
    unifiedPersona: string;       // "High-Performance Wellness Expert"
    integrationMessage: string;   // How tags work together
    priorityRecommendation: string; // Single most important action
  };
  
  // Enhanced environmental correlations
  environmentalInsights: Array<{
    factor: 'pressure' | 'humidity' | 'temperature' | 'uv';
    impact: string;               // How this affects the user today
    recommendation: string;       // Specific mitigation strategy
    confidence: number;           // How certain AI is about this correlation
  }>;
}
```

#### C. Tag-Specific Analysis Logic Implementation

```typescript
class TagAnalysisEngine {
  
  analyzeWorkTag(biologicalData: BiologicalContext, environmentalData: EnvironmentalContext): TagInsight {
    let insights = [];
    
    // REM Sleep Analysis
    if (biologicalData.sleepRem < 60) {
      insights.push({
        type: 'warning',
        message: 'Memory consolidation was incomplete last night. Expect reduced learning capacity after 2 PM.',
        actionItem: 'Schedule important decisions for this morning while REM recovery is still active.'
      });
    }
    
    // Pressure Drop Analysis  
    if (environmentalData.pressureTrend < -5) {
      insights.push({
        type: 'warning', 
        message: 'Barometric pressure dropped significantly. Brain fog and headaches likely by evening.',
        actionItem: 'Front-load cognitively demanding tasks. Prepare pain management strategy for later.'
      });
    }
    
    // HRV-Focus Correlation
    if (biologicalData.hrvStatus < -10) {
      insights.push({
        type: 'critical',
        message: 'Stress levels are impacting cognitive resources. Focus will be fragmented today.',
        actionItem: 'Use time-boxing (25min focus blocks) instead of expecting sustained attention.'
      });
    }
    
    return this.synthesizeWorkInsights(insights);
  }
  
  analyzeBeautyTag(biologicalData: BiologicalContext, environmentalData: EnvironmentalContext): TagInsight {
    // Similar detailed analysis for Beauty factors...
  }
  
  // Additional tag analysis methods...
}
```
