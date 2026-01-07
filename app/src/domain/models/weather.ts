/**
 * 天気関連の型定義
 */

// 気圧トレンド
export type PressureTrend = "rising" | "stable" | "falling";

// 天気データ
export interface WeatherData {
  temperature: number; // °C
  humidity: number; // %
  pressure: number; // hPa
  pressureTrend: PressureTrend;
  weatherCode: number; // WMO weather code
  uvIndexMax: number;
  sunrise?: string; // ISO8601
  sunset?: string; // ISO8601
  location: string;
}

// 簡易天気データ（ホーム画面用）
export interface SimpleWeatherData {
  temp: number;
  condition: string;
  pressure: number;
  pressureTrend: PressureTrend;
  uv: number;
  location: string;
}

// 空気質データ
export interface AirQuality {
  pm25: number;
  aqi: number; // US AQI
}

// 位置情報
export interface Location {
  latitude: number;
  longitude: number;
  city: string;
}

/**
 * WMOコードから天気状態を取得
 * @param code WMO天気コード
 * @returns 天気状態の文字列
 */
export const getWeatherCondition = (code: number): string => {
  if (code === 0) return "快晴";
  if (code <= 3) return "晴れ";
  if (code <= 49) return "曇り";
  if (code <= 59) return "霧雨";
  if (code <= 69) return "雨";
  if (code <= 79) return "雪";
  if (code <= 99) return "雷雨";
  return "不明";
};

/**
 * 気圧トレンドのラベルを取得
 * @param trend 気圧トレンド
 * @returns ラベル文字列
 */
export const getPressureTrendLabel = (trend: PressureTrend): string => {
  switch (trend) {
    case "rising":
      return "上昇中";
    case "stable":
      return "安定";
    case "falling":
      return "下降中";
  }
};

/**
 * 気圧トレンドのアイコンを取得
 * @param trend 気圧トレンド
 * @returns アイコン文字列
 */
export const getPressureTrendIcon = (trend: PressureTrend): string => {
  switch (trend) {
    case "rising":
      return "↑";
    case "stable":
      return "→";
    case "falling":
      return "↓";
  }
};

// UVインデックスのレベル
export type UVLevel = "low" | "moderate" | "high" | "veryHigh" | "extreme";

/**
 * UVインデックスからレベルを取得
 * @param index UVインデックス値
 * @returns UVレベル
 */
export const getUVLevel = (index: number): UVLevel => {
  if (index <= 2) return "low";
  if (index <= 5) return "moderate";
  if (index <= 7) return "high";
  if (index <= 10) return "veryHigh";
  return "extreme";
};

/**
 * UVレベルのラベルを取得
 * @param level UVレベル
 * @returns ラベル文字列
 */
export const getUVLevelLabel = (level: UVLevel): string => {
  switch (level) {
    case "low":
      return "弱い";
    case "moderate":
      return "中程度";
    case "high":
      return "強い";
    case "veryHigh":
      return "非常に強い";
    case "extreme":
      return "極端";
  }
};

// 気圧アラートのしきい値
export const PRESSURE_DROP_ALERT_THRESHOLD = -10; // hPa/24h

/**
 * 気圧が低下中かどうかを判定
 * @param trend 気圧トレンド
 * @returns 低下中の場合true
 */
export const isPressureDropping = (trend: PressureTrend): boolean => {
  return trend === "falling";
};
