# Phase 3 Technical Specification: Cleanup & Optimization

## Theme: Refactoring, Standardization, and Performance

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール
5. **UX 設計原則**: [.claude/ux_concepts.md](../../.claude/ux_concepts.md) - UX 心理学原則
6. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

### 1. Overview

After the feature implementations of Phases 1, 1.5, and 2, Phase 3 focuses on **optimization, performance, and technical debt removal**.
This phase ensures the AI analysis architecture is cost-effective, performant, and maintainable while cleaning up any accumulated technical debt.

The goal is to create a production-ready system that delivers intelligent insights efficiently and reliably.

### 2. AI System Optimization (Priority Focus)

#### A. Lifestyle Mode-Aware Optimization

**Mode-Specific Cost Management:**

```typescript
interface ModeOptimizationStrategy {
  standard_mode: {
    target_tokens: 1500,  // Simpler, more conversational responses
    cache_duration: 4800, // 80 minutes (longer due to stable lifestyle patterns)
    complexity_level: "simplified",
    personalization_depth: "moderate"
  },
  
  athlete_mode: {
    target_tokens: 2500,  // Detailed, data-rich responses
    cache_duration: 3600, // 60 minutes (shorter due to dynamic training needs)
    complexity_level: "comprehensive", 
    personalization_depth: "deep"
  }
}
```

**Token Efficiency Strategy:**

```typescript
interface ModeAwarePromptOptimization {
  // Dynamic targets based on user lifestyle mode
  standard_mode_target: 1500; // tokens (simpler responses)
  athlete_mode_target: 2500;   // tokens (detailed analysis)
  blended_average: 2000;       // overall target
  optimization_strategies: [
    "Remove redundant context repetition",
    "Use structured data format instead of verbose descriptions", 
    "Implement prompt template caching",
    "Dynamic context inclusion based on relevance scores"
  ];
}

class OptimizedPromptBuilder {
  buildPrompt(context: AIAnalysisRequest): string {
    // 1. Core context only (no redundant information)
    const essentialContext = this.extractEssentialContext(context);
    
    // 2. Dynamic tag injection (only active tags)
    const relevantTagInstructions = this.getRelevantTagInstructions(context.userContext.activeTags);
    
    // 3. Structured data format (JSON-like, not prose)
    const structuredData = this.formatAsStructuredData(context);
    
    return this.assembleOptimizedPrompt(essentialContext, relevantTagInstructions, structuredData);
  }
}
```

#### B. Intelligent Caching Architecture

**Multi-Layer Caching Strategy:**

```typescript
interface CacheLayerStrategy {
  // Layer 1: Instant Response Cache (1 hour)
  layer1: {
    duration: 3600; // seconds
    triggers: ['app_open', 'energy_calculation'];
    purpose: "Eliminate loading delays for frequent app usage";
  };
  
  // Layer 2: Contextual Cache (4 hours)  
  layer2: {
    duration: 14400; // seconds
    triggers: ['significant_data_change', 'weather_update'];
    purpose: "Reduce API calls for similar contexts";
  };
  
  // Layer 3: Fallback Static Analysis (permanent)
  layer3: {
    duration: 'permanent';
    triggers: ['api_failure', 'offline_mode'];
    purpose: "Ensure app functionality during service disruptions";
  };
}

class IntelligentCacheManager {
  async getAnalysis(context: AIAnalysisRequest): Promise<AnalysisResult> {
    // Check Layer 1: Recent identical context
    const cached = await this.getFromLayer1(context);
    if (cached && this.isStillRelevant(cached, context)) {
      return this.enhanceWithFreshData(cached, context);
    }
    
    // Check Layer 2: Similar context patterns
    const similarCache = await this.findSimilarContext(context);
    if (similarCache && this.canAdapt(similarCache, context)) {
      return this.adaptCachedAnalysis(similarCache, context);
    }
    
    // Layer 3: Generate new analysis
    const freshAnalysis = await this.requestAIAnalysis(context);
    await this.cacheWithStrategy(freshAnalysis, context);
    
    return freshAnalysis;
  }
}
```

#### C. Cost Management & Rate Limiting

**AI Usage Optimization:**

