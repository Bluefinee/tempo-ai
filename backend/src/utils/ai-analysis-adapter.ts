/**
 * @fileoverview AI Analysis Data Adapter
 *
 * 既存のHealthDataとWeatherDataをAI分析用の構造に変換する
 * アダプター関数群。データの一貫性とタイプセーフティを保証します。
 */

import type { AIAnalysisRequest, FocusTagType } from '../types/ai-analysis'
import type { HealthData } from '../types/health'
import type { WeatherData } from '../types/weather'

// 基準値定数
const BASELINE_HRV_MS = 50 // 30歳健康成人の平均HRV
const BASELINE_RHR_BPM = 65 // 成人平均安静時心拍数
const BASELINE_RESPIRATORY_RATE = 16 // 基準呼吸数

/**
 * HealthDataからBiologicalContextを生成
 */
export const createBiologicalContext = (
  healthData: HealthData,
): AIAnalysisRequest['biologicalContext'] => {
  const hrvStatus = healthData.hrv.average - BASELINE_HRV_MS
  const rhrStatus = healthData.heartRate.resting - BASELINE_RHR_BPM

  // 睡眠時間を分単位に変換（既存データは時間単位）
  const sleepDeepMinutes = Math.round(healthData.sleep.deep * 60)
  const sleepRemMinutes = Math.round(healthData.sleep.rem * 60)

  // 呼吸数の推定（HRVから算出）
  const estimatedRespiratoryRate =
    BASELINE_RESPIRATORY_RATE + (hrvStatus < 0 ? 2 : -1)

  return {
    hrvStatus,
    rhrStatus,
    sleepDeep: sleepDeepMinutes,
    sleepRem: sleepRemMinutes,
    respiratoryRate: Math.max(10, Math.min(24, estimatedRespiratoryRate)),
    steps: healthData.activity.steps,
    activeCalories: healthData.activity.calories,
  }
}

/**
 * WeatherDataからEnvironmentalContextを生成
 */
export const createEnvironmentalContext = (
  currentWeather: WeatherData,
): AIAnalysisRequest['environmentalContext'] => {
  // 気圧変化の計算（前回データがある場合）
  const pressureTrend = 0
  // TODO: Open-Meteo APIから気圧データを取得して計算

  return {
    pressureTrend,
    humidity: currentWeather.current.relative_humidity_2m,
    feelsLike:
      currentWeather.current.apparent_temperature ||
      currentWeather.current.temperature_2m,
    uvIndex: currentWeather.current.uv_index || 0,
    weatherCode: currentWeather.current.weather_code,
  }
}

/**
 * エネルギーレベルの計算
 * 既存のBatteryEngineロジックを再実装
 */
export const calculateEnergyLevel = (
  healthData: HealthData,
  environmentalContext: AIAnalysisRequest['environmentalContext'],
): number => {
  // 睡眠スコア（0-100）
  const sleepScore = Math.min(
    100,
    (healthData.sleep.duration / 8.0) * healthData.sleep.efficiency,
  )

  // HRVスコア（0-100）
  const hrvRatio = Math.max(
    0.5,
    Math.min(1.5, healthData.hrv.average / BASELINE_HRV_MS),
  )
  const hrvScore = hrvRatio * 100

  // 基本エネルギー（睡眠60% + HRV40%）
  const baseEnergy = sleepScore * 0.6 + hrvScore * 0.4

  // 環境要因による調整
  let environmentalPenalty = 0
  if (environmentalContext.pressureTrend < -3) environmentalPenalty += 5 // 気圧低下
  if (environmentalContext.humidity < 30) environmentalPenalty += 3 // 乾燥
  if (environmentalContext.feelsLike > 30) environmentalPenalty += 4 // 高温

  return Math.max(0, Math.min(100, baseEnergy - environmentalPenalty))
}

/**
 * バッテリートレンドの計算
 */
export const calculateBatteryTrend = (
  currentEnergy: number,
  previousEnergy?: number,
): AIAnalysisRequest['batteryTrend'] => {
  if (!previousEnergy) return 'stable'

  const energyDiff = currentEnergy - previousEnergy
  if (energyDiff > 5) return 'recovering'
  if (energyDiff < -5) return 'declining'
  return 'stable'
}

/**
 * 時間帯の計算
 */
export const calculateTimeOfDay = (
  date: Date = new Date(),
): AIAnalysisRequest['userContext']['timeOfDay'] => {
  const hour = date.getHours()
  if (hour >= 6 && hour < 12) return 'morning'
  if (hour >= 12 && hour < 17) return 'afternoon'
  if (hour >= 17 && hour < 21) return 'evening'
  return 'night'
}

/**
 * 完全なAIAnalysisRequestを生成
 */
export const createAIAnalysisRequest = (
  healthData: HealthData,
  weatherData: WeatherData,
  activeTags: FocusTagType[],
  userMode: 'standard' | 'athlete' = 'standard',
  language: 'ja' | 'en' = 'ja',
  previousEnergy?: number,
): AIAnalysisRequest => {
  const biologicalContext = createBiologicalContext(healthData)
  const environmentalContext = createEnvironmentalContext(weatherData)
  const batteryLevel = calculateEnergyLevel(healthData, environmentalContext)
  const batteryTrend = calculateBatteryTrend(batteryLevel, previousEnergy)

  return {
    batteryLevel,
    batteryTrend,
    biologicalContext,
    environmentalContext,
    userContext: {
      activeTags,
      timeOfDay: calculateTimeOfDay(),
      language,
      userMode,
    },
  }
}

interface StaticAnalysisResult {
  energyLevel: number
  batteryState: 'low' | 'medium' | 'high' | 'critical'
  basicMetrics: {
    sleepScore: number
    activityScore: number
    stressScore: number
  }
  generatedAt: string
}

/**
 * 静的分析結果を生成
 * AI分析が利用できない場合のフォールバック
 */
export const createStaticAnalysis = (
  healthData: HealthData,
  environmentalContext: AIAnalysisRequest['environmentalContext'],
): StaticAnalysisResult => {
  const energyLevel = calculateEnergyLevel(healthData, environmentalContext)

  // バッテリー状態の判定
  const batteryState: 'low' | 'medium' | 'high' | 'critical' =
    energyLevel < 20
      ? 'critical'
      : energyLevel < 40
        ? 'low'
        : energyLevel < 70
          ? 'medium'
          : 'high'

  // 基本メトリクスの計算
  const sleepScore = Math.min(
    100,
    (healthData.sleep.duration / 8.0) * healthData.sleep.efficiency,
  )
  const activityScore = Math.min(100, (healthData.activity.steps / 10000) * 100)
  const stressScore = Math.max(
    0,
    100 - Math.abs(healthData.hrv.average - BASELINE_HRV_MS) * 2,
  )

  return {
    energyLevel,
    batteryState,
    basicMetrics: {
      sleepScore: Math.round(sleepScore),
      activityScore: Math.round(activityScore),
      stressScore: Math.round(stressScore),
    },
    generatedAt: new Date().toISOString(),
  }
}
