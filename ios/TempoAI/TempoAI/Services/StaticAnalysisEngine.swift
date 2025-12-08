/**
 * @fileoverview Static Analysis Engine
 *
 * 数値計算による即座の健康分析エンジン。
 * AI分析が利用できない場合でも基本的な分析を提供し、
 * 0.5秒以内の応答時間を保証します。
 */

import Foundation
import HealthKit
import os.log

/**
 * 静的分析エンジン
 * 数値計算のみで健康指標を算出
 */
class StaticAnalysisEngine {
    
    // MARK: - Constants
    
    private enum AnalysisConstants {
        static let optimalSleepDuration: Double = 8.0  // 最適睡眠時間（時間）
        static let baselineHRV: Double = 50.0          // HRV基準値（ms）
        static let baselineRHR: Double = 65.0          // 安静時心拍数基準値（bpm）
        static let optimalSteps: Int = 10000           // 最適歩数
    }
    
    // MARK: - Public Methods
    
    /**
     * 包括的な静的分析を実行
     */
    func analyze(
        healthData: HealthData,
        weatherData: WeatherData?,
        previousEnergyLevel: Double? = nil
    ) -> StaticAnalysis {
        let startTime = Date()
        
        // 基本メトリクス計算
        let sleepScore = calculateSleepScore(healthData.sleep)
        let activityScore = calculateActivityScore(healthData.activity)
        let stressScore = calculateStressScore(healthData.hrv)
        
        // エネルギーレベル計算
        let energyLevel = calculateEnergyLevel(
            sleepScore: sleepScore,
            activityScore: activityScore,
            stressScore: stressScore,
            weatherData: weatherData
        )
        
        // バッテリー状態判定
        let batteryState = determineBatteryState(energyLevel)
        
        let elapsed = Date().timeIntervalSince(startTime)
        os_log("Static analysis completed in %{public}.3f seconds", log: .default, type: .info, elapsed)
        
        return StaticAnalysis(
            energyLevel: energyLevel,
            batteryState: batteryState,
            basicMetrics: BasicMetrics(
                sleepScore: sleepScore,
                activityScore: activityScore,
                stressScore: stressScore
            ),
            generatedAt: Date()
        )
    }
    
    // MARK: - Private Methods - Score Calculations
    
    /**
     * 睡眠スコア計算（0-100）
     */
    private func calculateSleepScore(_ sleepData: SleepData) -> Double {
        // 睡眠時間評価（0-70点）
        let durationScore = min(70, (sleepData.duration / AnalysisConstants.optimalSleepDuration) * 70)
        
        // 睡眠効率評価（0-30点）
        let efficiencyScore = sleepData.quality * 30
        
        return min(100, durationScore + efficiencyScore)
    }
    
    /**
     * 活動スコア計算（0-100）
     */
    private func calculateActivityScore(_ activityData: ActivityData) -> Double {
        // 歩数評価（0-60点）
        let stepsScore = min(60, (Double(activityData.steps) / Double(AnalysisConstants.optimalSteps)) * 60)
        
        // 活動時間評価（0-40点）
        let activeMinutesScore = min(40, (Double(activityData.activeMinutes) / 30.0) * 40)
        
        return min(100, stepsScore + activeMinutesScore)
    }
    
    /**
     * ストレススコア計算（0-100、高いほど良い）
     */
    private func calculateStressScore(_ hrvData: HRVData) -> Double {
        // HRV基準値との比較
        let hrvRatio = hrvData.average / AnalysisConstants.baselineHRV
        
        // 理想的な範囲：0.8-1.2
        if hrvRatio >= 0.8 && hrvRatio <= 1.2 {
            return 100
        } else if hrvRatio > 1.2 {
            return max(70, 100 - (hrvRatio - 1.2) * 50)
        } else {
            return max(30, hrvRatio * 125)
        }
    }
    
    /**
     * 総合エネルギーレベル計算
     */
    private func calculateEnergyLevel(
        sleepScore: Double,
        activityScore: Double,
        stressScore: Double,
        weatherData: WeatherData?
    ) -> Double {
        // 重み付け平均（睡眠50%、ストレス30%、活動20%）
        let baseEnergy = (sleepScore * 0.5) + (stressScore * 0.3) + (activityScore * 0.2)
        
        // 環境要因による調整
        let environmentalAdjustment = calculateEnvironmentalAdjustment(weatherData)
        
        return max(0, min(100, baseEnergy + environmentalAdjustment))
    }
    
    /**
     * 環境要因による調整計算
     */
    private func calculateEnvironmentalAdjustment(_ weatherData: WeatherData?) -> Double {
        guard let weather = weatherData else { return 0 }
        
        var adjustment: Double = 0
        
        // 温度調整
        let temperature = weather.current.temperature_2m
        if temperature < 5 || temperature > 30 {
            adjustment -= 5 // 極端な温度はエネルギーを消耗
        }
        
        // 湿度調整
        let humidity = weather.current.relative_humidity_2m
        if humidity < 30 {
            adjustment -= 3 // 乾燥はエネルギーを消耗
        } else if humidity > 80 {
            adjustment -= 2 // 高湿度も負担
        }
        
        // 気圧調整（データがある場合）
        if let pressure = weather.current.surface_pressure {
            let pressureDiff = abs(pressure - 1013.25) // 標準気圧との差
            if pressureDiff > 20 {
                adjustment -= 4 // 気圧変動は体調に影響
            }
        }
        
        return adjustment
    }
    
    /**
     * バッテリー状態の判定
     */
    private func determineBatteryState(_ energyLevel: Double) -> BatteryState {
        switch energyLevel {
        case 0..<20:
            return .critical
        case 20..<40:
            return .low
        case 40..<70:
            return .medium
        case 70...100:
            return .high
        default:
            return .medium
        }
    }
}

// MARK: - Extensions

/**
 * StaticAnalysis用の拡張
 */
extension StaticAnalysis {
    
    /**
     * フォールバック用の最小限の分析結果を生成
     */
    static func fallback() -> StaticAnalysis {
        return StaticAnalysis(
            energyLevel: 50.0,
            batteryState: .medium,
            basicMetrics: BasicMetrics(
                sleepScore: 50.0,
                activityScore: 50.0,
                stressScore: 50.0
            ),
            generatedAt: Date()
        )
    }
    
    /**
     * エネルギーレベルに基づく基本的なメッセージを生成
     */
    func generateBasicMessage() -> String {
        switch batteryState {
        case .critical:
            return "エネルギーが不足しています。十分な休息を取りましょう。"
        case .low:
            return "少し疲れが見えます。無理をせず、ペースを落としてみませんか？"
        case .medium:
            return "バランスの取れた状態です。今日のペースを維持しましょう。"
        case .high:
            return "調子が良いですね！今日は積極的に活動できそうです。"
        }
    }
    
    /**
     * 改善提案を生成
     */
    func generateImprovementSuggestions() -> [String] {
        var suggestions: [String] = []
        
        if basicMetrics.sleepScore < 70 {
            suggestions.append("今夜は早めに休んで、睡眠時間を確保しましょう。")
        }
        
        if basicMetrics.activityScore < 50 {
            suggestions.append("軽い散歩や階段の利用で、活動量を増やしてみませんか？")
        }
        
        if basicMetrics.stressScore < 60 {
            suggestions.append("深呼吸や短い瞑想で、ストレスを軽減しましょう。")
        }
        
        return suggestions.isEmpty ? ["現在の生活リズムを継続しましょう。"] : suggestions
    }
}