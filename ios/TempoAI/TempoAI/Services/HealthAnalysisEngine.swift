import Combine
import Foundation

/**
 * Health Analysis Engine
 *
 * Central routing and orchestration service for health analysis requests.
 * Intelligently routes requests between AI analysis and local evidence-based analysis
 * based on cost-benefit analysis, data quality, and user preferences.
 *
 * Key Features:
 * - Intelligent AI vs local analysis routing
 * - Cost optimization and rate limiting
 * - Analysis caching and performance optimization
 * - Graceful fallback handling
 * - Real-time analysis status monitoring
 */

@MainActor
class HealthAnalysisEngine: ObservableObject {

    // MARK: - Properties

    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: Double = 0.0
    @Published var currentAnalysisType: AnalysisRequestType = .quick
    @Published var lastAnalysisResult: AnalysisResult?
    @Published var analysisHistory: [AnalysisResult] = []

    // Service Dependencies
    private let localAnalyzer = LocalHealthAnalyzer()
    private let aiClient = TempoAIAPIClient.shared
    private let rateLimiter = AIRequestRateLimiter()
    private let cacheManager = AnalysisCacheManager()
    private let decisionEngine = AIDecisionEngine()

    // Analysis State
    private var cancellables = Set<AnyCancellable>()
    private let analysisQueue = DispatchQueue(label: "health.analysis", qos: .userInitiated)

    // MARK: - Public Analysis Methods

    /// Request comprehensive health analysis with intelligent routing
    /// - Parameters:
    ///   - healthData: Complete health data for analysis
    ///   - userProfile: User demographics and preferences
    ///   - requestType: Type of analysis requested
    ///   - language: Analysis language preference
    /// - Returns: Analysis result with routing information
    func requestAnalysis(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType,
        language: String = "english",
        forceLocal: Bool = false
    ) async -> AnalysisResult {

        print("📊 Starting health analysis request: \(requestType)")

        isAnalyzing = true
        currentAnalysisType = requestType
        analysisProgress = 0.1

        defer {
            isAnalyzing = false
            analysisProgress = 0.0
        }

        // 1. Check cache first
        if let cachedResult = await checkCache(
            healthData: healthData,
            userProfile: userProfile,
            requestType: requestType
        ) {
            print("📱 Returning cached analysis result")
            analysisProgress = 1.0
            return cachedResult
        }

        analysisProgress = 0.2

        // 2. Evaluate routing decision
        let routingDecision = await evaluateRoutingDecision(
            healthData: healthData,
            userProfile: userProfile,
            requestType: requestType,
            forceLocal: forceLocal
        )

        analysisProgress = 0.3

        // 3. Execute analysis based on routing decision
        let result: AnalysisResult

        switch routingDecision.route {
        case .aiAnalysis(let aiDecision):
            result = await performAIAnalysis(
                healthData: healthData,
                userProfile: userProfile,
                requestType: requestType,
                language: language,
                decision: aiDecision
            )

        case .localAnalysis(let localDecision):
            result = await performLocalAnalysis(
                healthData: healthData,
                userProfile: userProfile,
                requestType: requestType,
                language: language,
                decision: localDecision
            )

        case .hybridAnalysis(let hybridDecision):
            result = await performHybridAnalysis(
                healthData: healthData,
                userProfile: userProfile,
                requestType: requestType,
                language: language,
                decision: hybridDecision
            )
        }

        analysisProgress = 0.9

        // 4. Cache result and update state
        await cacheResult(result)
        lastAnalysisResult = result
        analysisHistory.append(result)

        // Keep history manageable
        if analysisHistory.count > 20 {
            analysisHistory.removeFirst(analysisHistory.count - 20)
        }

        analysisProgress = 1.0

        print("✅ Analysis completed using \(result.analysisMethod)")
        return result
    }

