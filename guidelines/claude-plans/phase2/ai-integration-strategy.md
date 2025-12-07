# AI Integration Strategy - Phase 2

**Objective**: Implement intelligent, cost-efficient Claude AI integration for health analysis
**Principle**: Maximum value from AI requests while avoiding unnecessary costs

## AI Usage Decision Framework

### High-Value AI Analysis Triggers

#### 1. Daily Comprehensive Review
- **Frequency**: Once per day maximum
- **Trigger**: First comprehensive data request after 6 AM
- **Data Required**: Full day's health metrics + previous day's sleep
- **Value**: Holistic health assessment, pattern recognition, personalized insights

#### 2. Weekly Deep Analysis
- **Frequency**: Once per week (Sunday evening)
- **Trigger**: Weekly summary request or automatic trigger
- **Data Required**: 7 days aggregated health data + trends
- **Value**: Long-term pattern analysis, goal progress, lifestyle recommendations

#### 3. Critical Health Events
- **Frequency**: As needed (rate-limited)
- **Triggers**:
  - Blood pressure > Stage 2 hypertension
  - Resting heart rate > 120 BPM sustained
  - Sleep < 4 hours for consecutive days
  - Significant HRV decline (>20% from baseline)
- **Value**: Immediate health risk assessment, urgent recommendations

#### 4. User-Requested Detailed Analysis
- **Frequency**: User-initiated (rate-limited to 3 per day)
- **Trigger**: Manual "Get AI Analysis" button
- **Data Required**: Current comprehensive health state
- **Value**: On-demand personalized insights, specific question answering

#### 5. Significant Pattern Changes
- **Frequency**: Event-driven
- **Triggers**:
  - Health score change > 15 points in 3 days
  - Sleep efficiency drop > 20% for 3+ days
  - Activity level change crossing categories
- **Value**: Early intervention, trend explanation, corrective guidance

### Local Analysis Sufficient Cases

#### 1. Real-time Metrics Display
- Current heart rate, steps, calories
- Basic threshold alerts (daily goals)
- Simple progress indicators

#### 2. Rule-based Recommendations
- "Take 500 more steps to reach goal"
- "Bedtime reminder based on sleep goal"
- "Water break reminder after exercise"

#### 3. Achievement Notifications
- Daily/weekly goal completions
- Streak celebrations
- Milestone achievements

#### 4. Basic Health Tips
- General wellness advice
- Timing-based recommendations
- Standard medical guidelines

## Implementation Architecture

### 1. AI Request Routing Engine

```swift
@MainActor
class AIAnalysisRouter: ObservableObject {
    
    private let rateLimiter = AIRequestRateLimiter()
    private let costTracker = AICostTracker()
    private let localAnalyzer = LocalHealthAnalyzer()
    
    func routeAnalysisRequest(_ request: HealthAnalysisRequest) async -> AnalysisResponse {
        
        // 1. Evaluate AI necessity
        let aiRecommendation = evaluateAIRecommendation(for: request)
        
        switch aiRecommendation.decision {
        case .requiresAI(let reason):
            return await performAIAnalysis(request, reason: reason)
            
        case .localSufficient(let reason):
            return await performLocalAnalysis(request, reason: reason)
            
        case .rateLimited(let reason):
            return await performLocalAnalysis(request, fallbackReason: reason)
        }
    }
    
    private func evaluateAIRecommendation(for request: HealthAnalysisRequest) -> AIRecommendation {
        
        let factors = AIDecisionFactors(
            analysisType: request.type,
            dataRichness: assessDataRichness(request.healthData),
            userContext: request.userContext,
            timeSinceLastAI: rateLimiter.timeSinceLastAIRequest(),
            costBudgetRemaining: costTracker.remainingBudget(),
            criticalityLevel: assessCriticality(request.healthData)
        )
        
        return AIDecisionEngine.evaluate(factors)
    }
}

enum AIDecisionResult {
    case requiresAI(reason: String)
    case localSufficient(reason: String)  
    case rateLimited(reason: String)
}
```

