import Foundation

// MARK: - Alert Manager

/// Generates health alerts based on data analysis and patterns
/// Creates actionable notifications for users about their health status
struct AlertManager {
    
    /// Generate health alerts from comprehensive health data
    /// - Parameter data: Comprehensive health data to analyze
    /// - Returns: Array of health alerts prioritized by severity
    static func generateAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Critical health alerts (immediate attention)
        alerts.append(contentsOf: generateCriticalAlerts(data))
        
        // Health trend alerts
        alerts.append(contentsOf: generateTrendAlerts(data))
        
        // Goal milestone alerts
        alerts.append(contentsOf: generateMilestoneAlerts(data))
        
        // Environmental alerts
        alerts.append(contentsOf: generateEnvironmentalAlerts(data))
        
        // Motivational alerts
        alerts.append(contentsOf: generateMotivationalAlerts(data))
        
        // Health tip alerts
        alerts.append(contentsOf: generateHealthTipAlerts(data))
        
        // Sort by severity and limit to most important alerts
        return Array(alerts.sorted { $0.severity.rawValue > $1.severity.rawValue }.prefix(10))
    }
    
    // MARK: - Private Alert Generation Methods
    
    /// Generate critical health alerts requiring immediate attention
    private static func generateCriticalAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Blood pressure critical alerts
        if let bloodPressure = data.vitalSigns.bloodPressure {
            if bloodPressure.category == .stage2Hypertension {
                alerts.append(HealthAlert(
                    type: .dataAnomaly,
                    title: "血圧注意",
                    description: "血圧が高めです（\(Int(bloodPressure.systolic))/\(Int(bloodPressure.diastolic))mmHg）。生活習慣の見直しをお考えください。",
                    severity: .critical,
                    actionRequired: true,
                    recommendations: [
                        "塩分摂取を控える",
                        "定期的な運動を心がける",
                        "ストレス管理を改善する",
                        "医療専門家への相談を検討する"
                    ]
                ))
            }
        }
        
        // Heart rate anomaly alerts
        if let heartRate = data.vitalSigns.heartRate {
            if let restingHR = heartRate.resting, restingHR > 120 {
                alerts.append(HealthAlert(
                    type: .dataAnomaly,
                    title: "心拍数注意",
                    description: "安静時心拍数が高めです（\(Int(restingHR))bpm）。体調に変化がないか確認してください。",
                    severity: .warning,
                    actionRequired: true,
                    recommendations: [
                        "深呼吸でリラックスする",
                        "水分補給を行う",
                        "激しい運動を控える",
                        "症状が続く場合は医療機関へ"
                    ]
                ))
            }
        }
        
        // Severe sleep deprivation alert
        let sleepHours = data.sleep.totalDuration / 3600
        if sleepHours < 4 {
            alerts.append(HealthAlert(
                type: .dataAnomaly,
                title: "睡眠不足注意",
                description: "睡眠時間が極端に短いです（\(String(format: "%.1f", sleepHours))時間）。今日は十分な休息を取ることをおすすめします。",
                severity: .critical,
                actionRequired: true,
                recommendations: [
                    "今日は早めに就寝する",
                    "カフェインの摂取を控える",
                    "仮眠を検討する（15-20分程度）",
                    "重要な判断は明日以降に延期する"
                ]
            ))
        }
        
        return alerts
    }
    
    /// Generate trend-based alerts
    private static func generateTrendAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // HRV declining trend alert
        if let hrv = data.vitalSigns.heartRateVariability, hrv.trend == .declining {
            alerts.append(HealthAlert(
                type: .trendAlert,
                title: "ストレス傾向注意",
                description: "心拍変動の低下傾向が見られます。ストレス管理に注意を払ってみませんか？",
                severity: .warning,
                recommendations: [
                    "深呼吸や瞑想を試す",
                    "十分な睡眠を確保する",
                    "適度な運動を取り入れる",
                    "ストレス源の特定と対処"
                ]
            ))
        }
        
        // Sleep efficiency declining alert
        if data.sleep.sleepEfficiency < 0.7 {
            alerts.append(HealthAlert(
                type: .trendAlert,
                title: "睡眠の質注意",
                description: "睡眠効率が低下しています（\(String(format: "%.0f", data.sleep.sleepEfficiency * 100))%）。睡眠環境を見直してみませんか？",
                severity: .warning,
                recommendations: [
                    "就寝前のスクリーン時間を減らす",
                    "寝室の温度を調整する",
                    "就寝前のカフェイン摂取を避ける",
                    "規則的な就寝時間を設定する"
                ]
            ))
        }
        
        // Activity level declining alert
        if data.activity.steps < 3000 {
            alerts.append(HealthAlert(
                type: .trendAlert,
                title: "活動量低下注意",
                description: "今日の歩数が少なめです（\(data.activity.steps)歩）。軽い運動から始めてみませんか？",
                severity: .info,
                recommendations: [
                    "短時間の散歩を取り入れる",
                    "階段を積極的に使う",
                    "家事や掃除で体を動かす",
                    "ストレッチを習慣化する"
                ]
            ))
        }
        
        return alerts
    }
    
    /// Generate milestone achievement alerts
    private static func generateMilestoneAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Step goal achievement
        if data.activity.steps >= 10000 {
            alerts.append(HealthAlert(
                type: .goalMilestone,
                title: "🎉 歩数目標達成！",
                description: "素晴らしい！今日は\(data.activity.steps)歩を達成しました。この調子で続けましょう！",
                severity: .info,
                recommendations: [
                    "達成感を味わう",
                    "明日も同様の活動を心がける",
                    "友人や家族と成果を共有する"
                ]
            ))
        }
        
        // Excellent sleep achievement
        let sleepHours = data.sleep.totalDuration / 3600
        if sleepHours >= 7 && sleepHours <= 9 && data.sleep.sleepEfficiency >= 0.9 {
            alerts.append(HealthAlert(
                type: .goalMilestone,
                title: "😴 質の高い睡眠達成！",
                description: "昨夜は\(String(format: "%.1f", sleepHours))時間の良質な睡眠を取れました。素晴らしいです！",
                severity: .info,
                recommendations: [
                    "この睡眠パターンを継続する",
                    "就寝前ルーティンを記録する",
                    "睡眠環境を維持する"
                ]
            ))
        }
        
        // High health score achievement
        let healthScore = data.overallHealthScore.overall
        if healthScore >= 85 {
            alerts.append(HealthAlert(
                type: .goalMilestone,
                title: "🌟 優秀な健康スコア！",
                description: "健康スコア\(Int(healthScore))点を達成！バランスの取れた健康管理ができています。",
                severity: .info,
                recommendations: [
                    "現在の健康習慣を継続する",
                    "新しい健康目標を設定する",
                    "家族や友人と健康のコツを共有する"
                ]
            ))
        }
        
        return alerts
    }
    
    /// Generate environmental alerts
    private static func generateEnvironmentalAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Note: In a real implementation, this would use actual weather data
        // For now, we'll generate simulated environmental alerts based on health patterns
        
        // Temperature-based activity alert (simulated)
        if data.activity.exerciseTime > 60 {
            alerts.append(HealthAlert(
                type: .environmental,
                title: "🌡️ 運動時の温度注意",
                description: "長時間の運動を行っています。水分補給と体温調節に注意してください。",
                severity: .info,
                recommendations: [
                    "こまめに水分補給する",
                    "涼しい場所で休憩を取る",
                    "体調の変化に注意する",
                    "無理をせず適度に休む"
                ]
            ))
        }
        
        return alerts
    }
    
    /// Generate motivational alerts
    private static func generateMotivationalAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Daily motivation based on current progress
        let healthScore = data.overallHealthScore.overall
        
        if healthScore >= 70 && healthScore < 85 {
            alerts.append(HealthAlert(
                type: .motivational,
                title: "💪 順調に進歩中！",
                description: "健康スコア\(Int(healthScore))点と良好です。もう少しの改善で更なる向上が期待できます！",
                severity: .info,
                recommendations: [
                    "今の習慣を継続する",
                    "一つの分野でさらに改善を図る",
                    "小さな変化から始める"
                ]
            ))
        } else if healthScore < 60 {
            alerts.append(HealthAlert(
                type: .motivational,
                title: "🌱 改善のチャンス！",
                description: "今日は新しい健康習慣を始める絶好の機会です。小さな一歩から始めましょう。",
                severity: .info,
                recommendations: [
                    "一つの小さな目標を設定する",
                    "簡単な運動から始める",
                    "食事の一品を改善する",
                    "十分な水分補給を心がける"
                ]
            ))
        }
        
        // Weekly progress motivation
        if data.activity.steps > 7000 {
            alerts.append(HealthAlert(
                type: .motivational,
                title: "🚶‍♀️ 素晴らしい活動量！",
                description: "\(data.activity.steps)歩と活発に活動されています。健康的な一日ですね！",
                severity: .info,
                recommendations: [
                    "この活動レベルを維持する",
                    "歩数記録を継続する",
                    "運動習慣の楽しさを実感する"
                ]
            ))
        }
        
        return alerts
    }
    
    /// Generate health tip alerts
    private static func generateHealthTipAlerts(_ data: ComprehensiveHealthData) -> [HealthAlert] {
        
        var alerts: [HealthAlert] = []
        
        // Hydration tip based on activity
        if data.activity.activeEnergyBurned > 400 {
            alerts.append(HealthAlert(
                type: .healthTip,
                title: "💧 水分補給のコツ",
                description: "活発に活動されていますね！運動後の水分補給は回復を助けます。",
                severity: .info,
                recommendations: [
                    "運動後15分以内に水分補給",
                    "少量ずつこまめに飲む",
                    "電解質補給も検討する",
                    "尿の色で水分状態を確認"
                ]
            ))
        }
        
        // Recovery tip based on HRV
        if let hrv = data.vitalSigns.heartRateVariability, hrv.average < 30 {
            alerts.append(HealthAlert(
                type: .healthTip,
                title: "😌 回復のヒント",
                description: "体の回復を促すために、今日はリラックスを重視してみませんか？",
                severity: .info,
                recommendations: [
                    "深呼吸を5分間行う",
                    "ぬるめのお風呂に入る",
                    "軽いストレッチをする",
                    "好きな音楽を聞く"
                ]
            ))
        }
        
        // Sleep optimization tip
        if data.sleep.sleepEfficiency < 0.8 && data.sleep.sleepEfficiency >= 0.7 {
            alerts.append(HealthAlert(
                type: .healthTip,
                title: "🌙 睡眠の質向上のヒント",
                description: "睡眠効率が\(String(format: "%.0f", data.sleep.sleepEfficiency * 100))%です。少しの工夫でさらに改善できそうです。",
                severity: .info,
                recommendations: [
                    "就寝前1時間はスマホを見ない",
                    "寝室の温度を18-20度に保つ",
                    "就寝時間を一定にする",
                    "寝る前の軽いストレッチ"
                ]
            ))
        }
        
        // Nutrition timing tip
        if data.activity.exerciseTime > 30 {
            alerts.append(HealthAlert(
                type: .healthTip,
                title: "🍎 栄養タイミングのヒント",
                description: "運動後の栄養補給は筋肉の回復と成長に重要です。",
                severity: .info,
                recommendations: [
                    "運動後30分以内にタンパク質摂取",
                    "炭水化物で筋グリコーゲンを補充",
                    "抗酸化物質豊富な食品を選ぶ",
                    "適切なタイミングでの食事"
                ]
            ))
        }
        
        return alerts
    }
}