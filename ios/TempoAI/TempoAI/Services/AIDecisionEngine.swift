import Foundation

// MARK: - AI Decision Engine

class AIDecisionEngine {

    var lastFactors: AIDecisionFactors?

    func evaluateDecisionFactors(
        healthData: ComprehensiveHealthData,
        userProfile: UserProfile,
        requestType: AnalysisRequestType
    ) async -> AIDecisionFactors {

        let dataComplexity = calculateDataComplexity(healthData)
        let userEngagement = assessUserEngagement(userProfile)
        let timeSensitivity = assessTimeSensitivity(requestType)
        let budgetAvailable = calculateAvailableBudget()
        let privacyRequirements = assessPrivacyRequirements(userProfile)
        let offlineMode = checkOfflineMode()
        let previousPreferences = userProfile.analysisPreferences
        let healthCriticalityScore = calculateHealthCriticality(healthData, userProfile)

        let factors = AIDecisionFactors(
            dataComplexity: dataComplexity,
            userEngagement: userEngagement,
            timeSensitivity: timeSensitivity,
            budgetAvailable: budgetAvailable,
            privacyRequirements: privacyRequirements,
            offlineMode: offlineMode,
            previousPreferences: previousPreferences,
            healthCriticalityScore: healthCriticalityScore
        )

        lastFactors = factors
        return factors
    }

    func makeRoutingDecision(factors: AIDecisionFactors) -> RoutingDecision {

        // Calculate AI suitability score
        let aiScore = calculateAIScore(factors)
        let localScore = calculateLocalScore(factors)

        // Decision thresholds
        let aiThreshold: Double = 0.7
        let hybridThreshold: Double = 0.4

        if factors.offlineMode || factors.budgetAvailable < 0.1 {
            // Force local analysis
            let localDecision = LocalAnalysisDecision(
                canProcessLocally: true,
                reason: factors.offlineMode ? .offlineMode : .budgetConstraints,
                confidence: localScore,
                estimatedAccuracy: 0.8,
                processingTime: 0.5,
                limitations: generateLocalLimitations(factors)
            )

            return RoutingDecision(
                route: .local,
                aiDecision: nil,
                localDecision: localDecision,
                hybridDecision: nil,
                decisionFactors: factors,
                fallbackParams: nil
            )
        } else if aiScore >= aiThreshold {
            // AI Analysis
            let aiDecision = AIAnalysisDecision(
                shouldUseAI: true,
                reason: determineAIReason(factors),
                confidence: aiScore,
                estimatedCost: estimateCost(factors),
                estimatedResponseTime: estimateResponseTime(.ai),
                fallbackToLocal: true
            )

            return RoutingDecision(
                route: .ai,
                aiDecision: aiDecision,
                localDecision: nil,
                hybridDecision: nil,
                decisionFactors: factors,
                fallbackParams: createFallbackParams(factors)
            )
        } else if aiScore >= hybridThreshold {
            // Hybrid Analysis
            let hybridDecision = HybridAnalysisDecision(
                strategy: determineHybridStrategy(factors),
                localComponents: generateLocalComponents(factors),
                aiComponents: generateAIComponents(factors),
                estimatedCombinedAccuracy: (aiScore + localScore) / 2.0,
                costBenefit: calculateCostBenefit(factors)
            )

            return RoutingDecision(
                route: .hybrid,
                aiDecision: nil,
                localDecision: nil,
                hybridDecision: hybridDecision,
                decisionFactors: factors,
                fallbackParams: createFallbackParams(factors)
            )
        } else {
            // Local Analysis
            let localDecision = LocalAnalysisDecision(
                canProcessLocally: true,
                reason: determineLocalReason(factors),
                confidence: localScore,
                estimatedAccuracy: calculateLocalAccuracy(factors),
                processingTime: 0.5,
                limitations: generateLocalLimitations(factors)
            )

            return RoutingDecision(
                route: .local,
                aiDecision: nil,
                localDecision: localDecision,
                hybridDecision: nil,
                decisionFactors: factors,
                fallbackParams: nil
            )
        }
    }

    // MARK: - Factor Calculation Methods

    private func calculateDataComplexity(_ healthData: ComprehensiveHealthData) -> AnalysisComplexity {
        var complexityScore: Int = 0

        // Count available data sources
        if healthData.vitalSigns.heartRate != nil { complexityScore += 1 }
        if healthData.vitalSigns.heartRateVariability != nil { complexityScore += 2 }
        if healthData.vitalSigns.bloodPressure != nil { complexityScore += 1 }
        if healthData.sleep.totalDuration > 0 { complexityScore += 1 }
        if healthData.activity.steps > 0 { complexityScore += 1 }
        if healthData.nutrition.calories > 0 { complexityScore += 1 }

        // Additional complexity factors
        if !healthData.sleep.sleepStages.isEmpty { complexityScore += 2 }
        if !healthData.activity.workouts.isEmpty { complexityScore += 1 }

        switch complexityScore {
        case 0 ... 2:
            return .simple
        case 3 ... 5:
            return .moderate
        case 6 ... 8:
            return .complex
        default:
            return .veryComplex
        }
    }

