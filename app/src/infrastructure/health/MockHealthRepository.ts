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

  constructor(options?: { simulateDelay?: boolean }) {
    this.simulateDelay = options?.simulateDelay ?? true;
  }

  private async delay(ms: number): Promise<void> {
    if (this.simulateDelay) {
      await new Promise((resolve) => setTimeout(resolve, ms));
    }
  }

  async getAuthorizationStatus(): Promise<HealthAuthorizationStatus> {
    return {
      isAuthorized: this.isAuthorized,
      canRequestAuthorization: true,
    };
  }

  async requestAuthorization(): Promise<boolean> {
    await this.delay(500);
    this.isAuthorized = true;
    return true;
  }

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

  async fetchSleepHistory(days: number): Promise<SleepMetrics[]> {
    await this.delay(300);

    // Generate mock sleep history
    const history: SleepMetrics[] = [];
    const baseDate = new Date();

    for (let i = 0; i < days; i++) {
      const date = new Date(baseDate);
      date.setDate(date.getDate() - i);

      // Add some variation to the mock data
      const variation = Math.random() * 0.2 - 0.1; // -10% to +10%

      history.push({
        bedtime: new Date(date.setHours(23, Math.floor(Math.random() * 30), 0, 0)),
        wakeTime: new Date(date.setHours(6, 30 + Math.floor(Math.random() * 30), 0, 0)),
        durationMinutes: Math.round(MOCK_SLEEP_METRICS.durationMinutes * (1 + variation)),
        deepSleepMinutes: Math.round(MOCK_SLEEP_METRICS.deepSleepMinutes * (1 + variation)),
        remSleepMinutes: Math.round(MOCK_SLEEP_METRICS.remSleepMinutes * (1 + variation)),
      });
    }

    return history;
  }

  async isAvailable(): Promise<boolean> {
    return true;
  }
}

// Singleton instance for easy access
export const mockHealthRepository = new MockHealthRepository();