    /// Quick health assessment for immediate insights
    func quickHealthCheck(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        language: String = "english"
    ) async -> AnalysisResult {

        // Quick checks always use local analysis for speed
        let localInsights = localAnalyzer.quickHealthAssessment(
            healthData: healthData,
            userProfile: userProfile,
            language: language
        )

        return AnalysisResult(
            id: UUID(),
            analysisMethod: .local,
            requestType: .quick,
            insights: .quick(localInsights),
            routingDecision: RoutingDecision(
                route: .localAnalysis(
                    LocalAnalysisDecision(
                        reason: .speedOptimization,
                        confidence: 0.95
                    )),
                factors: AIDecisionFactors(
                    dataRichness: 0.5,
                    analysisComplexity: .low,
                    userEngagement: .medium,
                    timeSensitivity: .immediate,
                    costBudget: 1.0
                ),
                executionTime: 50  // ms
            ),
            performanceMetrics: AnalysisPerformanceMetrics(
                totalTime: 0.05,
                cacheHit: false,
                dataQuality: 0.8
            ),
            generatedAt: Date(),
            language: language
        )
    }

    /// Get analysis capabilities and current status
    func getAnalysisCapabilities() -> AnalysisCapabilities {
        let aiStatus = rateLimiter.getAIAvailabilityStatus()

        return AnalysisCapabilities(
            aiAnalysisAvailable: aiStatus.canMakeRequest,
            localAnalysisAvailable: true,
            hybridAnalysisAvailable: aiStatus.canMakeRequest,
            dailyAIRequestsRemaining: aiStatus.remainingRequests,
            nextResetTime: aiStatus.nextReset,
            analysisInProgress: isAnalyzing,
            cacheSize: cacheManager.getCacheSize()
        )
    }

    // MARK: - Cache Management

    private func checkCache(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) async -> AnalysisResult? {

        return await cacheManager.getCachedAnalysis(
            healthData: healthData,
            userProfile: userProfile,
            requestType: requestType
        )
    }

    private func cacheResult(_ result: AnalysisResult) async {
        await cacheManager.cacheAnalysis(result)
    }

    // MARK: - Routing Decision Logic

    private func evaluateRoutingDecision(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType,
        forceLocal: Bool
    ) async -> RoutingDecision {

        if forceLocal {
            return RoutingDecision(
                route: .localAnalysis(
                    LocalAnalysisDecision(
                        reason: .userPreference,
                        confidence: 1.0
                    )),
                factors: AIDecisionFactors(
                    dataRichness: 0.5,
                    analysisComplexity: .medium,
                    userEngagement: .medium,
                    timeSensitivity: .normal,
                    costBudget: 1.0
                ),
                executionTime: 0
            )
        }

        let factors = await decisionEngine.evaluateDecisionFactors(
            healthData: healthData,
            userProfile: userProfile,
            requestType: requestType
        )

        let decision = decisionEngine.makeRoutingDecision(factors: factors)

        return RoutingDecision(
            route: decision,
            factors: factors,
            executionTime: 10  // Decision time in ms
        )
    }

    // MARK: - Analysis Execution Methods

    private func performAIAnalysis(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType,
        language: String,
        decision: AIAnalysisDecision
    ) async -> AnalysisResult {

        let startTime = Date()

        do {
            // Track rate limit usage
            rateLimiter.recordAIRequest(type: requestType)

            analysisProgress = 0.5

            // Perform AI analysis
            let analysisRequest = AnalysisRequest(
                healthData: healthData,
                userProfile: userProfile,
                language: language,
                analysisGoals: requestType.analysisGoals
            )

            let aiInsights = try await aiClient.analyzeHealth(request: analysisRequest)

            analysisProgress = 0.8

            return AnalysisResult(
                id: UUID(),
                analysisMethod: .ai,
                requestType: requestType,
                insights: .comprehensive(aiInsights),
                routingDecision: RoutingDecision(
                    route: .aiAnalysis(decision),
                    factors: decisionEngine.lastFactors ?? AIDecisionFactors(),
                    executionTime: Int(Date().timeIntervalSince(startTime) * 1000)
                ),
                performanceMetrics: AnalysisPerformanceMetrics(
                    totalTime: Date().timeIntervalSince(startTime),
                    cacheHit: false,
                    dataQuality: assessDataQuality(healthData)
                ),
                generatedAt: Date(),
                language: language
            )

        } catch {
            print("❌ AI analysis failed: \(error.localizedDescription)")

            // Fallback to local analysis
            return await performLocalAnalysisFallback(LocalAnalysisFallbackParams(
                healthData: healthData,
                userProfile: userProfile,
                requestType: requestType,
                language: language,
                fallbackReason: error.localizedDescription,
                startTime: startTime
            ))
        }
    }

