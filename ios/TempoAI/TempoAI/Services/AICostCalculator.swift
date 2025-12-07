import Foundation

// MARK: - AI Cost Calculator

class AICostCalculator {

    // Cost estimates per request type (in USD)
    private let costEstimates: [AnalysisRequestType: Double] = [
        .quick: 0.005,
        .daily: 0.015,
        .comprehensive: 0.050,
        .weekly: 0.080,
        .critical: 0.030,
        .userRequested: 0.040,
    ]

    func estimateCost(for requestType: AnalysisRequestType) -> Double {
        return costEstimates[requestType] ?? 0.020
    }

    func calculateMonthlyCost(
        quick: Int = 0,
        daily: Int = 0,
        comprehensive: Int = 0,
        weekly: Int = 0,
        critical: Int = 0,
        userRequested: Int = 0
    ) -> Double {

        let costs: [(AnalysisRequestType, Int)] = [
            (.quick, quick),
            (.daily, daily),
            (.comprehensive, comprehensive),
            (.weekly, weekly),
            (.critical, critical),
            (.userRequested, userRequested),
        ]

        return costs.reduce(0.0) { total, item in
            total + (Double(item.1) * estimateCost(for: item.0))
        }
    }

    func calculateDetailedCost(for requestType: AnalysisRequestType, tokens: Int = 0) -> CostBreakdown {
        let baseRequestCost = estimateCost(for: requestType)
        let tokenCost = Double(tokens) * 0.00001  // $0.00001 per token
        let priorityModifier = getPriorityModifier(for: requestType)
        let totalCost = (baseRequestCost + tokenCost) * priorityModifier

        return CostBreakdown(
            baseRequestCost: baseRequestCost,
            tokenCost: tokenCost,
            priorityModifier: priorityModifier,
            totalCost: totalCost,
            currency: "USD"
        )
    }

    func estimateMonthlyCostFromUsage(_ usage: AIUsageStatistics) -> CostEstimate {
        var totalCost = 0.0
        var confidence = 0.8

        for (requestType, count) in usage.requestsByType {
            totalCost += Double(count) * estimateCost(for: requestType)
        }

        // Adjust confidence based on data quality
        if usage.totalRequests < 10 {
            confidence = 0.5
        } else if usage.totalRequests > 100 {
            confidence = 0.9
        }

        let breakdown = CostBreakdown(
            baseRequestCost: totalCost * 0.8,
            tokenCost: totalCost * 0.15,
            priorityModifier: 1.05,
            totalCost: totalCost,
            currency: "USD"
        )

        return CostEstimate(
            estimatedCost: totalCost,
            confidence: confidence,
            factorsConsidered: [
                "Historical usage patterns",
                "Request type distribution",
                "Average response time",
                "Success rate impact",
            ],
            breakdown: breakdown
        )
    }

    private func getPriorityModifier(for requestType: AnalysisRequestType) -> Double {
        switch requestType {
        case .critical:
            return 1.5  // Higher priority = higher cost
        case .userRequested:
            return 1.2
        case .comprehensive:
            return 1.1
        case .weekly:
            return 1.0
        case .daily:
            return 0.9
        case .quick:
            return 0.8
        }
    }
}
