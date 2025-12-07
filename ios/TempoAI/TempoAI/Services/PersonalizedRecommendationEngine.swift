import Combine
import Foundation

class PersonalizedRecommendationEngine {

    func generateRecommendations(
        categoryInsights: [HealthCategoryInsight],
        riskFactors: [HealthRiskFactor],
        userProfile: UserProfile,
        language: String
    ) -> PersonalizedRecommendations {

        // Identify priority areas
        let priorityCategory = identifyPriorityCategory(
            insights: categoryInsights,
            riskFactors: riskFactors
        )

        // Generate immediate recommendations
        let immediate = generateImmediateRecommendations(
            category: priorityCategory,
            userProfile: userProfile,
            language: language
        )

        // Generate short-term recommendations
        let shortTerm = generateShortTermRecommendations(
            categoryInsights: categoryInsights,
            userProfile: userProfile,
            language: language
        )

        // Generate long-term recommendations
        let longTerm = generateLongTermRecommendations(
            riskFactors: riskFactors,
            userProfile: userProfile,
            language: language
        )

        return PersonalizedRecommendations(
            immediate: immediate,
            shortTerm: shortTerm,
            longTerm: longTerm,
            priority: priorityCategory.rawValue
        )
    }

    private func identifyPriorityCategory(
        insights: [HealthCategoryInsight],
        riskFactors: [HealthRiskFactor]
    ) -> HealthCategory {

        // Find category with lowest score
        let lowestScoreCategory = insights.min { $0.score < $1.score }?.category ?? .cardiovascular

        // Check for high-risk factors
        let highRiskCategories =
            riskFactors
            .filter { $0.riskLevel == .high || $0.riskLevel == .critical }
            .map { $0.category }

        return highRiskCategories.first ?? lowestScoreCategory
    }