```typescript
interface CostOptimizationStrategy {
  // Budget: $0.10 per daily active user
  daily_budget_per_user: 0.10; // USD
  cost_per_analysis: 0.02;      // USD (2000 tokens)
  max_analyses_per_day: 5;      // per user
  
  rate_limiting: {
    same_context_reuse_window: 3600; // seconds - don't reanalyze identical context
    minimum_data_change_threshold: 10; // % - require significant change for new analysis
    fallback_to_static_after: 3; // failed requests
  };
  
  optimization_techniques: [
    "Batch analysis requests during low-usage periods",
    "Predictive caching based on user patterns", 
    "Progressive disclosure - basic analysis first, detailed on demand",
    "Smart invalidation - only refresh when meaningful changes occur"
  ];
}

class AIUsageOptimizer {
  async requestAnalysis(context: AIAnalysisRequest, user: User): Promise<AnalysisResult> {
    // Check daily usage limits
    if (await this.exceedsUsageLimit(user)) {
      return this.generateStaticFallback(context);
    }
    
    // Check if analysis is necessary (meaningful change threshold)
    if (!await this.isAnalysisWarranted(context, user)) {
      return this.enhanceLastAnalysis(context, user);
    }
    
    // Proceed with AI analysis
    return this.performOptimizedAnalysis(context);
  }
}
```

#### D. Response Validation & Error Handling

**Robust AI Response Processing:**

```typescript
interface AIResponseValidation {
  validation_schema: ZodSchema<AIAnalysisResponse>;
  fallback_strategies: [
    "Partial response reconstruction",
    "Static rule engine activation", 
    "Cached response adaptation",
    "Minimal energy-only display"
  ];
  
  error_monitoring: {
    malformed_response_rate: "< 1%";
    api_timeout_rate: "< 5%";
    cost_overrun_alerts: "real-time";
    user_satisfaction_tracking: "weekly surveys";
  };
}

class RobustAIHandler {
  async processAIResponse(rawResponse: string, context: AIAnalysisRequest): Promise<AnalysisResult> {
    try {
      // 1. Parse and validate response
      const parsed = JSON.parse(rawResponse);
      const validated = this.validationSchema.parse(parsed);
      
      // 2. Enhance with confidence scores
      const enhanced = this.addConfidenceMetrics(validated, context);
      
      // 3. Cache successful response
      await this.cacheResponse(enhanced, context);
      
      return enhanced;
      
    } catch (error) {
      // Graceful degradation strategy
      return this.handleResponseError(error, context);
    }
  }
  
  private async handleResponseError(error: Error, context: AIAnalysisRequest): Promise<AnalysisResult> {
    if (error instanceof SyntaxError) {
      // Malformed JSON - try to extract partial data
      return this.attemptPartialRecovery(context);
    } else if (error instanceof ZodError) {
      // Schema validation failed - use static fallback
      return this.generateStaticAnalysis(context);
    } else {
      // Network/service error - use cached data
      return this.getMostRecentCache(context) ?? this.generateMinimalAnalysis(context);
    }
  }
}
```

### 3. Cleanup Targets

#### A. Remove Legacy Logic

- **Score System:** Completely remove any code related to the old "0-100 Health Score" if it contradicts the "Energy State" logic.
- **Unused Views:** Delete old Dashboard views, cards, or assets that do not fit the "Digital Cockpit" (Black/Neon) design system.
- **Hardcoded Text:** Move any hardcoded strings to `Localizable.strings` (English/Japanese).

#### B. Architecture Standardization

- **MVVM Strictness:** Ensure no business logic exists inside SwiftUI Views. All logic must be in ViewModels.
- **Service Layer:** Consolidate HealthKit queries and API calls into dedicated Services (`HealthService`, `WeatherService`, `AIService`).
- **Dependency Injection:** Ensure Services are injected into ViewModels for testability.

### 3. Data Model Refactoring

- **UserProfile:** Ensure `focusTags` (Set) and `userMode` (Enum) are the single source of truth. Remove conflicting flags.
- **Type Safety:** Verify that all JSON parsing from the Backend is strictly typed using `Codable` (Swift) and Zod (TypeScript).

### 4. UI Polish & Performance

- **View Hierarchy:** Reduce the depth of `VStack`/`HStack` embedding to improve rendering performance.
- **Animation:** Ensure the Liquid Energy animation does not cause high CPU usage (optimize frames or use efficient libraries).
- **Error States:** Implement user-friendly error views (e.g., "Offline Mode", "Weather Unavailable") instead of generic alerts.

### 5. Backend Optimization (Enhanced for AI Architecture)

#### A. AI-Specific Optimizations

- **Prompt Optimization:** 
  - Implement token counting and optimization algorithms
  - Create prompt templates with variable injection points
  - Establish prompt performance benchmarks (target: 2000 tokens)
  - Add prompt caching layer to avoid reconstruction

- **Dead Code Removal:**
  - Remove unused API routes or helper functions in Cloudflare Workers
  - Eliminate redundant data processing pipelines
  - Clean up old health scoring logic that conflicts with Energy State system

- **API Route Optimization:**
  - Implement batch processing for multiple health data points
  - Add request deduplication for identical contexts
  - Optimize JSON parsing and validation performance
  - Add response compression for large AI responses

