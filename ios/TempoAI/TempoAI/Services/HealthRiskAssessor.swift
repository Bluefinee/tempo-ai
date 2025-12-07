import Foundation

// MARK: - Health Risk Assessor

/// Analyzes health data to identify potential risk factors and areas of concern
/// Uses evidence-based thresholds and patterns for risk assessment
struct HealthRiskAssessor {
    
    /// Assess health data for potential risk factors
    /// - Parameter data: Comprehensive health data to analyze
    /// - Returns: Array of identified health risk factors
    static func assess(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var riskFactors: [HealthRiskFactor] = []
        
        // Cardiovascular risk assessment
        riskFactors.append(contentsOf: assessCardiovascularRisk(data))
        
        // Metabolic risk assessment
        riskFactors.append(contentsOf: assessMetabolicRisk(data))
        
        // Sleep-related risk assessment
        riskFactors.append(contentsOf: assessSleepRisk(data))
        
        // Activity-related risk assessment
        riskFactors.append(contentsOf: assessActivityRisk(data))
        
        // Stress-related risk assessment
        riskFactors.append(contentsOf: assessStressRisk(data))
        
        return riskFactors.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
    
    // MARK: - Private Assessment Methods
    
    /// Assess cardiovascular health risk factors
    private static func assessCardiovascularRisk(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var risks: [HealthRiskFactor] = []
        
        // Resting heart rate assessment
        if let restingHR = data.vitalSigns.heartRate?.resting {
            if restingHR > 100 {
                risks.append(HealthRiskFactor(
                    category: .cardiovascular,
                    description: "安静時心拍数が高めです（\(Int(restingHR))bpm）",
                    severity: restingHR > 120 ? .high : .moderate,
                    recommendations: [
                        "有酸素運動の継続実施",
                        "ストレス管理の改善",
                        "十分な睡眠の確保"
                    ],
                    dataPoints: ["resting_heart_rate: \(restingHR)"]
                ))
            } else if restingHR < 50 {
                risks.append(HealthRiskFactor(
                    category: .cardiovascular,
                    description: "安静時心拍数が低めです（\(Int(restingHR))bpm）",
                    severity: .low,
                    recommendations: [
                        "運動強度の確認",
                        "体調変化への注意"
                    ],
                    dataPoints: ["resting_heart_rate: \(restingHR)"]
                ))
            }
        }
        
        // Blood pressure assessment
        if let bloodPressure = data.vitalSigns.bloodPressure {
            let category = bloodPressure.category
            
            switch category {
            case .stage2Hypertension:
                risks.append(HealthRiskFactor(
                    category: .cardiovascular,
                    description: "血圧が高めです（\(Int(bloodPressure.systolic))/\(Int(bloodPressure.diastolic))mmHg）",
                    severity: .high,
                    recommendations: [
                        "塩分摂取量の見直し",
                        "定期的な有酸素運動",
                        "体重管理の改善",
                        "医療専門家への相談"
                    ],
                    dataPoints: ["blood_pressure: \(bloodPressure.systolic)/\(bloodPressure.diastolic)"]
                ))
            case .stage1Hypertension:
                risks.append(HealthRiskFactor(
                    category: .cardiovascular,
                    description: "血圧がやや高めです（\(Int(bloodPressure.systolic))/\(Int(bloodPressure.diastolic))mmHg）",
                    severity: .moderate,
                    recommendations: [
                        "食事改善の検討",
                        "適度な運動の増加",
                        "ストレス管理"
                    ],
                    dataPoints: ["blood_pressure: \(bloodPressure.systolic)/\(bloodPressure.diastolic)"]
                ))
            case .elevated:
                risks.append(HealthRiskFactor(
                    category: .cardiovascular,
                    description: "血圧がわずかに高めです（\(Int(bloodPressure.systolic))/\(Int(bloodPressure.diastolic))mmHg）",
                    severity: .low,
                    recommendations: [
                        "生活習慣の見直し",
                        "定期的な測定"
                    ],
                    dataPoints: ["blood_pressure: \(bloodPressure.systolic)/\(bloodPressure.diastolic)"]
                ))
            case .normal:
                break // No risk factor
            }
        }
        
        // Heart Rate Variability assessment
        if let hrv = data.vitalSigns.heartRateVariability {
            if hrv.average < 20 {
                risks.append(HealthRiskFactor(
                    category: .stress,
                    description: "心拍変動が低めです（\(String(format: "%.1f", hrv.average))ms）",
                    severity: .moderate,
                    recommendations: [
                        "ストレス軽減活動",
                        "深呼吸・瞑想の実践",
                        "十分な休息"
                    ],
                    dataPoints: ["hrv_average: \(hrv.average)"]
                ))
            }
        }
        
        return risks
    }
    
    /// Assess metabolic health risk factors
    private static func assessMetabolicRisk(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var risks: [HealthRiskFactor] = []
        
        // BMI assessment
        if let bmiCategory = data.bodyMeasurements.bmiCategory {
            switch bmiCategory {
            case .obese:
                if let bmi = data.bodyMeasurements.bodyMassIndex {
                    risks.append(HealthRiskFactor(
                        category: .metabolic,
                        description: "BMIが高めです（\(String(format: "%.1f", bmi))）",
                        severity: bmi > 35 ? .high : .moderate,
                        recommendations: [
                            "カロリー摂取量の見直し",
                            "有酸素運動の増加",
                            "食事バランスの改善",
                            "専門家への相談"
                        ],
                        dataPoints: ["bmi: \(bmi)"]
                    ))
                }
            case .overweight:
                if let bmi = data.bodyMeasurements.bodyMassIndex {
                    risks.append(HealthRiskFactor(
                        category: .metabolic,
                        description: "体重がやや多めです（BMI: \(String(format: "%.1f", bmi))）",
                        severity: .low,
                        recommendations: [
                            "食事内容の見直し",
                            "運動量の増加",
                            "体重記録の継続"
                        ],
                        dataPoints: ["bmi: \(bmi)"]
                    ))
                }
            case .underweight:
                if let bmi = data.bodyMeasurements.bodyMassIndex {
                    risks.append(HealthRiskFactor(
                        category: .metabolic,
                        description: "体重が少なめです（BMI: \(String(format: "%.1f", bmi))）",
                        severity: .moderate,
                        recommendations: [
                            "栄養摂取量の確認",
                            "筋力トレーニング",
                            "健康的な体重増加"
                        ],
                        dataPoints: ["bmi: \(bmi)"]
                    ))
                }
            case .normal:
                break // No risk factor
            }
        }
        
        // Body fat percentage assessment
        if let bodyFat = data.bodyMeasurements.bodyFatPercentage {
            // Risk thresholds vary by gender and age, using general guidelines
            if bodyFat > 30 { // High body fat
                risks.append(HealthRiskFactor(
                    category: .metabolic,
                    description: "体脂肪率が高めです（\(String(format: "%.1f", bodyFat))%）",
                    severity: bodyFat > 40 ? .high : .moderate,
                    recommendations: [
                        "有酸素運動の増加",
                        "筋力トレーニング",
                        "食事内容の改善"
                    ],
                    dataPoints: ["body_fat_percentage: \(bodyFat)"]
                ))
            }
        }
        
        return risks
    }
    
    /// Assess sleep-related risk factors
    private static func assessSleepRisk(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var risks: [HealthRiskFactor] = []
        
        let sleepData = data.sleep
        let sleepHours = sleepData.totalDuration / 3600
        
        // Sleep duration assessment
        if sleepHours < 6 {
            risks.append(HealthRiskFactor(
                category: .sleep,
                description: "睡眠時間が短いです（\(String(format: "%.1f", sleepHours))時間）",
                severity: sleepHours < 5 ? .high : .moderate,
                recommendations: [
                    "就寝時間の早期化",
                    "睡眠環境の改善",
                    "カフェイン摂取の制限",
                    "就寝前のスクリーン時間削減"
                ],
                dataPoints: ["sleep_duration: \(sleepHours)"]
            ))
        } else if sleepHours > 10 {
            risks.append(HealthRiskFactor(
                category: .sleep,
                description: "睡眠時間が長めです（\(String(format: "%.1f", sleepHours))時間）",
                severity: .low,
                recommendations: [
                    "睡眠の質の確認",
                    "日中の活動量増加",
                    "睡眠習慣の見直し"
                ],
                dataPoints: ["sleep_duration: \(sleepHours)"]
            ))
        }
        
        // Sleep efficiency assessment
        if sleepData.sleepEfficiency < 0.8 {
            risks.append(HealthRiskFactor(
                category: .sleep,
                description: "睡眠効率が低めです（\(String(format: "%.0f", sleepData.sleepEfficiency * 100))%）",
                severity: sleepData.sleepEfficiency < 0.7 ? .moderate : .low,
                recommendations: [
                    "就寝環境の最適化",
                    "就寝前ルーティンの確立",
                    "ストレス管理の改善"
                ],
                dataPoints: ["sleep_efficiency: \(sleepData.sleepEfficiency)"]
            ))
        }
        
        // Deep sleep percentage assessment
        if let deepSleep = sleepData.deepSleep {
            let deepSleepPercentage = (deepSleep / sleepData.totalDuration) * 100
            if deepSleepPercentage < 15 {
                risks.append(HealthRiskFactor(
                    category: .sleep,
                    description: "深い睡眠の割合が少ないです（\(String(format: "%.1f", deepSleepPercentage))%）",
                    severity: deepSleepPercentage < 10 ? .moderate : .low,
                    recommendations: [
                        "規則的な睡眠スケジュール",
                        "就寝前の激しい運動を避ける",
                        "室温の調整",
                        "アルコール摂取の制限"
                    ],
                    dataPoints: ["deep_sleep_percentage: \(deepSleepPercentage)"]
                ))
            }
        }
        
        return risks
    }
    
    /// Assess activity-related risk factors
    private static func assessActivityRisk(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var risks: [HealthRiskFactor] = []
        
        let activity = data.activity
        
        // Daily steps assessment
        if activity.steps < 5000 {
            risks.append(HealthRiskFactor(
                category: .activity,
                description: "歩数が少なめです（\(activity.steps)歩）",
                severity: activity.steps < 3000 ? .moderate : .low,
                recommendations: [
                    "日常的な歩行の増加",
                    "階段の積極的利用",
                    "短時間散歩の習慣化",
                    "活動量記録の継続"
                ],
                dataPoints: ["daily_steps: \(activity.steps)"]
            ))
        }
        
        // Exercise time assessment
        if activity.exerciseTime < 20 {
            risks.append(HealthRiskFactor(
                category: .activity,
                description: "運動時間が短めです（\(activity.exerciseTime)分）",
                severity: activity.exerciseTime < 10 ? .moderate : .low,
                recommendations: [
                    "有酸素運動の追加",
                    "筋力トレーニングの開始",
                    "運動習慣の段階的構築",
                    "楽しめる運動の発見"
                ],
                dataPoints: ["exercise_time: \(activity.exerciseTime)"]
            ))
        }
        
        // Stand hours assessment
        if activity.standHours < 8 {
            risks.append(HealthRiskFactor(
                category: .activity,
                description: "立位時間が短めです（\(activity.standHours)時間）",
                severity: activity.standHours < 6 ? .moderate : .low,
                recommendations: [
                    "定期的な立ち上がり",
                    "座位時間の意識的削減",
                    "スタンディングデスクの検討",
                    "1時間毎の軽い活動"
                ],
                dataPoints: ["stand_hours: \(activity.standHours)"]
            ))
        }
        
        return risks
    }
    
    /// Assess stress-related risk factors
    private static func assessStressRisk(_ data: ComprehensiveHealthData) -> [HealthRiskFactor] {
        
        var risks: [HealthRiskFactor] = []
        
        // Heart Rate Variability trend assessment
        if let hrv = data.vitalSigns.heartRateVariability {
            if hrv.trend == .declining {
                risks.append(HealthRiskFactor(
                    category: .stress,
                    description: "心拍変動が低下傾向にあります",
                    severity: .moderate,
                    recommendations: [
                        "ストレス管理の改善",
                        "深呼吸・瞑想の実践",
                        "リラクゼーション技法",
                        "十分な休息の確保"
                    ],
                    dataPoints: ["hrv_trend: declining"]
                ))
            }
        }
        
        // Sleep quality combined with heart rate patterns
        if let heartRate = data.vitalSigns.heartRate?.average {
            let sleepEfficiency = data.sleep.sleepEfficiency
            
            // High heart rate with poor sleep may indicate stress
            if heartRate > 80 && sleepEfficiency < 0.8 {
                risks.append(HealthRiskFactor(
                    category: .stress,
                    description: "ストレス指標の組み合わせに注意が必要です",
                    severity: .moderate,
                    recommendations: [
                        "ストレス源の特定と対処",
                        "リラクゼーション技法の学習",
                        "睡眠環境の改善",
                        "専門家への相談検討"
                    ],
                    dataPoints: [
                        "average_heart_rate: \(heartRate)",
                        "sleep_efficiency: \(sleepEfficiency)"
                    ]
                ))
            }
        }
        
        return risks
    }
}