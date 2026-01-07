/**
 * データソース切り替え設定
 * このフラグを false にするだけで実データに切り替わります
 */
export const DATA_SOURCE_CONFIG = {
  USE_MOCK_DATA: true, // 全体の切り替えマスタースイッチ

  // 個別の切り替え（デバッグ用）
  USE_MOCK_AI: true, // AIアドバイスのMock
  USE_MOCK_WEATHER: true, // 天気データのMock
  USE_MOCK_HEALTHKIT: true, // HealthKitのMock
} as const;

/**
 * 設定の取得（将来的に環境変数から読み込む可能性も考慮）
 */
export const getDataSourceConfig = () => {
  // 将来的にはここで環境変数から読み込む
  // if (process.env.EXPO_PUBLIC_USE_MOCK_DATA === 'false') { ... }

  return DATA_SOURCE_CONFIG;
};

