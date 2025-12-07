import Foundation

// MARK: - AI Usage Analyzer

class AIUsageAnalyzer {

    func analyzeUsagePatterns(_ records: [AIRequestRecord]) -> UsagePatternAnalysis {
        let peakHours = analyzePeakUsageHours(records)
        let averageRequestsPerHour = calculateAverageRequestsPerHour(records)
        let mostUsedRequestType = findMostUsedRequestType(records)
        let costTrend = analyzeCostTrend(records)
        let efficiency = calculateUsageEfficiency(records)
        let recommendations = generateOptimizationRecommendations(records)

        return UsagePatternAnalysis(
            peakHours: peakHours,
            averageRequestsPerHour: averageRequestsPerHour,
            mostUsedRequestType: mostUsedRequestType,
            costTrend: costTrend,
            efficiency: efficiency,
            recommendations: recommendations
        )
    }

    func generateUsageAnalytics(_ records: [AIRequestRecord], period: StatisticsPeriod) -> UsageAnalytics {
        let currentUsage = generateCurrentUsageStatistics(records, period: period)
        let historicalTrends = generateHistoricalTrends(records)
        let predictions = generateUsagePredictions(records)
        let recommendations = generateUsageRecommendations(records)
        let anomalies = detectUsageAnomalies(records)

        return UsageAnalytics(
            currentUsage: currentUsage,
            historicalTrends: historicalTrends,
            predictions: predictions,
            recommendations: recommendations,
            anomalies: anomalies
        )
    }

    private func analyzePeakUsageHours(_ records: [AIRequestRecord]) -> [Int] {
        var hourCounts: [Int: Int] = [:]

        for record in records {
            let hour = Calendar.current.component(.hour, from: record.timestamp)
            hourCounts[hour, default: 0] += 1
        }

        let sortedHours = hourCounts.sorted { $0.value > $1.value }
        return Array(sortedHours.prefix(3).map { $0.key })
    }

    private func calculateAverageRequestsPerHour(_ records: [AIRequestRecord]) -> Double {
        guard !records.isEmpty else { return 0.0 }

        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        guard let firstRecord = sortedRecords.first,
            let lastRecord = sortedRecords.last
        else { return 0.0 }

        let timeSpan = lastRecord.timestamp.timeIntervalSince(firstRecord.timestamp)
        let hours = timeSpan / 3600

        return hours > 0 ? Double(records.count) / hours : 0.0
    }

    private func findMostUsedRequestType(_ records: [AIRequestRecord]) -> AnalysisRequestType {
        var typeCounts: [AnalysisRequestType: Int] = [:]

        for record in records {
            typeCounts[record.requestType, default: 0] += 1
        }

        return typeCounts.max { $0.value < $1.value }?.key ?? .quick
    }

    private func analyzeCostTrend(_ records: [AIRequestRecord]) -> CostTrend {
        guard records.count >= 10 else { return .stable }

        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        let midPoint = sortedRecords.count / 2

        let firstHalfAvgCost = sortedRecords.prefix(midPoint).map { $0.estimatedCost }.reduce(0, +) / Double(midPoint)
        let secondHalfAvgCost = sortedRecords.suffix(midPoint).map { $0.estimatedCost }.reduce(0, +) / Double(midPoint)

        let change = (secondHalfAvgCost - firstHalfAvgCost) / firstHalfAvgCost

        if change > 0.2 {
            return .increasing
        } else if change < -0.2 {
            return .decreasing
        } else if abs(change) > 0.5 {
            return .volatile
        } else {
            return .stable
        }
    }

    private func calculateUsageEfficiency(_ records: [AIRequestRecord]) -> UsageEfficiency {
        guard !records.isEmpty else {
            return UsageEfficiency(
                successRate: 0.0,
                averageResponseTime: 0.0,
                costPerSuccessfulRequest: 0.0,
                optimalUsageScore: 0.0
            )
        }

        let successfulRequests = records.filter { $0.success }
        let successRate = Double(successfulRequests.count) / Double(records.count)

        let averageResponseTime = records.map { $0.responseTime }.reduce(0, +) / Double(records.count)

        let totalCost = successfulRequests.map { $0.estimatedCost }.reduce(0, +)
        let costPerSuccessfulRequest = successfulRequests.isEmpty ? 0.0 : totalCost / Double(successfulRequests.count)

        // Calculate optimal usage score (0-1)
        let responseTimeFactor = min(1.0, max(0.0, (5.0 - averageResponseTime) / 5.0))
        let costEfficiencyFactor = costPerSuccessfulRequest > 0 ? min(1.0, 0.1 / costPerSuccessfulRequest) : 1.0
        let optimalUsageScore = (successRate + responseTimeFactor + costEfficiencyFactor) / 3.0

        return UsageEfficiency(
            successRate: successRate,
            averageResponseTime: averageResponseTime,
            costPerSuccessfulRequest: costPerSuccessfulRequest,
            optimalUsageScore: optimalUsageScore
        )
    }

