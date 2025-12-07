# Mock Data Elimination Strategy - Phase 2

**Objective**: Complete removal of all mock/fixed data from TempoAI iOS application
**Target**: Real HealthKit data only, with intelligent fallback logic

## Current Mock Data Inventory

### 1. HealthKitManager.swift

#### Location: Lines 450-550
```swift
private func createEnhancedMockData() -> ComprehensiveHealthData {
    return ComprehensiveHealthData(
        vitalSigns: VitalSignsData(
            heartRate: HeartRateMetrics(
                current: 75,        // 固定値
                resting: 62,        // 固定値
                maximum: 185,       // 固定値
                // ... more fixed values
            )
        )
    )
}
```

**Elimination Strategy**:
- Remove `createEnhancedMockData()` method entirely
- Implement `validateRealHealthData()` method
- Add graceful handling for insufficient data
- Require minimum HealthKit permissions for core functionality

### 2. AIAnalysisService.swift

#### Location: Lines 280-420
```swift
private func generateJapaneseInsights(healthScore: Double, healthData: ComprehensiveHealthData) -> [String] {
    if healthScore >= 80 {
        insights.append("健康状態は非常に良好です")           // 固定文言
        insights.append("現在の健康習慣を継続することをおすすめします") // 固定文言
    }
    // ... more template text
}
```

**Elimination Strategy**:
- Replace with `LocalHealthAnalyzer` integration
- Implement data-driven insight generation
- Use evidence-based health assessment
- Maintain localization without fixed templates

### 3. TempoAIAPIClient.swift

#### Location: Lines 220-420
```swift
private func createFallbackInsights(from request: AnalysisRequest) -> AIHealthInsights {
    let insights: [String]
    if language == "japanese" || language == "ja" {
        insights = generateJapaneseInsights(healthScore: healthScore, healthData: healthData)
        // ... fixed template generation
    }
}
```

**Elimination Strategy**:
- Remove all fallback content generation
- Integrate with `LocalHealthAnalyzer` for real analysis
- Implement proper error handling without mock responses
- Add retry logic with exponential backoff

### 4. HealthMetricConstants.swift

#### Location: Lines 20-80
```swift
enum MetricValueConstants {
    static let hrvMultiplier: Double = 50.0        // 固定値
    static let sleepMultiplier: Double = 10.0      // 固定値  
    static let activityMultiplier: Double = 10000.0 // 固定値
    
    // Age-based heart rate zones (固定計算式)
    static func maxHeartRate(age: Int) -> Double {
        return 220.0 - Double(age)  // 固定計算
    }
}
```

**Elimination Strategy**:
- Replace with evidence-based medical formulas
- Add personalization based on user characteristics
- Implement dynamic threshold calculation
- Source from current medical guidelines

### 5. HealthRiskAssessor.swift

#### Location: Lines 40-390
```swift
risks.append(HealthRiskFactor(
    category: .cardiovascular,
    description: "安静時心拍数が高めです（\(Int(restingHR))bpm）",  // 固定テンプレート
    severity: restingHR > 120 ? .high : .moderate,
    recommendations: [
        "有酸素運動の継続実施",    // 固定推奨事項
        "ストレス管理の改善",      // 固定推奨事項
        "十分な睡眠の確保"        // 固定推奨事項
    ]
))
```

**Elimination Strategy**:
- Implement dynamic risk assessment
- Personalized recommendation generation
- Context-aware severity calculation
- Evidence-based intervention suggestions

### 6. AlertManager.swift

#### Location: Lines 40-365
```swift
alerts.append(HealthAlert(
    type: .dataAnomaly,
    title: "血圧注意",                           // 固定タイトル
    description: "血圧が高めです...",            // 固定説明
    recommendations: [
        "塩分摂取を控える",                      // 固定推奨事項
        "定期的な運動を心がける",                // 固定推奨事項
    ]
))
```

**Elimination Strategy**:
- Data-driven alert generation
- Personalized alert messaging
- Context-sensitive recommendations
- Dynamic severity assessment

## Implementation Plan

### Phase 1: Core Data Validation (Day 1)