    private func performLocalAnalysis(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType,
        language: String,
        decision: LocalAnalysisDecision
    ) async -> AnalysisResult {

        let startTime = Date()

        analysisProgress = 0.5

        let localInsights = await localAnalyzer.analyzeComprehensiveHealth(
            healthData: healthData,
            userProfile: userProfile,
            language: language
        )

        analysisProgress = 0.8

        return AnalysisResult(
            id: UUID(),
            analysisMethod: .local,
            requestType: requestType,
            insights: .local(localInsights),
            routingDecision: RoutingDecision(
                route: .localAnalysis(decision),
                factors: decisionEngine.lastFactors ?? AIDecisionFactors(),
                executionTime: Int(Date().timeIntervalSince(startTime) * 1000)
            ),
            performanceMetrics: AnalysisPerformanceMetrics(
                totalTime: Date().timeIntervalSince(startTime),
                cacheHit: false,
                dataQuality: assessDataQuality(healthData)
            ),
            generatedAt: Date(),
            language: language
        )
    }

    private func performHybridAnalysis(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType,
        language: String,
        decision: HybridAnalysisDecision
    ) async -> AnalysisResult {

        let startTime = Date()

        // Start local analysis immediately
        analysisProgress = 0.4
        let localTask = Task {
            await localAnalyzer.analyzeComprehensiveHealth(
                healthData: healthData,
                userProfile: userProfile,
                language: language
            )
        }

        // Attempt AI analysis in parallel
        analysisProgress = 0.5
        let aiTask = Task {
            do {
                rateLimiter.recordAIRequest(type: requestType)
                let request = AnalysisRequest(
                    healthData: healthData,
                    userProfile: userProfile,
                    language: language,
                    analysisGoals: requestType.analysisGoals
                )
                return try await aiClient.analyzeHealth(request: request)
            } catch {
                return nil
            }
        }

        analysisProgress = 0.7

        // Wait for both analyses
        let localInsights = await localTask.value
        let aiInsights = await aiTask.value

        analysisProgress = 0.9

        // Combine results based on strategy
        let combinedInsights = combineInsights(
            local: localInsights,
            ai: aiInsights,
            strategy: decision.strategy
        )

        return AnalysisResult(
            id: UUID(),
            analysisMethod: .hybrid,
            requestType: requestType,
            insights: .hybrid(combinedInsights),
            routingDecision: RoutingDecision(
                route: .hybridAnalysis(decision),
                factors: decisionEngine.lastFactors ?? AIDecisionFactors(),
                executionTime: Int(Date().timeIntervalSince(startTime) * 1000)
            ),
            performanceMetrics: AnalysisPerformanceMetrics(
                totalTime: Date().timeIntervalSince(startTime),
                cacheHit: false,
                dataQuality: assessDataQuality(healthData)
            ),
            generatedAt: Date(),
            language: language
        )
    }

    private func performLocalAnalysisFallback(_ params: LocalAnalysisFallbackParams) async -> AnalysisResult {

        print("🔄 Falling back to local analysis due to: \(params.fallbackReason)")

        let localInsights = await localAnalyzer.analyzeComprehensiveHealth(
            healthData: params.healthData,
            userProfile: params.userProfile,
            language: params.language
        )

        return AnalysisResult(
            id: UUID(),
            analysisMethod: .localFallback,
            requestType: params.requestType,
            insights: .local(localInsights),
            routingDecision: RoutingDecision(
                route: .localAnalysis(
                    LocalAnalysisDecision(
                        reason: .aiFallback,
                        confidence: 0.8
                    )),
                factors: decisionEngine.lastFactors ?? AIDecisionFactors(),
                executionTime: Int(Date().timeIntervalSince(params.startTime) * 1000)
            ),
            performanceMetrics: AnalysisPerformanceMetrics(
                totalTime: Date().timeIntervalSince(params.startTime),
                cacheHit: false,
                dataQuality: assessDataQuality(params.healthData),
                fallbackReason: params.fallbackReason
            ),
            generatedAt: Date(),
            language: params.language
        )
    }

    // MARK: - Helper Methods

