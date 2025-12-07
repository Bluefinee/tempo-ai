import Combine
import Foundation

/**
 * AI Request Rate Limiter
 *
 * Intelligent cost control and rate limiting system for AI analysis requests.
 * Manages request quotas, cost tracking, and optimizes AI usage patterns
 * to stay within budget while maximizing user value.
 *
 * Key Features:
 * - Multi-tier rate limiting (hourly, daily, weekly, monthly)
 * - Cost tracking and budget management
 * - Request priority and scheduling
 * - Usage analytics and optimization
 * - Predictive cost modeling
 * - User quota management
 */

@MainActor
class AIRequestRateLimiter: ObservableObject {

    // MARK: - Properties
    @MainActor static let shared: AIRequestRateLimiter = AIRequestRateLimiter()

    @Published var currentUsage: AIUsageStatus = AIUsageStatus()
    @Published var budgetStatus: BudgetStatus = BudgetStatus()
    @Published var rateLimitStatus: [RequestType: RateLimitInfo] = [:]

    private let userDefaults = UserDefaults.standard
    private let costCalculator = AICostCalculator()
    private let usageAnalyzer = AIUsageAnalyzer()

    // Rate limiting configuration
    private let rateLimits = RateLimitConfiguration()

    // MARK: - Public Interface

    /// Check if an AI request can be made for the given type
    /// - Parameter requestType: Type of analysis request
    /// - Returns: Rate limit result with availability status
    func canMakeAIRequest(for requestType: AnalysisRequestType) -> RateLimitResult {

        let now = Date()

        // Check multiple rate limit tiers
        let hourlyCheck = checkHourlyLimit(for: requestType, at: now)
        let dailyCheck = checkDailyLimit(for: requestType, at: now)
        let weeklyCheck = checkWeeklyLimit(for: requestType, at: now)
        let monthlyCheck = checkMonthlyLimit(for: requestType, at: now)
        let budgetCheck = checkBudgetLimit(for: requestType)

        // Find the most restrictive limit
        let checks = [hourlyCheck, dailyCheck, weeklyCheck, monthlyCheck, budgetCheck]
        let restrictiveCheck = checks.first { !$0.allowed } ?? hourlyCheck

        // Update rate limit status
        updateRateLimitStatus(for: requestType, result: restrictiveCheck)

        return restrictiveCheck
    }

    /// Record an AI request after successful execution
    /// - Parameters:
    ///   - requestType: Type of analysis request
    ///   - cost: Actual cost of the request
    ///   - responseTime: Time taken for the request
    ///   - userSatisfaction: User satisfaction score (optional)
    func recordAIRequest(
        type requestType: AnalysisRequestType,
        cost: Double = 0.0,
        responseTime: TimeInterval = 0.0,
        userSatisfaction: Double? = nil
    ) {

        let now = Date()
        let request = AIRequestRecord(
            id: UUID(),
            type: requestType,
            timestamp: now,
            cost: cost > 0 ? cost : costCalculator.estimateCost(for: requestType),
            responseTime: responseTime,
            userSatisfaction: userSatisfaction
        )

        // Store the request record
        storeRequestRecord(request)

        // Update usage counters
        incrementRequestCounter(for: requestType, at: now)
        updateBudgetUsage(cost: request.cost)

        // Update published properties
        refreshUsageStatus()
        refreshBudgetStatus()

        print("📊 AI request recorded: \(requestType.rawValue), cost: $\(String(format: "%.4f", request.cost))")
    }

    /// Get current AI availability status
    func getAIAvailabilityStatus() -> AIAvailabilityStatus {

        let canMakeRequest = canMakeAIRequest(for: .daily).allowed
        let remainingRequests = calculateRemainingRequests()
        let nextReset = calculateNextReset()
        let costBudgetRemaining = budgetStatus.remainingBudget

        return AIAvailabilityStatus(
            canMakeRequest: canMakeRequest,
            remainingRequests: remainingRequests,
            nextReset: nextReset,
            budgetRemaining: costBudgetRemaining,
            usageAnalytics: generateUsageAnalytics()
        )
    }

