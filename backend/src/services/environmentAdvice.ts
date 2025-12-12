import type {
  WeatherData,
  AirQualityData,
  EnvironmentAdvice,
  PressureTrend,
} from '../types/domain.js';

// =============================================================================
// Environment Advice Generation
// =============================================================================

/**
 * 環境データから環境アドバイスを生成
 *
 * ルールベースで環境アドバイスを生成する。優先順位順に最大3つまで返す。
 *
 * 優先順位:
 * 1. 大気質（必須）
 * 2. 気温
 * 3. UV
 * 4. 気圧
 * 5. 湿度
 *
 * @param weather - 気象データ
 * @param airQuality - 大気質データ
 * @param pressureTrend - 気圧トレンド
 * @returns 環境アドバイスの配列（最大3つ）
 *
 * @example
 * ```typescript
 * const advice = generateEnvironmentAdvice(
 *   { tempCurrentC: 5, uvIndex: 7, humidityPercent: 25, ... },
 *   { aqi: 45, pm25: 15, pm10: 30 },
 *   'falling'
 * );
 * // Returns: [
 * //   { type: 'air_quality', message: '大気質は良好。屋外運動に適しています' },
 * //   { type: 'temperature', message: '気温が低めです。外出時は暖かい服装を' },
 * //   { type: 'uv', message: 'UV指数が高めです。日焼け止めと帽子の着用を推奨します' }
 * // ]
 * ```
 */
export const generateEnvironmentAdvice = (
  weather: WeatherData,
  airQuality: AirQualityData,
  pressureTrend: PressureTrend,
): EnvironmentAdvice[] => {
  const advice: EnvironmentAdvice[] = [];

  // 1. 大気質（必須）
  const airQualityAdvice = generateAirQualityAdvice(airQuality);
  advice.push(airQualityAdvice);

  // 2. 気温
  const tempAdvice = generateTemperatureAdvice(weather);
  if (tempAdvice) advice.push(tempAdvice);

  // 3. UV
  const uvAdvice = generateUVAdvice(weather);
  if (uvAdvice) advice.push(uvAdvice);

  // 4. 気圧
  const pressureAdvice = generatePressureAdvice(pressureTrend);
  if (pressureAdvice) advice.push(pressureAdvice);

  // 5. 湿度
  const humidityAdvice = generateHumidityAdvice(weather);
  if (humidityAdvice) advice.push(humidityAdvice);

  // 最大3つまで
  return advice.slice(0, 3);
};

// =============================================================================
// Individual Advice Generators
// =============================================================================

/**
 * 大気質アドバイスを生成（必須）
 *
 * @param airQuality - 大気質データ
 * @returns 大気質アドバイス
 */
const generateAirQualityAdvice = (airQuality: AirQualityData): EnvironmentAdvice => {
  const { aqi } = airQuality;

  if (aqi <= 50) {
    return {
      type: 'air_quality',
      message: '大気質は良好。屋外運動に適しています',
    };
  }
  if (aqi <= 100) {
    return {
      type: 'air_quality',
      message: '大気質は普通です。敏感な方は長時間の屋外活動を控えめに',
    };
  }
  return {
    type: 'air_quality',
    message: '大気質が悪化しています。屋外での激しい運動は避けましょう',
  };
};

/**
 * 気温アドバイスを生成
 *
 * @param weather - 気象データ
 * @returns 気温アドバイス（条件に合わない場合はnull）
 */
const generateTemperatureAdvice = (weather: WeatherData): EnvironmentAdvice | null => {
  const { tempCurrentC } = weather;

  if (tempCurrentC < 10) {
    return {
      type: 'temperature',
      message: '気温が低めです。外出時は暖かい服装を',
    };
  }
  if (tempCurrentC > 30) {
    return {
      type: 'temperature',
      message: '気温が高めです。こまめな水分補給と日陰での休憩を',
    };
  }

  return null;
};

/**
 * UVアドバイスを生成
 *
 * @param weather - 気象データ
 * @returns UVアドバイス（条件に合わない場合はnull）
 */
const generateUVAdvice = (weather: WeatherData): EnvironmentAdvice | null => {
  const { uvIndex } = weather;

  if (uvIndex >= 6) {
    return {
      type: 'uv',
      message: 'UV指数が高めです。日焼け止めと帽子の着用を推奨します',
    };
  }
  if (uvIndex >= 3) {
    return {
      type: 'uv',
      message: 'UV指数は中程度。長時間の外出には日焼け止めを',
    };
  }

  return null;
};

/**
 * 気圧アドバイスを生成
 *
 * @param pressureTrend - 気圧トレンド
 * @returns 気圧アドバイス（条件に合わない場合はnull）
 */
const generatePressureAdvice = (pressureTrend: PressureTrend): EnvironmentAdvice | null => {
  if (pressureTrend === 'falling') {
    return {
      type: 'pressure',
      message: '気圧が下降中です。頭痛が出やすい方はお気をつけて',
    };
  }

  return null;
};

/**
 * 湿度アドバイスを生成
 *
 * @param weather - 気象データ
 * @returns 湿度アドバイス（条件に合わない場合はnull）
 */
const generateHumidityAdvice = (weather: WeatherData): EnvironmentAdvice | null => {
  const { humidityPercent } = weather;

  if (humidityPercent < 30) {
    return {
      type: 'humidity',
      message: '乾燥しています。保湿と水分補給を心がけましょう',
    };
  }
  if (humidityPercent > 80) {
    return {
      type: 'humidity',
      message: '湿度が高めです。熱中症に注意しましょう',
    };
  }

  return null;
};
