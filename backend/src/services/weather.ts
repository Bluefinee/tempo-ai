import type { WeatherData, HourlyPressureData } from '../types/domain.js';
import { WeatherApiError } from '../utils/errors.js';

// =============================================================================
// Constants
// =============================================================================

const TIMEOUT_MS = 5000; // 5秒タイムアウト
const API_BASE_URL = 'https://api.open-meteo.com/v1/forecast';

// =============================================================================
// Types
// =============================================================================

interface WeatherParams {
  latitude: number;
  longitude: number;
  includeHourlyPressure?: boolean; // Phase 10: 過去3時間の気圧データを取得するか
}

interface OpenMeteoWeatherResponse {
  current: {
    temperature_2m: number;
    relative_humidity_2m: number;
    weather_code: number;
    surface_pressure: number;
  };
  daily: {
    temperature_2m_max: number[];
    temperature_2m_min: number[];
    uv_index_max: number[];
    precipitation_probability_max: number[];
  };
  hourly?: {
    // Phase 10: 時間別データ
    time: string[];
    surface_pressure: number[];
  };
}

// =============================================================================
// Weather Code Mapping
// =============================================================================

/**
 * Weather Codeから日本語天気への変換マップ
 * https://open-meteo.com/en/docs
 */
const WEATHER_CODE_MAP: Record<number, string> = {
  0: '快晴',
  1: '晴れ',
  2: '晴れ',
  3: '晴れ',
  45: '霧',
  48: '霧',
  51: '霧雨',
  53: '霧雨',
  55: '霧雨',
  61: '雨',
  63: '雨',
  65: '雨',
  71: '雪',
  73: '雪',
  75: '雪',
  77: '霧雪',
  80: 'にわか雨',
  81: 'にわか雨',
  82: '激しいにわか雨',
  85: 'にわか雪',
  86: '激しいにわか雪',
  95: '雷雨',
  96: '雷雨',
  99: '激しい雷雨',
};

/**
 * Weather Codeを日本語天気に変換
 *
 * @param weatherCode - Open-Meteo Weather Code
 * @returns 日本語天気文字列
 */
const convertWeatherCodeToCondition = (weatherCode: number): string => {
  return WEATHER_CODE_MAP[weatherCode] || '不明';
};

// =============================================================================
// HTTP Utilities
// =============================================================================

/**
 * タイムアウト付きFetch実行
 *
 * @param url - リクエストURL
 * @param timeoutMs - タイムアウト時間（ミリ秒）
 * @returns Response Promise
 * @throws WeatherApiError タイムアウト時
 */
const fetchWithTimeout = async (url: string, timeoutMs: number = TIMEOUT_MS): Promise<Response> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new WeatherApiError(`Weather API request timed out after ${timeoutMs}ms`);
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
};

// =============================================================================
// API Request Building
// =============================================================================

/**
 * Open-Meteo Weather APIのリクエストURLを構築
 *
 * @param params - 緯度経度パラメータ
 * @returns リクエストURL
 */
const buildWeatherApiUrl = (params: WeatherParams): string => {
  const url = new URL(API_BASE_URL);

  url.searchParams.append('latitude', params.latitude.toString());
  url.searchParams.append('longitude', params.longitude.toString());
  url.searchParams.append(
    'current',
    'temperature_2m,relative_humidity_2m,weather_code,surface_pressure',
  );
  url.searchParams.append(
    'daily',
    'temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max',
  );

  // Phase 10: 過去3時間の気圧データを取得
  if (params.includeHourlyPressure) {
    url.searchParams.append('hourly', 'surface_pressure');
    url.searchParams.append('past_hours', '3');
  }

  url.searchParams.append('timezone', 'Asia/Tokyo');

  return url.toString();
};

// =============================================================================
// Response Processing
// =============================================================================

/**
 * Open-Meteo APIレスポンスをWeatherDataに変換
 *
 * @param response - Open-Meteo APIレスポンス
 * @param includeHourlyPressure - 過去の気圧データを含めるか
 * @returns 変換されたWeatherData（オプションで過去気圧データ含む）
 * @throws WeatherApiError データが不正な場合
 */
