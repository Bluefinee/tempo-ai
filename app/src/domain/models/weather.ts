/**
 * 天気関連の型定義
 */

// 気圧トレンド
export type PressureTrend = 'up' | 'stable' | 'down';

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

// WMOコードから天気状態を取得
export const getWeatherCondition = (code: number): string => {
  if (code === 0) return '快晴';
  if (code <= 3) return '晴れ';
  if (code <= 49) return '曇り';
  if (code <= 59) return '霧雨';
  if (code <= 69) return '雨';
  if (code <= 79) return '雪';
  if (code <= 99) return '雷雨';
  return '不明';
};

// 気圧トレンドのラベル
export const getPressureTrendLabel = (trend: PressureTrend): string => {
  switch (trend) {
    case 'up':
      return '上昇中';
    case 'stable':
      return '安定';
    case 'down':
      return '下降中';
  }
};

// 気圧トレンドのアイコン
export const getPressureTrendIcon = (trend: PressureTrend): string => {
  switch (trend) {
    case 'up':
      return '↑';
    case 'stable':
      return '→';
    case 'down':
      return '↓';
  }
};

// UVインデックスのレベル
export type UVLevel = 'low' | 'moderate' | 'high' | 'veryHigh' | 'extreme';

export const getUVLevel = (index: number): UVLevel => {
  if (index <= 2) return 'low';
  if (index <= 5) return 'moderate';
  if (index <= 7) return 'high';
  if (index <= 10) return 'veryHigh';
  return 'extreme';
};

export const getUVLevelLabel = (level: UVLevel): string => {
  switch (level) {
    case 'low':
      return '弱い';
    case 'moderate':
      return '中程度';
    case 'high':
      return '強い';
    case 'veryHigh':
      return '非常に強い';
    case 'extreme':
      return '極端';
  }
};

// 気圧アラートのしきい値
export const PRESSURE_DROP_ALERT_THRESHOLD = -10; // hPa/24h

// 気圧が低下中かどうか
export const isPressureDropping = (trend: PressureTrend): boolean => {
  return trend === 'down';
};