    private func assessDataQuality(_ healthData: ComprehensiveHealthData) -> Double {
        // Simple data quality assessment
        var score: Double = 0

        // Check vital signs
        if healthData.vitalSigns.heartRate != nil { score += 0.25 }
        if healthData.vitalSigns.heartRateVariability != nil { score += 0.15 }
        if healthData.vitalSigns.bloodPressure != nil { score += 0.1 }

        // Check activity data
        if healthData.activity.steps > 0 { score += 0.25 }
        if healthData.activity.exerciseTime > 0 { score += 0.15 }

        // Check sleep data
        if healthData.sleep.totalDuration > 0 { score += 0.1 }

        return score
    }

    private func combineInsights(
        local: LocalHealthInsights,
        ai: AIHealthInsights?,
        strategy: HybridStrategy
    ) -> HybridHealthInsights {

        switch strategy {
        case .aiFallbackLocal:
            if let ai = ai {
                return HybridHealthInsights(
                    primary: .ai(ai),
                    secondary: .local(local),
                    strategy: strategy
                )
            } else {
                return HybridHealthInsights(
                    primary: .local(local),
                    secondary: nil,
                    strategy: strategy
                )
            }

        case .localFallbackAI:
            return HybridHealthInsights(
                primary: .local(local),
                secondary: ai.map { .ai($0) },
                strategy: strategy
            )

        case .bestOfBoth:
            return HybridHealthInsights(
                primary: .local(local),
                secondary: ai.map { .ai($0) },
                strategy: strategy
            )
        }
    }
}

// MARK: - Supporting Types

/// Analysis request types with different complexity levels
enum AnalysisRequestType: String, CaseIterable {
    case quick = "quick"
    case daily = "daily"
    case comprehensive = "comprehensive"
    case weekly = "weekly"
    case critical = "critical"
    case userRequested = "user_requested"

    var analysisGoals: [String] {
        switch self {
        case .quick:
            return ["immediate_insights", "quick_recommendations"]
        case .daily:
            return ["daily_optimization", "progress_tracking", "immediate_actions"]
        case .comprehensive:
            return ["detailed_analysis", "risk_assessment", "long_term_planning"]
        case .weekly:
            return ["trend_analysis", "progress_review", "goal_adjustment"]
        case .critical:
            return ["immediate_risk_assessment", "urgent_recommendations", "medical_guidance"]
        case .userRequested:
            return ["personalized_insights", "specific_concerns", "detailed_explanations"]
        }
    }

    var complexity: AnalysisComplexity {
        switch self {
        case .quick:
            return .low
        case .daily, .weekly:
            return .medium
        case .comprehensive, .critical, .userRequested:
            return .high
        }
    }
}

/// Analysis routing options
enum AnalysisRoute {
    case aiAnalysis(AIAnalysisDecision)
    case localAnalysis(LocalAnalysisDecision)
    case hybridAnalysis(HybridAnalysisDecision)
}

/// AI analysis decision with reasoning
struct AIAnalysisDecision {
    let reason: AIAnalysisReason
    let confidence: Double
    let estimatedCost: Double
    let expectedResponseTime: TimeInterval
}

enum AIAnalysisReason: String {
    case dataRichness = "data_richness"
    case complexAnalysis = "complex_analysis"
    case userPreference = "user_preference"
    case dailyAllowance = "daily_allowance"
    case criticalHealth = "critical_health"
}

/// Local analysis decision with reasoning
struct LocalAnalysisDecision {
    let reason: LocalAnalysisReason
    let confidence: Double
}

enum LocalAnalysisReason: String {
    case costOptimization = "cost_optimization"
    case speedOptimization = "speed_optimization"
    case rateLimitReached = "rate_limit_reached"
    case userPreference = "user_preference"
    case aiFallback = "ai_fallback"
    case dataInsufficient = "data_insufficient"
}

/// Hybrid analysis decision with strategy
struct HybridAnalysisDecision {
    let strategy: HybridStrategy
    let confidence: Double
}

enum HybridStrategy: String {
    case aiFallbackLocal = "ai_fallback_local"
    case localFallbackAI = "local_fallback_ai"
    case bestOfBoth = "best_of_both"
}

/// Routing decision with factors and timing
struct RoutingDecision {
    let route: AnalysisRoute
    let factors: AIDecisionFactors
    let executionTime: Int  // milliseconds
}