    private func assessUserEngagement(_ userProfile: UserProfile) -> UserEngagement {
        var engagementScore = 0

        if !userProfile.healthGoals.isEmpty { engagementScore += 1 }
        if !userProfile.exerciseFrequency.isEmpty { engagementScore += 1 }
        if userProfile.wearableDeviceConnected { engagementScore += 1 }
        if userProfile.dailyHealthCheckins { engagementScore += 1 }

        switch engagementScore {
        case 0:
            return .passive
        case 1 ... 2:
            return .active
        case 3:
            return .interactive
        default:
            return .critical
        }
    }

    private func assessTimeSensitivity(_ requestType: AnalysisRequestType) -> TimeSensitivity {
        switch requestType {
        case .quick:
            return .realTime
        case .critical:
            return .immediate
        case .daily, .userRequested:
            return .standard
        case .comprehensive, .weekly:
            return .deferred
        }
    }

    private func calculateAvailableBudget() -> Double {
        // Simplified budget calculation - would integrate with actual cost tracking
        return 0.8  // 80% of budget available
    }

    private func assessPrivacyRequirements(_ userProfile: UserProfile) -> Bool {
        return userProfile.privacyPreferences?.shareDataWithAI == false
    }

    private func checkOfflineMode() -> Bool {
        // Check network connectivity and offline mode settings
        return false  // Simplified - would check actual connectivity
    }

    private func calculateHealthCriticality(_ healthData: ComprehensiveHealthData, _ userProfile: UserProfile) -> Double
    {
        var criticalityScore = 0.0

        // Check for critical vital signs
        if let bp = healthData.vitalSigns.bloodPressure {
            if bp.systolic > 180 || bp.diastolic > 120 {
                criticalityScore += 0.4
            }
        }

        if let hr = healthData.vitalSigns.heartRate {
            if hr.resting > 100 || hr.resting < 50 {
                criticalityScore += 0.3
            }
        }

        // Check user's chronic conditions
        if !userProfile.chronicConditions.isEmpty {
            criticalityScore += 0.3
        }

        return min(criticalityScore, 1.0)
    }

    // MARK: - Decision Logic Methods

    private func calculateAIScore(_ factors: AIDecisionFactors) -> Double {
        var score: Double = 0.0

        // Data complexity factor (30% weight)
        let complexityScore = factors.dataComplexity.scoreValue
        score += complexityScore * 0.3

        // User engagement factor (20% weight)
        let engagementScore = factors.userEngagement.scoreValue
        score += engagementScore * 0.2

        // Health criticality factor (25% weight)
        score += factors.healthCriticalityScore * 0.25

        // Time sensitivity factor (15% weight) - higher score for deferred
        let timeScore = factors.timeSensitivity.scoreValue
        score += timeScore * 0.15

        // Budget availability factor (10% weight)
        score += factors.budgetAvailable * 0.1

        // Privacy requirements penalty
        if factors.privacyRequirements {
            score *= 0.5
        }

        return min(score, 1.0)
    }

    private func calculateLocalScore(_ factors: AIDecisionFactors) -> Double {
        var score: Double = 0.8  // Base local processing capability

        // Favor local for simple data
        if factors.dataComplexity == .simple || factors.dataComplexity == .moderate {
            score += 0.2
        }

        // Favor local for immediate needs
        if factors.timeSensitivity == .realTime || factors.timeSensitivity == .immediate {
            score += 0.15
        }

        // Favor local for privacy requirements
        if factors.privacyRequirements {
            score += 0.3
        }

        // Favor local for budget constraints
        if factors.budgetAvailable < 0.3 {
            score += 0.2
        }

        return min(score, 1.0)
    }

    private func determineAIReason(_ factors: AIDecisionFactors) -> AIAnalysisReason {
        if factors.healthCriticalityScore > 0.7 {
            return .criticalHealth
        } else if factors.dataComplexity == .veryComplex || factors.dataComplexity == .complex {
            return .highComplexity
        } else if factors.userEngagement == .interactive || factors.userEngagement == .critical {
            return .userPreference
        } else {
            return .comprehensiveAnalysis
        }
    }