    /// Get detailed usage statistics
    func getUsageStatistics() -> AIUsageStatistics {

        let records = getRecentRequestRecords(days: 30)

        return AIUsageStatistics(
            totalRequests: records.count,
            totalCost: records.reduce(0) { $0 + $1.cost },
            averageCost: records.isEmpty ? 0 : records.reduce(0) { $0 + $1.cost } / Double(records.count),
            averageResponseTime: records.isEmpty
                ? 0 : records.reduce(0) { $0 + $1.responseTime } / Double(records.count),
            requestsByType: calculateRequestsByType(records),
            costByType: calculateCostByType(records),
            usageTrend: calculateUsageTrend(records),
            recommendations: generateUsageRecommendations(records)
        )
    }

    /// Predict if a request can be made at a future time
    func predictRequestAvailability(
        for requestType: AnalysisRequestType,
        at futureTime: Date
    ) -> PredictionResult {

        // Calculate when rate limits will reset
        let hourlyReset = nextHourlyReset(from: futureTime)
        let dailyReset = nextDailyReset(from: futureTime)
        let weeklyReset = nextWeeklyReset(from: futureTime)
        let monthlyReset = nextMonthlyReset(from: futureTime)

        // Check which limits will be available by the future time
        let hourlyAvailable = futureTime >= hourlyReset
        let dailyAvailable = futureTime >= dailyReset
        let weeklyAvailable = futureTime >= weeklyReset
        let monthlyAvailable = futureTime >= monthlyReset

        let budgetAvailable = budgetStatus.remainingBudget >= costCalculator.estimateCost(for: requestType)

        let canMakeRequest = hourlyAvailable && dailyAvailable && weeklyAvailable && monthlyAvailable && budgetAvailable

        let nextAvailableTime =
            canMakeRequest ? futureTime : [hourlyReset, dailyReset, weeklyReset, monthlyReset].min() ?? futureTime

        return PredictionResult(
            canMakeRequest: canMakeRequest,
            nextAvailableTime: nextAvailableTime,
            limitingFactor: determineLimitingFactor(
                hourly: hourlyAvailable,
                daily: dailyAvailable,
                weekly: weeklyAvailable,
                monthly: monthlyAvailable,
                budget: budgetAvailable
            ),
            confidence: 0.9
        )
    }

    /// Reset rate limits for testing purposes
    func resetRateLimits() {
        clearAllCounters()
        resetBudget()
        refreshUsageStatus()
        refreshBudgetStatus()
        print("🔄 Rate limits reset")
    }

    // MARK: - Rate Limit Checking

    private func checkHourlyLimit(for requestType: AnalysisRequestType, at date: Date) -> RateLimitResult {

        let limit = rateLimits.hourlyLimits[requestType] ?? rateLimits.defaultHourlyLimit
        let current = getCurrentHourlyCount(for: requestType, at: date)

        if current < limit {
            return RateLimitResult(
                allowed: true,
                limitType: .hourly,
                current: current,
                limit: limit,
                resetTime: nextHourlyReset(from: date),
                message: "Within hourly limit"
            )
        } else {
            return RateLimitResult(
                allowed: false,
                limitType: .hourly,
                current: current,
                limit: limit,
                resetTime: nextHourlyReset(from: date),
                message: "Hourly limit reached"
            )
        }
    }

    private func checkDailyLimit(for requestType: AnalysisRequestType, at date: Date) -> RateLimitResult {

        let limit = rateLimits.dailyLimits[requestType] ?? rateLimits.defaultDailyLimit
        let current = getCurrentDailyCount(for: requestType, at: date)

        if current < limit {
            return RateLimitResult(
                allowed: true,
                limitType: .daily,
                current: current,
                limit: limit,
                resetTime: nextDailyReset(from: date),
                message: "Within daily limit"
            )
        } else {
            return RateLimitResult(
                allowed: false,
                limitType: .daily,
                current: current,
                limit: limit,
                resetTime: nextDailyReset(from: date),
                message: "Daily limit reached"
            )
        }
    }

