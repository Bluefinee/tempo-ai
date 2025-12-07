import Combine
import Foundation

// MARK: - Health Analysis Utilities

class HealthAnalysisUtilities {

    static func generateCacheKey(healthData: ComprehensiveHealthData, userProfile: UserProfile) -> String {
        return "\(userProfile.id)_\(hashHealthData(healthData))"
    }

    private static func hashHealthData(_ data: ComprehensiveHealthData) -> String {
        // Simple hash based on key metrics for caching
        return String(data.vitalSigns.heartRate?.resting.hashValue ?? 0)
    }

    static func assessDataQuality(_ healthData: ComprehensiveHealthData) -> DataQuality {
        let completeness = calculateDataCompleteness(healthData)
        let recency = calculateDataRecency(healthData)
        let accuracy = 0.9  // Assumed high accuracy from HealthKit
        let consistency = 0.85  // Good consistency from device data

        let overallScore = (completeness + recency + accuracy + consistency) / 4.0

        var recommendations: [String] = []
        if completeness < 0.7 {
            recommendations.append("Consider enabling more health data categories")
        }
        if recency < 0.8 {
            recommendations.append("Sync your health data more frequently")
        }

        return DataQuality(
            completeness: completeness,
            recency: recency,
            accuracy: accuracy,
            consistency: consistency,
            overallScore: overallScore,
            recommendations: recommendations
        )
    }

    static func calculateConfidenceScore(_ dataQuality: DataQuality, _ profileCompleteness: Double) -> Double {
        return (dataQuality.overallScore + profileCompleteness) / 2.0
    }

    private static func calculateDataCompleteness(_ healthData: ComprehensiveHealthData) -> Double {
        var availableMetrics = 0
        var totalMetrics = 10  // Total expected metrics

        if healthData.vitalSigns.heartRate != nil { availableMetrics += 1 }
        if healthData.vitalSigns.bloodPressure != nil { availableMetrics += 1 }
        if healthData.vitalSigns.heartRateVariability != nil { availableMetrics += 1 }
        if healthData.bodyMeasurements.weight != nil { availableMetrics += 1 }
        if healthData.bodyMeasurements.height != nil { availableMetrics += 1 }
        if healthData.bodyMeasurements.bodyMassIndex != nil { availableMetrics += 1 }
        if healthData.sleep.totalDuration > 0 { availableMetrics += 1 }
        if healthData.activity.steps > 0 { availableMetrics += 1 }
        if healthData.activity.exerciseTime > 0 { availableMetrics += 1 }
        if healthData.nutrition.calories > 0 { availableMetrics += 1 }

        return Double(availableMetrics) / Double(totalMetrics)
    }

    private static func calculateDataRecency(_ healthData: ComprehensiveHealthData) -> Double {
        // Check if data is from today or yesterday for recency score
        let now = Date()
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now

        // Simplified: assume data timestamp is recent if available
        return 0.9
    }

    static func calculateProfileCompleteness(_ userProfile: UserProfile) -> Double {
        var completedFields = 0
        let totalFields = 8

        if !userProfile.name.isEmpty { completedFields += 1 }
        if userProfile.age > 0 { completedFields += 1 }
        if !userProfile.gender.isEmpty { completedFields += 1 }
        if !userProfile.healthGoals.isEmpty { completedFields += 1 }
        if !userProfile.exerciseFrequency.isEmpty { completedFields += 1 }
        if !userProfile.medications.isEmpty { completedFields += 1 }
        if !userProfile.chronicConditions.isEmpty { completedFields += 1 }
        if !userProfile.allergies.isEmpty { completedFields += 1 }

        return Double(completedFields) / Double(totalFields)
    }

    static func calculateBMR(bodyMeasurements: BodyMeasurementsData, age: Int, gender: String) -> Double? {
        guard let weight = bodyMeasurements.weight, let height = bodyMeasurements.height else { return nil }

        // Mifflin-St Jeor Equation
        if gender.lowercased() == "male" {
            return 88.362 + (13.397 * weight) + (4.799 * height * 100) - (5.677 * Double(age))
        } else {
            return 447.593 + (9.247 * weight) + (3.098 * height * 100) - (4.330 * Double(age))
        }
    }

