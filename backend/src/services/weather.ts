/**
 * @fileoverview Weather Data Service
 *
 * Open-Meteo APIを使用した天気データ取得サービス。
 * 位置情報（緯度・経度）を基に現在および今日の天気情報を取得し、
 * ヘルス分析に必要な気象データを提供します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { WeatherData } from '../types/weather'
import { APIError } from '../utils/errors'

/**
 * 指定位置の天気データを取得
 *
 * Open-Meteo APIを使用して、現在の天気情報と今日の予報を取得します。
 * 取得するデータには気温、湿度、降水量、UV指数などが含まれ、
 * これらはAI分析でのヘルスアドバイス生成に活用されます。
 *
 * @param latitude - 緯度座標
 * @param longitude - 経度座標
 * @returns 天気データ（現在と今日の予報）
 * @throws {APIError} Open-Meteo APIが利用できない場合
 * @throws {APIError} ネットワークエラーまたは無効な座標の場合
 */
export const getWeather = async (
  latitude: number,
  longitude: number,
): Promise<WeatherData> => {
  const url =
    'https://api.open-meteo.com/v1/forecast?' +
    `latitude=${latitude}&longitude=${longitude}&` +
    'current=temperature_2m,relative_humidity_2m,apparent_temperature,' +
    'precipitation,rain,weather_code,cloud_cover,wind_speed_10m&' +
    'daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,' +
    'uv_index_max,precipitation_sum&' +
    'timezone=auto'

  try {
    const response = await fetch(url)

    if (!response.ok) {
      throw new APIError(
        `Weather API failed with status ${response.status}`,
        503,
        'WEATHER_API_ERROR',
      )
    }

    const data = (await response.json()) as WeatherData
    return data
  } catch (error) {
    if (error instanceof APIError) {
      throw error
    }

    throw new APIError(
      'Failed to fetch weather data',
      503,
      'WEATHER_FETCH_ERROR',
    )
  }
}
