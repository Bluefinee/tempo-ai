# Phase 1.5 Technical Specification: AI Analysis Architecture
## Theme: Contextual Synthesis & "The Happy Insight"

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール
5. **UX 設計原則**: [.claude/ux_concepts.md](../../.claude/ux_concepts.md) - UX 心理学原則
6. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

## 1. Overview

Phase 1.5 introduces the sophisticated AI analysis architecture that transforms raw health and environmental data into meaningful, contextual insights. This phase builds on Phase 1's energy state visualization foundation and implements the **"Focus-Driven AI Specialists"** that provide **"Empowering Insights + Today's Try"** - advice that empowers rather than scolds, validates rather than criticizes, and suggests new personalized experiences.

### 🆕 **"Today's Try" Innovation**
Each focus area acts as a specialized AI advisor that not only analyzes current state but also suggests **personalized new experiences** based on real-time conditions and user history.

---

## 2. Data Context Payload (AIへの入力データ)

### A. Structured JSON Schema for AI Analysis

```typescript
interface AIAnalysisRequest {
  // Core Energy State Data
  energyLevel: number;          // 0-100%, calculated energy remaining
  energyTrend: 'recovering' | 'declining' | 'stable';
  
  // Biological Context (HealthKit processed)
  biologicalContext: {
    hrvStatus: number;           // SDNN deviation from 60-day average (ms)
    rhrStatus: number;           // RHR difference from baseline (bpm)
    sleepDeep: number;           // Deep sleep duration (minutes)
    sleepRem: number;            // REM sleep duration (minutes) 
    respiratoryRate: number;     // Current respiratory rate (breaths/min)
    steps: number;               // Daily step count
    activeCalories: number;      // Active energy burned (kcal)
  };
  
  // Environmental Context (Open-Meteo)
  environmentalContext: {
    pressureTrend: number;       // Surface pressure change over 6h (hPa)
    humidity: number;            // Relative humidity (%)
    feelsLike: number;           // Apparent temperature (°C)
    uvIndex: number;             // UV index (0-11)
    weatherCode: number;         // WMO weather interpretation code
  };
  
  // User Context & Preferences
  userContext: {
    activeTags: FocusTag[];      // 6 specialized focus areas (removed lifestyle modes)
    timeOfDay: 'morning' | 'afternoon' | 'evening' | 'night';
    language: 'ja' | 'en';
    trialHistory: TrialExperience[]; // Track what user has tried
  };
  
  // New: Today's Try feature
  trialSuggestionRequest?: {
    focusArea: FocusTag;
    noveltyLevel: 'gentle' | 'moderate' | 'adventurous';
    timeConstraint: number; // minutes available
  };
}
```

### B. Data Processing Rules (Static Logic)

**Static calculations performed on-device before AI analysis:**

```typescript
// Energy Engine (Local Processing)
const calculateEnergyLevel = (sleepScore: number, hrvScore: number, environmentalLoad: number): number => {
  const baseRecovery = (sleepScore * 0.6) + (hrvScore * 0.4);
  const environmentalImpact = environmentalLoad * 0.1; // Pressure drops, extreme temp
  return Math.max(0, Math.min(100, baseRecovery - environmentalImpact));
};

// Environmental Load Calculation
const calculateEnvironmentalLoad = (weather: EnvironmentalContext): number => {
  let load = 0;
  if (weather.pressureTrend < -5) load += 20; // Pressure drop headache risk
  if (weather.feelsLike > 35) load += 15;     // Heat stress
  if (weather.humidity < 30) load += 10;      // Dry skin stress  
  return load;
};
```

---

## 3. Prompt Engineering Framework (AIへの指示書)

### A. Lifestyle-Adaptive Persona System (モード別AIペルソナ)

```typescript
const MODE_SPECIFIC_PERSONAS = {
  standard: {
    persona_name: "ヘルスケアパートナー",
    core_identity: `
You are a gentle, empathetic healthcare partner who prioritizes daily wellness and sustainable habits.
Your goal is to make the user feel **supported**, **understood**, and **empowered** without pressure.

Tone & Approach:
- Use gentle, suggestion-based language ("〜してみませんか？")
- Focus on small, achievable improvements
- Validate feelings and acknowledge external factors (weather, stress)
- Prioritize mental health and work-life balance
- Avoid overwhelming technical details
    `,
    
    response_style: {
      complexity: "simple",
      data_presentation: "human-friendly explanations",
      action_suggestions: "micro-actions (2-5 minutes)",
      technical_depth: "minimal",
      encouragement_level: "high"
    }
  },
  
  athlete: {
    persona_name: "パフォーマンスメンター", 
    core_identity: `