    private func checkWeeklyLimit(for requestType: AnalysisRequestType, at date: Date) -> RateLimitResult {

        let limit = rateLimits.weeklyLimits[requestType] ?? rateLimits.defaultWeeklyLimit
        let current = getCurrentWeeklyCount(for: requestType, at: date)

        if current < limit {
            return RateLimitResult(
                allowed: true,
                limitType: .weekly,
                current: current,
                limit: limit,
                resetTime: nextWeeklyReset(from: date),
                message: "Within weekly limit"
            )
        } else {
            return RateLimitResult(
                allowed: false,
                limitType: .weekly,
                current: current,
                limit: limit,
                resetTime: nextWeeklyReset(from: date),
                message: "Weekly limit reached"
            )
        }
    }

    private func checkMonthlyLimit(for requestType: AnalysisRequestType, at date: Date) -> RateLimitResult {

        let limit = rateLimits.monthlyLimits[requestType] ?? rateLimits.defaultMonthlyLimit
        let current = getCurrentMonthlyCount(for: requestType, at: date)

        if current < limit {
            return RateLimitResult(
                allowed: true,
                limitType: .monthly,
                current: current,
                limit: limit,
                resetTime: nextMonthlyReset(from: date),
                message: "Within monthly limit"
            )
        } else {
            return RateLimitResult(
                allowed: false,
                limitType: .monthly,
                current: current,
                limit: limit,
                resetTime: nextMonthlyReset(from: date),
                message: "Monthly limit reached"
            )
        }
    }

    private func checkBudgetLimit(for requestType: AnalysisRequestType) -> RateLimitResult {

        let estimatedCost = costCalculator.estimateCost(for: requestType)
        let remainingBudget = budgetStatus.remainingBudget

        if remainingBudget >= estimatedCost {
            return RateLimitResult(
                allowed: true,
                limitType: .budget,
                current: Int(budgetStatus.usedBudget * 100),  // Convert to cents
                limit: Int(budgetStatus.totalBudget * 100),
                resetTime: nextMonthlyReset(from: Date()),
                message: "Within budget limit"
            )
        } else {
            return RateLimitResult(
                allowed: false,
                limitType: .budget,
                current: Int(budgetStatus.usedBudget * 100),
                limit: Int(budgetStatus.totalBudget * 100),
                resetTime: nextMonthlyReset(from: Date()),
                message: "Budget limit reached"
            )
        }
    }

    // MARK: - Counter Management

    private func getCurrentHourlyCount(for requestType: AnalysisRequestType, at date: Date) -> Int {
        let hourKey = generateHourKey(for: requestType, at: date)
        return userDefaults.integer(forKey: hourKey)
    }

    private func getCurrentDailyCount(for requestType: AnalysisRequestType, at date: Date) -> Int {
        let dayKey = generateDayKey(for: requestType, at: date)
        return userDefaults.integer(forKey: dayKey)
    }

    private func getCurrentWeeklyCount(for requestType: AnalysisRequestType, at date: Date) -> Int {
        let weekKey = generateWeekKey(for: requestType, at: date)
        return userDefaults.integer(forKey: weekKey)
    }

    private func getCurrentMonthlyCount(for requestType: AnalysisRequestType, at date: Date) -> Int {
        let monthKey = generateMonthKey(for: requestType, at: date)
        return userDefaults.integer(forKey: monthKey)
    }

    private func incrementRequestCounter(for requestType: AnalysisRequestType, at date: Date) {

        // Increment all applicable counters
        let hourKey = generateHourKey(for: requestType, at: date)
        let dayKey = generateDayKey(for: requestType, at: date)
        let weekKey = generateWeekKey(for: requestType, at: date)
        let monthKey = generateMonthKey(for: requestType, at: date)

        userDefaults.set(userDefaults.integer(forKey: hourKey) + 1, forKey: hourKey)
        userDefaults.set(userDefaults.integer(forKey: dayKey) + 1, forKey: dayKey)
        userDefaults.set(userDefaults.integer(forKey: weekKey) + 1, forKey: weekKey)
        userDefaults.set(userDefaults.integer(forKey: monthKey) + 1, forKey: monthKey)

        // Clean up old counters periodically
        if Int.random(in: 1 ... 10) == 1 {  // 10% chance
            cleanupOldCounters()
        }
    }

