/**
 * Health Data Repository Interface
 * Abstracts health data access for cross-platform support
 */

import {
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  HealthMetrics,
} from '../../domain/models';

export interface HealthAuthorizationStatus {
  isAuthorized: boolean;
  canRequestAuthorization: boolean;
  deniedPermissions?: string[];
}

export interface HealthRepository {
  /**
   * Check current authorization status
   */
  getAuthorizationStatus(): Promise<HealthAuthorizationStatus>;

  /**
   * Request authorization for health data access
   * @returns true if authorization was granted
   */
  requestAuthorization(): Promise<boolean>;

  /**
   * Fetch today's health metrics
   */
  fetchTodayMetrics(): Promise<HealthMetrics>;

  /**
   * Fetch sleep data for a specific date
   */
  fetchSleepMetrics(date: Date): Promise<SleepMetrics | null>;

  /**
   * Fetch HRV data for a specific date
   */
  fetchHRVMetrics(date: Date): Promise<HRVMetrics | null>;

  /**
   * Fetch activity data for a specific date
   */
  fetchActivityMetrics(date: Date): Promise<ActivityMetrics | null>;

  /**
   * Fetch sleep history for the past N days
   */
  fetchSleepHistory(days: number): Promise<SleepMetrics[]>;

  /**
   * Check if health data is available on this device
   */
  isAvailable(): Promise<boolean>;
}
