/**
 * @fileoverview Weather Data Type Definitions
 *
 * Open-Meteo APIから取得される天気データの型定義。
 * 現在の気象状況と今日の予報データを含み、
 * ヘルス分析での環境要因として活用されます。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { z } from 'zod'

/**
 * Enhanced weather data with air quality and environmental factors
 * Open-Meteo APIから取得される天気データと環境情報
 */
export interface WeatherData {
  /** 現在の気象データ */
  current: {
    /** 観測時刻（ISO 8601形式） */
    time: string
    /** 気温（摂氏） */
    temperature_2m: number
    /** 相対湿度（%） */
    relative_humidity_2m: number
    /** 体感温度（摂氏） */
    apparent_temperature: number
    /** 降水量（mm） */
    precipitation: number
    /** 雨量（mm） */
    rain: number
    /** 天気コード（WMO準拠） */
    weather_code: number
    /** 雲量（%） */
    cloud_cover: number
    /** 風速（m/s、地上10m） */
    wind_speed_10m: number
    /** UV指数（現在値） */
    uv_index?: number
  }
  /** 今日の予報データ */
  daily: {
    /** 予報日（ISO 8601形式の配列） */
    time: string[]
    /** 最高気温（摂氏の配列） */
    temperature_2m_max: number[]
    /** 最低気温（摂氏の配列） */
    temperature_2m_min: number[]
    /** 日の出時刻（配列） */
    sunrise: string[]
    /** 日の入り時刻（配列） */
    sunset: string[]
    /** UV指数の最大値（配列） */
    uv_index_max: number[]
    /** 1日の総降水量（mmの配列） */
    precipitation_sum: number[]
  }
  /** 大気質データ（Optional - from separate API） */
  airQuality?: {
    /** 大気質指数（AQI） */
    aqi: number
    /** 大気質カテゴリ */
    category: AirQualityCategory
    /** PM2.5濃度（μg/m³） */
    pm2_5?: number
    /** PM10濃度（μg/m³） */
    pm10?: number
    /** オゾン濃度（μg/m³） */
    ozone?: number
    /** 二酸化窒素濃度（μg/m³） */
    nitrogen_dioxide?: number
    /** データ取得時刻 */
    timestamp: string
  }
  /** 花粉データ（Optional - seasonal/regional） */
  pollen?: {
    /** 花粉レベル */
    level: PollenLevel
    /** 主要花粉の種類 */
    types: string[]
    /** データ取得時刻 */
    timestamp: string
  }
  /** 健康リスク評価 */
  healthRisk?: {
    /** 全体的な環境健康リスク */
    overall: HealthRiskLevel
    /** UV暴露リスク */
    uvExposure: HealthRiskLevel
    /** 大気質リスク */
    airQuality: HealthRiskLevel
    /** アレルギー/花粉リスク */
    allergen: HealthRiskLevel
    /** 運動適性スコア（0-100） */
    exerciseSuitability: number
  }
}

/** 大気質カテゴリ */
export enum AirQualityCategory {
  GOOD = 'good',
  MODERATE = 'moderate',
  UNHEALTHY_SENSITIVE = 'unhealthy_sensitive',
  UNHEALTHY = 'unhealthy',
  VERY_UNHEALTHY = 'very_unhealthy',
  HAZARDOUS = 'hazardous',
}

/** 花粉レベル */
export enum PollenLevel {
  LOW = 'low',
  MODERATE = 'moderate',
  HIGH = 'high',
  VERY_HIGH = 'very_high',
}

/** 健康リスクレベル */
export enum HealthRiskLevel {
  LOW = 'low',
  MODERATE = 'moderate',
  HIGH = 'high',
  VERY_HIGH = 'very_high',
}

/**
 * Zod schemas for weather data validation
 */

/** Air Quality Category enum schema */
export const AirQualityCategorySchema = z.nativeEnum(AirQualityCategory)

/** Pollen Level enum schema */
export const PollenLevelSchema = z.nativeEnum(PollenLevel)

/** Health Risk Level enum schema */
export const HealthRiskLevelSchema = z.nativeEnum(HealthRiskLevel)

/** Enhanced WeatherData schema with optional environmental data */
export const WeatherDataSchema = z.object({
  current: z.object({
    time: z.string(),
    temperature_2m: z.number(),
    relative_humidity_2m: z.number(),
    apparent_temperature: z.number(),
    precipitation: z.number(),
    rain: z.number(),
    weather_code: z.number(),
    cloud_cover: z.number(),
    wind_speed_10m: z.number(),
    uv_index: z.number().optional(),
  }),
  daily: z.object({
    time: z.array(z.string()),
    temperature_2m_max: z.array(z.number()),
    temperature_2m_min: z.array(z.number()),
    sunrise: z.array(z.string()),
    sunset: z.array(z.string()),
    uv_index_max: z.array(z.number()),
    precipitation_sum: z.array(z.number()),
  }),
  airQuality: z
    .object({
      aqi: z.number(),
      category: AirQualityCategorySchema,
      pm2_5: z.number().optional(),
      pm10: z.number().optional(),
      ozone: z.number().optional(),
      nitrogen_dioxide: z.number().optional(),
      timestamp: z.string(),
    })
    .optional(),
  pollen: z
    .object({
      level: PollenLevelSchema,
      types: z.array(z.string()),
      timestamp: z.string(),
    })
    .optional(),
  healthRisk: z
    .object({
      overall: HealthRiskLevelSchema,
      uvExposure: HealthRiskLevelSchema,
      airQuality: HealthRiskLevelSchema,
      allergen: HealthRiskLevelSchema,
      exerciseSuitability: z.number().min(0).max(100),
    })
    .optional(),
})
