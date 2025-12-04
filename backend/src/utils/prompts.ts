/**
 * @fileoverview AI Prompt Generation Utilities
 *
 * Claude AI分析用のプロンプト生成機能。
 * HealthKitデータ、天気情報、ユーザープロファイルを統合して
 * 構造化されたAI分析用プロンプトを作成します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { HealthData, UserProfile } from '../types/health'
import type { WeatherData } from '../types/weather'

/**
 * プロンプト生成関数のパラメータ型定義
 */
interface PromptParams {
  /** HealthKitから取得したヘルスデータ */
  healthData: HealthData
  /** Open-Meteoから取得した天気データ */
  weather: WeatherData
  /** ユーザープロファイル情報 */
  userProfile: UserProfile
}

/**
 * AI分析用の構造化プロンプトを生成
 *
 * HealthKitデータ、天気情報、ユーザープロファイルを統合して、
 * Claude AIがパーソナライズされた健康アドバイスを生成するための
 * 詳細で構造化されたプロンプトを作成します。
 *
 * プロンプトには以下の要素が含まれます：
 * - ユーザープロファイル（年齢、性別、目標など）
 * - 直近24時間のヘルスデータ
 * - 現在の天気と予報データ
 * - 期待される回答形式（JSON構造）
 * - 分析ガイドライン
 *
 * @param params - プロンプト生成に必要なデータ
 * @param params.healthData - ヘルス指標データ
 * @param params.weather - 気象データ
 * @param params.userProfile - ユーザー基本情報
 * @returns Claude AI用の構造化プロンプト文字列
 */
export const buildPrompt = (params: PromptParams): string => {
  const { healthData, weather, userProfile } = params

  return `
Analyze the following health data and weather conditions to provide personalized health advice for today.

USER PROFILE:
- Age: ${userProfile.age}
- Gender: ${userProfile.gender}
- Goals: ${userProfile.goals.join(', ')}
- Dietary Preferences: ${userProfile.dietaryPreferences || 'None specified'}
- Exercise Habits: ${userProfile.exerciseHabits || 'Not specified'}
- Exercise Frequency: ${userProfile.exerciseFrequency || 'Not specified'}

HEALTH DATA (Last 24 hours):
- Sleep Duration: ${healthData.sleep.duration} hours
- Sleep Quality: Deep ${healthData.sleep.deep}h, REM ${healthData.sleep.rem}h, Light ${healthData.sleep.light}h
- Sleep Efficiency: ${healthData.sleep.efficiency}%
- Heart Rate Variability (HRV): ${healthData.hrv.average} ms (min: ${healthData.hrv.min}, max: ${healthData.hrv.max})
- Resting Heart Rate: ${healthData.heartRate.resting} bpm
- Average Heart Rate: ${healthData.heartRate.average} bpm
- Steps: ${healthData.activity.steps}
- Distance: ${healthData.activity.distance} km
- Active Calories: ${healthData.activity.calories} kcal
- Active Minutes: ${healthData.activity.activeMinutes}

WEATHER CONDITIONS:
- Current Temperature: ${weather.current.temperature_2m}°C
- Feels Like: ${weather.current.apparent_temperature}°C
- Humidity: ${weather.current.relative_humidity_2m}%
- Max Temperature Today: ${weather.daily.temperature_2m_max[0]}°C
- Min Temperature Today: ${weather.daily.temperature_2m_min[0]}°C
- UV Index: ${weather.daily.uv_index_max[0]}
- Precipitation: ${weather.current.precipitation}mm
- Wind Speed: ${weather.current.wind_speed_10m} km/h

Based on this data, provide comprehensive health advice in the following JSON structure. Be specific and actionable:

{
  "theme": "Short theme for today (e.g., 'Recovery Day', 'Energy Boost Day', 'Balanced Activity Day')",
  "summary": "2-3 sentence overview of today's health status and main recommendations based on the data",
  "breakfast": {
    "recommendation": "Specific breakfast recommendation tailored to sleep quality and today's needs",
    "reason": "Why this is recommended based on the health data",
    "examples": ["Example meal 1", "Example meal 2", "Example meal 3"]
  },
  "lunch": {
    "recommendation": "Lunch guidance based on morning activity and afternoon needs",
    "reason": "Connection to health metrics",
    "timing": "Optimal lunch time (e.g., '12:30 PM')",
    "examples": ["Example meal 1", "Example meal 2"],
    "avoid": ["Foods to avoid based on current condition"]
  },
  "dinner": {
    "recommendation": "Dinner guidance for recovery and next day preparation",
    "reason": "Why this supports recovery",
    "timing": "Optimal dinner time (e.g., '6:30 PM')",
    "examples": ["Example meal 1", "Example meal 2"],
    "avoid": ["Late night foods to avoid"]
  },
  "exercise": {
    "recommendation": "Specific exercise type and duration based on HRV and sleep",
    "intensity": "Low/Moderate/High based on recovery status",
    "reason": "Why this intensity is suitable given HRV and sleep data",
    "timing": "Best time to exercise considering weather and circadian rhythm",
    "avoid": ["Exercises to avoid based on recovery status"]
  },
  "hydration": {
    "target": "Total water intake in liters (adjust for weather and activity)",
    "schedule": {
      "morning": "Amount in ml",
      "afternoon": "Amount in ml",
      "evening": "Amount in ml"
    },
    "reason": "Why this hydration level considering humidity and activity"
  },
  "breathing": {
    "technique": "Recommended breathing exercise (e.g., '4-7-8 breathing', 'Box breathing')",
    "duration": "How long to practice (e.g., '5 minutes')",
    "frequency": "How many times today (e.g., '3 times')",
    "instructions": ["Step 1 instruction", "Step 2 instruction", "Step 3 instruction", "Step 4 instruction"]
  },
  "sleep_preparation": {
    "bedtime": "Recommended bedtime based on sleep debt and tomorrow's needs",
    "routine": ["Activity 1 with timing", "Activity 2 with timing", "Activity 3 with timing"],
    "avoid": ["Things to avoid before bed"]
  },
  "weather_considerations": {
    "warnings": ["Weather-related health precautions"],
    "opportunities": ["Weather-related activity opportunities"]
  },
  "priority_actions": [
    "Most important action based on lowest health metric",
    "Second priority action",
    "Third priority action"
  ]
}

Important guidelines:
1. All recommendations must be specific and actionable
2. Consider the interaction between sleep quality, HRV, and activity levels
3. Adjust intensity based on recovery status (low HRV = lower intensity)
4. Factor in weather for outdoor activities and hydration needs
5. Provide exact times and quantities where possible
6. Tailor food recommendations to support the user's goals
`
}
