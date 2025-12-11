import type { AirQualityData } from '../types/domain.js';
import { AirQualityApiError } from '../utils/errors.js';

// =============================================================================
// Constants
// =============================================================================

const TIMEOUT_MS = 5000; // 5秒タイムアウト
const API_BASE_URL = 'https://air-quality-api.open-meteo.com/v1/air-quality';

// =============================================================================
// Types
// =============================================================================

interface AirQualityParams {
  latitude: number;
  longitude: number;
}

interface OpenMeteoAirQualityResponse {
  current: {
    pm2_5: number;
    pm10: number;
    us_aqi: number;
  };
}

// =============================================================================
// HTTP Utilities
// =============================================================================

/**
 * タイムアウト付きFetch実行
 *
 * @param url - リクエストURL
 * @param timeoutMs - タイムアウト時間（ミリ秒）
 * @returns Response Promise
 * @throws AirQualityApiError タイムアウト時
 */
const fetchWithTimeout = async (url: string, timeoutMs: number = TIMEOUT_MS): Promise<Response> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new AirQualityApiError(`Air Quality API request timed out after ${timeoutMs}ms`);
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
 * Open-Meteo Air Quality APIのリクエストURLを構築
 *
 * @param params - 緯度経度パラメータ
 * @returns リクエストURL
 */
const buildAirQualityApiUrl = (params: AirQualityParams): string => {
  const url = new URL(API_BASE_URL);

  url.searchParams.append('latitude', params.latitude.toString());
  url.searchParams.append('longitude', params.longitude.toString());
  url.searchParams.append('current', 'pm2_5,pm10,us_aqi');

  return url.toString();
};

// =============================================================================
// Response Processing
// =============================================================================

/**
 * Open-Meteo APIレスポンスをAirQualityDataに変換
 *
 * @param response - Open-Meteo Air Quality APIレスポンス
 * @returns 変換されたAirQualityData
 * @throws AirQualityApiError データが不正な場合
 */
const transformAirQualityResponse = (response: OpenMeteoAirQualityResponse): AirQualityData => {
  const { current } = response;

  // 必須フィールドの存在確認
  if (!current) {
    throw new AirQualityApiError('Invalid air quality API response: missing current data');
  }

  const { pm2_5: pm25, pm10, us_aqi: aqi } = current;

  // 必須フィールドの値確認
  if (typeof pm25 !== 'number' || typeof aqi !== 'number') {
    throw new AirQualityApiError('Invalid air quality API response: missing required fields');
  }

  // 負の値をチェック
  if (pm25 < 0 || aqi < 0) {
    throw new AirQualityApiError('Invalid air quality API response: negative values detected');
  }

  return {
    aqi,
    pm25,
    pm10: typeof pm10 === 'number' && pm10 >= 0 ? pm10 : undefined,
  };
};

// =============================================================================
// Main Service Function
// =============================================================================

/**
 * Open-Meteo Air Quality APIから大気汚染データを取得
 *
 * @param params - 緯度経度パラメータ
 * @returns 大気汚染データ
 * @throws AirQualityApiError API呼び出し失敗時
 *
 * @example
 * ```typescript
 * const airQualityData = await fetchAirQualityData({
 *   latitude: 35.6895,
 *   longitude: 139.6917
 * });
 * console.log(`AQI: ${airQualityData.aqi}, PM2.5: ${airQualityData.pm25}`);
 * ```
 */
export const fetchAirQualityData = async (params: AirQualityParams): Promise<AirQualityData> => {
  const { latitude, longitude } = params;

  // パラメータバリデーション
  if (latitude < -90 || latitude > 90) {
    throw new AirQualityApiError(`Invalid latitude: ${latitude}. Must be between -90 and 90.`);
  }

  if (longitude < -180 || longitude > 180) {
    throw new AirQualityApiError(`Invalid longitude: ${longitude}. Must be between -180 and 180.`);
  }

  const url = buildAirQualityApiUrl(params);

  console.log(`[AirQuality] Fetching for lat=${latitude}, lon=${longitude}`);

  try {
    const response = await fetchWithTimeout(url);

    if (!response.ok) {
      throw new AirQualityApiError(
        `Air Quality API returned ${response.status}: ${response.statusText}`,
        response.status,
      );
    }

    const data = (await response.json()) as OpenMeteoAirQualityResponse;
    const airQualityData = transformAirQualityResponse(data);

    console.log('[AirQuality] Response:', airQualityData);

    return airQualityData;
  } catch (error) {
    if (error instanceof AirQualityApiError) {
      console.error('[AirQuality] Error:', error.message);
      throw error;
    }

    // 予期しないエラーをAirQualityApiErrorに変換
    const airQualityError = new AirQualityApiError(
      `Air Quality API request failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );

    console.error('[AirQuality] Error:', airQualityError.message);
    throw airQualityError;
  }
};
