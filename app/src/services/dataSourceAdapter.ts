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
  RHRMetrics,
  ActivityMetrics,
  RhythmAnalysis,
  SimpleWeatherData,
  HealthTimeRange,
  HealthMetricHistory,
  RealtimeMetrics,
  SleepTimingHistory,
} from "../domain/models";
import type { EnvironmentData } from "../domain/models/environment";
import type { AdviceRequest, AdviceResponse } from "../api/types";
import { DEFAULT_ENVIRONMENT_DATA } from "../constants/environmentConstants";

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

  /**
   * RHRメトリクスを取得
   */
  async getRHRMetrics(): Promise<RHRMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return { value: 62, baseline30d: 60 };
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * リアルタイムメトリクスを取得
   */
  async getRealtimeMetrics(): Promise<RealtimeMetrics> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      const now = new Date();
      return {
        hrv: { value: 55, unit: "ms", baseline: 50, deviationPercent: 10, lastUpdated: now },
        rhr: { value: 62, unit: "bpm", baseline: 60, deviationPercent: 3.3, lastUpdated: now },
        respiratory: { value: 14, unit: "rpm", baseline: 14, deviationPercent: 0, lastUpdated: now },
        spo2: { value: 98, unit: "%", baseline: 98, deviationPercent: 0, lastUpdated: now },
        wristTemp: { value: 36.5, unit: "°C", baseline: 36.5, deviationPercent: 0, lastUpdated: now },
      };
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * HRV履歴を取得
   */
  async getHRVHistory(_timeRange: HealthTimeRange): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return this.generateMockMetricHistory("hrv", 55, 50, 10);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * RHR履歴を取得
   */
  async getRHRHistory(_timeRange: HealthTimeRange): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return this.generateMockMetricHistory("rhr", 62, 55, 5);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * 呼吸数履歴を取得
   */
  async getRespiratoryHistory(_timeRange: HealthTimeRange): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return this.generateMockMetricHistory("respiratory", 14, 12, 2);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * SpO2履歴を取得
   */
  async getSpO2History(_timeRange: HealthTimeRange): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return this.generateMockMetricHistory("spo2", 98, 95, 3);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * 手首温度履歴を取得
   */
  async getWristTempHistory(_timeRange: HealthTimeRange): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      return this.generateMockMetricHistory("wristTemp", 36.5, 36.0, 0.5);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * 睡眠タイミング履歴を取得
   */
  async getSleepTimingHistory(_timeRange: HealthTimeRange): Promise<SleepTimingHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      const samples = [];
      const now = new Date();
      for (let i = 0; i < 30; i++) {
        const date = new Date(now);
        date.setDate(date.getDate() - i);
        const bedtime = new Date(date);
        bedtime.setHours(23, Math.floor(Math.random() * 30), 0);
        const wakeTime = new Date(date);
        wakeTime.setDate(wakeTime.getDate() + 1);
        wakeTime.setHours(7, Math.floor(Math.random() * 30), 0);
        samples.push({
          date,
          bedtime,
          wakeTime,
          durationMinutes: 420 + Math.floor(Math.random() * 60) - 30,
        });
      }
      return { samples };
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * スコア履歴を取得
   */
  async getScoreHistory(
    scoreType: "recovery" | "sleep" | "rhythm" | "energy",
    _timeRange: HealthTimeRange
  ): Promise<HealthMetricHistory> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
      const metricType = `${scoreType}Score` as const;
      return this.generateMockMetricHistory(metricType, 75, 60, 15);
    }
    throw new Error("Real HealthKit integration not yet implemented");
  }

  /**
   * 環境データを取得
   */
  async getEnvironmentData(_latitude: number, _longitude: number): Promise<EnvironmentData> {
    if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
      return DEFAULT_ENVIRONMENT_DATA;
    }
    // TODO: Implement real API call
    return DEFAULT_ENVIRONMENT_DATA;
  }

  /**
   * モックメトリクス履歴を生成するヘルパー
   */
  private generateMockMetricHistory(
    metricType: HealthMetricHistory["metricType"],
    baseValue: number,
    minValue: number,
    variance: number
  ): HealthMetricHistory {
    const samples = [];
    const now = new Date();
    for (let i = 0; i < 60; i++) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      samples.push({
        date,
        value: baseValue + (Math.random() - 0.5) * variance * 2,
      });
    }
    return {
      metricType,
      samples,
      baseline: baseValue,
      typicalRange: {
        min: minValue,
        max: baseValue + variance,
        source: "default" as const,
      },
      lastUpdated: now,
    };
  }
}

// シングルトンインスタンス
export const dataSourceAdapter = new DataSourceAdapter();
