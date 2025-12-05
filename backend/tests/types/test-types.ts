/**
 * @fileoverview Test-Only Type Definitions
 *
 * テスト専用の型定義。本実装とは分離し、テスト効率性を重視。
 * CLAUDE.mdの分離方針に従い、緩和された型制約を許可。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

// テスト専用：any型の使用を許可（biome overrideで設定済み）

/**
 * テスト用の天気リクエスト型定義
 * 緩和された制約でテストの簡便性を重視
 */
export interface WeatherTestRequest {
  latitude: number
  longitude: number
}

/**
 * テスト用の位置データ型定義
 */
export interface LocationTestData {
  latitude: number
  longitude: number
}

/**
 * テスト用の分析リクエスト型定義
 */
export interface AnalyzeTestRequest {
  location: LocationTestData
}

/**
 * テスト用バリデーション関数（緩和された制約）
 */
export const isWeatherTestRequest = (data: unknown): data is WeatherTestRequest => {
  return (
    typeof data === 'object' &&
    data !== null &&
    'latitude' in data &&
    'longitude' in data &&
    typeof (data as { latitude: unknown; longitude: unknown }).latitude === 'number' &&
    typeof (data as { latitude: unknown; longitude: unknown }).longitude === 'number' &&
    (data as WeatherTestRequest).latitude >= -90 &&
    (data as WeatherTestRequest).latitude <= 90 &&
    (data as WeatherTestRequest).longitude >= -180 &&
    (data as WeatherTestRequest).longitude <= 180 &&
    !Number.isNaN((data as WeatherTestRequest).latitude) &&
    !Number.isNaN((data as WeatherTestRequest).longitude)
  )
}

/**
 * テスト用分析リクエストバリデーション（緩和された制約）
 */
export const isAnalyzeTestRequest = (data: unknown): data is AnalyzeTestRequest => {
  return (
    typeof data === 'object' &&
    data !== null &&
    'location' in data &&
    typeof (data as AnalyzeTestRequest).location === 'object' &&
    (data as AnalyzeTestRequest).location !== null &&
    typeof (data as AnalyzeTestRequest).location.latitude === 'number' &&
    typeof (data as AnalyzeTestRequest).location.longitude === 'number' &&
    (data as AnalyzeTestRequest).location.latitude >= -90 &&
    (data as AnalyzeTestRequest).location.latitude <= 90 &&
    (data as AnalyzeTestRequest).location.longitude >= -180 &&
    (data as AnalyzeTestRequest).location.longitude <= 180 &&
    !Number.isNaN((data as AnalyzeTestRequest).location.latitude) &&
    !Number.isNaN((data as AnalyzeTestRequest).location.longitude)
  )
}

/**
 * モックレスポンス型（テスト用）
 */
export interface TestResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
}

export interface ErrorResponse {
  success: false
  error: string
}

export interface SuccessResponse<T = unknown> {
  success: true
  data: T
}

/**
 * テスト用のモックデータファクトリ
 */
export const createMockWeatherRequest = (
  latitude = 35.6762,
  longitude = 139.6503,
): WeatherTestRequest => ({
  latitude,
  longitude,
})

export const createMockAnalyzeRequest = (
  location = { latitude: 35.6762, longitude: 139.6503 },
): AnalyzeTestRequest => ({
  location,
})