const transformWeatherResponse = (
  response: OpenMeteoWeatherResponse,
  includeHourlyPressure = false,
): WeatherData & { hourlyPressure?: HourlyPressureData } => {
  const { current, daily } = response;

  // 必須フィールドの存在確認
  if (!current || !daily) {
    throw new WeatherApiError('Invalid weather API response: missing current or daily data');
  }

  const {
    temperature_2m: tempCurrentC,
    relative_humidity_2m: humidityPercent,
    weather_code: weatherCode,
    surface_pressure: pressureHpa,
  } = current;

  const {
    temperature_2m_max: tempMaxArray,
    temperature_2m_min: tempMinArray,
    uv_index_max: uvIndexArray,
    precipitation_probability_max: precipitationArray,
  } = daily;

  // 配列データの存在確認
  if (
    tempMaxArray?.[0] === undefined ||
    tempMinArray?.[0] === undefined ||
    uvIndexArray?.[0] === undefined ||
    precipitationArray?.[0] === undefined
  ) {
    throw new WeatherApiError('Invalid weather API response: missing daily forecast data');
  }

  const result: WeatherData = {
    condition: convertWeatherCodeToCondition(weatherCode),
    tempCurrentC,
    tempMaxC: tempMaxArray[0],
    tempMinC: tempMinArray[0],
    humidityPercent,
    uvIndex: uvIndexArray[0],
    pressureHpa,
    precipitationProbability: precipitationArray[0],
  };

  // Phase 10: 時間別気圧データの追加
  if (includeHourlyPressure && response.hourly) {
    const pressureArray: number[] = response.hourly.surface_pressure;
    // 最初のデータポイントが3時間前のデータ
    const pressure3hAgo: number | undefined = pressureArray?.[0];

    if (pressure3hAgo !== undefined) {
      return {
        ...result,
        hourlyPressure: { pressure3hAgo },
      };
    }
  }

  return result;
};

// =============================================================================
// Main Service Function
// =============================================================================

/**
 * Open-Meteo Weather APIから気象データを取得
 *
 * @param params - 緯度経度パラメータ（includeHourlyPressure: 過去3時間の気圧データを含むか）
 * @returns 気象データ（オプションで過去気圧データ含む）
 * @throws WeatherApiError API呼び出し失敗時
 *
 * @example
 * ```typescript
 * // 基本的な使用法
 * const weatherData = await fetchWeatherData({
 *   latitude: 35.6895,
 *   longitude: 139.6917
 * });
 * console.log(weatherData.condition); // "晴れ"
 *
 * // 過去の気圧データを含める（Phase 10）
 * const weatherDataWithPressure = await fetchWeatherData({
 *   latitude: 35.6895,
 *   longitude: 139.6917,
 *   includeHourlyPressure: true
 * });
 * console.log(weatherDataWithPressure.hourlyPressure?.pressure3hAgo); // 1015
 * ```
 */
export const fetchWeatherData = async (
  params: WeatherParams,
): Promise<WeatherData & { hourlyPressure?: HourlyPressureData }> => {
  const { latitude, longitude } = params;

  // パラメータバリデーション
  if (latitude < -90 || latitude > 90) {
    throw new WeatherApiError(`Invalid latitude: ${latitude}. Must be between -90 and 90.`);
  }

  if (longitude < -180 || longitude > 180) {
    throw new WeatherApiError(`Invalid longitude: ${longitude}. Must be between -180 and 180.`);
  }

  const url = buildWeatherApiUrl(params);

  console.log(`[Weather] Fetching for lat=${latitude}, lon=${longitude}`);

  try {
    const response = await fetchWithTimeout(url);

    if (!response.ok) {
      throw new WeatherApiError(
        `Weather API returned ${response.status}: ${response.statusText}`,
        response.status,
      );
    }

    const data = (await response.json()) as OpenMeteoWeatherResponse;
    const weatherData = transformWeatherResponse(data, params.includeHourlyPressure);

    console.log('[Weather] Response:', weatherData);

    return weatherData;
  } catch (error) {
    if (error instanceof WeatherApiError) {
      console.error('[Weather] Error:', error.message);
      throw error;
    }

    // 予期しないエラーをWeatherApiErrorに変換
    const weatherError = new WeatherApiError(
      `Weather API request failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );

    console.error('[Weather] Error:', weatherError.message);
    throw weatherError;
  }
};