    private func clearAllCounters() {
        let keys = userDefaults.dictionaryRepresentation().keys
        let rateLimitKeys = keys.filter { $0.hasPrefix("ai_rate_limit_") }

        for key in rateLimitKeys {
            userDefaults.removeObject(forKey: key)
        }
    }

    private func cleanupOldCounters() {
        let now = Date()
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now

        let keys = userDefaults.dictionaryRepresentation().keys
        let rateLimitKeys = keys.filter { $0.hasPrefix("ai_rate_limit_") }

        for key in rateLimitKeys {
            if let extractedDate = extractDateFromKey(key), extractedDate < cutoffDate {
                userDefaults.removeObject(forKey: key)
            }
        }
    }

    // MARK: - Key Generation

    private func generateHourKey(for requestType: AnalysisRequestType, at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        return "ai_rate_limit_hour_\(requestType.rawValue)_\(formatter.string(from: date))"
    }

    private func generateDayKey(for requestType: AnalysisRequestType, at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "ai_rate_limit_day_\(requestType.rawValue)_\(formatter.string(from: date))"
    }

    private func generateWeekKey(for requestType: AnalysisRequestType, at date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let week = calendar.component(.weekOfYear, from: date)
        return "ai_rate_limit_week_\(requestType.rawValue)_\(year)_\(week)"
    }

    private func generateMonthKey(for requestType: AnalysisRequestType, at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "ai_rate_limit_month_\(requestType.rawValue)_\(formatter.string(from: date))"
    }

