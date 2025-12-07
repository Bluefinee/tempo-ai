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

Phase 1.5 introduces the sophisticated AI analysis architecture that transforms raw health and environmental data into meaningful, contextual insights. This phase builds on Phase 1's Human Battery foundation and implements the **"Empathetic Partner"** AI model that provides **"Happy Insights"** - advice that empowers rather than scolds, validates rather than criticizes.

---

## 2. Data Context Payload (AIへの入力データ)

### A. Structured JSON Schema for AI Analysis

```typescript
interface AIAnalysisRequest {
  // Core Human Battery Data
  batteryLevel: number;          // 0-100%, calculated battery remaining
  batteryTrend: 'charging' | 'draining' | 'stable';
  
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
    mode: 'Standard' | 'Athlete';
    activeTags: FocusTag[];      // Selected focus tags
    timeOfDay: 'morning' | 'afternoon' | 'evening' | 'night';
    language: 'ja' | 'en';
  };
}
```

### B. Data Processing Rules (Static Logic)

**Static calculations performed on-device before AI analysis:**

```typescript
// Battery Engine (Local Processing)
const calculateBattery = (sleepScore: number, hrvScore: number, environmentalLoad: number): number => {
  const baseCharge = (sleepScore * 0.6) + (hrvScore * 0.4);
  const environmentalDrain = environmentalLoad * 0.1; // Pressure drops, extreme temp
  return Math.max(0, Math.min(100, baseCharge - environmentalDrain));
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

### A. System Persona Definition

```typescript
const SYSTEM_PERSONA = `
You are Tempo, a sophisticated health partner with deep empathy and scientific knowledge. 
Your primary goal is to make the user feel **understood**, **validated**, and **empowered**.

Core Principles:
1. NEVER scold or criticize the user for "bad" data
2. Always offer a "recovery strategy" instead of dwelling on problems  
3. Start responses with THE CONCLUSION first (The Headline)
4. Connect invisible environmental forces to how the user feels
5. Provide permission to rest OR encouragement to push - never guilt

You are not a doctor. You are a wise friend who sees patterns the user cannot see.
`;
```

### B. Dynamic Prompt Injection (Tag-Specific Logic)

```typescript
interface TagAnalysisLogic {
  Work: {
    dataFocus: ['sleepRem', 'pressureTrend', 'batteryLevel'];
    logic: `
      - If REM sleep < 60min OR pressure drops > 5hPa: Warn "Brain Fog Risk" 
      - Suggest high-focus tasks be done NOW before cognitive decline
      - If battery < 30%: "Permission to delegate or postpone non-critical tasks"
    `;
  };
  
  Beauty: {
    dataFocus: ['sleepDeep', 'humidity', 'uvIndex'];
    logic: `
      - If Deep sleep < 40min OR humidity < 40%: "Skin Barrier Disruption Risk"
      - Suggest hydration strategy and earlier bedtime (growth hormone 10PM-2AM)
      - UV protection advice based on index and skin exposure time
    `;
  };
  
  Athlete: {
    dataFocus: ['hrvStatus', 'feelsLike', 'batteryLevel'];
    logic: `
      - If HRV high (+10ms) AND temp moderate: "Go for Personal Best"
      - If HRV low (-10ms): "Active Recovery Only - trust your body"
      - Heat index > 32°C: "Adjust intensity, prioritize hydration"
    `;
  };
}
```

### C. Conflict Resolution Logic

```typescript
const resolveTagConflicts = (tags: FocusTag[], batteryLevel: number): string => {
  // BIOLOGICAL SAFETY ALWAYS WINS
  if (batteryLevel < 20) {
    return "Battery critically low. All activities should prioritize recovery.";
  }
  
  // Example: Work + Beauty conflict
  if (tags.includes('Work') && tags.includes('Beauty') && batteryLevel < 50) {
    return "Your skin needs the recovery more than work needs the extra hour. Early rest wins tonight.";
  }
  
  return "Multiple focuses detected. Prioritizing based on your current energy state.";
};
```

---

## 4. Output Schema (AIからの返答構造)

```typescript
interface AIAnalysisResponse {
  headline: {
    title: string;              // "気圧低下 × 肌荒れ注意" 
    subtitle: string;           // "夕方の頭痛に備え、今のうちに加湿と休憩を"
    impactLevel: 'low' | 'medium' | 'high'; // UI color coding
    confidence: number;         // 0-100% AI confidence in analysis
  };
  
  batteryComment: string;       // "予想より消耗が早いです。ペースを落としましょう"
  
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
    high_battery: "You are unstoppable today. **Permission granted** to push your limits!";
    low_battery: "**Permission granted** to rest without guilt. Tomorrow needs you at 100%.";
    medium_battery: "**Permission granted** to choose your battles today.";
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
| **Battery Calculation** | **Static (Local)** | `BatteryEngine.swift` | Real-time necessity, no API delay |
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
        let battery = BatteryEngine.calculate(from: healthData)
        let colors = ColorScheme.from(battery: battery)
        
        // 2. Show immediate feedback
        UI.update(battery: battery, colors: colors)
        
        // 3. Fetch AI enhancement asynchronously
        let aiInsight = await AIService.analyze(context: fullContext)
        
        // 4. Enhance UI with AI content
        UI.enhance(with: aiInsight)
        
        return AnalysisResult(static: battery, ai: aiInsight)
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
    'battery_change_>20%',     // Significant battery shift
    'weather_pressure_change_>3hPa',  // Meaningful weather change
    'new_health_data',         // Fresh HealthKit sync
    'tag_preference_change'    // User updates focus tags
  ];
  
  // Fallback priorities
  fallback_order: [
    'cached_ai_response',      // Show last AI response if < 3 hours old
    'static_rule_engine',      // Generate basic advice locally  
    'minimal_battery_view'     // Show battery only if all else fails
  ];
}
```

### B. Error Handling & Offline Support

```swift
enum AnalysisState {
    case fresh(AIAnalysisResponse)      // New AI analysis
    case cached(AIAnalysisResponse)     // Cached AI response
    case fallback(StaticAnalysis)       // Local rule engine
    case minimal(BatteryData)           // Battery only
    case offline                        // No data available
}

class OfflineAnalysisEngine {
    func generateFallbackAdvice(battery: Double, weather: WeatherData?) -> StaticAnalysis {
        var advice = "Battery at \(Int(battery))%. "
        
        if battery > 70 {
            advice += "Energy is high - good time for challenging tasks."
        } else if battery < 30 {
            advice += "Energy is low - prioritize rest and recovery."
        } else {
            advice += "Energy is moderate - pace yourself through the day."
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