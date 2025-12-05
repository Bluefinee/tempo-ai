/**
 * @fileoverview Test-specific Request Type Definitions
 *
 * Type definitions and validation functions for test API endpoints only.
 * These types are separate from production types and may have relaxed constraints.
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

interface WeatherTestRequest {
  latitude: number
  longitude: number
}

interface AnalyzeTestRequest {
  location: {
    latitude: number
    longitude: number
  }
}

/**
 * Weather test request validation with relaxed type constraints
 */
export const isWeatherTestRequest = (
  data: unknown,
): data is WeatherTestRequest => {
  return (
    typeof data === 'object' &&
    data !== null &&
    'latitude' in data &&
    'longitude' in data &&
    typeof (data as WeatherTestRequest).latitude === 'number' &&
    typeof (data as WeatherTestRequest).longitude === 'number' &&
    (data as WeatherTestRequest).latitude >= -90 &&
    (data as WeatherTestRequest).latitude <= 90 &&
    (data as WeatherTestRequest).longitude >= -180 &&
    (data as WeatherTestRequest).longitude <= 180 &&
    !Number.isNaN((data as WeatherTestRequest).latitude) &&
    !Number.isNaN((data as WeatherTestRequest).longitude)
  )
}

/**
 * Analyze test request validation with relaxed type constraints
 */
export const isAnalyzeTestRequest = (
  data: unknown,
): data is AnalyzeTestRequest => {
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