    private func generateOptimizationRecommendations(_ records: [AIRequestRecord]) -> [OptimizationRecommendation] {
        var recommendations: [OptimizationRecommendation] = []

        // Analyze quick requests that could be local
        let quickRequests = records.filter { $0.requestType == .quick }
        if quickRequests.count > 10 {
            recommendations.append(
                OptimizationRecommendation(
                    category: .requestType,
                    suggestion: "Route quick analyses to local processing when possible",
                    potentialImprovement: "Reduce costs by up to 90% for simple queries",
                    implementationEffort: .medium
                ))
        }

        // Analyze timing patterns
        let nightRequests = records.filter {
            let hour = Calendar.current.component(.hour, from: $0.timestamp)
            return hour < 6 || hour > 22
        }

        if nightRequests.count > records.count / 4 {
            recommendations.append(
                OptimizationRecommendation(
                    category: .timing,
                    suggestion: "Defer non-urgent requests to off-peak hours",
                    potentialImprovement: "Improved system performance and potential cost savings",
                    implementationEffort: .easy
                ))
        }

        // Analyze error rates
        let failedRequests = records.filter { !$0.success }
        if Double(failedRequests.count) / Double(records.count) > 0.1 {
            recommendations.append(
                OptimizationRecommendation(
                    category: .errorHandling,
                    suggestion: "Improve error handling and retry logic",
                    potentialImprovement: "Reduce wasted requests by up to 50%",
                    implementationEffort: .medium
                ))
        }

        return recommendations
    }

    private func generateCurrentUsageStatistics(
        _ records: [AIRequestRecord], period: StatisticsPeriod
    ) -> AIUsageStatistics {
        let totalRequests = records.count
        let successfulRequests = records.filter { $0.success }.count
        let failedRequests = totalRequests - successfulRequests

        let totalTokensUsed = records.map { $0.tokensUsed }.reduce(0, +)
        let totalCostIncurred = records.map { $0.estimatedCost }.reduce(0, +)

        var requestsByType: [AnalysisRequestType: Int] = [:]
        var costByType: [AnalysisRequestType: Double] = [:]

        for record in records {
            requestsByType[record.requestType, default: 0] += 1
            costByType[record.requestType, default: 0.0] += record.estimatedCost
        }

        let peakUsageHours = analyzePeakUsageHours(records)
        let averageResponseTime =
            records.isEmpty ? 0.0 : records.map { $0.responseTime }.reduce(0, +) / Double(records.count)

        return AIUsageStatistics(
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            averageResponseTime: averageResponseTime,
            totalTokensUsed: totalTokensUsed,
            totalCostIncurred: totalCostIncurred,
            requestsByType: requestsByType,
            peakUsageHours: peakUsageHours,
            costByType: costByType,
            period: period
        )
    }

    private func generateHistoricalTrends(_ records: [AIRequestRecord]) -> [AIUsageStatistics] {
        // Placeholder for historical trend analysis
        // Would need to group records by time periods and analyze trends
        return []
    }

    private func generateUsagePredictions(_ records: [AIRequestRecord]) -> UsagePredictions {
        let dailyUsage = records.count  // Simplified
        let weeklyCost = records.map { $0.estimatedCost }.reduce(0, +) * 7
        let monthlyBudgetUsage = weeklyCost * 4.3

        return UsagePredictions(
            projectedDailyUsage: dailyUsage,
            projectedWeeklyCost: weeklyCost,
            projectedMonthlyBudgetUsage: monthlyBudgetUsage,
            peakUsageTimes: [],  // Would calculate based on patterns
            confidence: 0.7
        )
    }

    private func generateUsageRecommendations(_ records: [AIRequestRecord]) -> [UsageRecommendation] {
        var recommendations: [UsageRecommendation] = []

        let efficiency = calculateUsageEfficiency(records)

        if efficiency.successRate < 0.9 {
            recommendations.append(
                UsageRecommendation(
                    type: .errorReduction,
                    title: "Improve Success Rate",
                    description:
                        "Your current success rate is below optimal. Consider implementing better error handling and validation.",
                    potentialSavings: Double(records.count) * 0.1 * 0.02,  // 10% of failed requests * avg cost
                    implementationDifficulty: .medium,
                    priority: .high
                )
            )
        }

        if efficiency.costPerSuccessfulRequest > 0.05 {
            recommendations.append(
                UsageRecommendation(
                    type: .budgetOptimization,
                    title: "Optimize Request Types",
                    description:
                        "Your average cost per request is high. Consider using more efficient request types for routine queries.",
                    potentialSavings: efficiency.costPerSuccessfulRequest * 0.3 * Double(records.count),
                    implementationDifficulty: .easy,
                    priority: .medium
                )
            )
        }

        return recommendations
    }

    private func detectUsageAnomalies(_ records: [AIRequestRecord]) -> [UsageAnomaly] {
        var anomalies: [UsageAnomaly] = []

        // Detect burst patterns
        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        for index in 0 ..< max(0, sortedRecords.count - 5) {
            let timeSpan = sortedRecords[index + 4].timestamp.timeIntervalSince(sortedRecords[index].timestamp)
            if timeSpan < 300 {  // 5 requests in 5 minutes
                anomalies.append(
                    UsageAnomaly(
                        timestamp: sortedRecords[index].timestamp,
                        pattern: .unusualSpike,
                        severity: .medium,
                        description: "Unusual spike in request frequency detected",
                        impact: "May indicate automated or batch processing"
                    )
                )
                break
            }
        }

        // Detect expensive request clusters
        let expensiveRequests = records.filter { $0.estimatedCost > 0.04 }
        if Double(expensiveRequests.count) / Double(records.count) > 0.3 {
            anomalies.append(
                UsageAnomaly(
                    timestamp: Date(),
                    pattern: .rapidConsumption,
                    severity: .high,
                    description: "High proportion of expensive requests detected",
                    impact: "Potential budget overrun risk"
                )
            )
        }

        return anomalies
    }
}
