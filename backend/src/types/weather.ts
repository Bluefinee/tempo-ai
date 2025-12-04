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

/**
 * Open-Meteo APIから取得される天気データ
 * 現在の気象データと今日の予報データを含む
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
}