/// AI decision factors for routing logic
struct AIDecisionFactors {
    let dataRichness: Double
    let analysisComplexity: AnalysisComplexity
    let userEngagement: UserEngagement
    let timeSensitivity: TimeSensitivity
    let costBudget: Double

    init(
        dataRichness: Double = 0.5,
        analysisComplexity: AnalysisComplexity = .medium,
        userEngagement: UserEngagement = .medium,
        timeSensitivity: TimeSensitivity = .normal,
        costBudget: Double = 1.0
    ) {
        self.dataRichness = dataRichness
        self.analysisComplexity = analysisComplexity
        self.userEngagement = userEngagement
        self.timeSensitivity = timeSensitivity
        self.costBudget = costBudget
    }
}

/// Parameters for local analysis fallback
struct LocalAnalysisFallbackParams {
    let healthData: ComprehensiveHealthData
    let userProfile: UserProfile
    let requestType: AnalysisRequestType
    let language: String
    let fallbackReason: String
    let startTime: Date
}

enum AnalysisComplexity: String {
    case low
    case medium
    case high
}

enum UserEngagement: String {
    case low
    case medium
    case high
}

enum TimeSensitivity: String {
    case immediate
    case normal
    case deferred
}

/// Analysis result container
struct AnalysisResult: Identifiable {
    let id: UUID
    let analysisMethod: AnalysisMethod
    let requestType: AnalysisRequestType
    let insights: AnalysisInsights
    let routingDecision: RoutingDecision
    let performanceMetrics: AnalysisPerformanceMetrics
    let generatedAt: Date
    let language: String
}

enum AnalysisMethod: String {
    case ai = "ai"
    case local = "local"
    case hybrid = "hybrid"
    case localFallback = "local_fallback"
}

/// Analysis insights union type
enum AnalysisInsights {
    case quick(QuickHealthInsights)
    case local(LocalHealthInsights)
    case comprehensive(AIHealthInsights)
    case hybrid(HybridHealthInsights)
}

/// Hybrid analysis insights
struct HybridHealthInsights {
    let primary: InsightSource
    let secondary: InsightSource?
    let strategy: HybridStrategy

    enum InsightSource {
        case ai(AIHealthInsights)
        case local(LocalHealthInsights)
    }
}

/// Performance metrics for analysis
struct AnalysisPerformanceMetrics {
    let totalTime: TimeInterval
    let cacheHit: Bool
    let dataQuality: Double
    let fallbackReason: String?

    init(totalTime: TimeInterval, cacheHit: Bool, dataQuality: Double, fallbackReason: String? = nil) {
        self.totalTime = totalTime
        self.cacheHit = cacheHit
        self.dataQuality = dataQuality
        self.fallbackReason = fallbackReason
    }
}

/// Analysis capabilities status
struct AnalysisCapabilities {
    let aiAnalysisAvailable: Bool
    let localAnalysisAvailable: Bool
    let hybridAnalysisAvailable: Bool
    let dailyAIRequestsRemaining: Int
    let nextResetTime: Date?
    let analysisInProgress: Bool
    let cacheSize: Int
}

// MARK: - AI Decision Engine

class AIDecisionEngine {

    var lastFactors: AIDecisionFactors?

    func evaluateDecisionFactors(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) async -> AIDecisionFactors {

        let dataRichness = calculateDataRichness(healthData)
        let analysisComplexity = requestType.complexity
        let userEngagement = assessUserEngagement(userProfile)
        let timeSensitivity = assessTimeSensitivity(requestType)
        let costBudget = calculateAvailableBudget()

        let factors = AIDecisionFactors(
            dataRichness: dataRichness,
            analysisComplexity: analysisComplexity,
            userEngagement: userEngagement,
            timeSensitivity: timeSensitivity,
            costBudget: costBudget
        )

        lastFactors = factors
        return factors
    }

