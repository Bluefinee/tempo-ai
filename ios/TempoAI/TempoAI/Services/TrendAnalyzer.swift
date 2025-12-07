import Foundation

// MARK: - Trend Analyzer

/// Analyzes health data trends over time to identify patterns and changes
/// Uses statistical methods to detect significant trends and their implications
struct TrendAnalyzer {

    /// Analyze health data trends
    /// - Parameter data: Current comprehensive health data
    /// - Returns: Array of identified health trends
    static func analyzeTrends(_ data: ComprehensiveHealthData) -> [HealthTrend] {

        var trends: [HealthTrend] = []

        // Note: In a real implementation, this would analyze historical data
        // For now, we'll analyze current data patterns and simulate trends

        // Heart Rate trends
        trends.append(contentsOf: analyzeHeartRateTrends(data.vitalSigns.heartRate))

        // HRV trends
        trends.append(contentsOf: analyzeHRVTrends(data.vitalSigns.heartRateVariability))

        // Sleep trends
        trends.append(contentsOf: analyzeSleepTrends(data.sleep))

        // Activity trends
        trends.append(contentsOf: analyzeActivityTrends(data.activity))

        // Overall health score trend (simulated)
        trends.append(contentsOf: analyzeOverallTrends(data))

        return trends.sorted { $0.significance > $1.significance }
    }

    // MARK: - Private Analysis Methods

    /// Analyze heart rate trends
    private static func analyzeHeartRateTrends(_ heartRateMetrics: HeartRateMetrics?) -> [HealthTrend] {

        guard let heartRate = heartRateMetrics else { return [] }

        var trends: [HealthTrend] = []

        // Resting heart rate trend analysis
        if let restingHR = heartRate.resting {
            // Simulate trend based on current value vs. typical ranges
            let direction: TrendDirection
            let magnitude: Double
            let significance: Double

            if restingHR < 60 {
                direction = .improving
                magnitude = abs(60 - restingHR) / 60.0
                significance = 0.7
            } else if restingHR > 80 {
                direction = .declining
                magnitude = (restingHR - 80) / 80.0
                significance = 0.8
            } else {
                direction = .stable
                magnitude = 0.1
                significance = 0.5
            }

            trends.append(
                HealthTrend(
                    metric: "安静時心拍数",
                    direction: direction,
                    magnitude: magnitude,
                    timeframe: .week,
                    significance: significance,
                    description: generateHeartRateTrendDescription(restingHR, direction)
                ))
        }

        // Heart rate variability within metrics
        if let variabilityScore = heartRate.variabilityScore {
            let direction: TrendDirection =
                variabilityScore > 80 ? .improving : variabilityScore < 60 ? .declining : .stable

            trends.append(
                HealthTrend(
                    metric: "心拍変動スコア",
                    direction: direction,
                    magnitude: abs(variabilityScore - 70) / 70.0,
                    timeframe: .week,
                    significance: 0.6,
                    description: "心拍変動スコアは\(direction == .improving ? "良好" : direction == .stable ? "安定" : "注意が必要")です"
                ))
        }

        return trends
    }

    /// Analyze HRV-specific trends
    private static func analyzeHRVTrends(_ hrvMetrics: HRVMetrics?) -> [HealthTrend] {

        guard let hrv = hrvMetrics else { return [] }

        var trends: [HealthTrend] = []

        // Use the existing trend indicator from HRV data
        let trendDirection: TrendDirection
        switch hrv.trend {
        case .improving:
            trendDirection = .improving
        case .declining:
            trendDirection = .declining
        case .stable:
            trendDirection = .stable
        case .unknown:
            trendDirection = .unknown
        }

        // Calculate significance based on HRV average
        let significance: Double
        if hrv.average > 40 {
            significance = 0.8  // High HRV is significant for health
        } else if hrv.average < 20 {
            significance = 0.9  // Low HRV is very significant
        } else {
            significance = 0.6  // Moderate HRV
        }

        trends.append(
            HealthTrend(
                metric: "心拍変動（HRV）",
                direction: trendDirection,
                magnitude: hrv.average / 50.0,  // Normalize to 50ms baseline
                timeframe: .week,
                significance: significance,
                description: generateHRVTrendDescription(hrv.average, trendDirection)
            ))

        return trends
    }