    static func analyzeTrends(healthData: ComprehensiveHealthData) -> [HealthTrend] {
        // Placeholder for trend analysis - would need historical data
        return []
    }

    static func generateKeyInsights(
        overallScore: Double, categoryInsights: CategoryInsights, language: String
    ) -> [String] {
        var insights: [String] = []

        if language == "japanese" {
            if overallScore >= 80 {
                insights.append("総合的な健康状態は良好です")
            } else if overallScore >= 60 {
                insights.append("いくつかの改善点があります")
            } else {
                insights.append("健康状態の改善が必要です")
            }

            // Add category-specific insights
            if categoryInsights.cardiovascular.score < 75 {
                insights.append("心血管健康の向上をお勧めします")
            }
            if categoryInsights.sleep.score < 75 {
                insights.append("睡眠の質の改善が重要です")
            }
            if categoryInsights.activity.score < 75 {
                insights.append("日常の活動量を増やしましょう")
            }
            if categoryInsights.metabolic.score < 75 {
                insights.append("代謝健康の管理が大切です")
            }
        } else {
            if overallScore >= 80 {
                insights.append("Your overall health status is good")
            } else if overallScore >= 60 {
                insights.append("There are some areas for improvement")
            } else {
                insights.append("Health improvements are recommended")
            }

            // Add category-specific insights
            if categoryInsights.cardiovascular.score < 75 {
                insights.append("Focus on cardiovascular health improvement")
            }
            if categoryInsights.sleep.score < 75 {
                insights.append("Sleep quality improvement is important")
            }
            if categoryInsights.activity.score < 75 {
                insights.append("Increase daily physical activity")
            }
            if categoryInsights.metabolic.score < 75 {
                insights.append("Metabolic health management is crucial")
            }
        }

        return insights
    }

    static func generateCategoryInsight(category: HealthCategory, language: String) -> String {
        if language == "japanese" {
            switch category {
            case .cardiovascular:
                return "心血管系の健康状態"
            case .sleep:
                return "睡眠の質と回復"
            case .activity:
                return "運動と日常活動"
            case .metabolic:
                return "代謝と体組成"
            default:
                return "健康状態"
            }
        } else {
            switch category {
            case .cardiovascular:
                return "Cardiovascular health status"
            case .sleep:
                return "Sleep quality and recovery"
            case .activity:
                return "Exercise and daily activity"
            case .metabolic:
                return "Metabolism and body composition"
            default:
                return "Health status"
            }
        }
    }

    static func identifyTopPriority(_ categoryInsights: CategoryInsights, userProfile: UserProfile) -> String {
        var lowestScore = categoryInsights.cardiovascular.score
        var topPriority = "cardiovascular"

        if categoryInsights.sleep.score < lowestScore {
            lowestScore = categoryInsights.sleep.score
            topPriority = "sleep"
        }

        if categoryInsights.activity.score < lowestScore {
            lowestScore = categoryInsights.activity.score
            topPriority = "activity"
        }

        if categoryInsights.metabolic.score < lowestScore {
            topPriority = "metabolic"
        }

        return topPriority
    }

    static func generateQuickTip(priority: String, language: String) -> String {
        if language == "japanese" {
            switch priority {
            case "sleep":
                return "今夜は30分早く就寝してみましょう"
            case "activity":
                return "今日は10分多く歩いてみましょう"
            case "cardiovascular":
                return "深呼吸とリラクゼーションを取り入れましょう"
            default:
                return "水分補給と栄養バランスに注意しましょう"
            }
        } else {
            switch priority {
            case "sleep":
                return "Try going to bed 30 minutes earlier tonight"
            case "activity":
                return "Add 10 minutes of walking to your day"
            case "cardiovascular":
                return "Practice deep breathing and relaxation"
            default:
                return "Focus on hydration and balanced nutrition"
            }
        }
    }

    static func generateQuickSummary(score: Double, language: String) -> String {
        if language == "japanese" {
            if score >= 80 {
                return "健康状態は優秀です"
            } else if score >= 60 {
                return "健康状態は良好です"
            } else {
                return "健康状態の改善が推奨されます"
            }
        } else {
            if score >= 80 {
                return "Your health status is excellent"
            } else if score >= 60 {
                return "Your health status is good"
            } else {
                return "Health improvements are recommended"
            }
        }
    }
}