    func makeRoutingDecision(factors: AIDecisionFactors) -> AnalysisRoute {

        // Calculate AI score based on multiple factors
        let aiScore = calculateAIScore(factors)

        // Decision thresholds
        let aiThreshold: Double = 0.7
        let hybridThreshold: Double = 0.4

        if aiScore >= aiThreshold {
            return .aiAnalysis(
                AIAnalysisDecision(
                    reason: determineAIReason(factors),
                    confidence: aiScore,
                    estimatedCost: estimateCost(factors),
                    expectedResponseTime: estimateResponseTime(.ai)
                ))
        } else if aiScore >= hybridThreshold {
            return .hybridAnalysis(
                HybridAnalysisDecision(
                    strategy: determineHybridStrategy(factors),
                    confidence: aiScore
                ))
        } else {
            return .localAnalysis(
                LocalAnalysisDecision(
                    reason: determineLocalReason(factors),
                    confidence: 1.0 - aiScore
                ))
        }
    }

    // MARK: - Factor Calculation Methods

    private func calculateDataRichness(_ healthData: ComprehensiveHealthData) -> Double {
        var richness: Double = 0.0

        // Vital signs richness
        if healthData.vitalSigns.heartRate != nil { richness += 0.2 }
        if healthData.vitalSigns.heartRateVariability != nil { richness += 0.15 }
        if healthData.vitalSigns.bloodPressure != nil { richness += 0.1 }
        if healthData.vitalSigns.oxygenSaturation > 0 { richness += 0.05 }

        // Activity richness
        if healthData.activity.steps > 0 { richness += 0.15 }
        if healthData.activity.exerciseTime > 0 { richness += 0.1 }
        if healthData.activity.activeEnergyBurned > 0 { richness += 0.1 }

        // Sleep richness
        if healthData.sleep.totalDuration > 0 { richness += 0.1 }
        if healthData.sleep.sleepEfficiency > 0 { richness += 0.05 }

        return min(richness, 1.0)
    }

    private func assessUserEngagement(_ userProfile: UserProfile) -> UserEngagement {
        // Simple engagement assessment based on profile completeness
        var engagementScore = 0

        if !userProfile.goals.isEmpty { engagementScore += 1 }
        if !userProfile.dietaryPreferences.isEmpty { engagementScore += 1 }
        if userProfile.exerciseFrequency != "never" { engagementScore += 1 }

        switch engagementScore {
        case 0 ... 1:
            return .low
        case 2:
            return .medium
        default:
            return .high
        }
    }

    private func assessTimeSensitivity(_ requestType: AnalysisRequestType) -> TimeSensitivity {
        switch requestType {
        case .quick:
            return .immediate
        case .critical:
            return .immediate
        case .daily, .userRequested:
            return .normal
        case .comprehensive, .weekly:
            return .deferred
        }
    }

    private func calculateAvailableBudget() -> Double {
        // Simplified budget calculation - would integrate with actual cost tracking
        return 0.8  // 80% of budget available
    }

    // MARK: - Decision Logic Methods

    private func calculateAIScore(_ factors: AIDecisionFactors) -> Double {
        var score: Double = 0.0

        // Data richness factor (30% weight)
        score += factors.dataRichness * 0.3

        // Complexity factor (25% weight)
        let complexityScore =
            factors.analysisComplexity == .high ? 1.0 : factors.analysisComplexity == .medium ? 0.6 : 0.2
        score += complexityScore * 0.25

        // User engagement factor (20% weight)
        let engagementScore = factors.userEngagement == .high ? 1.0 : factors.userEngagement == .medium ? 0.6 : 0.3
        score += engagementScore * 0.2

        // Time sensitivity factor (15% weight) - higher for deferred
        let timeScore = factors.timeSensitivity == .deferred ? 1.0 : factors.timeSensitivity == .normal ? 0.6 : 0.2
        score += timeScore * 0.15

        // Cost budget factor (10% weight)
        score += factors.costBudget * 0.1

        return min(score, 1.0)
    }

    private func determineAIReason(_ factors: AIDecisionFactors) -> AIAnalysisReason {
        if factors.dataRichness >= 0.8 {
            return .dataRichness
        } else if factors.analysisComplexity == .high {
            return .complexAnalysis
        } else if factors.userEngagement == .high {
            return .userPreference
        } else {
            return .dailyAllowance
        }
    }

    private func determineLocalReason(_ factors: AIDecisionFactors) -> LocalAnalysisReason {
        if factors.costBudget < 0.3 {
            return .costOptimization
        } else if factors.timeSensitivity == .immediate {
            return .speedOptimization
        } else if factors.dataRichness < 0.4 {
            return .dataInsufficient
        } else {
            return .costOptimization
        }
    }