    /// Analyze sleep trends
    private static func analyzeSleepTrends(_ sleepData: EnhancedSleepData) -> [HealthTrend] {

        var trends: [HealthTrend] = []

        // Sleep duration trend
        let sleepHours = sleepData.totalDuration / 3600
        let direction: TrendDirection
        let significance: Double

        if sleepHours >= 7 && sleepHours <= 9 {
            direction = .stable
            significance = 0.7
        } else if sleepHours < 6 {
            direction = .declining
            significance = 0.9
        } else if sleepHours > 10 {
            direction = .declining
            significance = 0.6
        } else {
            direction = .improving
            significance = 0.8
        }

        trends.append(
            HealthTrend(
                metric: "睡眠時間",
                direction: direction,
                magnitude: abs(sleepHours - 8) / 8.0,
                timeframe: .week,
                significance: significance,
                description:
                    """
                    睡眠時間は\(String(format: "%.1f", sleepHours))時間で\(
                        direction == .stable ? "適切" :
                        direction == .improving ? "改善傾向" : "注意が必要"
                    )です
                    """
            ))

        // Sleep efficiency trend
        let efficiencyDirection: TrendDirection =
            sleepData.sleepEfficiency >= 0.85 ? .improving : sleepData.sleepEfficiency < 0.75 ? .declining : .stable

        trends.append(
            HealthTrend(
                metric: "睡眠効率",
                direction: efficiencyDirection,
                magnitude: abs(sleepData.sleepEfficiency - 0.85),
                timeframe: .week,
                significance: sleepData.sleepEfficiency < 0.8 ? 0.8 : 0.6,
                description:
                    """
                    睡眠効率は\(String(format: "%.0f", sleepData.sleepEfficiency * 100))%で\(
                        efficiencyDirection == .improving ? "良好" :
                        efficiencyDirection == .stable ? "標準的" : "改善の余地があります"
                    )
                    """
            ))

        // Deep sleep percentage trend
        if let deepSleep = sleepData.deepSleep {
            let deepSleepPercentage = (deepSleep / sleepData.totalDuration) * 100
            let deepSleepDirection: TrendDirection =
                deepSleepPercentage >= 20 ? .improving : deepSleepPercentage < 15 ? .declining : .stable

            trends.append(
                HealthTrend(
                    metric: "深い睡眠",
                    direction: deepSleepDirection,
                    magnitude: abs(deepSleepPercentage - 20) / 20.0,
                    timeframe: .week,
                    significance: deepSleepPercentage < 15 ? 0.8 : 0.6,
                    description: "深い睡眠の割合は\(String(format: "%.1f", deepSleepPercentage))%です"
                ))
        }

        return trends
    }

    /// Analyze activity trends
    private static func analyzeActivityTrends(_ activityData: EnhancedActivityData) -> [HealthTrend] {

        var trends: [HealthTrend] = []

        // Daily steps trend
        let stepsDirection: TrendDirection
        let stepsSignificance: Double

        if activityData.steps >= 10000 {
            stepsDirection = .improving
            stepsSignificance = 0.8
        } else if activityData.steps < 5000 {
            stepsDirection = .declining
            stepsSignificance = 0.9
        } else {
            stepsDirection = .stable
            stepsSignificance = 0.6
        }

        trends.append(
            HealthTrend(
                metric: "歩数",
                direction: stepsDirection,
                magnitude: Double(activityData.steps) / 10000.0,
                timeframe: .week,
                significance: stepsSignificance,
                description:
                    """
                    1日の歩数は\(activityData.steps)歩で\(
                        stepsDirection == .improving ? "目標を達成" :
                        stepsDirection == .stable ? "標準的" : "増加が推奨"
                    )されます
                    """
            ))

        // Exercise time trend
        let exerciseDirection: TrendDirection =
            activityData.exerciseTime >= 30 ? .improving : activityData.exerciseTime < 15 ? .declining : .stable

        trends.append(
            HealthTrend(
                metric: "運動時間",
                direction: exerciseDirection,
                magnitude: Double(activityData.exerciseTime) / 30.0,
                timeframe: .week,
                significance: activityData.exerciseTime < 15 ? 0.8 : 0.6,
                description:
                    """
                    運動時間は\(activityData.exerciseTime)分で\(
                        exerciseDirection == .improving ? "十分" :
                        exerciseDirection == .stable ? "標準的" : "増加が推奨"
                    )です
                    """
            ))

        // Stand hours trend
        let standDirection: TrendDirection =
            activityData.standHours >= 10 ? .improving : activityData.standHours < 6 ? .declining : .stable

        trends.append(
            HealthTrend(
                metric: "立位時間",
                direction: standDirection,
                magnitude: Double(activityData.standHours) / 12.0,
                timeframe: .week,
                significance: activityData.standHours < 6 ? 0.7 : 0.5,
                description:
                    """
                    立位時間は\(activityData.standHours)時間で\(
                        standDirection == .improving ? "良好" :
                        standDirection == .stable ? "標準的" : "増加が推奨"
                    )です
                    """
            ))

        // Activity level classification trend
        let activityLevel = activityData.activityLevel
        let activityDirection: TrendDirection

        switch activityLevel {
        case .extremelyActive, .veryActive:
            activityDirection = .improving
        case .moderatelyActive:
            activityDirection = .stable
        case .lightlyActive, .sedentary:
            activityDirection = .declining
        }

        trends.append(
            HealthTrend(
                metric: "活動レベル",
                direction: activityDirection,
                magnitude: Double(activityData.activityScore) / 100.0,
                timeframe: .week,
                significance: 0.7,
                description:
                    """
                    総合活動レベルは\(
                        activityLevel == .extremelyActive || activityLevel == .veryActive ? "非常に良好" :
                        activityLevel == .moderatelyActive ? "標準的" : "改善の余地があります"
                    )です
                    """
            ))

        return trends
    }