### 2. Rate Limiting & Cost Control

```swift
class AIRequestRateLimiter {
    private let userDefaults = UserDefaults.standard
    
    func canMakeAIRequest(type: AnalysisType) -> RateLimitResult {
        let today = Calendar.current.startOfDay(for: Date())
        
        switch type {
        case .dailyComprehensive:
            return checkDailyLimit(date: today, limit: 1)
            
        case .weeklyReview:
            return checkWeeklyLimit(limit: 1)
            
        case .userRequested:
            return checkDailyLimit(date: today, limit: 3)
            
        case .criticalAlert:
            return checkHourlyLimit(limit: 2) // Emergency situations
            
        case .patternChange:
            return checkDailyLimit(date: today, limit: 2)
        }
    }
    
    private func checkDailyLimit(date: Date, limit: Int) -> RateLimitResult {
        let key = "ai_requests_\(date.timeIntervalSince1970)"
        let currentCount = userDefaults.integer(forKey: key)
        
        if currentCount < limit {
            userDefaults.set(currentCount + 1, forKey: key)
            return .allowed(remaining: limit - currentCount - 1)
        } else {
            let nextReset = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            return .rateLimited(resetTime: nextReset)
        }
    }
}
```

### 3. Enhanced Local Analysis Engine

```swift
@MainActor
class LocalHealthAnalyzer: ObservableObject {
    
    private let evidenceEngine = EvidenceBasedAnalysisEngine()
    private let riskAssessor = EnhancedHealthRiskAssessor()
    private let recommendationEngine = PersonalizedRecommendationEngine()
    
    func performComprehensiveLocalAnalysis(_ data: ComprehensiveHealthData) -> LocalAnalysisResult {
        
        // 1. Evidence-based health assessment
        let healthMetrics = evidenceEngine.analyzeHealthMetrics(data)
        
        // 2. Risk factor identification  
        let riskFactors = riskAssessor.identifyRiskFactors(data)
        
        // 3. Personalized recommendations
        let recommendations = recommendationEngine.generateRecommendations(
            healthMetrics: healthMetrics,
            riskFactors: riskFactors,
            userProfile: data.userProfile
        )
        
        // 4. Trend analysis
        let trends = analyzeTrends(data, historical: getHistoricalData())
        
        // 5. Generate insights
        let insights = generateInsights(
            metrics: healthMetrics,
            risks: riskFactors,
            trends: trends,
            recommendations: recommendations
        )
        
        return LocalAnalysisResult(
            insights: insights,
            recommendations: recommendations,
            riskFactors: riskFactors,
            trends: trends,
            confidenceLevel: calculateConfidence(data),
            limitationsNote: generateLimitationsNote()
        )
    }
}
```

## Backend Claude API Integration

### 1. Comprehensive Prompt Engineering

```typescript
// backend/src/services/claude-prompt-builder.ts
export class HealthAnalysisPromptBuilder {
  
  buildComprehensiveAnalysisPrompt(
    healthData: ComprehensiveHealthData,
    language: 'japanese' | 'english',
    analysisGoals: AnalysisGoal[]
  ): string {
    
    const promptSections = [
      this.buildRoleAndContext(language),
      this.buildHealthDataSection(healthData),
      this.buildUserContextSection(healthData.userProfile),
      this.buildAnalysisGoalsSection(analysisGoals),
      this.buildOutputFormatSection(language),
      this.buildCulturalContextSection(language)
    ];
    
    return promptSections.join('\n\n');
  }
  
  private buildRoleAndContext(language: string): string {
    if (language === 'japanese') {
      return `
あなたは経験豊富な健康アドバイザーです。ユーザーの包括的な健康データを分析し、
個人に合わせた具体的で実行可能なアドバイスを提供してください。