    private func determineLocalReason(_ factors: AIDecisionFactors) -> LocalAnalysisReason {
        if factors.budgetAvailable < 0.3 {
            return .budgetConstraints
        } else if factors.timeSensitivity == .realTime || factors.timeSensitivity == .immediate {
            return .fastResponseNeeded
        } else if factors.privacyRequirements {
            return .privacyPreferred
        } else if factors.dataComplexity == .simple {
            return .simpleMetrics
        } else {
            return .basicAnalysisOnly
        }
    }

    private func determineHybridStrategy(_ factors: AIDecisionFactors) -> HybridStrategy {
        if factors.timeSensitivity == .realTime {
            return .localFirst
        } else if factors.dataComplexity == .veryComplex {
            return .aiEnhanced
        } else if factors.budgetAvailable > 0.7 {
            return .parallel
        } else {
            return .sequential
        }
    }

    private func generateLocalComponents(_ factors: AIDecisionFactors) -> [String] {
        var components = ["basic_vitals_analysis", "simple_trends"]

        if factors.dataComplexity == .simple || factors.dataComplexity == .moderate {
            components.append("guidelines_based_recommendations")
        }

        if factors.timeSensitivity == .realTime {
            components.append("immediate_alerts")
        }

        return components
    }

    private func generateAIComponents(_ factors: AIDecisionFactors) -> [String] {
        var components: [String] = []

        if factors.dataComplexity == .complex || factors.dataComplexity == .veryComplex {
            components.append("pattern_recognition")
            components.append("predictive_analysis")
        }

        if factors.userEngagement == .interactive {
            components.append("personalized_insights")
        }

        if factors.healthCriticalityScore > 0.5 {
            components.append("risk_stratification")
        }

        return components
    }

    private func generateLocalLimitations(_ factors: AIDecisionFactors) -> [String] {
        var limitations: [String] = []

        if factors.dataComplexity == .veryComplex {
            limitations.append("Complex pattern analysis not available")
        }

        if factors.userEngagement == .critical {
            limitations.append("Advanced personalization limited")
        }

        return limitations
    }

    private func estimateCost(_ factors: AIDecisionFactors) -> Double {
        let baseCost: Double = 0.05  // Base AI cost
        let complexityMultiplier = factors.dataComplexity.costMultiplier
        let criticalityMultiplier = 1.0 + (factors.healthCriticalityScore * 0.5)

        return baseCost * complexityMultiplier * criticalityMultiplier
    }

    private func estimateResponseTime(_ route: AnalysisRoute) -> TimeInterval {
        switch route {
        case .local, .fallback:
            return 0.5  // 500ms
        case .ai:
            return 8.0  // 8 seconds
        case .hybrid:
            return 4.0  // 4 seconds
        }
    }

    private func calculateLocalAccuracy(_ factors: AIDecisionFactors) -> Double {
        var accuracy = 0.8  // Base local accuracy

        if factors.dataComplexity == .simple {
            accuracy = 0.9
        } else if factors.dataComplexity == .veryComplex {
            accuracy = 0.6
        }

        return accuracy
    }

    private func calculateCostBenefit(_ factors: AIDecisionFactors) -> Double {
        let aiCost = estimateCost(factors)
        let localCost = 0.0
        let aiAccuracy = 0.95
        let localAccuracy = calculateLocalAccuracy(factors)

        let accuracyGain = aiAccuracy - localAccuracy
        let costIncrease = aiCost - localCost

        return costIncrease > 0 ? accuracyGain / costIncrease : accuracyGain
    }

    private func createFallbackParams(_ factors: AIDecisionFactors) -> LocalAnalysisFallbackParams {
        return LocalAnalysisFallbackParams(
            maxWaitTime: factors.timeSensitivity == .realTime ? 1.0 : 10.0,
            minimumAccuracyThreshold: 0.7,
            enabledComponents: generateLocalComponents(factors),
            degradedModeSettings: ["reduce_complexity": true]
        )
    }
}

// MARK: - Extensions for Score Conversion

extension AnalysisComplexity {
    var scoreValue: Double {
        switch self {
        case .simple: return 0.25
        case .moderate: return 0.5
        case .complex: return 0.75
        case .veryComplex: return 1.0
        }
    }

    var costMultiplier: Double {
        switch self {
        case .simple: return 0.5
        case .moderate: return 1.0
        case .complex: return 1.5
        case .veryComplex: return 2.0
        }
    }
}

extension UserEngagement {
    var scoreValue: Double {
        switch self {
        case .passive: return 0.25
        case .active: return 0.5
        case .interactive: return 0.75
        case .critical: return 1.0
        }
    }
}

extension TimeSensitivity {
    var scoreValue: Double {
        switch self {
        case .realTime: return 0.0  // Favor local for real-time
        case .immediate: return 0.25
        case .standard: return 0.5
        case .deferred: return 1.0  // Favor AI for deferred
        }
    }
}
