import { DATA_SOURCE_CONFIG } from "../config/dataSource";
import { apiClient } from "../api/client";
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_RHYTHM_ANALYSIS,
  MOCK_WEATHER,
  MOCK_AI_RESPONSE,
} from "../constants/mockData";
import type {
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  SimpleWeatherData,
} from "../domain/models";
import type { AdviceRequest, AdviceResponse } from "../api/types";

/**
 * データソースアダプター
 * Mock と実データを統一インターフェースで提供
 */
class DataSourceAdapter {
  /**
   * 睡眠メトリクスを取得
   */
  async getSleepMetrics(): Promise<SleepMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_SLEEP_METRICS;
    }
    // TODO: 実装 - HealthKitService.fetchSleepMetrics()
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * HRVメトリクスを取得
   */
  async getHRVMetrics(): Promise<HRVMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_HRV_METRICS;
    }
    // TODO: 実装 - HealthKitService.fetchHRVMetrics()
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * アクティビティメトリクスを取得
   */
  async getActivityMetrics(): Promise<ActivityMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_ACTIVITY_METRICS;
    }
    // TODO: 実装 - HealthKitService.fetchActivityMetrics()
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * リズム分析を取得
   */
  async getRhythmAnalysis(): Promise<RhythmAnalysis> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return MOCK_RHYTHM_ANALYSIS;
    }
    // TODO: 実装 - HealthKitService.fetchRhythmAnalysis()
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * 天気データを取得
   */
  async getWeather(lat: number, lon: number): Promise<SimpleWeatherData> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
      return MOCK_WEATHER;
    }

    const result = await apiClient.getWeather(lat, lon);
    if (!result.success) {
      throw new Error("Failed to fetch weather data");
    }

    return {
      temp: result.data.temperature,
      condition: result.data.description || "sunny",
      pressure: result.data.pressure,
      pressureTrend: result.data.pressureTrend,
      uv: 0, // TODO: UV index is not available yet
      location: result.data.location || "現在地",
    };
  }

  /**
   * AIアドバイスを取得
   */
  async getAIAdvice(request: AdviceRequest): Promise<AdviceResponse> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_AI) {
      return MOCK_AI_RESPONSE;
    }

    const result = await apiClient.generateAdvice(request);
    if (!result.success) {
      throw new Error("Failed to generate AI advice");
    }

    return result.data;
  }
}

// シングルトンインスタンス
export const dataSourceAdapter = new DataSourceAdapter();