    private func extractDateFromKey(_ key: String) -> Date? {
        // Simple extraction - could be more sophisticated
        let components = key.split(separator: "_")
        guard components.count >= 3 else { return nil }

        let dateStr = String(components.last ?? "")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateStr)
    }

    // MARK: - Reset Time Calculations

    private func nextHourlyReset(from date: Date) -> Date {
        let calendar = Calendar.current
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: date) ?? date
        return calendar.dateInterval(of: .hour, for: nextHour)?.start ?? date
    }

    private func nextDailyReset(from date: Date) -> Date {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        return calendar.startOfDay(for: nextDay)
    }

    private func nextWeeklyReset(from date: Date) -> Date {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        return calendar.dateInterval(of: .weekOfYear, for: nextWeek)?.start ?? date
    }

    private func nextMonthlyReset(from date: Date) -> Date {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        return calendar.dateInterval(of: .month, for: nextMonth)?.start ?? date
    }

    // MARK: - Budget Management

    private func updateBudgetUsage(cost: Double) {
        let currentUsage = userDefaults.double(forKey: "ai_budget_used_this_month")
        let newUsage = currentUsage + cost

        userDefaults.set(newUsage, forKey: "ai_budget_used_this_month")

        // Update budget status
        budgetStatus = BudgetStatus(
            totalBudget: budgetStatus.totalBudget,
            usedBudget: newUsage,
            remainingBudget: max(0, budgetStatus.totalBudget - newUsage),
            resetDate: budgetStatus.resetDate
        )
    }

    private func resetBudget() {
        userDefaults.set(0.0, forKey: "ai_budget_used_this_month")
        refreshBudgetStatus()
    }

    // MARK: - Request Record Management

    private func storeRequestRecord(_ record: AIRequestRecord) {
        var records = getRequestRecords()
        records.append(record)

        // Keep only recent records (last 100)
        if records.count > 100 {
            records = Array(records.suffix(100))
        }

        saveRequestRecords(records)
    }

    private func getRequestRecords() -> [AIRequestRecord] {
        guard let data = userDefaults.data(forKey: "ai_request_records"),
            let records = try? JSONDecoder().decode([AIRequestRecord].self, from: data)
        else {
            return []
        }
        return records
    }

    private func getRecentRequestRecords(days: Int) -> [AIRequestRecord] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return getRequestRecords().filter { $0.timestamp >= cutoffDate }
    }

    private func saveRequestRecords(_ records: [AIRequestRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: "ai_request_records")
        }
    }

    // MARK: - Status Updates

    private func refreshUsageStatus() {
        let now = Date()
        var typeUsage: [AnalysisRequestType: RequestTypeUsage] = [:]

        for requestType in AnalysisRequestType.allCases {
            typeUsage[requestType] = RequestTypeUsage(
                hourly: getCurrentHourlyCount(for: requestType, at: now),
                daily: getCurrentDailyCount(for: requestType, at: now),
                weekly: getCurrentWeeklyCount(for: requestType, at: now),
                monthly: getCurrentMonthlyCount(for: requestType, at: now)
            )
        }

        currentUsage = AIUsageStatus(
            lastUpdated: now,
            requestTypeUsage: typeUsage
        )
    }

    private func refreshBudgetStatus() {
        let totalBudget = 10.0  // $10 per month
        let usedBudget = userDefaults.double(forKey: "ai_budget_used_this_month")
        let nextReset = nextMonthlyReset(from: Date())

        budgetStatus = BudgetStatus(
            totalBudget: totalBudget,
            usedBudget: usedBudget,
            remainingBudget: max(0, totalBudget - usedBudget),
            resetDate: nextReset
        )
    }

    private func updateRateLimitStatus(for requestType: AnalysisRequestType, result: RateLimitResult) {
        rateLimitStatus[RequestType(requestType)] = RateLimitInfo(
            allowed: result.allowed,
            current: result.current,
            limit: result.limit,
            resetTime: result.resetTime,
            limitType: result.limitType
        )
    }

    // MARK: - Analytics and Calculations

    private func calculateRemainingRequests() -> Int {
        let dailyLimits = AnalysisRequestType.allCases.compactMap { type in
            rateLimits.dailyLimits[type] ?? rateLimits.defaultDailyLimit
        }

        let dailyUsage = AnalysisRequestType.allCases.compactMap { type in
            getCurrentDailyCount(for: type, at: Date())
        }

        let totalLimit = dailyLimits.reduce(0, +)
        let totalUsage = dailyUsage.reduce(0, +)

        return max(0, totalLimit - totalUsage)
    }

    private func calculateNextReset() -> Date? {
        let now = Date()
        let resets = [
            nextHourlyReset(from: now),
            nextDailyReset(from: now),
            nextWeeklyReset(from: now),
            nextMonthlyReset(from: now),
        ]

        return resets.min()
    }

    private func generateUsageAnalytics() -> UsageAnalytics {
        let records = getRecentRequestRecords(days: 7)

        return UsageAnalytics(
            averageRequestsPerDay: Double(records.count) / 7.0,
            mostUsedRequestType: calculateMostUsedType(records),
            peakUsageHour: calculatePeakHour(records),
            costTrend: calculateCostTrend(records),
            efficiencyScore: calculateEfficiencyScore(records)
        )
    }

    private func calculateRequestsByType(_ records: [AIRequestRecord]) -> [AnalysisRequestType: Int] {
        var counts: [AnalysisRequestType: Int] = [:]

        for record in records {
            counts[record.type, default: 0] += 1
        }

        return counts
    }

    private func calculateCostByType(_ records: [AIRequestRecord]) -> [AnalysisRequestType: Double] {
        var costs: [AnalysisRequestType: Double] = [:]

        for record in records {
            costs[record.type, default: 0.0] += record.cost
        }

        return costs
    }

    private func calculateUsageTrend(_ records: [AIRequestRecord]) -> TrendDirection {
        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        guard sortedRecords.count >= 4 else { return .stable }

        let firstHalf = Array(sortedRecords.prefix(sortedRecords.count / 2))
        let secondHalf = Array(sortedRecords.suffix(sortedRecords.count / 2))

        let firstHalfAvg = Double(firstHalf.count) / 7.0
        let secondHalfAvg = Double(secondHalf.count) / 7.0

        let change = (secondHalfAvg - firstHalfAvg) / firstHalfAvg

        if change > 0.1 {
            return .improving
        } else if change < -0.1 {
            return .declining
        } else {
            return .stable
        }
    }

    private func generateUsageRecommendations(_ records: [AIRequestRecord]) -> [UsageRecommendation] {
        var recommendations: [UsageRecommendation] = []

        let totalCost = records.reduce(0) { $0 + $1.cost }

        if totalCost > budgetStatus.totalBudget * 0.8 {
            recommendations.append(
                UsageRecommendation(
                    type: .costOptimization,
                    title: "High Cost Usage Detected",
                    description: "Consider using local analysis for routine checks",
                    priority: .high,
                    estimatedSavings: totalCost * 0.3
                ))
        }

        let quickRequests = records.filter { $0.type == .quick }.count
        if quickRequests > records.count / 2 {
            recommendations.append(
                UsageRecommendation(
                    type: .usagePattern,
                    title: "Frequent Quick Analyses",
                    description: "Quick analyses should use local processing",
                    priority: .medium,
                    estimatedSavings: Double(quickRequests) * costCalculator.estimateCost(for: .quick) * 0.9
                ))
        }

        return recommendations
    }

    private func calculateMostUsedType(_ records: [AIRequestRecord]) -> AnalysisRequestType? {
        let counts = calculateRequestsByType(records)
        return counts.max { $0.value < $1.value }?.key
    }

    private func calculatePeakHour(_ records: [AIRequestRecord]) -> Int {
        var hourCounts: [Int: Int] = [:]

        for record in records {
            let hour = Calendar.current.component(.hour, from: record.timestamp)
            hourCounts[hour, default: 0] += 1
        }

        return hourCounts.max { $0.value < $1.value }?.key ?? 12
    }

    private func calculateCostTrend(_ records: [AIRequestRecord]) -> TrendDirection {
        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        guard sortedRecords.count >= 4 else { return .stable }

        let firstHalf = Array(sortedRecords.prefix(sortedRecords.count / 2))
        let secondHalf = Array(sortedRecords.suffix(sortedRecords.count / 2))

        let firstCost = firstHalf.reduce(0) { $0 + $1.cost }
        let secondCost = secondHalf.reduce(0) { $0 + $1.cost }

        let change = (secondCost - firstCost) / firstCost

        if change > 0.2 {
            return .improving
        } else if change < -0.2 {
            return .declining
        } else {
            return .stable
        }
    }

    private func calculateEfficiencyScore(_ records: [AIRequestRecord]) -> Double {
        guard !records.isEmpty else { return 1.0 }

        let averageSatisfaction = records.compactMap { $0.userSatisfaction }.reduce(0, +) / Double(records.count)
        let averageCost = records.reduce(0) { $0 + $1.cost } / Double(records.count)
        let maxCost = costCalculator.estimateCost(for: .comprehensive)

        let costEfficiency = 1.0 - (averageCost / maxCost)
        let satisfactionScore = averageSatisfaction / 5.0  // Assuming 5-point scale

        return (costEfficiency + satisfactionScore) / 2.0
    }

    private func determineLimitingFactor(
        hourly: Bool,
        daily: Bool,
        weekly: Bool,
        monthly: Bool,
        budget: Bool
    ) -> LimitingFactor {

        if !budget { return .budget }
        if !hourly { return .hourly }
        if !daily { return .daily }
        if !weekly { return .weekly }
        if !monthly { return .monthly }
        return .none
    }
}