You are a data-driven performance mentor who helps optimize training and recovery.
Your goal is to provide **strategic**, **objective**, and **actionable** insights for peak performance.

Tone & Approach:
- Use clear, analytical language with specific metrics
- Focus on performance optimization and efficient recovery
- Provide strategic recommendations based on data trends
- Respect the user's commitment to excellence
- Include relevant technical details when beneficial
    `,
    
    response_style: {
      complexity: "detailed",
      data_presentation: "metrics and trends",
      action_suggestions: "strategic interventions (10-30 minutes)",
      technical_depth: "comprehensive",
      encouragement_level: "motivational"
    }
  }
};
```

### B. 6つの関心分野専門AI + Try機能 (Focus-Driven Specialists)

**設計変更**: ライフスタイルモード削除により、6つの関心分野がそれぞれ独立した専門AIアドバイザーとして機能。「今日のトライ」「今週のトライ」で温かく個人的な新体験を提案：

```typescript
interface SixFocusAreaSpecialists {
  // 🧠 Work: 認知パフォーマンス最適化
  work: {
    persona: "集中力コーチ",
    todays_try: "今日の集中力が高めですね。新しいポモドーロテクニック（25分集中+5分休憩）を試してみませんか？いつもより深い集中を体験できるかもしれません。",
    weekly_try: "今週は「マインドフルワーク」を取り入れてみませんか。作業の前に2分間、呼吸を意識して心を落ち着かせる時間を作ることで、集中力が高まり、作業効率が向上します。この習慣は、ストレスを軽減し、より創造的な仕事へと導いてくれるでしょう。"
  },
  
  // ✨ Beauty: 美容・スキンケア専門
  beauty: {
    persona: "美容コンシェルジュ",
    todays_try: "今日の湿度は30%と低めです。お肌のために、温かいカモミールティーで内側からの水分補給を試してみませんか？リラックス効果もあり、一石二鳥です。",
    weekly_try: "今週は「夜のスペシャルケア」を取り入れてみませんか。温めたセサミオイルで顔を優しくマッサージすることで、血行を促進し、翌朝の肌の輝きが違ってくるでしょう。この習慣は、日中のストレスをリセットし、美しさと心の安らぎを同時に育んでくれます。"
  },
  
  // 🥗 Diet: 食事・栄養専門
  diet: {
    persona: "栄養タイミングアドバイザー",
    todays_try: "今日の活動量から、ランチにナッツを小皿一杯追加してみませんか？良質な脂質が脳の機能をサポートし、午後の集中力が向上します。",
    weekly_try: "今週は「色彩豊かな朝食」を始めてみませんか。赤（トマト）、緑（ホウレン草）、黄（パプリカ）の野菜を組み合わせることで、様々な栄養素をバランスよく摂取できます。色鮮やかな朝食は、一日をポジティブな気持ちでスタートさせてくれるでしょう。"
  },
  
  // 💤 Sleep: 睡眠質・リカバリー専門
  sleep: {
    persona: "睡眠ウェルネスアドバイザー",
    todays_try: "昨夜の睡眠が浅めでしたね。今夜は入眠1時間前にカモミールティーを飲んでみませんか？自然な眠気を誘い、深い眠りにつながります。",
    weekly_try: "今週は「睡眠前リチュアル」を作ってみませんか。入浴後に、ラベンダーオイルで手首を優しくマッサージし、好きな本を数ページ読む時間を作りましょう。この習慣は副交感神経を優位にし、深いリラックスと質の高い睡眠へと導いてくれます。"
  },
  
  // 🏃‍♂️ Fitness: 運動・トレーニング専門
  fitness: {
    persona: "フィットネスコーチ",
    todays_try: "HRV+12ms、気温22℃でコンディション理想ですね。今日は普段より5分長いウォーキングにチャレンジしませんか？体が求めている新しい刺激を与えてあげましょう。",
    weekly_try: "今週は「モーニングストレッチ」を日課にしてみませんか。起床後5分間、太陽の光を浴びながら全身をゆっくりと伸ばすことで、一日のエネルギーが活性化されます。この習慣は、日中の運動パフォーマンスを向上させ、よりアクティブな生活へと導いてくれるでしょう。"
  },
  
  // 🍃 Chill: ストレス管理・リラックス専門
  chill: {
    persona: "リラクゼーションスペシャリスト",
    todays_try: "今日は気圧が下がっていて、体が重く感じるかもしれません。温かいジンジャーティーで体を内側から温めて、気圧変化に負けない体作りをしませんか？",
    weekly_try: "今週は「夜のオイルマッサージ」を取り入れてみませんか。温めたセサミオイルで足裏を優しくマッサージすることは、ヴァータの乱れによる思考の巡りすぎや不安を鎮め、深い眠りへと誘います。これまでの実践で得た知識と、ご自身の体質への理解を両輪に、これからもエネルギッシュで穏やかな毎日を創造していってください。"
  }
}
```