分析の際は以下の点を重視してください：
- データに基づいた客観的な評価
- 個人の生活環境や文化的背景を考慮
- 実行可能で継続しやすい改善提案
- 健康リスクの適切な評価と優先順位付け
- 前向きで励ましとなるトーン
      `;
    } else {
      return `
You are an experienced health advisor analyzing comprehensive user health data.
Provide personalized, actionable insights based on the following principles:

- Evidence-based objective assessment
- Cultural and lifestyle context consideration  
- Practical, sustainable improvement suggestions
- Appropriate risk assessment and prioritization
- Encouraging and positive communication tone
      `;
    }
  }
  
  private buildHealthDataSection(healthData: ComprehensiveHealthData): string {
    return `
# Health Data Summary

## Vital Signs
- Resting Heart Rate: ${healthData.vitalSigns.heartRate?.resting || 'N/A'} bpm
- Heart Rate Variability: ${healthData.vitalSigns.heartRateVariability?.average || 'N/A'} ms
- Blood Pressure: ${this.formatBloodPressure(healthData.vitalSigns.bloodPressure)}

## Sleep Analysis
- Duration: ${this.formatSleepDuration(healthData.sleep.totalDuration)}
- Efficiency: ${(healthData.sleep.sleepEfficiency * 100).toFixed(0)}%
- Deep Sleep: ${this.formatSleepStage(healthData.sleep.deepSleep, healthData.sleep.totalDuration)}

## Activity Metrics  
- Daily Steps: ${healthData.activity.steps}
- Active Energy: ${healthData.activity.activeEnergyBurned} kcal
- Exercise Time: ${healthData.activity.exerciseTime} minutes
- Stand Hours: ${healthData.activity.standHours}

## Body Measurements
- BMI: ${healthData.bodyMeasurements.bodyMassIndex || 'N/A'}
- Body Fat: ${healthData.bodyMeasurements.bodyFatPercentage || 'N/A'}%

## Environmental Factors
- Weather: ${healthData.environmental?.weather || 'N/A'}
- Temperature: ${healthData.environmental?.temperature || 'N/A'}°C
- Air Quality Index: ${healthData.environmental?.airQualityIndex || 'N/A'}
    `;
  }
}
```

### 2. Response Parsing & Validation

```typescript
// backend/src/services/claude-response-parser.ts
export class ClaudeResponseParser {
  
  parseHealthInsights(
    response: string,
    language: string
  ): AIHealthInsights {
    
    try {
      // Extract structured insights from Claude response
      const insights = this.extractInsights(response);
      const recommendations = this.extractRecommendations(response);
      const riskAssessment = this.extractRiskAssessment(response);
      const actionPlan = this.extractActionPlan(response);
      
      // Validate response quality
      this.validateInsightsQuality(insights, language);
      
      return {
        overallScore: this.calculateOverallScore(insights),
        keyInsights: insights,
        riskFactors: riskAssessment,
        recommendations: recommendations,
        todaysOptimalPlan: actionPlan,
        culturalNotes: this.extractCulturalNotes(response, language),
        confidenceScore: this.calculateConfidenceScore(response),
        generatedAt: new Date(),
        language: language
      };
      
    } catch (error) {
      throw new ClaudeParsingError(
        `Failed to parse Claude response: ${error.message}`,
        response
      );
    }
  }
  
  private validateInsightsQuality(insights: string[], language: string): void {
    
    // Check for generic/template responses
    const genericPatterns = this.getGenericPatterns(language);
    
    for (const insight of insights) {
      for (const pattern of genericPatterns) {
        if (pattern.test(insight)) {
          throw new GenericResponseError(
            `Generic response detected: ${insight}`,
            insight
          );
        }
      }
    }
    
    // Check minimum specificity
    if (insights.every(insight => insight.length < 20)) {
      throw new InsufficientDetailError(
        'Insights lack sufficient detail',
        insights
      );
    }
  }
}
```