    /// Analyze overall health trends
    private static func analyzeOverallTrends(_ data: ComprehensiveHealthData) -> [HealthTrend] {

        var trends: [HealthTrend] = []

        // Calculate overall health score
        let healthScore = data.overallHealthScore

        // Simulate trend based on score
        let overallDirection: TrendDirection
        let overallSignificance: Double

        if healthScore.overall >= 80 {
            overallDirection = .improving
            overallSignificance = 0.8
        } else if healthScore.overall < 60 {
            overallDirection = .declining
            overallSignificance = 0.9
        } else {
            overallDirection = .stable
            overallSignificance = 0.7
        }

        trends.append(
            HealthTrend(
                metric: "総合健康スコア",
                direction: overallDirection,
                magnitude: healthScore.overall / 100.0,
                timeframe: .month,
                significance: overallSignificance,
                description:
                    "総合的な健康状態は\(overallDirection == .improving ? "良好な方向" : overallDirection == .stable ? "安定" : "注意が必要な状況")にあります"
            ))

        // Recovery trend based on HRV and sleep
        if let hrv = data.vitalSigns.heartRateVariability {
            let recoveryScore = hrv.recoveryScore
            let recoveryDirection: TrendDirection =
                recoveryScore >= 70 ? .improving : recoveryScore < 50 ? .declining : .stable

            trends.append(
                HealthTrend(
                    metric: "回復状態",
                    direction: recoveryDirection,
                    magnitude: recoveryScore / 100.0,
                    timeframe: .week,
                    significance: 0.8,
                    description:
                        "体の回復状態は\(recoveryDirection == .improving ? "良好" : recoveryDirection == .stable ? "標準的" : "注意が必要")です"
                ))
        }

        return trends
    }

    // MARK: - Helper Methods

    /// Generate descriptive text for heart rate trends
    private static func generateHeartRateTrendDescription(_ restingHR: Double, _ direction: TrendDirection) -> String {
        switch direction {
        case .improving:
            return "安静時心拍数(\(Int(restingHR))bpm)は健康的な範囲にあります"
        case .declining:
            return "安静時心拍数(\(Int(restingHR))bpm)に注意が必要です"
        case .stable:
            return "安静時心拍数(\(Int(restingHR))bpm)は安定しています"
        case .unknown:
            return "安静時心拍数の傾向を分析中です"
        }
    }

    /// Generate descriptive text for HRV trends
    private static func generateHRVTrendDescription(_ hrvAverage: Double, _ direction: TrendDirection) -> String {
        switch direction {
        case .improving:
            return "心拍変動(\(String(format: "%.1f", hrvAverage))ms)が改善傾向にあります"
        case .declining:
            return "心拍変動(\(String(format: "%.1f", hrvAverage))ms)の低下に注意が必要です"
        case .stable:
            return "心拍変動(\(String(format: "%.1f", hrvAverage))ms)は安定しています"
        case .unknown:
            return "心拍変動の傾向を分析中です"
        }
    }
}