### C. 関心分野シンセシス・ロジック (Multi-Focus Synthesis)

6つの関心分野から複数選択された場合のシナジー提案システム：

```typescript
const synthesizeFocusAreas = (selectedTags: FocusTag[], energyLevel: number): TryAdvice => {
  // エネルギー状態による優先度調整
  if (energyLevel < 30) {
    return prioritizeRecoveryFocusAreas(selectedTags); // Sleep, Chill優先
  }
  
  // 複数分野のシナジー例
  if (selectedTags.includes('sleep') && selectedTags.includes('beauty')) {
    return {
      todays_try: "睡眠×美容のゴールデンタイム。22時からのナイトルーチンで、美肌と深い睡眠を同時に手に入れませんか？",
      weekly_try: "今週は「美容睡眠週間」として、成長ホルモン分泌ピーク（22-02時）を最大活用する生活リズムを試してみましょう。"
    };
  }
  
  if (selectedTags.includes('work') && selectedTags.includes('fitness')) {
    return {
      todays_try: "脳と体の両方が活性化中。15分の散歩ミーティング（電話会議）で、運動と仕事を同時に効率化しませんか？",
      weekly_try: "今週は「アクティブワーク」として、スタンディングデスクや歩きながらの思考時間を取り入れて、座りっぱなしを解消しましょう。"
    };
  }
  
  return generateBalancedAdvice(selectedTags, energyLevel);
};
```

---

## 4. AI分析タイミング戦略 (Smart Analysis Scheduling)

### A. 3段階AI分析システム

**設計原則**: コスト効率と体験価値の最適バランスを実現

```typescript
interface AIAnalysisTimingStrategy {
  // 1. 朝の詳細AI分析 (高価値・高コスト)
  morning_deep_analysis: {
    frequency: "daily_once", // 1日1回
    timing: "07:00-09:00",   // 朝の時間帯
    trigger: "app_first_open_of_day",
    processing: "claude_api_full_analysis",
    output: {
      main_advice: "包括的な健康アドバイス",
      todays_try: "即実行可能な新体験提案（2-15分）",
      energy_forecast: "1日のエネルギー予測",
      environmental_alerts: "気圧・天候への対策"
    },
    cost_impact: "high", // ~$0.04/request
    value_impact: "highest"
  },

  // 2. リアルタイム軽量分析 (親しみやすさ・ゼロコスト)
  realtime_light_analysis: {
    frequency: "on_app_open", // アプリ開く度
    timing: "immediate",
    trigger: "healthkit_data_change_detected",
    processing: "local_rule_engine", // AIリクエストなし
    output: {
      quick_status: "「少し疲れ気味ですね」「調子良さそうです」",
      micro_suggestions: "簡単なアクション（休憩、水分補給等）",
      energy_update: "現在のエネルギー状態"
    },
    cost_impact: "zero", // ローカル処理
    value_impact: "medium" // 親しみやすさとリアルタイム性
  }
}
```

### B. ローカル軽量分析エンジン

```swift
class LocalAnalysisEngine {
    func generateQuickResponse(
        previousEnergy: Double,
        currentEnergy: Double,
        selectedFocusAreas: Set<FocusTag>
    ) -> QuickAdvice? {
        
        let energyChange = currentEnergy - previousEnergy
        
        // 疲労増加検出 (関心分野別アドバイス)
        if energyChange < -15 {
            if selectedFocusAreas.contains(.chill) {
                return QuickAdvice(message: "少し疲れが溜まってきましたね。深呼吸で心をリセットしませんか？")
            } else if selectedFocusAreas.contains(.work) {
                return QuickAdvice(message: "集中力が下がってきたようです。5分の休憩で効率を回復させましょう。")
            }
        }
        
        // エネルギー回復検出
        if energyChange > 10 && currentEnergy > 70 {
            if selectedFocusAreas.contains(.fitness) {
                return QuickAdvice(message: "調子が良さそうです！軽い運動で更なる活性化はいかがですか？")
            }
        }
        
        return nil // 大きな変化なし
    }
}
```

---

## 5. Output Schema (AIからの返答構造)