// MARK: - Supporting Types

struct RateLimitConfiguration {
    // Hourly limits by request type
    let hourlyLimits: [AnalysisRequestType: Int] = [
        .quick: 20,
        .daily: 5,
        .comprehensive: 2,
        .weekly: 1,
        .critical: 3,
        .userRequested: 3,
    ]

    // Daily limits by request type
    let dailyLimits: [AnalysisRequestType: Int] = [
        .quick: 50,
        .daily: 10,
        .comprehensive: 5,
        .weekly: 3,
        .critical: 10,
        .userRequested: 8,
    ]

    // Weekly limits by request type
    let weeklyLimits: [AnalysisRequestType: Int] = [
        .quick: 200,
        .daily: 50,
        .comprehensive: 20,
        .weekly: 10,
        .critical: 30,
        .userRequested: 25,
    ]

    // Monthly limits by request type
    let monthlyLimits: [AnalysisRequestType: Int] = [
        .quick: 500,
        .daily: 150,
        .comprehensive: 50,
        .weekly: 30,
        .critical: 100,
        .userRequested: 80,
    ]

    // Default limits for unknown types
    let defaultHourlyLimit = 5
    let defaultDailyLimit = 15
    let defaultWeeklyLimit = 50
    let defaultMonthlyLimit = 100
}