#### 1.1 HealthKit Data Validation
```swift
// New implementation in HealthKitManager.swift
func validateHealthDataAvailability() async -> HealthDataAvailabilityStatus {
    let requiredTypes: [HKQuantityTypeIdentifier] = [
        .heartRate, .stepCount, .activeEnergyBurned, 
        .distanceWalkingRunning, .bloodPressureSystolic
    ]
    
    var availableTypes: [HKQuantityTypeIdentifier] = []
    var missingTypes: [HKQuantityTypeIdentifier] = []
    
    for type in requiredTypes {
        let authStatus = healthStore.authorizationStatus(for: HKQuantityType(type))
        if authStatus == .sharingAuthorized {
            let hasData = await checkDataAvailability(for: type)
            if hasData {
                availableTypes.append(type)
            } else {
                missingTypes.append(type)
            }
        } else {
            missingTypes.append(type)
        }
    }
    
    return HealthDataAvailabilityStatus(
        available: availableTypes,
        missing: missingTypes,
        sufficiencyScore: Double(availableTypes.count) / Double(requiredTypes.count)
    )
}
```

#### 1.2 Graceful Degradation Logic
```swift
func generateHealthAnalysis(from healthData: ComprehensiveHealthData) -> HealthAnalysis {
    let availability = validateDataCompleteness(healthData)
    
    switch availability.level {
    case .comprehensive:
        return generateFullAnalysis(healthData)
    case .partial:
        return generatePartialAnalysis(healthData, limitations: availability.limitations)
    case .minimal:
        return generateMinimalAnalysis(healthData, guidance: availability.guidance)
    case .insufficient:
        return generateInsufficientDataResponse(missingTypes: availability.missingTypes)
    }
}
```

### Phase 2: Local Intelligence Engine (Day 2-3)

#### 2.1 Create LocalHealthAnalyzer.swift
```swift
@MainActor
class LocalHealthAnalyzer: ObservableObject {
    
    // Evidence-based health analysis without AI
    func analyzeHealthData(_ data: ComprehensiveHealthData) -> LocalHealthInsights {
        var insights: [HealthInsight] = []
        
        // Cardiovascular health analysis
        insights.append(contentsOf: analyzeCardiovascularHealth(data.vitalSigns))
        
        // Sleep quality analysis
        insights.append(contentsOf: analyzeSleepQuality(data.sleep))
        
        // Activity analysis
        insights.append(contentsOf: analyzeActivityPatterns(data.activity))
        
        // Risk factor identification
        let riskFactors = identifyRiskFactors(data)
        
        // Personalized recommendations
        let recommendations = generatePersonalizedRecommendations(
            insights: insights, 
            riskFactors: riskFactors,
            userProfile: data.userProfile
        )
        
        return LocalHealthInsights(
            insights: insights,
            riskFactors: riskFactors,
            recommendations: recommendations,
            confidenceScore: calculateConfidenceScore(data),
            dataQuality: assessDataQuality(data)
        )
    }
    
    private func analyzeCardiovascularHealth(_ vitals: VitalSignsData) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        if let heartRate = vitals.heartRate {
            // Age-adjusted analysis
            let ageAdjustedThresholds = calculateAgeAdjustedThresholds(
                age: userProfile.age,
                fitnessLevel: userProfile.estimatedFitnessLevel
            )
            
            if let resting = heartRate.resting {
                let insight = analyzeRestingHeartRate(
                    resting, 
                    thresholds: ageAdjustedThresholds.restingHR
                )
                insights.append(insight)
            }
        }
        
        return insights
    }
}
```