    private func generateImmediateRecommendations(
        category: HealthCategory,
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        switch category {
        case .cardiovascular:
            recommendations.append(
                generateCardiovascularRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .sleep:
            recommendations.append(
                generateSleepRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .activity:
            recommendations.append(
                generateActivityRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))

        case .metabolic:
            recommendations.append(
                generateMetabolicRecommendation(
                    type: .immediate,
                    userProfile: userProfile,
                    language: language
                ))
        }

        return recommendations
    }

    private func generateShortTermRecommendations(
        categoryInsights: [HealthCategoryInsight],
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        var recommendations: [ActionableRecommendation] = []

        // Generate recommendations for categories scoring below 75
        for insight in categoryInsights where insight.score < 75 {
            let recommendation = generateCategoryRecommendation(
                category: insight.category,
                type: .shortTerm,
                userProfile: userProfile,
                language: language
            )
            recommendations.append(recommendation)
        }

        return recommendations
    }

    private func generateLongTermRecommendations(
        riskFactors: [HealthRiskFactor],
        userProfile: UserProfile,
        language: String
    ) -> [ActionableRecommendation] {

        return riskFactors.map { riskFactor in
            generateRiskMitigationRecommendation(
                riskFactor: riskFactor,
                userProfile: userProfile,
                language: language
            )
        }
    }

    // MARK: - Category-Specific Recommendation Generators

    private func generateCardiovascularRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "心血管健康の改善",
                    description: "今日から始められる心血管健康の向上策",
                    category: .cardiovascular,
                    priority: .high,
                    timeframe: "今日から",
                    steps: [
                        "10分間の軽い散歩をする",
                        "深呼吸を5分間行う",
                        "水分を十分に摂取する",
                    ],
                    expectedBenefit: "血行改善とストレス軽減"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "心血管フィットネスの向上",
                    description: "持続的な心血管健康の改善計画",
                    category: .cardiovascular,
                    priority: .medium,
                    timeframe: "4-8週間",
                    steps: [
                        "週3回の有酸素運動",
                        "階段利用の習慣化",
                        "定期的な心拍数モニタリング",
                    ],
                    expectedBenefit: "心血管疾患リスクの低減"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Cardiovascular Health Boost",
                    description: "Immediate actions to support heart health",
                    category: .cardiovascular,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Take a 10-minute light walk",
                        "Practice 5 minutes of deep breathing",
                        "Stay well-hydrated",
                    ],
                    expectedBenefit: "Improved circulation and stress reduction"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Cardiovascular Fitness Improvement",
                    description: "Sustainable plan for heart health enhancement",
                    category: .cardiovascular,
                    priority: .medium,
                    timeframe: "4-8 weeks",
                    steps: [
                        "Engage in aerobic exercise 3x per week",
                        "Take stairs instead of elevators",
                        "Monitor heart rate regularly",
                    ],
                    expectedBenefit: "Reduced cardiovascular disease risk"
                )
            }
        }
    }

    private func generateSleepRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "今夜の睡眠改善",
                    description: "今夜からできる睡眠の質向上",
                    category: .sleep,
                    priority: .high,
                    timeframe: "今夜から",
                    steps: [
                        "就寝1時間前にスクリーンタイムを止める",
                        "室温を18-21℃に調整する",
                        "リラクゼーション音楽を聴く",
                    ],
                    expectedBenefit: "睡眠の質と回復の向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "睡眠習慣の最適化",
                    description: "長期的な睡眠の質向上計画",
                    category: .sleep,
                    priority: .medium,
                    timeframe: "2-4週間",
                    steps: [
                        "一定の就寝時間を確立する",
                        "就寝前ルーティンを作る",
                        "カフェイン摂取時間を管理する",
                    ],
                    expectedBenefit: "総合的な健康と認知機能の向上"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Tonight's Sleep Enhancement",
                    description: "Immediate actions for better sleep tonight",
                    category: .sleep,
                    priority: .high,
                    timeframe: "Tonight",
                    steps: [
                        "Stop screen time 1 hour before bed",
                        "Set room temperature to 65-70°F",
                        "Listen to calming music or sounds",
                    ],
                    expectedBenefit: "Improved sleep quality and recovery"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Sleep Habit Optimization",
                    description: "Long-term plan for sleep quality improvement",
                    category: .sleep,
                    priority: .medium,
                    timeframe: "2-4 weeks",
                    steps: [
                        "Establish consistent bedtime",
                        "Create pre-sleep routine",
                        "Manage caffeine intake timing",
                    ],
                    expectedBenefit: "Enhanced overall health and cognitive function"
                )
            }
        }
    }

    private func generateActivityRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "今日の活動量アップ",
                    description: "今日すぐにできる活動量の増加",
                    category: .activity,
                    priority: .high,
                    timeframe: "今日",
                    steps: [
                        "階段を使って移動する",
                        "15分間の散歩をする",
                        "立って仕事や作業を行う",
                    ],
                    expectedBenefit: "エネルギーレベルと気分の向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "活動習慣の構築",
                    description: "持続可能な運動習慣の確立",
                    category: .activity,
                    priority: .medium,
                    timeframe: "4-6週間",
                    steps: [
                        "週150分の中強度運動を目指す",
                        "日常生活に運動を組み込む",
                        "進歩を追跡・記録する",
                    ],
                    expectedBenefit: "長期的な健康と体力の向上"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Today's Activity Boost",
                    description: "Immediate ways to increase daily movement",
                    category: .activity,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Take stairs instead of elevators",
                        "Go for a 15-minute walk",
                        "Stand while working when possible",
                    ],
                    expectedBenefit: "Increased energy levels and mood"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Activity Habit Building",
                    description: "Sustainable exercise routine development",
                    category: .activity,
                    priority: .medium,
                    timeframe: "4-6 weeks",
                    steps: [
                        "Aim for 150 minutes moderate exercise weekly",
                        "Integrate movement into daily routines",
                        "Track and celebrate progress",
                    ],
                    expectedBenefit: "Long-term health and fitness improvements"
                )
            }
        }
    }

    private func generateMetabolicRecommendation(
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        if language == "japanese" {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "代謝の活性化",
                    description: "今日からできる代謝改善策",
                    category: .metabolic,
                    priority: .high,
                    timeframe: "今日",
                    steps: [
                        "水分摂取を増やす",
                        "バランスの取れた食事を心がける",
                        "食後に軽い散歩をする",
                    ],
                    expectedBenefit: "代謝機能とエネルギーの向上"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "代謝健康の最適化",
                    description: "長期的な代謝改善計画",
                    category: .metabolic,
                    priority: .medium,
                    timeframe: "6-12週間",
                    steps: [
                        "栄養バランスの見直し",
                        "適正体重の維持",
                        "定期的な健康チェック",
                    ],
                    expectedBenefit: "生活習慣病の予防と健康寿命の延伸"
                )
            }
        } else {
            switch type {
            case .immediate:
                return ActionableRecommendation(
                    title: "Metabolic Activation",
                    description: "Immediate steps to boost metabolism",
                    category: .metabolic,
                    priority: .high,
                    timeframe: "Today",
                    steps: [
                        "Increase water intake",
                        "Choose balanced, nutritious meals",
                        "Take a light walk after meals",
                    ],
                    expectedBenefit: "Enhanced metabolic function and energy"
                )
            case .shortTerm, .longTerm:
                return ActionableRecommendation(
                    title: "Metabolic Health Optimization",
                    description: "Long-term metabolic improvement strategy",
                    category: .metabolic,
                    priority: .medium,
                    timeframe: "6-12 weeks",
                    steps: [
                        "Review and improve nutritional balance",
                        "Maintain healthy weight range",
                        "Schedule regular health checkups",
                    ],
                    expectedBenefit: "Prevention of lifestyle diseases and longevity"
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func generateCategoryRecommendation(
        category: HealthCategory,
        type: RecommendationType,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        switch category {
        case .cardiovascular:
            return generateCardiovascularRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .sleep:
            return generateSleepRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .activity:
            return generateActivityRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        case .metabolic:
            return generateMetabolicRecommendation(
                type: type,
                userProfile: userProfile,
                language: language
            )
        }
    }

    private func generateRiskMitigationRecommendation(
        riskFactor: HealthRiskFactor,
        userProfile: UserProfile,
        language: String
    ) -> ActionableRecommendation {

        let priority: Priority = {
            switch riskFactor.riskLevel {
            case .critical: return .urgent
            case .high: return .high
            case .moderate: return .medium
            case .low: return .low
            }
        }()

        return ActionableRecommendation(
            title: language == "japanese"
                ? "\(riskFactor.category.rawValue)リスクの軽減"
                : "\(riskFactor.category.rawValue.capitalized) Risk Mitigation",
            description: riskFactor.description,
            category: riskFactor.category,
            priority: priority,
            timeframe: riskFactor.timeframe,
            steps: riskFactor.recommendations,
            expectedBenefit: language == "japanese" ? "健康リスクの軽減" : "Reduced health risk"
        )
    }
}