```typescript
interface AIAnalysisResponse {
  headline: {
    title: string;              // "気圧低下 × 肌荒れ注意" 
    subtitle: string;           // "夕方の頭痛に備え、今のうちに加湿と休憩を"
    impactLevel: 'low' | 'medium' | 'high'; // UI color coding
    confidence: number;         // 0-100% AI confidence in analysis
  };
  
  energyComment: string;       // "予想より疲労が早いです。ペースを落としましょう"
  
  tagInsights: Array<{
    tag: FocusTag;
    icon: string;               // SF Symbol name
    message: string;            // "湿度が30%を切りました。ミスト化粧水で対策を"
    urgency: 'info' | 'warning' | 'critical';
  }>;
  
  smartSuggestions: Array<{
    title: string;
    description: string;
    actionType: 'rest' | 'hydrate' | 'exercise' | 'focus' | 'social';
    estimatedTime: string;      // "5 minutes", "30 minutes"
    difficulty: 'easy' | 'medium' | 'hard';
  }>;
  
  detailAnalysis: string;       // Markdown explanation of correlations
  
  // Meta Information
  dataQuality: {
    healthDataCompleteness: number; // 0-100%
    weatherDataAge: number;         // minutes since last update  
    analysisTimestamp: string;
  };
}
```

---

## 5. The "Happy Advice" Strategy Implementation

### A. The Three Pillars of Happy Insights

```typescript
interface HappyAdviceFramework {
  // 1. Permission-Granting (許可を与える)
  permissive: {
    high_energy: "You are unstoppable today. **Permission granted** to push your limits!";
    low_energy: "**Permission granted** to rest without guilt. Tomorrow needs you at 100%.";
    medium_energy: "**Permission granted** to choose your battles today.";
  };
  
  // 2. Contextual Connection (意外なつながり)  
  contextual: {
    pressure_drop_headache: "That headache isn't your fault - the pressure dropped 8hPa. Your body is just sensitive to weather.";
    humidity_skin: "Your skin feels tight because humidity dropped to 25%. It's the air, not your routine.";
    sleep_work: "Your focus dips at 2PM because your REM sleep was cut short. It's biology, not laziness.";
  };
  
  // 3. Micro-Actions (小さな提案)
  microActions: {
    instead_of: "1 hour gym session";
    suggest: "3 deep breaths right now";
    examples: ["One glass of water", "2-minute walk", "30-second stretch", "Close eyes for 10 seconds"];
  };
}
```

### B. Implementation in Response Generation

```typescript
const generateHappyAdvice = (context: AIAnalysisRequest): string => {
  // ALWAYS start with validation, not criticism
  const validation = findValidation(context);
  
  // Connect invisible forces to feelings
  const connection = findEnvironmentalConnection(context);
  
  // Offer micro-action instead of overwhelming change
  const microAction = generateMicroAction(context);
  
  return `${validation} ${connection} ${microAction}`;
};

// Example outputs:
// "Your energy dip is completely normal - the pressure dropped 6hPa in 3 hours. How about one deep breath to reset?"
// "That restless feeling makes sense - humidity is at 28%. Try a 2-minute face mist break."
```

---

## 6. Static vs AI Processing Matrix (Cost Optimization)

| Feature | Processing Type | Implementation | Rationale |
|---------|----------------|----------------|-----------|
| **Energy Calculation** | **Static (Local)** | `EnergyEngine.swift` | Real-time necessity, no API delay |
| **Color Coding** | **Static (Local)** | `ColorScheme.swift` | Immediate UI response |
| **Weather Icon Mapping** | **Static (Local)** | `WeatherCode → SFSymbol` | No AI needed for simple mapping |
| **Headline Generation** | **AI (Cloud)** | Claude API | Complex correlation analysis needed |
| **Smart Suggestions** | **Hybrid** | AI generates, app formats | Content=AI, Display=Local |
| **Tag Insights** | **AI (Cloud)** | Claude API | Multi-factor synthesis required |
| **Fallback Advice** | **Static (Local)** | `StaticRuleEngine.swift` | Offline/error scenarios |

### Implementation Pattern:

```swift
class HybridAnalysisEngine {
    func generateInsight() async -> AnalysisResult {
        // 1. Calculate static components immediately
        let energy = EnergyEngine.calculate(from: healthData)
        let colors = ColorScheme.from(energy: energy)
        
        // 2. Show immediate feedback
        UI.update(energy: energy, colors: colors)
        
        // 3. Fetch AI enhancement asynchronously
        let aiInsight = await AIService.analyze(context: fullContext)
        
        // 4. Enhance UI with AI content
        UI.enhance(with: aiInsight)
        
        return AnalysisResult(static: energy, ai: aiInsight)
    }
}
```