#### B. Performance Monitoring Implementation

```typescript
interface AIPerformanceMetrics {
  // Response Time Monitoring
  response_times: {
    target_p95: 2000; // milliseconds
    target_p99: 3000; // milliseconds
    current_average: number;
  };
  
  // Cost Monitoring  
  cost_metrics: {
    daily_cost_per_user: number;
    token_efficiency_ratio: number; // useful insights per token
    cache_hit_rate: number; // % of requests served from cache
  };
  
  // Quality Monitoring
  quality_metrics: {
    user_satisfaction_score: number; // 1-5 rating
    advice_relevance_score: number;  // AI confidence x user feedback
    fallback_usage_rate: number;     // % of requests using static fallback
  };
}

class AIPerformanceMonitor {
  async trackAnalysisRequest(
    context: AIAnalysisRequest, 
    response: AnalysisResult, 
    duration: number
  ): Promise<void> {
    // Track performance metrics
    await this.recordResponseTime(duration);
    await this.recordTokenUsage(context, response);
    await this.recordCacheEfficiency(context);
    
    // Alert on performance issues
    if (duration > 3000) {
      await this.alertSlowResponse(context, duration);
    }
    
    if (response.source === 'fallback') {
      await this.trackFallbackUsage(context);
    }
  }
}
```

#### C. Cloudflare Workers Optimization

- **Memory Management:**
  - Implement streaming for large AI responses
  - Optimize context object serialization
  - Add garbage collection for unused cache entries

- **Edge Computing:**
  - Deploy caching layers closer to users geographically
  - Implement regional fallback strategies
  - Optimize for Cloudflare Workers runtime constraints

- **KV Storage Optimization:**
  - Design efficient key structure for cache lookups
  - Implement cache compression for storage efficiency
  - Add cache warming strategies for common user patterns

### 6. Deliverables

#### A. Optimized AI Architecture
- **Intelligent caching system** with 3-layer strategy (instant/contextual/fallback)
- **Cost-optimized prompt engineering** targeting 2000 tokens per analysis
- **Robust error handling** with graceful degradation to static analysis
- **Performance monitoring** with real-time cost and quality tracking

#### B. Clean Project Structure
- Separate `Models`, `Views`, `ViewModels`, `Services`, `Utils` directories
- Dedicated `AI/` folder with prompt builders, cache managers, and response processors
- Optimized service layer with clear separation between static and AI processing

#### C. Production Readiness
- Zero compiler warnings across iOS and backend codebases
- Comprehensive error states for offline/degraded AI service scenarios
- Performance benchmarks met (sub-2-second AI responses, >60% cache hit rate)
- Cost controls implemented ($0.10/user/day target achieved)

#### D. Documentation Updates
- Updated `README.md` reflecting AI-enhanced architecture
- Enhanced `CLAUDE.md` with AI optimization guidelines
- Comprehensive API documentation for AI service endpoints
- Performance monitoring dashboards and alerting setup

#### E. Mode-Specific Quality Assurance
- **A/B testing framework** with mode-specific variations (gentle vs analytical messaging)
- **User satisfaction tracking** separated by lifestyle mode for targeted improvements  
- **Mode-appropriate response quality** monitoring (empathy scores for Standard, accuracy scores for Athlete)
- **Differential cost management** with mode-aware budget allocation
- **Persona consistency validation** - ensuring Standard users never receive "harsh" feedback
- **Performance relevance scoring** - ensuring Athlete users receive actionable data insights

### 7. Success Metrics

#### Technical Performance
- **AI Response Time:** P95 < 2 seconds, P99 < 3 seconds
- **Cache Efficiency:** >60% cache hit rate for repeated app usage  
- **Cost Control:** <$0.10 per daily active user
- **Reliability:** <5% fallback usage rate during normal operations

#### Mode-Specific User Experience
- **Zero Loading States:** Static components render <0.5 seconds (both modes)
- **Seamless Degradation:** Graceful fallback to mode-appropriate static advice
- **Mode-Consistent Quality:** 
  - Standard Mode: Empathy & Support score >4.2/5.0
  - Athlete Mode: Data Relevance & Actionability score >4.0/5.0
- **Engagement by Mode:**
  - Standard: Increased daily check-ins (stress validation)
  - Athlete: Increased session depth (detailed analysis consumption)

#### Operational Excellence
- **Zero Critical Bugs:** No crashes from AI response processing
- **Monitoring Coverage:** 100% observability into AI system performance
- **Cost Predictability:** Monthly AI costs within 10% of projections
- **Scalability Ready:** System handles 10x current user load without degradation
