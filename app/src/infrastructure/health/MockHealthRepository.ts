/**
 * Mock Health Repository
 * Returns mock data for development and testing
 */

import {
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  HealthMetrics,
} from '../../domain/models';
import {
  MOCK_SLEEP_METRICS,
  MOCK_HRV_METRICS,
  MOCK_ACTIVITY_METRICS,
  MOCK_HEALTH_METRICS,
} from '../../constants/mockData';
import { HealthRepository, HealthAuthorizationStatus } from './HealthRepository';

export class MockHealthRepository implements HealthRepository {
  private isAuthorized = false;
  private simulateDelay = true;

  /**
   * MockHealthRepositoryのコンストラクタ
   * @param options オプション設定
   * @param options.simulateDelay 遅延をシミュレートするかどうか
   */
  constructor(options?: { simulateDelay?: boolean }) {
    this.simulateDelay = options?.simulateDelay ?? true;
  }

  private async delay(ms: number): Promise<void> {
    if (this.simulateDelay) {
      await new Promise((resolve) => setTimeout(resolve, ms));
    }
  }

  /**
   * 認証状態を取得
   * @returns 認証状態
   */
  async getAuthorizationStatus(): Promise<HealthAuthorizationStatus> {
    return {
      isAuthorized: this.isAuthorized,
      canRequestAuthorization: true,
    };
  }

  /**
   * 認証をリクエスト
   * @returns 認証が成功した場合true
   */
  async requestAuthorization(): Promise<boolean> {
    await this.delay(500);
    this.isAuthorized = true;
    return true;
  }

  /**
   * 今日のメトリクスを取得
   * @returns ヘルスメトリクス
   */
  async fetchTodayMetrics(): Promise<HealthMetrics> {
    await this.delay(300);
    return {
      ...MOCK_HEALTH_METRICS,
      date: new Date(),
    };
  }

  async fetchSleepMetrics(_date: Date): Promise<SleepMetrics | null> {
    await this.delay(200);
    return MOCK_SLEEP_METRICS;
  }

  async fetchHRVMetrics(_date: Date): Promise<HRVMetrics | null> {
    await this.delay(200);
    return MOCK_HRV_METRICS;
  }

  async fetchActivityMetrics(_date: Date): Promise<ActivityMetrics | null> {
    await this.delay(200);
    return MOCK_ACTIVITY_METRICS;
  }

  /**
   * 睡眠履歴を取得
   * @param days 取得する日数
   * @returns 睡眠メトリクスの配列
   */
  async fetchSleepHistory(days: number): Promise<SleepMetrics[]> {
    await this.delay(300);

    // Generate mock sleep history
    const history: SleepMetrics[] = [];
    const baseDate = new Date();

    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);

      // Add some variation to the mock data
      const variation = Math.random() * 0.2 - 0.1; // -10% to +10%

      // Create separate date objects for bedtime and wakeTime to avoid mutation
      const bedtimeDate = new Date(date);
      bedtimeDate.setHours(23, Math.floor(Math.random() * 30), 0, 0);
      
      const wakeTimeDate = new Date(date);
      wakeTimeDate.setHours(6, 30 + Math.floor(Math.random() * 30), 0, 0);

      history.push({
        bedtime: bedtimeDate,
        wakeTime: wakeTimeDate,
        durationMinutes: Math.round(MOCK_SLEEP_METRICS.durationMinutes * (1 + variation)),
        deepSleepMinutes: Math.round(MOCK_SLEEP_METRICS.deepSleepMinutes * (1 + variation)),
        remSleepMinutes: Math.round(MOCK_SLEEP_METRICS.remSleepMinutes * (1 + variation)),
      });
    }

    return history;
  }

  /**
   * ヘルスリポジトリが利用可能かどうかを確認
   * @returns 常にtrue（モック実装）
   */
  async isAvailable(): Promise<boolean> {
    return true;
  }
}

// Singleton instance for easy access
export const mockHealthRepository = new MockHealthRepository();