    private func determineHybridStrategy(_ factors: AIDecisionFactors) -> HybridStrategy {
        if factors.dataRichness >= 0.6 {
            return .aiFallbackLocal
        } else if factors.timeSensitivity == .immediate {
            return .localFallbackAI
        } else {
            return .bestOfBoth
        }
    }

    private func estimateCost(_ factors: AIDecisionFactors) -> Double {
        let baselineLocalCost: Double = 0.0
        let baseCost: Double = 0.05  // Base AI cost
        let complexityMultiplier =
            factors.analysisComplexity == .high ? 1.5 : factors.analysisComplexity == .medium ? 1.2 : 1.0

        return baseCost * complexityMultiplier
    }

    private func estimateResponseTime(_ method: AnalysisMethod) -> TimeInterval {
        switch method {
        case .local, .localFallback:
            return 0.5  // 500ms
        case .ai:
            return 8.0  // 8 seconds
        case .hybrid:
            return 4.0  // 4 seconds
        }
    }
}

// MARK: - Analysis Cache Manager

actor AnalysisCacheManager {

    private var cache: [String: CachedAnalysis] = [:]
    private let maxCacheSize = 50
    private let cacheExpiryTime: TimeInterval = 3600  // 1 hour

    func getCachedAnalysis(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) -> AnalysisResult? {

        let key = generateCacheKey(
            healthData: healthData,
            userProfile: userProfile,
            requestType: requestType
        )

        guard let cached = cache[key] else { return nil }

        // Check if cache is still valid
        let age = Date().timeIntervalSince(cached.createdAt)
        if age > cacheExpiryTime {
            cache.removeValue(forKey: key)
            return nil
        }

        // Check data similarity
        if calculateDataSimilarity(healthData, cached.healthData) < 0.9 {
            return nil
        }

        return cached.result
    }

    func cacheAnalysis(_ result: AnalysisResult) {
        guard case .comprehensive(let insights) = result.insights else { return }

        let key = generateCacheKey(
            healthData: ComprehensiveHealthData(),  // Would extract from result
            userProfile: UserProfile(
                age: 30, gender: "unknown", goals: [], dietaryPreferences: "", exerciseHabits: "",
                exerciseFrequency: "never"),  // Would extract from result
            requestType: result.requestType
        )

        let cached = CachedAnalysis(
            result: result,
            healthData: ComprehensiveHealthData(),  // Would store the input data
            createdAt: Date()
        )

        cache[key] = cached

        // Clean up old entries if cache is too large
        if cache.count > maxCacheSize {
            cleanupOldEntries()
        }
    }

    func getCacheSize() -> Int {
        return cache.count
    }

    func clearCache() {
        cache.removeAll()
    }

    // MARK: - Private Methods

    private func generateCacheKey(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) -> String {

        let dataHash = "\(healthData.timestamp.timeIntervalSince1970)"
        let profileHash = "\(userProfile.age)-\(userProfile.gender)-\(userProfile.exerciseFrequency)"

        return "\(requestType.rawValue)-\(dataHash)-\(profileHash)"
    }

    private func calculateDataSimilarity(
        _ current: ComprehensiveHealthData,
        _ cached: ComprehensiveHealthData
    ) -> Double {

        // Simplified similarity calculation
        let timeDiff = abs(current.timestamp.timeIntervalSince(cached.timestamp))

        if timeDiff < 3600 {  // Less than 1 hour
            return 0.95
        } else if timeDiff < 86400 {  // Less than 1 day
            return 0.8
        } else {
            return 0.5
        }
    }

    private func cleanupOldEntries() {
        let cutoffDate = Date().addingTimeInterval(-cacheExpiryTime)

        cache = cache.filter { _, cached in
            cached.createdAt > cutoffDate
        }

        // If still too large, remove oldest entries
        if cache.count > maxCacheSize {
            let sortedEntries = cache.sorted { $0.value.createdAt > $1.value.createdAt }
            cache = Dictionary(uniqueKeysWithValues: Array(sortedEntries.prefix(maxCacheSize)))
        }
    }
}

struct CachedAnalysis {
    let result: AnalysisResult
    let healthData: ComprehensiveHealthData
    let createdAt: Date
}