---

## 7. Caching & Performance Strategy

### A. Smart Caching Rules

```typescript
interface CacheStrategy {
  // AI responses cached for 1 hour
  ai_cache_duration: 3600; // seconds
  
  // Cache invalidation triggers
  invalidate_on: [
    'energy_change_>20%',     // Significant energy shift
    'weather_pressure_change_>3hPa',  // Meaningful weather change
    'new_health_data',         // Fresh HealthKit sync
    'tag_preference_change'    // User updates focus tags
  ];
  
  // Fallback priorities
  fallback_order: [
    'cached_ai_response',      // Show last AI response if < 3 hours old
    'static_rule_engine',      // Generate basic advice locally  
    'minimal_energy_view'     // Show energy only if all else fails
  ];
}
```

### B. Error Handling & Offline Support

```swift
enum AnalysisState {
    case fresh(AIAnalysisResponse)      // New AI analysis
    case cached(AIAnalysisResponse)     // Cached AI response
    case fallback(StaticAnalysis)       // Local rule engine
    case minimal(EnergyData)           // Energy only
    case offline                        // No data available
}

class OfflineAnalysisEngine {
    func generateFallbackAdvice(energy: Double, weather: WeatherData?) -> StaticAnalysis {
        var advice = "エネルギーレベルは \(Int(energy))%です。"
        
        if energy > 70 {
            advice += "調子が良いですね。チャレンジングなタスクに取り組めそうです。"
        } else if energy < 30 {
            advice += "少しお疲れのようです。休息と回復を優先しましょう。"
        } else {
            advice += "バランスの取れた状態です。無理のないペースで進みましょう。"
        }
        
        if let weather = weather, weather.pressureTrend < -3 {
            advice += " Pressure is dropping - headaches possible."
        }
        
        return StaticAnalysis(advice: advice, confidence: 0.6)
    }
}
```

---

## 8. Implementation Phases

### Phase 1.5A: Core AI Infrastructure
- [ ] Implement `AIAnalysisRequest` and `AIAnalysisResponse` types
- [ ] Create `HybridAnalysisEngine` with static/AI separation
- [ ] Build prompt construction system with dynamic tag injection
- [ ] Implement caching layer with 1-hour expiration

### Phase 1.5B: Happy Advice Engine  
- [ ] Create `HappyAdviceFramework` with permission/connection/micro-action patterns
- [ ] Implement conflict resolution logic for multi-tag scenarios
- [ ] Build `StaticRuleEngine` for offline fallback
- [ ] Add confidence scoring for AI responses

### Phase 1.5C: Integration & Testing
- [ ] Integrate with existing `BatteryEngine` from Phase 1
- [ ] Connect to `WeatherService` for environmental context
- [ ] Implement UI updates for new AI response schema
- [ ] Add error states and loading improvements

### Phase 1.5D: Optimization & Polish
- [ ] Optimize prompt token usage for cost efficiency
- [ ] Implement cache invalidation strategies
- [ ] Add A/B testing framework for advice variations
- [ ] Performance monitoring for AI response times

---

## 9. Success Metrics

### Technical Performance
- AI response time < 2 seconds (95th percentile)
- Cache hit rate > 60% for repeated app opens
- Fallback engagement rate < 15% (offline scenarios)
- Zero crashes from malformed AI responses

### User Experience 
- Time to first insight < 0.5 seconds (static components)
- User session length increase (engaging insights)
- Positive sentiment in advice feedback
- Reduced "advice fatigue" compared to generic health apps

### Cost Optimization
- API costs < $0.10 per daily active user
- Token usage optimization (target: 2000 tokens per analysis)
- Cache efficiency reducing redundant API calls by 60%

---

## 10. Dependencies & Prerequisites

### Backend Updates (Cloudflare Workers)
- Update `AnalysisRequest` schema with new fields
- Implement dynamic prompt construction
- Add response validation with Zod
- Implement caching layer with KV storage

### iOS Updates  
- Create new model types for AI responses
- Update `HealthService` to calculate processed metrics
- Enhance `WeatherService` with pressure trend calculation
- Implement `HybridAnalysisEngine` coordination layer

### Design System Updates
- New loading states for hybrid static/AI content
- Error state designs for AI service failures  
- Enhanced card layouts for multi-insight display
- Confidence indicators for AI-generated advice

This Phase 1.5 establishes the foundation for truly intelligent, contextual, and emotionally resonant health insights that transform Tempo AI from a data display tool into an empathetic partner.