#### 2.2 Create HealthAnalysisEngine.swift
```swift
@MainActor
class HealthAnalysisEngine: ObservableObject {
    
    private let localAnalyzer = LocalHealthAnalyzer()
    private let aiClient = TempoAIAPIClient.shared
    private let cacheManager = AnalysisCacheManager()
    
    func requestHealthAnalysis(_ request: AnalysisRequest) async -> HealthAnalysisResult {
        
        // 1. Check cache first
        if let cachedResult = cacheManager.getCachedAnalysis(for: request) {
            return cachedResult
        }
        
        // 2. Determine analysis approach
        let shouldUseAI = evaluateAIAnalysisValue(for: request)
        
        if shouldUseAI {
            // AI Analysis Path
            do {
                let aiInsights = try await aiClient.analyzeHealth(request: request)
                let result = HealthAnalysisResult.ai(aiInsights)
                cacheManager.cacheAnalysis(result, for: request)
                return result
            } catch {
                // Fallback to local analysis on AI failure
                let localInsights = await localAnalyzer.analyzeHealthData(request.healthData)
                return HealthAnalysisResult.local(localInsights, aiFailureReason: error.localizedDescription)
            }
        } else {
            // Local Analysis Path
            let localInsights = await localAnalyzer.analyzeHealthData(request.healthData)
            return HealthAnalysisResult.local(localInsights)
        }
    }
    
    private func evaluateAIAnalysisValue(for request: AnalysisRequest) -> Bool {
        let factors = AIValueFactors(
            dataRichness: assessDataRichness(request.healthData),
            analysisComplexity: request.analysisType.complexity,
            userEngagement: request.userContext.engagementLevel,
            timeSensitivity: request.timing.urgency,
            costBudget: getCurrentCostBudget()
        )
        
        return AIDecisionEngine.shouldUseAI(factors)
    }
}
```

### Phase 3: Backend Integration (Day 4)

#### 3.1 Enhanced Backend Claude Integration
```typescript
// backend/src/services/claude-analysis.ts
export class ClaudeAnalysisService {
  
  async analyzeComprehensiveHealth(request: AnalysisRequest): Promise<AIHealthInsights> {
    
    // Validate real health data
    this.validateHealthDataIntegrity(request.healthData)
    
    // Generate comprehensive prompt
    const prompt = this.generateComprehensivePrompt(
      request.healthData,
      request.language,
      request.userContext
    )
    
    // Call Claude API with robust error handling
    const response = await this.callClaudeAPI(prompt, {
      retries: 3,
      timeout: 30000,
      rateLimit: this.getRateLimit(request.userId)
    })
    
    // Parse and validate response
    const insights = this.parseAIResponse(response, request.language)
    
    // Log for monitoring
    this.logAnalysisMetrics(request, insights, response.usage)
    
    return insights
  }
  
  private generateComprehensivePrompt(
    healthData: ComprehensiveHealthData,
    language: string,
    context: UserContext
  ): string {
    const promptBuilder = new HealthPromptBuilder(language)
    
    return promptBuilder
      .addHealthDataContext(healthData)
      .addUserContext(context)
      .addAnalysisGoals(['insights', 'risks', 'recommendations'])
      .addCulturalContext(this.getCulturalContext(language))
      .build()
  }
}
```

### Phase 4: Quality Validation (Day 5)

#### 4.1 Test Coverage
- Unit tests for all new analysis components
- Integration tests for real HealthKit data flow
- End-to-end tests with various data scenarios
- Performance tests under different data loads

#### 4.2 Data Quality Assurance
```swift
func validateRealDataOnly() -> ValidationResult {
    var violations: [MockDataViolation] = []
    
    // Check for mock data patterns
    violations.append(contentsOf: scanForFixedValues())
    violations.append(contentsOf: scanForTemplateText())
    violations.append(contentsOf: scanForHardcodedThresholds())
    
    return ValidationResult(
        isValid: violations.isEmpty,
        violations: violations
    )
}
```

## Success Criteria

### Technical Validation
- [ ] Zero mock data usage in production builds
- [ ] All health insights based on real user data
- [ ] Graceful handling of incomplete data scenarios
- [ ] Comprehensive test coverage > 90%

### User Experience Validation
- [ ] Clear messaging when data insufficient
- [ ] Meaningful insights with partial data
- [ ] No generic/template responses
- [ ] Localization works with real analysis

### Performance Validation
- [ ] Local analysis < 50ms response time
- [ ] AI analysis routing works intelligently
- [ ] Memory usage remains stable with real data
- [ ] HealthKit queries optimized for performance

## Risk Mitigation

### Data Availability Risks
- **Risk**: Users have insufficient HealthKit data
- **Mitigation**: Progressive disclosure onboarding, clear value communication

### Analysis Quality Risks
- **Risk**: Local analysis less sophisticated than AI
- **Mitigation**: Evidence-based algorithms, medical literature sourcing

### Performance Risks
- **Risk**: Real HealthKit queries slower than mock data
- **Mitigation**: Caching strategies, background processing, query optimization

### User Experience Risks
- **Risk**: Users frustrated by data permission requirements
- **Mitigation**: Clear explanations, optional features, graceful degradation