## Cost Optimization Strategies

### 1. Request Batching
```swift
class AIRequestBatcher {
    private var pendingRequests: [HealthAnalysisRequest] = []
    private let batchingThreshold = 3
    
    func submitRequest(_ request: HealthAnalysisRequest) {
        if request.urgency == .critical {
            // Process immediately
            processImmediately(request)
        } else {
            // Add to batch
            pendingRequests.append(request)
            
            if pendingRequests.count >= batchingThreshold {
                processBatch()
            }
        }
    }
    
    private func processBatch() {
        let combinedRequest = combineRequests(pendingRequests)
        Task {
            let response = await aiClient.analyzeBatch(combinedRequest)
            distributeResponses(response, to: pendingRequests)
            pendingRequests.removeAll()
        }
    }
}
```

### 2. Intelligent Caching
```swift
class AIResponseCache {
    private let cacheDB = CoreDataManager.shared
    private let maxCacheAge: TimeInterval = 3600 // 1 hour
    
    func getCachedAnalysis(
        for healthData: ComprehensiveHealthData,
        type: AnalysisType
    ) -> AIHealthInsights? {
        
        let similarity = calculateDataSimilarity(healthData, withCached: getCachedData())
        
        // Use cache if data is very similar and not too old
        if similarity > 0.95 && cacheAge < maxCacheAge {
            return getCachedInsights(for: type)
        }
        
        return nil
    }
    
    private func calculateDataSimilarity(
        _ current: ComprehensiveHealthData,
        withCached cached: ComprehensiveHealthData
    ) -> Double {
        
        let vitalsSimilarity = calculateVitalsSimilarity(current.vitalSigns, cached.vitalSigns)
        let sleepSimilarity = calculateSleepSimilarity(current.sleep, cached.sleep)
        let activitySimilarity = calculateActivitySimilarity(current.activity, cached.activity)
        
        return (vitalsSimilarity + sleepSimilarity + activitySimilarity) / 3.0
    }
}
```

## Quality Metrics & Monitoring

### 1. AI Usage Metrics
```swift
struct AIUsageMetrics {
    let dailyRequests: Int
    let weeklyRequests: Int
    let costPerUser: Double
    let averageResponseTime: TimeInterval
    let userSatisfactionScore: Double
    let fallbackRate: Double
}

class AIMetricsCollector {
    func recordAIRequest(
        type: AnalysisType,
        responseTime: TimeInterval,
        cost: Double,
        userRating: Int?
    ) {
        let metrics = AIRequestMetrics(
            type: type,
            timestamp: Date(),
            responseTime: responseTime,
            cost: cost,
            userRating: userRating
        )
        
        MetricsDatabase.shared.save(metrics)
    }
    
    func generateUsageReport() -> AIUsageReport {
        let recentMetrics = MetricsDatabase.shared.getMetrics(
            from: Date().addingTimeInterval(-7 * 24 * 3600) // Last 7 days
        )
        
        return AIUsageReport(
            totalRequests: recentMetrics.count,
            averageCost: recentMetrics.map(\.cost).average,
            averageResponseTime: recentMetrics.map(\.responseTime).average,
            typeDistribution: calculateTypeDistribution(recentMetrics),
            userSatisfaction: calculateUserSatisfaction(recentMetrics)
        )
    }
}
```

### 2. Success Criteria

#### Cost Efficiency
- Average cost per user per month < $10
- AI request rate < 5 requests per user per day
- Cache hit rate > 30%

#### Quality Metrics
- User satisfaction score > 4.0/5.0
- Response relevance score > 85%
- Fallback rate < 15%

#### Performance Metrics  
- AI response time < 10 seconds
- Local analysis response time < 500ms
- System availability > 99.5%

#### User Engagement
- Daily active usage > 60%
- Feature adoption rate > 70%
- User retention at 7 days > 80%