struct RateLimitResult {
    let allowed: Bool
    let limitType: LimitType
    let current: Int
    let limit: Int
    let resetTime: Date
    let message: String
}

enum LimitType: String, CaseIterable {
    case hourly
    case daily
    case weekly
    case monthly
    case budget
}

struct AIRequestRecord: Codable {
    let id: UUID
    let type: AnalysisRequestType
    let timestamp: Date
    let cost: Double
    let responseTime: TimeInterval
    let userSatisfaction: Double?
}

struct AIUsageStatus {
    let lastUpdated: Date
    let requestTypeUsage: [AnalysisRequestType: RequestTypeUsage]

    init(
        lastUpdated: Date = Date(),
        requestTypeUsage: [AnalysisRequestType: RequestTypeUsage] = [:]
    ) {
        self.lastUpdated = lastUpdated
        self.requestTypeUsage = requestTypeUsage
    }
}

struct RequestTypeUsage {
    let hourly: Int
    let daily: Int
    let weekly: Int
    let monthly: Int
}

struct BudgetStatus {
    let totalBudget: Double
    let usedBudget: Double
    let remainingBudget: Double
    let resetDate: Date

    init(
        totalBudget: Double = 10.0,
        usedBudget: Double = 0.0,
        remainingBudget: Double = 10.0,
        resetDate: Date = Calendar.current.startOfDay(for: Date())
    ) {
        self.totalBudget = totalBudget
        self.usedBudget = usedBudget
        self.remainingBudget = remainingBudget
        self.resetDate = resetDate
    }
}

struct RequestType: Hashable {
    let analysisType: AnalysisRequestType

    init(_ type: AnalysisRequestType) {
        self.analysisType = type
    }
}

struct RateLimitInfo {
    let allowed: Bool
    let current: Int
    let limit: Int
    let resetTime: Date
    let limitType: LimitType
}

struct AIAvailabilityStatus {
    let canMakeRequest: Bool
    let remainingRequests: Int
    let nextReset: Date?
    let budgetRemaining: Double
    let usageAnalytics: UsageAnalytics
}

struct PredictionResult {
    let canMakeRequest: Bool
    let nextAvailableTime: Date
    let limitingFactor: LimitingFactor
    let confidence: Double
}

enum LimitingFactor: String {
    case none
    case hourly
    case daily
    case weekly
    case monthly
    case budget
}

// AIUsageStatistics, UsageAnalytics, and UsageRecommendation are now in AIRateLimitingTypes.swift
// This avoids duplicate type definitions

// MARK: - Extracted Components
//
// AICostCalculator is now in Services/AICostCalculator.swift
// AIUsageAnalyzer is now in Services/AIUsageAnalyzer.swift
// This avoids duplicate class definitions

// AIUsageAnalyzer and related types are now in Services/AIUsageAnalyzer.swift
// This avoids duplicate class definitions

// MARK: - Extensions

extension AnalysisRequestType: Codable {}
